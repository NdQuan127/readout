- BGM: 26.50s peak swell continues, reaching the loudest point of the entire film at 27.20s (-4dB)
- BGM: After 27.20s, the BGM begins to sustain (no longer increasing, but maintaining peak intensity)
- **SFX: impact (slogan SIX) at 26.50s — deep bass impact, slightly a semitone heavier than the impact in the ONE shot (-7dB)**
- SFX: staggered metallic clicks when the 6 pills enter the scene (each -24dB, 50ms)
- SFX: extremely light pen flourish at 27.80s (sub-caption entry)

**[CHROME]**

- B: ON, version chip continues
- D: ON, watermark continues
- E: ON
- md stamp (top-left): ON

**[ANTI-SLOP]**

- ✅ ONE SOURCE. is Ink, SIX FORMS. is Terracotta—representing the color contrast between "source" and "form" respectively, not decorative colors
- ✅ The background of the two NEW pills among the 6 pills is #FFF7F0 (extremely light mist tint), not "orange fill"—restraint
- ✅ The NEW mini badge is located at the prominent position of -8/-10px at the top right of the pill, but has only 9px font size—the standard position for a detailed signature
- ✅ The sub-caption uses the Chinese comma "，" and period "。"—a respect for Chinese typesetting
- ✅ This frame (28.30s) is the "most complete frame for marketing" of this film—it can be screenshotted as a thumbnail / X poster / WeChat Official Account cover image, with all information in one frame: slogan + 6 capabilities + sub-caption + brand stamp + version

**[WHY]**

This is the resolution shot.

If SHOT 11 is the thesis (ONE SOURCE.), SHOT 12 is the antithesis + synthesis (SIX FORMS. plus the complete capability map).

At 27.50s in this frame, the audience should be fully absorbed by the typography visually while listening to the string peak—these are the most worthwhile 5 seconds of the film.

The next shot is the wrap-up, letting the strings decay and allowing the md stamp to shine alone.

---

## SHOT 13 · "SIGN-OFF"

**[TIMECODE]** 29.00 — 30.00s (1.0s) `|` **FUNCTION** Outro. Have all slogan elements exit, leaving the md stamp to shine alone. Brand signature.

**[VISUAL]**

29.00s: SIX FORMS. + 6 pills + sub-caption start to hold-in-place.

29.20-29.60s: ONE SOURCE. + SIX FORMS. + 6 pills + sub-caption fade out slowly (each 400ms linear, **do not stagger**, they fade out synchronously—creating a feeling of "the visual elements settling/precipitating").

29.40s: The md stamp character in the top-left slowly scales up from 56px to 88px, while its position slides from (128, 88) toward the center of the frame (960, 540)—this is md's "final return".

29.40-29.80s: The md character settles in the center of the frame, size 88px, color Ink + Terracotta dot.

29.80-30.00s: A short Terracotta rule (120×2px, shorter and more refined than the one in SHOT 03) appears 30px below the md character, growing from 0 width.

30.00s: All elements are in place. The final frame is:

```
                                                                  ● HUASHU-MD-HTML · v2.0
                                                                                               (top-right chrome)


                                            md.                   ← Newsreader 600, 88px, Ink + Terracotta dot
                                          ───                     ← Terracotta rule, 120×2px

                                                                                CREATED BY HUASHU-DESIGN
                                                                                              (bottom-right watermark)
```

The entire frame contains only 4 elements: md stamp, accent rule, top-right chrome, and bottom-right watermark. Everything else is empty.

**[TYPE]**

- md.: Newsreader 600, 88px, Ink + Terracotta dot
- accent rule: 120×2px Terracotta

**[ANIM]**

- 29.00-29.20s · Hold from the previous shot (allowing the audience to fully absorb it)
- 29.20-29.60s · ONE SOURCE. + SIX FORMS. + 6 pills + sub-caption fade out synchronously (400ms linear, synchronous)
- 29.40-29.80s · md stamp scales up + slides to the center (400ms expoOut, size 56 → 88, position (128,88) → (960,540))
- 29.80-30.00s · accent rule unfolds (200ms expoOut, 0 → 120px)
- 30.00s · final hold (if there is a loop, loop back to 00.00s)

**[AUDIO]**

- BGM: 29.00s starts to decay into L6 (all layers fade out)
- BGM: 29.40s strings fade, leaving piano + reverb tail
- BGM: 30.00s, everything returns to silence + room tone
- **SFX: final stamp / sign-off at 29.40s (ink stamp + soft reverb, -14dB)**—when md lands in the center
- SFX: extremely light paper rustle at 29.80s (accent rule entry)

**[CHROME]**

- B: ON, continuous
- D: ON, continuous
- E: ON, continuous
- All others OFF

**[ANTI-SLOP]**

