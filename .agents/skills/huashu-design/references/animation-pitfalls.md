# Animation Pitfalls: Rules and Pitfalls of HTML Animations

The most common bugs encountered when creating animations and how to avoid them. Every rule comes from real-world failure cases.

Reading this guide before writing animations will save you a round of iteration.

## 1. Stacked Layout — `position: relative` is a Default Obligation

**The Pitfall**: A `sentence-wrap` element contained 3 `bracket-layer`s (`position: absolute`). Since `position: relative` was not set on `sentence-wrap`, the absolute brackets used `.canvas` as their coordinate system, drifting 200px outside the bottom of the screen.

**Rules**:
- Any container containing `position: absolute` child elements **must** explicitly set `position: relative`.
- Even if no visual "offset" is needed, `position: relative` must be declared to serve as the coordinate system anchor.
- If you are writing `.parent { ... }` and its child elements include `.child { position: absolute }`, reflexively add `relative` to the parent.

**Quick Check**: Whenever `position: absolute` appears, trace up the ancestors to ensure that the nearest positioned ancestor is the coordinate system you *actually want*.

## 2. Character Pitfalls — Do Not Rely on Rare Unicode Characters

**The Pitfall**: Trying to use `␣` (U+2423 OPEN BOX) to visualize a "space token". Neither Noto Serif SC nor Cormorant Garamond contains this glyph, causing it to render as blank space or a "tofu" character, making it completely invisible to the audience.

**Rules**:
- **Every character appearing in the animation must exist in your selected font.**
- Common rare character blacklist: `␣ ␀ ␐ ␋ ␨ ↩ ⏎ ⌘ ⌥ ⌃ ⇧ ␦ ␖ ␛`
- To represent metacharacters like "space / enter / tab", use a **CSS-constructed semantic box**:
  ```html
  <span class="space-key">Space</span>
  ```
  ```css
  .space-key {
    display: inline-flex;
    padding: 4px 14px;
    border: 1.5px solid var(--accent);
    border-radius: 4px;
    font-family: monospace;
    font-size: 0.3em;
    letter-spacing: 0.2em;
    text-transform: uppercase;
  }
  ```
- Emojis must also be verified: some emojis will fallback to gray boxes in fonts other than Noto Emoji. It is best to use the `emoji` font-family or SVGs.

## 3. Data-Driven Grid/Flex Templates

**The Pitfall**: In the code, `const N = 6` tokens, but the CSS hardcoded `grid-template-columns: 80px repeat(5, 1fr)`. As a result, the 6th token did not have a column, causing the entire matrix to be misaligned.

**Rules**:
- When the count comes from a JS array (`TOKENS.length`), the CSS template should also be data-driven.
- Option A: Inject via CSS variables from JS:
  ```js
  el.style.setProperty('--cols', N);
  ```
  ```css
  .grid { grid-template-columns: 80px repeat(var(--cols), 1fr); }
  ```
- Option B: Use `grid-auto-flow: column` to let the browser expand automatically.
- **Ban the combination of "fixed numbers + JS constants"**; if N changes, the CSS will not update in sync.

## 4. Transition Gaps — Scene Transitions Must Be Continuous

**The Pitfall**: Between zoom1 (13-19s) and zoom2 (19.2-23s), the main sentence was already hidden, leading to zoom1 fade out (0.6s) + zoom2 fade in (0.6s) + stagger delay (0.2s+) = about 1 second of pure blank screen. The audience thought the animation had frozen.

**Rules**:
- When transitioning between scenes continuously, the fade out and fade in must **overlap**, rather than starting the next only after the previous has completely disappeared:
  ```js
  // Bad:
  if (t >= 19) hideZoom('zoom1');      // 19.0s out
  if (t >= 19.4) showZoom('zoom2');    // 19.4s in → 0.4s of blank space in between

  // Good:
  if (t >= 18.6) hideZoom('zoom1');    // Start fade out 0.4s early
  if (t >= 18.6) showZoom('zoom2');    // Fade in simultaneously (cross-fade)
  ```
- Alternatively, use an "anchor element" (such as the main sentence) as a visual bridge between scenes, letting it briefly reappear during the zoom transition.
- Calculate the duration of CSS transitions carefully to prevent the next one from triggering before the current transition finishes.

## 5. Pure Render Principle — Animation States Must Be Seekable

