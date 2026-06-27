# Nền M3 (token + font + component + ripple), chứng minh trên luồng auth

Status: ready-for-agent

## Parent

`.scratch/m3-foundation/PRD.md` — Slice 0 (M3 Foundation). Quyết định nền: ADR
`docs/adr/0011-bespoke-material3-on-tailwind-v4-drop-daisyui.md`.

## What to build

Tracer bullet dọc cho nền Material 3: một đường mỏng xuyên đủ tầng (design token →
`@layer components` M3 → `core_components` → trang auth thật → test), chứng minh
trên **luồng auth của `phx.gen.auth`**. DaisyUI **vẫn được cài** ở slice này (Digest
còn dùng), nên lớp M3 chạy **song song** — chưa gỡ gì.

Phạm vi end-to-end:

- **M3 design tokens**: color roles M3 (primary / on-primary / primary-container /
  on-primary-container / secondary + container / surface + surface containers /
  on-surface / on-surface-variant / outline / outline-variant…), **seed xanh lá**,
  đủ **light + dark**, expose qua CSS variables + `@theme` của Tailwind v4. Kèm
  shape scale + state-layer opacities. Giá trị khởi đầu lấy từ
  `priv/prototypes/digest-7.html` (`:root` = light, `html.dark` = dark).
- **Font self-host**: Be Vietnam Pro (UI sans), Literata (serif đọc), Material
  Symbols (icon) — `@font-face` vendored, subset có Vietnamese; **không** `<link>`
  Google Fonts. Map sans cho UI, serif cho lớp đọc.
- **Lớp `@layer components` M3** cho **đúng primitive mà auth + core_components
  cần**: button (filled / tonal / text / outlined tùy chỗ auth dùng), text-field
  (input), flash, card, switch (native checkbox styled), state-layer, ripple-host.
  Không dựng primitive không có người dùng thật ở slice này (vd outlined-select,
  FAB, nav-rail).
- **Viết lại `core_components`** trên nền lớp M3, **giữ chữ ký hàm công khai**
  (`input`, `button`, `flash`, `header`, `table`, `list`, `error`…) để 4 trang
  auth và test không phải đổi. Được tách module phụ cho primitive M3 nếu cấu trúc
  sạch hơn, miễn API ngoài ổn định.
- **Ripple**: một listener `pointerdown` **delegated** (colocated hook hoặc khối
  nhỏ trong `app.js`) nhắm phần tử ripple-host. State-layer + switch **không** cần
  JS. Tôn trọng `prefers-reduced-motion`.
- **Layout/auth surface**: trang login, đăng ký/magic-link, settings, xác nhận
  khoác diện mạo M3 qua `core_components`; **giữ nguyên hành vi + copy tiếng Anh**
  hiện tại.

Không schema/migration/context. Thuần web/asset layer.

## Acceptance criteria

- [ ] M3 token set (color roles seed xanh lá, shape, state-layer) định nghĩa cho cả light + dark qua CSS vars / `@theme`; toggle dark/light đổi đúng màu trên trang auth.
- [ ] Be Vietnam Pro / Literata / Material Symbols được self-host (không request tới Google Fonts ở prod build); UI dùng Be Vietnam Pro, glyph tiếng Việt hiển thị đúng dấu.
- [ ] Có lớp `@layer components` M3 cho button / text-field / flash / card / switch / state-layer / ripple-host; switch là `<input type="checkbox">` được style (không JS).
- [ ] `core_components` được viết lại trên lớp M3, **giữ nguyên chữ ký hàm công khai**; 4 trang auth render theo M3.
- [ ] Ripple hoạt động qua một listener delegated duy nhất; tắt khi `prefers-reduced-motion`.
- [ ] **Toàn bộ test LiveView auth hiện có xanh** (`user_live/login_test`, `settings_test`, `confirmation_test`) — không sửa hành vi/copy; chỉ chỉnh assertion nếu vô tình bám cấu trúc đổi.
- [ ] DaisyUI vẫn còn (chưa gỡ); app build và chạy bình thường, Digest chưa bị đụng vẫn render.
- [ ] State-layer (hover/pressed) và focus-visible hiển thị đúng trên control auth.

## Blocked by

None - can start immediately.
