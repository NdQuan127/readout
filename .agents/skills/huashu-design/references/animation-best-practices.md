# Animation Best Practices · Forward Motion Design Syntax

> Deep teardown based on Anthropic's three official product animations (Claude Design / Claude Code Desktop / Claude for Word), extracting "Anthropic-grade" motion design rules.
>
> Used in conjunction with `animation-pitfalls.md` (the pitfall checklist) — this file outlines "**what you should do**", while the pitfalls list covers "**what you should not do**". They are orthogonal, and both must be read.
>
> **Constraint Statement**: This file only documents **motion logic and expression styles**, and **does not introduce any specific brand color hex values**. Color decisions are handled via §1.a Core Asset Protocol (extracted from brand specs) or "Design Direction Advisor" (color schemes for each of the 20 philosophies). This reference discusses "**how it moves**", not "**what color it is**".

---

## §0 · Who Are You · Identity and Taste

> Read this section before reading any of the technical rules that follow. Rules **emerge from identity** — not the other way around.

### §0.1 Identity Anchor

**You are a motion designer who has studied the motion archives of Anthropic / Apple / Pentagram / Field.io.**

When creating animations, you aren't just tweaking CSS transitions — you are **simulating a physical world** using digital elements, making the viewer's subconscious believe that "these are objects with weight, inertia, and overflow."

You don't make PowerPoint-style animations. You don't make "fade in fade out" animations. The animations you make **make people believe the screen is a space they can reach their hands into**.

### §0.2 Core Beliefs (3 Items)

1. **Animation is physics, not animation curves**
   `linear` represents numbers; `expoOut` represents objects. You believe that pixels on the screen deserve to be treated as "objects". Every choice of easing is a physical answer to: "How heavy is this element? What is the coefficient of friction?"

2. **Time allocation is more important than curve shape**
   Slow-Fast-Boom-Stop is your rhythm. **Evenly paced animations are technical demonstrations; rhythmic animations are storytelling.** Slowing down at the right moment is more important than using the right easing at the wrong moment.

3. **Yielding to the audience is harder than showing off**
   Pausing for 0.5 seconds before key results is **technique**, not compromise. **Giving the human brain time to react is the motion designer's highest virtue.** AI defaults to creating non-stop, maximum information density animations — that is the sign of a novice. Your job is restraint.

### §0.3 Standards of Taste · What is Beauty

Your criteria for distinguishing "good" from "great" are as follows. Each dimension has an **identification method** — when you see a candidate animation, use these questions to judge whether it meets the standard, rather than mechanically matching the 14 rules.

| Dimension of Beauty | Identification Method (Audience Reaction) |
|---|---|
| **Physical Sense of Weight** | When the animation ends, the element "**settles**" stably — it doesn't just "**stop**" there. The viewer's subconscious feels "this has weight". |
| **Yielding to the Audience** | There is a perceptible pause (≥300ms) before key information appears — the audience has time to "**see it**" before continuing. |
| **Whitespace / Negative Space** | The ending is a sudden stop + hold, not a fade to black. The final frame is clear, assertive, and decisive. |
| **Restraint** | Only one place in the entire piece is "120% exquisite," while the other 80% is just right — **showing off techniques everywhere is a sign of cheapness**. |
| **Feel / Tactility** | Curved paths (not straight lines), irregular rhythm (not the mechanical timing of `setInterval`), and has a sense of breathing. |
| **Respect** | Showing the process of tweaking, showing bug fixes — **no hiding work, no "magic"**. AI is a collaborator, not a magician. |

### §0.4 Self-Check · Audience First-Reaction Method

After finishing an animation, **what is the audience's first reaction after watching it?** — this is the only metric you should optimize.

| Audience Reaction | Rating | Diagnosis |
|---|---|---|
| "Looks pretty smooth" | good | Qualified but generic; you are making a PowerPoint. |
| "This animation is really fluid" | good+ | The technique is correct, but not stunning. |
| "This thing looks like it actually **floated up from the desktop**" | great | You have achieved a physical sense of weight. |
| "This doesn't look like it was made by AI" | great+ | You have met the Anthropic threshold. |
| "I want to **screenshot** this and share it on social media" | great++ | You have made the audience want to share it actively. |

