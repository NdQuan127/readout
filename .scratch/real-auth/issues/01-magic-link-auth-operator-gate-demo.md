# Magic-link auth cho operator, khóa `/demo` theo `current_scope`

Status: ready-for-agent

## Parent

`.scratch/real-auth/PRD.md`

## What to build

Tracer bullet end-to-end thay danh tính hardcode bằng đăng nhập magic-link thật cho **một operator**, và khóa vùng app theo phiên. Đi trọn đường: dựng auth bằng `mix phx.gen.auth` (magic-link, default Phoenix 1.8) → merge vào `Accounts`/`User`/`Scope` sẵn có → khóa router → rewire DemoLive đọc `current_scope` → seed operator → migrate test.

Hành vi demoable: mở `/demo` khi chưa đăng nhập bị đá sang `/users/log-in`; nhập email operator đã seed → đọc magic-link ở `/dev/mailbox` → vào phiên → `/demo` hiển thị đúng Source/Article của operator đó (không còn demo user). `/` vẫn là landing công khai; đã-login vào `/` thì redirect `/demo`.

Chi tiết:

- **Generator**: chạy `phx.gen.auth` đầy đủ rồi **merge thủ công**. Phần khó-và-nhạy-cảm (hashing, token rotation, session, plug `UserAuth`, LiveView `on_mount`, tích hợp `Scope`) để generator lo — **không** tự code tay.
- **`User`**: giữ field `email` sẵn có, nhận thêm field generator yêu cầu; **giữ association `user_source`** không đứt.
- **`Scope`**: hợp nhất với `Scope` generator sinh; assign chuẩn **`:current_scope`**.
- **Email**: Swoosh **dev mailbox** (`/dev/mailbox`); **không** cắm adapter email thật.
- **Đăng ký công khai**: **gỡ route register khỏi router**; code register generator sinh giữ nguyên, chỉ không expose.
- **Seed** (`seeds.exs`): **xóa demo user**, seed **một operator mới** (idempotent). Bỏ `get_or_create_demo_user/0` và `@demo_email`.
- **Router**: `/demo` + `/users/settings` sau `require_authenticated_user`; `/` công khai; đã-login vào `/` → redirect `/demo`; sau login thành công → redirect `/demo`.
- **DemoLive**: bỏ `get_or_create_demo_user()`, đọc `socket.assigns.current_scope`; bỏ assign `:scope`/`:user` thủ công.
- **Không đụng ownership**: `Ingestion.list_sources/list_articles/subscribe_source` đã nhận `%Scope{}` lọc theo `user_id` — chỉ thay nguồn cấp Scope.

Theo **ADR 0008** cho trade-off B-vs-A và lý do bám sát convention generator. Thuật ngữ **User** theo `CONTEXT.md`.

## Acceptance criteria

- [ ] `mix phx.gen.auth` được merge: `User` giữ `email` + association `user_source`, hashing/token/session do generator quản
- [ ] `Scope` hợp nhất; toàn bộ chỗ dùng (DemoLive + Ingestion) chạy qua assign `:current_scope`, không còn `:scope`/`:user` thủ công
- [ ] Magic-link gửi qua Swoosh dev mailbox; không cấu hình email adapter thật
- [ ] Route đăng ký công khai bị gỡ khỏi router (code register giữ lại, không expose)
- [ ] `seeds.exs` xóa demo user và seed một operator mới (idempotent); `get_or_create_demo_user/0` + `@demo_email` bị xóa
- [ ] Truy cập ẩn danh `/demo` → redirect `/users/log-in`; `/users/settings` cũng yêu cầu đăng nhập
- [ ] `/` để công khai; operator đã-login vào `/` → redirect `/demo`; sau login thành công → redirect `/demo`
- [ ] DemoLive đọc danh tính từ `current_scope.user`, hiển thị đúng Source/Article của user đó
- [ ] 5 test cũ trong `demo_live_test.exs` migrate sang setup `register_and_log_in_user`; không re-test máy móc auth do generator sinh
- [ ] Thêm assertion seam ở `/demo`: (a) ẩn danh → redirect log-in, (b) đã-login → render Source của đúng operator
- [ ] `mix test` xanh

## Blocked by

None - can start immediately
