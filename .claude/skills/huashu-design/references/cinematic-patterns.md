# Cinematic Patterns · Best Practices for Workflow Demos

> 5 key patterns to upgrade from "PPT animations" to "launch-event-level cinematic" demos.
> Distilled from two cinematic demos (Nuwa workflow + Darwin workflow) in the April 2026 "Let's Talk Skills" deck; proven and reproducible.

---

## 0 · What This Document Resolves

When you need to create a "demo animation demonstrating a workflow" (typical scenarios: skill workflows, product onboarding, API call flows, agent task execution), there are two common approaches:

| Paradigm | What it Looks Like | Consequence |
|---|---|---|
| **PPT Animation** (Bad) | step 1 fade in → step 2 fade in → step 3 fade in, with 4 boxes displayed on screen together | The audience feels it's "just a PPT with fade effects" — no wow moment |
| **Cinematic** (Good) | Scene-based, focusing on only one thing at a time, with dissolve / focus pull / morph transitions between scenes | The audience feels like "this is a clip from a product launch event" and will want to take screenshots to share |

The root of the difference is **not the animation technology**, but the **narrative paradigm**. This document explains how to upgrade from the former to the latter.

---

## 1 · Five Core Patterns

### Pattern A · Dual-Layer Structure: Dashboard + Cinematic Overlay

**Problem**: A pure cinematic defaults to a black screen + a ▶ play button. If the user scrolls to this page and does not click it, they see nothing.

**Solution**:
```
DEFAULT State (Always Visible): Full static workflow dashboard
  └── Audience sees at a glance how this skill / workflow runs

POINT ▶ Trigger (Overlay pops up): 22-second cinematic
  └── Automatically fades back to DEFAULT after running
```

**Key Implementation Details**:
- `.dash` is visible by default; `.cinema` defaults to `opacity: 0; pointer-events: none`.
- The `.play-cta` is a small gold button in the bottom-right corner (not a massive center overlay).
- Click → `cinema.classList.add('show')` + `dash.classList.add('hide')`.
- Run once with `requestAnimationFrame` (not a loop), and call `endCinematic()` to reverse the state when finished.
- **Anti-pattern**: Default = a giant play ▶ overlay in the center covering everything; the page is blank before clicking.

---

### Pattern B · Scene-based, NOT Step-based

**Problem**: Splitting the animation into "show step 1 → show step 2 → ..." is a PPT mindset.

**Solution**: Split it into 5 scenes. Each scene is an **independent camera shot**, with the full screen focusing on only one thing at a time:

| Scene Type | Responsibility | Duration |
|---|---|---|
| 1 · Invoke | Triggered by user input (terminal typewriter effect) | 3-4s |
| 2 · Process | Visualization of the core workflow (unique visual language) | 5-6s |
| 3 · Result/Insight | Key extracted deliverables (visualization) | 4-5s |
| 4 · Output | Display of the actual output (file / diff / numbers) | 3-4s |
| 5 · Hero Reveal | Wrap-up hero moment (large typography + value proposition) | 4-5s |

**Total Duration ≈ 22 seconds** — This is the proven golden length:
- Shorter than 18 seconds: The PM finishes watching before even getting into the context.
- Longer than 25 seconds: They lose patience.
- 22 seconds is just right to "hook → unfold → resolve → leave a lasting impression."

**Key Implementation Details**:
- Global timeline: `T = { DURATION: 22.0, s1_in: [0, 0.7], s2_in: [3.8, 4.6], ... }`.
- Use a single `requestAnimationFrame(render)` to compute the opacity/transform for all scenes.
- Do not use `setTimeout` chains (they break easily and are hard to debug).
- Easing must use `expoOut` / `easeOut` / cubic-bezier; **linear is strictly forbidden**.

---

### Pattern C · Each Demo Must Have a Unique Visual Language

**Problem**: After finishing the first cinematic, copy-pasting the same template for the second one (using the same orbit + pentagon + typewriter + large hero typography) and only changing the text.

**Consequence**: The audience notices that the two skills "look identical," which essentially communicates that "there is no difference between these two skills."

**Solution**: Since the core metaphor of each workflow is different, their visual languages must also be distinct.

**Comparison Case Study**:

