# Design Philosophy Showcases — Showcase Asset Index

> 8 scenarios × 3 styles = 24 pre-made design showcases
> Used in Phase 3 when recommending a design direction, to directly show "what this style looks like when built"

## Style Descriptions

| Code | School | Style Name | Visual Vibe |
|------|------|---------|---------|
| **Pentagram** | Information Architecture | Pentagram / Michael Bierut | Black-and-white restraint, Swiss grid, strong typographic hierarchy, #E63946 red accents |
| **Build** | Minimalism | Build Studio | Luxury-tier whitespace (70%+), subtle font weights (200-600), #D4A574 warm gold, refined |
| **Takram** | Eastern Philosophy | Takram | Soft tech aesthetic, natural colors (beige/gray/green), rounded corners, charts as art |

## Scenario Quick Reference

### Content Design Scenarios

| # | Scenario | Dimensions | Pentagram | Build | Takram |
|---|------|------|-----------|-------|--------|
| 1 | WeChat Cover | 1200×510 | `cover/cover-pentagram` | `cover/cover-build` | `cover/cover-takram` |
| 2 | PPT Data Slide | 1920×1080 | `ppt/ppt-pentagram` | `ppt/ppt-build` | `ppt/ppt-takram` |
| 3 | Vertical Infographic | 1080×1920 | `infographic/infographic-pentagram` | `infographic/infographic-build` | `infographic/infographic-takram` |

### Website Design Scenarios

| # | Scenario | Dimensions | Pentagram | Build | Takram |
|---|------|------|-----------|-------|--------|
| 4 | Personal Homepage | 1440×900 | `website-homepage/homepage-pentagram` | `website-homepage/homepage-build` | `website-homepage/homepage-takram` |
| 5 | AI Directory | 1440×900 | `website-ai-nav/ainav-pentagram` | `website-ai-nav/ainav-build` | `website-ai-nav/ainav-takram` |
| 6 | AI Writing Tool | 1440×900 | `website-ai-writing/aiwriting-pentagram` | `website-ai-writing/aiwriting-build` | `website-ai-writing/aiwriting-takram` |
| 7 | SaaS Landing Page | 1440×900 | `website-saas/saas-pentagram` | `website-saas/saas-build` | `website-saas/saas-takram` |
| 8 | Developer Docs | 1440×900 | `website-devdocs/devdocs-pentagram` | `website-devdocs/devdocs-build` | `website-devdocs/devdocs-takram` |

> Each entry contains both `.html` (source code) and `.png` (screenshot) files.

## Usage Instructions

### Referencing during Phase 3 Recommendation
After recommending a design direction, show the corresponding pre-made screenshots of the scenario:
```
"Here is what the WeChat cover looks like in the Pentagram style → [Show cover/cover-pentagram.png]"
"This is how a PPT data slide feels in the Takram style → [Show ppt/ppt-takram.png]"
```

### Scenario Matching Priority
1. **Exact Match**: The requested scenario matches exactly → Directly display the corresponding scenario.
2. **Similar Type**: No exact match but the type is similar → Display the closest matching scenario (e.g., "Product Website" → Display SaaS Landing Page).
3. **No Match**: No match at all → Skip the pre-made showcases and go directly to Phase 3.5 live generation.

### Side-by-Side Comparison
The 3 styles of the same scenario are suitable for side-by-side display to help users visually compare:
- "Here is the same WeChat cover implemented in 3 different styles"
- **Display Order**: Pentagram (rational restraint) → Build (luxurious minimalism) → Takram (soft & warm)

## Content Details

### WeChat Cover (cover/)
- Content: Claude Code Agent workflow — 8 parallel Agent architecture
- Pentagram: Giant red "8" + Swiss grid lines + data bars
- Build: Ultra-light font weight "Agent" suspended in 70%+ whitespace + warm gold thin lines
- Takram: 8-node radial flow chart as art + beige background

### PPT Data Slide (ppt/)
- Content: GLM-4.7 open-source model coding capability breakthrough (AIME 95.7 / SWE-bench 73.8% / τ²-Bench 87.4)
- Pentagram: 260px "95.7" anchor point + red/gray/light-gray contrast bar chart
- Build: Three sets of 120px ultra-light numbers suspended + warm gold gradient contrast bars
- Takram: SVG radar chart + three-color overlay + rounded data cards

### Vertical Infographic (infographic/)
- Content: AI memory system CLAUDE.md optimized from 93KB to 22KB
- Pentagram: Giant "93→22" numbers + numbered blocks + CSS data bars
- Build: Extreme whitespace + soft shadow cards + warm gold connector lines
- Takram: SVG donut chart + organic curved flow chart + frosted glass cards

### Personal Homepage (website-homepage/)
- Content: Indie developer Alex Chen's portfolio homepage
- Pentagram: 112px name + Swiss grid columns + editorial numbers
- Build: Glassmorphism navigation + floating stats cards + ultra-light font weights
- Takram: Paper texture + small circular avatar + hairline dividers + asymmetric layout

### AI Directory (website-ai-nav/)
- Content: AI Compass — 500+ AI tools directory
- Pentagram: Square-cornered search box + numbered tool lists + uppercase category tags
- Build: Rounded search box + refined white tool cards + pill tags
- Takram: Organic staggered card layout + soft category labels + diagrammatic connections

### AI Writing Tool (website-ai-writing/)
- Content: Inkwell — AI writing assistant
- Pentagram: 86px big headline + wireframe editor mockup + grid feature columns
- Build: Floating editor card + warm gold CTA + luxury writing experience
- Takram: Poetic serif headline + organic editor + flow chart

### SaaS Landing Page (website-saas/)
- Content: Meridian — Business Intelligence analysis platform
- Pentagram: Black-and-white split column layout + structured dashboard + 140px "3x" anchor point
- Build: Floating dashboard cards + SVG area chart + warm gold gradient
- Takram: Rounded bar chart + process nodes + soft earth tones

### Developer Docs (website-devdocs/)
- Content: Nexus API — Unified AI model gateway
- Pentagram: Left sidebar navigation + square-cornered code blocks + red string highlighting
- Build: Centered floating code card + soft shadows + warm gold icons
- Takram: Beige code block + flow chart connections + dashed feature cards

## File Statistics

- HTML source files: 24
- PNG screenshots: 24
- Total assets: 48 files

---

**Version**: v1.0
**Date Created**: 2026-02-13
**Applicable to**: design-philosophy skill Phase 3 recommendation phase
