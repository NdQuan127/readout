- **L6 · Decay + reverb tail** (26-30s): Decay on all layers, leaving piano + reverb

**Style Target**: Max Richter's *On the Nature of Daylight* + Ólafur Arnalds's *Re:member* + Jóhann Jóhannsson's *Orphée*

### SFX Dictionary

```
Cue                          Time        Type               Volume
────────────────────────────────────────────────────────────────────
keyboard click               00.5-02.0   keypress × 12      -18dB (30ms each)
cursor blink                 02.0-02.8   subtle tick        -28dB
md morph swell               02.8-03.2   soft whoosh + bloom -16dB
file card whoosh × 6         05.5-08.0   short whoosh       -20dB (200ms each)
absorb / ink drop            08.0-08.4   "absorb" splash    -16dB
paper rustle                 08.5-09.0   paper turn         -22dB
chime: capability 02 →       09.0        single chime tone  -18dB
chime: capability 03 →       12.0        single chime tone  -18dB
chime: capability 04 →       15.0        single chime tone  -18dB
chime: NEW (05)              18.0        double chime + glow -14dB
chime: NEW (06)              21.0        double chime + glow -14dB
build sweep                  22.0-22.6   ascending sweep    -10dB
impact (slogan ONE)          22.6        deep impact        -8dB
impact (slogan SIX)          23.4        deep impact        -8dB
pen flourish                 24.0-24.4   pen on paper       -22dB
final stamp / sign-off       29.0-29.5   ink stamp          -14dB
```

**SFX Frequency Band Isolation** (preventing clashes):
- BGM occupies low frequencies (40Hz-2kHz)
- SFX whooshes / chimes occupy mid-to-high frequencies (2kHz-8kHz)
- SFX impacts occupy sub-low frequencies (40Hz-120Hz) — overlaps with BGM cello, but BGM simultaneously ducks by -3dB

## 2.7 Anti-AI Slop Checklist (per shot)

Every shot must pass this checklist before execution:

```
□  No purple (of any saturation)
□  No combination of rounded-corner cards + left accent borders (except for the honest mica border of the destination card)
□  No emojis as icons
□  No SVG-drawn characters / abstract figures
□  No colors outside the Part II.1 color palette
□  No Inter / Roboto / Arial for display fonts
□  Letter-spacing, line-height, and font-size must all come from the Part II.2 typography system (no values added "by feel")
□  Vertical positions must be multiples of 8 (except for deliberate visual reasons)
□  Terracotta orange occupies < 10% of the screen in this shot
□  This shot has at least one detail worthy of being "screenshotted when paused" (120% signature detail)
□  The transition from the previous shot to this shot is a cross-dissolve + scale, not a hard cut
□  At the end of this shot, visual space is "yielded" for the next shot (not "full screen filled until the last frame")
```

---

# Part III · Story Arc

## 3.1 Three-Act Structure

**ACT I · SET-UP (00.0 — 06.0s)**

The audience enters the screen. The question is posed: What is the source of truth?

- SHOT 01 (0.0-1.5s) · BLANK PAGE
- SHOT 02 (1.5-3.0s) · THE CURSOR
- SHOT 03 (3.0-5.0s) · THE TRANSFORMATION
- SHOT 04 (5.0-6.0s) · Entering gathering (overlaps with ACT II)

**ACT II · ESCALATION (06.0 — 22.0s)**

The answer unfolds: md is the source. It radiates outward into 6 output chains.

- SHOT 04 (5.0-8.5s) · GATHERING (any → md)
- SHOT 05 (8.5-11.5s) · FIRST FLOWER (md → html)
- SHOT 06 (11.5-14.5s) · REVERSE FLOW (html → md)
- SHOT 07 (14.5-17.5s) · PUBLISHER GRADE (md → docx)
- SHOT 08 (17.5-20.5s) · ★ NEW · PRINT (md → pdf)
- SHOT 09 (20.5-22.5s) · ★ NEW · EBOOK (md → epub, overlaps with ACT III by 0.5s)

**ACT III · PAYOFF (22.5 — 30.0s)**

The theme is elevated. The slogan appears. The brand stamp.

- SHOT 10 (22.5-24.0s) · THE CONVERGENCE
- SHOT 11 (24.0-26.5s) · ONE SOURCE.
- SHOT 12 (26.5-29.0s) · SIX FORMS.
- SHOT 13 (29.0-30.0s) · SIGN-OFF

## 3.2 Emotion Curve

