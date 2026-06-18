# Voiceover Pipeline · Voiceover-Driven Animation

> Upgrades the animation workflow from "silent visuals + post-recording voiceover" to "**voiceover first, then drive the visuals using measured audio duration**".
> Applicable: 5-20 min concept explanation videos, tutorial videos, long-form science/knowledge communication.
>
> Use in conjunction with `references/animation-best-practices.md`—this file governs **how to sync the voiceover and visuals**, while `animation-best-practices.md` governs **how each frame moves**.

---

## 🛑 Iron Laws · Must Read Before Writing a Single Line of Code

> **We cannot emphasize this enough: The #1 failure mode of voiceover animation is turning it into a PowerPoint with voiceover.**

### Rule 1 · The entire video is a continuous motion narrative, not a set of independent scenes

PowerPoint consists of 7 slides. What we are making is **a continuous film lasting X minutes**.

**Mindset Shift**:
- ❌ You are not "making content for 7 scenes"
- ✅ You are "making one or a few hero elements perform on screen for X minutes"

**Visual Backbone = One or a few hero elements spanning the entire video**:
- They appear at t=0 and do not leave the screen until the end.
- Each cue triggers a **state change** (position, scale, color, perspective, shape) of the hero element, rather than "switching to a new element".
- Scene boundaries exist in the script, **but should not exist in the visuals**—the audience should not perceive "this is the 3rd scene"; they should only see continuous motion.

**Negative Example (V1 Real-world Pitfall of this Skill · 2026-05-10)**:
- 7 independent `<Scene>` layouts, where scene transitions = page-wide opacity 1→0 fading into the next page.
- Each cue = `opacity: p, transform: translateY((1-p)*30px)` (monotonous use of fade-up).
- Result: The audience's first reaction is "it feels like Keynote slides," destroying the cinematic quality of the video.

**Correct Pattern**:
- Select 1-2 hero elements (e.g., in the demo of this article, select the two characters "md" and "html" as the backbone).
- These two characters remain on screen **from start to finish**.
- Each "scene" is actually a state transition of these hero elements:
  - opening: The two characters confront each other in the center of the screen.
  - md-side: md scales up and becomes bold, dominating the screen, while html retreats to the corner as small text; data flows in around md.
  - html-side: html becomes the main character; md retreats to the corner.
  - the-real-question: Both characters return to the center, but separated by a "≠" sign in between.
  - the-split: Both characters push outwards to the sides, expanding the negative space in between.
  - activity-proof: The two characters alternate flashing along the timeline.
  - closing: The two characters land in their final answer positions.
- Thus, the entire video is about "md and html performing on screen for X minutes," not 7 independent PPT slides.

**Minimal Implementation Backbone (Copy and modify directly)**:

