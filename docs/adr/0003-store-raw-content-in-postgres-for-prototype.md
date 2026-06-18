# 0003. Store Raw Content in Postgres for Prototype

Chúng tôi quyết định lưu trữ nội dung thô (`raw_content` / raw HTML) của các bài viết trực tiếp vào database PostgreSQL dưới dạng trường `:text` trong suốt giai đoạn thử nghiệm (prototype). 

Đây là một sự thỏa hiệp có chủ ý để giảm thiểu số lượng dịch vụ cần cài đặt (không cần tích hợp Object Storage như S3 hay Cloudflare R2 ngay từ đầu), giúp việc kiểm thử và chạy thử nghiệm cục bộ diễn ra nhanh chóng hơn. 

Khi hệ thống chuyển sang giai đoạn vận hành chính thức (production) với lượng bài viết lớn, chúng tôi sẽ di chuyển phần nội dung thô này ra Object Storage độc lập để tránh làm phình to dung lượng đĩa và làm chậm các chỉ mục (indexes) của database.
