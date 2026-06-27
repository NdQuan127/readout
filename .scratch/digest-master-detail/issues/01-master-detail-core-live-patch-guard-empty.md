# Master-detail core: list ↔ detail qua live_patch, guard, empty pane, chrome→English

Status: done

## Parent

`.scratch/digest-master-detail/PRD.md` — Slice 1 (Digest master-detail). Tôn trọng
ADR 0011 (M3 bespoke) và ADR 0009 (Curation persisted Digest).

## What to build

Tracer bullet dọc cho master-detail: một đường đầy đủ từ dữ liệu → route → LiveView
2 pane → test, biến `/digest` từ một cột cuộn dọc thành **sidebar danh sách ↔ pane
chi tiết**, responsive cả desktop lẫn mobile, trên nền M3 của Slice 0.

Phạm vi end-to-end:

- **Mở rộng `Curation.get_today_digest`**: preload thêm `article.source` (tên Source)
  cho mỗi mục — **chỉ preload, không đổi schema**; giữ thứ tự `published_at` desc.
- **Route**: thêm `live "/digest/:id", DigestLive` trong **cùng** block
  `live_session :require_authenticated_user` với `/digest` (một LiveView, hai route,
  `live_patch` giữa chúng) — theo quy tắc router/live_session ở AGENTS.md.
- **Viết lại `DigestLive`** thành master-detail:
  - **Master (list)**: mỗi mục là M3 card hiện tên Source, giờ xuất bản, tiêu đề
    Article, Tag; mục đang chọn được làm nổi (active).
  - **Detail (pane)**: Source + giờ + Tag, tiêu đề, **thân Summary render Markdown**
    (tái dùng `render_markdown/1`, vùng thân dùng serif đọc), link "đọc bài gốc"
    (canonical_url).
  - **Chọn bài bằng URL**: list dùng `live_patch` tới `/digest/#{summary.id}`;
    `handle_params/3` phục vụ cả `/digest` và `/digest/:id`, tìm mục có
    `summary.id == id` trong Digest đã load.
  - **Guard**: `id` không thuộc Digest hôm nay của chính User (id bịa hoặc Summary
    của User khác) → `push_patch` về `/digest` (không lỗi). Tận dụng dữ liệu đã lọc
    theo scope từ `get_today_digest` — không truy vấn quyền riêng, tránh N+1.
  - **`/digest` trần**: desktop = pane phải là **empty-state M3 trang trí** ("chọn
    một bài"), **không** auto-chọn bài đầu; mobile = chỉ list.
  - **Responsive**: **cả hai pane luôn trong DOM**; desktop 2 cột; mobile detail là
    slide-over hiện/ẩn bằng class **bound vào assigns** ("có mục đang chọn"),
    transition **CSS thuần** + `prefers-reduced-motion`; **không** scroll hook (list
    không unmount nên giữ vị trí cuộn); nút back mobile `live_patch` về `/digest`.
  - **Giữ event `generate`** (tạo/tạo-lại Digest hôm nay); **empty Digest** →
    empty-state mời tạo.
- **Chrome → tiếng Anh**: đổi mọi copy chrome (tiêu đề màn, nút, empty-state, định
  dạng ngày như "Jun 27"). **Content giữ nguyên**: tiêu đề Article theo nguồn, thân
  Summary theo ngôn ngữ Gemini cấu hình, Tag do model sinh.
- **Selector ổn định cho test**: `#digest-item-<summary_id>` (giữ pattern hiện có),
  `#detail-pane`, `#detail-empty`, `#digest-empty`.

Mô hình trạng thái (từ prototype, rút gọn): mục đang chọn lấy **nguồn sự thật từ URL**
(`/digest/:id`); mobile `detail-open` = (có mục đang chọn); cả list lẫn detail luôn
trong DOM.

## Acceptance criteria

- [ ] `get_today_digest` preload `article.source`; render list/detail không phát sinh N+1.
- [ ] `/digest/:id` tồn tại trong `live_session :require_authenticated_user`; chọn mục trong list `live_patch` đổi URL sang `/digest/#{summary.id}` và detail hiện đúng `summary_text` (render Markdown) của bài đó.
- [ ] Refresh tại `/digest/:id` giữ đúng bài đang đọc; back trình duyệt (mobile) từ detail về list hoạt động.
- [ ] `/digest` trần: desktop hiện `#detail-empty` (không auto-chọn bài); mobile chỉ hiện list.
- [ ] `id` lạ/không thuộc Digest hôm nay của User → `push_patch` về `/digest`, không crash.
- [ ] Mục đang chọn được đánh dấu active trong list; detail có link "đọc bài gốc" (canonical_url).
- [ ] Cả hai pane luôn trong DOM; mobile slide-over + transition CSS, tắt khi `prefers-reduced-motion`; vị trí cuộn list giữ nguyên khi quay lại (không scroll hook).
- [ ] Chrome bằng tiếng Anh (nút, empty-state, ngày); tiêu đề Article + thân Summary + Tag giữ nguyên ngôn ngữ nội dung.
- [ ] Empty Digest → empty-state mời tạo; nút generate vẫn tạo/tạo-lại được.
- [ ] **`summary_fixture` được nhấc ra `test/support/fixtures`** (dựng N Summary qua M Source cho User trong scope), dùng chung bởi test cũ + mới.
- [ ] `digest_live_test` mở rộng, **xanh**, target bằng ID ổn định: selection → `assert_patch ~p"/digest/#{id}"` + detail chứa `summary_text`; `/digest` trần → `#detail-empty`; guard id lạ → `assert_patch` về `/digest`; empty Digest → empty-state; thứ tự `published_at` desc.

## Blocked by

- `.scratch/m3-foundation/issues/02-migrate-layouts-digest-remove-daisyui.md`
