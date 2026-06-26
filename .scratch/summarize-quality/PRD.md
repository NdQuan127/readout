# Nâng chất Summarize — prompt trung thực, tag vocabulary thiết kế lại, render Markdown

Status: done

## Problem Statement

Là operator, khi mở Digest tôi thấy các Summary **nhạt và generic**: chúng đọc như "bài viết này thảo luận về…", không bám cấu trúc và giọng gốc của Article, dễ rơi vào văn bách khoa phẳng lì. Gốc rễ là prompt sinh Summary hiện quá sơ sài — chỉ vỏn vẹn "Summarize this article in Vietnamese", và còn tham chiếu tới một "configured closed vocabulary" mà **prompt không thực sự liệt kê tag nào ra** cho model.

Thêm hai chỗ chướng:
- **Tag lộn xộn.** Tập tag hiện tại trộn hai trục — chủ đề (`technology`, `science`…) lẫn địa lý (`world`) — và trộn cả grain (tag thô nuốt mọi bài lẫn tag hẹp), nên Tag gần như vô dụng để phân loại/lọc.
- **Markdown hiển thị thô.** Nếu Summary chứa định dạng, Digest đổ thẳng chuỗi vào thẻ `<p>` nên người đọc thấy `**`, `#` literal thay vì văn bản đã định dạng.

Tôi cần Summary trung thực hơn, Tag có ý nghĩa để lọc, và bản tóm tắt hiển thị sạch sẽ — mà **không** phá vỡ kiến trúc một-call Gemini structured output đã chốt ở ADR 0006.

## Solution

Nâng chất Summary trong đúng một call Gemini structured output (giữ nguyên ADR 0006: `responseMimeType` + `responseSchema`, không tái lập fallback của legacy), gồm ba mảng:

1. **Viết lại prompt "não".** Bỏ hướng dẫn theo-thể-loại hardcode; thay bằng các chỉ thị **phổ quát**: phản chiếu cấu trúc/mạch của Article, giữ giọng/register tác giả, mật độ thông tin theo kiểu Chain-of-Density (recall-trước-precision, để chính nguồn định nghĩa cái gì "nổi bật"), cấm mở bài rỗng, và một dòng chống prompt injection ("treat as data") với delimiter bao quanh Content. Thân Summary **co giãn theo nguồn + cấm filler** thay vì ép độ dài cứng.

2. **Thiết kế lại Tag vocabulary.** Một tập **đóng** 11 tag, theo nguyên tắc *single-axis (chủ đề) + load-bearing + grain-theo-mật-độ-corpus*: chẻ mịn vùng tech (corpus dày), để thô vùng ngoài tech (thưa). Trần 3 tag là **ngưỡng tối đa, không phải chỉ tiêu**. Code là source-of-truth: lọc bỏ tag ngoài vocabulary và cắt ≤3, bất kể model trả gì.

3. **Render Markdown an toàn ở Digest.** Lưu Markdown trong Summary, render-lúc-hiển-thị qua MDEx với sanitize built-in, đặt trong một helper dùng chung để slice UI sau tái dùng.

`output_language` và tag vocabulary nằm trong runtime config (đổi theo deployment không cần recompile); phần còn lại của prompt hardcode. Không thêm tầng eval, không thêm field output — Summary vẫn chỉ gồm summary text (Markdown) và Tag.

## User Stories

