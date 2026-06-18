# Audio Design Rules · huashu-design

> Audio application recipes for all animation demos. Used in conjunction with `sfx-library.md` (asset list).
> Refined through real-world practice: huashu-design release hero v1-v9 iterations · Gemini deep-dive teardown of three official Anthropic videos · 8000+ A/B comparisons

---

## Core Principle · Audio Dual-Track System (Ironclad Rule)

Animation audio **must be designed independently in two layers**, rather than just a single layer:

| Layer | Role | Time Scale | Relationship with Visuals | Frequency Band |
|---|---|---|---|---|
| **SFX (Beat Layer)** | Marks each visual beat | Short, 0.2-2 seconds | **Strong synchronization** (frame-level alignment) | **High frequency 800Hz+** |
| **BGM (Ambient Bed)** | Emotional foundation, soundstage | Continuous, 20-60 seconds | Weak synchronization (section-level) | **Mid-to-low frequency <4kHz** |

**Animations with only BGM are crippled**—the audience subconsciously perceives that "the visuals are moving but there is no audio response," which is the root cause of a cheap feel.

---

## Gold Standard · The Golden Ratio

These sets of values are **hard engineering parameters** derived from testing the three official Anthropic videos + our own v9 final version comparison. You can apply them directly:

### Volume
- **BGM Volume**: `0.40-0.50` (relative to full scale 1.0)
- **SFX Volume**: `1.00`
- **Loudness Difference**: BGM peak is **-6 to -8 dB lower** than SFX peak (highlighted not by the absolute loudness of SFX, but by the loudness difference)
- **amix parameter**: `normalize=0` (never use `normalize=1`, as it flattens the dynamic range)

### Frequency Band Isolation (P1 Hard Optimization)
Anthropic's secret is not "loud SFX volume," but **frequency band layering**:

```bash
[bgm_raw]lowpass=f=4000[bgm]      # Restrict BGM to mid-to-low frequencies <4kHz
[sfx_raw]highpass=f=800[sfx]      # Push SFX to mid-to-high frequencies 800Hz+
[bgm][sfx]amix=inputs=2:duration=first:normalize=0[a]
```

Why: The human ear is most sensitive to the 2-5kHz range (the "presence band"). If the SFX is within this range and the BGM covers the entire frequency spectrum, **the SFX will be masked by the high-frequency portion of the BGM**. By using a highpass filter to push the SFX higher and a lowpass filter to suppress the BGM, they each occupy separate parts of the spectrum, boosting SFX clarity to the next level.

### Fade
- BGM Fade-in: `afade=in:st=0:d=0.3` (0.3s, to avoid hard cuts)
- BGM Fade-out: `afade=out:st=N-1.5:d=1.5` (1.5s long tail, for a sense of closure)
- SFX has its own envelope; no additional fade is needed.

---

## SFX Cue Design Rules

### Density (Number of SFX per 10 seconds)
The SFX density measured in Anthropic's three videos falls into three levels:

| Video | SFX count per 10s | Product Personality | Scene |
|---|---|---|---|
| Artifacts (ref-1) | **~9 / 10s** | Feature-dense, highly informative | Complex tool demo |
| Code Desktop (ref-2) | **0** | Pure ambient, meditative | Developer tool focus state |
| Word (ref-3) | **~4 / 10s** | Balanced, office tempo | Productivity tool |

**Heuristics**:
- Calm/focused product personality → Low SFX density (0-3 / 10s), primarily driven by BGM
- Lively/highly informative product personality → High SFX density (6-9 / 10s), driven by SFX tempo
- **Do not fill every visual beat**—negative space feels more premium than high density. **Deleting 30-50% of the cues will make the remaining ones much more dramatic**.

### Cue Selection Priority
Not every visual beat needs a matching SFX. Select according to this priority:

**P0 Essential** (omitting these will feel jarring):
- Typing (terminal/input)
- Clicking/selecting (moments of user decision-making)
- Focus switching (shift of the visual protagonist)
- Logo reveal (brand closure)

**P1 Recommended**:
- Element entry/exit (modal / card)
- Completion/success feedback
- AI generation start/end
- Major transition (scene switching)

**P2 Optional** (too many will cause clutter):
- hover / focus-in
- Progress tick
- Decorative ambient

