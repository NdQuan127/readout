# Tweaks: Real-time Parameter Tuning for Design Variations

Tweaks is a core capability in this skill—allowing users to switch variations and adjust parameters in real time without modifying the code.

**Cross-Agent Environment Adaptation**: Some design-agent native environments (such as Claude.ai Artifacts) rely on the host's `postMessage` to write tweak values back to the source code for persistence. This skill adopts a **pure frontend localStorage approach**—the effect is the same (state is preserved on refresh), but persistence happens in the browser's `localStorage` rather than the source code files. This approach works in any agent environment (Claude Code / Codex / Cursor / Trae / etc.).

## When to Add Tweaks

- The user explicitly requests "parameter tuning" or "switching between multiple versions"
- When a design has multiple variations that need to be compared
- The user did not state it explicitly, but you subjectively judge that **adding a few inspiring tweaks will help the user see possibilities**

Default Recommendation: **Add 2-3 tweaks to every design** (color themes, font sizes, layout variations) even if the user didn't ask—letting the user see the space of possibilities is part of the design service.

## Implementation Method (Pure Frontend Version)

### Basic Structure

```jsx
const TWEAK_DEFAULTS = {
  "primaryColor": "#D97757",
  "fontSize": 16,
  "density": "comfortable",
  "dark": false
};

function useTweaks() {
  const [tweaks, setTweaks] = React.useState(() => {
    try {
      const stored = localStorage.getItem('design-tweaks');
      return stored ? { ...TWEAK_DEFAULTS, ...JSON.parse(stored) } : TWEAK_DEFAULTS;
    } catch {
      return TWEAK_DEFAULTS;
    }
  });

  const update = (patch) => {
    const next = { ...tweaks, ...patch };
    setTweaks(next);
    try {
      localStorage.setItem('design-tweaks', JSON.stringify(next));
    } catch {}
  };

  const reset = () => {
    setTweaks(TWEAK_DEFAULTS);
    try {
      localStorage.removeItem('design-tweaks');
    } catch {}
  };

  return { tweaks, update, reset };
}
```

### Tweaks Panel UI

A floating panel in the bottom-right corner. It is collapsible:

```jsx
function TweaksPanel() {
  const { tweaks, update, reset } = useTweaks();
  const [open, setOpen] = React.useState(false);

  return (
    <div style={{
      position: 'fixed',
      bottom: 20,
      right: 20,
      zIndex: 9999,
    }}>
      {open ? (
        <div style={{
          background: 'white',
          border: '1px solid #e5e5e5',
          borderRadius: 12,
          padding: 20,
          boxShadow: '0 10px 40px rgba(0,0,0,0.12)',
          width: 280,
          fontFamily: 'system-ui',
          fontSize: 13,
        }}>
          <div style={{ 
            display: 'flex', 
            justifyContent: 'space-between', 
            alignItems: 'center',
            marginBottom: 16,
          }}>
            <strong>Tweaks</strong>
            <button onClick={() => setOpen(false)} style={{
              border: 'none', background: 'none', cursor: 'pointer', fontSize: 16,
            }}>×</button>
          </div>

          {/* Color */}
          <label style={{ display: 'block', marginBottom: 12 }}>
            <div style={{ marginBottom: 4, color: '#666' }}>Primary Color</div>
            <input 
              type="color" 
              value={tweaks.primaryColor} 
              onChange={e => update({ primaryColor: e.target.value })}
              style={{ width: '100%', height: 32 }}
            />
          </label>

          {/* Font size slider */}
          <label style={{ display: 'block', marginBottom: 12 }}>
            <div style={{ marginBottom: 4, color: '#666' }}>Font Size ({tweaks.fontSize}px)</div>
            <input 
              type="range" 
              min={12} max={24} step={1}
              value={tweaks.fontSize}
              onChange={e => update({ fontSize: +e.target.value })}
              style={{ width: '100%' }}
            />
          </label>

          {/* Density options */}
          <label style={{ display: 'block', marginBottom: 12 }}>
            <div style={{ marginBottom: 4, color: '#666' }}>Density</div>
            <select 
              value={tweaks.density}
              onChange={e => update({ density: e.target.value })}
              style={{ width: '100%', padding: 6 }}
            >
              <option value="compact">Compact</option>
              <option value="comfortable">Comfortable</option>
              <option value="spacious">Spacious</option>
            </select>
          </label>

          {/* Dark mode toggle */}
          <label style={{ 
            display: 'flex', 
            alignItems: 'center',
            gap: 8,
            marginBottom: 16,
          }}>
            <input 
              type="checkbox" 
              checked={tweaks.dark}
              onChange={e => update({ dark: e.target.checked })}
            />
            <span>Dark Mode</span>
          </label>

          <button onClick={reset} style={{
            width: '100%',
            padding: '8px 12px',
            background: '#f5f5f5',
            border: 'none',
            borderRadius: 6,
            cursor: 'pointer',
            fontSize: 12,
          }}>Reset</button>
        </div>
      ) : (
        <button 
          onClick={() => setOpen(true)}
          style={{
            background: '#1A1A1A',
            color: 'white',
            border: 'none',
            borderRadius: 999,
            padding: '10px 16px',
            fontSize: 12,
            cursor: 'pointer',
            boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
          }}
        >⚙ Tweaks</button>
      )}
    </div>
  );
}
```

