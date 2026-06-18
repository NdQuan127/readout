# Launch Film Workflow: Write the Ten-Thousand-Word Director's Notes First, Then Animate

> Standard workflow for high-spec visual work (≥ 20 seconds, featuring brand narrative, slogan reveal, potentially promoted on X / WeChat Official Account / Bilibili).
>
> Trigger conditions: The task is a "product upgrade promo video / brand launch film / launch trailer / superbowl-tier ad / brand campaign / hero animation video", and **the user has clear quality expectations** (e.g., "Super Bowl quality," "10x details," "Apple-grade").
>
> Anti-trigger: Do not use this workflow for "quick animation demo," "simple motion graphic," or "single icon animation" — it will be over-engineered.

---

## 1. Why Write Director's Notes First

Real-world lesson (from the 2026-05-11 huashu-md-html v2.0 project):

In the first round, we started writing HTML directly. The output was "programmer-perspective animation" — capability showcase evenly paced, constant speed, slogans colliding, lacking a narrative arc.
In the second round, after receiving the user's instruction: "Stop, write a 10,000-word storyboard script from an Apple director's perspective first," we wrote `v5-director-notes.md` (11,500 words, 13-shot shot-by-shot spec), and then implemented it according to the script — done in one shot, every paused frame was visually engaging, and the rhythm had rises and falls with a climax.

**Core difference**: Writing the script is thinking, writing HTML is executing. Once you think it through, execution is just mechanical translation. If you execute first, every shot requires on-the-spot decision-making, which inevitably leads to chaos.

Writing director's notes is not about "pretending"; it is about consolidating all visual decisions into a document **before starting** — visualizing and reasoning through every single shot, and tracing them back to the context. During HTML implementation, there is no need for creative decisions; you only need to translate faithfully.

---

## 2. Trigger Evaluation (Ask Yourself 3 Questions First)

Before initiating the launch film workflow, ask:

1. **Does this film carry a brand narrative?** (Has a thesis / slogan reveal / sense of upgrade ritual) — YES → Go to the director's notes workflow
2. **Will the audience pause to look at it?** (Possible screenshots, X posters, cover images, slow-motion reviews) — YES → Every frame must be visually engaging
3. **Does the client/user have a reference like "I want it to look like XXX"?** (Apple / Anthropic / Nike / Penguin / a specific director) — YES → The visual context must be explicitly defined

If any of these is "YES", use the workflow. If all three are "NO", skip it and use the standard workflow in [animations.md](animations.md) directly.

---

## 3. The 5 Major Components of Director's Notes

A 10,000-word (10,000–12,000 Chinese characters / equivalent English word count) director's notes document must contain these 5 major sections. **If any section is missing, it is incomplete, and the quality will suffer.**

### Part I · Director's Statement (approx. 1500-2000 words)

Answer 5 questions:

1. **What is this film NOT?** (Explicit exclusions — e.g., "This is not a feature introduction video," "not a demo")
2. **Core thesis in one line** — If the audience remembers only one sentence after watching, which one is it?
3. **Conversing with whose context?** — List 5-8 visual references (director / designer / brand / photographer / work title + year), explaining what was learned from each reference
4. **Three types of audience personas + promise to each**: Primary audience / Secondary audience / Tertiary audience, with a paragraph for each
5. **Rhythm philosophy** — Explanation of the curve (slow beats / acceleration / peak / slow decay) + the exact second of the emotional climax (**not necessarily the last second**)

Finally, add an anti-slop checklist: **Things this film will NOT do** (listed specifically, not vaguely).

### Part II · Visual System (Full Visual System Spectrum, approx. 1500-2500 words)

This is the engineered visual spec. Once complete, any executor can produce consistent visuals.

Required subsections:

- **Complete Color Palette**: At least 8-10 colors, each including HEX + functional definition + maximum screen proportion limit
- **Typography System**: At least 6 font size hierarchies, each including font name + weight + size + letter-spacing + usage
- **Grid System**: Canvas dimensions + outer margins + column grid + baseline grid + key safe zones + golden ratio anchor points
- **Animation System**: Easing library (4 or fewer) + duration dictionary + stagger rules + scene transition rules
- **Chrome Elements**: Small details throughout the film (counter / chip / ticker / watermark / texture), each including position + entry/exit timing
- **Audio System**: BGM 30-second progression curve (layered) + SFX dictionary (10+ cues including timecode + volume + frequency band isolation)
- **Anti-AI Slop Checklist**: Per-shot self-check list (10-15 items)

Ironclad rule: **All visual decisions must be derived from the Visual System; do not invent new values on the fly in the shot list.**

### Part III · Story Arc (approx. 500-800 words)

Three-act structure + emotional curve:

- **Act I · SETUP** (0 → 1/5 of the total duration, e.g., 0-6s for a 30s film): The audience enters, the problem is posed
- **Act II · ESCALATION** (Middle 2/3): The answer unfolds, the theme is laid out
- **Act III · PAYOFF** (Last 1/4): Elevation, slogan reveal, brand stamp

Include an ASCII emotional curve diagram + emotional climax timecode markings.

**Key Decision**: The climax is not necessarily at the very end. For a 30s video, the climax is usually at 22-25s (not 29s) — the last few seconds are resolution / decay, not the peak. Violating this rule will inevitably make the work "end with a whimper."

### Part IV · Shot-by-Shot Storyboard (approx. 5000-7000 words · occupying 60% of the content)

Each shot must contain 10 fields (none can be omitted):

```
SHOT NN · NAME
[TIMECODE]    Start/end time + duration
[FUNCTION]    The function of this shot in the story arc (one sentence)
[VISUAL]      Frame composition + element positions + motion direction
[TYPE]        Typography spec (font / size / letter-spacing / line-height / color / alignment)
[ANIM]        Entry/exit timing of each element + easing + duration + stagger + delay
[AUDIO]       Music beat + SFX cue (corresponding BGM rhythm for each shot + mandatory SFX timeline)
[CHROME]      Four-corner element states (which chrome elements are present / which fade in/out / which pulse)
[ANTI-SLOP]   Which self-check items this shot passed + what the 120% detail signature is
[WHY]         Logic connecting from the previous shot + the hook driving to the next shot
```

**Fields average 30-80 words → 400-700 words per shot → 12-15 shots → 5000-7000 words**.

Real-world experience: After writing the storyboard, **read it yourself** — if you delete any single shot, does the film still hold together? If it can be deleted, that shot is redundant; delete it.

### Part V · Production Manifest (approx. 800-1200 words)

Engineering delivery checklist:

- Font loading URL (including preconnect)
- CSS variables (directly copy-pasteable)
- BGM selection criteria + Suno/Udio prompt keywords + alternative libraries
- SFX dictionary (file path + volume listed by timecode)
- **Keyframe Verification Plan**: 12-15 pause-and-check keyframe timecodes, listing verification items for each frame (fonts / positions / chrome state)
- Recording parameters (fps / codec / bitrate / preset)
- ffmpeg audio mixing command (including audio stream verification)
- Deliverables list (mp4 / mp4-60fps / gif / poster.png / silent.mp4 / shot-list.csv)
- End-to-end time estimation (hour-level precision)

---

## 4. 5 Tips for Writing Director's Notes

**4.1 Use a Director's Tone, Not a PM's Tone**

❌ "This shot displays the product features."
✅ "This is the hero shot — if the audience pauses anywhere, I want it to be here."

Director's notes are written for executors, but they are also for your future self. First-person expression + judgment leaves more decision-making clues than description.

**4.2 Reference Specific Works (Including Years), Not Just Genre Names**

❌ "Apple-inspired"
✅ "Apple 'Designed by Apple in California' (2013, dir. Mark Romanek) — learning the slow tempo + serif + large white background"

Benefits of referencing specific works: (a) Any viewer can search for the reference online (b) It forces you to think clearly about what specific techniques you are learning (c) It prevents "fuzzy inspiration."