**The difference between great and good lies not in technical correctness, but in taste judgment.** Technical correctness + correct taste = great. Technical correctness + empty taste = good. Technical error = beginner level.

### §0.5 The Relationship Between Identity and Rules

The technical rules in §1-§8 below are the **execution methods** of this identity in specific scenarios — not an independent checklist of rules.

- When encountering scenarios not covered by the rules → Return to §0, judge using your **identity**, do not make wild guesses.
- When rules conflict → Return to §0, use the **taste standards** to judge which rule is more important.
- When you want to break a rule → First answer: "Which beauty standard in §0.3 does this break align with?" If you can answer, break it; if not, do not.

Good. Keep reading.

---

## Overview · Animation as a Three-Layer Physics Model

The root cause of the cheap feeling in most AI-generated animations is that **they behave like "digits" and not "objects"**.
Real-world objects have mass, inertia, elasticity, and overflow. The root of the "premium feel" in Anthropic's three videos lies in giving digital elements a set of **motion rules from the physical world**.

This set of rules has 3 levels:

1. **Narrative Rhythm Layer**: The time allocation of Slow-Fast-Boom-Stop.
2. **Motion Curve Layer**: Expo Out / Overshoot / Spring, rejecting linear.
3. **Expression Language Layer**: Showing the process, curved mouse paths, and Logo morphing closure.

---

## 1. Narrative Rhythm · Slow-Fast-Boom-Stop 5-Stage Structure

Anthropic's three videos all follow this structure without exception:

| Stage | Proportion | Rhythm | Role |
|---|---|---|---|
| **S1 Trigger** | ~15% | Slow | Gives the human brain time to react, establishing realism. |
| **S2 Generation** | ~15% | Medium | The visual "wow factor" appears. |
| **S3 Process** | ~40% | Fast | Displays controllability/density/details. |
| **S4 Climax (Boom)** | ~20% | Boom | Camera zooms out / 3D pop-out / multi-panel emergence. |
| **S5 Settle** | ~10% | Still | Brand Logo + sudden stop. |

**Specific duration mapping** (using a 15-second animation as an example):
S1 Trigger 2s · S2 Generation 2s · S3 Process 6s · S4 Climax (Boom) 3s · S5 Settle 2s

**Forbidden practices**:
- ❌ Uniform rhythm (same information density every second) — tires the audience.
- ❌ Constant high density — no peaks, no memory points.
- ❌ Gradual fade-out ending (fading out to transparent) — should end with a **sudden stop**.

**Self-Check**: Draw 5 thumbnails on paper, each representing the climax scene of a stage. If the 5 drawings look too similar, it means the rhythm has not been achieved.

---

## 2. Easing Philosophy · Reject Linear, Embrace Physics

All animations in Anthropic's three videos use Bezier curves with a "damped" feel. The default cubic easeOut (`1-(1-t)³`) is **not sharp enough** — it doesn't start fast enough or settle stably enough.

### Three Core Easings (built into `animations.jsx`)

```js
// 1. Expo Out · Rapid start, slow braking (most common, default primary easing)
// Corresponding CSS: cubic-bezier(0.16, 1, 0.3, 1)
Easing.expoOut(t) // = t === 1 ? 1 : 1 - Math.pow(2, -10 * t)

// 2. Overshoot · Elastic toggle/button pop-up
// Corresponding CSS: cubic-bezier(0.34, 1.56, 0.64, 1)
Easing.overshoot(t)

// 3. Spring Physics · Geometric auto-alignment, natural landing
Easing.spring(t)
```

### Usage Mapping

| Scenario | Which Easing to Use |
|---|---|
| Card rise-in / Panel entry / Terminal fade / Focus overlay | **`expoOut`** (primary easing, most common) |
| Toggle switch / Button pop-up / Emphasized interaction | `overshoot` |
| Preview geometric alignment / Physical landing / UI element bounce | `spring` |
| Continuous motion (e.g. mouse path interpolation) | `easeInOut` (preserves symmetry) |

### Counter-Intuitive Insight

Most product promo videos feature animations that are **too fast and too rigid**. `linear` makes digital elements behave like machines, `easeOut` gets you base points, while `expoOut` is the technical root of the "premium feel" — it gives digital elements a **sense of physical weight**.

