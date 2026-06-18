# Design Philosophy Style Library: 20 Systems

> A design style library for visual design (web, PPT, PDF, infographics, illustrations, apps, etc.).
> Each style provides: Philosophical Core + Core Features + Prompt DNA (used in combination with scene templates).

## Style × Scene × Execution Path Quick Reference Table

| Style | Web | PPT | PDF | Infographic | Cover | AI Generation | Best Path |
|------|:---:|:---:|:---:|:-----:|:---:|:-----:|---------|
| 01 Pentagram | ★★★ | ★★★ | ★★☆ | ★★☆ | ★★★ | ★☆☆ | HTML |
| 02 Stamen Design | ★★☆ | ★★☆ | ★★☆ | ★★★ | ★★☆ | ★★☆ | Hybrid |
| 03 Information Architects | ★★★ | ★☆☆ | ★★★ | ★☆☆ | ★☆☆ | ★☆☆ | HTML |
| 04 Fathom | ★★☆ | ★★★ | ★★★ | ★★★ | ★★☆ | ★☆☆ | HTML |
| 05 Locomotive | ★★★ | ★★☆ | ★☆☆ | ★☆☆ | ★★☆ | ★★☆ | Hybrid |
| 06 Active Theory | ★★★ | ★☆☆ | ★☆☆ | ★☆☆ | ★★☆ | ★★★ | AI Generation |
| 07 Field.io | ★★☆ | ★★☆ | ★☆☆ | ★★☆ | ★★★ | ★★★ | AI Generation |
| 08 Resn | ★★★ | ★☆☆ | ★☆☆ | ★☆☆ | ★★☆ | ★★☆ | AI Generation |
| 09 Experimental Jetset | ★★☆ | ★★☆ | ★★☆ | ★★☆ | ★★★ | ★★☆ | Hybrid |
| 10 Müller-Brockmann | ★★☆ | ★★★ | ★★★ | ★★★ | ★★☆ | ★☆☆ | HTML |
| 11 Build | ★★★ | ★★★ | ★★☆ | ★☆☆ | ★★★ | ★☆☆ | HTML |
| 12 Sagmeister & Walsh | ★★☆ | ★★★ | ★☆☆ | ★★☆ | ★★★ | ★★★ | AI Generation |
| 13 Zach Lieberman | ★☆☆ | ★☆☆ | ★☆☆ | ★★☆ | ★★★ | ★★★ | AI Generation |
| 14 Raven Kwok | ★☆☆ | ★★☆ | ★☆☆ | ★★☆ | ★★★ | ★★★ | AI Generation |
| 15 Ash Thorp | ★★☆ | ★★☆ | ★☆☆ | ★☆☆ | ★★★ | ★★★ | AI Generation |
| 16 Territory Studio | ★★☆ | ★★☆ | ★☆☆ | ★★☆ | ★★★ | ★★★ | AI Generation |
| 17 Takram | ★★★ | ★★★ | ★★★ | ★★☆ | ★★☆ | ★☆☆ | HTML |
| 18 Kenya Hara | ★★☆ | ★★★ | ★★★ | ★☆☆ | ★★★ | ★☆☆ | HTML |
| 19 Irma Boom | ★☆☆ | ★★☆ | ★★★ | ★★☆ | ★★★ | ★★☆ | Hybrid |
| 20 Neo Shen | ★★☆ | ★★☆ | ★★☆ | ★★☆ | ★★★ | ★★★ | AI Generation |

> Scene Adaptation: ★★★ = Highly Recommended / ★★☆ = Suitable / ★☆☆ = Requires Modification
> AI Generation: ★★★ = Excellent direct output / ★★☆ = Requires adjustment / ★☆☆ = HTML implementation recommended
> Best Path: AI Generation (Direct image output) / HTML (Code rendering, precise data) / Hybrid (HTML layout + AI illustration)

**Core Principle**: Styles with distinct visual elements (illustrations, particles, generative art) yield excellent direct AI outputs; styles that rely on precise typography and data (grids, information architecture, negative space/whitespace) are more controllable when rendered via HTML.

---

## I. Information Architecture School (01-04)
> Philosophy: "Data is not decoration; it is building material."

