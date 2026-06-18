# 0007. Tách Content ra schema `ArticleContent` riêng

Chúng tôi quyết định lưu cleaned content của bài viết trong một schema/bảng riêng `ArticleContent` (1:1 với `Article`), thay vì để trên cột `raw_content` của bảng `articles`.

## Bối cảnh

ADR 0003 chọn lưu content thẳng trong Postgres cho prototype; ban đầu nhét vào cột `raw_content` trên `articles`. Khi bắt đầu AI summary slice, ta nhận ra content (`:text`, vài KB) nằm chung `articles` sẽ bị kéo theo trên mọi hot-path query danh sách bài (right column của `/demo`, sau này Digest) dù chỉ cần title/url. Tách bảng → query list không chạm body; chỉ join/preload khi mở chi tiết. Bảng riêng cũng là đường biên migration sạch khi sau này offload body sang object storage (R2/S3).

Quyết định này **không** đảo ngược 0003 (content vẫn trong Postgres cho prototype) — chỉ tinh chỉnh *chỗ* lưu. Cột `raw_content` cũ đang rỗng nên đổi gần như không tốn gì.
