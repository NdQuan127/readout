# Pipeline Automation — cron fetch → auto-scrape → auto-summarize → auto-refresh digest

Status: ready-for-agent

## Problem Statement

Là operator, toàn bộ pipeline hiện chạy *bằng tay*: tôi phải bấm để fetch nguồn, bấm để tóm tắt, bấm "Tạo digest hôm nay" mới có bản tin. Các nút này dựng ra để *test* từng slice, nhưng mục đích thật là tôi mở app lên và **đọc** — không ai đi bấm thủ công từng bước mỗi vài giờ. Hơn nữa tin từ các Source tôi follow về **rải rác trong ngày** ở những khung giờ khác nhau; kể cả khi tôi chịu khó bấm, tôi cũng không thể canh đúng lúc mỗi bài về. Tôi cần pipeline tự chạy theo nhịp để digest hôm nay tự lớn dần mà tôi không phải đụng tay.

## Solution

Cho cả chuỗi `fetch → scrape → summarize → digest` tự chạy bằng mô hình **hybrid** (ADR 0010): cron ở hai đầu *time-driven*, push-chain ở khúc giữa *event-driven*.

- **Cron fetch (mỗi 3h):** một dispatcher lặp qua mọi Source, enqueue một fetch job mỗi nguồn.
- **Push-chain `fetch → scrape → summarize`:** khi fetch về **bài mới**, `SourceFetcher` tự enqueue scrape cho đúng những bài mới đó; scrape xong tự enqueue summarize (đã có sẵn). Một lần fetch cascade qua cả chuỗi nội dung mà không cần cron riêng cho từng stage.
- **Cron refresh digest (lệch 30' sau fetch):** một dispatcher lặp qua các User-có-Source, enqueue một refresh job mỗi user; mỗi job gọi `Curation.generate_digest(scope, hôm nay)` — vốn đã idempotent.

Các nút thủ công **giữ nguyên** (vẫn tiện test/debug); tự động hóa là *cộng thêm* trigger, không thay thế. Không có UI mới — đây là nhánh hạ tầng: digest hôm nay từ nay tự đầy lên mỗi ~3h.

Theo **ADR 0010** cho topology, `returning: [:id]`, fan-out per-user, constraint riêng tư; **ADR 0009** cho `generate_digest` idempotent + guard "chỉ hôm nay" là tiền đề khiến cron-refresh an toàn.

## User Stories

1. Là operator, tôi muốn các Source mình follow được tự fetch định kỳ, để không phải bấm fetch thủ công mỗi vài giờ.
2. Là operator, tôi muốn một bài mới fetch về được tự scrape rồi tự tóm tắt, để có Summary mà không phải bấm nút "Tóm tắt".
3. Là operator, tôi muốn digest hôm nay tự làm mới theo nhịp, để mở app lên là thấy bản tin mới nhất mà không phải bấm "Tạo digest".
4. Là operator, tôi muốn tin về rải rác trong ngày dần dần lọt vào digest hôm nay sau mỗi vòng, để bản tin lớn dần theo ngày một cách tự động.
5. Là chủ hệ thống, tôi muốn cron fetch chạy mỗi 3h, để cân bằng độ tươi của tin với tải/chi phí Gemini.
6. Là chủ hệ thống, tôi muốn vòng fetch chỉ enqueue scrape cho **bài thực sự mới**, để không re-scrape lại bài cũ mỗi nhịp và đốt tài nguyên vô ích.
7. Là chủ hệ thống, tôi muốn cron refresh digest chạy **lệch ~30'** sau cron fetch, để pipeline kịp tiêu hóa Summary của vòng đó trước khi gom digest, và để rải tải request-per-minute của Gemini.
8. Là chủ hệ thống, tôi muốn cron refresh chỉ chạy cho **User có Source**, để không tạo Digest rỗng vô nghĩa cho user chưa onboard.
9. Là operator, tôi muốn mỗi user được refresh trong một job riêng, để lỗi ở dữ liệu của user này không chặn việc refresh của user khác.
10. Là chủ hệ thống, tôi muốn refresh digest đi qua đúng `Curation.generate_digest` cho **đúng một user mỗi job**, để dữ liệu của các operator không bao giờ lẫn vào nhau.
11. Là operator, tôi muốn job nền **không** ghi nội dung bài hay danh sách bài của tôi ra log, để thông tin "tôi follow gì / đọc gì" không bị rò qua log hệ thống.
12. Là chủ hệ thống, tôi muốn cron + nút thủ công cùng đi qua cơ chế `unique`, để chạy chồng cũng không tạo job hay bài trùng.
13. Là chủ hệ thống, khi Gemini trả 429/5xx lúc tóm tắt tự động, tôi muốn job tự lùi lại retry thay vì mất bài, để vượt giới hạn RPM không làm thủng pipeline.
14. Là chủ hệ thống, tôi muốn các nút thủ công (fetch khi subscribe, "Tóm tắt", "Tạo digest") vẫn hoạt động song song với cron, để vẫn debug/test tay được.
15. Là operator, tôi muốn một bài nguồn đăng đêm qua mà vòng fetch sáng nay mới lấy về vẫn được tóm tắt và lọt vào digest hôm nay, để không mất tin (nhờ neo summary-ready của ADR 0009).
16. Là chủ hệ thống, tôi muốn nếu một vòng refresh "hụt" một Summary chưa kịp tóm tắt xong, vòng sau tự vá vào digest, để cuối cùng không bài đủ-điều-kiện nào bị bỏ sót.

## Implementation Decisions

- **Mô hình hybrid** (ADR 0010): cron điểm-vào (fetch) + push-chain (`fetch→scrape→summarize`) + cron refresh (digest). Không thuần pull, không push tới tận digest.
- **Đóng `fetch→scrape` bằng `returning: [:id]`**: `Readout.Ingestion.SourceFetcher.fetch/1` đổi `Repo.insert_all(Article, ..., on_conflict: :nothing, conflict_target: [:source_id, :canonical_url])` thành thêm `returning: [:id]`. Postgres chỉ trả id của **hàng thực sự chèn** (bỏ hàng skip do conflict) → đúng tập bài mới. `SourceFetcher` rồi enqueue một `ArticleScrapeWorker` mỗi id mới. **Side-effect enqueue đặt trong `SourceFetcher`** (context), không ở worker — đồng nhất grain với `Ingestion.scrape_article` tự enqueue summarize. `fetch/1` đổi return từ `{:ok, count}` sang xử lý danh sách id mới (vẫn broadcast PubSub `"source:#{id}:fetched"` như cũ).
- **Cron fetch — dispatcher fan-out, mỗi 3h**: một worker mới (vd `Readout.Workers.SourceFetchCronWorker`) lặp qua **mọi Source** → enqueue một `SourceFetchWorker(source_id)` mỗi nguồn. Đăng ký qua **Oban Cron plugin** với crontab `"0 */3 * * *"` (UTC).
- **Cron refresh digest — dispatcher fan-out, lệch 30'**: một worker mới (vd `Readout.Workers.DigestRefreshCronWorker`) lặp qua **chỉ User-có-Source** (`JOIN user_sources`, distinct user_id) → enqueue một `DigestRefreshWorker(user_id)` mỗi user. Crontab `"30 */3 * * *"` (UTC).
- **Worker per-user `DigestRefreshWorker`**: nhận `user_id`, **dựng `Scope` cho đúng một user** rồi gọi `Curation.generate_digest(scope, Date.utc_today())`. Wrapper mỏng — không chứa logic digest (đã ở `Curation`).
- **Queue mới `digest_refresh`** trong cấu hình Oban (`config/config.exs`), tách khỏi `article_summarize` để refresh không kẹt sau hàng dài summarize. Bật **Oban Cron plugin** trong cùng cấu hình.
- **Constraint riêng tư (ADR 0010)** — bắt buộc:
  - `DigestRefreshWorker` xử lý **đúng một user mỗi job** và **chỉ đi qua `Curation.generate_digest`** (vốn lọc `user_source.user_id == ^scope.user.id`). **Cấm** mọi query gộp nhiều user trong tầng cron. Fan-out per-user chính là lá chắn: một job = một user = một Scope.
  - Log/telemetry của cả hai cron **không dump nội dung Summary hay danh sách Article của user** — chỉ đếm/aggregate (vd "enqueued N jobs").
- **Throttle Gemini ngoài scope**: dựa vào queue `article_summarize` concurrency 2 + `ArticleSummarizeWorker` retry-on-429/5xx sẵn có. Không thêm rate-limit chủ động (cần Oban Pro/không có).
- **Manual triggers giữ nguyên**: nút "Tóm tắt", "Tạo digest", enqueue-fetch-khi-subscribe đều còn. Cron + manual cùng đi qua `unique` của các worker (`SourceFetchWorker` period 60, `ArticleScrapeWorker`/`ArticleSummarizeWorker` period 300) — cadence 3h ≫ các cửa sổ này nên mỗi vòng cron là một lần enqueue hợp lệ, đồng thời không double-enqueue trong cùng vòng.
- **Không đổi schema, không migration**: nhánh này chỉ thêm worker + cấu hình Oban + sửa một hàm `SourceFetcher.fetch/1`. `Curation`/`Digest`/`DigestItem` dùng nguyên.

## Testing Decisions

- **Nguyên tắc**: chỉ test hành vi bên ngoài. Tầng tự-động-hóa chịu trách nhiệm **"enqueue đúng job đúng lúc"** — đó là cái test. Nội dung từng stage (`SourceFetcher`, `scrape_article`, `summarize_article`, `generate_digest`) đã có test riêng ở `ingestion_test.exs` / `analysis_test.exs` / `curation_test.exs`, **không test lại**.
- **Cơ chế**: `config/test.exs` đã `config :readout, Oban, testing: :manual` — không chạy job thật, chỉ `assert_enqueued`/`refute_enqueued`. Tiền lệ: các test worker/enqueue hiện có trong `test/readout/`.
- **Ba seam (đúng bằng ba gap được vá):**
  1. **Fan-out fetch** — cho N Source, chạy `SourceFetchCronWorker.perform/1` → `assert_enqueued` đúng N `SourceFetchWorker`, mỗi cái đúng `source_id`.
  2. **Chain `fetch→scrape` chỉ bài mới** (seam *quan trọng nhất*, logic `returning: [:id]`): gọi `SourceFetcher.run/1` với feed có bài mới → `assert_enqueued` `ArticleScrapeWorker` cho từng bài mới; gọi lại với feed không có bài mới (toàn conflict) → **`refute_enqueued`** (không enqueue scrape thừa).
  3. **Fan-out digest** — có User-A và User-B đều có Source, User-C không Source; chạy `DigestRefreshCronWorker.perform/1` → `assert_enqueued` đúng một `DigestRefreshWorker` cho A và cho B, **`refute_enqueued`** cho C.
- **`DigestRefreshWorker` (wrapper mỏng)**: không test lại logic digest; tối đa một test xác nhận nó gọi `generate_digest` cho đúng user (hoặc tin tưởng wrapper, bỏ qua) — quyết định lúc implement, không bắt buộc.
- **Out of scope cho test**: integration end-to-end chạy `Oban.drain_queue` xuyên cả chuỗi (chạm Gemini/HTTP thật, phải mock nặng) — để dành, không thuộc slice này.

## Out of Scope

- **Throttle/rate-limit Gemini chủ động** (rải `schedule_in`, Oban Pro `rate_limit`) — dựa concurrency 2 + retry-429 sẵn có; nâng cấp khi scale.
- **Realtime / event-driven refresh digest** (refresh ngay khi Summary mới về qua PubSub, thay cho cron lệch-pha) — defer tới khi đông user; ADR 0009/0010 để ngỏ, hybrid không cản đường.
- **Múi giờ người dùng cho nhịp cron** — cron chạy UTC, nhất quán digest neo UTC; per-user timezone thuộc multi-user sau này.
- **UI/observability cho trạng thái pipeline** (dashboard job, lần fetch gần nhất, đếm lỗi) — không trong nhánh hạ tầng này.
- **Backfill/refresh digest ngày quá khứ** — `generate_digest` guard "chỉ hôm nay"; lịch sử bất biến (ADR 0009).
- **Đổi cadence động / per-source cadence** — một nhịp 3h chung cho mọi nguồn.

## Further Notes

- Tham chiếu **ADR 0010** (`docs/adr/0010-automate-pipeline-cron-and-push-chain.md`) cho mọi quyết định lớn + trade-off; **ADR 0009** cho nền `generate_digest` idempotent + guard hôm nay; **ADR 0008** cho auth single-operator.
- Tên `Workers.*` và queue `digest_refresh` là boundary kỹ thuật, không phải từ vựng người dùng → không thêm vào `CONTEXT.md`.
- Cron dùng **giờ UTC** (Oban Cron mặc định). Bật Oban Cron plugin là thay đổi cấu hình Oban đầu tiên kể từ khi dựng 3 queue ban đầu.
- Nhánh này dựng thẳng trên các slice đã hoàn tất (AI pipeline, real-auth, daily digest); không cần thay đổi schema.
