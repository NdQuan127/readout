# Readout

Nền tảng tổng hợp và tóm tắt tin tức cá nhân hóa (Personalized intelligence briefing system).

## Language

**User**:
Thành viên đăng ký trên hệ thống để nhận các bản tin digest được cá nhân hóa.
_Avoid_: Client, reader, account

**Source**:
Nguồn phát hành tin tức (RSS feed, kênh thông tin...) được đăng ký trong hệ thống.
_Avoid_: Feed, channel, link

**Article**:
Một bài viết thô được thu thập từ một Source, lưu trữ ở mức toàn cục (global) để dùng chung.
_Avoid_: Post, news, item

**Content**:
Thân bài đã được bóc sạch (cleaned paragraph text) của một Article, tách khỏi metadata và lưu 1:1 với Article. Là đầu vào để sinh tóm tắt.
_Avoid_: raw_content, body, text

**Summary**:
Bản tóm tắt do AI sinh cho một Article, lưu global 1:1 và dùng chung cho mọi User (gồm summary text và tags). Khác với Digest — Summary là của một bài, Digest là tổng hợp nhiều bài cho một User trong ngày.
_Avoid_: ArticleSummary (tên schema, không dùng trong văn nói), abstract

**Tag**:
Nhãn phân loại do AI gán cho một Article, lấy từ một tập cố định có kiểm soát (closed vocabulary). Tin không khớp nhãn nào thì để trống.
_Avoid_: Category, label, topic

**Digest**:
Bản tin tóm tắt tổng hợp được cá nhân hóa sinh ra cho một User cụ thể vào một ngày cụ thể.
_Avoid_: Briefing, newsletter
