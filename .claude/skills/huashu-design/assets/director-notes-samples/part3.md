- SFX: paper rustle (when tagline enters, -22dB)

**[CHROME]**

- A (top-left capability counter): ON, displays `CAPABILITY · 01`, first dot is solid
- B (version chip): ON, showing continuously
- C (timeline ticker): OFF (will enter in SHOT 05)
- D (watermark): ON, always ON
- E (paper texture): ON

**[ANTI-SLOP]**

- ✅ The 6 cards are not emojis or icons, but **mini demos with internal content**—each one is readable
- ✅ The flight trajectory is parabolic (feeling of gravity), not a straight line (computerized feel)
- ✅ When converging, it is "absorption" (scaling down and positioning moving inward simultaneously), not "overlaying"
- ✅ No glow or particle effects are given to the md characters (no need to explain "md is absorbing", the audience can understand it on their own)
- ✅ pause-and-look signature: When pausing to look at any card in mid-flight, you can read "this is a PDF / this is a DOCX"—this is the detail achieved at 120%
- ✅ The tagline uses "→" instead of "to" or "至" (to), which is markdown's own character

**[WHY]**

This is the opening shot of ACT II. If the audience doesn't realize "Oh, md is the source" after watching this 3.5 seconds, the subsequent shots will be in vain.

There are 3 micro-narrative beats in the 3.5 seconds:
1. The hero yields (md moves up) — implying "I make way for my products"
2. 6 products appear — revealing "what I can consume/integrate"
3. All return to md — "but in the end, they are all md"

The next shot enters the forward flow of md → html—the audience has already accepted "md is the source", and is now ready to see "how md transforms".

---

## SHOT 05 · "FIRST FLOWER · HTML" (md → html)

**[TIMECODE]** 08.50 — 11.50s (3.0s) `|` **FUNCTION** CAPABILITY 02. First forward export. Establishes the ScenePipeline pattern (used across the next 5 shots).

**[VISUAL]**

08.50s: The hero `md.` slides from the top-center position to the left side of the screen (x=480, y=540), size remains at 220px.

At the same time, a destination card appears on the right side of the screen (x=1400, y=540): simulating a "Tufte CSS-style essay html".

Destination card design (**real readable content, not bar lines**):

```
┌─────────────────────────────────┐
│                                  │
│  On Markdown                     │  ← Newsreader 600, 32px, Ink
│  AN ESSAY · 2026                 │  ← Mono 11px, 0.18em, Smoke
│  ▬▬▬                             │  ← Terracotta rule 60×3px
│                                  │
│  md is the source of truth.      │  ← Newsreader 400, 18px, line-height 1.7
│  Anything else is product.       │
│  We write once. Publish six      │
│  ways. The river forks; the      │
│  spring stays the same.          │
│                                  │
│  ─ huashu, 2026.05.11            │  ← italic 14px, Smoke
│                                  │
│  article.html · TUFTE THEME      │  ← Mono 10px, 0.18em, Smoke (bottom)
└─────────────────────────────────┘
   Width 480px × Height 560px
   White background + Mica border + 24° corner fold
```

The md characters and the destination card are connected by a thin terracotta line that starts from the dot in "md.", grows 380px to the right, and the arrow head reaches the left boundary of the card. A label "md → html" (JetBrains Mono 14px Terracotta, letter-spacing 0.14em) is displayed 30px above the line.

At 09.80s: Chrome C (timeline ticker) enters for the first time, fixed at y=1000.

**[TYPE]**

- See embedded visual description
- label "md → html" font size 14px, Mono Bold, Terracotta, letter-spacing 0.14em
- destination card top chapter title is Newsreader 600, 32px, Ink
- destination card bottom stamp mono 10px Smoke 0.18em

**[ANIM]**

- 08.50-08.80s · hero md slides from center-top to left-mid (300ms expoOut)
- 08.80-09.10s · arrow line grows to the right from the md.dot starting point (300ms expoOut, 0 → 380px)
- 09.10s · arrow head emerges (200ms overshoot)
- 09.20-09.40s · label "md → html" enters (fade-in + 8px y slide-down, 300ms expoOut)
- 09.40-10.10s · destination card enters as a whole (700ms expoOut, scale 0.85 → 1 + opacity 0 → 1)
- 10.10-10.80s · destination card internal staggered entry: title (400ms delay 0) → subtitle metadata (delay 200ms) → terracotta rule (delay 400ms) → 6 lines of body text (each delay 60ms cascade) → signature (delay 1000ms) → bottom mono (delay 1100ms)
- 10.80-11.50s · hold + micro-breathing (overall scale 1 → 1.005 → 1, 600ms ease-in-out infinite, but this shot only plays half a cycle)

