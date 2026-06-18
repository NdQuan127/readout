# Slide Decks: HTML Slide Deck Production Specification

Making slide decks is a high-frequency scenario in design work. This document describes how to create high-quality HTML slide decks—from architectural selection and single-page design to the complete path of PDF/PPTX export.

**This skill's capability coverage**:
- **HTML presentation version (basic deliverable, always default and required)** → Each page is an independent HTML + aggregated by `assets/deck_index.html` for keyboard page turning and full-screen presentations in browsers.
- HTML → PDF export → `scripts/export_deck_pdf.mjs` / `scripts/export_deck_stage_pdf.mjs`
- HTML → Editable PPTX export → `references/editable-pptx.md` + `scripts/html2pptx.js` + `scripts/export_deck_pptx.mjs` (requires HTML to follow 4 hard constraints)

> **⚠️ HTML is the foundation; PDF/PPTX are derivatives.** Regardless of the final delivery format, the aggregated HTML presentation version (`index.html` + `slides/*.html`) **must** be created first. It is the "source" of the slide deck work. PDF/PPTX are snapshots exported from the HTML with a single command.
>
> **Why HTML First**:
> - Best for presentations/demos on-site (projector/screen sharing full screen directly, keyboard page-turning, no dependency on Keynote/PPT software)
> - Each page can be individually opened by double-clicking to verify during development without running the export script every time
> - It is the sole upstream for PDF/PPTX export (avoiding the infinite loop of "discovering changes needed after export, which requires modifying the HTML and exporting again")
> - Deliverables can be a dual set of "HTML + PDF" or "HTML + PPTX", allowing the recipient to use whichever they prefer.
>
> 2026-04-22 moxt brochure real-world test: after completing 13 pages of HTML + `index.html` aggregation, `export_deck_pdf.mjs` exported the PDF in one command with zero changes. The HTML version itself is a deliverable that can be played directly in a browser.

---

## 🛑 Confirm Delivery Format Before Starting (The Hardest Checkpoint)

**This decision comes before deciding "single file vs. multiple files".** Real-world test of the Options Private Board project on 2026-04-20: **Failure to confirm the delivery format before starting = 2-3 hours of rework.**

### Decision Tree (HTML-First Architecture)

All deliveries start from the same HTML aggregation page (`index.html` + `slides/*.html`). The delivery format only determines **HTML writing constraints** and **export commands**:

```
[Always Default · Required] HTML Aggregation Presentation Version (index.html + slides/*.html)
   │
   ├── Only browser presentation / local HTML archive   → Completed here, maximum visual freedom in HTML
   │
   ├── Also need PDF (print / share in group / archive) → Run export_deck_pdf.mjs to export with one click
   │                                                      HTML writing is free, no visual constraints
   │
   └── Also need editable PPTX (colleague needs to edit text) → Must follow the 4 hard constraints from the first line of HTML
                                                               Run export_deck_pptx.mjs to export with one click
                                                               Sacrifices gradients / web components / complex SVGs
```

### Communication Script (Copy and Use)

> Regardless of whether the final delivery is HTML, PDF, or PPTX, I will first create an HTML aggregation version (`index.html` with keyboard page-turning) that can be switched and presented in the browser—this is always the default basic deliverable. On top of that, I'll ask if you need an additional snapshot in PDF / PPTX format.
>
> Which export format do you need?
> - **HTML only** (presentation/archive) → complete visual freedom
> - **Also need PDF** → Same as above, plus one export command
> - **Also need editable PPTX** (colleagues will edit text in PPT) → I must write the HTML following the 4 hard constraints from the very first line of code, which will sacrifice some visual features (no gradients, no web components, no complex SVGs).

### Why "Editable PPTX Requires Following the 4 Hard Constraints from the Beginning"

For the PPTX to be editable, `html2pptx.js` must translate the DOM element-by-element into PowerPoint objects. It requires **4 hard constraints**:

1. The body must be fixed at 960pt × 540pt (matching `LAYOUT_WIDE`, 13.333″ × 7.5″, not 1920×1080px)
2. All text must be wrapped inside `<p>` or `<h1>`–`<h6>` (divs directly containing text are prohibited; using `<span>` to carry main text is prohibited)
3. `<p>`/`<h*>` themselves cannot have background/border/shadow (place them on the outer div instead)
4. `<div>` cannot use `background-image` (use `<img>` tags instead)
5. No CSS gradients, no web components, no complex SVG decorations

**The default HTML visual freedom in this skill is high**—with many spans, nested flexbox, complex SVGs, web components (like `<deck-stage>`), and CSS gradients—**almost none of which can naturally pass html2pptx constraints** (real-world tests show that visually-driven HTML run directly through html2pptx has a pass rate of < 30%).