### Applying Tweaks

Use Tweaks in the main component:

```jsx
function App() {
  const { tweaks } = useTweaks();

  return (
    <div style={{
      '--primary': tweaks.primaryColor,
      '--font-size': `${tweaks.fontSize}px`,
      background: tweaks.dark ? '#0A0A0A' : '#FAFAFA',
      color: tweaks.dark ? '#FAFAFA' : '#1A1A1A',
    }}>
      {/* Your content */}
      <TweaksPanel />
    </div>
  );
}
```

Using variables in CSS:

```css
button.cta {
  background: var(--primary);
  color: white;
  font-size: var(--font-size);
}
```

## Typical Tweak Options

What tweaks to add to different types of designs:

### General
- Primary color (color picker)
- Font size (slider 12-24px)
- Typeface (select: display font vs body font)
- Dark mode (toggle)

### Slide Deck
- Theme (light/dark/brand)
- Background style (solid/gradient/image)
- Type contrast (more decorative vs. more restrained)
- Information density (minimal/standard/dense)

### Product Prototype
- Layout variations (layout A / B / C)
- Interaction speed (animation speed 0.5x-2x)
- Amount of data (number of mock data items: 5/20/100)
- State (empty/loading/success/error)

### Animation
- Speed (0.5x-2x)
- Loop (once/loop/ping-pong)
- Easing (linear/easeOut/spring)

### Landing Page
- Hero style (image/gradient/pattern/solid)
- CTA copy (several variations)
- Structure (single column / two column / sidebar)

## Tweaks Design Principles

### 1. Meaningful Options, Not Restless Fiddling

Each tweak must present **real design choices**. Avoid adding tweaks that no one would actually use (such as a border-radius slider from 0-50px, where users find all intermediate values ugly).

A good tweak exposes **discrete, well-thought-out variations**:
- "Corner Radius Style": No round corners / Slightly rounded / Heavily rounded (three options)
- Instead of: "Corner Radius": 0-50px slider

### 2. Less is More

A Tweaks panel for a design should have **at most 5-6** options. Any more and it turns into a "configuration page," defeating the purpose of rapidly exploring variations.

### 3. The Default Value is the Completed Design

Tweaks are the **icing on the cake**. The default value must itself be a complete, publishable design. What users see when they close the Tweaks panel is the final output.

### 4. Logical Grouping

Group options logically when there are many:

```
---- Visual ----
Primary Color | Font Size | Dark Mode

---- Layout ----
Density | Sidebar Position

---- Content ----
Display Data Count | State
```

## Forward Compatibility with Source-Level Persistence Host

If you want the design to run in environments supporting source-level tweaks (such as Claude.ai Artifacts) in the future, retain the **EDITMODE marker block**:

```jsx
const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "primaryColor": "#D97757",
  "fontSize": 16,
  "density": "comfortable",
  "dark": false
}/*EDITMODE-END*/;
```

The marker block has **no effect** in the localStorage approach (acting as a normal comment), but it will be read by hosts that support writing back to source code, enabling source-level persistence. Adding this is harmless to the current environment while maintaining forward compatibility.

## Frequently Asked Questions

**Tweaks panel blocks design content**
→ Make it dismissible. Keep it collapsed by default, displaying a small button that expands only when the user clicks it.

**Users have to repeat settings after switching tweaks**
→ It already uses localStorage. If it doesn't persist after refresh, check if localStorage is available (incognito mode will fail, so use catch block).

**Multiple HTML pages want to share tweaks**
→ Add a project name to the localStorage key: `design-tweaks-[projectName]`.

**I want to establish dependencies/relations between tweaks**
→ Add logic in `update`:

```jsx
const update = (patch) => {
  let next = { ...tweaks, ...patch };
  // Dependency: auto-switch font color when dark mode is selected
  if (patch.dark === true && !patch.textColor) {
    next.textColor = '#F0EEE6';
  }
  setTweaks(next);
  localStorage.setItem(...);
};
```
