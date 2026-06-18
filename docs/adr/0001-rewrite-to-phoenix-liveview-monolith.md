# 0001. Rewrite to Phoenix LiveView Monolith

Chúng tôi quyết định rewrite lại dự án Readout từ kiến trúc serverless hiện tại (SvelteKit + Cloudflare Workers + D1) sang một ứng dụng Phoenix LiveView monolith chạy trên PostgreSQL với Oban làm job engine. 

Quyết định này được thúc đẩy bởi mong muốn thử nghiệm lập trình hàm (Functional Programming) trong Elixir và chuyển đổi sản phẩm từ một công cụ cá nhân tự lưu trữ (single-user personal tool) thành một nền tảng web đa người dùng (multi-user web platform). 

Chúng tôi đánh đổi sự tiện lợi và chi phí vận hành thấp ở edge của Cloudflare để lấy sự đơn giản trong vận hành (single runtime monolith), sự bền bỉ của hàng đợi Oban cho các tác vụ cào và tóm tắt tin tức nền, cùng khả năng cập nhật realtime mượt mà của LiveView.
