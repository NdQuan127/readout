# Gallery Ripple + Multi-Focus · Scene Orchestration Philosophy

> A **reusable visual orchestration structure** distilled from the huashu-design hero animation v9 (25 seconds, 8 scenes).
> It is not an animation production pipeline, but rather **in what scenarios this orchestration is "right"**.
> Practical Reference: [demos/hero-animation-v9.mp4](../demos/hero-animation-v9.mp4) · [https://www.huasheng.ai/huashu-design-hero/](https://www.huasheng.ai/huashu-design-hero/)

## TL;DR

> **When you have 20+ homogeneous visual assets and the scene needs to "convey scale and depth", prioritize this Gallery Ripple + Multi-Focus orchestration over cluttered layouts.**

Generic SaaS feature animations, product launches, skill promotions, portfolio showcases—as long as you have enough assets and a consistent style, this structure almost always delivers.

---

## What Exactly is This Technique Conveying?

It's not "showing off assets"—it tells a narrative through **two rhythmic shifts**:

**Beat 1: Ripple Reveal (~1.5s)**: 48 cards ripple outward from the center. The audience is awed by the sheer volume—"Oh, there's so much output here."

**Beat 2: Multi-Focus (~8s, 4 loops)**: While the camera slowly pans, it dims and desaturates the background four times to zoom in on a single card in the center of the screen. The audience shifts from the "impact of volume" to a "gaze of quality," with a stable pace of 1.7s per cycle.

**Core Narrative Structure**: **Scale (Ripple) → Gaze (Focus × 4) → Outro (Walloff)**. These three beats combine to express "Breadth × Depth"—not only is there a vast quantity, but every single item is worth pausing to look at.

Contrast with negative patterns:

| Approach | Audience Perception |
|------|---------|
| Static grid of 48 cards (No Ripple) | Looks good but has no narrative; feels like a grid screenshot |
| Rapid cuts one by one (No Gallery context) | Feels like a slideshow; loses the sense of scale |
| Ripple only, no Focus | Awed by the scale but fails to make any specific card memorable |
| **Ripple + Focus × 4 (This formula)** | **First awed by quantity, then gazing at quality, finally fading out calmly—a complete emotional arc** |

---

## Prerequisites (Must All Be Met)

This orchestration **is not a silver bullet**; all four of the following conditions must be met:

1. **Asset scale ≥ 20 items, ideally 30+**
   Fewer than 20 items will make the Ripple look empty—there is a sense of density only when all 48 slots are in motion. v9 used 48 grid slots with 32 unique images (loop-filled).

2. **Consistent visual style of assets**
   All 16:9 slide previews / all app screenshots / all cover designs—the aspect ratios, color palettes, and layouts must look like they belong to "one system". Mixing and matching styles will make the Gallery look like a random clipboard.

3. **Assets must remain legible when zoomed in**
   Focus works by zooming a card to 960px wide. If the original image gets blurry or has sparse information when enlarged, the Focus beat is ruined. Reverse validation: Can you select 4 "most representative" cards from the 48? If not, the quality of the assets is inconsistent.

4. **The scene itself must be landscape or square, not portrait**
   The 3D tilt of the Gallery (`rotateX(14deg) rotateY(-10deg)`) requires a sense of horizontal extension. A portrait screen will make the tilt look narrow and awkward.

**Fallback Paths When Conditions Are Not Met:**

| Missing Condition | Fallback Solution |
|-------|-----------|
| Assets < 20 items | Switch to "3-5 side-by-side static items + sequential focus" |
| Inconsistent style | Switch to a keynote-style "Cover + 3 major section images" layout |
| Sparse information | Switch to a "data-driven dashboard" or "punchy quotes + large text" |
| Portrait scene | Switch to a "vertical scroll + sticky cards" layout |

---

## Technical Formula (v9 Production Parameters)

### 4-Layer Structure

```
viewport (1920×1080, perspective: 2400px)
  └─ canvas (4320×2520, huge overflow) → 3D tilt + pan
      └─ 8×6 grid = 48 cards (gap 40px, padding 60px)
          └─ img (16:9, border-radius 9px)
      └─ focus-overlay (absolute center, z-index 40)
          └─ img (matches selected slide)
```

**Key**: The canvas is 2.25 times larger than the viewport, which makes the pan feel like "peeking into a larger world."

### Ripple Reveal (Distance Delay Algorithm)

```js
// Entrance time of each card = distance to center × 0.8s delay
const col = i % 8, row = Math.floor(i / 8);
const dc = col - 3.5, dr = row - 2.5;       // Offset to the center
const dist = Math.hypot(dc, dr);
const maxDist = Math.hypot(3.5, 2.5);
const delay = (dist / maxDist) * 0.8;       // 0 → 0.8s
const localT = Math.max(0, (t - rippleStart - delay) / 0.7);
const opacity = expoOut(Math.min(1, localT));
```

**Core Parameters**:
- Total duration: 1.7s (`T.s3_ripple: [8.3, 10.0]`)
- Maximum delay: 0.8s (center reveals earliest, corners latest)
- Entrance duration per card: 0.7s
- Easing: `expoOut` (for a sense of explosion, not smoothness)

**Simultaneous Action**: The canvas scale transitions from 1.25 → 0.94 (zoom out to reveal)—coordinating with the reveal for a synchronized pushback feel.

### Multi-Focus (4-Beat Rhythm)

```js
T.focuses = [
  { start: 11.0, end: 12.7, idx: 2  },  // 1.7s
  { start: 13.3, end: 15.0, idx: 3  },  // 1.7s
  { start: 15.6, end: 17.3, idx: 10 },  // 1.7s
  { start: 17.9, end: 19.6, idx: 16 },  // 1.7s
];
```

**Rhythmic Pattern**: Each focus lasts 1.7s, with a 0.6s breathing gap. Total duration is 8s (11.0–19.6s).

**Inside Each Focus Event**:
- In ramp: 0.4s (`expoOut`)
- Hold: 0.9s in the middle (`focusIntensity = 1`)
- Out ramp: 0.4s (`easeOut`)

**Background Changes (This is Key)**:

```js
if (focusIntensity > 0) {
  const dimOp = entryOp * (1 - 0.6 * focusIntensity);  // dim to 40%
  const brt = 1 - 0.32 * focusIntensity;                // brightness 68%
  const sat = 1 - 0.35 * focusIntensity;                // saturate 65%
  card.style.filter = `brightness(${brt}) saturate(${sat})`;
}
```

**Not just opacity—simultaneous desaturation + darkening**. This makes the colors of the foreground overlay "pop out" rather than just making them "a bit brighter."

**Focus Overlay Dimensions Animation**:
- From 400×225 (entrance) → 960×540 (hold state)
- Wrapped with a 3-layer shadow + 3px accent-colored outline ring, creating a "framed look and feel"

### Pan (Continuous Movement to Prevent Static Boredom)

```js
const panT = Math.max(0, t - 8.6);
const panX = Math.sin(panT * 0.12) * 220 - panT * 8;
const panY = Math.cos(panT * 0.09) * 120 - panT * 5;
```

- Dual-layered motion of sine wave + linear drift—not a pure loop; the position is different at every moment
- Different X/Y frequencies (0.12 vs 0.09) to prevent the viewer from detecting a "regular cycle"
- clamped within ±900/500px to prevent drifting out of bounds

**Why not pure linear pan**: With pure linear pan, the audience easily predicts where the camera will be next; the sine + drift combination makes every second fresh. Under the 3D tilt, this creates a subtle "motion sickness" sensation (in a good way) that hooks the viewer's attention.

---

## 5 Reusable Patterns (Distilled from v6→v9 Iterations)

### 1. **expoOut as the primary easing, not cubicOut**

`easeOut = 1 - (1-t)³` (smooth) vs `expoOut = 1 - 2^(-10t)` (burst followed by rapid deceleration).

**Rationale**: The first 30% of expoOut quickly reaches 90%. It feels more like physical damping, aligning with the intuition of "heavy objects landing." It is especially suited for:
- Card entrance (weight feel)
- Ripple propagation (shockwave feel)
- Brand float-up (settling feel)

**When to still use cubicOut**: Focus out ramps and symmetrical micro-interactions.

### 2. **Paper-texture background + terracotta orange accent (Anthropic pedigree)**

```css
--bg: #F7F4EE;        /* warm paper */
--ink: #1D1D1F;       /* almost black */
--accent: #D97757;    /* terracotta orange */
--hairline: #E4DED2;  /* warm hairline */
```

**Why**: A warm background color retains a "breathing quality" even after GIF compression, unlike pure white which looks too "screen-like." Terracotta orange serves as the single accent color running through the terminal prompt, directory-card selection, cursor, brand hyphen, and focus ring—connecting all visual anchors with one color.

**Lesson from v5**: We added a noise overlay to simulate "paper texture," but it completely ruined GIF frame compression (since every frame was different). v6 changed to "background color only + warm shadow," keeping 90% of the paper feel while reducing GIF file size by 60%.

### 3. **Two tiers of shadow to simulate depth without true 3D**

```css
.gallery-card.depth-near { box-shadow: 0 32px 80px -22px rgba(60,40,20,0.22), ... }
.gallery-card.depth-far  { box-shadow: 0 14px 40px -16px rgba(60,40,20,0.10), ... }
```

Using a deterministic `sin(i × 1.7) + cos(i × 0.73)` algorithm to assign near/mid/far shadow tiers to each card—**creating a visual sense of "3D stacking" while keeping transform properties completely unchanged per frame, resulting in 0 GPU overhead**.

**The cost of true 3D**: `translateZ` applied to each card individually requires the GPU to compute 48 transforms and shadow blurs on every frame. We tried this in v4, and even Playwright struggled to record at 25fps. In v6, the visual difference between the two shadow tiers is <5%, but the computational cost differs tenfold.

### 4. **Weight interpolation (font-variation-settings) feels more cinematic than font-size scaling**

```js
const wght = 100 + (700 - 100) * morphP;  // 100 → 700 over 0.9s
wordmark.style.fontVariationSettings = `"wght" ${wght.toFixed(0)}`;
```

The brand wordmark morphs from Thin → Bold over 0.9s, paired with a subtle letter-spacing adjustment (-0.045 → -0.048em).

**Why it is better than scaling:**
- Scaling is overused, and the audience's expectation is set.
- Weight interpolation provides an "inherent sense of fullness," like a balloon being inflated, rather than "being pushed closer."
- Variable fonts are a feature popularized after 2020, giving the audience a subconscious impression of "modernity."

**Limitation**: You must use a typeface that supports variable fonts (e.g., Inter, Roboto Flex, Recursive). Normal static fonts can only simulate this, which causes jarring jumps between fixed weights.

### 5. **Low-intensity persistent corner branding signature**

During the Gallery stage, a small `HUASHU · DESIGN` mark appears in the top-left corner with 16% opacity, a 12px font size, and wide letter-spacing.

**Why add this:**
- After the Ripple bursts, the audience can easily lose focus and forget what they are watching. A subtle top-left indicator helps anchor their attention.
- More elegant than a full-screen giant logo—designers know that a brand signature does not need to shout.
- It leaves a mark of ownership even when the GIF is screenshotted and shared.

**Rule**: Appears only during the middle section (when the screen is busy). Off at the start (to avoid blocking the terminal) and off at the end (when the brand reveal takes center stage).

---

## Anti-Patterns: When NOT to Use This Orchestration

❌ **Product demos (showing features)**: The Gallery flies by so quickly that the audience cannot remember any individual feature. Switch to "single-screen focus + tooltips."

❌ **Data-driven content**: The audience needs to read numbers, but the rapid pace of the Gallery does not grant them enough time. Switch to "data charts + sequential reveal."

❌ **Story narratives**: A Gallery is a parallel structure, whereas stories require causality. Switch to keynote-style section transitions.

❌ **When you only have 3-5 assets**: The Ripple density is insufficient, making it look like a "patchwork." Switch to "static arrangement + sequential highlighting."

❌ **Portrait (9:16)**: The 3D tilt requires horizontal space. A portrait screen will make the tilt feel skewed rather than spread out.

---

## How to Determine if Your Task Suits This Orchestration

A quick three-step check:

**Step 1: Asset Count**: Count how many homogeneous visual assets you have. < 15 → Stop; 15-25 → Put together more; 25+ → Go ahead and use.

**Step 2: Consistency Test**: Place 4 random assets side-by-side. Do they look like they belong to "one system"? If not → Unify their style first, or change the approach.

**Step 3: Narrative Alignment**: Are you trying to convey "Breadth × Depth" (quantity × quality)? Or is it a "workflow", "feature demo", or "story"? If it is not the former, do not force this structure.

If all three steps are "yes", directly fork the v6 HTML, modify the `SLIDE_FILES` array and timeline to reuse. Adjust the color palette by changing `--bg / --accent / --ink` to swap the skin without modifying the underlying bones.

---

## Related References

- Full technical workflow: [references/animations.md](animations.md) · [references/animation-best-practices.md](animation-best-practices.md)
- Animation export pipeline: [references/video-export.md](video-export.md)
- Audio configuration (Dual-track BGM + SFX): [references/audio-design-rules.md](audio-design-rules.md)
- Apple-gallery style horizontal reference: [references/apple-gallery-showcase.md](apple-gallery-showcase.md)
- Source HTML (v6 + Audio integrated version): `www.huasheng.ai/huashu-design-hero/index.html`