### Timestamp Alignment Precision
- **Same-frame alignment** (0ms error): Click / focus switch / Logo settling
- **Pre-aligned by 1-2 frames** (-33ms): Fast whoosh (provides psychological anticipation to the audience)
- **Post-aligned by 1-2 frames** (+33ms): Object landing / impact (conforms to real-world physics)

---

## BGM Selection Decision Tree

The huashu-design skill comes with 6 built-in BGMs (`assets/bgm-*.mp3`):

```
What is the animation personality?
├─ Product Launch / Tech Demo → bgm-tech.mp3 (minimal synth + piano)
├─ Tutorial / Tool Walkthrough → bgm-tutorial.mp3 (warm, instructional)
├─ Education / Concept Explanation → bgm-educational.mp3 (curious, thoughtful)
├─ Marketing / Brand Promotion → bgm-ad.mp3 (upbeat, promotional)
└─ Variation needed for same style → bgm-*-alt.mp3 (respective alternative version)
```

### Scenes without BGM (Worth Considering)
Referencing Anthropic Code Desktop (ref-2): **0 SFX + pure Lo-fi BGM** can also be very premium.

**When to choose No BGM**:
- Animation duration <10s (BGM cannot be established)
- Product personality is "focus/meditative"
- The scene itself has ambient sound/voiceover
- When SFX density is very high (to avoid auditory overload)

---

## Scene Recipes (Out of the Box)

### Recipe A · Product Launch Hero (Same style as huashu-design v9)
```
Duration: 25 seconds
BGM: bgm-tech.mp3 · 45% · Frequency band <4kHz
SFX Density: ~6 / 10s

cues:
  Terminal typing → type × 4 (0.6s interval)
  Enter           → enter
  Cards gathering → card × 4 (staggered by 0.2s)
  Select          → click
  Ripple          → whoosh
  4x Focus        → focus × 4
  Logo            → thud (1.5s)

Volume: BGM 0.45 / SFX 1.0 · amix normalize=0
```

### Recipe B · Tool Feature Demo (Referencing Anthropic Code Desktop)
```
Duration: 30-45 seconds
BGM: bgm-tutorial.mp3 · 50%
SFX Density: 0-2 / 10s (extremely rare)

Strategy: Let the BGM + voiceover drive, with SFX used only at **decisive moments** (file save / command execution complete)
```

### Recipe C · AI Generation Demo
```
Duration: 15-20 seconds
BGM: bgm-tech.mp3 or No BGM
SFX Density: ~8 / 10s (high density)

cues:
  User input      → type + enter
  AI processing   → magic/ai-process (1.2s loop)
  Generation done → feedback/complete-done
  Result display  → magic/sparkle
  
Highlight: ai-process can loop 2-3 times to span the entire generation process
```

### Recipe D · Pure Ambient Long Take (Referencing Artifacts)
```
Duration: 10-15 seconds
BGM: None
SFX: 3-5 carefully designed cues used individually

Strategy: Each SFX is the protagonist, avoiding the issue of BGM "muddying" them together.
Best for: Slow-motion product shots, close-ups
```

---

## FFmpeg Composition Templates

### Template 1 · Overlaying a single SFX onto video
```bash
ffmpeg -y -i video.mp4 -itsoffset 2.5 -i sfx.mp3 \
  -filter_complex "[0:a][1:a]amix=inputs=2:normalize=0[a]" \
  -map 0:v -map "[a]" output.mp4
```

### Template 2 · Multi-SFX timeline composition (aligned to cue timestamps)
```bash
ffmpeg -y \
  -i sfx-type.mp3 -i sfx-enter.mp3 -i sfx-click.mp3 -i sfx-thud.mp3 \
  -filter_complex "\
[0:a]adelay=1100|1100[a0];\
[1:a]adelay=3200|3200[a1];\
[2:a]adelay=7000|7000[a2];\
[3:a]adelay=21800|21800[a3];\
[a0][a1][a2][a3]amix=inputs=4:duration=longest:normalize=0[mixed]" \
  -map "[mixed]" -t 25 sfx-track.mp3
```
**Key Parameters**:
- `adelay=N|N`: The first is the left channel delay (ms) and the second is the right channel, written twice to ensure stereo alignment
- `normalize=0`: Preserves dynamic range, crucial!
- `-t 25`: Truncate to the specified duration

