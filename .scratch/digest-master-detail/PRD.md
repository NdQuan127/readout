# Digest master-detail — sidebar danh sách ↔ pane chi tiết, responsive M3

Status: done

> Slice 1 trong cặp "Material 3 UI". **Tiêu thụ nền M3** của Slice 0
> (`.scratch/m3-foundation/`). Reference thị giác sống:
> `priv/prototypes/digest-7.html` + `priv/prototypes/NOTES.md`. Tôn trọng ADR 0011
> (bespoke M3 trên Tailwind v4) và ADR 0009 (Curation context, persisted daily Digest).

## Problem Statement

Là operator, `/digest` hiện là **một cột cuộn dọc**: mỗi Summary đổ thành một khối
dài, đọc hết bài này mới tới bài kia. Khi Digest có nhiều bài, tôi không có cái nhìn
tổng quan để quét nhanh rồi nhảy vào bài muốn đọc; cũng không lọc được theo Source.
Trên điện thoại trải nghiệm càng đuối vì phải cuộn rất dài.

Tôi muốn `/digest` thành **master-detail**: một danh sách bài gọn bên cạnh (quét
nhanh tiêu đề/nguồn) ↔ một pane chi tiết hiển thị Summary của bài đang chọn — hoạt
động mượt cả desktop lẫn mobile, đúng ngôn ngữ Material 3 đã chốt.

## Solution

Viết lại `DigestLive` thành **master-detail responsive** trên nền M3 (Slice 0):

- **Master (list):** danh sách các mục Digest hôm nay — mỗi mục là một M3 card hiện
  tên Source, giờ xuất bản, tiêu đề Article, Tag. Sắp xếp theo `published_at` giảm
  dần (đã có ở Curation).
- **Detail (pane):** Summary của bài đang chọn — Source + giờ + Tag, tiêu đề, **thân
  Summary render Markdown** (tái dùng `render_markdown/1`), và link "đọc bài gốc"
  (canonical_url).
- **Chọn bài bằng URL:** `live_patch` `/digest/:id` với `id = summary.id` (binary_id),
  để back trên mobile đúng nghĩa và giữ chỗ khi refresh. Guard `id` không thuộc Digest
  hôm nay của chính User → `push_patch` về `/digest`.
