# 0010. Tự động hóa pipeline: cron điểm-vào + push-chain + cron refresh digest

Chúng tôi cho toàn bộ chuỗi `fetch → scrape → summarize → digest` tự chạy không cần người bấm, bằng một mô hình **hybrid**: cron ở hai đầu *time-driven*, push-chain ở khúc giữa *event-driven*. Đây là nhánh tự động hóa, dựng lên trên các slice đã có (AI pipeline, auth, daily digest — ADR 0009).

Các quyết định cốt lõi:

- **Topology hybrid, không thuần một kiểu.** Mỗi mắt xích đặt theo đúng bản chất kích hoạt của nó:
  - **Re-fetch Source định kỳ → Cron.** Bản chất time-driven ("cứ N giờ quét nguồn"), không sự kiện nào châm ngòi.
  - **fetch → scrape → summarize → Push-chain.** `scrape→summarize` *đã* chain sẵn (`Ingestion.scrape_article` tự enqueue summarize); ta chỉ đóng nốt `fetch→scrape`. Push tránh full-table-scan lặp mỗi nhịp, độ trễ thấp, và `unique` trên các worker đã làm việc enqueue idempotent.
  - **Refresh Digest → Cron.** Time-driven theo nhịp "bản tin"; *và* Summary là global còn Digest là per-user nên một Summary mới fan-out tới nhiều User — chain sẽ lằng nhằng, cron lặp qua User gọn hơn.
  - Loại pull thuần (4 cron quét toàn bảng mỗi nhịp): lãng phí, nghịch grain push sẵn có. Loại push tới tận digest: fan-out per-user không hợp với chain.
- **Đóng `fetch→scrape` bằng `returning: [:id]`.** `SourceFetcher.fetch/1` đổi `insert_all(..., on_conflict: :nothing)` sang thêm `returning: [:id]` — Postgres chỉ trả id của **hàng thực sự chèn** (bỏ hàng bị skip do conflict), tức **chính xác tập bài mới**. `SourceFetcher` rồi `Enum.each` enqueue một `ArticleScrapeWorker` mỗi id mới. Side-effect đặt **trong context `SourceFetcher`**, không ở worker — đồng nhất grain với `scrape_article` tự enqueue summarize. `fetch/1` đổi từ trả `{:ok, count}` sang xử lý danh sách id mới.
- **Hai cron dispatcher fan-out + một worker per-user.**
  - **Cron fetch — mỗi 3h** (`"0 */3 * * *"`, UTC): một dispatcher loop **mọi Source** → enqueue một `SourceFetchWorker(source_id)` mỗi nguồn.
  - **Cron digest — lệch 30'** (`"30 */3 * * *"`, UTC): một dispatcher loop **chỉ User-có-Source** (`JOIN user_sources`, distinct) → enqueue một `DigestRefreshWorker(user_id)` mỗi user. Lệch pha cho pipeline kịp tiêu hóa summary của vòng fetch và để rải tải RPM Gemini.
  - `DigestRefreshWorker(user_id)` dựng `Scope` cho đúng một user rồi gọi `Curation.generate_digest(scope, hôm nay)`.
  - Queue **`digest_refresh` riêng** để refresh không kẹt sau hàng dài `article_summarize`.
- **Constraint riêng tư (mới, bắt buộc).** Cron chạy **không có phiên đăng nhập** — nguồn của `Scope` đổi từ "phiên xác thực" sang "dựng trong worker". Để bất biến phân tách per-user không vỡ:
  1. `DigestRefreshWorker` dựng `Scope` cho **đúng một user** và **bắt buộc đi qua `Curation.generate_digest`** (vốn lọc `user_source.user_id == ^scope.user.id`). **Cấm** query gộp nhiều user. Fan-out per-user (thay vì một job lặp in-process) củng cố chính constraint này: một job = một user = một Scope = một lời gọi.
  2. **Log/telemetry của cron không dump nội dung hay article-list của user** — chỉ đếm/aggregate. Phần nhạy cảm là *việc một user có Summary X* (tiết lộ họ follow gì), nằm ở `digest_items`; cron không mở đường đọc mới (`/digest` vẫn gated `require_authenticated_user`, vẫn chỉ trả `current_scope.user`).
