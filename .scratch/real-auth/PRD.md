# Real Auth — login thật cho operator, thay user hardcode

Status: ready-for-agent

## Problem Statement

Hiện app không có xác thực. `/demo` mở công khai và mọi phiên đều chạy dưới một User hardcode (`get_or_create_demo_user/0`, email `demo@readout.local`). Không ai thực sự "đăng nhập"; không có ranh giới giữa người dùng và dữ liệu của họ ở tầng phiên. Là chủ hệ thống, tôi cần đăng nhập như một User thật để app vận hành theo đúng danh tính của tôi, và để nền tảng này về sau mở được cho nhiều người mà không phải xây lại.

## Solution

Dựng xác thực bằng `mix phx.gen.auth` với **magic-link** (cơ chế chính, đúng default Phoenix 1.8). Giai đoạn này phục vụ **một operator** (xem ADR 0008): chưa mở đăng ký công khai, operator được seed sẵn, magic-link gửi qua dev mailbox của Swoosh.

Sau khi đăng nhập, `/demo` (và `/users/settings`) yêu cầu phiên hợp lệ; `/` để landing công khai. App đọc danh tính từ `current_scope.user` của phiên thay vì User hardcode. Khái niệm "demo user" bị gỡ bỏ hoàn toàn. Vì `Ingestion` đã scope-aware sẵn, app tự động chỉ hiển thị Source/Article của User đang đăng nhập.

Nền do generator dựng đã là nền multi-user; nâng lên public sau này là cộng dồn (mở lại route đăng ký, cắm email adapter thật, bật các lớp bảo vệ), không phải viết lại.

## User Stories

1. Là operator, tôi muốn đăng nhập bằng magic-link gửi tới email, để truy cập app như một User thật thay vì danh tính hardcode.
2. Là operator, tôi muốn nhập email ở trang log-in và nhận một link đăng nhập, để vào phiên mà không cần nhớ mật khẩu.
3. Là operator (môi trường dev), tôi muốn đọc magic-link ở `/dev/mailbox`, để đăng nhập được mà không cần cấu hình email service thật.
4. Là operator chưa đăng nhập, khi truy cập `/demo` tôi muốn bị chuyển hướng sang trang log-in, để vùng app được bảo vệ.
5. Là operator đã đăng nhập, tôi muốn `/demo` hiển thị đúng Source và Article của chính tôi, để app phản ánh dữ liệu của danh tính tôi.
6. Là operator đã đăng nhập, khi truy cập `/` tôi muốn được chuyển hướng sang `/demo`, để không phải thấy lại landing.
7. Là khách ẩn danh, tôi muốn xem được landing `/`, để biết app là gì trước khi đăng nhập.
8. Là operator, tôi muốn đăng xuất, để kết thúc phiên trên thiết bị hiện tại.
9. Là operator, tôi muốn phiên đăng nhập được giữ qua các lần tải lại trang, để không phải đăng nhập lại liên tục.
10. Là operator, tôi muốn trang `/users/settings` yêu cầu đăng nhập, để cài đặt tài khoản không truy cập được khi chưa xác thực.
11. Là chủ hệ thống, tôi muốn operator được seed sẵn và demo user cũ bị xóa, để khởi động sạch với một danh tính thật duy nhất.
12. Là chủ hệ thống, tôi muốn đăng ký công khai chưa được expose, để giai đoạn này chỉ một operator dùng được.
13. Là chủ hệ thống, tôi muốn nền auth sẵn sàng cho multi-user, để sau này mở public chỉ là cộng dồn cấu hình chứ không viết lại.

## Implementation Decisions

