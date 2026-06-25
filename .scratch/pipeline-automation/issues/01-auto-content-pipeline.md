# Auto content pipeline — cron fetch + chain fetch→scrape→summarize

Status: done

## Parent

`.scratch/pipeline-automation/PRD.md`

## What to build

Cho khúc content của pipeline tự chảy không cần người bấm: một cron điểm-vào fetch mọi Source định kỳ, và mỗi bài mới fetch về tự đẩy qua scrape rồi summarize.

Hai phần khớp thành một mạch:

- **Đóng gap `fetch→scrape`:** `Readout.Ingestion.SourceFetcher.fetch/1` hiện `insert_all(Article, ..., on_conflict: :nothing, conflict_target: [:source_id, :canonical_url])` chỉ trả count. Thêm `returning: [:id]` để Postgres trả id của **chỉ những hàng thực sự chèn** (bỏ hàng skip do conflict) → đúng tập **bài mới**. `SourceFetcher` rồi enqueue một `ArticleScrapeWorker` cho mỗi id mới. `scrape→summarize` đã chain sẵn (`Ingestion.scrape_article` tự enqueue summarize), nên một lần fetch cascade qua cả chuỗi nội dung. Side-effect enqueue đặt **trong `SourceFetcher`** (context), không ở worker — đồng nhất grain. Giữ nguyên broadcast PubSub `"source:#{id}:fetched"`. `fetch/1` đổi return từ `{:ok, count}` sang xử lý danh sách id mới.
- **Cron fetch điểm-vào:** bật **Oban Cron plugin** trong cấu hình Oban; một dispatcher worker mới (vd `Readout.Workers.SourceFetchCronWorker`) lặp qua **mọi Source** → enqueue một `SourceFetchWorker(source_id)` mỗi nguồn. Crontab `"0 */3 * * *"` (UTC).

Nút thủ công (enqueue-fetch-khi-subscribe, "Tóm tắt") **giữ nguyên** — cron là cộng thêm. Cron + manual cùng đi qua `unique` của các worker nên không tạo job/bài trùng. Không đổi schema, không migration.

Throttle Gemini **ngoài scope**: dựa concurrency 2 + retry-429 sẵn có của `ArticleSummarizeWorker`.

## Acceptance criteria

- [ ] `SourceFetcher.fetch/1` dùng `returning: [:id]`; chỉ enqueue `ArticleScrapeWorker` cho bài **mới chèn**, không cho bài đã tồn tại (conflict).
- [ ] Enqueue scrape diễn ra **trong `SourceFetcher`** (context), không trong worker.
- [ ] Broadcast PubSub `"source:#{id}:fetched"` vẫn hoạt động như trước.
- [ ] Oban Cron plugin được bật trong cấu hình Oban (`config/config.exs`).
- [ ] `SourceFetchCronWorker` lặp qua mọi Source và enqueue một `SourceFetchWorker(source_id)` mỗi nguồn; đăng ký crontab `"0 */3 * * *"`.
- [ ] Nút/luồng thủ công hiện có vẫn chạy song song với cron, không bị thay thế.
- [ ] **Seam #1 (fan-out fetch):** cho N Source, chạy dispatcher → `assert_enqueued` đúng N `SourceFetchWorker` với đúng `source_id`.
- [ ] **Seam #2 (chain fetch→scrape chỉ bài mới):** `SourceFetcher.run/1` với feed có bài mới → `assert_enqueued` `ArticleScrapeWorker` cho từng bài mới; gọi lại với feed toàn-conflict (0 bài mới) → `refute_enqueued`.
- [ ] Test theo `Oban testing: :manual` (chỉ assert enqueue, không chạy job thật); không re-test logic stage đã có test riêng.
- [ ] Suite hiện có vẫn xanh.

## Blocked by

None - can start immediately.
