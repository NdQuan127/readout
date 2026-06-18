---
name: rich-html-documents
description: Generate self-contained HTML artifacts instead of markdown walls when spatial layout, color, diagrams, or interactivity would make the output more readable. Use for code reviews, side-by-side explorations, status reports, diagrams, slide decks, incident timelines, design systems, or any document where the user benefits from seeing structure rather than reading a text wall. Always keep the chat conversation in markdown — HTML is a file attachment for the user to open in a browser.
---

# Rich HTML Documents

Generate single-file, self-contained HTML documents as user-facing artifacts. Zero dependencies, zero build step, zero server. The user opens the file in a browser. The agent never reads HTML back — markdown stays the conversation protocol.

## Core Rule

- **Markdown = chat protocol.** Every agent turn: markdown. Summaries, questions, answers, next steps — all in markdown.
- **HTML = user artifact.** When the content benefits from spatial layout (side-by-side, diff annotations, timelines, diagrams, charts, slides), write a `.html` file and tell the user the path. That's it. No server, no frame template, no event loop, no background process.
- **Never paste HTML into chat.** Do not output raw HTML tags in the terminal conversation. The HTML file is for the browser, not for chat.

## When to Use

Use this skill when the answer to _"would the user understand this better by seeing it than by reading it?"_ is yes.

| Situation | Use |
|---|---|
| Comparing 2+ approaches / designs / options | `exploration-code-approaches.html` or `exploration-visual-designs.html` |
| Reviewing a PR with annotated diffs | `code-review-pr.html` |
| Mapping an unfamiliar module / package | `code-understanding.html` |
| Writing a PR description for reviewers | `pr-writeup.html` |
| Explaining how a feature works (collapsible, tabbed) | `research-feature-explainer.html` |
| Teaching a concept with live demo / diagram | `research-concept-explainer.html` |
| Drawing a flowchart or deploy pipeline | `flowchart-diagram.html` |
| Weekly status, burndown, metric cards | `status-report.html` |
| Incident post-mortem with timeline | `incident-report.html` |
| Implementation plan with milestones | `implementation-plan.html` |
| Design system tokens / component variants | `design-system.html` or `component-variants.html` |
| Presentation / walkthrough slides | `slide-deck.html` |
| Prototyping animation curves in isolation | `prototype-animation.html` |
| Prototyping a click-through flow | `prototype-interaction.html` |
| SVG figure sheet for a blog post | `svg-illustrations.html` |
| Drag-drop ticket triage board | `editor-triage-board.html` |
| Feature flag toggle editor | `editor-feature-flags.html` |
| Prompt template tuner with live preview | `editor-prompt-tuner.html` |

When in doubt, default to markdown. HTML is a power tool, not a default.

## Workflow

### 1. Pick the template

Read this skill file to match the user's request to a template name. Then `read` the chosen template from `templates/<name>.html`. The template is a complete, self-contained HTML file with CSS and sample data.

### 2. Strip and customize

Keep the entire `<style>` block and all CSS intact. Replace only the sample content:

- `<title>` — use a real title
- The prompt box / eyebrow / header — replace with the actual context
- All sample data: code blocks, metrics, names, dates, ticket IDs, numbers — replace with real data from the user's codebase or request
- The recommendation / conclusion section — write real conclusions

Do NOT:
- Add external CSS/JS links (no CDN, no Tailwind, no Mermaid unless the template already uses it)
- Add npm or build steps
- Change the CSS variables (`--ivory`, `--slate`, `--clay`, `--olive`, `--oat`) — they are a shared design system across all templates
- Remove the Apache-2.0 license header at the top

### 3. Write the file

Write the customized HTML to a predictable location. Preference order:

1. `<project-root>/docs/output/` if the project has a `docs/` directory
2. `<project-root>/output/` as fallback
3. OS temp directory as last resort: `$TMPDIR` or `/tmp/`

Filename convention: `YYYY-MM-DD-<topic>.html`

```bash
# Example
write /home/user/project/docs/output/2026-05-22-debounce-approaches.html
```

### 4. Report in markdown

After writing the file, return to markdown chat. Tell the user:
- Absolute file path
- One-sentence summary of what's inside
- The key takeaway or recommendation (in markdown, not just "see the file")

Example:

> I created a side-by-side comparison of the three debounce approaches at:
> `/home/user/project/docs/output/2026-05-22-debounce-approaches.html`
>
> **Key takeaway:** Approach 2 (custom hook) is the sweet spot — removes duplication without adding a dependency. See the HTML for the full annotated diff and trade-off table.

### 5. Conversation continues in markdown

The user may open the HTML or may not. Either way, the next turn continues in markdown. Reference the HTML file by path if needed, but do not paste its contents into chat.

## Template Catalog

All templates live in `templates/`. Each is a self-contained `.html` file with inline CSS and sample data.

### Exploration & Planning