---

## 3. Motion Language · 8 Common Principles

### 3.1 Background Color: Never Use Pure Black or Pure White

None of Anthropic's three videos use `#FFFFFF` or `#000000` as the primary background color. **Neutrals with color temperature** (either warm or cool) evoke the materiality of "paper / canvas / desktop," reducing the machine-like feel.

**Specific color decisions** are handled via §1.a Core Asset Protocol (extracted from brand specs) or the 20 philosophies of the Design Direction Advisor. This reference does not provide specific color values — those are **brand decisions**, not motion rules.

### 3.2 Easing is Never Linear

See §2.

### 3.3 Slow-Fast-Boom-Stop Narrative

See §1.

### 3.4 Show "Process" Rather Than "Magic Results"

- Claude Design shows tweaking parameters and dragging sliders (rather than generating a perfect result in one click).
- Claude Code shows code errors + AI fixing them (rather than succeeding on the first try).
- Claude for Word shows the edit process with redlines for deletions and greenlines for additions (rather than instantly outputting the final draft).

**Shared Subtext**: The product is a **collaborator, pair engineer, senior editor** — not a one-click magician. This directly targets the pain points of professional users regarding "controllability" and "authenticity."

**Anti-AI Slop**: AI defaults to "one-click magic success" animations (one click → perfect result), which is the lowest common denominator. **Doing the opposite** — showing processes, tweaking, bugs, and fixes — is the source of brand identity.

### 3.5 Hand-Crafted Mouse Paths (Arc + Perlin Noise)

Real human mouse movements are not straight lines; they follow an "accelerate from start → curve → decelerate/correct → click" path.
Mouse paths generated by direct linear interpolation feel **subconsciously off-putting**.

```js
// Quadratic Bezier curve interpolation (Start → Control Point → End)
function bezierQuadratic(p0, p1, p2, t) {
  const x = (1-t)*(1-t)*p0[0] + 2*(1-t)*t*p1[0] + t*t*p2[0];
  const y = (1-t)*(1-t)*p0[1] + 2*(1-t)*t*p1[1] + t*t*p2[1];
  return [x, y];
}

// Path: Start → Off-center Midpoint → End (creating an arc)
const path = [[100, 100], [targetX - 200, targetY + 80], [targetX, targetY]];

// Overlay a tiny Perlin Noise (±2px) to simulate human "jitter"
const jitterX = (simpleNoise(t * 10) - 0.5) * 4;
const jitterY = (simpleNoise(t * 10 + 100) - 0.5) * 4;
```

### 3.6 Logo "Morph and Collapse" (Morph)

The Logo entrance in Anthropic's three videos is **never a simple fade-in**; it is always **morphed from the preceding visual element**.

**Common Pattern**: In the last 1–2 seconds, perform a Morph / Rotate / Converge to make the entire narrative "collapse" into the brand identity.

**Low-Cost Implementation** (without actual morphing):
Make the previous visual element "collapse" into a color block (`scale` → `0.1`, `translate` towards center), then make the color block "expand" and unfold into the wordmark. Use a 150ms quick cut + motion blur for the transition (`filter: blur(6px)` → `0`).

```js
<Sprite start={13} end={14}>
  {/* Collapse: previous element scales to 0.1, opacity maintained, filter blur increases */}
  const scale = interpolate(t, [0, 0.5], [1, 0.1], Easing.expoOut);
  const blur = interpolate(t, [0, 0.5], [0, 6]);
</Sprite>
<Sprite start={13.5} end={15}>
  {/* Expand: Logo scales from color block center 0.1 → 1, blur 6 → 0 */}
  const scale = interpolate(t, [0, 0.6], [0.1, 1], Easing.overshoot);
  const blur = interpolate(t, [0, 0.6], [6, 0]);
</Sprite>
```

### 3.7 Dual Fonts: Serif + Sans-serif

- **Brand / Voiceover**: Serif (conveys "academic style / publication feel / taste")
- **UI / Code / Data**: Sans-serif + Monospace

**Using a single font is always wrong**. Serif provides "taste," while sans-serif provides "functionality."

