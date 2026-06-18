# 0006. Dùng Gemini Flash Lite + structured output, bỏ fallback machinery của legacy

Chúng tôi quyết định sinh Summary qua **Gemini 3.1 Flash Lite** với **structured output (`responseSchema`)** để ép model trả về JSON đúng schema ngay tầng decode, và **không** port lại đống cơ chế chống lỗi JSON của legacy (repair JSON, fallback plain-text 4 bước, sanitize LaTeX, heuristic phát hiện meta-text/markdown cụt, xoay vòng nhiều model).

## Bối cảnh

Legacy chạy trên **Gemma** — model open-weight không hỗ trợ structured output đáng tin, nên buộc phải đẻ ra ~260 dòng băng dán để vá JSON rác. Phần lớn độ phức tạp đó là hệ quả của lựa chọn model, không phải bản chất bài toán. Gemini Flash Lite hỗ trợ `responseSchema` native (use case official: trích xuất tài liệu thô → record sạch để ghi DB), nên JSON rác gần như biến mất và lớp fallback trở thành thừa. Đây cũng là điều lệch khỏi mô tả trong PRD ("JSON mode + hàm làm sạch markdown wrapper") — với `responseSchema` thì không cần bước làm sạch đó.

## Trade-off

`responseSchema` chỉ đảm bảo JSON **đúng cấu trúc**, không đảm bảo **chất lượng nội dung** (tóm tắt cụt/nhạt vẫn lọt). Các quality-check của legacy bắt được "hợp lệ nhưng tệ"; ta cố tình bỏ để giữ slice gọn, và chỉ thêm lại check khi quan sát thấy lỗi lặp lại thật. Lỗi tạm thời (429/timeout/5xx) giao cho Oban retry thay vì hand-roll. Model id giữ trong config (một biến) để dễ nâng lên tier mạnh hơn.
