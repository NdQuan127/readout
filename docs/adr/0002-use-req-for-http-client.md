# 0002. Use Req for HTTP Client

Chúng tôi quyết định sử dụng thư viện `Req` làm HTTP client cốt lõi cho ứng dụng. `Req` sẽ được dùng cho cả hai tác vụ chính: thu thập nguồn tin (cào RSS, tải HTML bài viết) và giao tiếp trực tiếp với Gemini API thông qua REST endpoint.

Quyết định này được chọn thay vì sử dụng các SDK wrapper chuyên biệt hoặc các HTTP client cũ hơn như `HTTPoison`/`Tesla`. `Req` được xây dựng trên nền tảng `Finch` cung cấp cơ chế connection pooling hiệu năng cao, tích hợp sẵn tính năng tự động retry (exponential backoff) hữu ích khi cào tin, và có cú pháp cực kỳ tinh gọn giúp tối giản hóa mã nguồn.