```
Emotional Intensity
 │                                       ╔═══╗
 │                                    ╔══╝   ╚══╗
 │                              ╔═════╝         ╚══╗
 │                          ╔═══╝                   ╚══╗
 │                       ╔══╝                          ╚══╗
 │                   ╔═══╝                                 ╚════════╗
 │             ╔═════╝                                              ╚══╗
 │       ╔═════╝                                                       ╚══
 │  ╔════╝
 │══╝
 0──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──>
    0     2     4     6     8    10    12    14    16    18    20    22    24    26    28    30s
    │     │     │            │           │            │            │     │     │
    blank cursor morph      gather       cap 02-04   cap 05/06 ★  slogan slogan sign-off
                                                                  ONE   SIX
                                                                  ──────►
                                                                  PEAK 24.5s
```

**Key Emotional Beats**:
- **02.0s**: First keyboard click → audience enters
- **03.0s**: Born of md character → first sense of "awe"
- **08.0s**: 6 document cards gather into md → "Ah, so md is the source" first realization/click
- **18.0s**: First NEW label appears → veteran users go "Oh!"
- **22.5s**: All chrome collapses, preparing to enter Act III → tension build-up peak
- **24.5s**: SIX FORMS. lands → emotional climax
- **30.0s**: md stamp sits silently → resolution

---

# Part IV · Shot-by-Shot Storyboard

Format for each shot:

```
SHOT NN · NAME
[TIMECODE]  |  FUNCTION
[VISUAL]     Screen composition
[TYPE]       Precise typography spec
[ANIM]       In/out/easing/delay for each element
[AUDIO]      music beat + SFX cue
[CHROME]     State of corner elements
[ANTI-SLOP]  Passed checklist items
[WHY]        Connection + progression
```

---

## SHOT 01 · "BLANK PAGE"

**[TIMECODE]** 00.00 — 01.50s (1.5s) `|` **FUNCTION** Opening. Draws the audience in. Giving time to the "emptiness".

**[VISUAL]**

The entire 1920×1080 frame is Ivory paper #FAFAF6. **Nothing is on screen**.

The only presence: an extremely subtle paper texture (SVG noise + 0.3% scale extremely slow breathing), barely visible, but giving the subconscious impression that "this is a real piece of paper".

Composition: Completely empty. This is "white" in the Kenya Hara sense—not "not yet painted", but "the content itself".

**[TYPE]** No text.

**[ANIM]**

- 0.00s · paper texture opacity from 0 → 0.04 (500ms linear)
- 0.50-1.50s · The entire frame holds, no action. Allowing the audience's eyes to adapt to this white.
- 1.40-1.50s · The cursor position starts to emerge in the center-left of the screen (x=860, y=540) (transparent, reveals in the next shot)

**[AUDIO]**

- BGM: Room tone enters (300ms fade-in to -38dB)
- SFX: None

**[CHROME]** All hidden. Chrome A/B/C/D/E have not appeared yet.

**[ANTI-SLOP]**

- ✅ No logos, no "Loading...", no pre-branding elements
- ✅ No gradients, no effects
- ✅ The "pause-and-look" signature of this shot: The screen has texture (paper texture) but never steals the spotlight

**[WHY]**

Apple's "Designed by Apple in California" also opens like this—giving time to the blank space. It tells the audience, "this film requires you to slow down." If logos and chrome are piled up at the beginning, the audience's attention gets scattered and cannot be gathered back for the next 30 seconds.

These 1.5 seconds are among the most important 1.5 seconds of this film.

---

## SHOT 02 · "THE CURSOR"

**[TIMECODE]** 01.50 — 03.00s (1.5s) `|` **FUNCTION** Birth of the typewriter. The first piece of content.

**[VISUAL]**