### 01. Pentagram - Michael Bierut Style
**Philosophy**: Type is language, grid is thought.
**Core Features**:
- Extremely restrained color palette (black, white + one brand color)
- Modern interpretation of the Swiss grid system
- Typography as the primary visual language
- Strategic use of negative space (60%+ whitespace)

**Prompt DNA**:
```
Pentagram/Michael Bierut style:
- Extreme typographic hierarchy, Helvetica/Univers family
- Swiss grid with precise mathematical spacing
- Black/white + one accent color (#HEX)
- Information architecture as visual structure
- 60%+ whitespace ratio
- Data visualization as primary decoration
```

**Key Work**: Hillary Clinton 2016 campaign identity
**Search Keywords**: pentagram hillary logo system

---

### 02. Stamen Design - Data Poetics
**Philosophy**: Making data a tangible landscape
**Core Features**:
- Cartography thinking applied to information design
- Algorithm-generated organic shapes
- Warm data visualization palettes (ochre, sage green, deep blue)
- Interactive hierarchical systems

**Prompt DNA**:
```
Stamen Design aesthetic:
- Cartographic approach to data visualization
- Organic, algorithm-generated patterns
- Warm palette (terracotta, sage green, deep blues)
- Layered information like topographic maps
- Hand-crafted feel despite digital precision
- Soft shadows and depth
```

**Key Work**: COVID-19 surge map
**Search Keywords**: stamen covid map visualization

---

### 03. Information Architects - Content-First Principle
**Philosophy**: Design is not decoration; it is the architecture of content.
**Core Features**:
- Extreme clarity of content hierarchy
- System fonts only (optimized for reading)
- Adherence to the classic blue hyperlink tradition
- Performance is aesthetics

**Prompt DNA**:
```
Information Architects philosophy:
- Content-first hierarchy, zero decorative elements
- System fonts only (SF Pro/Roboto/Inter)
- Classic blue hyperlinks (#0000EE)
- Reading-optimized line length (66 characters)
- Progressive disclosure of depth
- Text-heavy, fast-loading design
```

**Key Work**: iA Writer app
**Search Keywords**: information architects ia writer

---

### 04. Fathom Information Design - Scientific Narrative
**Philosophy**: Every single pixel must carry information.
**Core Features**:
- Rigor of scientific journals + elegance of design
- Precise visualization of quantitative data
- Calm, professional color schemes (gray, navy blue)
- Design integration of annotations and citation systems

**Prompt DNA**:
```
Fathom Information Design style:
- Scientific journal aesthetic meets modern design
- Precise data visualization (charts, timelines, scatter plots)
- Neutral scheme (grays, navy, one highlight color)
- Footnote/citation design integrated into layout
- Clean sans-serif (GT America/Graphik)
- Information density without clutter
```

**Key Work**: Bill & Melinda Gates Foundation Annual Report
**Search Keywords**: fathom information design gates foundation

---

## II. Motion Poetics School (05-08)
> Philosophy: "Technology itself is a form of fluid poetry."

### 05. Locomotive - Masters of Scrollytelling
**Philosophy**: Scrolling is not browsing; it is a journey.
**Core Features**:
- Silky-smooth parallax scrolling
- Cinematic storyboard narrative
- Bold spatial negative space
- Precise choreography of dynamic elements

**Prompt DNA**:
```
Locomotive scroll narrative style:
- Film-like scene composition with parallax depth
- Generous vertical spacing between sections
- Bold typography emerging from darkness
- Smooth motion blur effects
- Dark mode (near-black backgrounds)
- Strategic glowing accents
- Hero sections 100vh tall
```

**Key Work**: Lusion.co website
**Search Keywords**: locomotive scroll lusion

---

### 06. Active Theory - WebGL Poets
**Philosophy**: Making technology visible is making it understandable.
**Core Features**:
- 3D particle systems as the core element
- Real-time rendered data visualization
- Mouse interaction-driven world building
- Neon and deep space color schemes

**Prompt DNA**:
```
Active Theory WebGL aesthetic:
- Particle systems representing data flow
- 3D visualization in depth space
- Neon gradients (cyan/magenta/electric blue) on dark
- Mouse-reactive environment
- Depth of field and bokeh effects
- Floating UI with glassmorphism
```

