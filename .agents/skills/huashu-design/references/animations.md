# Animations: Timeline Animation Engine

Read this when creating animations/HTML motion design. Principles, usage, and typical patterns.

## Core Pattern: Stage + Sprite

Our animation system (`assets/animations.jsx`) provides a timeline-driven engine:

- **`<Stage>`**: The container for the entire animation, automatically providing auto-scale (fit viewport) + scrubber + play/pause/loop controls
- **`<Sprite start end>`**: Time segment. A Sprite is only rendered during the time from `start` to `end`. Inside the Sprite, you can use the `useSprite()` hook to read its local progress `t` (0→1)
- **`useTime()`**: Read the current global time (in seconds)
- **`Easing.easeInOut` / `Easing.easeOut` / ...**: Easing functions
- **`interpolate(t, from, to, easing?)`**: Interpolate based on `t`

This pattern draws inspiration from Remotion and After Effects, but is lightweight and has zero dependencies.

## Getting Started

```html
<script type="text/babel" src="animations.jsx"></script>
<script type="text/babel">
  const { Stage, Sprite, useTime, useSprite, Easing, interpolate } = window.Animations;

  function Title() {
    const { t } = useSprite();  // Local progress 0→1
    const opacity = interpolate(t, [0, 1], [0, 1], Easing.easeOut);
    const y = interpolate(t, [0, 1], [40, 0], Easing.easeOut);
    return (
      <h1 style={{ 
        opacity, 
        transform: `translateY(${y}px)`,
        fontSize: 120,
        fontWeight: 900,
      }}>
        Hello.
      </h1>
    );
  }

  function Scene() {
    return (
      <Stage duration={10}>  {/* 10-second animation */}
        <Sprite start={0} end={3}>
          <Title />
        </Sprite>
        <Sprite start={2} end={5}>
          <SubTitle />
        </Sprite>
        {/* ... */}
      </Stage>
    );
  }

  const root = ReactDOM.createRoot(document.getElementById('root'));
  root.render(<Scene />);
</script>
```

## Common Animation Patterns

### 1. Fade In / Fade Out

```jsx
function FadeIn({ children }) {
  const { t } = useSprite();
  const opacity = interpolate(t, [0, 0.3], [0, 1], Easing.easeOut);
  return <div style={{ opacity }}>{children}</div>;
}
```

**Note the Range**: `[0, 0.3]` means the fade-in completes in the first 30% of the sprite's duration, and `opacity = 1` is maintained for the rest.

### 2. Slide In

```jsx
function SlideIn({ children, from = 'left' }) {
  const { t } = useSprite();
  const progress = interpolate(t, [0, 0.4], [0, 1], Easing.easeOut);
  const offset = (1 - progress) * 100;
  const directions = {
    left: `translateX(-${offset}px)`,
    right: `translateX(${offset}px)`,
    top: `translateY(-${offset}px)`,
    bottom: `translateY(${offset}px)`,
  };
  return (
    <div style={{
      transform: directions[from],
      opacity: progress,
    }}>
      {children}
    </div>
  );
}
```

### 3. Character-by-Character Typewriter

```jsx
function Typewriter({ text }) {
  const { t } = useSprite();
  const charCount = Math.floor(text.length * Math.min(t * 2, 1));
  return <span>{text.slice(0, charCount)}</span>;
}
```

### 4. Number Count-Up

```jsx
function CountUp({ from = 0, to = 100, duration = 0.6 }) {
  const { t } = useSprite();
  const progress = interpolate(t, [0, duration], [0, 1], Easing.easeOut);
  const value = Math.floor(from + (to - from) * progress);
  return <span>{value.toLocaleString()}</span>;
}
```

### 5. Step-by-Step Explanation (Typical Educational Animation)

```jsx
function Scene() {
  return (
    <Stage duration={20}>
      {/* Phase 1: Present the problem */}
      <Sprite start={0} end={4}>
        <Problem />
      </Sprite>

      {/* Phase 2: Explain the approach */}
      <Sprite start={4} end={10}>
        <Approach />
      </Sprite>

      {/* Phase 3: Show results */}
      <Sprite start={10} end={16}>
        <Result />
      </Sprite>

      {/* Captions displayed throughout */}
      <Sprite start={0} end={20}>
        <Caption />
      </Sprite>
    </Stage>
  );
}
```

## Easing Functions

Preset easing curves:

