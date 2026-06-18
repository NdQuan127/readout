# Video Export: HTML Animation Export to MP4/GIF

After completing the HTML animation, users often ask, "Can we export it as a video?" This guide provides the complete workflow.

## When to Export

**Export Timing**:
- The animation runs completely and is visually verified (Playwright screenshots confirm correct states at different time points)
- The user has previewed it in the browser at least once and confirmed that the effect is OK
- **Do not** export while animation bugs are still unresolved — making changes after exporting to video is more expensive

**Trigger Phrases (What Users Might Say)**:
- "Can it be exported as a video?"
- "Convert to MP4"
- "Make it a GIF"
- "60fps"

## Output Specifications

By default, provide all three formats at once for the user to choose from:

| Format | Specs | Best Use Cases | Typical Size (30s) |
|---|---|---|---|
| MP4 25fps | 1920×1080 · H.264 · CRF 18 | WeChat Official Account embedding, Video Channels, YouTube | 1-2 MB |
| MP4 60fps | 1920×1080 · minterpolate frame interpolation · H.264 · CRF 18 | High frame rate showcase, Bilibili, portfolios | 1.5-3 MB |
| GIF | 960×540 · 15fps · palette optimization | Twitter/X, README, Slack preview | 2-4 MB |

## Toolchain

Two scripts located in `scripts/`:

### 1. `render-video.js` — HTML → MP4

Records a baseline 25fps MP4. Relies on global Playwright.

```bash
NODE_PATH=$(npm root -g) node /path/to/claude-design/scripts/render-video.js <html_file>
```

Optional Parameters:
- `--duration=30` Animation duration in seconds
- `--width=1920 --height=1080` Resolution
- `--trim=2.2` Number of seconds to trim from the start of the video (removes reload + font loading time)
- `--fontwait=1.5` Time to wait for font loading in seconds, increase if there are many fonts

Output: Saved in the same directory as the HTML file, with the extension `.mp4`.

### 2. `add-music.sh` — MP4 + BGM → MP4

Mixes background music into a silent MP4, selecting from a built-in BGM library based on the scenario (mood), or using a custom audio file. It automatically matches the video duration and adds fade-in and fade-out effects.

```bash
bash add-music.sh <input.mp4> [--mood=<name>] [--music=<path>] [--out=<path>]
```

**Built-in BGM Library** (located at `assets/bgm-<mood>.mp3`):

| `--mood=` | Style | Suitable Scenarios |
|-----------|------|---------|
| `tech` (default) | Apple Silicon / Apple Keynote, minimalist synthesizer + piano | Product launches, AI tools, Skill promotions |
| `ad` | Upbeat modern electronic, with build + drop | Social media ads, product trailers, promo videos |
| `educational` | Warm and bright, light guitar/electric piano, inviting | Pop science, tutorial intros, course previews |
| `educational-alt` | Alternative option in the same category, try another one | Same as above |
| `tutorial` | Lo-fi ambient, barely noticeable | Software demos, programming tutorials, long presentations |
| `tutorial-alt` | Alternative option in the same category | Same as above |

**Behavior**:
- Music is cropped according to the video duration
- 0.3s fade-in + 1s fade-out (prevents abrupt cuts)
- Video stream uses `-c:v copy` without re-encoding, audio stream uses AAC 192k
- `--music=<path>` has higher priority than `--mood` and can directly specify any external audio file
- Passing an invalid mood name will list all available options instead of failing silently

**Typical Pipeline** (three-piece animation export + background music):
```bash
node render-video.js animation.html                        # Screen recording
bash convert-formats.sh animation.mp4                      # Generate 60fps + GIF
bash add-music.sh animation-60fps.mp4                      # Add default tech BGM
# Or for different scenarios:
bash add-music.sh tutorial-demo.mp4 --mood=tutorial
bash add-music.sh product-promo.mp4 --mood=ad --out=promo-final.mp4
```

### 3. `convert-formats.sh` — MP4 → 60fps MP4 + GIF

Generates a 60fps version and a GIF from an existing MP4.

```bash
bash /path/to/claude-design/scripts/convert-formats.sh <input.mp4> [gif_width] [--minterpolate]
```

Outputs (saved in the same directory as the input):
- `<name>-60fps.mp4` — By default uses `fps=60` frame duplication (broad compatibility); add `--minterpolate` to enable high-quality motion interpolation
- `<name>.gif` — Palette-optimized GIF (default width 960, customizable)

**60fps Mode Selection**:

| Mode | Command | Compatibility | Scenarios |
|---|---|---|---|
| Frame Duplication (Default) | `convert-formats.sh in.mp4` | Universal support on QuickTime/Safari/Chrome/VLC | General delivery, platform uploads, social media |
| minterpolate Motion Interpolation | `convert-formats.sh in.mp4 --minterpolate` | macOS QuickTime/Safari may fail to open | Showcase scenarios like Bilibili that require real frame interpolation; **must test locally** on target players before delivery |

