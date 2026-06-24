# Daily digest end-to-end: context `Curation` + `/digest` cho operator

Status: done

## Parent

`.scratch/daily-digest/PRD.md`

## What to build

Tracer bullet xuyên mọi tầng: operator mở `/digest`, bấm "Tạo digest hôm nay", và thấy một bản tin gom các **Summary** đủ điều kiện của hôm nay từ các **Source** mình đang subscribe.

Hành vi demoable: ẩn danh vào `/digest` → đá sang `/users/log-in`; đã-login mà chưa có gì → empty-state; có Summary hoàn tất hôm nay cho nguồn đã subscribe → bấm tạo → bài hiện trong digest kèm summary text + tag; nguồn không subscribe không lọt vào; bấm tạo nhiều lần không nhân đôi. Digest hôm nay *lớn dần* khi có thêm Summary rồi tạo lại; digest ngày đã qua không ghi được nữa.

Đi trọn đường: migration `digests` + `digest_items` → context mới `Curation` (`Digest`, `DigestItem`, `generate_digest/2`, hàm đọc digest hôm nay) → router gate `/digest` → LiveView `/digest` + nút tạo → 2 seam test.

Chi tiết (theo **ADR 0009**, auth nền theo **ADR 0008**):

- **Context `Curation`**: chứa `Digest` + `DigestItem`. Chỉ *đọc* từ `Ingestion` (`UserSource`) và `Analysis` (`Summary`); **không sửa** hai context đó, không thêm `user_id` vào `Analysis`.
- **`Digest`**: thuộc một User cho một `date` (kiểu `:date`). `has_many` `DigestItem`. **Unique `(user_id, date)`**. Open/closed **không lưu cột** — suy ra `date < hôm nay`.
- **`DigestItem`**: thuộc một `Digest`, **trỏ `summary_id`** (pointer, không copy chữ). **Unique `(digest_id, summary_id)`**.
- **`Curation.generate_digest(scope, date)`** — idempotent upsert theo `(user, date)`:
  - **Guard quá khứ**: `date != hôm nay (UTC)` → no-op (đường ghi duy nhất, invariant enforce tại đây).
  - **Tuyển chọn**: mọi `Summary` có `inserted_at` thuộc ngày UTC `date` **VÀ** Article của nó thuộc Source mà `scope.user` subscribe.
  - **Upsert**: ensure một `Digest` cho `(user, date)` kể cả khi rỗng; insert `DigestItem` còn thiếu (`on_conflict: :nothing` trên `(digest_id, summary_id)`).
- **Hàm đọc digest hôm nay** của `scope.user`: preload Summary + Article (title, published_at) + tags, xếp `published_at` desc; trả về rỗng khi chưa có item.
- **`/digest` LiveView**: mount đọc `current_scope.user`; nút "Tạo digest hôm nay" gọi `generate_digest(scope, today)` rồi đọc lại + render. **Không real-time**. Tái dùng cách render Summary + tags ở `/demo`.
- **Router**: `/digest` trong **`live_session :require_authenticated_user`**, `pipe_through [:browser, :require_authenticated_user]`, `on_mount {ReadoutWeb.UserAuth, :require_authenticated}` — vì digest per-operator đọc từ `current_scope.user`.
- **Ngày tính theo UTC**.

## Acceptance criteria

- [ ] Migration tạo `digests` (binary_id) với unique `(user_id, date)` và `digest_items` với unique `(digest_id, summary_id)`
- [ ] Context `Curation` chứa `Digest`, `DigestItem`; không sửa `Ingestion`/`Analysis`, không thêm `user_id` vào `Analysis`
- [ ] `DigestItem` trỏ `summary_id` (pointer), không copy `summary_text`/`tags`
- [ ] `generate_digest(scope, date)` chọn Summary theo `inserted_at` thuộc ngày `date` (UTC) **và** Article thuộc Source mà user subscribe
- [ ] `generate_digest` idempotent: gọi lại nhiều lần cho hôm nay → một `Digest`, không trùng `DigestItem`
- [ ] `generate_digest(scope, ngày_quá_khứ)` → no-op (không tạo/sửa digest ngày đã qua)
- [ ] Hôm nay không có Summary đủ điều kiện → vẫn upsert một `Digest` rỗng cho `(user, hôm nay)`
- [ ] `/digest` đặt trong `live_session :require_authenticated_user`; ẩn danh truy cập → redirect `/users/log-in`
- [ ] `/digest` đã-login: empty-state khi chưa có; sau khi bấm tạo, hiển thị đúng Summary (text + tag) của hôm nay, xếp `published_at` desc
- [ ] Summary của Source operator **không** subscribe không xuất hiện trong digest
- [ ] **Seam 1** (`/digest` LiveView, tiền lệ `demo_live_test.exs`): redirect ẩn danh; empty-state; bấm tạo hiện bài nguồn-subscribe; nguồn-không-subscribe vắng mặt; bấm 2 lần không nhân đôi
- [ ] **Seam 2** (context `Curation`, tiền lệ `ingestion_test.exs`/`analysis_test.exs`): cửa sổ chọn (hôm nay vào / backdate hôm qua loại / nguồn không subscribe loại); idempotent; guard quá khứ no-op; digest rỗng vẫn upsert
- [ ] Không re-test máy móc Ecto/Oban/gen.auth
- [ ] `mix test` xanh

## Blocked by

None - can start immediately
