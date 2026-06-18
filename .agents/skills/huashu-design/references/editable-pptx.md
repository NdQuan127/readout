# Editable PPTX Export: HTML Hard Constraints + Dimension Decisions + Common Errors

This document describes the path for **translating HTML element-by-element into real, editable PowerPoint text boxes using `scripts/html2pptx.js` + `pptxgenjs`**, which is also the only path supported by `export_deck_pptx.mjs`.

> **Core Prerequisite**: To take this path, the HTML must be written according to the 4 constraints below right from the very first line. **Do not write it first and try to convert it later**—belated remediation will trigger 2-3 hours of rework (empirically proven during the 2026-04-20 Option Private Board Project).
>
> For scenarios where visual freedom is a priority (animations / web components / CSS gradients / complex SVGs), please use the PDF path instead (`export_deck_pdf.mjs` / `export_deck_stage_pdf.mjs`). **Do not** expect a PPTX export to achieve both visual fidelity and editability—this is a physical constraint of the PPTX file format itself (see "Why the 4 Constraints Are Not Bugs But Physical Constraints" at the end of this document).

---

## Canvas Size: Use 960×540pt (LAYOUT_WIDE)

PPTX units are **inches** (physical dimensions), not px. Decision Principle: The computedStyle dimensions of the body must **match the inch dimensions of the presentation layout** (within ±0.1", enforced by `validateDimensions` in `html2pptx.js`).

### Comparison of 3 Candidate Sizes

| HTML body | Physical Size | Corresponding PPT Layout | When to Choose |
|---|---|---|---|
| **`960pt × 540pt`** | **13.333″ × 7.5″** | **pptxgenjs `LAYOUT_WIDE`** | ✅ **Recommended by default** (Standard for modern PowerPoint 16:9) |
| `720pt × 405pt` | 10″ × 5.625″ | Custom | Only when the user specifies an "old version PowerPoint Widescreen" template |
| `1920px × 1080px` | 20″ × 11.25″ | Custom | ❌ Non-standard size; fonts appear abnormally small when projected |

**Do not think of HTML dimensions as resolution.** PPTX is a vector document; the body dimensions determine the **physical size**, not the clarity. An oversized body (20″ × 11.25″) will not make text sharper—it only makes the font size in pt smaller relative to the canvas, making it look worse when projected or printed.

### Choose One of Three body Declarations (Equivalent)

```css
body { width: 960pt;  height: 540pt; }    /* Cleanest, recommended */
body { width: 1280px; height: 720px; }    /* Equivalent, px habits */
body { width: 13.333in; height: 7.5in; }  /* Equivalent, inch intuition */
```

Companion pptxgenjs code:

```js
const pptx = new pptxgen();
pptx.layout = 'LAYOUT_WIDE';  // 13.333 × 7.5 inches, no custom layout required
```

---

## 4 Hard Constraints (Violation Will Directly Throw an Error)

`html2pptx.js` translates the HTML DOM element-by-element into PowerPoint objects. The format constraints of PowerPoint project onto HTML as the following 4 rules.

### Rule 1: Text cannot be written directly inside a DIV — it must be wrapped in `<p>` or `<h1>`-`<h6>`

```html
<!-- ❌ Incorrect: Text placed directly inside a div -->
<div class="title">Q3 revenue increased by 23%</div>

<!-- ✅ Correct: Text wrapped in <p> or <h1>-<h6> -->
<div class="title"><h1>Q3 revenue increased by 23%</h1></div>
<div class="body"><p>New users are the primary growth driver</p></div>
```

**Why**: PowerPoint text must exist inside a text frame, and a text frame maps to block/paragraph-level elements (p/h*/li) in HTML. A bare `<div>` has no corresponding text container in PPTX.

**You also cannot use `<span>` to carry the primary text**—span is an inline element and cannot be independently aligned into a text box. Spans can only be **nested inside p/h\*** elements to apply local styling (bold, color changes).

### Rule 2: CSS Gradients are not supported — only solid colors can be used

```css
/* ❌ Incorrect */
background: linear-gradient(to right, #FF6B6B, #4ECDC4);

/* ✅ Correct: Solid color */
background: #FF6B6B;

/* ✅ If multi-color stripes are required, use flex child elements each with solid colors */
.stripe-bar { display: flex; }
.stripe-bar div { flex: 1; }
.red   { background: #FF6B6B; }
.teal  { background: #4ECDC4; }
```

**Why**: PowerPoint's shape fill only supports solid/gradient-fill, but pptxgenjs's `fill: { color: ... }` only maps to solid. Using PowerPoint's native gradients would require a different structure, which is not currently supported by the toolchain.

### Rule 3: Background, border, and shadow can only be applied to DIVs, not to text tags

```html
<!-- ❌ Incorrect: <p> has background color -->
<p style="background: #FFD700; border-radius: 4px;">Key Content</p>

<!-- ✅ Correct: The outer div carries the background/border, while <p> handles only the text -->
<div style="background: #FFD700; border-radius: 4px; padding: 8pt 12pt;">
  <p>Key Content</p>
</div>
```

**Why**: In PowerPoint, a shape (box/rounded rectangle) and a text frame are two separate objects. HTML's `<p>` is only translated into a text frame. Background, border, and shadow belong to shapes—so they must be defined on the **div wrapping the text**.

### Rule 4: DIV cannot use `background-image` — use the `<img>` tag instead

```html
<!-- ❌ Incorrect -->
<div style="background-image: url('chart.png')"></div>

<!-- ✅ Correct -->
<img src="chart.png" style="position: absolute; left: 50%; top: 20%; width: 300pt; height: 200pt;" />
```

**Why**: `html2pptx.js` only extracts image paths from `<img>` elements and does not parse CSS `background-image` URLs.

---

## Merging Text Boxes (`data-pptx-merge`)

**Default Behavior**: Every `<p>`/`<h1>`-`<h6>` in HTML becomes an **independent text box** in PPTX. If a card has 3 `<p>` elements → PowerPoint will stack 3 separate text boxes. During editing, you cannot press Enter to add paragraphs seamlessly; you must change font sizes and alignments one by one.

**Solution**: Add `data-pptx-merge="true"` to the outer div. All `<p>/<h*>` elements inside the container will be merged into **a single editable text box**, separated by paragraph breaks. In PowerPoint, this allows continuous paragraph editing.

```html
<!-- ✅ Merged approach: All 4 paragraphs are merged into one text box -->
<div class="card" data-pptx-merge="true"
     style="position: absolute; top: 60pt; left: 60pt; width: 420pt;
            background: #1A4A8A; border-radius: 8pt; padding: 20pt 24pt;">
  <h2 style="font-size: 24pt; color: #FFFFFF;">Title</h2>
  <p  style="font-size: 14pt; color: #DDEEFF;">First paragraph of body text.</p>
  <p  style="font-size: 14pt; color: #FFD166;">Second paragraph: Color changed for emphasis.</p>
  <p  style="font-size: 14pt; color: #DDEEFF;">Third paragraph: Continuing in the same text box.</p>
</div>
```

**Preserved Styles** (written as run options per-paragraph): `font-size`, `color`, `font-family`, `font-weight` (bold), `font-style` (italic), `text-decoration: underline`, and inline styles for `<b>/<i>/<u>/<strong>/<em>/<span>`.

**Inherited from the First Paragraph & Unified Across the Entire Box**: `text-align`, `line-height`. Since alignment and line spacing in PowerPoint are at the paragraph/textbox level, a single text box can only have one alignment. If paragraph alignments differ, do not use merge; keep them independent.

**The Container's Own `background`/`border`/`box-shadow`/`border-radius`** are rendered as shapes as usual, behaving exactly like ordinary divs. This means the blue card background and text still exist in two layers ("shape + text frame"), but the text layer collapses from 3–4 text boxes into just 1.

**Limitations**:
- Nested `data-pptx-merge` is not allowed (will throw an error).
- The container cannot use `background-image` (same as Hard Constraint Rule 4).
- Do not place child divs with `background` or `border` inside the container—they will still be rendered as independent shapes, but the text inside them will have been merged elsewhere, which may cause visual misalignments.

**When to Use**: Scenarios where the content will be edited repeatedly inside PowerPoint. For one-off archival exports, you do not need to add this attribute, as the visual output remains identical.

---

## Path A HTML Template Skeleton

Each slide is in a separate HTML file, with isolated styling scopes (avoiding CSS pollution found in single-file decks).

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    width: 960pt; height: 540pt;           /* ⚠️ Matches LAYOUT_WIDE */
    font-family: system-ui, -apple-system, "PingFang SC", sans-serif;
    background: #FEFEF9;                    /* Solid color, no gradient */
    overflow: hidden;
  }
  /* DIV handles layout/background/borders */
  .card {
    position: absolute;
    background: #1A4A8A;                    /* Background applied on the DIV */
    border-radius: 4pt;
    padding: 12pt 16pt;
  }
  /* Text tags handle only font styling, no backgrounds/borders */
  .card h2 { font-size: 24pt; color: #FFFFFF; font-weight: 700; }
  .card p  { font-size: 14pt; color: rgba(255,255,255,0.85); }
</style>
</head>
<body>

  <!-- Title Area: Outer div handles positioning, inner elements handle text -->
  <div style="position: absolute; top: 40pt; left: 60pt; right: 60pt;">
    <h1 style="font-size: 36pt; color: #1A1A1A; font-weight: 700;">Use assertive sentences for titles, not just theme words</h1>
    <p style="font-size: 16pt; color: #555555; margin-top: 10pt;">Subtitle providing supplementary details</p>
  </div>

  <!-- Content Card: div handles background, h2/p handle text -->
  <div class="card" style="top: 130pt; left: 60pt; width: 240pt; height: 160pt;">
    <h2>Key Point One</h2>
    <p>Brief explanation text</p>
  </div>

  <!-- List: Use ul/li, do not write bullet points manually -->
  <div style="position: absolute; top: 320pt; left: 60pt; width: 540pt;">
    <ul style="font-size: 16pt; color: #1A1A1A; padding-left: 24pt; list-style: disc;">
      <li>First key point</li>
      <li>Second key point</li>
      <li>Third key point</li>
    </ul>
  </div>

  <!-- Illustration: Use <img> tag, do not use background-image -->
  <img src="illustration.png" style="position: absolute; right: 60pt; top: 110pt; width: 320pt; height: 240pt;" />

</body>
</html>
```

---

## Common Errors Reference

| Error Message | Reason | Resolution |
|---------|------|---------|
| `DIV element contains unwrapped text "XXX"` | Bare text inside a div | Wrap the text inside `<p>` or `<h1>`-`<h6>` |
| `CSS gradients are not supported` | Used linear/radial-gradient | Change to a solid color, or split into sections using flex child elements |
| `Text element <p> has background` | Background color applied directly on the `<p>` tag | Wrap it with a `<div>` to hold the background, keeping only text styles on the `<p>` |
| `Background images on DIV elements are not supported` | Used background-image on a div | Replace with an `<img>` tag |
| `HTML content overflows body by Xpt vertically` | Content exceeds 540pt height | Reduce content size, decrease font size, or truncate with `overflow: hidden` |
| `HTML dimensions don't match presentation layout` | Body size does not match presentation layout | Use `960pt × 540pt` for the body alongside `LAYOUT_WIDE`; or use defineLayout for custom sizing |
| `Text box "XXX" ends too close to bottom edge` | Large-font `<p>` sits too close to the body's bottom edge (< 0.5 inches) | Move it upward to leave sufficient bottom padding; the bottom of a slide is often obscured when projected anyway |

---

## Basic Workflow (3 Steps to Output PPTX)

### Step 1: Write Individual HTML Pages Adhering to Constraints

```
MyDeck/
├── slides/
│   ├── 01-cover.html    # Each file is a complete 960×540pt HTML file
│   ├── 02-agenda.html
│   └── ...
└── illustration/        # Images referenced by all <img> tags
    ├── chart1.png
    └── ...
```

### Step 2: Write build.js to Call `html2pptx.js`

```js
const pptxgen = require('pptxgenjs');
const html2pptx = require('../scripts/html2pptx.js');  // The script for this skill

(async () => {
  const pres = new pptxgen();
  pres.layout = 'LAYOUT_WIDE';  // 13.333 × 7.5 inches, matching HTML's 960×540pt

  const slides = ['01-cover.html', '02-agenda.html', '03-content.html'];
  for (const file of slides) {
    await html2pptx(`./slides/${file}`, pres);
  }

  await pres.writeFile({ fileName: 'deck.pptx' });
})();
```

### Step 3: Open and Verify

- Open the exported PPTX in PowerPoint/Keynote.
- Double-click any text; it should be directly editable (if it's a flattened image, it means Rule 1 was violated).
- Verify overflow: Everything should fit within the body boundaries on each slide without being clipped.

---

## This Path vs. Other Options (When to Choose What)

| Requirement | What to Choose |
|------|------|
| Colleagues need to edit the text in the PPTX / Sending to non-technical users for further editing | **This path** (editable, requires writing HTML from scratch under the 4 constraints) |
| For presentation use / archiving only, no further edits needed | `export_deck_pdf.mjs` (multi-file) or `export_deck_stage_pdf.mjs` (single-file deck-stage), outputting vector PDF |
| Visual freedom is priority (animations, web components, CSS gradients, complex SVGs), non-editable is acceptable | **PDF** (same as above)—PDF offers fidelity and cross-platform consistency, making it far better than a "flattened image PPTX" |

**Never run html2pptx directly on HTML that was written with absolute visual freedom**—empirically, the pass rate for visually-driven HTML is < 30%, and retrofitting the remaining page structure is slower than rewriting it. Such cases should output to PDF, rather than being forced into PPTX.

---

## Fallback: Existing Visual Draft but the User Insists on an Editable PPTX

Occasionally, you will encounter this scenario: You or the user have already written a visually-driven HTML file (using gradients, web components, complex SVGs, etc.). While outputting to PDF would be ideal, the user explicitly states: "No, it must be an editable PPTX."

**Do not run `html2pptx` blindly and expect it to pass**—the pass rate for visually-driven HTML is <30%; the other 70% will fail or distort. The correct fallback workflow is:

### Step 1: Inform the User of the Limitations (Transparent Communication)

Explain three things clearly to the user in a short message:

> "Your current HTML uses [specifically list: gradients / web components / complex SVGs / ...], which will fail when directly converted into an editable PPTX. I have two options:
> - A. **Output to PDF** (Recommended)—100% visual fidelity is preserved; the recipient can view and print it, but cannot edit the text.
> - B. **Rewrite as an Editable HTML using the visual draft as a guide** (retains color/layout/copy design choices, but reorganizes the HTML structure under the 4 hard constraints, **sacrificing** visual features like gradients, web components, and complex SVGs) → then export to an editable PPTX.
>
> Which one would you prefer?"

Do not treat Option B lightly—clearly state **what will be lost**. Let the user make the trade-off.

### Step 2: If the User Chooses Option B: The AI Proactively Rewrites the HTML

The doctrine here is: **The user provides design intent, and you are responsible for translating it into a compliant implementation.** Do not expect the user to learn the 4 hard constraints and rewrite the code themselves.

Principles to follow when rewriting:
- **Preserve**: Color systems (primary/secondary/neutral), typographic hierarchy (headings/subheadings/body text/annotations), core copy, layout framework (header-body-footer / split columns / grid layout), and page pacing.
- **Degrade**: CSS gradients → solid colors or flex-segmented sections, web components → paragraph-level HTML, complex SVGs → simplified `<img>` tags or solid geometric shapes, shadows → remove or reduce to extremely light styles, and custom fonts → fall back to system fonts.
- **Rewrite**: Bare text → wrapped in `<p>`/`<h*>`, `background-image` → `<img>` tags, and backgrounds/borders on `<p>` elements → moved to outer `<div>` containers.

### Step 3: Produce a Comparison Checklist (Transparent Delivery)

Once the rewrite is finished, provide a before/after comparison to show the user which visual details have been simplified:

```
Original Design → Editable Edition Adjustment
- Purple gradient in heading area → Primary color #5B3DE8 solid background
- Data card shadows → Removed (replaced with 2pt border for separation)
- Complex SVG line chart → Simplified to <img> PNG (generated from HTML screenshot)
- Hero section web component animation → Static first frame (web components cannot be translated)
```

### Step 4: Export & Dual-Format Delivery

- Editable HTML → Run `scripts/export_deck_pptx.mjs` to output the editable PPTX.
- **It is recommended to also preserve** the original visual draft → Run `scripts/export_deck_pdf.mjs` to output a high-fidelity PDF.
- Deliver both formats to the user: The high-fidelity PDF + the editable PPTX, each serving its purpose.

### When to Refuse Option B Directly

In some scenarios, the rewriting cost is too high, and you should advise the user against an editable PPTX:
- The core value of the HTML lies in its animation or interactivity (rewriting leaves only a static first frame, losing 50%+ of the information).
- Number of pages > 30, meaning rewriting would take over 2 hours.
- The visual design relies heavily on precise SVG paths or custom CSS filters (rewriting would look nothing like the original draft).

In these cases, tell the user: "The cost of rewriting this deck is too high, so I recommend outputting a PDF instead of a PPTX. If the recipient absolutely must have a PPTX file, they will need to accept a significantly simplified visual design—would you like to switch to a PDF?"

---

## Why the 4 Constraints Are Not Bugs But Physical Constraints

These 4 rules do not stem from laziness on the part of the `html2pptx.js` author—they are the result of **PowerPoint's file format (OOXML) constraints** projected onto HTML:

- In PPTX, text must reside in a text frame (`<a:txBody>`), which corresponds to block/paragraph-level HTML elements.
- PowerPoint shapes and text frames are two separate objects; you cannot draw a background and write text within the same PPTX element.
- PowerPoint shape fills have limited gradient support (only certain preset gradients; arbitrary CSS gradient angles are not supported).
- A PowerPoint picture object must reference an actual image file, not a CSS property.

Once you understand this, **do not expect the tools to get smarter**—the HTML syntax must adapt to the PPTX format, not the other way around.
