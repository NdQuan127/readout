# M3 Foundation — Material 3 design layer trên Tailwind v4, bỏ DaisyUI

Status: ready-for-agent

> Slice 0 trong cặp slice "Material 3 UI". Đây là **hạ tầng thị giác** mà Slice 1
> (Digest master-detail) sẽ tiêu thụ. Quyết định nền tảng đã chốt ở **ADR 0011**
> (bespoke M3 trên Tailwind v4, bỏ DaisyUI, loại `@material/web`). Reference thị
> giác sống: `priv/prototypes/digest-7.html` + `priv/prototypes/NOTES.md`.

## Problem Statement

Là operator, toàn bộ web UI hiện tại đang mặc **theme mặc định của Phoenix +
DaisyUI** — seed màu cam/tím, shape generic, không có ngôn ngữ thị giác riêng.
Tôi đã chốt hướng **Material 3 (seed xanh lá)** cho cả app để trải nghiệm nhất
quán và hiện đại. Nhưng trước khi dựng được màn hình chính (Digest master-detail),
app cần một **nền M3 dùng chung**: bảng màu tonal M3, shape, typography, và một bộ
component M3 cơ bản. Nếu không có nền này, mỗi màn hình sẽ tự chế M3 một kiểu →
chính là mớ techdebt "skin-không-nhất-quán" tôi muốn tránh.

Đồng thời, DaisyUI hiện đang là engine component (dùng trong `core_components` +
4 trang auth). Giữ DaisyUI rồi nhồi M3 lên trên nghĩa là **đánh nhau với default
của framework** và mang theo token/component không bao giờ khớp M3 — nên nó phải
bị gỡ, không phải re-theme.

## Solution

Dựng một **lớp Material 3 bespoke trên Tailwind v4** và **bỏ DaisyUI**, theo
ADR 0011. Gồm bốn mảng:

1. **Token layer (M3 design tokens).** Định nghĩa color roles M3 (primary /
   on-primary / primary-container / on-primary-container / secondary +
   container / surface + surface containers 5 mức / on-surface /
   on-surface-variant / outline / outline-variant…), **seed xanh lá**, đầy đủ
   **light + dark**, dạng CSS custom properties + `@theme` của Tailwind v4. Kèm
   shape scale (bo góc M3), state-layer opacities. Gỡ plugin DaisyUI + hai theme
   cam/tím khỏi `app.css`; giữ cơ chế dark mode theo `data-theme`/biến variant
   đang có.

2. **Lớp component M3 (`@layer components`).** Một bộ primitive M3 **chỉ gồm cái
   có người dùng thật** trong Slice 0/Slice 1: button (filled / tonal / text /
   outlined), icon-button, card, chip/assist, list-item, outlined-select (dropdown
   M3), switch, state-layer + ripple host. **Không** dựng kho component "phòng khi
   cần" (no FAB/nav-rail trừ khi auth/core_components cần ngay — cái đó để Slice 1
   nếu chỉ digest dùng).

3. **Viết lại `core_components` trên nền lớp M3 + tối ưu cấu trúc.** Chuyển các
   function component generated (input / button / flash / header / table / list /
   error…) từ class DaisyUI sang lớp M3. Đây là chỗ "tối ưu cấu trúc" có kiểm
   soát: được tách module/đặt lại tên/attrs cho sạch, **với điều kiện giữ được
   hành vi + copy để 4 trang auth và test auth không vỡ**. Nguyên tắc chặn phình:
   **chỉ dựng/đổi cái có người dùng thật.**

4. **Typography + ripple.** Self-host **Be Vietnam Pro** (UI sans), **Literata**
   (serif đọc), **Material Symbols** (icon) — không `<link>` Google Fonts ở prod;
   cả ba phủ tiếng Việt đầy đủ. Ripple M3 = **một listener `pointerdown`
   delegated** (colocated hook hoặc `app.js`) nhắm các phần tử `.ripple` host;
   state-layer + switch **không** cần JS.

Sau Slice 0, **4 trang auth của `phx.gen.auth`** (vốn đã tiếng Anh) tự thừa hưởng
diện mạo M3 qua `core_components`. `digest_live` được **reclass tối thiểu** để
không vỡ khi DaisyUI biến mất — **giữ nguyên layout 1 cột + copy tiếng Việt + DOM
skeleton hiện tại**; bản master-detail + chuyển chrome sang tiếng Anh là việc của
**Slice 1**.

## User Stories