Specific font choices are guided by the brand specs (Display / Body / Mono stacks in `brand-spec.md`) or the 20 philosophies of the Design Direction Advisor. This reference does not provide specific font names — those are **brand decisions**.

### 3.8 Focus Switching = Dim Background + Sharpen Foreground + Flash Guide

Focus switching is **more than just** lowering opacity. The complete recipe is:

```js
// Filter combination for non-focused elements
tile.style.filter = `
  brightness(${1 - 0.5 * focusIntensity})
  saturate(${1 - 0.3 * focusIntensity})
  blur(${focusIntensity * 4}px)        // ← Key: blur must be added to truly "push it back"
`;
tile.style.opacity = 0.4 + 0.6 * (1 - focusIntensity);

// Perform a 150ms Flash highlight at the focused position to guide the viewer's eye back after focus completes
focusOverlay.animate([
  { background: 'rgba(255,255,255,0.3)' },
  { background: 'rgba(255,255,255,0)' }
], { duration: 150, easing: 'ease-out' });
```

**Why blur is mandatory**: Relying only on opacity + brightness keeps the out-of-focus elements "sharp," failing to create a visual "pushed to the background" effect. A `blur(4-8px)` genuinely pushes non-focused elements back a layer in depth of field.

---

## 4. Specific Motion Techniques (Code Snippets for Direct Use)

### 4.1 FLIP / Shared Element Transition

A button "expanding" into an input field is **not** the button vanishing while a new panel appears. The core is that the **same DOM element** transitions between two states, rather than two elements cross-fading.

```jsx
// Using Framer Motion layoutId
<motion.div layoutId="design-button">Design</motion.div>
// ↓ Clicked, sharing the same layoutId
<motion.div layoutId="design-button">
  <input placeholder="Describe your design..." />
</motion.div>
```

For native implementation, refer to https://aerotwist.com/blog/flip-your-animations/

### 4.2 "Breathing" Expansion (width → height)

Panel expansion is **not pulling width and height simultaneously**, but rather:
- First 40% of time: only stretch width (keeping height small)
- Last 60% of time: maintain width, expand height

This simulates the physical sensation of "unfolding first, then filling with water."

```js
const widthT = interpolate(t, [0, 0.4], [0, 1], Easing.expoOut);
const heightT = interpolate(t, [0.3, 1], [0, 1], Easing.expoOut);
style.width = `${widthT * targetW}px`;
style.height = `${heightT * targetH}px`;
```

### 4.3 Staggered Fade-up (30ms stagger)

When table rows, card columns, or list items enter, **stagger each element by 30ms**, with `translateY` returning from 10px to 0.

```js
rows.forEach((row, i) => {
  const localT = Math.max(0, t - i * 0.03);  // 30ms stagger
  row.style.opacity = interpolate(localT, [0, 0.3], [0, 1], Easing.expoOut);
  row.style.transform = `translateY(${
    interpolate(localT, [0, 0.3], [10, 0], Easing.expoOut)
  }px)`;
});
```

### 4.4 Non-Linear Pause · Hover for 0.5s Before Key Results

Machines execute quickly and continuously, but **hovering for 0.5 seconds before key results appear** gives the viewer's brain time to react.

```jsx
// Typical scenario: AI finishes generation → Hover for 0.5s → Result appears
<Sprite start={8} end={8.5}>
  {/* 0.5s pause — nothing moves, keeping the viewer's focus on the loading state */}
  <LoadingState />
</Sprite>
<Sprite start={8.5} end={10}>
  <ResultAppear />
</Sprite>
```

**Counter-example**: Cutting seamlessly to the result as soon as AI generation completes — the audience gets no reaction time, leading to information loss.

### 4.5 Chunk Reveal · Simulating Streaming Tokens

When AI generates text, **do not pop up character-by-character using `setInterval`** (like old movie subtitles). Use **chunk reveal** instead — revealing 2-5 characters at a time with irregular intervals, simulating real streaming token output.

```js
// Split by chunks instead of characters
const chunks = text.split(/(\s+|,\s*|\.\s*|;\s*)/);  // Split by word + punctuation
let i = 0;
function reveal() {
  if (i >= chunks.length) return;
  element.textContent += chunks[i++];
  const delay = 40 + Math.random() * 80;  // Irregular 40-120ms
  setTimeout(reveal, delay);
}
reveal();
```