Why was the default changed to frame duplication? The H.264 elementary stream output by minterpolate has a known compatibility bug — we previously ran into the issue where "macOS QuickTime cannot open the file" multiple times when minterpolate was the default. See `animation-pitfalls.md` §14 for details.

`gif_width` parameter:
- 960 (default) — Universal for social media platforms
- 1280 — Clearer but results in larger files
- 600 — Prioritized for loading on Twitter/X

## Full Workflow (Standard Recommendation)

Once the user says "export video":

```bash
cd <project_directory>

# Assume $SKILL points to the root directory of this skill (replace accordingly based on your installation path)

# 1. Record the baseline 25fps MP4
NODE_PATH=$(npm root -g) node "$SKILL/scripts/render-video.js" my-animation.html

# 2. Derive 60fps MP4 and GIF
bash "$SKILL/scripts/convert-formats.sh" my-animation.mp4

# Output Manifest:
# my-animation.mp4         (25fps · 1-2 MB)
# my-animation-60fps.mp4   (60fps · 1.5-3 MB)
# my-animation.gif         (15fps · 2-4 MB)
```

## Technical Details (Troubleshooting)

### Gotchas in Playwright's recordVideo

- The frame rate is fixed at 25fps; you cannot record directly at 60fps (due to the compositor limits in Chromium headless)
- Recording starts when the context is created, so you must use `trim` to crop out the initial loading time
- The default format is webm; it needs to be converted to H.264 MP4 using FFmpeg for universal playback

`render-video.js` already handles all the issues above.

### FFmpeg minterpolate Parameters

Current configuration: `minterpolate=fps=60:mi_mode=mci:mc_mode=aobmc:me_mode=bidir:vsbmc=1`

- `mi_mode=mci` — motion compensation interpolation
- `mc_mode=aobmc` — adaptive overlapped block motion compensation
- `me_mode=bidir` — bidirectional motion estimation
- `vsbmc=1` — variable-size block motion compensation

Works well for CSS **transform animations** (translate/scale/rotate).
For **pure fades**, it might produce slight ghosting — if the user is unsatisfied, fall back to simple frame duplication:

```bash
ffmpeg -i input.mp4 -r 60 -c:v libx264 ... output.mp4
```

### Why GIF Palette Generation Requires Two Stages

GIF only supports 256 colors. A single-pass GIF compression would squash the colors of the entire animation into a generic 256-color palette, which makes delicate color schemes like a beige background with orange details look muddy.

Two-stage process:
1. `palettegen=stats_mode=diff` —— Scans the entire video first to generate an **optimal palette specifically for this animation**
2. `paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle` —— Encodes using this palette; rectangle diff only updates changing areas, drastically reducing file size

For fade transitions, using `dither=bayer` produces smoother results than `none`, but the file size will be slightly larger.

## Pre-flight Check (Before Exporting)

30-second self-check before exporting:

- [ ] HTML has been run completely in the browser with no console errors
- [ ] Frame 0 of the animation is the complete initial state (not blank or loading)
- [ ] The last frame of the animation is a stable final state (not cut in half)
- [ ] Fonts, images, and emojis are all rendered correctly (refer to `animation-pitfalls.md`)
- [ ] The duration parameter matches the actual animation duration in the HTML
- [ ] The Stage detection in the HTML sets `window.__recording` to force `loop=false` (mandatory check for custom Stages; built-in for those using `assets/animations.jsx`)
- [ ] The `fadeOut={0}` attribute is set on the ending Sprite (no fade-out on the final frame of the video)
- [ ] Includes the "Created by Huashu-Design" watermark (required only for animation scenes; add a "Non-official release · " prefix for third-party branded work. See SKILL.md § "Skill Promotion Watermark" for details)

## Delivery Note Template

Standard format for instructions provided to the user after export completes:

```
**Complete Delivery**

| File | Format | Specs | Size |
|---|---|---|---|
| foo.mp4 | MP4 | 1920×1080 · 25fps · H.264 | X MB |
| foo-60fps.mp4 | MP4 | 1920×1080 · 60fps (Motion Interpolated) · H.264 | X MB |
| foo.gif | GIF | 960×540 · 15fps · Palette Optimized | X MB |

**Notes**
- 60fps uses minterpolate for motion estimation frame interpolation, which works well for transform animations.
- GIF uses palette optimization; a 30s animation can be compressed to around 3MB.

Let me know if you need to change the size or frame rate.
```

## Common User Add-on Requests

| What the User Says | Solution |
|---|---|
| "The file size is too big" | MP4: Increase CRF to 23-28; GIF: Lower resolution to 600 or FPS to 10 |
| "The GIF is too blurry" | Increase `gif_width` to 1280; or suggest using MP4 instead (WeChat Moments also supports it) |
| "Need vertical 9:16 layout" | Change HTML source resolution parameters to `--width=1080 --height=1920`, and record again |
| "Add watermark" | FFmpeg: Add `-vf "drawtext=..."` or `overlay=` with a PNG |
| "Need transparent background" | MP4 does not support alpha channel; use WebM VP9 + alpha or APNG |
| "Need lossless quality" | Change CRF to 0 + preset veryslow (file size will be 10x larger) |
