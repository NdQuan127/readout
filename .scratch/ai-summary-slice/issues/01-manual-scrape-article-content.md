# Manual scrape → ArticleContent, hiện trạng thái lên DemoLive

Status: done

## What to build

Tracer bullet end-to-end cho bước cào nội dung, kích hoạt thủ công từ UID.

Trên `/demo`, mỗi article card có nút "Tóm tắt". Click nút → enqueue một Oban job cào bài viết đó. Worker tải HTML từ `canonical_url`, dùng Floki bóc text trong các thẻ `<p>`, ghi kết quả vào **Content** (schema `ArticleContent`, 1:1 với Article — xem ADR 0007). Cào xong, broadcast PubSub để `DemoLive` cập nhật **tại chỗ** một dấu hiệu "đã cào" trên đúng card đó (vd badge hoặc số ký tự), không reload trang.

Prefactor đi kèm: bỏ cột `raw_content` (đang rỗng) khỏi bảng `articles` — Content giờ sống ở bảng riêng (ADR 0007).

Trạng thái "đang xử lý" giữ ephemeral trong assigns (MapSet article_id), không persist. Click trùng được Oban unique job chặn.

Thuật ngữ: dùng **Content** theo glossary trong `CONTEXT.md`. Bóc `<p>` bằng Floki theo ADR 0004.

## Acceptance criteria

- [ ] Migration tạo bảng `article_contents` (1:1 với articles) và gỡ cột `raw_content` khỏi `articles`
- [ ] `ArticleScrapeWorker` cào HTML → bóc `<p>` bằng Floki → ghi Content; test với HTML mẫu xác nhận Content đúng
- [ ] Worker xử lý lỗi cào (4xx/5xx/timeout) qua retry/cancel semantics của Oban, không làm sập job
- [ ] Nút "Tóm tắt" trên mỗi article card enqueue worker cho đúng article
- [ ] Click trùng không tạo job trùng (Oban unique)
- [ ] Cào xong, card cập nhật dấu hiệu "đã cào" realtime qua PubSub, không reload
- [ ] LiveView test giả lập sự kiện scrape-hoàn-tất → card cập nhật trong DOM

## Blocked by

None - can start immediately