**4.3 Trace Every Decision Back to a First Principle**

The entire film should have one first principle (e.g., "Markdown is the new typewriter."). Every specific decision — color palette / typography / rhythm / chrome — must trace back to this statement.

Decisions that cannot be traced back are merely decorative; delete them.

**4.4 Writing "Anti-Slop" is More Important Than Writing "Do This"**

A list of "things this film will not do" (purple gradients / emojis / Lorem ipsum / Inter display / drawing characters with SVG / rounded cards + left border accent) does more to protect quality than a list of "things this film will do."

Positive decisions are infinite, whereas negative checklists are finite — but once a negative checklist is violated, it becomes slop.

**4.5 Do Not Implement Immediately After Writing — Reread After 30 Minutes**

While writing, the brain is in "production mode" and blind to inconsistencies. Reading the storyboard you wrote after 30 minutes, you will find:
- Two shots have duplicate functions (delete one)
- The narrative jump in a shot is too abrupt (add a transition)
- The emotional climax is in the wrong place (move it)
- The chrome elements do not match the number of shots (re-align)

These 30 minutes will save you 2 hours of rework later.

---

## 5. Director's Notes → HTML Implementation Workflow

After finishing the director's notes, the HTML implementation steps are:

1. **Reuse starter components** (`assets/animations.jsx`'s Stage/Sprite/Easing/interpolate) — do not reinvent the wheel
2. **Paste CSS variables directly from Visual System Part II** — do not change colors on the fly in HTML
3. **Map the Sprite start/end timeline to Part IV timecodes** — do not add shots arbitrarily
4. **Abstract chrome elements into separate components** (ChromeA/B/C/D), driven by `useTime()` for state switching
5. **Destination card content must be real and readable** (not fake bar lines) — this is the most frequently mentioned 120% detail signature in the v5 project
6. **Immediately screenshot and verify keyframes after writing each shot** (using the `?t=NN` URL parameter + Playwright), do not write the entire film before verifying all at once

---

## 6. Keyframe Verification Workflow

URL parameter implementation (must be added to the Stage component):

```js
const urlMatch = window.location.search.match(/[?&]t=([\d.]+)/);
const frozenTime = urlMatch ? parseFloat(urlMatch[1]) : null;
const [time, setTime] = useState(frozenTime != null ? frozenTime : 0);
const [playing, setPlaying] = useState(frozenTime == null);
```

→ This way, `file:///path/animation.html?t=14.5` freezes directly at 14.5 seconds.

Batch screenshots:

```bash
for t in 0.5 2.5 4.9 7.0 10.5 13.5 16.5 19.0 21.5 23.4 25.5 28.0 29.9; do
  npx -y playwright screenshot \
    "file://$PWD/animation.html?t=$t" \
    "keyframes/t-$t.png" \
    --viewport-size=1920,1136 \
    --wait-for-timeout=2500
done
```

Every screenshot must verify:
- [ ] No element overflows the 1920×1080 canvas
- [ ] Letter-spacing and line-height are visually correct (neither too cramped nor too loose)
- [ ] Key typography details (period color / em-dash / italic / small caps) are recognizable
- [ ] Chrome element positions + states are correct
- [ ] Anti-AI slop checklist is passed
- [ ] The 120% detail signature that makes the frame "worth looking at when paused" exists

---

## 7. Multi-Perspective Parallel Strategy (Advanced)

For complex projects (e.g., cannot choose a direction for the launch film / want to see different aesthetic differences / client hasn't decided on a style), you can **spin up multiple subagents to run different director's perspective versions in parallel**.

Real-world configuration (2026-05-11 huashu-md-html project, running 6 parallel versions):

```
v5  · Baseline (Anthropic / Penguin Classics publisher taste)
v5a · Wes Anderson (symmetry + vintage + chapter cards)
v5b · Saul Bass (paper-cut + '60s large typography + geometric cuts)
v5c · Wong Kar-wai (Chinese serif + slow motion + nostalgia)
v5d · Massimo Vignelli (Modernist grid + red/black)
v5e · Kenya Hara (minimalist Japanese + whitespace)
v5f · Yayoi Kusama (polka dots + repetition + single strong color)
```

Each subagent receives an independent brief:
- Project background (the same)
- Mandatory references (the same `v5-director-notes.md` as a methodology template)
- **Designated artist DNA** (color palette / typography / visual language / rhythm / signature elements / enhanced anti-slop version, 30-50 words each)
- Unified task list (director-notes.md + animation.html + keyframes/ + README.md)
- Unified constraints (30s / 1920×1080 / file:// / Google Fonts)

Launched in parallel and run in the background, 6 complete versions are produced in about 30-60 minutes.

After completion, review and compare:
1. Core aesthetic decisions table for each version
2. Side-by-side keyframe comparison (one frame at the same timestamp for each version)
3. Vote: Which one best fits the user's real needs

**Key**: Do not let subagents reference each other — they must produce independently, or they will converge to the "average." Explicitly state in each subagent's instructions: "Do not repeat the aesthetics of v5."

---

## 8. Typical Trigger Scenarios

| User Scenario | Trigger? | Remarks |
|---------|---------|------|
| "Create a SaaS upgrade promo video" | ✅ Triggered | Standard workflow by default |
| "Apple-grade / Super Bowl-quality video" | ✅ Triggered + Upgraded | Strongly recommend multi-perspective parallel runs |
| "30-second brand launch film" | ✅ Triggered | |
| "Write a 10,000-word script for this project before animating" | ✅ Triggered | Explicitly specified by the user |
| "Simple motion graphic, just spin the logo" | ❌ Not Triggered | Use the animations.md standard workflow |
| "Create an onboarding animation demo" | ❌ Not Triggered | Use animations.md |
| "Tutorial video with voiceover" | ❌ Not Triggered | Go to voiceover-pipeline.md |
| "Single hero animation" | ⚠️ Depends on complexity | Triggered if it is a high-spec hero; use hero-animation-case-study.md for a regular hero |

---

## 9. Reference Samples

Full director's notes reference sample (self-contained, within this skill):

`assets/director-notes-samples/launch-film-30s-sample.md` (approx. 78KB · 11,500 words · 13 shots · all 5 major parts complete)

Original project location (including corresponding HTML implementation + keyframes):

- `~/.claude/skills/huashu-md-html/demos/v5-director-notes.md` (director's notes)
- `~/.claude/skills/huashu-md-html/demos/v5-six-forms.html` (HTML implementation)
- `~/.claude/skills/huashu-md-html/demos/v5-keyframes/` (keyframe verification screenshots)

When writing a new project, it is highly recommended to **read this sample first** to understand the workload and detail density before deciding whether to follow the full workflow.

---

## 10. Anti-Patterns (Do Not Do This)

❌ **Starting work after writing a condensed 1,000-word version of director's notes**
→ A condensed version will inevitably miss some sub-items of the Visual System, leading to constant backtracking to fill in specs during HTML implementation. Either do it at a 10,000-word level, or skip it entirely to save time.

❌ **Writing only 5-8 shots in the storyboard**
→ A 30-second video needs at least 12-15 shots (2-3 seconds per shot). Fewer shots = constant pacing = no climax.

❌ **Delivering only the director's notes after writing them, without implementation**
→ Documentation is not the deliverable; the animation is. Deliver both the documentation and the animation together, with the documentation attached as a "design rationale" appendix.

❌ **Allowing subagents to view other versions during parallel runs**
→ Each subagent must be independent, otherwise they will converge. Compare only during the review phase.

❌ **Skipping keyframe verification and recording the MP4 directly**
→ This will inevitably lead to rework. Keyframe verification is the cheapest quality gate.

❌ **Delaying animation detail decisions with "I'll figure it out when I record"**
→ The recording phase is mechanical execution; you cannot make creative decisions. All decisions must be locked in the director's notes.

---

*Last revised: 2026-05-11*
*Real case: huashu-md-html v2.0 launch film (v5-director-notes.md)*