1. Là operator, tôi muốn cả app khoác một ngôn ngữ thị giác Material 3 thống nhất (seed xanh lá), để trải nghiệm hiện đại và liền mạch giữa các màn hình.
2. Là operator, tôi muốn có chế độ sáng và tối đầy đủ theo tonal scheme M3, để dùng được trong mọi điều kiện ánh sáng mà vẫn đúng phong cách.
3. Là operator, tôi muốn màu sắc đến từ một bảng color-roles M3 mạch lạc (primary, surface, outline…), để giao diện hài hòa thay vì màu rời rạc.
4. Là operator, tôi muốn các nút bấm theo dáng M3 (filled / tonal / text / outlined, bo tròn pill), để thao tác cảm giác quen thuộc và tinh tế.
5. Là operator, tôi muốn các bề mặt (card, list-item) có tầng surface và bo góc M3, để phân cấp thị giác rõ và dễ chịu.
6. Là operator, tôi muốn dropdown lọc theo dáng M3 outlined, để chọn lựa rõ ràng và scale tốt khi nhiều lựa chọn.
7. Là operator, khi rê/nhấn lên phần tử tương tác, tôi muốn thấy state-layer (lớp phủ hover/pressed) đúng M3, để biết phần tử đang phản hồi.
8. Là operator, khi nhấn vào phần tử tương tác, tôi muốn thấy hiệu ứng ripple lan từ điểm chạm, để cảm giác chạm "có sức nặng" đúng Material.
9. Là operator dùng bàn phím, tôi muốn focus-visible rõ ràng trên mọi control, để điều hướng không-chuột vẫn theo dõi được vị trí.
10. Là operator, tôi muốn chữ giao diện dùng Be Vietnam Pro, để tiếng Việt hiển thị dấu chuẩn và đẹp, chữ Anh cũng sắc.
11. Là operator, tôi muốn nội dung đọc dài (sau này là Summary) dùng serif Literata, để cảm giác đọc "editorial" dễ chịu.
12. Là operator, tôi muốn icon dùng Material Symbols, để biểu tượng đồng bộ với ngôn ngữ M3.
13. Là chủ hệ thống, tôi muốn font được self-host, để prod không phụ thuộc Google Fonts (riêng tư, tốc độ, không phụ thuộc bên thứ ba).
14. Là chủ hệ thống, tôi muốn font phủ đầy đủ glyph tiếng Việt, để tiêu đề Article và Summary tiếng Việt không bị vỡ dấu.
15. Là chủ hệ thống, tôi muốn loại bỏ hoàn toàn DaisyUI khỏi pipeline CSS, để không còn hai hệ thống thiết kế chồng nhau và không gánh token/shape không-M3.
16. Là chủ hệ thống, tôi muốn các M3 token nằm dạng CSS variables + `@theme` của Tailwind v4, để app code, component và utility cùng nói một ngôn ngữ token (CSS-first).
17. Là chủ hệ thống, tôi muốn một lớp component M3 dùng chung (`@layer components`), để mọi màn hình lấy nút/card/chip/switch từ cùng một nguồn thay vì tự chế.
18. Là chủ hệ thống, tôi muốn lớp component M3 chỉ chứa primitive có người dùng thật, để không phình thành thư viện component chết.
19. Là chủ hệ thống, tôi muốn `core_components` được viết lại trên lớp M3 nhưng **giữ chữ ký hàm** (`<.input>`, `<.button>`, `<.flash>`…), để các trang auth và test gọi qua chúng không phải đổi.
20. Là operator, tôi muốn 4 trang auth (đăng nhập, đăng ký/magic-link, settings, xác nhận) tự khoác diện mạo M3, để toàn bộ luồng vào app nhất quán.
21. Là operator, tôi muốn các trang auth giữ nguyên hành vi và nội dung tiếng Anh hiện tại, để việc đổi giao diện không thay đổi cách dùng quen thuộc.
22. Là chủ hệ thống, tôi muốn switch M3 được dựng từ `<input type="checkbox">` native được style, để có a11y + form-binding miễn phí và không cần JavaScript.
23. Là chủ hệ thống, tôi muốn ripple là một listener delegated duy nhất, để bề mặt JS của lớp M3 tối thiểu và an toàn với DOM-patching của LiveView.
24. Là chủ hệ thống, tôi muốn state-layer thuần CSS (không JS), để hover/pressed nhẹ và không phụ thuộc script.
25. Là operator nhạy cảm chuyển động, tôi muốn `prefers-reduced-motion` tắt ripple/animation, để không bị khó chịu vì hiệu ứng.
26. Là operator, tôi muốn Digest vẫn hiển thị và hoạt động bình thường (xem danh sách, tạo digest, empty-state) sau khi nền M3 thay DaisyUI, để không có khoảng gãy giữa hai slice.
27. Là developer kế nhiệm, tôi muốn lý do bỏ DaisyUI / không dùng `@material/web` được ghi ở ADR 0011, để không có người "sửa lại" thành web components sau sáu tháng.
28. Là chủ hệ thống, tôi muốn bundle CSS/JS không phình quá mức khi thêm font + lớp M3, để trang vẫn nhẹ.

