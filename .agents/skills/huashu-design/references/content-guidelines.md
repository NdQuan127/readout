# Content Guidelines: Anti-AI Slop, Content Principles, and Scale Standards

The easiest trap to fall into in AI design. This is a list of "what not to do", which is more important than "what to do"—because AI slop is the default; if you do not actively avoid it, it will happen.

## AI Slop Complete Blacklist

### Visual Traps

**❌ Aggressive Gradient Backgrounds**
- Purple → pink → blue full-screen gradients (the typical signature of AI-generated webpages)
- Any direction of rainbow gradients
- Mesh gradients covering the entire background
- ✅ If gradients are to be used: subtle, monochromatic, and intentional accents (such as button hover states)

**❌ Rounded cards with a left border accent color**
```css
/* This is the typical signature of an AI-flavored card */
.card {
  border-radius: 12px;
  border-left: 4px solid #3b82f6;
  padding: 16px;
}
```
This type of card is ubiquitous in AI-generated dashboards. Want to add emphasis? Use more design-centric approaches: background color contrast, font weight/size contrast, plain dividers, or simply not dividing into cards at all.

**❌ Emoji Decorations**
Unless the brand itself uses emojis (e.g., Notion, Slack), do not place emojis in the UI. **In particular, do not use**:
- Emojis like 🚀 ⚡️ ✨ 🎯 💡 in front of headers
- ✅ in feature lists
- Emojis like → in CTA buttons (arrow symbols alone are fine, but emoji arrows are not)

If there are no icons, use real icon libraries (such as Lucide, Heroicons, or Phosphor), or use placeholders.

**❌ Using SVG to draw imagery**
Do not attempt to use SVG to draw: people, scenes, devices, objects, or abstract art. SVG imagery drawn by AI immediately screams "AI", looking childish and cheap. **A grey rectangle with a text label like "Illustration Placeholder 1200×800" is a hundred times better than a poorly executed SVG hero illustration**.

The only scenarios where SVG is acceptable:
- Actual icons (16×16 to 32×32 size)
- Geometric shapes as decorative elements
- Charts for data visualization

**❌ Excessive iconography**
Not every header, feature, or section needs an icon. Overusing icons makes the interface look like a toy. Less is more.