**Key Work**: NASA Prospect
**Search Keywords**: active theory nasa webgl

---

### 07. Field.io - Algorithmic Aesthetics
**Philosophy**: Code is the designer.
**Core Features**:
- Generative art systems
- Dynamic graphics that differ with each visit
- Intelligent choreography of abstract geometry
- Balance between technology and artistry

**Prompt DNA**:
```
Field.io generative design style:
- Abstract geometric patterns, algorithmically generated
- Dynamic composition that feels computational
- Monochromatic base with vibrant accent
- Mathematical precision in spacing
- Voronoi diagrams or Delaunay triangulation
- Clean code aesthetic
```

**Key Work**: British Council digital installations
**Search Keywords**: field.io generative design

---

### 08. Resn - Narrative-Driven Interaction
**Philosophy**: Every click advances the story.
**Core Features**:
- Gamified user journeys
- Strong emotional design
- Deep integration of illustration and code
- Non-linear exploration experiences

**Prompt DNA**:
```
Resn interactive storytelling approach:
- Illustrative style mixed with UI elements
- Gamified exploration (progress indicators)
- Warm color palette despite tech subject
- Character-driven design
- Scroll-triggered animations
- Editorial illustration meets product design
```

**Key Work**: Resn.co.nz portfolio
**Search Keywords**: resn interactive storytelling

---

## III. Minimalism School (09-12)
> Philosophy: "Reduce until nothing more can be removed."

### 09. Experimental Jetset - Conceptual Minimalism
**Philosophy**: One idea = one form.
**Core Features**:
- A single visual metaphor running throughout the entire design
- Mondrian color palette of blue/red/yellow + black/white
- Typography as graphics
- Anti-commercial, honest design

**Prompt DNA**:
```
Experimental Jetset conceptual minimalism:
- Single visual metaphor for entire design
- Primary colors only (red/blue/yellow) + black/white
- Typography as main graphic element
- Grid-based with deliberate rule-breaking
- No photography, only type and geometry
- Anti-commercial, honest aesthetic
```

**Key Work**: Whitney Museum identity
**Search Keywords**: experimental jetset whitney responsive w

---

### 10. Müller-Brockmann Legacy - Swiss Grid Purism
**Philosophy**: Objectivity is beauty.
**Core Features**:
- Mathematically precise grid systems (8pt baseline)
- Absolute flush-left or centering
- One or two-color schemes
- Functionalism above all

**Prompt DNA**:
```
Josef Müller-Brockmann Swiss modernism:
- Mathematical grid system (8pt baseline)
- Strict alignment (flush left or centered)
- Two-color maximum (black + one accent)
- Akzidenz-Grotesk or similar rationalist typeface
- No decorative elements
- Timeless, objective aesthetic
```

**Key Work**: *Grid Systems in Graphic Design*
**Search Keywords**: muller brockmann grid systems poster

---

### 11. Build - Contemporary Minimalist Branding
**Philosophy**: Refined simplicity is harder than complexity.
**Core Features**:
- Luxury-grade whitespace (70%+)
- Subtle typographic weight contrast (200–600)
- Strategic use of a single accent color
- Rhythmic, breathing feel

**Prompt DNA**:
```
Build studio luxury minimalism:
- Generous whitespace (70%+ of area)
- Subtle typography weight shifts (200 to 600)
- Single accent color used sparingly
- High-end product photography aesthetic
- Soft shadows and subtle gradients
- Golden ratio proportions
```

**Key Work**: Build studio portfolio
**Search Keywords**: build studio london branding

---

### 12. Sagmeister & Walsh - Joyful Minimalism
**Philosophy**: Beauty is the emotional dimension of function.
**Core Features**:
- Unexpected bursts of color
- Fusion of handcrafted feel and digital
- Optimistic visual language
- Experimental yet legible

**Prompt DNA**:
```
Sagmeister & Walsh joyful philosophy:
- Unexpected color bursts on minimal base
- Handmade elements (physical objects in digital)
- Optimistic visual language
- Experimental typography that remains legible
- Human warmth through imperfection
- Mix of analog and digital aesthetics
```

**Key Work**: The Happy Show
**Search Keywords**: sagmeister walsh happy show

