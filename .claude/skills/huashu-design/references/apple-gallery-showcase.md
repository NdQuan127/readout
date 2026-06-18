# Apple Gallery Showcase · Gallery Showcase Wall Animation Style

> Inspiration: Claude Design official website hero video + Apple product page "work wall" style display
> Practical Source: huashu-design release hero v5
> Applicable Scenarios: **Product launch hero animations, skill capability demonstrations, portfolio showcases**—any scenario where you need to display "multiple high-quality deliverables" simultaneously and guide the audience's attention.

---

## Trigger Decision: When to Use This Style

**Suitable for**:
- Displaying 10+ actual deliverables on the same screen (slides, apps, web pages, infographics)
- Professional audience (developers, designers, product managers) sensitive to "texture/quality"
- Conveying a tone that is "restrained, exhibition-like, premium, and spacious"
- Requiring both focus and overview to coexist (viewing details without losing the big picture)

**Not suitable for**:
- Single-product focus (use the frontend-design product hero template instead)
- Emotion-driven or highly narrative animations (use the timeline storytelling template instead)
- Small screens / portrait mode (the tilted perspective will look blurry on small screens)

---

## Core Visual Tokens

```css
:root {
  /* Light gallery palette */
  --bg:         #F5F5F7;   /* Main canvas background — Apple website gray */
  --bg-warm:    #FAF9F5;   /* Warm off-white variant */
  --ink:        #1D1D1F;   /* Main text color */
  --ink-80:     #3A3A3D;
  --ink-60:     #545458;
  --muted:      #86868B;   /* Secondary text */
  --dim:        #C7C7CC;
  --hairline:   #E5E5EA;   /* Card 1px border */
  --accent:     #D97757;   /* Terracotta orange — Claude brand */
  --accent-deep:#B85D3D;

  --serif-cn: "Noto Serif SC", "Songti SC", Georgia, serif;
  --serif-en: "Source Serif 4", "Tiempos Headline", Georgia, serif;
  --sans:     "Inter", -apple-system, "PingFang SC", system-ui;
  --mono:     "JetBrains Mono", "SF Mono", ui-monospace;
}
```

**Key Principles**:
1. **Never use a pure black background**. Black backgrounds make the work look like a movie, rather than "work deliverables ready to be adopted."
2. **Terracotta orange is the only hue accent**; everything else is grayscale + white.
3. **Three-font stack** (Serif EN + Serif CN + Sans + Mono) builds an editorial/publication aesthetic rather than an "internet product" feel.

---

## Core Layout Patterns

### 1. Floating Card (The Fundamental Unit of the Style)

```css
.gallery-card {
  background: #FFFFFF;
  border-radius: 14px;
  padding: 6px;                          /* Padding acts as the "mounting board" */
  border: 1px solid var(--hairline);
  box-shadow:
    0 20px 60px -20px rgba(29, 29, 31, 0.12),   /* Primary shadow, soft and long */
    0 6px 18px -6px rgba(29, 29, 31, 0.06);     /* Secondary ambient light, creating the floating effect */
  aspect-ratio: 16 / 9;                  /* Unifies the slide ratio */
  overflow: hidden;
}
.gallery-card img {
  width: 100%; height: 100%;
  object-fit: cover;
  border-radius: 9px;                    /* Slightly smaller than the card border radius for visual nesting */
}
```

**Anti-Pattern**: Avoid edge-to-edge tiled cards (without padding, borders, or shadows)—that represents infographic density, not an exhibition.

### 2. 3D Tilted Gallery Wall

```css
.gallery-viewport {
  position: absolute; inset: 0;
  overflow: hidden;
  perspective: 2400px;                   /* Deeper perspective, tilt is not exaggerated */
  perspective-origin: 50% 45%;
}
.gallery-canvas {
  width: 4320px;                         /* Canvas = 2.25x viewport */
  height: 2520px;                        /* Leaves space for panning */
  transform-origin: center center;
  transform: perspective(2400px)
             rotateX(14deg)              /* Tilt backward */
             rotateY(-10deg)             /* Rotate left */
             rotateZ(-2deg);             /* Minor roll/tilt, breaking the rigid grid */
  display: grid;
  grid-template-columns: repeat(8, 1fr);
  gap: 40px;
  padding: 60px;
}
```

**Parameter Sweet Spots**:
- rotateX: 10-15deg (any more and it looks like a VIP background banner at a reception)
- rotateY: ±8-12deg (symmetry control)
- rotateZ: ±2-3deg (adds a human touch, signaling "this wasn't aligned by a machine")
- perspective: 2000-2800px (less than 2000px causes fisheye distortion; greater than 3000px approaches orthographic projection)