**The Pitfall**: Using `setTimeout` + `fireOnce(key, fn)` to chain-trigger animation states. This works fine during normal playback, but during frame-by-frame recording or when seeking to arbitrary time points, since the previous `setTimeout`s have already run, it is impossible to "go back in time."

**Rules**:
- The `render(t)` function should ideally be a **pure function**: given `t`, it outputs a unique DOM state.
- If side effects (such as class toggling) are unavoidable, use a `fired` set combined with an explicit reset:
  ```js
  const fired = new Set();
  function fireOnce(key, fn) { if (!fired.has(key)) { fired.add(key); fn(); } }
  function reset() { fired.clear(); /* Clear all .show classes */ }
  ```
- Expose `window.__seek(t)` for Playwright / debugging purposes:
  ```js
  window.__seek = (t) => { reset(); render(t); };
  ```
- Do not let animation-related `setTimeout`s span more than 1 second; otherwise, seeking back and forth will cause chaos.

## 6. Measuring Before Fonts Load = Incorrect Measurement

**The Pitfall**: Calling `charRect(idx)` to measure the bracket's position as soon as `DOMContentLoaded` fires. Since the fonts are not yet loaded, each character's width is that of the fallback font, making all positions wrong. Once the fonts load (about 500ms later), the bracket's `left: Xpx` remains at the old value, causing a permanent offset.

**Rules**:
- Any layout code that relies on DOM measurements (`getBoundingClientRect`, `offsetWidth`) **must** be wrapped in `document.fonts.ready.then()`:
  ```js
  document.fonts.ready.then(() => {
    requestAnimationFrame(() => {
      buildBrackets(...);  // Fonts are ready now; measurement is accurate
      tick();              // Animation starts
    });
  });
  ```
- The extra `requestAnimationFrame` gives the browser one frame of time to submit the layout.
- If using Google Fonts CDN, use `<link rel="preconnect">` to speed up the initial load.

## 7. Recording Preparation — Reserving Hooks for Video Export

**The Pitfall**: Playwright's `recordVideo` defaults to 25fps and starts recording as soon as the context is created. The first 2 seconds of page loading and font loading are recorded. Upon delivery, the video begins with 2 seconds of blank space or white flashes.

**Rules**:
- Provide a `render-video.js` tool to handle the process: warmup navigate → reload to restart animation → wait for duration → ffmpeg trim head + transcode to H.264 MP4.
- The **0th frame** of the animation must be the complete initial state with the final layout already in place (not a blank screen or a loading state).
- Want 60fps? Use ffmpeg `minterpolate` post-processing; do not rely on the browser's source frame rate.
- Want a GIF? Use a two-stage palette (`palettegen` + `paletteuse`), which can compress a 30s 1080p animation down to 3MB.

See `video-export.md` for the complete script invocation details.

## 8. Batch Export — The `tmp` Directory Name Must Include PID to Avoid Concurrency Conflicts

**The Pitfall**: Running `render-video.js` with 3 parallel processes to record 3 HTML files. Because `TMP_DIR` was named using only `Date.now()`, the 3 processes started in the exact same millisecond and shared the same tmp directory. The process that finished first cleaned up the tmp directory, causing the other two to throw `ENOENT` when reading the directory, crashing all of them.

**Rules**:
- Any temporary directory that might be shared across multiple processes must include a **PID or a random suffix** in its name:
  ```js
  const TMP_DIR = path.join(DIR, '.video-tmp-' + Date.now() + '-' + process.pid);
  ```
- If you really want parallel processing of multiple files, use the shell's `&` + `wait` rather than forking within a single Node.js script.
- When batch-recording multiple HTML files, the conservative approach is to run them **sequentially** (up to 2 can run in parallel; for 3 or more, queue them up sequentially).

## 9. Progress Bars/Replay Buttons in Recordings — Chrome Elements Polluting the Video

**The Pitfall**: The animation HTML added a `.progress` bar, a `.replay` button, and a `.counter` timestamp to facilitate human debugging of the playback. When recorded into the delivered MP4, these elements appeared at the bottom of the video, making it look as if the developer tools were accidentally screenshotted in.

**Rules**:
- The "chrome elements" designed for humans in the HTML (progress bar / replay button / footer / masthead / counter / phase labels) must be managed separately from the main video content body.
- **Establish a class naming convention** `.no-record`: Any element with this class will be automatically hidden by the recording script.
- The script side (`render-video.js`) injects CSS by default to hide common chrome class names:
  ```
  .progress .counter .phases .replay .masthead .footer .no-record [data-role="chrome"]
  ```
