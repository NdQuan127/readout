# 0008. Auth qua phx.gen.auth + magic-link, giai đoạn single-operator

Chúng tôi dựng xác thực bằng `mix phx.gen.auth` (magic-link là cơ chế chính, đúng default Phoenix 1.8), thay cho user hardcode `get_or_create_demo_user`. Generator được chạy đầy đủ rồi merge thủ công vào `Accounts`/`User`/`Scope` sẵn có, để phần khó-và-nhạy-cảm (hashing, token rotation, session, LiveView `on_mount` hooks, tích hợp `Scope`) do generator lo, không tự code tay.

Phạm vi hiện tại là **một operator** (B), chưa mở multi-user công khai (A):

- **Route đăng ký công khai bị gỡ khỏi router**; code register do generator sinh giữ nguyên, chỉ không expose. Operator được **seed** trực tiếp (idempotent trong `seeds.exs`); demo user cũ bị xóa.
- **Magic-link gửi qua dev mailbox của Swoosh** — chưa cắm email adapter thật. Login = nhập email đã seed → đọc link ở `/dev/mailbox`.
- `/demo` và `/users/settings` khóa sau `require_authenticated_user`; `/` để landing công khai (đã-login vào `/` → redirect `/demo`).

## Trade-off

Chọn B thay vì A để bám risk-retirement: rủi ro cần tháo ở nhánh auth là "app chạy theo `current_scope.user` từ session thay vì user hardcode" — tháo được trọn vẹn với một user thật. Toàn bộ máy móc public signup (email confirm, password reset, rate-limit chống abuse) là bề mặt lớn nhưng không tháo thêm rủi ro nào cho prototype một người, lại phụ thuộc quyết định sản phẩm chưa cần chốt.

Đánh đổi: nâng lên (A) sau này = thêm lại route đăng ký + cắm email adapter thật + bật các lớp bảo vệ — **cộng dồn, không phải viết lại**, vì nền do generator dựng đã là nền multi-user. Đây chính là lý do dùng generator + bám sát convention của nó (assign `:current_scope`, không đặt tên lệch) thay vì tự chế auth tối giản — auth tối giản tự chế mới là thứ vỡ khi upgrade.

Lưu ý: Ingestion context **đã** scope-aware (`list_sources/list_articles/subscribe_source` đều nhận `%Scope{}` và lọc theo `user_id`), nên slice này chỉ thay nguồn cấp Scope, không đụng mô hình sở hữu dữ liệu.