```jsx
// ── Step 1: Define the target state of the hero in each scene (position/scale/opacity) ──
const HERO_KEYS = {
  opening:    { md: { x: 50, y: 35, scale: 1.0, opacity: 1 }, html: { x: 50, y: 65, scale: 1.0, opacity: 1 } },
  'md-side':  { md: { x: 78, y: 50, scale: 1.6, opacity: 1 }, html: { x: 92, y: 8,  scale: 0.25, opacity: 0.4 } },
  'html-side':{ md: { x: 8,  y: 8,  scale: 0.25, opacity: 0.4 }, html: { x: 22, y: 50, scale: 1.6, opacity: 1 } },
  // ... One entry per scene; continuous motion transitions from the previous scene's final state to the current scene's start state
};

// ── Step 2: Easing & Lerp Utilities ──
const expoOut = t => t === 1 ? 1 : 1 - Math.pow(2, -10 * t);
const lerp = (a, b, t) => a + (b - a) * t;
const lerpPos = (from, to, t) => ({
  x: lerp(from.x, to.x, t), y: lerp(from.y, to.y, t),
  scale: lerp(from.scale, to.scale, t),
  opacity: lerp(from.opacity ?? 1, to.opacity ?? 1, t),
});

// ── Step 3: HeroAnchor Component — Mount directly as a child of <NarrationStage>, do not place inside <Scene> ──
const HeroAnchor = () => {
  const { time, scene, timeline } = useNarration();
  if (!scene) return null;
  const idx = timeline.scenes.findIndex(s => s.id === scene.id);
  const prevId = idx > 0 ? timeline.scenes[idx - 1].id : scene.id;
  const from = HERO_KEYS[prevId];
  const to   = HERO_KEYS[scene.id];

  // The first ~45% of the scene duration is used to morph from the prev state to the current state, and the rest is held.
  const transitionDur = Math.min(2.0, scene.duration * 0.45);
  const t = expoOut(Math.min(1, (time - scene.start) / transitionDur));
  const md   = lerpPos(from.md,   to.md,   t);
  const html = lerpPos(from.html, to.html, t);

  // Add a subtle breathing effect so every frame has motion (aligning with Iron Law #3)
  const breath = 1 + Math.sin(time * 0.6) * 0.012;

  const renderHero = (label, pos, color) => (
    <div style={{
      position: 'absolute', left: `${pos.x}%`, top: `${pos.y}%`,
      transform: `translate(-50%, -50%) scale(${pos.scale * breath})`,
      opacity: pos.opacity, color, fontSize: 360, fontWeight: 800,
      lineHeight: 1, willChange: 'transform, opacity', pointerEvents: 'none',
    }}>{label}</div>
  );
  return <>
    {renderHero('md',   md,   '#1B4965')}
    {renderHero('html', html, '#C04A1A')}
  </>;
};

// ── Step 4: Main Component — Hero is a child of NarrationStage; auxiliary elements within the scene are managed separately ──
const App = () => (
  <NarrationStage timeline={TIMELINE} audioSrc="_narration/voiceover.mp3" width={1920} height={1080}>
    <HeroAnchor />  {/* ← Persists across scenes, acting as the visual backbone of the entire video */}
    {/* Use useSceneFade to soft-fade auxiliary elements within the scene; do not cut abruptly */}
    <MdSideAux />
    <HtmlSideAux />
    {/* ... */}
  </NarrationStage>
);
```

**Complete runnable reference**: `demos/md-html-narration/md-html-demo.html` (3 min 21 s, 7 scenes, 21 cues, verified in production)

### Rule 2 · No Hard Cuts Between Scenes

| Incorrect Pattern (PowerPoint slop) | Correct Pattern (Cinematic Feel) |
|---|---|
| Scene A's overall `opacity 1→0` while scene B's `opacity 0→1` | Core elements of scene A **morph into** scene B (smooth transitions in position/scale/color) |
| Each scene has an independent layout where elements appear/disappear | Elements **persist** on screen, with only their position and form changing |
| `keepMounted=false`, component unmounts at the moment of scene transition | Hero uses `keepMounted=true`, sharing DOM nodes across scenes |
| Subtitle bars and data cards fade in and out independently | The subtitle bar enters as the only non-hero element, holds, and then **exits in sync with the hero's motion** |

Implementation level:
- **Share elements across scenes** -> Hoist the hero to be a direct child of `<NarrationStage>`, **do not place it inside any `<Scene>`**
- Use the `useNarration()` hook in the hero element to read `time`, `scene`, and `isCueTriggered`, and determine its form based on the current time.
- `<Scene>` should only manage auxiliary elements (data cards, quote blocks, etc.) that appear only in that specific scene. Furthermore, **do not hard-cut these auxiliary elements** either—use `expoOut` + stagger for entry, and fade overlap to blend their exit with the next scene.

### Rule 3 · Every Frame Must Have Motion