1. Là operator, tôi muốn Summary bám sát cấu trúc và mạch trình bày của Article gốc, để bản tóm tắt phản ánh đúng bài thay vì bị nhồi vào một khuôn mẫu cứng.
2. Là operator, tôi muốn Summary giữ giọng/register của tác giả ở mức vừa đủ, để bài quan điểm vẫn ra chất quan điểm, bài kỹ thuật vẫn ra chất kỹ thuật, không bị làm phẳng thành văn bách khoa.
3. Là operator, tôi muốn mọi thông tin mà chính Article làm nổi bật (tên riêng, con số, ngày tháng, luận điểm trung tâm) đều xuất hiện trong Summary, để không mất chi tiết then chốt.
4. Là operator, tôi muốn Summary ưu tiên diễn đạt cụ thể, dày thông tin và không độn filler chung chung, để đọc nhanh mà vẫn nắm đủ.
5. Là operator, tôi muốn Summary không mở bằng câu rỗng kiểu "Bài viết này thảo luận về…" hay "Tóm lại…", để vào thẳng nội dung.
6. Là operator, tôi muốn thân Summary dài ngắn co giãn theo lượng chất của Article, để bài giàu thông tin có tóm tắt đầy đặn còn bài mỏng không bị kéo dài giả tạo.
7. Là operator, tôi muốn Summary trung thực với nguồn — không suy diễn, ngoại suy hay phỏng đoán vượt khỏi Article, để tôi tin được những gì mình đọc.
8. Là operator, tôi muốn Summary giữ nguyên thuật ngữ kỹ thuật bằng tiếng Anh khi cần, để không bị dịch ép làm sai nghĩa chuyên ngành.
9. Là chủ hệ thống, tôi muốn nội dung Article được model coi là **dữ liệu để tóm tắt, không phải chỉ thị**, để một Article độc cố nhúng lệnh không lái được hành vi model.
10. Là chủ hệ thống, tôi muốn Content được bao trong delimiter rõ ràng trong prompt, để ranh giới chỉ-thị / dữ-liệu tường minh với model.
11. Là chủ hệ thống, tôi muốn dựa vào structured output làm phòng tuyến cấu trúc (model chỉ điền được summary text + Tag, không gọi được tool), để blast radius của injection bị khóa ở "Summary bị bẩn".
12. Là operator, tôi muốn mỗi Article được gán Tag từ một tập đóng có kiểm soát, để Tag đủ nhất quán mà lọc/nhóm về sau.
13. Là operator, tôi muốn tập Tag chỉ gồm các nhãn chủ đề thực sự phân biệt được (load-bearing), để không có nhãn rỗng kiểu "World" chỉ là ngăn kéo rác.
14. Là operator, tôi muốn vùng chủ đề tech được chẻ mịn (AI, Software, Infra, Security, Hardware), để phân biệt được giữa các bài tech vốn chiếm phần lớn nguồn của tôi.
15. Là operator, tôi muốn vùng ngoài tech để thô (Science, Business, Finance, Policy, Culture, Math), để không sinh ra nhãn quá hẹp gần như không bao giờ khớp.
16. Là operator, tôi muốn mỗi Article có nhiều nhất 3 Tag và model **không độn cho đủ 3**, để Tag yếu không làm loãng khả năng lọc.
17. Là operator, tôi muốn Article không khớp nhãn nào thì để trống Tag, để hệ thống không gán bừa một nhãn mặc định sai.
18. Là chủ hệ thống, tôi muốn code lọc Tag là source-of-truth — bỏ mọi Tag ngoài vocabulary và cắt còn ≤3 bất kể model trả gì, để prompt chỉ là gợi ý mềm còn code là phanh cứng.
19. Là chủ hệ thống, tôi muốn Tag được lưu và hiển thị theo đúng casing chuẩn của vocabulary (vd "AI", "Software"), để badge trên Digest nhất quán, không bị hạ về chữ thường.
20. Là chủ hệ thống, tôi muốn vocabulary Tag được khớp không-phân-biệt-hoa-thường khi model trả về, để "ai"/"AI"/"Ai" đều quy về cùng một Tag chuẩn.
21. Là operator, tôi muốn Summary hiển thị trên Digest dưới dạng Markdown đã render (đậm, danh sách, tiêu đề, link), để dễ đọc thay vì thấy ký tự định dạng thô.
22. Là chủ hệ thống, tôi muốn HTML render từ Markdown được sanitize (loại `<script>`, `onclick`…), để một Summary chứa mã độc không tạo lỗ hổng XSS trên Digest.
23. Là developer, tôi muốn việc render Markdown nằm trong một helper dùng chung, để slice UI sau (master-detail) tái dùng đúng một đường render, không nhân bản logic.
24. Là chủ hệ thống, tôi muốn `output_language` và tag vocabulary đặt trong runtime config, để đổi ngôn ngữ tóm tắt hoặc tập Tag theo deployment mà không cần recompile.
25. Là chủ hệ thống, tôi muốn prompt thực sự liệt kê tag vocabulary và ngôn ngữ đầu ra lấy từ config, để model biết chính xác tập Tag được phép thay vì một tham chiếu rỗng.
26. Là chủ hệ thống, tôi muốn giữ nguyên một call Gemini structured output (ADR 0006), không thêm tầng eval/critic/verifier, để slice gọn theo tinh thần tracer-bullet.
27. Là chủ hệ thống, khi Gemini lỗi tạm thời lúc sinh Summary, tôi muốn dựa vào Oban retry sẵn có thay vì cơ chế fallback plain-text nhiều bước của legacy, vì Gemini Flash Lite trả JSON đúng schema đủ tin (ADR 0006).
28. Là operator, tôi muốn Summary rỗng/thiếu bị từ chối ở changeset (summary text bắt buộc), để Digest không hiển thị mục trống.