| Dimension | Nuwa (Distillation) | Darwin (Skill Optimization) |
|---|---|---|
| Core Metaphor | Collect → Distill → Write | Loop → Evaluate → Ratchet |
| Visual Motion | Floating / Radiating / Pentagon | Cycling / Ascending / Contrast |
| Scene 2 | 3D Orbit · 8 archives floating on a perspective ellipse | Spin Loop · Tokens travel 5 laps along a 6-node ring |
| Scene 3 | Pentagon · 5 tokens radiating from the center | v1 vs v5 · Side-by-side diff (Red version vs. Gold version) |
| Scene 4 | SKILL.md typewriter effect | Hill-Climb · Full-screen curve plotting |
| Scene 5 Hero | "21 Minutes" in large serif italic typography | Rotating gears ⚙ + "KEPT +1.1" gold tag |

**Evaluation Criterion**: If you cover up the text and look only at the visuals, can you distinguish which demo is which? If not, you got lazy.

---

### Pattern D · Use AI-Generated Real Assets, Not Emojis or Hand-Drawn SVGs

**Problem**: In a 3D orbit / gallery where floating asset fragments are required, emojis (📚🎤) look cheap and unbranded, and hand-drawn SVG book spines never look like real books.

**Solution**: Use `huashu-gpt-image` to generate a large 4×2 grid image (8 theme-related items · white background · 60px breathing space · unified style), and use `extract_grid.py --mode bbox` to crop them into 8 individual transparent PNGs.

**Key Prompt Guidelines** (see the `huashu-gpt-image` skill for detailed prompt patterns):
- IP anchoring (e.g., "1960s Caltech archive aesthetic" or "Hearthstone-style consistent treatment").
- White background (crucial for clean cropping; gray backgrounds have good atmosphere but make extracting transparent backgrounds very difficult).
- 4×2 grid instead of 5×5 (prevents the last-row compression bug).
- Persona finishing (e.g., "You are a Wired magazine curator preparing an exhibition photo").

**Anti-pattern**: Using emojis as icons or using CSS silhouettes instead of actual product graphics.

---

### Pattern E · Dual-Track Audio: BGM + SFX

**Problem**: Having animations without sound makes the audience subconsciously perceive it as a "cheap, low-budget demo."

**Solution**: A continuous background music (BGM) track + 11 sound effects (SFX) cues.

**Universal SFX Cue Recipe** (applicable to workflow demos):

| Timing | SFX | Trigger Scenario |
|---|---|---|
| 0.10s | Whoosh | Terminal slides up from the bottom |
| 3.0s | Enter | Typewriter completes, pressing enter |
| 4.0s | Slide-in | Scene 2 elements enter |
| 5-9s × 5 times | Sparkle | Key process milestones (each generation / each token / each data point) |
| 14s | Click | Switch to the output scene |
| 17.8s | Logo-reveal | Hero reveal moment |
| Typewriter | Type | Triggered once every 2 characters (keep density reasonable) |

**Frequency Separation**: BGM volume at 0.32 (low-frequency ambient noise floor), SFX volume at 0.55 (mid-to-high frequency punch), sparkle at 0.7 (needs to stand out), and logo-reveal at 0.85 (the strongest hero moment).

**User Control**:
- A play ▶ initiation overlay is required (due to browser autoplay restrictions).
- A small mute button in the top-right corner (allowing the user to mute at any time).
- Never implement auto-play on scrolling to the page.

---

## 2 · Key Design Points for the Static Dashboard

The Dashboard is Layer 1 of the dual-layer structure. Even if a PM doesn't click ▶, they should still be able to understand the skill.

**Layout**: 3-column grid (or 1 large + 2 small), with each panel addressing a specific question:

| Panel Type | Question Addressed | Examples |
|---|---|---|
| **Pipeline / Flow Diagram** | "What is the workflow of this skill?" | Nuwa 4-stage pipeline · Darwin auto-research loop |
| **Snapshot / State** | "What does the actual generated data look like?" | Darwin 8-dimensional rubric snapshot |
| **Trajectory / Evolution** | "How does it change over multiple runs?" | Darwin 5-generation hill-climb curve |
| **Examples / Gallery** | "What has already been produced?" | Nuwa 21 personas gallery |
| **Strip · Example I/O** | "Input what → Output what" | Nuwa example strip: `› nuwa distill feynman → feynman.skill (21 min)` |

**Critical Constraints**:
- Information density must be high enough (each panel should carry distinct information).
- Avoid data slop (every number must have a clear purpose).
- Colors must be consistent with the cinematic overlay (using the same color palette to make transitions seamless and natural).

---

## 3 · Debugging and Development Tools

Any long animation must be equipped with three development tools, otherwise debugging will be a nightmare.

### Tool 1 · `?seek=N` Freeze at the N-th Second

