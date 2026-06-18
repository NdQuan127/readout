# Verification: Output Verification Workflow

Some native environments for design agents (such as Claude.ai Artifacts) have a built-in `fork_verifier_agent` that spins up subagents to perform checks using iframe screenshots. Most agent environments (Claude Code / Codex / Cursor / Trae / etc.) do not have this built-in capability—doing it manually with Playwright can cover the same verification scenarios.

## Verification Checklist

Every time you output HTML, run through this checklist once:

### 1. Browser Rendering Check (Mandatory)

The most fundamental check: **Can the HTML open?** On macOS:

```bash
open -a "Google Chrome" "/path/to/your/design.html"
```

Or use Playwright to take screenshots (next section).

### 2. Console Error Check

The most common issue in HTML files is a blank screen caused by JavaScript errors. Run it once with Playwright:

```bash
python ~/.claude/skills/claude-design/scripts/verify.py path/to/design.html
```

This script will:
1. Open the HTML using headless Chromium
2. Save the screenshot to the project directory
3. Capture console errors
4. Report status

For details, see `scripts/verify.py`.

### 3. Multi-Viewport Check

For responsive designs, capture multiple viewports:

```bash
python verify.py design.html --viewports 1920x1080,1440x900,768x1024,375x667
```

### 4. Interaction Check

Tweaks, animations, and button toggles cannot be seen in a default static screenshot. **It is recommended to have the user open the browser and click through it themselves**, or record a video using Playwright:

```python
page.video.record('interaction.mp4')
```

### 5. Slide-by-Slide Check

For deck-like HTML, capture slide by slide:

```bash
python verify.py deck.html --slides 10  # Capture the first 10 slides
```

Generates `deck-slide-01.png`, `deck-slide-02.png`, etc., for quick browsing.

## Playwright Setup

For first-time use:

```bash
# If not installed yet
npm install -g playwright
npx playwright install chromium

# Or the Python version
pip install playwright
playwright install chromium
```

If the user has already installed Playwright globally, you can use it directly.

## Screenshot Best Practices

### Capture Full Page

```python
page.screenshot(path='full.png', full_page=True)
```

### Capture Viewport

```python
page.screenshot(path='viewport.png')  # Captures only the visible area by default
```

### Capture Specific Element

```python
element = page.query_selector('.hero-section')
element.screenshot(path='hero.png')
```

### High-Definition Screenshots

```python
page = browser.new_page(device_scale_factor=2)  # Retina
```

### Wait for Animations to Finish Before Screenshot

```python
page.wait_for_timeout(2000)  # Wait 2 seconds for animations to settle
page.screenshot(...)
```

## Share Screenshots with the User

### Open Local Screenshots Directly

```bash
open screenshot.png
```

The user will view it in their own Preview/Figma/VSCode/browser.

### Upload to Image Hosting for Sharing Link

If you need to share with remote collaborators (e.g., Slack/Lark/WeChat), have the user upload it using their own image hosting tool or MCP:

```bash
python ~/Documents/写作/tools/upload_image.py screenshot.png
```

Returns a permanent ImgBB link, which can be pasted anywhere.

## When Verification Fails

### Blank Screen

There must be errors in the console. Check the following first:

1. Whether the integrity hash of the React+Babel script tags is correct (see `react-setup.md`)
2. Whether there is a naming conflict with `const styles = {...}`
3. Whether cross-file components are exported to `window`
4. JSX syntax errors (babel.min.js might not report errors; switch to the uncompressed version of babel.js)

### Laggy Animations

- Record a session using the Chrome DevTools Performance tab
- Look for layout thrashing (frequent reflows)
- Prioritize using `transform` and `opacity` for animations (GPU acceleration)

### Incorrect Fonts

- Check if the `@font-face` URL is accessible
- Check the fallback fonts
- Chinese fonts load slowly: display fallback first, and switch once loaded

### Misaligned Layout

- Check if `box-sizing: border-box` is applied globally
- Check the `*  margin: 0; padding: 0` reset
- Turn on gridlines in Chrome DevTools to inspect the actual layout

## Verification = The Designer's Second Set of Eyes

**Always double-check it yourself.** When AI writes code, the following often occurs:

- It looks correct, but there are bugs in interaction
- The static screenshot looks good, but it misaligns during scrolling
- It looks great on wide screens but breaks on narrow ones
- Forgot to test Dark Mode
- Some components do not respond after toggling tweaks

**A final 1-minute verification can save 1 hour of rework.**

## Common Verification Script Commands

```bash
# Basic: Open + Screenshot + Error Capture
python verify.py design.html

# Multi-Viewport
python verify.py design.html --viewports 1920x1080,375x667

# Multi-Slide
python verify.py deck.html --slides 10

# Output to designated directory
python verify.py design.html --output ./screenshots/

# headless=false, opens a real browser for you to see
python verify.py design.html --show
```