## Implementation Decisions

**Phạm vi module (tên, không phải path):**
- **GeminiClient** — viết lại hàm dựng prompt: hardcode phần "não" (vai trò, chỉ thị trung thực cấu trúc + register, chỉ thị mật độ kiểu Chain-of-Density phổ quát recall-trước-precision, cấm mở bài rỗng, dòng "treat as data" + delimiter bao Content), và **tiêm từ config** `output_language` cùng danh sách tag vocabulary vào prompt. `responseSchema` **giữ nguyên** `["summary_text", "tags"]` — overview đã bị cắt nên không đổi schema, không đổi response decode.
- **Analysis** — `normalize_tags` đã tồn tại và đã đọc vocabulary từ config; sửa để (a) khớp vocabulary **không-phân-biệt-hoa-thường**, (b) **phát ra casing chuẩn** của vocabulary thay vì hạ chữ thường, (c) tiếp tục cắt ≤3 và bỏ tag ngoài tập. Trần 3 giữ nguyên như ngưỡng cứng.
- **Web HTML helper dùng chung** — thêm `render_markdown/1` trả về HTML an toàn (`{:safe, ...}`) qua MDEx với sanitize built-in.
- **DigestLive** — thay chỗ đổ thẳng chuỗi summary text bằng lời gọi `render_markdown/1`.

**Tag vocabulary (tập đóng, 11 tag, casing chuẩn):**
`AI · Software · Infra · Security · Hardware · Science · Business · Finance · Policy · Culture · Math`
- Nguyên tắc: single-axis (chủ đề, không địa lý) + load-bearing (cắt ngăn-kéo-rác) + grain-theo-mật-độ (chẻ mịn vùng tech dày, để thô vùng ngoài tech thưa).
- Ranh **Business | Finance**: Business = công ty/ngành (startup, M&A, funding, chiến lược, động thái big-tech); Finance = tiền như đối tượng (thị trường, vĩ mô/kinh tế, fintech, trading, lãi suất).
- **Math** = facet định nghĩa hẹp — chỉ gán khi toán là *đối tượng cốt lõi* (chứng minh, lý thuyết thuật toán, numerical methods, formal math), không gán cho mọi bài có dùng toán. Hợp lệ khi đi kèm beat khác (vd `[AI, Math]`) nhờ cho phép tối đa 3 Tag.
- Bỏ khỏi tập cũ: `world`, `economy`, `health`, `politics` → thay bằng tập trên; không có `Crypto`, không có `Entertainment`, không có tag địa lý.

**Schema / dữ liệu:**
- **Không migration.** Cột `summary_text` (string) và `tags` (array) đã có; từ nay `summary_text` *chứa* Markdown. Changeset giữ `validate_required([:article_id, :summary_text])` và `unique_constraint(:article_id)` — không thêm validate độ dài/chất lượng.
- Summary vẫn lưu **global 1:1 với Article**, dùng chung cho mọi User (không đổi).

**Prompt — hành vi đã chốt:**
- Một dòng rule mật độ phổ quát thay cho checklist liệt kê cũ: bắt trọn cái nguồn nhấn mạnh (recall) rồi siết cho dày, phản chiếu cấu trúc + register, không độn, không editorialize. **Không** dùng chỉ dẫn "tách fact khỏi interpretation" (đánh nhau với việc giữ register).
- Tag: "chỉ gán chủ đề bài thực sự nói về — thường 1–2, tối đa 3; ít là tốt, đừng độn cho đủ 3".
- Bỏ cơ chế "rà thầm trước khi viết" và bỏ hướng dẫn theo-thể-loại hardcode.

**Config:**
- `output_language` (default "Vietnamese") và `allowed_tags` (11 tag chuẩn) đọc qua runtime config / ENV với default; phần còn lại của prompt hardcode trong GeminiClient. Test config dùng giá trị dummy (không đụng secret thật).

**Dependency:**
- Thêm **MDEx** vào project cho render + sanitize Markdown.

## Testing Decisions