### Cost Comparison of Two Real Paths (Real-world pitfall on 2026-04-20)

| Path | Approach | Result | Cost |
|------|------|------|------|
| ❌ **Write HTML freely first, remedy PPTX later** | Single-file deck-stage + heavy use of SVG/span decorations | To get an editable PPTX, only two options remain:<br>A. Manually write hundreds of lines of hardcoded coordinates in pptxgenjs<br>B. Rewrite 17 pages of HTML into Path A format | 2-3 hours of rework, and the manual version carries **permanent maintenance cost** (modifying a single word in HTML requires manual synchronization in PPTX) |
| ✅ **Write following Path A constraints from step 1** | Independent HTML per page + 4 hard constraints + 960×540pt | Export 100% editable PPTX with one command, while also allowing full-screen presentation in browsers (Path A HTML is standard HTML playable in browsers) | 5 minutes extra during HTML writing to think about "how to wrap text in `<p>`", zero rework |

### What about mixed delivery?

If the user says, "I want HTML presentation **and** editable PPTX" — **this is not mixed**, the PPTX requirement supersedes the HTML requirement. The HTML written according to Path A can still be played full screen in the browser (just add a `deck_index.html` binder). **There is no extra cost.**

If the user says, "I want PPTX **and** animations / web components" — **this is a true contradiction**. Tell the user: to have an editable PPTX, these visual capabilities must be sacrificed. Let them choose; do not silently implement a manual pptxgenjs solution (which will become a permanent maintenance debt).

### What if I only find out PPTX is needed after the fact? (Emergency Remedy)

In very rare cases, the HTML is already written when you find out PPTX is required. The recommended fallback workflow is (see details at the end of `references/editable-pptx.md` under "Fallback: Visual layout exists but user insists on editable PPTX"):

1. **Preferred: Convert to PDF** (100% visual preservation, cross-platform, readable and printable by the recipient) — If the recipient's actual need is "presentation/archiving", PDF is the best deliverable.
2. **Alternative: AI rewrites into editable HTML based on the visual design** → Export to editable PPTX — Retains design decisions for colors, layout, and copywriting, while sacrificing gradients, web components, complex SVGs, and other visual capabilities.
3. **Not recommended: Rebuild by hand-writing pptxgenjs** — Positions, fonts, and alignments must be manually adjusted, resulting in high maintenance costs. Future updates to a single word in HTML will require manual sync again.

Always present the choices to the user and let them decide. **Never start hand-writing pptxgenjs as your first reaction**—that is the final fallback of last resort.

---

## 🛑 Before Mass Production: Create 2 Showcase Pages to Set the Grammar

**If the deck has ≥ 5 pages, absolutely do not write from page 1 straight to the last page.** Correct sequence validated in the 2026-04-22 moxt brochure project:

1. Select **2 page types with the greatest visual difference** to create showcases (e.g., "Cover" + "Mood/Quote page", or "Cover" + "Product Showcase page")
2. Take screenshots for the user to confirm the grammar (masthead / fonts / colors / spacing / structure / Chinese-to-English bilingual ratio)
3. Once the direction is approved, mass-produce the remaining N-2 pages, reusing the established grammar for each page
4. After completing all pages, synthesize them into the HTML aggregation + PDF / PPTX derivatives.

**Why**: Writing 13 pages straight through → User says "direction is wrong" = rework 13 times. Write 2 showcase pages first → direction is wrong = rework 2 times. Once the visual grammar is established, the decision space for the subsequent N pages is significantly narrowed, leaving only "how to put the content in".

**Showcase Page Selection Principles**: Choose the two pages with the most different visual structures. If these two pages pass, other intermediate states will pass.

| Deck Type | Recommended Showcase Page Combination |
|-----------|---------------------|
| B2B brochure / Product Announcement | Cover + Content page (concept/emotion page) |
| Brand Launch | Cover + Product feature page |
| Data Report | Data visualization page + Analysis conclusion page |
| Tutorials / Courseware | Section cover + Specific knowledge point page |

---

## 📐 Publication Grammar Template (Reusable, verified in moxt)

Suitable for B2B brochures / product announcements / long report-type decks. Reusing this structure on each page = 13 pages of completely consistent visuals, 0 rework.

### Page Skeleton