---

## IV. Experimental Avant-Garde School (13-16)
> Philosophy: "Breaking rules is creating rules."

### 13. Zach Lieberman - Code Poetics
**Philosophy**: Coding is painting.
**Core Features**:
- Algorithmic graphics with a hand-drawn feel
- Real-time generative art
- Pure black-and-white expression
- Visibility of the tool itself

**Prompt DNA**:
```
Zach Lieberman code-as-art style:
- Hand-drawn aesthetic generated by code
- Black and white only, no color
- Real-time generative patterns
- Sketch-like line quality
- Visible process/grid/construction lines
- Poetic interpretation of algorithms
```

**Key Work**: openFrameworks creative coding
**Search Keywords**: zach lieberman openframeworks generative

---

### 14. Raven Kwok - Parametric Aesthetics
**Philosophy**: The beauty of the system exceeds the beauty of individual elements.
**Core Features**:
- Fractal and recursive graphics
- High-contrast black and white
- Architectural information structures
- Algorithmic interpretation of Eastern gardens

**Prompt DNA**:
```
Raven Kwok parametric aesthetic:
- Fractal patterns and recursive structures
- High-contrast black and white
- Architectural visualization of data
- Chinese garden principles in algorithm form
- Intricate detail that rewards zooming
- Processing/Creative coding aesthetic
```

**Key Work**: Raven Kwok generative art exhibitions
**Search Keywords**: raven kwok processing generative art

---

### 15. Ash Thorp - Cyber Poetics
**Philosophy**: The future is not cold; it is a solitary poem.
**Core Features**:
- Cinematic lighting and shadow
- A warm version of cyberpunk (orange/teal, not cold blue)
- Narrative concept design
- Refinement of industrial aesthetics

**Prompt DNA**:
```
Ash Thorp cinematic concept art:
- Film-grade lighting and atmospheric effects
- Warm cyberpunk (orange/teal, NOT cold blue)
- Industrial design meets luxury
- Narrative concept art feel
- Volumetric lighting and god rays
- Blade Runner warmth over Tron coldness
```

**Key Work**: Ghost in the Shell concept art
**Search Keywords**: ash thorp ghost shell concept art

---

### 16. Territory Studio - Screen Interface Fiction (FUI)
**Philosophy**: Today's imagination of the future UI.
**Core Features**:
- Screen designs in science fiction films (FUI)
- Sense of holographic projection
- Multi-layered overlapping data visualizations
- Believable futurism

**Prompt DNA**:
```
Territory Studio FUI (Fantasy User Interface):
- Fantasy User Interface design
- Holographic projection aesthetics
- Orange/amber monochrome or cyan accents
- Multiple overlapping data layers
- Believable future technology
- Technical readouts and data streams
```

**Key Work**: Blade Runner 2049 screen graphics
**Search Keywords**: territory studio blade runner interface

---

## V. Eastern Philosophy School (17-20)
> Philosophy: "Negative space is content."

### 17. Takram - Japanese Speculative Design
**Philosophy**: Technology is a medium for thinking.
**Core Features**:
- Elegance of conceptual prototypes
- Soft tech aesthetic (rounded corners, gentle shadows)
- Charts and diagrams as art
- Modest sophistication

**Prompt DNA**:
```
Takram Japanese speculative design:
- Elegant concept prototypes and diagrams
- Soft tech aesthetic (rounded corners, gentle shadows)
- Charts and diagrams as art pieces
- Modest sophistication
- Neutral natural colors (beige, soft gray, muted green)
- Design as philosophical inquiry
```

**Key Work**: NHK Fabricated City
**Search Keywords**: takram nhk data visualization

---

### 18. Kenya Hara - Design of Emptiness
**Philosophy**: Design is not filling, but emptying.
**Core Features**:
- Extreme whitespace (80%+)
- Digitalization of paper texture
- Layers of white (warm white, cool white, off-white)
- Visualization of tactility

**Prompt DNA**:
```
Kenya Hara "emptiness" design:
- Extreme whitespace (80%+)
- Paper texture and tactility in digital form
- Layers of white (warm white, cool white, off-white)
- Minimal color (if any, very desaturated)
- Design by subtraction not addition
- Zen simplicity
```

