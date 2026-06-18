# Product Requirement Document (PRD): Readout LiveView Demo Slice

Tài liệu yêu cầu sản phẩm này phác thảo các mục tiêu, câu chuyện người dùng (user stories), các quyết định kỹ thuật và kế hoạch kiểm thử cho tính năng **Vertical Slice LiveView Demo** tối giản của hệ thống Readout.

---

## Problem Statement

Để chuyển đổi kiến trúc serverless cũ sang Phoenix LiveView monolith, nhà phát triển cần kiểm thử và xác thực sự phối hợp đồng bộ giữa cơ sở dữ liệu (Ecto), xử lý tác vụ nền (Oban), và đồng bộ hóa giao diện thời gian thực (LiveView WebSockets). Việc triển khai toàn bộ hệ thống (bao gồm xác thực người dùng, tích hợp AI, và tổng hợp bản tin) cùng một lúc sẽ dẫn đến sự phức tạp không cần thiết (overkill) và làm chậm quá trình phản hồi/kiểm chứng thiết kế kiến trúc ban đầu.

## Solution

Xây dựng một lát cắt dọc (Vertical Slice) tối giản: **1 trang LiveView duy nhất (`/demo`)** cho phép một User demo thực hiện đăng ký nguồn tin (Source) RSS Feed, hệ thống tự động kích hoạt Oban chạy ngầm để cào bài viết (Articles), và tự động cập nhật danh sách bài viết thời gian thực lên giao diện thông qua Phoenix.PubSub và LiveView streams mà không cần tải lại trang.

## User Stories

1. **As a** developer, **I want** the system to seed and assign a default demo User on page mount, **so that** I can test database interactions without building an authentication flow first.
2. **As a** User, **I want** to see a list of my subscribed news Sources in the left column, **so that** I can easily keep track of my active subscriptions.
3. **As a** User, **I want** to input an RSS feed URL via a form to subscribe to a new Source, **so that** I can add it to my list of news sources.
4. **As a** User, **I want** the system to check the existence and validate the structure of the RSS feed synchronously upon subscription, **so that** I receive immediate errors if the URL is unreachable or not a valid RSS/Atom feed.
5. **As a** User, **I want** the system to handle duplicate subscriptions gracefully, **so that** I don't get double subscriptions to the same feed.
6. **As a** User, **I want** the system to automatically enqueue a background job (`SourceFetchWorker`) upon subscription, **so that** the initial feed ingestion happens asynchronously.
7. **As a** User, **I want** to see a list of the latest 20 articles from all my subscribed sources in the right column, **so that** I can catch up on the newest stories.
8. **As a** User, **I want** the list of articles to update dynamically (prepending new items) when the background fetch completes, **so that** I see new articles instantly without manual page refreshes.

## Implementation Decisions

### Modules to Build/Modify
- **`Readout.Accounts`**: Sẽ được bổ sung logic hỗ trợ seed và truy vấn tài khoản demo cố định `demo@readout.local`. User demo được bọc trong `Readout.Accounts.Scope` trước khi gọi các hành vi thuộc User.
- **`Readout.Ingestion`**: 
  - Các hàm đăng ký và truy vấn dữ liệu thuộc User nhận `Readout.Accounts.Scope` làm tham số đầu tiên.
  - Nâng cấp hàm `subscribe_source/2` để thực hiện gọi HTTP GET (qua `Readout.HTTP.get/1`) và kiểm tra XML structure (qua `FeedParser.parse/1`) trước khi tiến hành ghi vào DB.
  - Trả về mã lỗi rõ ràng (`:invalid_source_url`, `{:feed_unreachable, status}`, `:invalid_rss_format`) nếu việc kiểm tra thất bại.
- **`Readout.Ingestion.SourceFetcher`**: Thực hiện fetch, insert Articles và broadcast thông báo hoàn thành đến topic của Source: `"source:#{source_id}:fetched"`.
- **`Readout.Workers.SourceFetchWorker`**: Là Oban adapter mỏng gọi `SourceFetcher` và chuyển kết quả thành retry/cancel semantics của Oban.
- **`ReadoutWeb.DemoLive`**: LiveView module được mount tại route `live "/demo", DemoLive`. Module này sẽ xử lý việc đăng ký kênh PubSub cho các Source của User và dùng LiveView `streams` để quản lý danh sách Articles hiển thị trên UI.

### Database Schema Decisions
- Sử dụng các bảng hiện có (`users`, `sources`, `user_sources`, `articles`) cùng các ràng buộc duy nhất (Unique Constraints) đã định nghĩa trong DB.
- Chuẩn hóa `articles.published_at` từ RSS/Atom thành UTC datetime trước khi lưu để truy vấn và sắp xếp nhất quán.
- Không cần tạo bảng mới trong phase này.

### Interactions & API Contracts
- **PubSub Topic Structure**: Sử dụng cấu trúc hướng nguồn (Source-centric) `"source:#{source_id}:fetched"`. Tin nhắn truyền tải sẽ là map hoặc tuple đơn giản: `{:articles_fetched, source_id}`.
- **Giao diện**: Sử dụng TailwindCSS v3 được thiết lập sẵn trong dự án để chia bố cục 2 cột (Trái: Quản lý nguồn tin; Phải: Danh sách bài viết).

## Testing Decisions

### Seams for Testing
Chúng ta sẽ tập trung viết kiểm thử tích hợp ở mức cao nhất có thể (Highest Seam) thông qua Phoenix LiveView Test Helpers:

1. **Integration Test cho LiveView (DemoLiveTest)**:
   - **Mount**: Đảm bảo khi truy cập `/demo`, LiveView gán đúng demo user vào socket, hiển thị đúng danh sách source và articles đang có.
   - **Subscription Form**: Giả lập điền một URL không hợp lệ -> Kiểm tra xem lỗi changeset/validation có hiển thị đúng dưới input.
   - **PubSub & Stream Update**: Render LiveView trong môi trường test, sau đó giả lập gửi tin nhắn PubSub `{:articles_fetched, source_id}` từ test process -> Kiểm tra xem LiveView có tự động chèn thêm (prepend) bài viết mới vào DOM và hiển thị mà không cần reload.

2. **Unit Test cho Ingestion Context**:
   - Mock HTTP client (`Req` hoặc `Readout.HTTP` thông qua config/test) để test hành vi của `subscribe_source/2` khi gặp feed bị 404, 500, timeout hoặc XML bị lỗi cú pháp.

## Out of Scope

- Hệ thống xác thực người dùng (Login, Register, Logout, Password reset).
- Triển khai Worker cào nội dung chi tiết bài viết (`ArticleScrapeWorker`).
- Tích hợp Gemini AI Client, tóm tắt tin tức, phân loại tag và đo lường token/cost.
- Tổng hợp bản tin cá nhân hóa (`Digest` và `DigestItem`).
- Giao diện Admin quản trị và giám sát Oban Queue.

## Further Notes

- Việc lựa chọn phương án bất đồng bộ bằng Oban kết hợp PubSub giúp đảm bảo cấu trúc nền tảng không thay đổi khi chúng ta tiến hành tích hợp sâu AI ở các giai đoạn sau.