```
┌─ masthead (top strip + horizontal line) ────────────┐
│  [logo 22-28px] · A Product Brochure                Issue · Date · URL │
├──────────────────────────────────────────┤
│                                          │
│  ── kicker (green short line + uppercase tag)   │
│  CHAPTER XX · SECTION NAME                 │
│                                          │
│  H1 (Chinese Noto Serif SC 900)             │
│  Apply brand primary color to key words only                      │
│                                          │
│  English subtitle (Lora italic)            │
│  ─────────── Separator ──────────            │
│                                          │
│  [Specific content: two-column 60/40 / 2x2 grid / list] │
│                                          │
├──────────────────────────────────────────┤
│ section name                     XX / total │
└──────────────────────────────────────────┘
```

### Style Conventions (Copy directly)

- **H1**: Chinese Noto Serif SC 900, font size 80-140px depending on information volume. Highlight key words individually with the brand primary color (do not over-color the whole text).
- **English subtitle**: Lora italic 26-46px, brand signature terms (e.g., "AI team") in bold + primary color italic.
- **Body**: Noto Serif SC 17-21px, line-height 1.75-1.85.
- **Accent highlight**: Bold keywords with primary color in the body, max 3 per page (too many loses the anchoring effect).
- **Background**: Warm cream #FAFAFA + faint radial-gradient noise (`rgba(33,33,33,0.015)`) to add a paper-like feel.

### Visual Centerpiece Must Be Differentiated

If 13 pages are all "text + one screenshot", it gets monotonous. **Rotate the visual centerpiece type for each page**:

| Visual Type | Suitable Section |
|---------|---------------|
| Cover Layout (large text + masthead + pillar) | Home page / Chapter cover |
| Single-character portrait (large single mascot, etc.) | Introducing a single concept/character |
| Group portrait / Side-by-side avatar cards | Team / User case studies |
| Timeline card progression | Showing "long-term relationships" or "evolution" |
| Knowledge graph / Connected node diagram | Showing "collaboration" or "flow" |
| Before/After comparison cards + Center arrow | Showing "change" or "differences" |
| Product UI screenshot + Device mockup border | Specific feature showcases |
| Big-quote (half-page large text) | Emotion page / Problem page / Citation page |
| Real user avatar + Quote card (2×2 or 1×4) | User testimonials / Usage scenarios |
| Large-text back cover + Oval CTA button | CTA / Outro |

---

## ⚠️ Common Pitfalls (Summarized from moxt real-world tests)

### 1. Emojis not rendering during Chromium / Playwright export

Chromium does not include color emoji fonts by default. Emojis display as empty boxes in `page.pdf()` or `page.screenshot()`.

**Solution**: Use Unicode text symbols (`✦` `✓` `✕` `→` `·` `—`) instead, or use plain text ("Email · 23" instead of "📧 23 emails").

### 2. `export_deck_pdf.mjs` throws error `Cannot find package 'playwright'`

Reason: ESM module resolution looks up for `node_modules` from the script's location. The script is in `~/.claude/skills/huashu-design/scripts/`, where dependencies are missing.

**Solution**: Copy the script into your deck project directory (e.g., `brochure/build-pdf.mjs`), run `npm install playwright pdf-lib` in the project root, and then run `node build-pdf.mjs --slides slides --out output/deck.pdf`.

### 3. Screenshot taken before Google Fonts load → Chinese defaults to system sans-serif

Wait at least `wait-for-timeout=3500` before taking screenshots/PDFs with Playwright to let the web fonts download and paint. Or self-host fonts in `shared/fonts/` to reduce network dependencies.

### 4. Imbalanced Information Density: Stuffing too much into content pages

The first draft of the moxt philosophy page used 2×2 = 4 paragraphs + 3 tenets at the bottom = 7 content blocks, which was cramped and repetitive. Changing it to 1×3 = 3 paragraphs immediately restored breathing room.

**Solution**: Keep each page to "1 core message + 3-4 supporting points + 1 visual centerpiece". If it exceeds this, split it into a new page. **Less is more**—the audience looks at a page for 10 seconds. Giving them 1 takeaway is easier to remember than giving them 4.

---

## 🛑 Select Architecture First: Single File or Multiple Files?

**This decision is the very first step of making a slide deck. Getting it wrong leads to repeated setbacks. Read this section before writing any code.**

### Architectural Comparison

