# 0005. Use Floki for RSS Parsing

Chúng tôi quyết định sử dụng thư viện `Floki` để phân tích cú pháp (parsing) các tệp XML của nguồn RSS/Atom thay vì cài đặt thêm các thư viện phân tích XML chuyên biệt (như `feeder_ex` hay `fast_xml`).

Quyết định này được đưa ra để tận dụng tối đa thư viện `Floki` (vốn đã được sử dụng cho việc cào nội dung), duy trì một codebase thuần Elixir có số lượng thư viện phụ thuộc (dependencies) ở mức tối thiểu. Điều này giúp đẩy nhanh tốc độ biên dịch (compile time), đơn giản hóa quá trình cấu hình môi trường chạy thử nghiệm và triển khai sau này.