**❌ "Data slop"**
Fabricated decorative statistics:
- "10,000+ happy customers" (when you don't even know if they exist)
- "99.9% uptime" (do not write it if there is no real data)
- Decorative "metric cards" composed of icons, numbers, and words
- Fancy, over-styled mock tables filled with fake data

If there is no real data, leave placeholders or ask the user for it.

**❌ "Quote slop"**
Fabricated user reviews or famous quotes used to decorate the page. Leave placeholders and ask the user for real quotes.

### Typography Traps

**❌ Avoid these overused fonts**:
- Inter (the default for AI-generated webpages)
- Roboto
- Arial / Helvetica
- Pure system font stacks
- Fraunces (overused as soon as AI discovered it)
- Space Grotesk (AI's recent favorite)

**✅ Use distinctive display + body font pairings**. Inspiration directions:
- Serif display + sans-serif body (for an editorial feel)
- Monospace display + sans-serif body (for a technical feel)
- Heavy display + light body (for contrast)
- Variable fonts to animate font weight in the hero section

Font resources:
- Underrated options from Google Fonts (Instrument Serif, Cormorant, Bricolage Grotesque, JetBrains Mono)
- Open-source font sites (sister fonts of Fraunces, Adobe Fonts)
- Do not make up font names out of thin air

### Color Traps

**❌ Inventing colors out of thin air**
Do not design a whole set of unfamiliar colors from scratch. This usually leads to disharmony.

**✅ Strategies**:
1. Brand color exists → Use the brand color, and use OKLCH interpolation for missing color tokens
2. No brand color but references exist → Color-pick from screenshots of reference products
3. Completely from scratch → Choose a known color system (Radix Colors / Tailwind's default palette / Anthropic's brand colors), and do not tweak them yourself

**Defining colors with OKLCH** is the most modern approach:
```css
:root {
  --primary: oklch(0.65 0.18 25);      /* Warm terracotta */
  --primary-light: oklch(0.85 0.08 25); /* Same hue, lighter */
  --primary-dark: oklch(0.45 0.20 25);  /* Same hue, darker */
}
```
OKLCH ensures that the hue does not shift when adjusting lightness, making it much better than HSL.

**❌ Carelessly inverting colors for dark mode**
Dark mode is not just about inverting colors. A good dark mode requires readjusting saturation, contrast, and accent colors. If you don't want to design dark mode, don't do it.

### Layout Traps

**❌ Overuse of Bento Grids**
Every AI-generated landing page tries to use a bento grid. Unless your information structure genuinely suits a bento layout, use other layouts.

**❌ Large hero + 3-column features + testimonials + CTA**
This landing page template is overused. If you want to innovate, actually innovate.

**❌ Every card in a card grid looking identical**
Asymmetric layouts, varying card sizes, cards with images vs. text-only, or cards spanning columns—this is what looks like a real designer's work.

## Content Principles

### 1. Don't add filler content

Every element must earn its place. Empty space is a design challenge to be solved with **composition** (contrast, rhythm, whitespace), **not** by stuffing it with content.

**Questions to identify filler**:
- If this content is removed, will the design get worse? If the answer is "no", remove it.
- What real problem does this element solve? If the answer is "to make the page look less empty", delete it.
- Is this statistic/quote/feature backed by real data? If not, do not write it out of thin air.

“One thousand no's for every yes.”

### 2. Ask before adding material

Think adding an extra paragraph, page, or section will make it better? Ask the user first; do not add it unilaterally.

Reasons:
- The user knows their audience better than you do
- Adding content has costs, and the user might not want it
- Unilaterally adding content violates the dynamics of the "junior designer reporting work" relationship

### 3. Create a system up front

After exploring the design context, **first describe the system you intend to use verbally** and get the user's confirmation:

```markdown
My design system:
- Color: #1A1A1A main + #F0EEE6 background + #D97757 accent (from your brand)
- Typography: Instrument Serif for display + Geist Sans for body
- Rhythm: Section titles use full-bleed colored backgrounds + white text; regular sections use white backgrounds
- Imagery: Full-bleed photo for the hero section; placeholders for the feature sections awaiting your content
- Use at most 2 background colors to avoid clutter

Please confirm this direction and I will begin the work.
```

Wait for user confirmation before starting. This check-in avoids "realizing the direction is wrong halfway through".

## Scale Specifications

### Slides (1920×1080)

- Body text minimum **24px**, ideally 28-36px
- Headlines 60-120px
- Section titles 80-160px
- Hero headlines can use large type sizes of 180-240px
- Never use text sizes <24px on slides

### Printed Documents

- Body text minimum **10pt** (≈13.3px), ideally 11-12pt
- Headlines 18-36pt
- Captions 8-9pt

### Web & Mobile

- Body text minimum **14px** (use 16px to be accessible/elderly-friendly)
- Mobile body text **16px** (to avoid automatic zoom on iOS)
- Hit targets (tappable elements) minimum **44×44px**
- Line height 1.5-1.7 (1.7-1.8 for Chinese)

### Contrast

- Body text vs. background **at least 4.5:1** (WCAG AA)
- Large text vs. background **at least 3:1**
- Verify using Chrome DevTools accessibility tools

## CSS Superpowers

**Advanced CSS features** are a designer's best friend. Use them boldly:

### Typography

```css
/* Balances headings for cleaner line breaks, preventing single orphan words on the last line */
h1, h2, h3 { text-wrap: balance; }

/* Prevents widows and orphans in body text */
p { text-wrap: pretty; }

/* Essential for Chinese typography: punctuation squeeze, line start/end control */
p { 
  text-spacing-trim: space-all;
  hanging-punctuation: first;
}
```

### Layout

```css
/* CSS Grid + named areas = Extreme readability */
.layout {
  display: grid;
  grid-template-areas:
    "header header"
    "sidebar main"
    "footer footer";
  grid-template-columns: 240px 1fr;
  grid-template-rows: auto 1fr auto;
}

/* Subgrid to align card content */
.card { display: grid; grid-template-rows: subgrid; }
```

### Visual Effects

```css
/* Well-designed scrollbars */
* { scrollbar-width: thin; scrollbar-color: #666 transparent; }

/* Glassmorphism (use sparingly) */
.glass {
  backdrop-filter: blur(20px) saturate(150%);
  background: color-mix(in oklch, white 70%, transparent);
}

/* View transitions API for smooth page navigation */
@view-transition { navigation: auto; }
```

### Interaction

```css
/* The :has() selector makes conditional styling easy */
.card:has(img) { padding-top: 0; } /* Cards with images have no top padding */

/* Container queries make components truly responsive */
@container (min-width: 500px) { ... }

/* Modern color-mix function */
.button:hover {
  background: color-mix(in oklch, var(--primary) 85%, black);
}
```

## Quick Reference Decision Tree: When in Doubt

- Want to add a gradient? → Most likely don't.
- Want to add an emoji? → Don't.
- Want to add rounded corners + border-left accent to a card? → Don't. Find another way.
- Want to use SVG to draw a hero illustration? → Don't. Use a placeholder.
- Want to add a quote section as decoration? → Ask the user for real quotes first.
- Want to add a row of icon features? → Ask first if they are even necessary; they might not be.
- Use Inter? → Switch to a more distinctive font.
- Use purple gradients? → Switch to a well-reasoned color scheme.

**Whenever you feel "adding this would make it look better"—that is usually a sign of AI slop**. Build the absolute minimal version first, and add elements only when requested by the user.