- **`/digest` trần:** desktop = pane phải là **empty-state M3 có trang trí** ("chọn
  một bài"), **không** auto-chọn bài đầu; mobile = chỉ hiện list.
- **Mobile master-detail:** **cả hai pane luôn trong DOM**; detail là slide-over,
  hiện/ẩn bằng class **bound vào assigns** (có bài đang chọn hay không); transition
  **CSS thuần** + `prefers-reduced-motion`; **không** scroll-restoration hook vì list
  không bị unmount.
- **Lọc Source:** M3 **outlined dropdown** (không phải chip-row), liệt kê các Source
  có mặt trong Digest hôm nay + "All sources"; chọn → list thu hẹp.
- **Tạo lại Digest:** giữ hành động generate (nút "regenerate" cạnh filter); empty
  Digest → empty-state mời tạo.
- **Chrome chuyển sang tiếng Anh** (nav/nút/empty-state/định dạng ngày). **Content
  giữ nguyên:** tiêu đề Article theo nguồn, thân Summary theo ngôn ngữ Gemini cấu
  hình, Tag do model sinh.

## User Stories

1. Là operator, tôi muốn `/digest` hiển thị một danh sách bài gọn bên cạnh, để quét nhanh các Summary hôm nay thay vì cuộn một cột dài.
2. Là operator, tôi muốn mỗi mục trong danh sách hiện tên Source, giờ xuất bản, tiêu đề Article và Tag, để quyết định đọc bài nào mà chưa cần mở.
3. Là operator, tôi muốn bấm vào một mục để xem chi tiết Summary của nó ở pane bên cạnh, để đọc mà không rời màn hình tổng quan.
4. Là operator, tôi muốn pane chi tiết hiện tiêu đề, Source, giờ, Tag và thân Summary đã render Markdown, để đọc bản tóm tắt sạch sẽ, dễ đọc.
5. Là operator, tôi muốn pane chi tiết có link "đọc bài gốc", để mở Article gốc khi muốn đọc đầy đủ.
6. Là operator, tôi muốn URL thay đổi theo bài đang chọn (`/digest/:id`), để refresh trang vẫn giữ đúng bài đang đọc.
7. Là operator trên điện thoại, tôi muốn nút back của trình duyệt đưa tôi từ chi tiết trở lại danh sách, để điều hướng tự nhiên như một app thật.
8. Là operator trên điện thoại, tôi muốn mở một bài là pane chi tiết trượt vào phủ toàn màn, và back để trượt ra, để trải nghiệm gọn trên màn nhỏ.
9. Là operator trên điện thoại, khi quay lại danh sách, tôi muốn vị trí cuộn của danh sách được giữ nguyên, để không phải dò lại chỗ cũ.
10. Là operator trên desktop, tôi muốn thấy đồng thời danh sách và pane chi tiết, để vừa quét vừa đọc.
11. Là operator trên desktop, khi chưa chọn bài (`/digest` trần), tôi muốn pane chi tiết là một empty-state đẹp gợi ý "chọn một bài", để màn không trống trơ.
12. Là operator, tôi muốn mục đang chọn được làm nổi (active) trong danh sách, để biết mình đang đọc bài nào.
13. Là operator, tôi muốn lọc danh sách theo Source qua một dropdown M3, để chỉ xem các bài từ một nguồn.
14. Là operator, tôi muốn dropdown lọc liệt kê các Source thực sự có bài trong Digest hôm nay cộng tùy chọn "tất cả", để lọc không trả về danh sách rỗng vô nghĩa.
15. Là operator, khi tôi đang chọn một bài rồi lọc Source khác, tôi muốn bài đang đọc vẫn hiển thị ở pane chi tiết, để bộ lọc chỉ ảnh hưởng danh sách chứ không cắt mất bài đang đọc.
16. Là operator, khi Digest hôm nay trống, tôi muốn một empty-state mời tôi tạo Digest, để biết cần làm gì.
17. Là operator, tôi muốn nút tạo/tạo-lại Digest hôm nay ngay trên màn, để làm mới danh sách mà không rời trang.
18. Là operator, tôi muốn giao diện theo Material 3 (card, state-layer, ripple, dropdown outlined) đồng nhất với phần còn lại của app, để trải nghiệm liền mạch.
19. Là operator nhạy cảm chuyển động, tôi muốn hiệu ứng slide/ripple tắt khi bật `prefers-reduced-motion`, để không khó chịu.
20. Là chủ hệ thống, tôi muốn `id` trên URL được kiểm thuộc đúng Digest hôm nay của chính User, để không ai đoán UUID xem được Summary ngoài Digest của mình.
21. Là chủ hệ thống, khi `id` lạ/không thuộc Digest hôm nay, tôi muốn được đưa về `/digest` trần thay vì gặp lỗi, để trải nghiệm không gãy.
22. Là operator, tôi muốn chrome giao diện bằng tiếng Anh (nav, nút, empty-state, ngày), để nhất quán với các trang còn lại của app.
23. Là operator, tôi muốn tiêu đề Article và thân Summary giữ nguyên ngôn ngữ nội dung (tiêu đề theo nguồn, Summary theo cấu hình tóm tắt), để nội dung không bị ép dịch.
24. Là operator, tôi muốn thân Summary dùng kiểu chữ đọc (serif) dễ chịu cho văn dài, để đọc tóm tắt thoải mái.
25. Là operator, tôi muốn pane chi tiết tự cuộn riêng khi Summary dài, trong khi danh sách giữ vị trí của nó, để hai vùng cuộn độc lập.
26. Là chủ hệ thống, tôi muốn danh sách và chi tiết dùng chung một nguồn dữ liệu Digest đã preload (gồm Source), để không phát sinh truy vấn N+1 khi render.

## Implementation Decisions

**Phạm vi module (tên, không phải path):**

- **DigestLive (viết lại render + thêm điều hướng).**
  - `handle_params/3` phục vụ cả `/digest` và `/digest/:id`: rút `id`, tìm mục có
    `summary.id == id` trong Digest đã load; thấy → assign mục đang chọn; không thấy
    (hoặc `/digest` trần) → không chọn gì; `id` lạ → `push_patch` về `/digest`.
  - Danh sách dùng `live_patch` tới `/digest/#{summary.id}`; nút back mobile
    `live_patch` về `/digest`.
  - Lọc Source: `phx-change` trên dropdown cập nhật assign `filter` (Source id hoặc
    "all"); list render lọc theo `filter`. **Filter giữ ở assign, không vào URL**
    (chọn bài mới là thứ cần bền qua refresh).
  - Giữ event `generate` hiện có (tạo/tạo-lại Digest hôm nay).
  - Mobile slide-over: render cả hai pane, class `detail-open` (hoặc tương đương)
    bound vào việc "có mục đang chọn"; transition CSS từ Slice 0.
- **Curation.get_today_digest (mở rộng preload).** Thêm preload `article.source`
  (tên Source) vào item query để list/detail hiển thị tên Source và dropdown lọc
  được — **chỉ preload, không đổi schema**. Giữ thứ tự `published_at` desc hiện có.
- **Router.** Thêm `live "/digest/:id", DigestLive` trong **cùng** block
  `live_session :require_authenticated_user` với `/digest` (một LiveView, hai route,
  `live_patch` giữa chúng) — theo quy tắc router/live_session ở AGENTS.md; Digest
  yêu cầu đăng nhập nên thuộc `:require_authenticated_user`.
- **Lớp component M3 (Slice 0) — dùng + bổ sung primitive có người dùng thật ở đây:**
  outlined-select (dropdown lọc), list-item card, detail layout, empty-state trang
  trí (cho cả "chưa chọn bài" lẫn "Digest trống"). `render_markdown/1` tái dùng cho
  thân Summary; serif đọc (Literata) áp cho vùng thân Summary.
- **Chrome → tiếng Anh:** đổi mọi copy chrome của `digest_live` sang tiếng Anh
  (tiêu đề màn, nút, empty-state, định dạng ngày). Content (tiêu đề Article, thân
  Summary, Tag) **không** đụng.

**Mô hình trạng thái (từ prototype `digest-7.html`, rút gọn phần quyết định):**

- `selArticle` ↔ assign mục đang chọn, **nguồn sự thật = URL** (`/digest/:id`), không
  phải state nội bộ rời rạc.
- `filter` = Source id | "all"; chỉ tác động list, **độc lập** với mục đang chọn
  (chọn bài vẫn hiện ở detail dù bị lọc khỏi list).
- Mobile: `detail-open` = (có mục đang chọn) — class điều khiển slide-over; cả list
  lẫn detail luôn ở trong DOM.

**Dữ liệu/schema:** không migration, không đổi schema. Chỉ mở rộng preload. Digest
vẫn là bản persisted theo (User, ngày) của ADR 0009.

## Testing Decisions

Một test tốt chỉ kiểm **hành vi ngoài** (điều hướng URL, mục nào hiện ở detail,
list lọc ra sao, guard chuyển hướng, empty-state), **không** kiểm chi tiết hiện thực
(không assert class M3, không test CSS/responsive, không assert private). Vì markup
M3 sẽ thay đổi, test **target bằng ID/data-attr ổn định, không bằng copy/class.**

- **Seam (tái dùng, cao nhất): `digest_live_test.exs` mở rộng** —
  `register_and_log_in_user` + `Phoenix.LiveViewTest`, đúng seam đang có (prior art).
  Các case mới:
  - *Selection*: click `#digest-item-<summary_id>` (hoặc link `live_patch`) →
    `assert_patch(view, ~p"/digest/#{id}")` → pane chi tiết chứa `summary_text` của
    bài đó.
  - *Empty pane (desktop)*: vào `/digest` trần → `#detail-empty` có trong DOM, chưa
    có Summary nào ở detail.
  - *Filter Source*: chọn một Source trên `#source-filter` → chỉ các mục thuộc Source
    đó còn trong list; "all" → đủ lại.
  - *Filter không cắt bài đang đọc*: đang ở `/digest/:id` rồi lọc Source khác → detail
    vẫn giữ `summary_text` của bài đang chọn.
  - *Guard*: `live(conn, ~p"/digest/#{bogus_or_foreign_id}")` → `assert_patch` về
    `/digest` (id không thuộc Digest hôm nay của User này — gồm cả Summary của User
    khác hoặc id bịa).
  - *Empty Digest*: chưa generate → empty-state hiện; generate → list có item.
  - *Thứ tự*: list theo `published_at` desc (giữ assertion hiện có, đổi selector nếu
    cần sang ID ổn định).
- **Đầu tư seam một lần: nhấc `summary_fixture` ra `test/support/fixtures`**
  (vd `curation_fixtures.ex`), dựng được **N Summary qua M Source** cho User trong
  scope — để test filter có nhiều Source. Hàm hiện đang inline trong
  `digest_live_test.exs`; promote để cả test cũ lẫn mới dùng chung.
- **Selector ổn định cần có trong markup:** `#digest-item-<summary_id>` (đã có
  pattern), `#detail-pane`, `#detail-empty`, `#digest-empty`, `#source-filter`.
- **Ngoài automated scope:** layout desktop-vs-mobile, slide-over, ripple, scroll —
  là CSS/JS thị giác, **không** test bằng `LiveViewTest` (chỉ assert cả hai pane
  có mặt trong DOM). Muốn test layout thật cần Wallaby/e2e — không kéo vào slice này.

## Out of Scope

- **Nền M3 (token/font/component/bỏ DaisyUI)** — đó là Slice 0
  (`.scratch/m3-foundation/`); slice này **giả định nền đã có**.
- **Navigation rail / bottom navigation đa-đích (Bản tin / Nguồn)** — chỉ dựng khi
  có trang Sources thật; nay chưa có → để **slice Sources** sau. Slice 1 tập trung
  master-detail trong phạm vi Digest.
- **Trang Sources / theo dõi Source / M3 switch theo-dõi** — slice riêng.
- **read/unread, save/bookmark ("Lưu"), date-navigator, tabs Articles|AI, hot-score**
  — mỗi cái là slice riêng, thiếu backend (như NOTES.md đã đóng khung "option a").
- **Lọc Source lưu vào URL/query param** — filter giữ ở assign; bền-qua-refresh chỉ
  áp cho mục đang chọn. Thêm sau nếu cần share link đã-lọc.
- **Streams cho list** — list giới hạn trong một ngày Digest (không vô hạn) nên assign
  thường là đủ; cân nhắc stream chỉ khi đo thấy vấn đề bộ nhớ (assigns-audit).
- **Wallaby / e2e / visual regression** — không thiết lập.
- **Thay đổi schema / Curation core logic / Oban / PubSub** — chỉ mở rộng preload.

## Further Notes

- Tôn trọng **ADR 0011** (M3 bespoke, không thêm component lib) và **ADR 0009**
  (Digest persisted theo (User, ngày); `get_today_digest`/`generate_digest` giữ
  nguyên hợp đồng, chỉ thêm preload Source).
- **Tái dùng `render_markdown/1`** cho thân Summary (đã ra đời ở slice
  summarize-quality đúng để màn này dùng lại) — không nhân bản đường render.
- Guard "id thuộc Digest hôm nay của User" tận dụng chính dữ liệu đã load từ
  `get_today_digest(scope)` (đã lọc theo scope) — không cần truy vấn quyền riêng,
  tránh N+1.
- Khi port màu/shape từ `priv/prototypes/digest-7.html`, nhớ đây là artifact
  throwaway sẽ bị xóa ở cuối Slice 0; Slice 1 lấy diện mạo từ lớp M3 của Slice 0,
  không phụ thuộc file prototype lúc chạy.
- Định dạng ngày chrome sang tiếng Anh (vd "Jun 27") thay cho "27 Th6" hiện tại.
- Mục đang chọn là **Summary** (khóa `summary.id`), nhất quán với việc Digest item
  trỏ tới Summary và `render_markdown` ăn `summary.summary_text`.