### 4.6 Anticipation → Action → Follow-through

Three of the 12 Disney principles. Anthropic uses them explicitly:

- **Anticipation**: A small reverse movement before action starts (e.g., button shrinking slightly before popping out).
- **Action**: The primary movement itself.
- **Follow-through**: The residual effect after movement ends (e.g., card bouncing slightly after landing).

```js
// Complete three stages of card entry
const anticip = interpolate(t, [0, 0.2], [1, 0.95], Easing.easeIn);     // Anticipation
const action  = interpolate(t, [0.2, 0.7], [0.95, 1.05], Easing.expoOut); // Action
const settle  = interpolate(t, [0.7, 1], [1.05, 1], Easing.spring);       // Settle
// Final scale = product of the three stages or applied segmentally
```

**Counter-example**: Animations that only have Action without Anticipation + Follow-through look like "PowerPoint animations."

### 4.7 3D Perspective + translateZ Layering

To achieve a "tilted 3D + floating card" style, add perspective to the container and different translateZ values to individual elements:

```css
.stage-wrap {
  perspective: 2400px;
  perspective-origin: 50% 30%;  /* Viewer's line of sight is slightly downward */
}
.card-grid {
  transform-style: preserve-3d;
  transform: rotateX(8deg) rotateY(-4deg);  /* Golden ratio */
}
.card:nth-child(3n) { transform: translateZ(30px); }
.card:nth-child(5n) { transform: translateZ(-20px); }
.card:nth-child(7n) { transform: translateZ(60px); }
```

**Why rotateX 8° / rotateY -4° is the golden ratio**:
- Greater than 10° → Element distortion is too strong, making them look like they are "falling over".
- Less than 5° → Looks like a "shear" rather than "perspective".
- The asymmetric ratio of 8° × -4° simulates the natural angle of "camera looking down from the top-left of the desk."

### 4.8 Diagonal Pan · Moving XY Simultaneously

Camera movement should not be purely vertical or horizontal; move **XY simultaneously** to simulate diagonal panning:

```js
const panX = Math.sin(flowT * 0.22) * 40;
const panY = Math.sin(flowT * 0.35) * 30;
stage.style.transform = `
  translate(-50%, -50%)
  rotateX(8deg) rotateY(-4deg)
  translate3d(${panX}px, ${panY}px, 0)
`;
```

**Key**: X and Y use different frequencies (0.22 vs 0.35) to avoid regular Lissajous loops.

---

## 5. Scenario Recipes (Three Narrative Templates)

The three videos in the reference material correspond to three product personalities. **Choose the one that best fits your product**; do not mix and match.

### Recipe A · Apple Keynote Dramatic Style (Claude Design Style)

**Best for**: Major version releases, hero animations, visual wow-factor prioritized.
**Rhythm**: Strong Slow-Fast-Boom-Stop curve.
**Easing**: `expoOut` throughout, with a small amount of `overshoot`.
**SFX Density**: High (~0.4/s), with SFX pitch tuned to the scale of the BGM.
**BGM**: IDM / Minimal tech electronic, calm + precise.
**Closure**: Camera rapidly zooms out → drop → Logo morphs → ethereal single note → sudden stop.

### Recipe B · One-Take Tool Style (Claude Code Style)

**Best for**: Developer tools, productivity apps, deep flow scenarios.
**Rhythm**: Continuous, stable flow with no obvious peaks.
**Easing**: `spring` physics + `expoOut`.
**SFX Density**: **0** (editing rhythm is entirely driven by BGM).
**BGM**: Lo-fi Hip-hop / Boom-bap, 85-90 BPM.
**Core Technique**: Key UI actions hit on the transients of the BGM kick/snare — "**music rhythm acts as the interactive sound effects**."

### Recipe C · Office Productivity Narrative Style (Claude for Word Style)

**Best for**: Enterprise software, document/spreadsheet/calendar apps, professional feel prioritized.
**Rhythm**: Multi-scene hard cuts + Dolly In/Out.
**Easing**: `overshoot` (for toggles) + `expoOut` (for panels).
**SFX Density**: Medium (~0.3/s), primarily UI clicks.
**BGM**: Jazzy Instrumental, minor key, 90-95 BPM.
**Core Highlight**: A specific scene must have a "global highlight" — 3D pop-out / floating off the plane.