**Self-Check Method**: Take a screenshot of **any single frame** during recording (not just at the exact second a cue is triggered).
- If the visual looks **completely static** -> Wrong. Go back and add underlying motion (background drift / hero subtle scale / camera pan / parallax).
- There must always be an **underlying motion** running (even if it's not the focal point):
  - A 5-second breathing cycle of the hero element's `scale: 1 ↔ 1.02`
  - Slow drift of the background `translateX: 0 ↔ -20px`
  - A subtle jitter (Perlin noise) in the `translateY` of data cards after they enter
- A completely static frame = PowerPoint slop

### Rule 4 · Easing / Stagger / Hold are the Baseline

| Aspect | Required | Forbidden |
|---|---|---|
| Easing | `expoOut` for the main motion (`cubic-bezier(0.16, 1, 0.3, 1)`), `overshoot` for emphasis, `spring` for landing | `linear`, `ease`, CSS defaults |
| Multi-element Entry | 30ms stagger (each enters 30ms later than the previous) | Simultaneous abrupt appearance of all elements |
| Before Key Cues | Hold for 0.3-0.5s to let the audience "see" (previous elements settle for 0.3s before the cue triggers) | Seamless cut to the next section right after narration ends |
| Outro | Abrupt end, holding the final frame for 1s | Fade to black |

For detailed rules, refer to §1-§4 of `animation-best-practices.md`.

### Self-Check · First-Audience Reaction

Once completed, show it to someone who hasn't seen it (or look at it yourself 24 hours later). What is **their first reaction**?

| Reaction | Rating | Action |
|---|---|---|
| "This is a PowerPoint with voiceover" | Fail | Go back and redo it |
| "The visuals are just switching along with the audio" | Poor | Lacks continuous narrative; hero elements are absent or don't span the entire video |
| "This thing is moving" | Pass | But lacks memorable highlights |
| "I want to watch till the end" | Good | The pacing is correct |
| "I want to screenshot this part" | Great | You nailed it |

---

## Workflow (High-Level)

```
                ┌──────────────────────────┐
                │  Script .md (## scene +  │
                │  [[cue:xx]] marking key  │
                │  sentences)              │
                └──────────────┬───────────┘
                               │
                  narrate-pipeline.mjs
                               │
                               ▼
            ┌──────────────────────────────┐
            │ voiceover.mp3 (Concatenated  │
            │ full track)                  │
            │ timeline.json (Measured      │
            │ durations)                   │
            └──────────────┬───────────────┘
                           │
               ┌────────────┴────────────┐
               ▼                         ▼
     ┌─────────────────┐      ┌──────────────────┐
     │ HTML Animation  │      │ Record MP4 + Mix │
     │ (NarrationStage)│      │ render-narration │
     │ Real-time       │      │ → Final Release  │
     │ playback synced │      │   MP4            │
     │ with audio      │      │                  │
     └─────────────────┘      └──────────────────┘
        Deliverable 1            Deliverable 2
```

## Script Format

Can be placed anywhere in the project directory, suggested filename is `script.md`:

```markdown
---
title: What is LLM
voice: S_JSdgdWk22   # Optional, overrides default voice in .env
speed: 1.0           # Optional, 0.5-2.0
gap: 0.4             # Silences between sections in seconds, default is 0.3
---

## intro
Hello everyone, today we will explain what an LLM is in 5 minutes.

## what-is
LLM stands for Large Language Model. [[cue:bigmodel]]It is a neural network with hundreds of billions of parameters.
In essence, it is a text-completion predictor.

## demo
For example, if you input "today's weather is", [[cue:input]]the model will predict what the next word is most likely to be.
[[cue:predict]]Maybe "great", maybe "not bad".
```

**Rules**:
- Scene titles `## scene-id` must consist of English letters/numbers + hyphens (e.g., `## what-is`, `## scene-1`).
- `[[cue:xx]]` are placed **in the middle of key sentences**—the script splits the text at this position when running, and the moment right after the cue is the visual trigger point.
- Cue IDs are listened to using `<Cue id="xx">` in the animation HTML.
- When writing scripts, **focus on pacing and short sentences**; long sentences will sound flat when generated via TTS.

## timeline.json Schema

```ts
{
  title: string,
  voice: string | null,
  speed: number,
  gap: number,
  totalDuration: number,        // Measured duration of the entire voiceover.mp3 in seconds
  voiceover: 'voiceover.mp3',   // Path relative to timeline.json
  scenes: [
    {
      id: string,
      start: number,            // Start time of this scene in the entire audio track
      end: number,
      duration: number,
      audio: 'audio/<id>.mp3',  // Individual audio for this scene (sub-segments before merging are concatenated)
      text: string,             // Full text of the scene with [[cue:xx]] markers stripped
      // chunks are the sources for subtitles—each chunk is a sub-segment cut by cues, containing the measured TTS time window
      chunks: [
        {
          text: string,            // Sub-segment text
          start: number,           // Relative start time within the scene
          end: number,
          absoluteStart: number,   // Absolute start time on the entire track (aligned with voiceover.mp3)
          absoluteEnd: number,
        }
      ],
      cues: [
        {
          id: string,
          offset: number,       // Relative time offset within the scene
          absoluteTime: number, // Absolute timestamp on the entire track timeline
        }
      ]
    }
  ]
}
```

`absoluteTime` and `absoluteStart/End` are all **actually measured**—the pipeline splits the scene's text into sub-segments by cues and generates TTS for each individually. The time is calculated by accumulating the measured durations of preceding sub-segments, **not a linear estimation approximated by character count**.

## Subtitles

> **Subtitles are included by default**—without subtitles, long explanation videos will suffer from a significant drop in audience retention. `NarrationStage` provides `<Subtitles />` out of the box.

### Usage (One Liner)

```jsx
const { NarrationStage, Subtitles } = NarrationStageLib;
<NarrationStage timeline={TIMELINE} audioSrc="...">
  {/* Your hero / scene content */}
  <Subtitles />  {/* ← Automatically retrieves active text from timeline.scenes[].chunks */}
</NarrationStage>
```

### Visual Rules (Bilibili Style · Anti-PowerPoint)

| Aspect | Rule | Negative Example |
|---|---|---|
| Background | **No background** (do not use black bars or backdrop-blur) | Semi-transparent black background + blur = subtitle bar overlaying/cluttering the visuals = PPT-like feel |
| Text Color | **Deep ink `#1a1a1a` + white glow** for light backgrounds; white text + black glow for dark backgrounds | White text + black stroke on light backgrounds = blurry text |
| Font Size | 32px (for 1080p video) | <24px is illegible, >40px dominates the primary visuals |
| Font Family | `PingFang SC` / `Noto Sans SC` (sans-serif, standard for Bilibili) | Serif fonts = looks like movie subtitles |
| Position | bottom: 90px (not flush with edge) | Being flush with the bottom edge looks cheap |
| Single Line Length | **≤ 12-13 characters** (in Chinese/English mixed text, count English as 0.5 characters for visual width) | >15 characters per line cannot be finished reading on mobile screens |
| Sentence-Splitting | **Never truncate across a period**: Split by strong punctuation `。！？` first, then combine segments using weak punctuation `，、；：` up to ≤maxLen | Hard truncation by character count, e.g., cutting "This is good" into "This is go" + "od" |

`<Subtitles />` runs by default according to the above rules, no props needed. For dark backgrounds: `<Subtitles color="#fff" haloColor="rgba(0,0,0,0.85)" />`.

### Sentence-Splitting Algorithm (Built into narration_stage.jsx)

```js
splitChunkToLines(text, maxLen = 13)
// 1. Split sentences by strong punctuation (。！？\n)
// 2. Keep sentences directly if they are ≤ maxLen
// 3. Otherwise, split by weak punctuation (，、；：) and merge segments up to ≤ maxLen
// 4. Fallback to hard truncation (rare)
// Mixed Chinese/English: English/numbers count as 0.5 characters for visual width estimation
```

If a line is obviously too long or too short after chunk splitting, **change the cue position in the script** (the cue will split the segment into finer chunks), rather than tweaking the splitting logic in the frontend.

## NarrationStage API

```jsx
import 'assets/narration_stage.jsx';
const { NarrationStage, Scene, Cue, useNarration } = NarrationStageLib;

<NarrationStage
  timeline={TIMELINE}                  // timeline.json contents
  audioSrc="_narration/voiceover.mp3"  // Path relative to the current HTML
  width={1920} height={1080}
  background="#f5f1e8"
  controls={true}                      // Show the bottom playback controls during real-time playback
>
  {/* hero element: persists across scenes — placed directly as a child of NarrationStage */}
  <HeroAnchor />

  {/* Auxiliary elements within the scene: appear only in this scene */}
  <Scene id="intro">
    <Cue id="bigmodel">{(triggered, progress) => (
      <SomeElement style={{ opacity: progress }} />
    )}</Cue>
  </Scene>
</NarrationStage>
```

**Hooks**:
- `useNarration()` returns `{ time, scene, sceneTime, isCueTriggered, cueProgress }`
- Read directly inside custom components, no need to pass them as props

**Scene Component**:
- Mounted by default only when `scene.id === id`
- Add `keepMounted` to keep it mounted (used for continuous animations across scenes)

**Cue Component**:
- children must be `(triggered, progress) => ReactNode`
- progress is a gradual value from 0 to 1 after the cue is triggered (default 0.6s ramp)

## Time Source (Dual-Track)

NarrationStage automatically detects `window.__recording`:
- **Real-time Playback Mode** (default): Follows the `currentTime` of the audio element; synchronized even when the user pauses, drags, or seeks.
- **Video Recording Mode** (when `render-video.js` sets `window.__recording = true`): Self-driven by rAF wall-clock starting from 0, exposing `window.__seek(t)` to `render-video.js` for resetting.

## Scripts

| Script | Input | Output |
|---|---|---|
| `scripts/tts-doubao.mjs` | Single text segment | Single mp3 + measured duration |
| `scripts/narrate-pipeline.mjs` | Script .md | voiceover.mp3 + timeline.json |
| `scripts/mix-voiceover.sh` | Video + voiceover.mp3 [+ BGM] | MP4 with audio |
| `scripts/render-narration.sh` | Animation HTML + timeline.json | Final MP4 (all-in-one recording + mixing) |

## .env Configuration

.env at the root of the skill directory (already added to gitignore):

```
DOUBAO_TTS_API_KEY=<your_key>
DOUBAO_TTS_VOICE_ID=<your_clone_voice_id>
DOUBAO_TTS_CLUSTER=volcano_icl
DOUBAO_TTS_ENDPOINT=https://openspeech.bytedance.com/api/v1/tts
```

Refer to the `.env.example` template. The Doubao voice clone voice ID can be obtained from the Volcano Engine console.

## Standard Workflow (10 Steps)

1. **Write the Script**: The script is the source code. Write the entire spoken narration first, mark section headers with `## scene-id`, and add `[[cue:xx]]` before key sentences.
2. **Run narrate-pipeline**: `node scripts/narrate-pipeline.mjs --script script.md --out-dir _narration`
3. **Listen to the full voiceover.mp3**: If the pacing is off, go back and revise the script. **This step determines the quality ceiling of the entire video**.
4. **🛑 Address the Iron Laws before designing**: What is the hero element? What is its state in each scene? How does it morph across scenes? Do not write any code if you cannot answer these questions.
5. **Write the Animation HTML**: Use `NarrationStage` + one or a few hero elements performing across scenes.
6. **Real-time Preview**: Open the HTML in a browser, click ▶ Play, and listen to the visuals and voiceover synced in real-time.
7. **First-Audience Self-Check**: Rate your work using the "Self-Check · First-Audience Reaction" table above. If it fails, go back to Step 4 and redo.
8. **Record Video**: `bash scripts/render-narration.sh demo.html --timeline=_narration/timeline.json` (automatically records silent MP4 + mixes in voiceover).
9. **Optional BGM**: Add `--bgm-mood=educational` (or `tech`, `tutorial`, etc.) to `render-narration`.
10. **Delivery**: Browser HTML (for live demonstration) + final MP4 (for publication).

## Troubleshooting

| Issue | Solution |
|---|---|
| TTS API Error | Check if `DOUBAO_TTS_API_KEY` in `.env` is correct |
| A certain audio segment is obviously longer/shorter than the script | The text contains strange punctuation or emojis, causing a TTS parsing anomaly -> Revise the script |
| Inaccurate `cue absoluteTime` | Issues with ffmpeg during sub-segment concatenation within a scene -> Check mp3 encoding consistency |
| Black screen in the recorded video output | `render-video.js` did not receive the `window.__ready` signal -> Check if `NarrationStage` is mounted properly |
| Lag/stuttering in recorded video frames | Heavy layout operations in animation (excessive box-shadow or blur) -> Simplify or pre-compose |
| Audio/visual out of sync during real-time playback | Delay in loading the audio element -> Add `preload="auto"` or preload locally |

## When Not to Use This Pipeline

- **Short animations <60s**: Simply make silent animations + post-recording voiceover (`add-music.sh` + a single TTS segment), no timeline drive required.
- **BGM-only videos**: Use `add-music.sh` to add preset BGM.
- **Replacing TTS with human voiceovers**: Replace `voiceover.mp3` with human voice recordings, and manually write `timeline.json` or use `ffprobe` to measure segment durations + generate it with a helper script -> The rest of the workflow remains the same.

---

**One last reminder**: Go back to the Iron Laws before writing code. **Do not make a PowerPoint with voiceover**.