- ✅ Do not use sign-off text like "Thank you" or "Made with love" (cheap)
- ✅ Do not scale up the logo massively (unnecessary)
- ✅ The md stamp is the true protagonist of the entire film's story; letting it remain alone in the center of the frame at the end is the simplest form of resolution
- ✅ pause-and-look signature: In the final frame, md. in 88px Newsreader font with the Terracotta dot is the visual focal point of the entire screen—the viewer's eyes will naturally linger on this dot, then see the accent rule below, and then move to the version chip in the top-right. This "gaze path" is a success of visual hierarchy design
- ✅ silence in the last 0.2s gives the screen breathing room

**[WHY]**

The entire film begins with a blank page and ends with an md stamp + a touch of terracotta orange.

This is a visual rhyme:
- 0.0s: blank ivory page (empty)
- 30.0s: ivory page + md (filled)

The audience journeys from "empty" to "filled", but the "filled" state is actually just a single `md.` character—this is the visual manifesto of the "source-of-truth": **everything originates from a simple md.**

If the entire film leaves the audience with only one frame to remember, I hope it is this frame.

---

# Part V · Production Manifest

## 5.1 Font List + Loading Method

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Newsreader:ital,wght@0,300;0,400;0,500;0,600;0,700;1,400;1,500&family=JetBrains+Mono:wght@400;500;700&family=Noto+Serif+SC:wght@400;500;700;900&display=swap" rel="stylesheet">
```

**Measured Loading Time**: Approx. 800-1500ms depending on CDN status. The `document.fonts.ready` wait must block until it returns true before starting the Stage timer (Stage is already implemented).

## 5.2 Palette CSS Variables

```css
:root {
  --paper:       #FAFAF6;
  --mist:        #F2EDE4;
  --mica:        #E6E1D6;
  --smoke:       #6B6B6B;
  --cinder:      #3D3530;
  --ink:         #1A1A1A;
  --charred:     #2A2620;
  --terracotta:  #C2410C;
  --terra-hot:   #E55D21;
  --terra-deep:  #8B2D08;
}
```

## 5.3 BGM Source Selection Criteria

**Preferred**: Generate a 30-second cinematic minimal piece using Suno v6.0 / Udio v1.5, with the prompt keywords:

```
minimal cinematic piano, slow tempo 60bpm, single piano notes,
sparse arpeggio, low cello drone, subtle sub-kick percussion,
ascending strings at climax, decay to silence,
in the style of Max Richter on the nature of daylight,
no vocals, 30 seconds duration, ivory paper mood
```

**Alternative**: Search royalty-free libraries
- artlist.io: "minimal cinematic"
- bensound.com: "cinematic"
- musicbed.com: "Jóhann Jóhannsson style"

**Minimum Standard**: BGM of 30 seconds length, 44.1kHz sample rate, aim for -16 LUFS integrated loudness.

## 5.4 SFX Sources

**Preferred**: Use the 37 pre-made resources in `assets/sfx/<category>/*.mp3` of the huashu-design skill:

```
Event                         Recommended SFX File
─────────────────────────────────────────────────────
keyboard clicks            sfx/ui/keyboard-click-*.mp3
cursor blink               sfx/ui/tick-soft.mp3
md morph swell             sfx/cinematic/whoosh-bloom.mp3
file card whoosh           sfx/cinematic/whoosh-short-*.mp3
absorb / ink drop          sfx/foley/ink-drop.mp3
paper rustle               sfx/foley/paper-turn.mp3
chime capability           sfx/melodic/chime-single-*.mp3
chime NEW (double)         sfx/melodic/chime-double-warm.mp3
build sweep                sfx/cinematic/ascending-sweep.mp3
impact (slogan)            sfx/cinematic/deep-impact-*.mp3
pen flourish               sfx/foley/pen-stroke.mp3
final stamp                sfx/foley/ink-stamp.mp3
```

## 5.5 Screenshot Verification Plan

After implementing the HTML, the following keyframes must be verified (using Playwright + `?t=NN` URL parameters):

```
t=0.5    ← SHOT 01 mid: blank ivory page (Verify paper texture is not distracting)
t=2.5    ← SHOT 02 mid: typing in progress (Verify cursor blink + JetBrains Mono)
t=3.8    ← SHOT 03 mid: md morphing (Verify ghost residual + scale curve)
t=5.0    ← SHOT 03 end: hero md settled (Verify 480px + Terracotta dot)
t=7.0    ← SHOT 04 mid: cards in flight (Verify parabola + card content is actually readable)
t=8.4    ← SHOT 04 tagline (Verify "Everything → md" Chinese italic)
t=10.5   ← SHOT 05 mid: html card complete (Verify essay content readability)
t=13.5   ← SHOT 06 mid: md source visible (Verify syntax highlighting)
t=16.5   ← SHOT 07 mid: docx page complete (Verify chapter title + page number)
t=19.0   ← SHOT 08 mid: PDFs fanned out (Verify crop marks are visible)
t=21.5   ← SHOT 09 mid: EPUB frame complete (Verify Apple Books chrome)
t=23.4   ← SHOT 10 mid: 6 capability orbit (Verify complete capability overview/panorama)
t=25.0   ← SHOT 11 mid: ONE SOURCE. complete (Verify letter-spacing + Terracotta period)
t=27.5   ← SHOT 12 mid: SIX FORMS. + pills (Verify complete double-line slogan)
t=28.5   ← SHOT 12 marketing frame (Verify the overall marketing-ready frame)
t=29.9   ← SHOT 13 final hold (Verify md stamp + accent rule)
```

Each frame must meet the following criteria:
- No element overflows the 1920×1080 canvas
- Letter-spacing and line-height are visually correct
- Passes the anti-AI slop checklist
- Key typography details (such as the Terracotta dot, page number em-dash, chapter title small caps) are recognizable

## 5.6 Recording Parameters

```bash
node scripts/render-video.js \
  --file file:///path/to/v5-six-forms.html \
  --duration 30 \
  --fps 25 \
  --width 1920 \
  --height 1080 \
  --out v5-final-silent.mp4
```

**Key codec parameters**:
- video codec: libx264
- pixel format: yuv420p (for compatibility)
- bitrate: 12 Mbps (high quality, 30s file is ~45MB)
- profile: high
- preset: slow (quality > speed)

**Subsequent frame interpolation** (optional, 60fps smooth version):

```bash
bash scripts/convert-formats.sh v5-final-silent.mp4 --fps 60
```

## 5.7 Audio Mixing

```bash
# Step 1: Add BGM
bash scripts/add-music.sh v5-final-silent.mp4 \
  --bgm assets/bgm/cinematic-minimal-30s.mp3 \
  --bgm-volume -18dB \
  --out v5-with-bgm.mp4

# Step 2: Add SFX cues (added cue-by-cue according to the Part II.6 SFX dictionary)
# Multi-channel mixing using ffmpeg's -filter_complex amix
ffmpeg -i v5-with-bgm.mp4 \
  -i assets/sfx/ui/keyboard-click-1.mp3 \
  -i assets/sfx/ui/keyboard-click-2.mp3 \
  ... \
  -filter_complex "[1]adelay=500|500[s1];[2]adelay=550|550[s2];...;[0][s1][s2]...amix=inputs=N:duration=longest:dropout_transition=0[out]" \
  -map 0:v -map "[out]" \
  -c:v copy -c:a aac -b:a 192k \
  v5-final.mp4

# Step 3: Verify audio stream
ffprobe -i v5-final.mp4 -show_streams -select_streams a 2>&1 | grep -E "(codec_type|sample_rate|channels|duration)"
```

**Expected Output**:
- audio codec: aac
- sample rate: 44100Hz or 48000Hz
- channels: 2 (stereo)
- duration: 30.0s

## 5.8 Deliverables Checklist

```
v5-final.mp4              Main delivery (30s, 1920×1080, 25fps, with audio, ~50MB)
v5-final-60fps.mp4        High frame rate version (60fps interpolated, ~80MB, for X / YouTube)
v5-final.gif              Social media version (30s, optimized palette, < 8MB, for WeChat Official Account embedding)
v5-final-silent.mp4       Silent version (backup, convenient for subsequent dubbing/changing BGM)
v5-poster.png             Poster version (screenshot of the t=28.5s frame, for X Cards / WeChat Official Account cover)
v5-director-notes.md      This document (director notes)
v5-six-forms.html         Source file (HTML animation)
v5-shot-list.csv          Shot timecode + key parameter lookup table (for pause verification)
```

## 5.9 End-to-End Time Estimate

| Step | Estimated Time |
|-----|----------|
| Director's notes writing | Completed |
| HTML animation implementation | 4-6 hours |
| Keyframe screenshots + visual verification | 1 hour |
| Recording silent MP4 | 5-10 minutes (including Playwright startup) |
| BGM generation / selection | 30 minutes |
| SFX cue alignment + mixing | 2-3 hours |
| GIF derivation | 5 minutes |
| Poster screenshot + naming | 10 minutes |
| Final delivery + git commit | 10 minutes |
| **Total** | **8-11 hours** |

---

# Appendix · First Principle of this film

If I, as the director, could keep only one sentence for this film, it would be:

> **A typographic film about the "source", with a single `md.` character as the protagonist.**

All other design decisions—palette, fonts, rhythm, SFX, chrome, anti-slop checklist—are derived from this single sentence.

If a specific decision cannot be traced back to this sentence, do not make it.

---

*Director's notes — end of document*
*Total word count: Approx. 11,500 Chinese characters*
*Next: After user review and approval, enter the HTML implementation stage*