- Inject using Playwright's `addInitScript` (this takes effect before every navigation and remains stable even upon reload).
- Add the `--keep-chrome` flag when you want to view the raw HTML (with the chrome).

## 10. Repeated Animation in the First Few Seconds of Recording — Warmup Frame Leakage

**The Pitfall**: The old workflow of `render-video.js` was `goto → wait fonts 1.5s → reload → wait duration`. Recording started from the moment the context was created, meaning the animation had already played for a bit during the warmup phase before restarting from 0 after the reload. Consequently, the first few seconds of the video contained "mid-animation frames + transition + animation starting from 0", creating a strong sense of repetition.

**Rules**:
- **Warmup and Record must use separate contexts**:
  - Warmup context (without `recordVideo` option): only responsible for loading the URL, waiting for fonts, and then closing.
  - Record context (with `recordVideo` option): starts from a fresh state, recording the animation from t=0.
- ffmpeg `-ss trim` can only crop Playwright's minor startup latency (~0.3s) and **cannot** be used to cover up warmup frames; the source itself must be clean.
- Closing the recording context = writing the WebM file to disk, which is a constraint of Playwright.
- Relevant code pattern:
  ```js
  // Phase 1: warmup (throwaway)
  const warmupCtx = await browser.newContext({ viewport });
  const warmupPage = await warmupCtx.newPage();
  await warmupPage.goto(url, { waitUntil: 'networkidle' });
  await warmupPage.waitForTimeout(1200);
  await warmupCtx.close();

  // Phase 2: record (fresh)
  const recordCtx = await browser.newContext({ viewport, recordVideo });
  const page = await recordCtx.newPage();
  await page.goto(url, { waitUntil: 'networkidle' });
  await page.waitForTimeout(DURATION * 1000);
  await page.close();
  await recordCtx.close();
  ```

## 11. Do Not Draw "Fake Chrome" inside the Canvas — Decorative Player UI Clashing with Actual Chrome

**The Pitfall**: The animation used the `Stage` component, which already includes a built-in scrubber + timecode + pause button (which belong to the `.no-record` chrome and are automatically hidden during export). Feeling good about it, I drew a "magazine page-number-style decorative progress bar" reading `00:60 ──── CLAUDE-DESIGN / ANATOMY` at the bottom of the screen. **Result**: Users saw two progress bars — one was the Stage controller, and the other was the decoration I drew. They clashed completely in visual terms, and it was flagged as a bug: "What is going on with the second progress bar inside the video?"

**Rules**:

- Stage already provides a scrubber + timecode + pause/replay buttons. **Do not draw any more** progress indicators, current timecodes, copyright/attribution bars, or chapter counters inside the screen — they either clash with the chrome or are just filler slop (violating the "earn its place" principle).
- Decorative requests like "page-number feel," "magazine feel," or "attribution bars at the bottom" are high-frequency fillers automatically added by AI. Be alert to every instance — does it truly convey irreplaceable information? Or is it simply filling up empty space?
- If you firmly believe that a bottom bar must exist (for example, the theme of the animation is specifically about a player UI), it must be **narratively essential** and **visually distinguished from the Stage scrubber** (different position, different format, different hue).

**Element Attribution Test** (every element drawn into the canvas must be able to answer):

| What it belongs to | Action |
|------------|------|
| Narrative content of a specific scene/act | OK, keep it |
| Global chrome (for control/debugging) | Add `.no-record` class, hide during export |
| **Neither belongs to any scene, nor is chrome** | **Delete**. This is an unowned element and is bound to be filler slop |

**Self-Check (3 seconds before delivery)**: Take a screenshot and ask yourself:

- Is there anything in the frame that "looks like a video player UI" (such as a horizontal progress bar, a timecode, or control buttons)?
- If yes, does deleting it harm the narrative? If not, delete it.
- Does the same type of information (progress/time/attribution) appear twice? Consolidate it into the chrome.

**Counter-examples**: Drawing `00:42 ──── PROJECT NAME` at the bottom, drawing a "CH 03 / 06" chapter counter in the bottom-right corner, or drawing a version number "v0.3.1" near the edge — all of these are fake chrome filler.

## 12. Pre-recording Blank Frames + Recording Start Point Offset — The `__ready` × tick × lastTick Triple Trap

