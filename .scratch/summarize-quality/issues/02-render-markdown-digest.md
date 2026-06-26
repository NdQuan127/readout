# Render Markdown an toàn trên Digest

Status: done

## Parent

`.scratch/summarize-quality/PRD.md`

## What to build

Summary từ nay chứa Markdown; Digest hiện đổ thẳng chuỗi `summary_text` vào thẻ `<p>` nên hiển thị ký tự định dạng thô (`**`, `#`). Render Markdown thành HTML an toàn ngay lúc hiển thị:

- Thêm **MDEx** vào project (Rust NIF, có sanitize built-in).
- Một helper dùng chung `render_markdown/1` trả về HTML đã sanitize dưới dạng `{:safe, ...}`, đặt trong module HTML helper dùng chung (để slice UI sau — master-detail — tái dùng đúng một đường render, không nhân bản logic).
- `DigestLive` gọi `render_markdown/1` cho `summary_text` thay vì in chuỗi thô.
- **Render-lúc-hiển-thị**, không pre-render lưu HTML: single source of truth là Markdown; đổi cách render sau không phải re-summarize. Không thêm cột HTML.
- Sanitize bằng chính MDEx (chặn `<script>`, `onclick`…) — không tự cuộn sanitizer.

Link trong Summary để default cùng tab (không thêm `target="_blank"` ở slice này).

## Acceptance criteria

- [ ] MDEx được thêm làm dependency của project.
- [ ] Helper `render_markdown/1` trả `{:safe, html}` từ Markdown qua MDEx với sanitize built-in, đặt ở module dùng chung.
- [ ] `DigestLive` render `summary_text` qua helper; Markdown (đậm, danh sách, tiêu đề, link) hiển thị đã định dạng, không còn ký tự thô.
- [ ] **Seam test (`render_markdown/1` pure, trực tiếp):** Markdown hợp lệ → HTML đúng (đậm/list/link).
- [ ] Cùng test: input chứa `<script>`/`onclick` → HTML ra đã bị sanitize bỏ (không lọt XSS).
- [ ] Suite hiện có vẫn xanh.

## Blocked by

None - can start immediately. (Độc lập với issue 01 — render không phụ thuộc nội dung prompt; có thể làm song song.)