## Implementation Decisions

**Phạm vi module (tên, không phải path):**

- **App CSS (token + component layer).** Gỡ `@plugin daisyui` và hai khối
  `@plugin daisyui-theme` (cam/tím). Thay bằng: (a) **M3 token set** — color
  roles seed xanh lá cho light + dark (lấy giá trị từ `priv/prototypes/digest-7.html`
  làm điểm khởi đầu, tinh chỉnh khi port), shape scale, state-layer opacities,
  expose qua CSS variables + `@theme`; (b) **`@layer components` M3** cho các
  primitive đã liệt kê. Giữ cơ chế dark mode hiện có (`@custom-variant dark` theo
  `data-theme=dark`) và các `@custom-variant phx-*`.
- **`core_components`.** Viết lại ruột các function component từ class DaisyUI →
  class/lớp M3. **Giữ chữ ký công khai** (`input`, `button`, `flash`, `header`,
  `table`, `list`, `error`…) để auth pages + test không đổi. Được phép tách
  module phụ cho primitive M3 nếu giúp cấu trúc sạch hơn, miễn API ngoài ổn định.
- **Layouts.** Cập nhật `Layouts.app` (và root layout nếu cần) sang surface/token
  M3; nạp font self-host trong root layout (không `<link>` Google Fonts).
- **`digest_live`.** **Chỉ reclass tối thiểu** để không vỡ khi DaisyUI biến mất:
  thay `btn`/`badge`/`rounded-box`/`border-base-300`… bằng primitive M3 tương
  đương. **Giữ nguyên** layout một cột, copy tiếng Việt, và **DOM skeleton**
  (`id="digest-items"`, phần tử `article`, link tiêu đề `a`) — vì master-detail
  và chrome tiếng Anh thuộc Slice 1, và vì `digest_live_test` đang assert vào
  skeleton này.
- **Assets / JS.** Thêm ripple: **một listener `pointerdown` delegated** (ưu tiên
  colocated hook gắn ở phần tử bao quanh, hoặc khối nhỏ trong `app.js`) nhắm phần
  tử có class host ripple. Không thêm dependency JS cho switch/state-layer.
- **Fonts.** Vendored self-host **Be Vietnam Pro** + **Literata** (subset Latin +
  Latin Extended + Vietnamese) + **Material Symbols**. Khai báo `@font-face` +
  map vào token typography (sans cho UI, serif cho `.reading`/đọc).

**Quyết định kiến trúc / kỹ thuật:**

- **Engine = Tailwind v4** (CSS-first `@theme` + CSS variables). M3 ánh xạ tự
  nhiên vào mô hình token base → semantic → component. Không thêm component lib
  nào (DaisyUI/Petal/SaladUI/Fluxon/`@material/web`) — xem ADR 0011.
- **M3 ở đây là "M3 tinh thần"**, port trung thực từ prototype đã duyệt, **không**
  pixel-perfect spec. Component nặng-a11y (date picker, dialog focus-trap, menu
  bàn phím) ngoài scope và sẽ tự dựng nếu sau này cần.
- **Switch = native checkbox styled** (CSS-only). **State-layer = CSS-only.**
  **Ripple = JS thật, delegated, một chỗ** (LiveView.JS không tính được tọa độ
  pointer nên không dùng cho ripple).
- **Không schema change, không migration, không đụng context** (`Curation`,
  `Analysis`, `Ingestion`, `Accounts`). Slice này thuần web/asset layer.
- **Chrome vẫn tiếng Việt ở `digest_live`** trong Slice 0 (đổi sang tiếng Anh là
  việc Slice 1, nơi digest được viết lại).

## Testing Decisions

Một test tốt chỉ kiểm **hành vi ngoài** (trang render được, form submit đúng,
flash/redirect đúng, Digest vẫn hiện item/empty-state), **không** kiểm chi tiết
hiện thực (không assert class M3, không snapshot CSS, không test token). Vì Slice 0
chủ yếu là thay đổi thị giác, vai trò của test là **lưới an toàn chống regression**,
không phải đặc tả mới. Ưu tiên seam cao nhất, **tái dùng — thêm 0 seam mới:**