### Template 3 · Video + SFX track + BGM (with frequency band isolation)
```bash
ffmpeg -y -i video.mp4 -i sfx-track.mp3 -i bgm.mp3 \
  -filter_complex "\
[2:a]atrim=0:25,afade=in:st=0:d=0.3,afade=out:st=23.5:d=1.5,\
     lowpass=f=4000,volume=0.45[bgm];\
[1:a]highpass=f=800,volume=1.0[sfx];\
[bgm][sfx]amix=inputs=2:duration=first:normalize=0[a]" \
  -map 0:v -map "[a]" -c:v copy -c:a aac -b:a 192k final.mp4
```

---

## Troubleshooting & Failure Modes

| Symptom | Root Cause | Fix |
|---|---|---|
| SFX inaudible | High-frequency portion of BGM masks it | Add `lowpass=f=4000` to BGM + `highpass=f=800` to SFX |
| Sound effect too loud/piercing | Absolute SFX volume is too high | Decrease SFX volume to 0.7, and decrease BGM to 0.3 to maintain the gap |
| BGM and SFX tempo conflict | Incorrect BGM selection (used music with a strong beat) | Switch to an ambient / minimal synth BGM |
| BGM cuts off abruptly at the end | Missing fade-out | `afade=out:st=N-1.5:d=1.5` |
| SFX overlapping and muddy | Cues too dense + duration of each SFX is too long | Limit SFX duration to within 0.5s, cue interval ≥ 0.2s |
| WeChat Official Account mp4 has no sound | WeChat sometimes mutes auto-play | Don't worry, sound will play when user taps it; GIFs naturally don't have sound anyway |

---

## Integration with Visuals (Advanced)

### Match SFX Timbre with Visual Style
- Warm beige/paper-textured visuals → Use **woody/soft** SFX timbres (Morse, paper snap, soft click)
- Cold black tech visuals → Use **metallic/digital** SFX timbres (beep, pulse, glitch)
- Hand-drawn/childlike visuals → Use **cartoonish/exaggerated** SFX timbres (boing, pop, zap)

Our current warm beige background color in `apple-gallery-showcase.md` → paired with `keyboard/type.mp3` (mechanical) + `container/card-snap.mp3` (soft) + `impact/logo-reveal-v2.mp3` (cinematic bass)

### SFX Can Drive the Visual Tempo
Advanced Tip: **Design the SFX timeline first, then adjust the visual animation to align with the SFX** (rather than the other way around).

Since each SFX cue acts as a "clock tick," adapting the visual animation to the SFX tempo ensures a solid synchronization—whereas SFX chasing the visuals often results in a jarring mismatch of even ±1 frame.

---

## Quality Checklist (Pre-release Self-Check)

- [ ] Loudness Difference: SFX peak - BGM peak = -6 to -8 dB?
- [ ] Frequency Band: BGM lowpass 4kHz + SFX highpass 800Hz?
- [ ] amix `normalize=0` (preserve dynamic range)?
- [ ] BGM fade-in 0.3s + fade-out 1.5s?
- [ ] Is the number of SFX appropriate (density chosen based on scene personality)?
- [ ] Is each SFX aligned with the visual beat in the exact same frame (within ±1 frame)?
- [ ] Is the Logo reveal sound effect long enough (suggested 1.5s)?
- [ ] Listen with BGM muted: Is the SFX rhythmic enough on its own?
- [ ] Listen with SFX muted: Does the BGM have emotional dynamics on its own?

Each of the two layers should be self-consistent when listened to individually. If they only sound good when combined, it indicates poor execution.

---

## References

- SFX Asset List: `sfx-library.md`
- Visual Style Reference: `apple-gallery-showcase.md`
- Anthropic Three-Video In-Depth Audio Analysis: `/Users/alchain/Documents/写作/01-公众号写作/项目/2026.04-huashu-design发布/参考动画/AUDIO-BEST-PRACTICES.md`
- huashu-design v9 Case Study: `/Users/alchain/Documents/写作/01-公众号写作/项目/2026.04-huashu-design发布/配图/hero-animation-v9-final.mp4`
