# Lọc Source bằng M3 outlined dropdown

Status: done

## Parent

`.scratch/digest-master-detail/PRD.md` — Slice 1 (Digest master-detail). Tôn trọng
ADR 0011 (M3 bespoke).

## What to build

Thêm bộ lọc theo Source cho danh sách master-detail: một **M3 outlined dropdown**
(không phải chip-row ngang — scale tốt khi nhiều nguồn) liệt kê các Source thực sự
có bài trong Digest hôm nay, cộng tùy chọn "All sources". Chọn một Source → danh sách
thu hẹp chỉ còn bài của Source đó; "All sources" → đầy lại.

Hành vi end-to-end:

- Dropdown render từ tập **Source có mặt trong Digest hôm nay** (lấy từ dữ liệu đã
  preload ở issue 01), không liệt kê Source không có bài (tránh lọc ra danh sách
  rỗng vô nghĩa).
- `phx-change` trên dropdown cập nhật assign `filter` (Source id | "all"); list
  render lọc theo `filter`.
- **Filter độc lập với mục đang chọn**: nếu đang ở `/digest/:id` rồi lọc sang Source
  khác (bài đang đọc bị lọc khỏi list), pane chi tiết **vẫn giữ** bài đang đọc —
  filter chỉ ảnh hưởng list, không đụng selection/guard.
- **Filter ở assign, không vào URL** (chỉ mục đang chọn cần bền qua refresh).
- Dropdown đặt cạnh nút generate/tạo-lại; có `id="source-filter"` cho test.

## Acceptance criteria

- [ ] Dropdown M3 outlined hiện "All sources" + đúng các Source có bài trong Digest hôm nay (không thừa Source rỗng).
- [ ] Chọn một Source → list chỉ còn mục thuộc Source đó; chọn "All sources" → list đủ lại.
- [ ] Đang ở `/digest/:id` rồi đổi filter sang Source khác → detail vẫn hiện `summary_text` của bài đang chọn (không bị guard đẩy đi, không mất bài).
- [ ] Filter giữ ở assign (không thêm query param vào URL).
- [ ] `digest_live_test` mở rộng, **xanh**, target qua `#source-filter`: lọc thu hẹp list đúng; "all" khôi phục; filter không cắt bài đang đọc.

## Blocked by

- `.scratch/digest-master-detail/issues/01-master-detail-core-live-patch-guard-empty.md`