- **`exploration-code-approaches.html`** — Side-by-side comparison of 2-3 code approaches. Each approach gets a card with code block, pro/con table, and metadata chips (bundle impact, testability, etc.). Ends with a recommendation block.
- **`exploration-visual-designs.html`** — Side-by-side visual directions (e.g. 4 layout/palette options). Includes a light/dark theme toggle toolbar. Each direction in an artboard with a live rendered mockup and rationale.
- **`implementation-plan.html`** — Milestones on a timeline, data-flow diagram, inline mockups, risky code blocks, and a risk table. The plan you hand off before coding.

### Code Review & Understanding

- **`code-review-pr.html`** — Annotated diff with margin notes, severity tags (critical / warning / info), file tree sidebar, and jump links. Easier to scan than terminal output.
- **`pr-writeup.html`** — Author's side: motivation, before/after, file-by-file tour with the *why*, and where reviewers should focus.
- **`code-understanding.html`** — Module map: boxes and arrows for an unfamiliar package, hot path highlighted, entry points listed.

### Design

- **`design-system.html`** — Living design system: colors as swatches, type scale, spacing tokens pulled from a repo. Copy-friendly.
- **`component-variants.html`** — Every size, state, and intent of one component laid out on a single sheet.

### Prototyping

- **`prototype-animation.html`** — Animation sandbox with sliders for duration and easing. Tune the transition in isolation before wiring it in.
- **`prototype-interaction.html`** — Multi-screen click-through flow linked with anchor navigation. Enough fidelity to feel the interaction.

### Communication

- **`slide-deck.html`** — Arrow-key slide deck. `<section>` tags become slides. No build step, no Keynote export.
- **`status-report.html`** — Weekly status: what shipped, what slipped, a small bar chart. Formatted for a Monday-morning skim.
- **`incident-report.html`** — Post-mortem with minute-by-minute timeline, log excerpts, and follow-up checklist.
- **`pr-writeup.html`** — (see Code Review section above)

### Diagrams & Research

- **`svg-illustrations.html`** — SVG figure sheet for a blog post. Diagrams drawn inline so they can be tweaked and copied out.
- **`flowchart-diagram.html`** — Annotated flowchart with clickable nodes. Click any step to see details, timings, and failure paths.
- **`research-feature-explainer.html`** — "How X works" explainer: TL;DR box, collapsible request-path steps, tabbed code snippets, FAQ.
- **`research-concept-explainer.html`** — Concept explainer with an interactive demo (e.g. a ring you can add/remove nodes from), comparison table, hover-linked glossary.

### Custom Editors

- **`editor-triage-board.html`** — Kanban-style board: drag tickets across Now / Next / Later / Cut. Ends with a "copy as markdown" button.
- **`editor-feature-flags.html`** — Toggle switches grouped by area. Dependency warnings when prerequisites are off. "Copy diff" button for changed keys.
- **`editor-prompt-tuner.html`** — Editable template on the left, three sample inputs on the right, re-rendered live as you type.

## Design System Reference

All templates share a single palette and type scale. Do not drift from it — consistency is the point.

```css
:root {
  --ivory:    #FAF9F5;   /* page background */
  --slate:    #141413;   /* headings, primary text */
  --clay:     #D97757;   /* accent, warnings, CTAs */
  --oat:      #E3DACC;   /* tags, highlights, secondary accent */
  --olive:    #788C5D;   /* success, positive indicators */
  --rust:     #B04A3F;   /* errors, critical severity */
  --gray-150: #F0EEE6;   /* panels, subtle backgrounds */
  --gray-300: #D1CFC5;   /* borders, dividers */
  --gray-500: #87867F;   /* secondary text, metadata */
  --gray-700: #3D3D3A;   /* body text */

  --serif: ui-serif, Georgia, 'Times New Roman', serif;
  --sans:  system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
  --mono:  ui-monospace, 'SF Mono', Menlo, Monaco, monospace;
}
```

- Borders are `1.5px solid var(--gray-300)` (not `1px` — the half-pixel is intentional)
- Border radius clusters around `8px` (chips, rows) and `12-14px` (cards, panels)
- Headings use `var(--serif)` at `font-weight: 500` with negative letter-spacing
- Code blocks use `var(--mono)` on `var(--slate)` background with syntax highlighting via `<span class="kw">`, `<span class="str">`, `<span class="cm">`, `<span class="fn">`

## Anti-Patterns

- **Do not create a web app.** One file, no server, no router, no state management. If you find yourself adding a build step, stop.
- **Do not paste HTML into chat.** The file is for the browser. Chat stays markdown.
- **Do not read the HTML file back.** If you need to reference what you wrote, keep the key points in your markdown summary or regenerate from the user's request.
- **Do not use external CDNs.** The templates are self-contained. If you need a chart or diagram the template doesn't already handle, draw it with inline SVG or CSS. Do not add `<script src="https://cdn...">`.
- **Do not change the color palette per file.** The shared palette is what makes 20 different documents feel like a coherent system.
