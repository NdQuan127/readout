# Migrate Layouts + digest_live sang M3 và gỡ hẳn DaisyUI

Status: ready-for-agent

## Parent

`.scratch/m3-foundation/PRD.md` — Slice 0 (M3 Foundation). Quyết định nền: ADR
`docs/adr/0011-bespoke-material3-on-tailwind-v4-drop-daisyui.md`.

## What to build

Hoàn tất việc thay nền: chuyển các bề mặt còn lại đang dùng class DaisyUI sang
primitive M3, rồi **gỡ hẳn DaisyUI khỏi pipeline CSS** — sau slice này app không
còn DaisyUI ở đâu cả.

Phạm vi end-to-end:

- **`Layouts.app` (và root layout nếu cần)**: chuyển surface/khung sang token M3;
  đảm bảo cả Digest lẫn auth dùng chung shell M3.
- **`digest_live` — reclass tối thiểu, KHÔNG redesign**: thay class DaisyUI thô
  (`btn` / `badge` / `rounded-box` / `border-base-300`…) bằng primitive M3 tương
  đương. **Giữ nguyên**: layout một cột hiện tại, **copy tiếng Việt**, và **DOM
  skeleton** — `id="digest-items"`, phần tử `article` cho mỗi mục, link tiêu đề
  `a`. (Master-detail + chuyển chrome sang tiếng Anh là việc của Slice 1.)
- **Gỡ DaisyUI**: xóa `@plugin "../vendor/daisyui"` và hai khối
  `@plugin "../vendor/daisyui-theme"` (cam/tím) khỏi `app.css`. Giữ cơ chế dark
  mode hiện có (`@custom-variant dark` theo `data-theme=dark`) và các
  `@custom-variant phx-*`. Dọn file vendor DaisyUI không còn dùng.

Sau khi mọi bề mặt đã M3 và DaisyUI đã gỡ: `priv/prototypes/` là artifact throwaway
— **xóa** sau khi đã rút hết giá trị màu/shape (NOTES.md đã ghi).

Không schema/migration/context.

## Acceptance criteria

- [ ] `Layouts.app` + root layout dùng token/surface M3; shell nhất quán giữa Digest và auth, cả light + dark.
- [ ] `digest_live` không còn class DaisyUI; render bằng primitive M3, **giữ nguyên** layout 1 cột, copy tiếng Việt, và skeleton `#digest-items` / `article` / link tiêu đề `a`.
- [ ] `@plugin daisyui` và hai `@plugin daisyui-theme` đã bị xóa khỏi `app.css`; `grep` toàn `lib/readout_web` + `assets` không còn class/plugin DaisyUI (`btn`, `badge`, `rounded-box`, `base-100/200/300`, `daisy`).
- [ ] **`digest_live_test.exs` xanh** — empty-state, generate + chống trùng, thứ tự `published_at` giảm dần, render Markdown sạch; selector `#digest-items article` và `#digest-items article a` vẫn khớp.
- [ ] Test LiveView auth vẫn xanh sau khi gỡ DaisyUI.
- [ ] App build sạch (asset pipeline không lỗi vì thiếu DaisyUI); Digest render đúng M3 ở cả light/dark khi kiểm mắt thường.
- [ ] `priv/prototypes/` đã được xóa sau khi port xong giá trị thị giác.

## Blocked by

- `.scratch/m3-foundation/issues/01-m3-token-font-component-foundation-on-auth.md`
