# Product Requirement Document (PRD): Readout Phoenix Monolith Rewrite

Tài liệu yêu cầu sản phẩm này phác thảo các mục tiêu, câu chuyện người dùng (user stories), quyết định thiết kế kỹ thuật và kế hoạch kiểm thử cho việc rewrite hệ thống Readout từ kiến trúc serverless cũ sang nền tảng Phoenix LiveView monolith đa người dùng.

---

## Problem Statement

Kiến trúc hiện tại của Readout được xây dựng như một công cụ cá nhân tự lưu trữ (single-user personal tool) chạy trên Cloudflare Workers, Hono, SvelteKit và D1 database. Khi chuyển dịch sản phẩm thành một nền tảng Web cho nhiều người dùng (multi-user SaaS), hệ thống hiện tại bộc lộ nhiều điểm hạn chế:
1. **Thiếu cơ chế định danh người dùng**: Xác thực hiện tại sử dụng một API admin key dùng chung (`X-Admin-Key`), không hỗ trợ quản lý nhiều tài khoản riêng biệt.
2. **Thiếu cơ chế cá nhân hóa**: Dữ liệu bảng `digests` và `sources` được thiết kế ở mức toàn cục (global), khiến tất cả người dùng bắt buộc phải dùng chung một danh sách nguồn tin và nhận cùng một bản tin mỗi ngày.
3. **Môi trường Job nền kém bền bỉ**: Việc cào tin và gọi AI trên serverless cron/queue dễ gặp rủi ro quá tải wall-time, mất trạng thái khi restart, khó quản lý lỗi và cấu hình retry.
4. **Hóa đơn AI khó kiểm soát**: Hệ thống chưa có cơ chế ghi nhận lượng token tiêu thụ và chi phí ước tính theo từng user để ngăn chặn tình trạng lạm dụng tài nguyên.

---

## Solution

Tái cấu trúc và rewrite Readout dưới dạng một ứng dụng **monolith** chạy trên **Phoenix LiveView** và database **PostgreSQL** quan hệ, kết hợp thư viện **Oban** làm job engine nền bền bỉ.
1. **Định danh và Phân tách**: Tách dữ liệu Ingestion dùng chung (sources, articles, summaries) khỏi dữ liệu cá nhân của người dùng (user_sources, digests, read/saved articles) bằng các unique constraints ở tầng Postgres.
2. **Giao diện thời gian thực**: Sử dụng LiveView cập nhật trạng thái cào tin và sinh digest trực tiếp qua WebSocket mà không cần xây dựng REST API trung gian hay quản lý state SPA phức tạp.
3. **Vận hành tin cậy**: Oban đảm bảo các tác vụ cào tin và tóm tắt AI được persist trong DB, tự động retry với exponential backoff khi gặp lỗi mạng tạm thời hoặc rate-limit.

---

## User Stories

### Quản lý Tài khoản (Accounts)
1. **As a** new user, **I want to** register an account using my email and password, **so that** I can have a private space to customize my news feed.
2. **As a** registered user, **I want to** log in securely, **so that** I can access my personalized digests across different devices.
3. **As a** logged-in user, **I want to** log out of my account, **so that** my data remains secure on public or shared computers.
4. **As a** user, **I want to** reset my password via a secure email flow, **so that** I can regain access if I forget my login credentials.

### Quản lý Nguồn tin (Sources)
5. **As a** user, **I want to** subscribe to an RSS feed by inputting its URL and an optional custom name, **so that** its articles are included in my ingestion list.
6. **As a** user, **I want to** view a list of all my active source subscriptions, **so that** I can keep track of where my daily news comes from.
7. **As a** user, **I want to** unsubscribe from a source, **so that** its articles stop appearing in my upcoming daily digests.
8. **As a** developer, **I want the system to** check if an RSS feed URL is already registered globally, **so that** we only fetch and parse the feed once for all users.

### Bản tin cá nhân hóa (Digests & Reader)
9. **As a** user, **I want to** receive a single consolidated digest daily on my dashboard, **so that** I can catch up on all my news in under 5 minutes.
10. **As a** user, **I want to** see a color-coded "hot score" (1-100) next to each article in my digest, **so that** I can prioritize reading the most critical stories first.
11. **As a** user, **I want to** read a clean AI-generated summary and tags for each article, **so that** I can understand the core context without clicking the original link.
12. **As a** user, **I want to** click a button to mark an article in my digest as "read", **so that** it gets visually dimmed and I can focus on unread content.
13. **As a** user, **I want to** bookmark/save an article, **so that** I can easily refer back to it later in a dedicated "Saved" section.
14. **As a** user, **I want to** manually trigger a "Regenerate Digest" action on my dashboard, **so that** my digest updates instantly with the latest cào được trong ngày.

### Quản trị & Vận hành (Admin & Operations)
15. **As an** administrator, **I want to** monitor the AI token usage and estimated cost of each user, **so that** I can prevent system abuse and manage operating costs.
16. **As an** administrator, **I want to** view the status of background queues (success, failure, retry), **so that** I can diagnose scraping errors or API downtime promptly.