- **Generator**: chạy `mix phx.gen.auth` đầy đủ rồi **merge thủ công** vào `Accounts`/`User`/`Scope` sẵn có. Phần khó-và-nhạy-cảm (hashing, token rotation, session, plug `UserAuth`, LiveView `on_mount` hooks, tích hợp `Scope`) do generator lo, không tự code tay. (ADR 0008)
- **Cơ chế**: magic-link là chính (default 1.8). Password chỉ là tùy chọn "sudo mode" do generator sinh — không bắt buộc đặt ở giai đoạn này.
- **`User` schema**: giữ field `email` sẵn có, nhận thêm các field/`hashed_password`/token mà generator yêu cầu; **giữ association `user_source`** không đứt.
- **`Scope`**: hợp nhất với `Scope` do generator sinh; assign chuẩn là **`:current_scope`**.
- **Email**: Swoosh **dev mailbox** (`/dev/mailbox`) cho giai đoạn này; **không** cắm email adapter thật (defer tới khi public).
- **Đăng ký công khai**: **gỡ route register khỏi router**; code register do generator sinh giữ nguyên, chỉ không expose.
- **Seed**: trong `seeds.exs`, **xóa demo user** và seed **một operator mới** (idempotent). Bỏ `get_or_create_demo_user/0` và `@demo_email`.
- **Router**: `/demo` và `/users/settings` sau `require_authenticated_user` (qua `live_session` + `on_mount`); `/` để công khai; đã-login truy cập `/` → redirect `/demo`; sau login thành công → redirect `/demo`.
- **DemoLive**: bỏ `get_or_create_demo_user()`, đọc `socket.assigns.current_scope`; bỏ các assign `:scope`/`:user` thủ công, dùng `:current_scope` xuyên suốt.
- **Không đụng mô hình sở hữu dữ liệu**: `Ingestion.list_sources/list_articles/subscribe_source` đã nhận `%Scope{}` và lọc theo `user_id` — slice chỉ thay nguồn cấp Scope.

## Testing Decisions

- **Nguyên tắc**: chỉ test hành vi bên ngoài, không test chi tiết triển khai. Không re-test máy móc auth do generator sinh (token rotation, hashing, magic-link delivery, plug `UserAuth`, context `Accounts`) — chúng đã có test riêng của generator.
- **Seam của feature (một, cao nhất)**: integration test ở **`/demo` LiveView** — tái dùng `test/readout_web/live/demo_live_test.exs`, kiểm:
  1. Truy cập **ẩn danh** `/demo` → **redirect** sang `/users/log-in`.
  2. **Đã đăng nhập** → render đúng Source của operator đó (chạy theo `current_scope.user` thật).
- **Migrate test cũ**: 5 test hiện có trong `demo_live_test.exs` dùng `get_or_create_demo_user()` + `live(conn, ~p"/demo")` không đăng nhập → chuyển sang setup `register_and_log_in_user(%{conn: conn})` do generator sinh, lấy chính User đó dựng Scope. Không mở seam mới ở tầng plug/context.
- **Prior art**: `demo_live_test.exs` (LiveView + `Oban.Testing` + `Req.Test` stub) và bộ test do `phx.gen.auth` sinh (`ConnCase` helper `register_and_log_in_user`, `AccountsFixtures`).

## Out of Scope

- Đăng ký công khai / self-service signup (route gỡ, code giữ lại cho sau).
- Email confirmation, password reset, rate-limit chống abuse — thuộc giai đoạn multi-user (A).
- Email adapter thật (SMTP/SendGrid/...) — giai đoạn này chỉ dev mailbox.
- OAuth / social login.
- Phân quyền/role, nhiều operator, admin area.
- Đặt password bắt buộc (chỉ magic-link; password sudo là tùy chọn generator, không ép dùng).

## Further Notes

- Tham chiếu **ADR 0008** (`docs/adr/0008-phx-gen-auth-magic-link-single-operator.md`) cho trade-off B-vs-A và lý do bám sát convention generator.
- Email seed của operator có thể là bất kỳ giá trị nào trong giai đoạn dev (magic-link đọc ở `/dev/mailbox`, không cần sở hữu hộp thư thật) — chốt giá trị cụ thể lúc implement.
- Thuật ngữ **User** theo glossary `CONTEXT.md`; "operator" chỉ là cách gọi User duy nhất ở giai đoạn B, không phải khái niệm domain mới → không thêm vào glossary.
