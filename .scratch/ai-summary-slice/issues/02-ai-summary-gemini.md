# AI Summary (Gemini Flash Lite) trên Content

Status: ready-for-agent

## What to build

Tracer bullet cho bước tóm tắt AI, nối tiếp pipeline cào của slice 01.

`ArticleScrapeWorker` sau khi ghi Content xong sẽ **enqueue** `ArticleSummarizeWorker` (bàn giao qua Oban enqueue, KHÔNG dùng PubSub — PubSub chỉ để đẩy UI). Worker summarize đọc Content (truncate ~15.000 ký tự), gọi **Gemini Flash Lite** qua client `Req` với **structured output (`responseSchema`)**, nhận về JSON đúng schema, ghi **Summary** (schema `ArticleSummary`, Analysis context, 1:1 global với Article) gồm `summary_text` + `tags`. Sau đó broadcast `source:#{source_id}:summarized` → `DemoLive` render summary + tags inline, thay cho badge "đã cào" của slice 01.

Tags theo **closed vocabulary** hard-code trong config (không env-var): output Gemini được validate/normalize theo whitelist, tag lạ thì drop, tối đa 3.

KHÔNG port fallback machinery của legacy (repair JSON, fallback plain-text 4 bước, sanitize LaTeX, heuristic meta-text) — `responseSchema` ép schema ngay tầng decode (ADR 0006). Lỗi tạm thời (429/timeout/5xx) giao Oban retry. Model id để một biến trong config.

Bỏ `hot_score`. Defer `AiUsage` — chỉ `Logger` token count từ `usageMetadata` khi dev, không persist.

Thuật ngữ: **Summary**, **Tag** theo glossary trong `CONTEXT.md`.

## Acceptance criteria

- [ ] `Analysis` context + schema `ArticleSummary` (1:1 global với Article): `summary_text`, `tags`
- [ ] Client Gemini (`Req`) gọi Flash Lite với `responseSchema`; model id nằm trong config
- [ ] `ArticleScrapeWorker` enqueue `ArticleSummarizeWorker` sau khi ghi Content thành công
- [ ] Tags validate theo whitelist hard-code: tag ngoài danh sách bị drop, tối đa 3
- [ ] Content được truncate ~15k ký tự trước khi gửi Gemini
- [ ] Test (mock Gemini): ghi Summary đúng + drop tag lạ
- [ ] Summarize xong, card hiển thị summary + tags inline realtime qua PubSub `:summarized`, không reload
- [ ] LiveView test giả lập `{:article_summarized, _}` → card render summary + tags
- [ ] Không có code fallback/LaTeX/meta-text heuristic của legacy

## Blocked by

- `.scratch/ai-summary-slice/issues/01-manual-scrape-article-content.md`