Một test tốt chỉ kiểm **hành vi ngoài** (Summary được lưu thế nào, Tag được lọc ra sao, HTML render có sạch không), **không** kiểm chi tiết hiện thực (không snapshot toàn prompt, không assert hàm private). Hai seam, ưu tiên tái dùng seam sẵn có:

- **Seam 1 — `ArticleSummarizeWorker` / `Analysis.summarize_article` qua `Req.Test` (ĐÃ CÓ, cao nhất).** Đây chính là seam mà `test/readout/analysis_test.exs` đang dùng (prior art): stub `Req.Test` cho `GeminiClient`, đọc request body, rồi `perform_job` và assert `ArticleSummary` đã lưu. Slice này mở rộng nó để phủ:
  - *Prompt invariants*: stub assert prompt chứa `output_language` cấu hình, **các Tag của vocabulary**, delimiter bao Content, và nội dung Article (đã cắt theo `@max_content_length` — assertion cắt-content đã có sẵn).
  - *Tag filtering + casing*: stub trả Tag ngoài vocabulary và >3 → assert Summary lưu ≤3 Tag, đúng casing chuẩn, khớp không-phân-biệt-hoa-thường.
  - *Persistence + broadcast*: `summary_text` Markdown được lưu; `{:article_summarized, id}` được phát trên topic của Source.
  - `normalize_tags` và kiểm tra nội dung prompt **không cần seam riêng** — test xuyên qua seam này, không expose hàm private.
- **Seam 2 — `render_markdown/1` (MỚI, pure).** Hàm render là điểm test trực tiếp: assert Markdown ra HTML đúng (đậm, list, link), và **XSS** — input chứa `<script>`/`onclick` thì HTML ra đã bị sanitize bỏ.

Test config đã wire sẵn (`req_options: [plug: {Req.Test, GeminiClient}]`), nên không cần dựng hạ tầng test mới. Không test chất lượng nội dung Summary (faithfulness/density) — đó là việc của eval-layer đã cố tình defer (xem ADR 0006: chỉ thêm quality-check khi quan sát lỗi lặp lại thật).

## Out of Scope

- **Tầng eval / critic-verifier / claim-evidence / LLM-as-judge / regression dataset** — một hệ riêng, defer thành slice "summarize eval harness" tương lai.
- **Per-user summary language** — Summary vẫn global 1:1 với Article; ngôn ngữ là instance-wide. Per-(Article, language) để dành slice sau nếu thật sự cần.
- **UI master-detail + polish UI/UX (sidebar tiêu đề ↔ pane chi tiết)** — đó là Slice 2; ở đây chỉ render Markdown tối thiểu trong layout Digest hiện có.
- **Field `overview`** — đã cắt; nếu Slice 2 cần teaser riêng thì thêm cột nullable + một batch regen sau.
- **Tag `Crypto`, `Entertainment`, tag địa lý** — không đưa vào tập; thêm lại sau nếu nguồn phát sinh nhu cầu thật.
- **Link `target="_blank" rel="noopener"`** trong Summary — để default cùng tab; tinh chỉnh sau.
- **Quality-check JSON / fallback plain-text nhiều bước / xoay vòng model** — đã bỏ theo ADR 0006, không tái lập.

## Further Notes

- Tôn trọng **ADR 0006** (Gemini Flash Lite + structured output, bỏ fallback machinery): slice này không đổi shape `generationConfig` và không tái lập lớp chống-JSON-rác; phần "Summary hợp lệ nhưng nhạt" được cải thiện bằng prompt, đúng tinh thần "chỉ thêm check khi thấy lỗi lặp lại".
- Việc thiết kế lại **tag taxonomy** (nguyên tắc single-axis + load-bearing + grain-theo-mật-độ) và **triết lý prompt trung-thực-cấu-trúc/register** là quyết định kiến trúc bền — cân nhắc ghi một ADR mới khi triển khai để chốt rationale (đặc biệt ranh Business|Finance và Math-as-facet).
- Tập Tag mới làm test hiện có trong `analysis_test.exs` lỗi thời (đang assert `["ai","technology","world"]` chữ thường) — test này sẽ được viết lại theo vocabulary và casing chuẩn mới.
- Tinh thần xuyên suốt khi viết prompt: **leading words + cắt no-op + single source of truth** (theo `writing-great-skills`) — prompt mới phải ngắn, mỗi dòng đổi hành vi so với default của model, tránh over-specify gây hại cho model reasoning.