**The Pitfall (A · Pre-recording Blank Frames)**: A 60-second animation is exported as an MP4, but the first 2-3 seconds are a blank page. This cannot be cropped out with `ffmpeg --trim=0.3`.

**The Pitfall (B · Start Point Offset, a real incident on 2026-04-20)**: Exporting a 24-second video, and users perceived that "the video only started playing its first frame at the 19th second." In reality, the animation started recording at t=5, recorded until t=24, looped back to t=0, and then recorded another 5 seconds to the end — thus the last 5 seconds of the video were the actual start of the animation.

**Root Cause** (both pitfalls share the same root cause):

Playwright's `recordVideo` starts writing WebM from the exact moment `newContext()` is invoked. At this stage, Babel/React/font loading takes a total of L seconds (2-6s). The recording script waits for `window.__ready = true` as the anchor point for "the animation starts here" — which must be strictly paired with the animation's `time = 0`. There are two common incorrect approaches:

| Incorrect Approach | Symptom |
|------|------|
| `__ready` is set during `useEffect` or the synchronous setup phase (before the first frame of `tick`) | The recording script thinks the animation has started, but the WebM is actually still recording a blank page → **Pre-recording Blank Frames** |
| The `tick`'s `lastTick = performance.now()` is initialized at the **top level of the script** | The L seconds of font loading are counted into the first frame's `dt`, causing `time` to jump instantly to L → the entire recording lags by L seconds → **Start Point Offset** |

**✅ Correct and Complete Starter Tick Template** (handcrafted animations must use this skeleton):

```js
// ━━━━━━ state ━━━━━━
let time = 0;
let playing = false;   // ❗ Do not play by default; wait for fonts to be ready before starting
let lastTick = null;   // ❗ Sentinel — dt is forced to 0 during the first frame of tick (do not use performance.now())
const fired = new Set();

// ━━━━━━ tick ━━━━━━
function tick(now) {
  if (lastTick === null) {
    lastTick = now;
    window.__ready = true;   // ✅ Pair: "recording start point" is on the same frame as "animation t=0"
    render(0);               // Render once more to ensure the DOM is ready (fonts are ready at this point)
    requestAnimationFrame(tick);
    return;
  }
  const dt = (now - lastTick) / 1000;   // dt only starts advancing after the first frame
  lastTick = now;

  if (playing) {
    let t = time + dt;
    if (t >= DURATION) {
      t = window.__recording ? DURATION - 0.001 : 0;  // Do not loop during recording; leave 0.001s to preserve the final frame
      if (!window.__recording) fired.clear();
    }
    time = t;
    render(time);
  }
  requestAnimationFrame(tick);
}

// ━━━━━━ boot ━━━━━━
// Do not call rAF immediately at the top level — wait until fonts are loaded to start
document.fonts.ready.then(() => {
  render(0);                 // Render the initial frame first (fonts are ready)
  playing = true;
  requestAnimationFrame(tick);  // The first tick will pair __ready + t=0
});

// ━━━━━━ seek Interface (for defensive calibration by render-video) ━━━━━━
window.__seek = (t) => { fired.clear(); time = t; lastTick = null; render(t); };
```

**Why this template is correct**:

| Part | Why it must be done this way |
|------|-------------|
| `lastTick = null` + first-frame `return` | Prevents the L seconds between script loading and the first execution of `tick` from being counted towards the animation time |
| `playing = false` by default | Even if `tick` runs during font loading, it won't advance `time`, avoiding rendering misalignment |
| `__ready` set in the first frame of `tick` | The recording script starts timing from this moment, and the corresponding screen is the animation's true t=0 |
| Start `tick` only inside `document.fonts.ready.then(...)` | Avoids fallback font width measurements and prevents font layout shifts on the first frame |
| `window.__seek` exists | Allows `render-video.js` to perform active calibration — serving as a second line of defense |

**Corresponding defense on the recording script side**:
1. `addInitScript` injects `window.__recording = true` (prior to `page.goto`).
2. `waitForFunction(() => window.__ready === true)`, recording the offset at this moment to use as the ffmpeg trim.
3. **Extra**: After `__ready`, actively invoke `page.evaluate(() => window.__seek && window.__seek(0))` to force any potential time offset in the HTML back to zero — this is the second line of defense to handle HTML files that do not strictly adhere to the starter template.