- **Throttle Gemini ngoài scope.** Auto-summarize đẩy nhiều job vào queue `article_summarize` (concurrency 2). Cơ chế chịu RPM đã có: concurrency 2 giới hạn song song + `ArticleSummarizeWorker` retry-on-429/5xx → vượt RPM thì lùi retry, không mất bài. Không thêm rate-limit chủ động (cần Oban Pro hoặc code tay) ở quy mô hiện tại.
- **Manual triggers giữ nguyên.** Tự động hóa **cộng thêm** trigger time-driven, không thay nút "Tóm tắt"/"Tạo digest" thủ công. Cron + manual cùng đi qua `unique` nên không đụng nhau; nút tay vẫn tiện test/debug.

## Trade-off

**Hybrid (hai loại trigger) thay vì một.** Thuần cron hoặc thuần chain chỉ-một-cơ-chế, dễ nói. Nhưng ép cả pipeline vào một kiểu là sai bản chất: điểm-vào và digest *là* time-driven, khúc giữa *là* event-driven. Hybrid trả giá bằng hai loại trigger để mỗi mắt xích đặt đúng chỗ — và bám sát grain push (`scrape→summarize`) đã có, không viết lại.

**`returning: [:id]` thay vì enqueue-mọi-bài.** Enqueue scrape cho mọi bài fetch về rồi dựa `unique`/check-"đã có Content" để no-op thì đơn giản hơn, nhưng mỗi nhịp cron lại châm job cho cả bài cũ — lãng phí job và đụng cửa sổ unique. `returning: [:id]` là đúng-một-thay-đổi tại chính chỗ đứt, lấy chính xác bài mới, giữ batch insert. Loại luôn phương án `insert` từng bài (mất batch, N query).

**Fan-out per-user thay vì một job lặp.** Một job lặp in-process ít job hơn, nhưng một user lỗi có thể chặn/abort cả vòng và retry phải lặp lại user đã xong. Fan-out cô lập lỗi, retry đúng user, và khớp đúng mô hình fetch fan-out (cron → N job) — đổi lại N job mỗi vòng, rẻ với queue. Quan trọng hơn: nó *là* lá chắn riêng tư (một job một user).

**Throttle để ngoài.** Rate-limit chủ động chính xác hơn concurrency+retry, nhưng cần Oban Pro (không có) hoặc tự rải `schedule_in`. Ở quy mô vài user/vài nguồn/3h-một-vòng, số summary mỗi vòng nhỏ, concurrency 2 + backoff đã đủ. Cùng nhóm hoãn với "realtime khi đông user". Nâng cấp sau = thêm plugin/rate-limit, cộng dồn.

## Ghi chú

- Tham chiếu ADR 0009: `generate_digest(scope, date)` idempotent + guard "chỉ hôm nay" là tiền đề khiến cron-refresh chỉ-cần-lặp-gọi an toàn (gọi hụt sẽ tự lành vòng sau). Nhánh này hiện thực hóa đúng các trigger mà 0009 đã để ngỏ (cron 3h, refresh khi có Summary mới).
- Realtime/event-driven push (refresh digest ngay khi Summary mới về, qua PubSub) **defer** tới khi đông user — 0009 đã để ngỏ và hybrid không khóa cứng gì cản đường.
- Cron dùng **giờ UTC** (Oban Cron mặc định), nhất quán với digest neo UTC (0009).
- Test ở tầng "tự động hóa = enqueue đúng việc" (`Oban testing: :manual`, `assert_enqueued`), ba seam đúng bằng ba gap vá: fan-out fetch, chain fetch→scrape *chỉ bài mới*, fan-out digest. Nội dung từng stage đã có test riêng nên `DigestRefreshWorker` (wrapper mỏng quanh `generate_digest`) không test lại logic digest. End-to-end mock-nặng để dành.
- Tên module (`Workers.*`, queue `digest_refresh`) là boundary kỹ thuật, không phải từ vựng người dùng → không thêm vào `CONTEXT.md`.