**[AUDIO]**

- BGM: cello drone L3 enters at 09.00s (-30dB → -24dB)
- SFX: chime: capability 02 at 09.00s (-18dB)
- SFX: paper rustle (when card enters, -22dB)
- SFX: micro ticks (when each line of text enters staggered, -26dB each)

**[CHROME]**

- A: advances to `CAPABILITY · 02`, second dot is solid
- B: ON
- **C: First entry** at 09.80s, `any→md  ━━━━●━━━━━  md→html  ─  html→md  ─  md→docx  ─  md→pdf  ─  md→epub`, progress point ● is located above the second slot
- D: ON
- E: ON

**[ANTI-SLOP]**

- ✅ The "On Markdown" essay content of the destination card is actually a readable short English philosophical passage, not Lorem ipsum
- ✅ The "article.html · TUFTE THEME" stamp is a "detail signature readable when paused"
- ✅ No glow or particle is used to "emphasize" the md → html translation—relying on typography and composition to speak for itself
- ✅ The arrow line is not dashed or dotted (to avoid a "web tutorial" feel), it is a 1.5px solid Terracotta line
- ✅ pause-and-look signature: The "AN ESSAY · 2026" subtitle at the top of the destination card uses Newsreader's small caps OpenType feature with a 0.18em letter-spacing—this is the 120% detail of this shot

**[WHY]**

This is the first establishment of the ScenePipeline pattern. The subsequent 5 capability shots will all advance according to this structure:
1. md on the left, destination on the right
2. arrow + label in the middle
3. destination card internal staggered entry (each card has 6-8 text hierarchy levels)
4. card content is real and readable, not fake bar lines

The audience will understand this pattern by the second time (SHOT 06), and by the sixth time (SHOT 09), they will feel "Ah, here it is again, but this time it's NEW"—this is exactly the rhythm design of ACT II.

---

## SHOT 06 · "REVERSE FLOW · MD" (html → md)

**[TIMECODE]** 11.50 — 14.50s (3.0s) `|` **FUNCTION** CAPABILITY 03. Reverse archiving: html → md. Establishes the "bidirectional flow" concept.

**[VISUAL]**

cross-dissolve transition. The destination card from the previous shot shrinks and exits to the bottom-right corner within 11.50-11.80s, and the new destination card (showing markdown source code this time) enters from the right.

New destination card design: **dark background markdown source view** (creating a visual contrast with the light background html of SHOT 05).

```
┌─────────────────────────────────┐
│                                  │  ← Background Charred #2A2620
│  # On Markdown                   │  ← Terracotta, mono 14px
│                                  │
│  An essay · 2026                 │  ← Smoke, mono 14px
│                                  │
│  > md is the source.             │  ← italic Smoke, mono 14px
│  > Anything else is **product**. │     `**product**` highlight mica + bold
│                                  │
│  - 1 source                      │  ← mono 14px Smoke
│  - 6 forms                       │
│  - ∞ outputs                     │
│                                  │
│  essay.md · CLEAN MARKDOWN       │  ← bottom Mono 10px Smoke
└─────────────────────────────────┘
   480×560px, Charred background, 24° corner fold at the top is Cinder
```

arrow direction reversed: from the right destination card to the left md character direction (short Terracotta line + arrow head pointing left). label changed to "html → md".

**Key differences** (forming a visual rhyme with SHOT 05):
- destination on the right, md on the left (same as SHOT 05)
- But the arrow direction is reversed (visual: we are archiving/pulling back)
- The card has a dark background (visual contrast, emphasizing this is the source)

**[TYPE]**

- Inside the entire card is JetBrains Mono 14px
- Markdown syntax element coloring: `#` heading Terracotta, `>` quote italic Smoke, `**bold**` Mica + bold, list dash Smoke
- bottom mono 10px Smoke

**[ANIM]**

- 11.50-11.80s · card from previous shot exits (shrinks → bottom-right corner, fades out) + md characters remain
- 11.80-12.10s · arrow line grows in reverse (this time from right to left, 300ms expoOut)
- 12.10s · arrow head (pointing left) emerges
- 12.20-12.40s · label "html → md" enters
- 12.40-13.10s · new destination card enters (same entry logic as SHOT 05)
- 13.10-13.80s · markdown internal 6 lines staggered entry (100ms delay per line)
  - Special micro-detail: Each line simulates a typewriter on entry—a character-by-character cascade reveal of the line (making the audience feel "this is the process of markdown being 'written out'")