- **Seam 1 (tái dùng, cao nhất): test LiveView auth hiện có** — `user_live/login_test`,
  `settings_test`, `confirmation_test`. Đây là prior art trực tiếp: chúng dùng
  `register_and_log_in_user` + `Phoenix.LiveViewTest`, assert vào **copy tiếng Anh
  + hành vi** (đã xác minh: **không** assert class DaisyUI nào). Việc viết lại
  `core_components` phải giữ các test này **xanh nguyên**; nếu một assertion vô
  tình bám cấu trúc đổi, sửa tối thiểu về hành vi.
- **Seam 2 (tái dùng): `digest_live_test.exs`** — guard rằng Digest **vẫn render**
  sau khi reclass DaisyUI→M3: empty-state ("Chưa có digest hôm nay"), generate +
  chống trùng, thứ tự theo `published_at` giảm dần, render Markdown sạch. Giữ xanh
  bằng cách Slice 0 **không đổi copy/skeleton** của `digest_live`, chỉ đổi class.
  Cụ thể phải giữ selector `#digest-items article` và `#digest-items article a`.
- **Không seam mới.** Token/màu/shape/font + ripple-JS là **thị giác/manual** →
  ngoài automated scope (kiểm mắt thường trên cả light/dark; muốn test layout/responsive
  thật cần Wallaby/e2e — **không** kéo vào slice này).

## Out of Scope

- **Digest master-detail UI** (sidebar danh sách ↔ pane chi tiết, `live_patch
  /digest/:id`, lọc Source, empty pane trang trí, mobile slide-over) — **Slice 1**.
- **Chuyển chrome `digest_live` sang tiếng Anh** + đổi định dạng ngày — **Slice 1**
  (nơi digest được viết lại; Slice 0 giữ copy tiếng Việt để test cũ xanh).
- **Promote `summary_fixture` ra `test/support/fixtures`** + test mới cho
  selection/filter/guard — **Slice 1** (Slice 0 không cần test digest mới).
- **Component M3 nặng-a11y** (date picker, dialog focus-trap, menu bàn phím,
  autocomplete, slider, tooltip) — tự dựng sau nếu có nhu cầu thật.
- **FAB / navigation rail / bottom navigation** — chỉ dựng ở slice nào thực sự
  dùng (digest master-detail = Slice 1); không dựng "phòng khi cần" ở Slice 0.
- **Wallaby / e2e / visual regression** — không thiết lập hạ tầng browser test.
- **Trang Sources / read-unread / date-navigator / tabs Articles|AI / hot-score** —
  các slice riêng, thiếu backend.
- **Bất kỳ thay đổi context/schema/Oban/PubSub** nào — slice thuần web/asset.

## Further Notes

- Tôn trọng **ADR 0011**: không tái lập DaisyUI, không thêm `@material/web` hay
  component lib khác; M3 dựng bespoke trên Tailwind v4. Nếu lúc port phát sinh
  quyết định kiến trúc mới đáng nhớ (vd cách tổ chức token 3 tầng, ranh giới
  module primitive vs core_components), cân nhắc bổ sung ADR.
- **Giá trị màu** khởi đầu lấy từ `priv/prototypes/digest-7.html` (`:root` cho
  light, `html.dark` cho dark — seed xanh lá). `priv/prototypes/` là artifact
  throwaway: **xóa sau khi port xong** (NOTES.md đã ghi).
- **Thứ tự thực thi gợi ý:** token layer + font trước → lớp component M3 → viết
  lại `core_components` (chạy test auth làm phanh) → reclass `digest_live` (chạy
  `digest_live_test` làm phanh) → ripple hook. Mỗi bước có một seam test sẵn để
  xác nhận không vỡ.
- **Tiền lệ test**: `digest_live_test.exs` (LiveView + `register_and_log_in_user`)
  và `user_live/*_test.exs` là khuôn mẫu; không cần dựng helper test mới ở slice
  này.
- Kiểm font tiếng Việt **thật trên màn hình** lúc implement (Be Vietnam Pro +
  Literata): đảm bảo dấu nặng/ngã/móc đúng ở cả tiêu đề (sans) lẫn body đọc (serif).
- Sau Slice 0, **Slice 1 (Digest master-detail)** mới mở PRD riêng và tiêu thụ nền
  này.