| Dimension | Single File + `deck_stage.js` | **Multiple Files + `deck_index.html` Binder** |
|------|--------------------------|--------------------------------------|
| Code Structure | One HTML, all slides are `<section>` | Independent HTML per page, `index.html` uses iframes to bind them |
| CSS Scope | ❌ Global; styles on one page may affect all pages | ✅ Naturally isolated; each iframe has its own scope |
| Verification Granularity | ❌ Requires JS goTo to switch to a specific page | ✅ Double-clicking a single page opens it in browser for preview |
| Parallel Development | ❌ One file; edits by multiple agents will conflict | ✅ Multiple agents can work on different pages in parallel, zero merge conflicts |
| Debugging Difficulty | ❌ A CSS error in one place ruins the entire deck | ✅ An error on one page only affects itself |
| Embedded Interactivity | ✅ Sharing state across pages is easy | 🟡 Requires postMessage between iframes |
| Print PDF | ✅ Built-in | ✅ Binder uses beforeprint to traverse iframes |
| Keyboard Navigation | ✅ Built-in | ✅ Built-in to the binder |

### Which to Choose? (Decision Tree)

```
│ Question: How many pages is the deck expected to have?
├── ≤10 pages, needs in-deck animations or cross-page interaction, pitch deck → Single File
└── ≥10 pages, academic lecture, courseware, long deck, parallel agents → Multiple Files (Recommended)
```

**Go with the multiple-file path by default**. It is not an "alternative"; it is the **primary path for long decks and team collaboration**. Reason: Every benefit of the single-file architecture (keyboard navigation, printing, scaling) is also available in the multiple-file approach, but the scope isolation and ease of verification of multiple files cannot be backported to a single-file system.

### Why is this rule so strict? (Real Incident Log)

The single-file architecture once hit four consecutive pitfalls during the creation of the AI Psychology Lecture deck:

1. **CSS Specificity Override**: `.emotion-slide { display: grid }` (specificity 10) overrode `deck-stage > section { display: none }` (specificity 2), causing all pages to render overlapping.
2. **Shadow DOM slot rules suppressed by outer CSS**: `::slotted(section) { display: none }` could not withstand overrides from outer rules, preventing sections from hiding.
3. **localStorage + hash navigation race condition**: Reloading stayed at the old position recorded in localStorage instead of jumping to the hash location.
4. **High verification cost**: You had to run `page.evaluate(d => d.goTo(n))` to capture a specific page, which was twice as slow as direct `goto(file://.../slides/05-X.html)` and frequently threw errors.

The root cause of all these issues was a **single global namespace**—which the multiple-file architecture physically eliminates.

---

## Path A (Default): Multiple-File Architecture

### Directory Structure

```
MyDeck/
├── index.html              # Copied from assets/deck_index.html, modify MANIFEST
├── shared/
│   ├── tokens.css          # Shared design tokens (palettes/font sizes/common chrome)
│   └── fonts.html          # <link> imports Google Fonts (included in each page)
└── slides/
    ├── 01-cover.html       # Each file is a complete 1920×1080 HTML
    ├── 02-agenda.html
    ├── 03-problem.html
    └── ...
```

### Single Slide Template Skeleton

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>P05 · Chapter Title</title>
<link href="https://fonts.googleapis.com/css2?family=..." rel="stylesheet">
<link rel="stylesheet" href="../shared/tokens.css">
<style>
  /* Page-specific styles. Any class name here will not pollute other pages. */
  body { padding: 120px; }
  .my-thing { ... }
</style>
</head>
<body>
  <!-- 1920×1080 content (body width/height locked in tokens.css) -->
  <div class="page-header">...</div>
  <div>...</div>
  <div class="page-footer">...</div>
