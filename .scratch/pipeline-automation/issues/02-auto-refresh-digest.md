# Auto-refresh digest — cron lệch-pha, fan-out per-user

Status: done

## Parent

`.scratch/pipeline-automation/PRD.md`

## What to build

Cho digest hôm nay của mỗi operator tự làm mới theo nhịp, không cần bấm "Tạo digest". Một cron lệch pha sau cron fetch, fan-out mỗi User một job.

- **Queue mới `digest_refresh`** trong cấu hình Oban, tách khỏi `article_summarize` để refresh không kẹt sau hàng dài summarize.
- **Dispatcher cron refresh:** một worker mới (vd `Readout.Workers.DigestRefreshCronWorker`) lặp qua **chỉ User-có-Source** (`JOIN user_sources`, distinct `user_id`) → enqueue một `DigestRefreshWorker(user_id)` mỗi user. Crontab `"30 */3 * * *"` (UTC) — lệch ~30' sau cron fetch để pipeline kịp tiêu hóa Summary của vòng đó và rải tải RPM Gemini.
- **Worker per-user `DigestRefreshWorker`:** nhận `user_id`, **dựng `Scope` cho đúng một user**, gọi `Curation.generate_digest(scope, Date.utc_today())`. Wrapper mỏng — không chứa logic digest (đã ở `Curation`, vốn idempotent + guard "chỉ hôm nay").

**Constraint riêng tư (bắt buộc, ADR 0010):**
- `DigestRefreshWorker` xử lý **đúng một user mỗi job** và **chỉ đi qua `Curation.generate_digest`** (vốn lọc `user_source.user_id == ^scope.user.id`). **Cấm** query gộp nhiều user ở tầng cron. Fan-out per-user chính là lá chắn: một job = một user = một Scope.
- Log/telemetry của cron **không dump nội dung Summary hay danh sách Article của user** — chỉ đếm/aggregate.

Vì `generate_digest` idempotent, một vòng refresh "hụt" Summary chưa kịp tóm tắt xong sẽ được vòng sau vá vào. Không đổi schema, không migration.

## Acceptance criteria

- [ ] Queue `digest_refresh` được thêm vào cấu hình Oban.
- [ ] `DigestRefreshCronWorker` lặp qua **chỉ User-có-Source** (distinct), bỏ qua user không có Source; enqueue một `DigestRefreshWorker(user_id)` mỗi user; đăng ký crontab `"30 */3 * * *"`.
- [ ] `DigestRefreshWorker` dựng `Scope` cho đúng một user và gọi `Curation.generate_digest(scope, Date.utc_today())`; không chứa logic tuyển chọn digest.
- [ ] Tầng cron **không** có query gộp nhiều user; mỗi job đúng một user.
- [ ] Log của cron không ghi nội dung Summary / danh sách Article của user (chỉ đếm/aggregate).
- [ ] **Seam #3 (fan-out digest):** với User-A và User-B đều có Source, User-C không Source → chạy dispatcher → `assert_enqueued` đúng một `DigestRefreshWorker` cho A và cho B, `refute_enqueued` cho C.
- [ ] Test theo `Oban testing: :manual`; không re-test logic `generate_digest` (đã có ở `curation_test`).
- [ ] Suite hiện có vẫn xanh.

## Blocked by

- `.scratch/pipeline-automation/issues/01-auto-content-pipeline.md` — Slice 1 bật Oban Cron plugin (Slice 2 chỉ thêm crontab + queue), và cần pipeline sinh Summary để refresh có tác dụng thật.