### 3. 2×2 Four-Corner Convergence (Selection Scenes)

```css
.grid22 {
  display: grid;
  grid-template-columns: repeat(2, 800px);
  gap: 56px 64px;
  align-items: start;
}
```

Each card slides in and fades in from its corresponding corner (tl/tr/bl/br) towards the center. The corresponding `cornerEntry` vectors:

```js
const cornerEntry = {
  tl: { dx: -700, dy: -500 },
  tr: { dx:  700, dy: -500 },
  bl: { dx: -700, dy:  500 },
  br: { dx:  700, dy:  500 },
};
```

---

## Five Core Animation Modes

### Mode A · Four-Corner Convergence (0.8–1.2s)

4 elements slide in from the four corners of the viewport while scaling 0.85 → 1.0 with ease-out. Ideal for intro scenes showing "multi-directional choices."

```js
const inP = easeOut(clampLerp(t, start, end));
card.style.transform = `translate3d(${(1-inP)*ce.dx}px, ${(1-inP)*ce.dy}px, 0) scale(${0.85 + 0.15*inP})`;
card.style.opacity = inP;
```

### Mode B · Selected Zoom + Others Slide Out (0.8s)

The selected card zooms 1.0 → 1.28, while other cards fade out, blur, and drift back toward the four corners:

```js
// Selected
card.style.transform = `translate3d(${cellDx*outP}px, ${cellDy*outP}px, 0) scale(${1 + 0.28*easeOut(zoomP)})`;
// Unselected
card.style.opacity = 1 - outP;
card.style.filter = `blur(${outP * 1.5}px)`;
```

**Key Point**: Unselected cards must blur, not just fade. Blurring simulates depth of field, visually "pushing forward" the selected card.

### Mode C · Ripple Expansion (1.7s)

Fanning out from the center, each card fades in sequentially with a distance-based delay while scaling down from 1.25x to 0.94x (simulating a "camera zoom-out"):

```js
const col = i % COLS, row = Math.floor(i / COLS);
const dc = col - (COLS-1)/2, dr = row - (ROWS-1)/2;
const dist = Math.sqrt(dc*dc + dr*dr);
const delay = (dist / maxDist) * 0.8;
const localT = Math.max(0, (t - rippleStart - delay) / 0.7);
card.style.opacity = easeOut(Math.min(1, localT));

// Simultaneously scales the overall gallery 1.25 → 0.94
const galleryScale = 1.25 - 0.31 * easeOut(rippleProgress);
```

### Mode D · Sinusoidal Pan (Continuous Drift)

Combines sine waves with linear drift to avoid the rigid "start-to-finish" loop feel of a typical marquee:

```js
const panX = Math.sin(panT * 0.12) * 220 - panT * 8;    // Horizontal drift to the left
const panY = Math.cos(panT * 0.09) * 120 - panT * 5;    // Vertical drift upwards
const clampedX = Math.max(-900, Math.min(900, panX));   // Prevents edges from being exposed
```

