# Design Context: Starting from the Existing Context

**This is the single most important thing for this skill.**

Good hi-fi design must grow from the existing design context. **Creating hi-fi designs out of thin air is a last resort and will definitely produce generic work.** Therefore, at the start of every design task, first ask: is there anything we can refer to?

## What is Design Context

In descending order of priority:

### 1. The User's Design System/UI Kit
The user's own product's existing component library, color tokens, typography specifications, and icon system. **The most perfect scenario.**

### 2. The User's Codebase
If the user has provided a codebase, it will contain live component implementations. Read those component files:
- `theme.ts` / `colors.ts` / `tokens.css` / `_variables.scss`
- Specific components (`Button.tsx`, `Card.tsx`)
- Layout scaffold (`App.tsx`, `MainLayout.tsx`)
- Global stylesheets

**Read the code and copy the exact values**: hex codes, spacing scale, font stack, border radius. Do not redraw from memory.

### 3. The User's Published Product
If the user has a live product but hasn't provided the code, use Playwright or ask the user to provide screenshots.

```bash
# Capture a screenshot of a public URL using Playwright
npx playwright screenshot https://example.com screenshot.png --viewport-size=1920,1080
```

This lets you see the real visual vocabulary.

### 4. Brand Guidelines / Logo / Existing Assets
The user might have: Logo files, brand color specifications, marketing materials, slide templates. All of these are context.

### 5. Competitor References
If the user says "like website XX" — ask them to provide URLs or screenshots. **Do not** build based on vague impressions from your training data.

### 6. Known Design Systems (Fallback)
If none of the above are available, use a well-known design system as a base:
- Apple HIG
- Material Design 3
- Radix Colors (color palette)
- shadcn/ui (components)
- Tailwind default palette

Clearly tell the user what you are using, making it clear that this is a starting point, not the final version.

## Process of Obtaining Context

### Step 1: Ask the User

Must-ask checklist at the start of a task (from `workflow.md`):

```markdown
1. Do you have an existing design system/UI kit/component library? Where is it?
2. Are there any brand guidelines, color/font specifications?
3. Can you provide screenshots or URLs of your existing products?
4. Is there a codebase I can read?
```

### Step 2: Help Them Find It When the User Says "No"

Don't just give up. Try:

```markdown
Let me see if there are any clues:
- Do you have related designs from your previous projects?
- What colors/fonts does your company's marketing website use?
- What style is your product's Logo? Can you give me an image of it?
- Are there any products you admire that we can use as a reference?
```

### Step 3: Read All Context That Can Be Found

If the user provides a codebase path, read it:
1. **First, list the file structure**: Look for style/theme/component-related files
2. **Read theme/token files**: Extract specific hex/px values
3. **Read 2-3 representative components**: Inspect the visual vocabulary (hover states, shadows, borders, padding patterns)
4. **Read the global stylesheet**: Basic resets, font loading
5. **If there are Figma links/screenshots**: Look at the images, but **trust the code more**

**Important**: **Do not** just look at it once and design from memory. You have only truly extracted the context when you've gathered 30+ specific values from reading the code.

### Step 4: Vocalize the System You Are Going to Use

After reviewing the context, communicate the system you will use to the user:

```markdown
Based on your codebase and product screenshots, here is the design system I have extracted:

**Colors**
- Primary: #C27558 (from tokens.css)
- Background: #FDF9F0
- Text: #1A1A1A
- Muted: #6B6B6B

**Typography**
- Display: Instrument Serif (from @font-face in global.css)
- Body: Geist Sans
- Mono: JetBrains Mono

**Spacing** (from your scale system)
- 4, 8, 12, 16, 24, 32, 48, 64

**Shadow Pattern**
- `0 1px 2px rgba(0,0,0,0.04)` (subtle card)
- `0 10px 40px rgba(0,0,0,0.1)` (elevated modal)

**Border-radius**
- Small components: 4px, Cards: 12px, Buttons: 8px

**Component Vocabulary**
- Button: filled primary, outlined secondary, ghost tertiary, all with 8px border-radius
- Card: white background, subtle shadow, no border

I will start working based on this system. Does this look good?
```

Proceed only after the user confirms.

## Designing from Scratch (Fallback when there is no Context)

**Strong warning**: The output quality in this scenario will drop significantly. State this clearly to the user.

```markdown
Since you don't have a design context, I can only design based on general intuition.
The output will likely look "fine but generic."
Would you like to proceed anyway, or would you prefer to provide some reference materials first?
```

If the user insists on you proceeding, make decisions in the following order:

### 1. Choose an aesthetic direction
Do not provide generic results. Pick a clear direction:
- brutally minimal
- editorial/magazine
- brutalist/raw
- organic/natural
- luxury/refined
- playful/toy
- retro-futuristic
- soft/pastel

Tell the user which one you chose.

### 2. Choose a known design system as the skeleton
- Use Radix Colors for color palettes (https://www.radix-ui.com/colors)
- Use shadcn/ui for component vocabulary (https://ui.shadcn.com)
- Use Tailwind spacing scale (multiples of 4)

### 3. Choose distinctive font pairings

Do not use Inter/Roboto. Recommended pairings (available for free from Google Fonts):
- Instrument Serif + Geist Sans
- Cormorant Garamond + Inter Tight
- Bricolage Grotesque + Söhne (paid)
- Fraunces + Work Sans (note that Fraunces has been overused by AI)
- JetBrains Mono + Geist Sans (technical feel)

### 4. Provide reasoning for every key decision

Do not choose silently. Write it in an HTML comment:

```html
<!--
Design decisions:
- Primary color: warm terracotta (oklch 0.65 0.18 25) — fits the "editorial" direction  
- Display: Instrument Serif for humanist, literary feel
- Body: Geist Sans for cleanness contrast
- No gradients — committed to minimal, no AI slop
- Spacing: 8px base, golden ratio friendly (8/13/21/34)
-->
```

## Import Strategy (When the user provides a codebase)

If the user says "import this codebase as reference":

### Small (<50 files)
Read all of them to internalize the context.

### Medium (50-500 files)
Focus on:
- `src/components/` or `components/`
- All styles/tokens/theme related files
- 2-3 representative full-page components (`Home.tsx`, `Dashboard.tsx`)

### Large (>500 files)
Ask the user to specify the focus:
- "I want to build a settings page" → Read existing settings-related files
- "I want to build a new feature" → Read the global layout shell + the closest reference
- Prioritize accuracy over completeness

## Collaboration with Figma / Design Drafts

If the user provides a Figma link:

- **Do not** expect to directly "convert Figma to HTML" — that requires additional tooling.
- Figma links are usually not publicly accessible.
- Ask the user to: export it as a **screenshot** and send it to you + tell you the specific color/spacing values.

If they only provide a Figma screenshot, tell the user:
- I can see the visuals, but I cannot retrieve exact values.
- Please tell me the key values (hex, px), or export them as code (supported by Figma).

## Final Reminders

**The ceiling of a project's design quality is determined by the quality of the context you obtain.**

Spending 10 minutes gathering context is more valuable than spending an hour drawing hi-fi designs out of thin air.

**When there is no context, prioritize asking the user for it instead of forcing a design blindly.**