</body>
</html>
```

**Key Constraints**:
- `<body>` is the canvas; lay out elements directly on it. Do not wrap them in `<section>` or other wrappers.
- `width: 1920px; height: 1080px` is locked by the `body` rule in `shared/tokens.css`.
- Import `shared/tokens.css` for shared design tokens (color palette, font sizes, page-header/footer, etc.).
- Write the font `<link>` in each page (importing fonts individually is inexpensive and ensures pages can be opened independently).

### Binder: `deck_index.html`

**Copy directly from `assets/deck_index.html`**. You only need to modify one place—the `window.DECK_MANIFEST` array, listing all slide file paths and human-readable labels in order:

```js
window.DECK_MANIFEST = [
  { file: "slides/01-cover.html",    label: "Cover" },
  { file: "slides/02-agenda.html",   label: "Table of Contents" },
  { file: "slides/03-problem.html",  label: "Problem Statement" },
  // ...
];
```

The binder has built-in: keyboard navigation (←/→/Home/End/numeric keys/P to print), scale + letterboxing, bottom-right counter, localStorage state preservation, hash navigation, and print mode (traversing iframes to output PDF page by page).

### Single-Page Verification (The killer feature of multiple-file architecture)

Each slide is a standalone HTML file. **Double-click to open it directly in the browser once done**:

```bash
open slides/05-personas.html
```

Playwright screenshot generation also goes directly to `goto(file://.../slides/05-personas.html)` without needing JS page-turning, and is completely free from interference by other pages' CSS. This reduces the cost of the "edit a bit, check a bit" loop to near zero.

### Parallel Development

Distribute the tasks for different slides to different agents to run concurrently—HTML files are independent, meaning zero conflicts when merging. For long decks, this parallel workflow can compress production time to 1/N.

### What to Put in `shared/tokens.css`

Only place things that are **truly shared across pages**:

- CSS variables (color palettes, font scales, spacing scales)
- Canvas locks like `body { width: 1920px; height: 1080px; }`
- Page chrome that is identical on every page, such as `.page-header` / `.page-footer`

**Do not** put page-specific layout classes here—that degrades back to the global namespace pollution of the single-file architecture.

---

## Path B (Small Decks): Single File + `deck_stage.js`

Applicable to decks with ≤ 10 pages, requiring cross-page state sharing (for example, a React tweaks panel that controls all pages), or pitch deck demos that demand extreme compactness.

### Basic Usage

1. Read the contents from `assets/deck_stage.js` and embed it in the HTML `<script>` (or `<script src="deck_stage.js">`)
2. Wrap slides inside `<deck-stage>` inside the body
3. 🛑 **The script tag must be placed after `</deck-stage>`** (see hard constraints below)

```html
<body>

  <deck-stage>
    <section>
      <h1>Slide 1</h1>
    </section>
    <section>
      <h1>Slide 2</h1>
    </section>
  </deck-stage>

  <!-- ✅ Correct: script is placed after deck-stage -->
  <script src="deck_stage.js"></script>

</body>
```

### 🛑 Script Position Hard Constraint (Real-world pitfall on 2026-04-20)

**Do not put `<script src="deck_stage.js">` in `<head>`.** Even if it defines `customElements` in `<head>`, the parser triggers `connectedCallback` the moment it encounters the `<deck-stage>` start tag—at which point the child `<section>` elements have not yet been parsed. Thus, `_collectSlides()` gets an empty array, the counter shows `1 / 0`, and all pages render overlapping.

**Three compliant writing styles** (choose any one):

```html
<!-- ✅ Most recommended: script placed after </deck-stage> -->
</deck-stage>
<script src="deck_stage.js"></script>

<!-- ✅ Also acceptable: script in head but with defer -->
<head><script src="deck_stage.js" defer></script></head>

<!-- ✅ Also acceptable: module scripts defer by default -->
<head><script src="deck_stage.js" type="module"></script></head>
```

`deck_stage.js` itself has built-in `DOMContentLoaded` deferral defense, so placing the script in head won't completely break it—but using `defer` or placing it at the bottom of the body remains a cleaner practice to avoid depending on fallback defenses.

### ⚠️ CSS Pitfalls in Single-File Architecture (Must Read)

The most common trap in single-file architecture—**having the `display` property hijacked by single-page styles**.

Common bad practice 1 (writing display: flex directly on the section):

```css
/* ❌ External CSS specificity 2, overriding shadow DOM's ::slotted(section){display:none} (which is also 2) */
deck-stage > section {
  display: flex;            /* All pages will render overlapping! */
  flex-direction: column;
  padding: 80px;
  ...
}
```

Common bad practice 2 (section has a higher specificity class):

```css
.emotion-slide { display: grid; }   /* Specificity: 10, even worse */
```

Both styles cause **all slides to render overlapping**—the counter might show `1 / 10` pretending everything is normal, but visually page 1 will cover page 2, which covers page 3, etc.

### ✅ Starter CSS (Copy directly to avoid pitfalls)

**The section itself** only manages visibility ("visible/invisible"); **write layout rules (flex/grid, etc.) on `.active`**:

```css
/* Define only non-display general styles on the section */
deck-stage > section {
  background: var(--paper);
  padding: 80px 120px;
  overflow: hidden;
  position: relative;
  /* ⚠️ Do not write display here! */
}

/* Lock "hidden if not active" — double protection with specificity + weight */
deck-stage > section:not(.active) {
  display: none !important;
}

/* Write needed display + layout on active page only */
deck-stage > section.active {
  display: flex;
  flex-direction: column;
  justify-content: center;
}

/* Print mode: all pages must display, overriding :not(.active) */
@media print {
  deck-stage > section { display: flex !important; }
  deck-stage > section:not(.active) { display: flex !important; }
}
```

Alternative: **Write single-page flex/grid layouts on an inner wrapper `<div>`**, leaving the section itself strictly as a `display: block/none` toggle. This is the cleanest approach:

```html
<deck-stage>
  <section>
    <div class="slide-content flex-layout">...</div>
  </section>
</deck-stage>
```

### Custom Dimensions

```html
<deck-stage width="1080" height="1920">
  <!-- 9:16 portrait layout -->
</deck-stage>
```

---

## Slide Labels

Both `deck_stage` and `deck_index` assign labels to each page (shown in the counter). Give them **more meaningful** labels:

**Multiple Files**: Write `{ file, label: "04 Problem Statement" }` in `MANIFEST`.
**Single File**: Add `<section data-screen-label="04 Problem Statement">` to the section.

**Crucial: Slide indexing starts at 1, not 0**.

When a user says "slide 5", they mean the 5th slide, never array index `[4]`. Humans do not speak in 0-indexed terms.

---

## Speaker Notes

**Do not add by default**, only when explicitly requested by the user.

Adding speaker notes allows you to reduce text on slides to a minimum and focus on impactful visuals—notes carry the full script.

### Format

**Multiple Files**: Write in the `<head>` of `index.html`:

```html
<script type="application/json" id="speaker-notes">
[
  "Script for page 1...",
  "Script for page 2...",
  "..."
]
</script>
```

**Single File**: Same location.

### Key Points for Writing Notes

- **Complete**: Not an outline, but the actual words to be spoken.
- **Conversational**: Speak naturally, not in written/formal prose.
- **Correspondence**: The N-th array element maps to the N-th slide.
- **Length**: 200-400 words is ideal.
- **Emotional arc**: Mark emphasis, pauses, and key takeaways.

---

## Slide Design Patterns

### 1. Establish a System (Required)

After exploring the design context, **verbally communicate the system you plan to use first**:

```markdown
Deck System:
- Background: Max 2 colors (90% white + 10% dark section dividers)
- Typography: Instrument Serif for display headings, Geist Sans for body
- Rhythm: Full-bleed color + white text for section dividers, white background for standard slides
- Imagery: Full-bleed photos for hero slides, charts for data slides

I will proceed with this system. Let me know if you have any feedback.
```

Wait for user confirmation before proceeding.

### 2. Common Slide Layouts

- **Title slide**: Flat background color + giant title + subtitle + author/date
- **Section divider**: Colored background + chapter number + chapter title
- **Content slide**: White background + title + 1-3 bullet points
- **Data slide**: Title + large chart/numbers + brief description
- **Image slide**: Full-bleed photo + small caption at the bottom
- **Quote slide**: High whitespace + giant quote + attribution
- **Two-column**: Left/right comparison (vs / before-after / problem-solution)

Use a maximum of 4-5 layouts in a single deck.

### 3. Scale (Emphasized Again)

- Body text: min **24px**, ideally 28-36px
- Headings: **60-120px**
- Hero text: **180-240px**
- Slides are viewed from 10 meters away; keep text large.

### 4. Visual Rhythm

Decks require **intentional variety**:

- Color rhythm: Mostly white background + occasional colored section dividers + occasional dark segments
- Density rhythm: A few text-heavy slides + a few image-heavy slides + a few high-whitespace quote slides
- Font size rhythm: Normal headings + occasional giant hero text

**Avoid having every slide look the same**—that is a PPT template, not design.

### 5. Spacing and Breathing Room (Must-read for data-dense pages)

**The easiest pitfall for beginners**: Stuffing every piece of available information onto a single page.

Information density is not equal to effective communication. academic/presentation decks require restraint:

- List/Matrix pages: Do not draw N elements at the same size. Use **primary-secondary hierarchy**—enlarge the 5 elements you want to talk about today to serve as centerpieces, while shrinking the remaining 16 to serve as background hints.
- Large number pages: Numbers are the visual centerpiece. Limit surrounding captions to 3 lines max to avoid jumping eye movements.
- Quote pages: Keep whitespace between the quote and the attribution; do not crowd them together.

Self-assess with "is data the centerpiece?" and "is text crowded?". Adjust whitespace until it makes you feel slightly anxious.

---

## Printing to PDF

**Multiple Files**: `deck_index.html` has handled the `beforeprint` event to output PDF page by page.

**Single File**: `deck_stage.js` handles it similarly.

Print styles are pre-configured; no additional `@media print` CSS is required.

---

## Exporting to PPTX / PDF (Self-Service Scripts)

HTML remains the first-class citizen. However, users often require PPTX/PDF deliverables. Two universal scripts are provided under `scripts/`, which **can be used with any multiple-file deck**:

### `export_deck_pdf.mjs` — Export Vector PDF (Multiple-File Architecture)

```bash
node scripts/export_deck_pdf.mjs --slides <slides-dir> --out deck.pdf
```

**Features**:
- Text **remains vector** (copyable, searchable)
- 100% visual fidelity (printed after rendering in Playwright's headless Chromium)
- **Requires zero changes to the HTML**
- Run `page.pdf()` on each individual slide, then merge them using `pdf-lib`

**Dependencies**: `npm install playwright pdf-lib`

**Limitations**: Text in the PDF cannot be edited directly—make edits in the source HTML instead.

### `export_deck_stage_pdf.mjs` — Specific to Single-File deck-stage Architecture ⚠️

**When to use**: The deck is a single HTML file + `<deck-stage>` web component wrapping N `<section>` tags (Path B architecture). The `export_deck_pdf.mjs` script's approach of "one `page.pdf()` per HTML" will not work here. Use this dedicated script instead.

```bash
node scripts/export_deck_stage_pdf.mjs --html deck.html --out deck.pdf
```

**Why export_deck_pdf.mjs cannot be reused** (Real-world pitfall on 2026-04-20):

1. **Shadow DOM overrides `!important`**: The shadow CSS of deck-stage contains `::slotted(section) { display: none }` (only the active one is `display: block`). Even writing `@media print { deck-stage > section { display: block !important } }` in the light DOM cannot override it—Chromium ultimately renders only the active slide when triggering print media, resulting in a **1-page PDF** (repeating the current active slide).

2. **Looping goto per page still outputs only 1 page**: The intuitive workaround "navigate to each `#slide-N` and run `page.pdf({pageRanges:'1'})`" also fails—because the print CSS has `deck-stage > section { display: block }` overridden outside the shadow DOM, rendering the first section of the list every time instead of the navigated page. This results in 17 cover pages for 17 iterations.

3. **Absolute children spill into the next page**: Even if all sections are rendered, if a section is `position: static`, its absolutely positioned `cover-footer`/`slide-footer` will align relative to the initial containing block. When the section is forced to 1080px high during printing, absolute footers may be pushed to the next page (resulting in a PDF with more pages than sections, where the extra pages contain only orphan footers).

**Fix Strategy** (implemented in the script):

```js
// After opening the HTML, use page.evaluate to extract the sections out of the deck-stage slot,
// append them directly to a standard div under body, and inline styles to ensure position:relative + fixed size.
await page.evaluate(() => {
  const stage = document.querySelector('deck-stage');
  const sections = Array.from(stage.querySelectorAll(':scope > section'));
  document.head.appendChild(Object.assign(document.createElement('style'), {
    textContent: `
      @page { size: 1920px 1080px; margin: 0; }
      html, body { margin: 0 !important; padding: 0 !important; }
      deck-stage { display: none !important; }
    `,
  }));
  const container = document.createElement('div');
  sections.forEach(s => {
    s.style.cssText = 'width:1920px!important;height:1080px!important;display:block!important;position:relative!important;overflow:hidden!important;page-break-after:always!important;break-after:page!important;background:#F7F4EF;margin:0!important;padding:0!important;';
    container.appendChild(s);
  });
  // Disable page break on the last page to prevent trailing blank pages
  sections[sections.length - 1].style.pageBreakAfter = 'auto';
  sections[sections.length - 1].style.breakAfter = 'auto';
  document.body.appendChild(container);
});

await page.pdf({ width: '1920px', height: '1080px', printBackground: true, preferCSSPageSize: true });
```

**Why this works**:
- Pulling the sections from the shadow DOM slot into a standard div in the light DOM completely bypasses the `::slotted(section) { display: none }` rule.
- Inline `position: relative` ensures absolutely positioned child elements align relative to the section and do not overflow.
- `page-break-after: always` forces the browser to print each section as a separate page.
- Disabling breaks on the `:last-child` prevents trailing blank pages.

**Note when verifying with `mdls -name kMDItemNumberOfPages`**: macOS Spotlight metadata is cached. Run `mdimport file.pdf` after rewriting the PDF to force refresh, otherwise it shows the stale page count. Use `pdfinfo` or count files via `pdftoppm` for accuracy.

---

### `export_deck_pptx.mjs` — Export Editable PPTX

```bash
# Text box remains natively editable (fonts will fallback to system fonts)
node scripts/export_deck_pptx.mjs --slides <dir> --out deck.pptx
```

How it works: `html2pptx` reads computedStyle element-by-element and translates the DOM into PowerPoint objects (text frame / shape / picture). Text is transformed into editable text frames.

**Hard Constraints** (HTML must satisfy these, otherwise the page will be skipped; see details in `references/editable-pptx.md`):
- All text must reside inside `<p>`/`<h1>`-`<h6>`/`<ul>`/`<ol>` tags (bare text inside divs is prohibited).
- The `<p>`/`<h*>` tags themselves cannot have backgrounds, borders, or shadows (place them on the outer div instead).
- Do not use `::before`/`::after` to insert decorative text (pseudo-elements cannot be extracted).
- Inline elements (span/em/strong) must not have margins.
- No CSS gradients (cannot be rendered).
- Do not use `background-image` on divs (use `<img>` instead).

The script includes an **automatic preprocessor** to wrap bare text in leaf divs into `<p>` tags while preserving classes. This resolves the most common violation (bare text). However, other violations (borders on paragraphs, margins on spans, etc.) must be corrected at the source HTML level.

**Font Fallback Caveats**:
- Playwright uses web fonts to measure text-box dimensions; PowerPoint/Keynote uses local system fonts to render them.
- Discrepancies between the two can cause **overflows or misalignments**—visually inspect each page.
- Make sure target machines have the fonts used in the HTML installed, or fall back to `system-ui`.

**Do not use this path for visually critical scenarios** → Export to PDF using `export_deck_pdf.mjs` instead. PDFs offer 100% visual fidelity, vectors, cross-platform support, and searchable text—serving as the ideal destination for visual-first decks rather than an "uneditable compromise."

### Make HTML Export-Friendly From the Beginning

For decks with the most stable performance: **Write HTML following the 4 hard constraints for editability from the beginning.** This allows `export_deck_pptx.mjs` to pass all checks. The extra effort is minimal:

```html
<!-- ❌ Bad -->
<div class="title">Key Findings</div>

<!-- ✅ Good (wrapped in p, class inherited) -->
<p class="title">Key Findings</p>

<!-- ❌ Bad (border on p) -->
<p class="stat" style="border-left: 3px solid red;">41%</p>

<!-- ✅ Good (border on outer div) -->
<div class="stat-wrap" style="border-left: 3px solid red;">
  <p class="stat">41%</p>
</div>
```

### When to Choose Which

| Scenario | Recommendation |
|------|------|
| Sharing with host/archiving | **PDF** (Universal, high-fidelity, searchable text) |
| Sending to collaborators for text edits | **PPTX editable** (Accept font fallback) |
| On-site presentations, no content edits | **PDF** (Vector fidelity, cross-platform) |
| HTML is the primary medium | Play in browser directly; exports are just backups |

## Deep Path for Exporting to Editable PPTX (Long-term projects only)

If your deck will be maintained long-term, modified repeatedly, and developed by a team—we suggest **writing HTML following the html2pptx constraints from the beginning**, allowing `export_deck_pptx.mjs` to pass all checks. See details in `references/editable-pptx.md` (4 hard constraints + HTML template + common errors lookup + fallback workflow for existing visual designs).

---

## FAQ

**Multiple Files: Pages in iframe do not open / blank screen**
→ Check if the `file` path in `MANIFEST` is correct relative to `index.html`. Open the browser DevTools and check if the iframe src is directly accessible.

**Multiple Files: Page style conflicts with other pages**
→ Impossible (due to iframe isolation). If you notice a conflict, it is likely cached—force refresh with Cmd+Shift+R.

**Single File: Multiple slides rendering overlapping**
→ CSS specificity issue. Refer to the section "CSS Pitfalls in Single-File Architecture" above.

**Single File: Scaling looks incorrect**
→ Check if all slides are directly nested under `<deck-stage>` as `<section>` elements. Do not wrap them with `<div>`.

**Single File: Jumping to a specific slide**
→ Add a hash to the URL: `index.html#slide-5` to jump to page 5.

**Applicable to both architectures: Text positioning is inconsistent across different screens**
→ Use fixed dimensions (1920×1080) and `px` units. Do not use `vw`/`vh` or `%`. Let scaling be handled uniformly.

---

## Verification Checklist (Must pass after completing a deck)

1. [ ] Open `index.html` (or the main HTML) directly in the browser. Verify that there are no broken images and that fonts have loaded.
2. [ ] Navigate through each page using the → key. Verify there are no blank pages or layout misalignments.
3. [ ] Press the P key for print preview. Check that each page is exactly one A4 (or 1920×1080) page and is not cropped.
4. [ ] Randomly select 3 pages and force refresh them (Cmd+Shift+R). Check that localStorage memory works correctly.
5. [ ] Batch capture screenshots with Playwright (single-page architecture: traverse `slides/*.html`; single-file architecture: switch using goTo), and inspect them manually.
6. [ ] Search for remaining `TODO` / `placeholder` text, and verify they have been cleaned up.