| Easing | Characteristics | Usage |
|--------|-----------------|-------|
| `linear` | Constant speed | Scrolling captions, continuous animations |
| `easeIn` | Slow → Fast | Exits, fade-outs |
| `easeOut` | Fast → Slow | Entrances, fade-ins |
| `easeInOut` | Slow → Fast → Slow | Position changes |
| **`expoOut`** ⭐ | **Exponential ease-out** | **Anthropic-grade primary easing** (physical weight/inertia) |
| **`overshoot`** ⭐ | **Elastic overshoot** | **Toggles / Button pop-ups / Emphasized interactions** |
| `spring` | Spring | Interactive feedback, resetting geometric shapes |
| `anticipation` | Anticipation (reverse then forward) | Emphasizing actions |

**Use `expoOut` as the default primary easing** (not `easeOut`) — see `animation-best-practices.md` §2.

Use `expoOut` for entrances, `easeIn` for exits, and `overshoot` for toggles — the fundamental principles of Anthropic-grade animations.

## Rhythm and Duration Guide

### Micro-interactions (0.1 - 0.3 seconds)
- Button hover
- Card expand
- Tooltip entrance

### UI Transitions (0.3 - 0.8 seconds)
- Page transitions
- Modal entrances
- List item additions

### Narrative Animations (2 - 10 seconds per segment)
- A single phase of concept explanation
- Data chart reveals
- Scene transitions

### Max 10 Seconds per Narrative Segment
Human attention span is limited. Spend at most 10 seconds explaining one concept, then move to the next.

## Workflow for Designing Animations

### 1. Content and Story First, Animation Second

**Incorrect**: Deciding to make a fancy animation first, then squeezing in content.

**Correct**: Clarifying what information to convey first, then using animation to serve that message.

Animation is a **signal**, not **decoration**. A fade-in emphasizes that "this is important, look here" — if everything fades in, the signal loses its meaning.

### 2. Map Out Timelines by Scene

```
0:00 - 0:03   Problem appears (fade-in)
0:03 - 0:06   Problem zooms and pans/expands (zoom+pan)
0:06 - 0:09   Solution appears (slide-in from right)
0:09 - 0:12   Solution explanation unfolds (typewriter)
0:12 - 0:15   Result demonstration (counter-up + chart reveal)
0:15 - 0:18   One-sentence summary (static, 3 seconds to read)
0:18 - 0:20   CTA or fade-out
```

Write the components only after mapping out the timeline.

### 3. Assets First

Prepare the images, icons, and fonts needed for the animation **in advance**. Do not stop in the middle of creation to search for assets — it breaks the creative flow.

## Troubleshooting & FAQ

**Stuttering Animations**
→ Usually caused by layout thrashing. Animate `transform` and `opacity` instead of changing properties like `top`, `left`, `width`, `height`, or `margin`. The browser GPU accelerates `transform` operations.

**Animations Too Fast to Follow**
→ It takes 100–150ms for a person to read a Chinese character and 300–500ms for a word. If you are using text to tell a story, keep each sentence on screen for at least 3 seconds.

**Animations Too Slow or Boring**
→ Keep interesting visual changes dense. Static screens for more than 5 seconds will feel tedious.

**Multiple Animations Interfering with Each Other**
→ Use CSS `will-change: transform` to hint to the browser beforehand that the element will animate, reducing reflows.

**Recording to Video**
→ Use the toolchain built into this skill (one command outputs three formats): see `video-export.md`
- `scripts/render-video.js` — HTML → 25fps MP4 (Playwright + ffmpeg)
- `scripts/convert-formats.sh` — 25fps MP4 → 60fps MP4 + optimized GIF
- Need more precise frame-by-frame rendering? Make `render(t)` a pure function, see item 5 in `animation-pitfalls.md`

## Integration with Video Tools

This skill focuses on **HTML animations** (running in the browser). If the final output is intended as video footage:

- **Short animations/concept demos**: Build HTML animations using the method described here → Screen recording
- **Long videos/narratives**: This skill specializes in HTML animations; for long videos, use AI video generation skills or professional video editing software
- **Motion graphics**: Professional tools like After Effects or Motion Canvas are more suitable

## Regarding Popmotion and Other Libraries

If you absolutely need physics-based animations (spring, decay, keyframes with precise timing) that our engine cannot handle, you can fall back to Popmotion:

```html
<script src="https://unpkg.com/popmotion@11.0.5/dist/popmotion.min.js"></script>
```

But **try our engine first**. It covers 90% of use cases.
