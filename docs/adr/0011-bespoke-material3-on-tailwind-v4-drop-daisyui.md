# Adopt a bespoke Material 3 layer on Tailwind v4, drop DaisyUI

We are moving the whole web UI to a Material 3 visual language (green tonal
seed, light/dark). We decided to build M3 ourselves as design tokens + a thin
`@layer components` on top of **Tailwind v4** (CSS-first `@theme` + CSS
variables), with behaviour from `LiveView.JS` + minimal hooks, and to **remove
DaisyUI** rather than re-theme it. Behavioural primitives stay tiny: state
layers and the M3 switch are pure CSS (the switch is a styled native
checkbox); the only JavaScript in the M3 layer is a single delegated
`pointerdown` ripple listener.

## Considered Options

- **`@material/web` (official M3 web components).** Rejected. Google put it into
  **maintenance mode in June 2024** (engineers reassigned to the internal Wiz
  framework); roadmap frozen, no successor named. It also fights Phoenix
  LiveView: form inputs live in shadow DOM, so `phx-change`/`phx-submit` and DOM
  patching need bridging. Building the product's primary surface on a frozen,
  friction-heavy base was not worth it.
- **DaisyUI re-themed as M3 (keep it as the engine).** Rejected. DaisyUI's
  component anatomy is not M3-shaped, so reshaping it means fighting defaults and
  carrying tokens/components that never quite fit — the techdebt we are trying to
  avoid. The same objection applies to every other LiveView component library
  (Petal, SaladUI, Fluxon, Mishka): none is Material 3, so each is a non-M3
  design system bent into M3.
- **A CSS M3 dependency (Material Tailwind, tailwind-material-3, Tailmater).**
  Rejected as dependencies. All still assume the Tailwind v3 JS-config paradigm
  (`tailwind.config.js` / `@config`), which clashes with our v4 CSS-first setup;
  most are React-oriented. Tailmater is kept only as a *visual reference*, not
  installed.

## Consequences

- M3 here is "M3 in spirit," not pixel-perfect spec M3. The look is a faithful
  port of the approved `priv/prototypes/digest-7.html`, which is itself
  CSS-token M3 — so the approximation matches what was approved.
- We own and maintain the M3 component layer; nobody upstream patches it.
- Behaviour/a11y-heavy M3 components (date picker, menu, dialog with focus-trap)
  would have to be hand-built if ever needed. None are in current scope, and
  `@material/web` would not have helped without its own LiveView friction.
- `core_components.ex` is migrated off DaisyUI onto the M3 layer; the four
  `phx.gen.auth` pages (already English) inherit the new look through it.
