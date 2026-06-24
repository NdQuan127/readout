# 0009. Context `Curation` và Digest theo ngày dạng artifact lưu trữ

Chúng tôi dựng nhánh daily digest như một **artifact được lưu** (`Digest` + `DigestItem`) trong một context mới `Curation`, thay vì một view tính on-the-fly từ `Ingestion`. Một Digest thuộc về một User cho một ngày cụ thể, gom các Summary đủ điều kiện của ngày đó.

Các quyết định cốt lõi:

- **Context mới `Curation`** (`Readout.Curation.Digest`, `Readout.Curation.DigestItem`). Nó ngồi *trên* và đọc từ `Accounts` (User/Scope), `Ingestion` (`UserSource`), `Analysis` (`Summary`) — phụ thuộc một chiều, không context nào ở dưới biết tới Digest. Đây là viên gạch đầu tiên của tầng tuyển chọn per-user; ranking/lọc theo sở thích sau này về đây.
- **Open hôm nay / closed ngày đã qua.** Đơn vị là **mỗi User × mỗi ngày** (đúng glossary). Digest của hôm nay *sống và lớn dần* — bài về rải rác trong ngày sẽ rơi vào digest đúng khoảnh khắc Summary của nó hoàn tất. Sang ngày mới, digest hôm qua **đóng băng**. Trạng thái đóng/mở **suy ra từ ngày** (`date < hôm nay`), **không có cột status**.
- **Generation = idempotent upsert theo khóa `(User, date)`.** Mọi trigger (tay/cron/event) đều gọi cùng một hàm `generate_digest(scope, date)`; gọi bao nhiêu lần cũng được. Invariant "không ghi vào quá khứ" được enforce tại **đúng một chỗ** — guard trong hàm này (`date != hôm nay` → no-op), không cần DB trigger.
- **Pointer, không snapshot.** `DigestItem` chỉ trỏ `summary_id`, không copy `summary_text`. Thành viên digest cũ đóng băng nhờ guard ngày; nội dung *chữ* không đóng băng nếu re-summarize — chấp nhận được vì luồng đích summarize là một-lần-tự-động lúc bài về, không ai re-summarize bài cũ.
- **Neo thành viên theo lúc Summary sẵn sàng** (`summary.inserted_at`), **không** theo `published_at`. Một Summary đủ điều kiện cho digest hôm nay khi `summary.inserted_at` thuộc ngày UTC hôm nay **VÀ** Article của nó thuộc một Source operator đang subscribe.
- **Trigger thủ công trong slice này** (nút "Tạo digest hôm nay", giống nút "Tóm tắt" ở slice AI). Cron 3h/lần và refresh-khi-có-Summary-mới (PubSub) **defer** — vì hàm sinh đã idempotent nên gắn chúng sau là cộng dồn, không viết lại.
- **Bề mặt**: LiveView `/digest` riêng, trong `live_session :require_authenticated_user` (digest là dữ liệu per-operator, đọc từ `current_scope.user`). Không real-time trong tracer.
- **Chi tiết chốt cứng**: ngày theo **UTC** (tz người dùng để dành multi-user); xếp bài `published_at` desc; `generate_digest` upsert cả Digest **rỗng** cho `(user, hôm nay)`; unique `(user_id, date)` trên `digests` và unique `(digest_id, summary_id)` trên `digest_items` (`on_conflict: :nothing`) — đây là tầng DB làm cho "gọi lại nhiều lần" thành đúng.

## Trade-off

**Artifact lưu trữ thay vì computed view.** Rủi ro cần tháo của nhánh là "ta có thể sinh + lưu + refresh một daily digest" — một view chỉ re-render `Ingestion.list_articles` né mất chính rủi ro đó, và không cho digest quá khứ tính bất biến. Đổi lại: thêm schema + migration + quyết định idempotency — nhưng đó đúng là phần đáng tháo.

**Pointer thay vì snapshot.** Snapshot (copy chữ) cho bất biến tuyệt đối kể cả re-summarize, nhưng nặng và trùng dữ liệu. Vì luồng đích không sinh ra kịch bản re-summarize bài cũ, trả giá snapshot để phòng vệ điều không xảy ra là YAGNI. Nâng lên snapshot sau = thêm cột vào `DigestItem`, cộng dồn.

**Neo theo summary-ready thay vì `published_at`.** Neo `published_at` làm **mất tin**: bài nguồn đăng đêm qua mà sáng nay mới fetch+tóm tắt sẽ không bao giờ vào digest nào (digest hôm qua đã đóng trước khi có nó). Với một bản tin cá nhân, đó là lỗi nặng. "Hôm nay" của digest vì thế là *ngày bản tóm tắt đến tay tôi*, không phải ngày báo đăng — đúng tinh thần "những gì mới với tôi hôm nay".

**Context `Curation` mới thay vì nhét vào `Analysis`, và tên `Curation` thay vì `Personalization`.** Tách context giữ sạch lằn ranh global/personal: `Summary` global ở Analysis, `Digest` personal ở Curation — không để Analysis mọc thêm `user_id`. Tên "Personalization" bị loại vì **overclaim**: nội dung Summary là global, dùng chung mọi User; cái duy nhất per-user là *việc chọn* bài nào vào digest theo nguồn đã follow — tức **tuyển chọn (curation)**, không phải cá-nhân-hóa-nội-dung. `Curation` cũng nối liền bộ ba process-name: Ingestion → Analysis → Curation.

## Ghi chú

- Tham chiếu ADR 0008 cho nền auth single-operator mà nhánh này dựa lên (`current_scope.user`).
- "operator" vẫn chỉ là cách gọi User duy nhất ở giai đoạn B, không phải khái niệm domain mới. `Curation`/`Personalization` là tên *context* (module boundary), không phải từ vựng người dùng → không thêm vào `CONTEXT.md`. Thuật ngữ **Digest**, **Summary**, **Source**, **User** đã có trong glossary, giữ nguyên.