**Parameters**:
- Sine period `0.09-0.15 rad/s` (slow, roughly 30–50 seconds per swing)
- Linear drift `5-8 px/s` (slower than a viewer's blink)
- Amplitude `120-220 px` (noticeable but not dizzying)

### Mode E · Focus Overlay (Focus Switching)

**Key Design**: The focus overlay is a **flat element** (no tilt/perspective) floating above the tilted canvas. The selected slide scales from its tile position (approx. 400×225) to the center of the screen (960×540). The background canvas remains tilted but **dims to 45%**:

```js
// Focus overlay (flat, centered)
focusOverlay.style.width = (startW + (endW - startW) * focusIntensity) + 'px';
focusOverlay.style.height = (startH + (endH - startH) * focusIntensity) + 'px';
focusOverlay.style.opacity = focusIntensity;

// Background card dims but remains visible (Crucial! Avoid 100% opacity masking)
card.style.opacity = entryOp * (1 - 0.55 * focusIntensity);   // 1 → 0.45
card.style.filter = `brightness(${1 - 0.3 * focusIntensity})`;
```

**Clarity Rules**:
- The `<img>` inside the Focus overlay must connect directly to the high-resolution original source via `src`, **do not reuse the compressed thumbnails from the gallery**.
- Preload all original images in advance into a `new Image()[]` array.
- Calculate the overlay's own `width/height` frame-by-frame, letting the browser resample the original image at each frame.

---

## Timeline Architecture (Reusable Skeleton)

```js
const T = {
  DURATION: 25.0,
  s1_in: [0.0, 0.8],    s1_type: [1.0, 3.2],  s1_out: [3.5, 4.0],
  s2_in: [3.9, 5.1],    s2_hold: [5.1, 7.0],  s2_out: [7.0, 7.8],
  s3_hold: [7.8, 8.3],  s3_ripple: [8.3, 10.0],
  panStart: 8.6,
  focuses: [
    { start: 11.0, end: 12.7, idx: 2  },
    { start: 13.3, end: 15.0, idx: 3  },
    { start: 15.6, end: 17.3, idx: 10 },
    { start: 17.9, end: 19.6, idx: 16 },
  ],
  s4_walloff: [21.1, 21.8], s4_in: [21.8, 22.7], s4_hold: [23.7, 25.0],
};

// Core easing
const easeOut = t => 1 - Math.pow(1 - t, 3);
const easeInOut = t => t < 0.5 ? 4*t*t*t : 1 - Math.pow(-2*t+2, 3)/2;
function lerp(time, start, end, fromV, toV, easing) {
  if (time <= start) return fromV;
  if (time >= end) return toV;
  let p = (time - start) / (end - start);
  if (easing) p = easing(p);
  return fromV + (toV - fromV) * p;
}

// Single render(t) function: reads timestamps and writes to all elements
function render(t) { /* ... */ }
requestAnimationFrame(function tick(now) {
  const t = ((now - startMs) / 1000) % T.DURATION;
  render(t);
  requestAnimationFrame(tick);
});
```

**Architectural Essence**: **All states are derived from the timestamp t**, with no state machines and no `setTimeout`. This ensures:
- Instant seeking to any playback moment like `window.__setTime(12.3)` (convenient for Playwright frame-by-frame captures)
- Naturally seamless loops (t mod DURATION)
- The ability to freeze any frame during debugging

---

## Texture/Quality Details (Easy to Overlook but Critical)

### 1. SVG Noise Texture

Light backgrounds suffer most from looking "too flat." Overlay a very subtle fractalNoise layer:

```html
<style>
.stage::before {
  content: '';
  position: absolute; inset: 0;
  background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='200' height='200'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='2' stitchTiles='stitch'/><feColorMatrix values='0 0 0 0 0.078  0 0 0 0 0.078  0 0 0 0 0.074  0 0 0 0.035 0'/></filter><rect width='100%' height='100%' filter='url(%23n)'/></svg>");
  opacity: 0.5;
  pointer-events: none;
  z-index: 30;
}
</style>
```

It looks virtually identical, but you will immediately notice the difference if you remove it.

### 2. Corner Brand Identity

```html
<div class="corner-brand">
  <div class="mark"></div>
  <div>HUASHU · DESIGN</div>
</div>
```

```css
.corner-brand {
  position: absolute; top: 48px; left: 72px;
  font-family: var(--mono);
  font-size: 12px;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: var(--muted);
}
```

Only displays during the gallery wall scene, fading in and out. Mimics an art gallery exhibition label.

### 3. Ending Brand Wordmark

```css
.brand-wordmark {
  font-family: var(--sans);
  font-size: 148px;
  font-weight: 700;
  letter-spacing: -0.045em;   /* Negative letter-spacing is key to tightening the letters into a logo mark */
}
.brand-wordmark .accent {
  color: var(--accent);
  font-weight: 500;           /* The accent character is slightly thinner for visual contrast */
}
```

`letter-spacing: -0.045em` is the standard practice for large typography on Apple product pages.

---

## Common Failure Modes

| Symptom | Cause | Solution |
|---|---|---|
| Looks like a generic slide template | Card lacks shadow / hairline | Add two-layer box-shadow + 1px border |
| Tilted feel looks cheap | Only used rotateY without rotateZ | Add ±2-3deg rotateZ to break rigidity |
| Panning feels "choppy" | Used setTimeout or CSS keyframes loop | Use rAF + continuous sin/cos functions |
| Text is blurry when focused | Reused low-res thumbnails from the gallery tiles | Use an independent overlay + link directly to high-res source |
| Background feels too empty | Solid color `#F5F5F7` | Overlay SVG fractalNoise at 0.5 opacity |
| Typography feels too "tech/web-like" | Only Inter is used | Add Serif (one EN, one CN) + Mono for a three-font stack |

---

## References

- Complete implementation sample: `/Users/alchain/Documents/写作/01-公众号写作/项目/2026.04-huashu-design发布/配图/hero-animation-v5.html`
- Original Inspiration: claude.ai/design hero video
- Aesthetic Reference: Apple product pages, Dribbble shot collection page

When encountering animation requirements where "multiple high-quality deliverables need to be displayed," you can copy the skeleton directly from this file, swap the content, and adjust the timing.
