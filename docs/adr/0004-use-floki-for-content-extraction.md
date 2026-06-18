# 0004. Use Floki for Content Extraction

Chúng tôi quyết định sử dụng thư viện `Floki` (HTML parser của Elixir) để trích xuất nội dung chính của bài viết từ raw HTML bằng cách lấy văn bản bên trong các thẻ `<p>` (paragraphs).

Quyết định này được chọn thay vì sử dụng các thuật toán trích xuất phức tạp hơn (như Mozilla Readability) hoặc gửi toàn bộ raw HTML sang LLM. Cách tiếp cận này đảm bảo sự đơn giản trong triển khai cho prototype, hiệu năng xử lý cực nhanh, và giảm thiểu đáng kể số lượng input tokens gửi sang Gemini API, giúp tiết kiệm chi phí vận hành.