---

## Implementation Decisions

### Kiến trúc Contexts (Domain Design)
*   **Accounts Context**: Đóng gói schema `User`, logic xác thực session và `Accounts.Scope`. Scope mang identity của User từ session vào các context function xử lý dữ liệu thuộc User.
*   **Ingestion Context**: 
    *   Quản lý schema `Source`, `Article`, và `ArticleContent`.
    *   Trích xuất bài viết từ RSS XML sử dụng parser tự viết bằng thư viện `Floki` để giữ zero-dependency.
    *   Cào nội dung HTML gốc và trích xuất paragraph text (`<p>`) bằng `Floki` để lọc rác và tiết kiệm input token cho LLM.
*   **Analysis Context**:
    *   Quản lý schema `ArticleSummary` và bảng thống kê chi phí `AiUsage`.
    *   Giao tiếp với Gemini API thông qua REST API dùng client `Req`.
    *   Sử dụng cấu hình API JSON Mode kết hợp System Instruction và hàm làm sạch markdown wrapper ở code Elixir để nhận về JSON chuẩn xác tuyệt đối.
*   **Personalization Context**:
    *   Quản lý bảng liên kết `UserSource` và lập chỉ mục `Digest`, `DigestItem` theo từng cặp `(user_id, digest_date)`.

### Database Schema (PostgreSQL)
Thiết lập các ràng buộc dữ liệu nghiêm ngặt:
*   `sources`: `canonical_url` UNIQUE.
*   `articles`: `(source_id, canonical_url)` UNIQUE (check trùng bài viết).
*   `user_sources`: `(user_id, source_id)` UNIQUE.
*   `digests`: `(user_id, digest_date)` UNIQUE.
*   `digest_items`: `(digest_id, article_id)` UNIQUE.
*   `articles.published_at` sử dụng UTC datetime; timestamp từ RSS/Atom được chuẩn hóa trước khi ghi vào database.
*   `raw_content` được lưu tạm thời dưới dạng trường `:text` trong bảng `articles` cho prototype.

### Công việc nền (Oban Job Queues)
*   `source_fetch`: Cron định kỳ fetch RSS XML.
*   `article_scrape`: Tải HTML bài viết và trích xuất paragraph text.
*   `article_summarize`: Gọi Gemini API tóm tắt với concurrency limit được cấu hình chặt chẽ để chống quá tải rate limit của API.
*   `digest_generate`: Tổng hợp các bài viết đã được tóm tắt trong ngày thuộc các sources của user để tạo bản tin cá nhân hóa.

---

## Testing Decisions

### Chiến lược Kiểm thử
Chúng ta sẽ tập trung viết unit và integration tests kiểm thử các hành vi bên ngoài (external behaviors) và các trường hợp lỗi dữ liệu quan trọng thay vì test chi tiết triển khai nội bộ:

1.  **Phân tích RSS XML**: Viết test đảm bảo hàm parse XML bằng `Floki` bóc tách chính xác các trường `title`, `link`, `pubDate` từ cả hai định dạng RSS và Atom.
2.  **Trích xuất Paragraph HTML**: Test hàm trích xuất văn bản của `Floki` lọc sạch các thẻ rác, lấy đúng text trong `<p>` và ghép lại thành chuỗi hoàn chỉnh.
3.  **Gemini JSON Parser**: Mock API response từ Gemini (cả dạng JSON chuẩn và dạng bị lỗi bọc mã code markdown) để kiểm thử hàm `clean_json` và decode JSON thành Map.
4.  **Ràng buộc Unique DB**: Test Ecto migration đảm bảo các nỗ lực ghi đè hoặc ghi trùng lặp bài viết (`articles`), đăng ký nguồn (`user_sources`) sẽ kích hoạt lỗi constraint ở tầng database.

---

## Out of Scope (Ngoài phạm vi Prototype)

*   **Tích hợp thanh toán**: Chưa tích hợp Stripe hay thiết lập các gói subscription trả phí.
*   **Search Engine ngoài**: Không cài đặt Meilisearch hay Elasticsearch; tạm thời chỉ dùng SQL `LIKE` hoặc Full-Text Search có sẵn của Postgres.
*   **Object Storage**: Chưa kết nối với Cloudflare R2 hay Amazon S3; toàn bộ text thô được lưu tạm trực tiếp trong PostgreSQL.
*   **Hệ thống gửi Email**: Chưa tích hợp Resend/Postmark hay gửi digest qua email hàng ngày.
*   **Browser Extension / Scraping Reddit**: Tạm thời loại bỏ các nguồn tin cần cào qua client-side extension hoặc các trang chặn IP ngặt nghèo.

---

## Further Notes

*   Quyết định chọn `Req` và `Floki` giúp tối giản hóa danh sách thư viện phụ thuộc (`mix.exs`), làm giảm thời gian compile và giữ môi trường phát triển của ứng dụng gọn gàng nhất có thể.