**Verification Method**: After exporting the MP4:
```bash
ffmpeg -i video.mp4 -ss 0 -vframes 1 frame-0.png
ffmpeg -i video.mp4 -ss $DURATION-0.1 -vframes 1 frame-end.png
```
The first frame must be the initial state of the animation at t=0 (not in the middle, not black), and the final frame must be the final state of the animation (not some moment in the second loop cycle).

**Reference Implementation**: The `Stage` component in `assets/animations.jsx` and `scripts/render-video.js` are both implemented according to this protocol. Handcrafted HTML must wrap with the starter tick template — every single line has been written to prevent specific bugs.

## 13. Disable Loop When Recording — The `window.__recording` Signal

**The Pitfall**: The animation Stage defaults to `loop=true` (making it convenient to view the effect in a browser). `render-video.js` waits for an additional 300ms buffer after recording the duration seconds before stopping, which allows the Stage to enter the next loop cycle. When ffmpeg `-t DURATION` crops the clip, the final 0.5–1s falls into the next loop cycle — causing the video to abruptly jump back to the first frame (Scene 1) at the end, making the audience think there was a bug in the video.

**Root Cause**: There was no "I am recording" handshake protocol between the recording script and the HTML. The HTML is unaware that it is being recorded, so it continues looping according to the browser interaction scenario.

**Rules**:

1. **Recording Script**: Inject `window.__recording = true` in `addInitScript` (prior to `page.goto`):
   ```js
   await recordCtx.addInitScript(() => { window.__recording = true; });
   ```

2. **Stage Component**: Recognize this signal and force `loop=false`:
   ```js
   const effectiveLoop = (typeof window !== 'undefined' && window.__recording) ? false : loop;
   // ...
   if (next >= duration) return effectiveLoop ? 0 : duration - 0.001;
   //                                                       ↑ Leave 0.001 to prevent Sprite from being closed at end=duration
   ```

3. **fadeOut of the Ending Sprite**: Under recording scenarios, `fadeOut={0}` should be set; otherwise, the end of the video will fade into transparency/darkness — users expect it to freeze on a clear final frame, not fade out. When writing HTML by hand, it is recommended that the ending Sprite uses `fadeOut={0}`.

**Reference Implementation**: The Stage in `assets/animations.jsx` and `scripts/render-video.js` both have the handshake built-in. Handcrafted Stages must implement the `__recording` detection — otherwise, you are bound to run into this pitfall during recording.

**Verification**: After exporting the MP4, run `ffmpeg -ss 19.8 -i video.mp4 -frames:v 1 end.png` and check if it is still the expected final frame 0.2 seconds before the end, without any sudden transition to another scene.

## 14. 60fps Videos Default to Frame Duplication — minterpolate has Poor Compatibility

**The Pitfall**: The 60fps MP4 generated by `convert-formats.sh` using `minterpolate=fps=60:mi_mode=mci...` cannot be opened in certain versions of macOS QuickTime / Safari (showing a black screen or directly refusing to play). VLC and Chrome can open it.

**Root Cause**: The H.264 elementary stream output by minterpolate contains certain SEI / SPS fields that cause parsing issues in some players.

**Rules**:

- By default, use a simple `fps=60` filter (frame duplication) for 60fps, which has broad compatibility (can be opened by QuickTime/Safari/Chrome/VLC).
- Enable high-quality frame interpolation explicitly using the `--minterpolate` flag — but it **must be tested locally** on target players before delivery.
- The value of the 60fps label lies in the **algorithm recognition of upload platforms** (e.g., Bilibili/YouTube prioritize pushing 60fps labeled streams); for CSS animations, the actually perceived improvement in smoothness is minimal.
- Add `-profile:v high -level 4.0` to enhance general H.264 compatibility.

**`convert-formats.sh` has already been updated to compatibility mode by default**. If you need high-quality frame interpolation, add the `--minterpolate` flag:
```bash
bash convert-formats.sh input.mp4 --minterpolate
```

## 15. `file://` + External `.jsx` CORS Pitfall — Single-File Deliverables Must Inline the Engine

**The Pitfall**: Loading the engine externally using `<script type="text/babel" src="animations.jsx"></script>` in the animation HTML. Double-clicking to open locally (via the `file://` protocol) → Babel Standalone fetches the `.jsx` via XHR → Chrome throws `Cross origin requests are only supported for protocol schemes: http, https, chrome, chrome-extension...` → entire screen goes black. It doesn't report `pageerror` but only a console error, which is easily misdiagnosed as "animation not triggered."

