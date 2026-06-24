# Daily Digest — bản tin tổng hợp theo ngày cho operator

Status: ready-for-agent

## Problem Statement

Là operator, mỗi ngày tôi có nhiều Article được tóm tắt rải rác từ các Source tôi follow, nhưng không có chỗ nào gom chúng lại thành "bản tin của hôm nay". App hiện chỉ có `/demo` liệt kê Article trần theo nguồn — tôi phải tự lướt để biết hôm nay có gì mới đáng đọc. Tôi cần một bản tổng hợp theo ngày, chỉ gồm những bản tóm tắt *đến tay tôi* trong ngày, để đọc nhanh một lượt thay vì tự rà từng nguồn. Và bản tin của một ngày đã qua phải giữ nguyên, không bị nội dung mới hôm sau làm xáo trộn.

## Solution

Dựng một **Digest** theo ngày cho mỗi operator: một artifact được lưu, gom các **Summary** đủ điều kiện của ngày đó. Digest của **hôm nay** *sống và lớn dần* — mỗi khi một Summary mới hoàn tất cho một Source operator đang subscribe, lần sinh kế tiếp gom thêm nó vào. Sang ngày mới, digest hôm qua **đóng băng** thành bản ghi lịch sử.

App có thêm trang `/digest` (yêu cầu đăng nhập) hiển thị digest hôm nay của chính operator, kèm nút "Tạo digest hôm nay" để sinh/refresh. Logic gom nằm trong một context mới `Curation`, đọc từ `Ingestion` (subscription) và `Analysis` (Summary) nhưng không đụng tới chúng. Vì `Ingestion`/`Analysis` đã có sẵn dữ liệu, slice này chỉ thêm tầng tuyển chọn per-user.

Theo **ADR 0009**: artifact lưu trữ (không phải view), open-hôm-nay/closed-quá-khứ, neo theo summary-ready, context `Curation`, pointer (không snapshot). Auth nền theo **ADR 0008** (`current_scope.user`).

## User Stories

1. Là operator, tôi muốn mở `/digest` và thấy bản tin tổng hợp của hôm nay, để đọc nhanh những gì mới mà không phải rà từng Source.
2. Là operator, tôi muốn digest chỉ gồm Summary của các Source tôi đang subscribe, để không bị nhiễu bởi nguồn người khác.
3. Là operator, tôi muốn digest hôm nay gồm các Summary mà bản tóm tắt *hoàn tất trong hôm nay*, để bản tin phản ánh "những gì đến tay tôi hôm nay" chứ không phụ thuộc ngày báo gốc xuất bản.
4. Là operator, tôi muốn một bài nguồn đăng từ hôm qua nhưng sáng nay mới được tóm tắt vẫn xuất hiện trong digest hôm nay, để không bị mất tin.
5. Là operator, tôi muốn bấm "Tạo digest hôm nay" để sinh hoặc làm mới digest, để chủ động xem bản tin mới nhất khi cần (giai đoạn này trigger tay để test).
6. Là operator, tôi muốn bấm tạo nhiều lần mà digest không bị nhân đôi bài, để kết quả luôn nhất quán.
7. Là operator, khi hôm nay chưa có Summary nào đủ điều kiện, tôi muốn thấy trạng thái rỗng rõ ràng thay vì lỗi, để biết "chưa có gì hôm nay".
8. Là operator, sau khi có thêm bài được tóm tắt trong ngày rồi bấm tạo lại, tôi muốn digest gom thêm những bài mới đó, để bản tin lớn dần theo ngày.
9. Là operator, tôi muốn digest của một ngày đã qua giữ nguyên không bị thay đổi, để nó là bản ghi trung thực "hôm đó tôi đã có gì".
10. Là chủ hệ thống, tôi muốn không thao tác nào ghi được vào digest của ngày đã qua, kể cả do lỗi, để dữ liệu lịch sử không bị hỏng.
11. Là operator chưa đăng nhập, khi truy cập `/digest` tôi muốn bị chuyển hướng sang trang log-in, để dữ liệu cá nhân được bảo vệ.
12. Là operator, tôi muốn các bài trong digest xếp tin mới nhất lên đầu, để đọc theo thứ tự ưu tiên quen thuộc.
13. Là operator, tôi muốn thấy nội dung tóm tắt và các tag của từng bài ngay trong digest, để nắm ý mà không cần mở từng Article.
14. Là chủ hệ thống, tôi muốn nền digest sẵn sàng cho việc tự động hóa sau này (cron, refresh khi có Summary mới), để chuyển từ trigger tay sang tự động chỉ là cộng dồn, không viết lại.

## Implementation Decisions

- **Context mới `Curation`**: chứa `Digest` và `DigestItem`. Đọc từ `Accounts` (Scope/User), `Ingestion` (`UserSource`), `Analysis` (`Summary`); phụ thuộc một chiều — không context nào ở dưới biết tới Digest. (ADR 0009)
- **Schema `Digest`**: thuộc về một User cho một `date` (kiểu date). Quan hệ `has_many` tới `DigestItem`. **Unique `(user_id, date)`**. Trạng thái open/closed **không lưu thành cột** — suy ra từ `date` (closed iff `date < hôm nay`).
- **Schema `DigestItem`**: thuộc về một `Digest`, **trỏ tới một `Summary`** (`summary_id`) — pointer, **không** copy `summary_text`/`tags`. **Unique `(digest_id, summary_id)`** để chống trùng.
- **Hàm chính `Curation.generate_digest(scope, date)`** — idempotent upsert theo khóa `(user, date)`:
  - **Guard quá khứ**: nếu `date != hôm nay (UTC)` → no-op (không tạo/sửa gì). Đây là *con đường ghi duy nhất*, nên invariant "không ghi quá khứ" enforce tại đúng chỗ này.
  - **Tuyển chọn**: lấy mọi `Summary` mà `summary.inserted_at` thuộc ngày UTC `date` **VÀ** Article của nó thuộc một Source mà `scope.user` đang subscribe (`UserSource`).
  - **Upsert**: ensure một `Digest` cho `(user, date)` (tạo cả khi rỗng), rồi insert các `DigestItem` còn thiếu (`on_conflict: :nothing` trên `(digest_id, summary_id)`).