- 13.80-14.50s · hold

**[AUDIO]**

- BGM: continuous L1+L2+L3 layers
- SFX: chime: capability 03 at 12.00s (-18dB)
- SFX: paper rustle (12.40s)
- SFX: extremely soft keyboard click ticker as each line enters (-26dB each, 100ms apart)

**[CHROME]**

- A: advances to `CAPABILITY · 03`, third dot is solid
- B: ON
- C: progress point ● slides to the "html→md" position
- D: ON
- E: ON

**[ANTI-SLOP]**

- ✅ This is the only "dark background" shot in the entire video—deliberately creating visual contrast to let the audience know "this is the source code", not "just another destination"
- ✅ The syntax highlighting colors inside the markdown are not cyber colors (not like VS Code Dark+), but publisher colors (Terracotta + Smoke + Mica)
- ✅ "essay.md · CLEAN MARKDOWN" bottom stamp → pause-and-look signature
- ✅ The reverse arrow is not a "U-turn curve", it is a straight line + reverse arrow—maintaining structural consistency

**[WHY]**

The real purpose of this shot is not to "show off capability 03", but to **tell the audience that this pipeline is bidirectional**.

If all 6 capabilities in the entire video radiated outward from md, the audience would assume "md only goes out". The 3rd capability reverses the flow, establishing the worldview of "md is the center of everything".

This is why I chose the capability order 02 (md→html) → 03 (html→md) → 04 (md→docx) — deliberately placing the reverse capability in the 3rd slot to maximize the cognitive surprise of "bidirectional flow".

---

## SHOT 07 · "PUBLISHER GRADE · DOCX" (md → docx)

**[TIMECODE]** 14.50 — 17.50s (3.0s) `|` **FUNCTION** CAPABILITY 04. Publisher-grade docx. Establishes the argument that "md is not just for programmers."

**[VISUAL]**

Back to the light background, back to "md on the left, destination on the right".

destination card design: **Publisher-grade docx chapter main page** (high-density information, yet completely restrained).

```
┌─────────────────────────────────┐
│                       ON MARKDOWN│  ← page header, right-aligned, Smoke italic mono 9px
│  CHAPTER · 01                    │  ← Terracotta mono 11px bold 0.22em
│                                  │
│  On Markdown                     │  ← Newsreader 700, 36px, Ink, lh 1.1
│  A short essay on source-of-truth│  ← Newsreader italic 14px, Smoke
│  thinking                        │
│                                  │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━     │  ← Terracotta full-width rule 3px
│                                  │
│  ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬       │  ← 10 lines of mica bar paragraphs
│  ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬           │     (varied widths 76-95%)
│  ...                             │
│                                  │
│                — 1 —             │  ← page number, centered, mono 10px Smoke
└─────────────────────────────────┘
   480×580px, white card, Mica border, 24° corner fold
```

**Special details**:
- The "page header" in the top-right corner (book title in italic gray mono) is a detail signature of a real publisher's docx
- The "CHAPTER · 01" prefix makes the audience realize at a glance that "this is a page of a book, not an article"
- The terracotta full-width rule (not a thin line, but a 3px thick rule) is the signature of a publisher's chapter main page
- The dashes before and after the page number "— 1 —" at the bottom are Newsreader's em-dashes, not hyphens

**[TYPE]**

- page header: Newsreader italic 9px, Smoke, letter-spacing 0.14em
- CHAPTER · 01: JetBrains Mono Bold 11px, Terracotta, letter-spacing 0.22em
- main title: Newsreader 700, 36px, Ink, line-height 1.05
- subtitle: Newsreader italic 14px, Smoke
- terracotta rule: 3px thick, full card width
- bar paragraphs: Mica color #E6E1D6, height 6px
- page number: JetBrains Mono 10px, Smoke, letter-spacing 0.18em

**[ANIM]**

- 14.50-14.80s · card from previous shot exits + md remains
- 14.80-15.10s · arrow line grows forward
- 15.10s · arrow head, label "md → docx" enters
- 15.30-16.10s · destination card enters as a whole
- 16.10-17.00s · internal stagger: page header (delay 0) → CHAPTER marker (delay 100ms) → title (delay 300ms) → subtitle (delay 500ms) → rule (delay 700ms) → 10 lines of paragraph cascade (delay 850ms + 60ms cascade) → page number (delay 1600ms)
- 17.00-17.50s · hold