Starting an HTTP server might not even save you — if the local machine has a global proxy enabled, `localhost` will also go through the proxy, returning a 502 / connection failure.

**Rules**:

- **Single-File Deliverables (HTML files that run immediately upon double-clicking)** → `animations.jsx` **must be inlined** into the `<script type="text/babel">...</script>` tag; do not use `src="animations.jsx"`.
- **Multi-File Projects (demonstrated by running an HTTP server)** → Can be loaded externally, but specify the `python3 -m http.server 8000` command clearly during delivery.
- Criterion: Is the deliverable to the user an "HTML file" or a "project directory with a server"? The former should use inlining.
- The `Stage` component or `animations.jsx` is often over 200 lines — pasting them into the HTML `<script>` block is completely acceptable, so do not worry about file size.

**Minimum Verification**: Double-click your generated HTML, and **do not** open it via any server. If the Stage correctly displays the initial frame of the animation, only then is it considered passed.

## 16. Cross-Scene Contrast Context — Do Not Hardcode Colors for On-Screen Elements

**The Pitfall**: When creating a multi-scene animation, elements that **appear across multiple scenes** such as `ChapterLabel` / `SceneNumber` / `Watermark` have their colors hardcoded to `color: '#1A1A1A'` (dark text) in the component. While it works fine with the light background in the first 4 scenes, when it transitions to the 5th scene with a dark background, "05" and the watermark disappear entirely — throwing no errors, triggering no checks, and rendering critical information invisible.

**Rules**:

- **On-screen elements reused across multiple scenes** (chapter label / scene number / timecode / watermark / copyright bar) **are forbidden from hardcoding color values**.
- Instead, use one of these three approaches:
  1. **`currentColor` Inheritance**: The element simply declares `color: currentColor`, while the parent scene container specifies `color: computedValue`.
  2. **`invert` prop**: The component accepts `<ChapterLabel invert />` to manually switch between light and dark themes.
  3. **Automatic Calculation Based on Background**: `color: contrast-color(var(--scene-bg))` (a new CSS 4 API, or determined via JS).
- Before delivery, use Playwright to capture **representative frames for each scene** and perform a manual visual sweep to ensure "cross-scene elements" are all visible.

The stealthiness of this pitfall lies in the fact that **it triggers no bug alarms**. Only human eyes or OCR can detect it.

## Quick Self-Check Checklist (5 Seconds Before Starting)

- [ ] Every parent element of a `position: absolute` has `position: relative`?
- [ ] Do all special characters in the animation (`␣`, `⌘`, `emoji`) exist in the font?
- [ ] Do the counts in Grid/Flex templates match the length of the JS data?
- [ ] Is there a cross-fade between scene transitions, without any pure blank frames of >0.3s?
- [ ] Is the DOM measurement code wrapped inside `document.fonts.ready.then()`?
- [ ] Is `render(t)` pure, or does it have an explicit reset mechanism?
- [ ] Is the 0th frame the complete initial state, rather than a blank screen?
- [ ] Are there no "fake chrome" decorations on-screen (such as progress bars, timecodes, or bottom attribution bars clashing with the Stage scrubber)?
- [ ] Is `window.__ready = true` set synchronously on the first frame of the animation tick? (Built into animations.jsx; add manually for handcrafted HTML)
- [ ] Does Stage detect `window.__recording` and force `loop=false`? (Must be added for handcrafted HTML)
- [ ] Is the `fadeOut` of the ending Sprite set to 0 (freezing on a clear frame at the end of the video)?
- [ ] Does the 60fps MP4 default to frame duplication mode (for compatibility), and is `--minterpolate` added only for high-quality frame interpolation?
- [ ] Are the 0th frame and the final frame captured after export to verify the initial/final states of the animation?
- [ ] For specific brands (Stripe/Anthropic/Lovart/...): Have you completed the "Brand Assets Protocol" (SKILL.md §1.a five steps)? Has `brand-spec.md` been written?
- [ ] For single-file HTML deliverables: Is `animations.jsx` inlined instead of using `src="..."`? (External `.jsx` under `file://` will trigger CORS and cause a black screen)
- [ ] Do elements appearing across scenes (chapter label / watermark / scene number) avoid hardcoded colors? Are they visible under the background color of each scene?