- **Hàm đọc `Curation.get_today_digest(scope)`** (hoặc tương đương): trả về digest hôm nay của `scope.user` cùng các item, preload Summary + Article (title, published_at) + tags, **xếp `published_at` desc**. Trả về dạng rỗng/empty khi chưa có item.
- **Ngày**: tính theo **UTC** (ranh giới ngày server). Múi giờ người dùng để dành giai đoạn multi-user.
- **LiveView `/digest`**: mount đọc `current_scope.user`, hiện digest hôm nay; nút "Tạo digest hôm nay" gọi `generate_digest(scope, today)` rồi đọc lại và render. **Không real-time** (không PubSub auto-refresh) trong slice này. Tái dùng cách render Summary + tags đã có ở `/demo`.
- **Router**: `/digest` đặt trong **`live_session :require_authenticated_user`**, `pipe_through [:browser, :require_authenticated_user]`, `on_mount {ReadoutWeb.UserAuth, :require_authenticated}` — vì digest là dữ liệu per-operator đọc từ `current_scope.user`, bắt buộc đăng nhập (cùng nhóm `/demo`, `/users/settings`).
- **Không đụng `Ingestion`/`Analysis`**: chỉ đọc dữ liệu có sẵn; không thêm `user_id` vào `Analysis`. Lằn ranh global (Summary) / personal (Digest) giữ nguyên.
- **Migration**: thêm bảng `digests` và `digest_items` (binary_id, theo convention các schema hiện có) với hai unique index nêu trên.

## Testing Decisions

- **Nguyên tắc**: chỉ test hành vi bên ngoài, không test chi tiết triển khai. Không re-test máy móc của Ecto/Oban/gen.auth.
- **Seam 1 — `/digest` LiveView** (integration; tiền lệ: `test/readout_web/live/demo_live_test.exs`, dùng `register_and_log_in_user`, `Phoenix.LiveViewTest`):
  1. Truy cập **ẩn danh** `/digest` → redirect `/users/log-in`.
  2. **Đã đăng nhập**, chưa có gì → render empty-state.
  3. Có một Summary hôm nay cho **Source operator subscribe** → bấm "Tạo digest" → bài hiện trong digest (kèm summary text + tag).
  4. Một Summary cho **Source operator KHÔNG subscribe** → không xuất hiện.
  5. Bấm tạo **2 lần** → không nhân đôi item.
- **Seam 2 — context `Curation`** (tiền lệ: `test/readout/ingestion_test.exs`, `test/readout/analysis_test.exs`; dùng `AccountsFixtures.user_scope_fixture`) — cho invariant UI không lái được:
  1. **Cửa sổ chọn**: Summary `inserted_at` hôm nay (nguồn subscribe) → vào digest; Summary backdate hôm qua → bị loại; Summary của nguồn không subscribe → bị loại.
  2. **Idempotent**: gọi `generate_digest` hai lần cho hôm nay → đúng một `Digest`, không trùng `DigestItem`.
  3. **Guard quá khứ**: `generate_digest(scope, hôm_qua)` → no-op (không tạo/sửa digest ngày cũ).
  4. **Digest rỗng**: hôm nay không có Summary đủ điều kiện → vẫn upsert một `Digest` rỗng cho `(user, hôm nay)`.
- **Hai seam (không phải một)** vì logic tuyển chọn/đóng-băng-quá-khứ ở tầng context không với tới được qua nút bấm trên UI (UI chỉ sinh "hôm nay"). Cả hai seam đều có tiền lệ sẵn trong codebase.

## Out of Scope

- **Tự động hóa trigger**: cron định kỳ (vd 3h/lần) và refresh khi có Summary mới (PubSub) — defer; hàm sinh đã idempotent để gắn sau là cộng dồn.
- **Real-time UI**: `/digest` không tự cập nhật khi có Summary mới về; phải bấm nút.
- **Snapshot nội dung**: digest trỏ tới Summary (pointer), không copy chữ; đóng băng-nội-dung tuyệt đối để dành (ADR 0009).
- **Lịch sử/duyệt digest ngày cũ**: trang chỉ hiện digest hôm nay; xem lại các ngày trước là việc sau.
- **Cá nhân hóa nội dung thật**: ranking theo tag, lọc theo sở thích, dedup ngữ nghĩa — thuộc giai đoạn sau của `Curation`.
- **Gửi digest qua email**, đánh dấu đã đọc, múi giờ người dùng — multi-user / sau này.

## Further Notes

- Tham chiếu **ADR 0009** (`docs/adr/0009-curation-context-persisted-daily-digest.md`) cho mọi quyết định lớn và trade-off; **ADR 0008** cho nền auth single-operator.
- "operator" là cách gọi User duy nhất ở giai đoạn B; `Curation`/`DigestItem` là tên context/schema, không phải từ vựng người dùng → không thêm vào `CONTEXT.md`. Thuật ngữ **Digest**, **Summary**, **Source**, **User** theo glossary hiện có.
- Email seed operator và auth đã có từ nhánh real-auth; slice này dựng thẳng trên `current_scope.user`.