```js
const seek = parseFloat(params.get('seek'));
if (!isNaN(seek)) {
  started = true; muted = true;
  frozenT = seek;  // render() uses this t instead of elapsed
  cinema.classList.add('show'); dash.classList.add('hide');
}

// In render():
let t = frozenT !== null ? frozenT : (elapsed % T.DURATION);
```

Usage: Navigate directly to `http://.../slide.html?seek=12` to inspect the frame at exactly the 12th second, without waiting for playback.

### Tool 2 · `?autoplay=1` Skip the ▶ Overlay

Convenient for automated Playwright screenshot testing, and also for forcing start when embedded in an iframe.

### Tool 3 · Manual REPLAY Button

A small button in the top-right corner that allows the user or developer to replay the animation as many times as needed. CSS:

```css
.replay{position:absolute;top:18px;right:18px;background:rgba(212,165,116,0.1);
  border:1px solid rgba(212,165,116,0.3);color:#D4A574;
  font-family:monospace;font-size:10px;letter-spacing:.28em;text-transform:uppercase;
  padding:6px 12px;border-radius:1px;cursor:pointer;backdrop-filter:blur(6px);z-index:6}
```

---

## 4 · Pitfalls of iframe Embedding (If Cinematic is Embedded in a Deck)

### Pitfall 1 · Click Zone in the Parent Window Intercepts Buttons Inside the iframe

If the deck's `index.html` has "left/right 22vw transparent click zones for page flipping" enabled, it will **overlap the ▶ play button inside the iframe** — clicking the button gets swallowed and interpreted as "next page."

**Fix**: Add `top: 12vh; bottom: 25vh` to the click zones, leaving the top and bottom 25% non-intercepted so that both the center ▶ and bottom-right ▶ inside the iframe remain clickable.

### Pitfall 2 · Keyboard Events Lost After the iframe Grabs Focus

Once the user clicks inside the iframe, the focus shifts to the iframe, and the parent window stops receiving ←/→ keyboard events.

**Fix**:
```js
iframe.addEventListener('load', () => {
  // Inject keyboard forwarder
  const doc = iframe.contentDocument;
  doc.addEventListener('keydown', (e) => {
    window.dispatchEvent(new KeyboardEvent('keydown', { key: e.key, ... }));
  });
  // Pull focus back to the parent window after click
  doc.addEventListener('click', () => setTimeout(() => window.focus(), 0));
});
```

### Pitfall 3 · Behavioral Differences Between file:// and https://

A cinematic that tests fine locally under `file://` might break after deployment because:
- Under `file://`, the iframe's `contentDocument` is same-origin.
- Under `https://`, it is also same-origin (if on the same host), but audio autoplay restrictions are much stricter.

**Fix**:
- Before deployment, spin up a local HTTP server using `python3 -m http.server` to run a test pass.
- BGM must wait until the user clicks the play button ▶ to call `bgm.play()`; do not play it immediately on page load.

---

## 5 · Anti-Pattern Quick Reference

| ❌ Anti-Pattern | ✅ Correct Pattern |
|---|---|
| Default = Black screen with a play ▶ overlay | Default = Static dashboard, where the play ▶ button is auxiliary |
| 4 steps aligned horizontally on the same screen fading in | 5 scenes switching full-screen, focusing on only one thing per scene |
| Reusing templates and just changing text for different demos | Each demo has a unique visual language (distinguishable even when text is covered) |
| Emojis / hand-drawn SVGs used as assets | Large grid image via `gpt-image-2` + cropped using `extract_grid` |
| No BGM, no SFX | Dual-track audio with BGM + 11 SFX cues |
| Using `setTimeout` chains for scheduling | Using `requestAnimationFrame` + a global timeline `T` object |
| Linear animations | Expo / cubic-bezier easing |
| No dev tools provided | `?seek=N` + `?autoplay=1` + REPLAY button |
| Buttons inside the iframe swallowed by the parent's click zone | Click zones given top/bottom margins to make way for the buttons |

---

## 6 · Time Budget

According to these patterns, a complete cinematic demo (including the dashboard) requires:

| Task | Time |
|---|---|
| Design the 5-scene narrative + visual language | 30 mins (take this seriously as it determines uniqueness) |
| Dashboard static layout + content | 1 hour |
| Cinematic 5 scenes implementation | 1.5 hours |
| Audio cues timing adjustment + replay button | 30 mins |
| Verify 5 key frames via Playwright screenshots | 15 mins |
| **Total per demo** | **3-4 hours** |

The second demo can reuse the framework, but **its visual language must be independent**, taking approximately 2-3 hours.