**[AUDIO]**

- BGM: continuous; at 15.00s BGM overall swells +2dB (implying we are building up to the climax)
- SFX: chime: capability 04 at 15.00s (-18dB)
- SFX: paper rustle (15.30s)

**[CHROME]**

- A: `CAPABILITY · 04`, fourth dot is solid
- B/C/D/E: ON

**[ANTI-SLOP]**

- ✅ Do not write explanatory text like "this is a book inner page mockup" (let typography speak for itself)
- ✅ The bar paragraphs use a very light gray like Mica (#E6E1D6) rather than black—giving an honest signal that "this is a typographic style preview, not real content"
- ✅ pause-and-look signature: right-aligned page header italic mono at the top—99% of the audience won't notice, but 1% of designers will see it and know "this team did their homework"
- ✅ This shot is the most color-saturated among the 6 capabilities (Terracotta occupies the page rule + chapter label + top-right chrome counter)—exactly in the middle of the story arc, fitting the "build-up to climax" curve

**[WHY]**

CAPABILITY 04 is a key transitioning shot:
- It confirms that "md is not just for web use"—it can produce publisher-grade docx
- It establishes a "printed publication" visual context, preparing for SHOT 08 (pdf) and SHOT 09 (epub)

After watching this shot, the audience is ready for the "md → printed publication" pipeline. The NEW tags in the next two shots will then feel connected.

---

## SHOT 08 · "★ NEW · PRINT" (md → pdf)

**[TIMECODE]** 17.50 — 20.50s (3.0s) `|` **FUNCTION** CAPABILITY 05. **NEW**. md → publisher-grade PDF. The first "upgrade" marker lights up.

**[VISUAL]**

cross-dissolve transition. The visual intensity of this shot is **significantly higher** than SHOTs 05-07—because this is "something new" and needs to be remembered.

Visual differences:
1. **NEW Label**: A Terracotta rectangular border lights up next to the capability counter in the top-left, containing "★ NEW" characters (JetBrains Mono Bold 13px, Terracotta, letter-spacing 0.22em, 4px Terracotta border, 6px×12px padding)
2. **destination is not a single card, but two PDFs fanned out**: A4 in the back (slight +5° rotation), Large 32mo (176×240mm, domestic paper book specification) in the front (slight -3° rotation), forming a visual representation of "supporting both page-sizes"
3. **Each PDF has "crop marks"**—an L-shaped thin line in each of the four corners, 2px thick, Smoke color—this is a detail of actual print-shop PDFs
4. Arrow + label coloring all use Terracotta (not Ink), making the overall color palette warmer

**Contents of the two PDFs**:

```
┌──────────────────────────┐
│ ┌                      ┐ │  ← crop marks
│  A4 · 210×297mm           │  ← Mono Bold 10px Terracotta
│  ─── (Terracotta rule)    │
│  On Markdown              │  ← Newsreader 22px
│  ──────────────────       │
│  ▬▬▬▬▬▬▬▬▬▬▬             │  ← 7 lines mica bars
│  ▬▬▬▬▬▬▬▬▬▬▬▬            │
│  ...                      │
│                           │
│ └                      ┘ │  ← crop marks
└──────────────────────────┘
   360×460px, white card, +5° rotation
```

```
┌────────────────────┐
│ ┌                ┐ │  ← crop marks
│  Large 32mo · 176×240mm│  ← Mono Bold 10px Terracotta
│  ───                │
│  On Markdown        │  ← Newsreader 19px
│  ──────────         │
│  ▬▬▬▬▬▬▬▬▬▬        │  ← 6 lines mica bars
│  ...                │
│ └                ┘ │
└────────────────────┘
   290×410px, white card, -3° rotation
```

**[TYPE]**

- NEW label: Mono Bold 13px Terracotta, 0.22em letter-spacing, 1.5px Terracotta border
- arrow label "md → pdf": Mono Bold 14px Terracotta, 0.14em
- PDF spec labels (A4 · 210×297mm etc.): Mono Bold 10px Terracotta, 0.2em
- chapter titles inside PDFs: Newsreader 600 weight, 19-22px, Ink

**[ANIM]**

- 17.50-17.80s · card from previous shot exits + md remains