---

## 6. Pitfalls · Doing This is AI Slop

| Anti-Pattern | Why it's wrong | Correct Practice |
|---|---|---|
| `transition: all 0.3s ease` | `ease` is a relative of linear; all elements move at the same speed | Use `expoOut` + stagger individual elements |
| All entries are `opacity 0→1` | Lacks a sense of motion direction | Pair with `translateY 10→0` + Anticipation |
| Logo fade-in | Lacks a sense of narrative closure | Morph / Converge / Collapse-Expand |
| Linear mouse movement | Subconscious machine feel | Bezier curve + Perlin Noise |
| Subtitles popping up character by character (`setInterval`) | Feels like old movie subtitles | Chunk Reveal, random intervals |
| Key results appear without pausing | Viewer has no reaction time | Pause for 0.5s before displaying results |
| Focus switching only changes opacity | Out-of-focus elements remain sharp | opacity + brightness + **blur** |
| Pure black / Pure white background | Cyberpunk feel / Glare fatigue | Warm-toned neutrals (guided by brand specs) |
| All animations are equally fast | Lacks rhythm | Slow-Fast-Boom-Stop |
| Fade-out ending | Lacks decisiveness | Sudden stop (hold the final frame) |

---

## 7. Self-Check Checklist (60 Seconds Before Animation Delivery)

- [ ] Narrative structure is Slow-Fast-Boom-Stop, not a uniform rhythm?
- [ ] Default easing is `expoOut`, not `easeOut` or `linear`?
- [ ] Toggle / Button pop-up uses `overshoot`?
- [ ] Card / List entries have a 30ms stagger?
- [ ] Key results have a 0.5s pause before appearing?
- [ ] Typing uses Chunk Reveal, not `setInterval` character-by-character?
- [ ] Focus switching includes blur (not just opacity)?
- [ ] Logo is a morph/collapse (Morph), not a fade-in?
- [ ] Background color is not pure black / pure white (warm-toned)?
- [ ] Typography has a serif + sans-serif hierarchy?
- [ ] Ending is a sudden stop, not a fade-out?
- [ ] (If there is a mouse) The mouse path is an arc, not a straight line?
- [ ] SFX density fits the product personality (see Recipes A/B/C)?
- [ ] There is a 6-8dB loudness difference between BGM and SFX? (see `audio-design-rules.md`)

---

## 8. Relationship with Other Reference Files

| Reference | Focus | Relationship |
|---|---|---|
| `animation-pitfalls.md` | Technical Pitfalls (16 items) | "**What not to do**" · The flip side of this file |
| `animations.md` | Stage/Sprite Engine Usage | The basics of **how to write** animations |
| `audio-design-rules.md` | Dual-Track Audio Rules | Rules for **matching audio** with animations |
| `sfx-library.md` | List of 37 SFXs | Sound effects **asset library** |
| `apple-gallery-showcase.md` | Apple Gallery Showcase Style | A case study on a specific motion style |
| **This File** | Forward Motion Design Syntax | "**What you should do**" |

**Invocation Order**:
1. First, check the four questions in Step 3 of SKILL.md (determining narrative role and visual temperature).
2. Once the direction is chosen, read this file to determine the **motion language** (Recipes A/B/C).
3. When writing code, refer to `animations.md` and `animation-pitfalls.md`.
4. When exporting videos, follow `audio-design-rules.md` + `sfx-library.md`.

---

## Appendix · Sources of Reference Materials

- Teardown of Anthropic's official animations: `参考动画/BEST-PRACTICES.md` in the huashu project directory.
- Teardown of Anthropic's audio: `AUDIO-BEST-PRACTICES.md` in the same directory.
- 3 reference videos: `ref-{1,2,3}.mp4` + corresponding `gemini-ref-*.md` / `audio-ref-*.md`.
- **Strict Filtering**: This reference does not include any specific brand color values, font names, or product names.
  Color/font decisions are handled via §1.a Core Asset Protocol or the 20 design philosophies.