In the center-left of the screen (x=860, y=540), a vertical black block (3px × 56px, Ink #1A1A1A) starts blinking. This is the cursor.

After blinking twice (0.7s per cycle × 2), `# markdown.md` starts appearing character-by-character behind the cursor, in JetBrains Mono 56px, color Ink #1A1A1A, letter-spacing -0.01em.

With each character typed, a keyboard click sound triggers. After the last character is typed (total of 13 characters), the cursor continues to blink once after `.md`.

**[TYPE]**

- Text: `# markdown.md`
- Font: JetBrains Mono 500 weight
- Size: 56px
- Color: Ink #1A1A1A
- Letter-spacing: -0.01em
- Position: horizontal center, y = 540 (baseline, text vertical center is slightly below this)

**[ANIM]**

- 01.50s · cursor block opacity 0 → 1 (200ms)
- 01.50-01.85s · cursor blink 1st time (off 200ms / on 200ms)
- 01.85-02.20s · cursor blink 2nd time
- 02.20-02.85s · 13 characters appear staggered, every 50ms (total 650ms to complete), each character individually fading + 1px sliding down (180ms expoOut)
- 02.85-03.00s · cursor blinks one more time at the end (the last time, marking typing completion)

**[AUDIO]**

- BGM: First piano note struck at 01.50s (-22dB)
- SFX: keyboard click × 13 (once per character, -18dB, 30ms each)
- SFX: 200ms silence after the last cursor blink (yielding space for the next shot's morph)

**[CHROME]** Still hidden.

**[ANTI-SLOP]**

- ✅ The cursor does not blink in a sci-fi way (not 0.1s ultra-fast blinking), but is a realistic simulation of the macOS terminal cursor rhythm
- ✅ Typing is not "characters appearing all at once", but is typed with realistic rhythm
- ✅ The font is JetBrains Mono, not a system default mono like Courier or Menlo
- ✅ The pause-and-look signature: 3px width for the cursor (not 2px or 4px) — an extremely precise detail, experts will notice this is "real terminal design"

**[WHY]**

This shot is the core of the setup: **markdown is not a noun, it is an action**—it is the very act of "striking the keyboard to turn characters into structure."

The cursor is the smallest unit of writing. Starting from a cursor is the birth of the "source code".

The morph in the next shot builds on this premise that the audience has already accepted: "we are writing markdown."

---

## SHOT 03 · "THE TRANSFORMATION"

**[TIMECODE]** 03.00 — 05.00s (2.0s) `|` **FUNCTION** Reveal the hero. `# markdown.md` morphs into the hero `md.`

**[VISUAL]**

At 03.00s: `# markdown.md` (56px mono) starts gathering toward the center, scaling up, and morphing.

**Morphing Process** (detailed deconstruction):

- 03.00-03.30s (300ms): The `#` and `arkdown` parts of `# markdown.md` fade out (opacity 1 → 0), while `m` and the `md` part of `d.md` remain.
- 03.30-04.10s (800ms): The remaining `md` morphs from mono font to Newsreader serif, scales up from 56px to 480px, and remains Ink color (no color change), keeping its position (still centered in the frame).
- 04.10-04.80s (700ms): At the bottom-right of the `md` characters, a Terracotta period `.` emerges (fade-in + scale 0.6 → 1 + overshoot easing).
- 04.80-05.00s (200ms): The period officially settles, completing the hero. A 320px wide, 2px thick terracotta accent rule appears 30px below, expanding from the center to both ends.

**Ending Frame**: `md.` (Newsreader 600 weight, 480px, Ink with Terracotta dot) + a terracotta accent rule below. Everything else on screen is completely empty.

**[TYPE]**

- Text: `md.` (`md` Ink, `.` Terracotta)
- Font: Newsreader 600 weight
- Size: 480px (display L)
- Letter-spacing: -0.04em
- Color: `m`+`d` Ink #1A1A1A, `.` Terracotta #C2410C
- Horizontally and vertically centered on the hero centerline (y = 540)
- Accent rule 30px below, width 320px (grows from 0)

**[ANIM]**

- 03.00-03.30s · `#`, `arkdown`, `md` (middle segment) fade out (opacity 1 → 0, expoOut)
- 03.30-04.10s · `md` morph: fontFamily switch, fontSize from 56 → 480, weight from 500 → 600 (800ms expoOut; note that the morph is not an abrupt switch, but a ghosting/afterimage overlay + scale up + opacity switch)
- 04.10-04.80s · `.` enters (700ms overshoot, scale 0.6 → 1)
- 04.80-05.00s · accent rule width 0 → 320px (300ms expoOut)

**[AUDIO]**

- BGM: Second piano note at 03.00s (-20dB), third piano note at 04.20s (-18dB) — piano accumulation
- SFX: 03.00-03.20s soft whoosh (when morph starts, -16dB)
- SFX: 04.10s subtle bloom (the moment the period appears, -20dB)
- SFX: 04.80s short paper rustle (when accent rule expands, -22dB)

**[CHROME]**

- 04.50s · Chrome B (version chip top-right) starts to emerge (fade-in 600ms)
  - State: `● HUASHU-MD-HTML · v2.0`
  - terracotta dot, mono text, Ink color
  - Entry position: top: 78px, right: 80px
- Still hidden: Chrome A, C, E (visible only ≥ 06s)

**[ANTI-SLOP]**

- ✅ Morph is not a cheap transition like "fade-out + fade-in", but real character distortion (including ghosting/afterimage overlay)
- ✅ The period is the hero's "signature detail" (the 120% detail): The Terracotta period is as small as a fingernail, but it is the visual anchor of this film, **retained as the hero identifier in all subsequent shots**
- ✅ The accent rule is not a decoration, but the hero's baseline—it will reappear in Shot 11's slogan, establishing a beginning-to-end resonance
- ✅ pause-and-look signature: The letter-spacing of -0.04em for the 480px Newsreader 'md' makes 'm' and 'd' almost fit together but not touch, which is the signature feel of the Newsreader font at large sizes

**[WHY]**

This is the hero shot. The "protagonist" of the entire film (`md.`) for the next 25 seconds is born here.

The design philosophy of the morph: **from mono to serif, this is a metaphor from "I am typing" to "I am writing"**. Mono is typewriter, serif is publishing. md is both at the same time—it is typed on a keyboard, but it is the source code of publishing.

Entering ACT II in the next shot, the hero is already established—it will be pushed to the top of the screen to yield space for the "materialized products".

---

## SHOT 04 · "GATHERING" (any → md)

**[TIMECODE]** 05.00 — 08.50s (3.5s) `|` **FUNCTION** Reveal CAPABILITY 01. Everything → md. Establishing the worldview of "md is the source".

**[VISUAL]**

05.00s: The hero `md.` slides up from the center (y=540) to y=280 (1/4 height position) while scaling down to 220px.

Then, in the lower half of the screen (y=520 ~ y=900 region), 6 document cards appear, flying in sequentially from off-screen (below, y=1140), gathering toward the md hero along an invisible parabolic trajectory.

Design of the 6 cards (**each is a mini demo of a real file type, not fake bar lines**):

```
.pdf   │ double-column layout + header "doc.pdf" + page number "— 12 —" + a few lines of real typeset small text
.docx  │ heading "On Markdown" + italic subtitle + 6 paragraph lines of ascii
.pptx  │ title "MD AS SOURCE" + a simplified bar chart placeholder
.xlsx  │ 6×4 spreadsheet grid + some numbers
.epub  │ Apple Books style page + chapter title "Chapter 01"
.html  │ a browser chrome (three dots + URL bar "example.com") + title + paragraph
```

Each card is sized 130×180px, with white background + Mica border + 24° top-right fold.

**Flight Path**: Starting from y=1140 below, gathering toward the md hero's "." position (approximately x=960+50, y=280+90) along a parabolic path. In the middle section (when in the middle of the screen), the 6 cards are arranged in a fan shape with a 220px gap between adjacent cards. Finally, all 6 cards are "absorbed" by the md (scale 1 → 0.5 + opacity 1 → 0, while the positions gather into a single point).

Absorption Timing: Starting from 05.60s, one launches every 0.18s. Each flies for 1.1s before being absorbed. The last card's absorption completes at around 07.60s.

After absorption completes (07.60-08.20s), the tagline appears 60px below: "Everything → md" (Chinese serif, 36px, Ink, italic)

08.20-08.50s · Overall hold, preparing to enter Shot 05.

**[TYPE]**

- hero `md.`: scaled down to 220px (same font specs as SHOT 03)
- Inner layout of 6 cards: JetBrains Mono 12-14px for labels, Newsreader 12-16px for content
- tagline "Everything → md": Noto Serif SC 36px italic + middle arrow `→` is Newsreader italic + Terracotta
- Top Chrome A text: JetBrains Mono 12px

**[ANIM]**

- 05.00-05.30s · hero md scales + moves up (300ms expoOut)
- 05.30s · Chrome A capability counter enters (CAPABILITY · 01 displayed, first dot solid)
- 05.60-07.60s · 6 cards launch in sequence (each launch delay = 5.60 + i × 0.18s, flies for 1.1s, absorb at launch+1.1)
- 07.60-08.20s · tagline "Everything → md" enters (fade-in 400ms + slight y slide 12px → 0)
- 08.20-08.50s · hold

**[AUDIO]**

- BGM: piano arpeggio L2 enters at 05.00s (-26dB → -20dB fade-in)
- SFX: file card whoosh × 6 (once per card launch, 200ms each, -20dB)
- SFX: absorb / ink drop (triggered when the last card is absorbed, -16dB)