**Key Work**: Muji art direction, *Designing Design*
**Search Keywords**: kenya hara designing design muji

---

### 19. Irma Boom - Book Architect
**Philosophy**: The physical poetics of information.
**Core Features**:
- Non-linear information architecture
- Playing with edges, margins, and boundaries
- Unexpected color combinations (pink+red, orange+brown)
- Digital translation of handcraft

**Prompt DNA**:
```
Irma Boom book architecture style:
- Non-linear information structure
- Play with edges, margins, boundaries
- Unexpected color combos (pink+red, orange+brown)
- Handcraft translated to digital
- Dense information inviting exploration
- Editorial design, unconventional grid
```

**Key Work**: SHV Think Book (2136 pages)
**Search Keywords**: irma boom shv think book

---

### 20. Neo Shen - Eastern Poetry of Light and Shadow
**Philosophy**: Technology needs human warmth.
**Core Features**:
- Digitalization of ink wash painting
- Soft glow effects
- Poetic negative space
- Emotional colors (deep blue, warm gray, soft gold)

**Prompt DNA**:
```
Neo Shen poetic Chinese aesthetic:
- Digital interpretation of ink wash painting
- Soft glow and light diffusion effects
- Poetic negative space
- Emotional palette (deep blues, warm grays, soft gold)
- Calligraphic influences in typography
- Atmospheric depth
```

**Key Work**: Neo Shen digital art series
**Search Keywords**: neo shen digital ink wash art

---

## Prompt Usage Instructions

**Combination Formula**: `[Style Prompt DNA] + [Scene Template (see scene-templates.md)] + [Specific Content]`

### Core Principle: Mood, Not Layout

The key to AI image generation: Short prompts > Long prompts. Describing 3 sentences of mood and content works better than 30 lines of layout details.

| Diversity-Killing Approach | Creativity-Sparking Approach |
|----------------|----------------|
| Specifying color ratios (60%/25%/15%) | Describing the mood ("warm like Sunday morning") |
| Dictating layout positions ("title centered, image on the right") | Referencing specific aesthetics ("Pentagram editorial feel") |
| Restricting character poses and expressions | Letting the AI naturally interpret the style |
| Listing all visual elements to be included | Describing what the audience should feel |

### Good / Bad Examples

**Bad — Over-constrained (AI output ends up empty and flat):**
```
Professional presentation slide. Dark background, light text.
Title centered at top. Two columns below. Left column: bullet points.
Right column: bar chart. Colors: navy 60%, white 30%, gold 10%.
Font size: title 36pt, body 18pt. Margins: 40px all sides.
```

**Good — Mood-driven (generates diverse, high-texture results):**
```
A data visualization that feels like a Bloomberg Businessweek
editorial spread. The key number "28.5%" should dominate the
composition like a headline. Warm cream tones with sharp black
typography. The data tells a story of dramatic channel shift.
```

### Execution Path Selection

Choose based on the "Best Path" column in the quick reference table:
- **AI Generation**: For styles with distinct visual elements (06/07/12/13/14/15/16/20), use Gemini/Midjourney for direct output.
- **HTML Rendering**: For styles relying on precise typography and layout (01/03/04/10/11/17/18), use code to control data and layout.
- **Hybrid**: Use HTML for the skeletal layout + AI generation for illustrations/backgrounds (02/05/08/09/19).

### Quality Control

1. ❌ Avoid writing "in the style of Pentagram" directly → ✅ Describe specific design features instead.
2. Text often errors in AI generation → Replace text post-generation.
3. Aspect ratios are easily distorted → Specify the aspect ratio explicitly.
4. Generate 3–5 variations first, choose the best one, then refine.

**Default Aesthetic No-Go Zones** (can be overridden by user branding):
- ❌ Cyber-neon / deep blue background (#0D1117)
- ❌ Adding personal signatures/watermarks to cover images

---

**Version**: v2.1
**Update Date**: 2026-02-13
**Applicable Scenarios**: Web, PPT, PDF, infographics, covers, illustrations, apps, and all other visual designs.
**Integration with image-to-slides**: For PPT scenarios, you can directly reference styles in this file and execute generation via the image-to-slides skill.
