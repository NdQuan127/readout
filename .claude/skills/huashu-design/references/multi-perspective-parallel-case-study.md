# Multi-Perspective Parallel Experiment · Case Study

> huashu-md-html v2.0 launch film project · 2026-05-11
> Parallel director's notes + HTML + keyframes experiment across 6 artist perspectives

---

## Background

When the user requested to "produce a 30-second upgrade promo video for huashu-md-html v2.0", the main thread first produced the v5 baseline (Anthropic / Penguin Classics publisher taste). However, the user believed it could be improved and provided a critical instruction:

> "Call different subagents to generate 6 completely different versions of expression and visual design. You can try employing different directors and artists. Then, once all are completed, evaluate and review them."

This is the first systematic "multi-perspective parallel director's notes" experiment, validating a reusable workflow.

---

## Selection Logic for the 6 Perspectives

Do not randomly select 6 designers—they must have **extremely high visual differentiation** to avoid convergence.

The final selection of the 6 perspectives (including rationale for selection):

| Perspective | Genre/Movement | Aesthetic Anchor | Difference from Other Perspectives |
|------|------|---------|----------------|
| **v5 Baseline** | Modern Publisher | Anthropic Terracotta Orange + Penguin Classics Serif + Vignelli Grid | Safe "taste" choice |
| **v5a Wes Anderson** | Cinematic Chapter Aesthetics | *The French Dispatch* editorial feel + 1960 Olivetti industrial catalog | Symmetrical composition + chapter cards + decorative borders |
| **v5b Saul Bass** | '60s Film Title Art | Cut-paper + Trajan caps + fluid geometry | Paper-cut silhouettes + large typography + strong diagonals |
| **v5c Wong Kar-wai** | Hong Kong New Wave | *In the Mood for Love* / *2046* letterboxing + Chinese Serif | Slow tempo + misty halos + Chinese-focused |
| **v5d Massimo Vignelli** | 1970s Modernism | Knoll identity manual + NYC Subway map | Rigid grid + 3-color rule + rejection of decoration |
| **v5e Kenya Hara** | Japanese Minimalism | MUJI posters + *White* | Philosophy of empty space (yohaku) + no chrome + ma (space/interval) |
| **v5f Yayoi Kusama** | Installation Art | Infinity Mirror Rooms + Polka Dot Obsession | Obsessive repetition + single strong color + polka dots |

**Selection Principles**:
1. **3 different geographic cultures** (Western film / Japanese design / Hong Kong-style Chinese)
2. **3 different eras** (1960s / 1970s / 2010s+)
3. **3 different mediums** (Film / Graphic design / Installation art)
4. **Each must possess a visual signature that is "completely opposite to the generic SaaS aesthetics in the training corpus"**

---

## Implementation Flow

### Step 1 · Write independent briefs for each perspective (~15 minutes)

Each brief contains 8 fixed fields:

```
1. Project Background (identical across briefs)
2. Required Reading (identical v5-director-notes.md used as a methodology template)
3. Deliverables List (4 items)
4. Artist DNA (6 core fields):
   - Color Palette (specific HEX values)
   - Fonts (specific names + fallbacks)
   - Visual Language (core principles)
   - Brand Elements (identifiable signatures)
   - Pacing (differentiating from other perspectives)
   - Enhanced Anti-AI Slop (off-limit zones in the context of this style)
5. 30-Second Structure Reference (4-6 drafted shots)
6. Destination Cards Design Requirements (maintain authenticity and readability)
7. Key Constraints (30s / 1920×1080 / file:// / Google Fonts CDN)
8. Output Verification Checklist + Completion Report Format
```

**Key**: Each brief must explicitly emphasize "**do not replicate the v5 aesthetic**"—otherwise, subagents will be influenced by the v5 director-notes and converge.

### Step 2 · Launch 6 subagents in parallel (6 Agent tool calls within a single message)

```js
Agent({ subagent_type: "general-purpose", run_in_background: true, name: "v5a-anderson", ... })
Agent({ subagent_type: "general-purpose", run_in_background: true, name: "v5b-bass", ... })
// ... 6 agents in total
```

Run in the background, expected duration: 30-60 minutes.

### Step 3 · Idle work during the wait

Do not poll agent status. Subagents will automatically trigger a task-notification upon completion. During the wait, perform the following tasks:

- Fix bugs in the main thread's v5 baseline
- Write the review framework (evaluation dimensions for each version / Q&A)
- Codify the methodology into a skill (which is the source of this case study)
- Prepare the final summary document outline

### Step 4 · Handling Failures (~16% failure rate, acceptable)

Observed in practice: About 1 out of the 6 subagents may fail due to network or token limit issues (e.g., Bass encountered a socket error in the first round). Resolution steps:

1. Upon receiving the completion notification, **immediately check** the output folder of the respective agent.
2. If key deliverables are missing → restart the agent (using the same brief, optionally annotated with "Last attempt failed, please execute again").
3. If partially completed (e.g., HTML is generated but screenshots are missing) → use the main thread to capture Playwright screenshots, rather than restarting the agent.

### Step 5 · Systematic Review After All 6 Versions Are Completed

Review framework (5 dimensions + 3 high-level questions + use case allocation):

```
5-Dimension Scoring (1-10 per dimension):
- Distinctiveness (Visual differentiation)
- Coherence (Aesthetic consistency)
- Anti-slop (Anti-AI slop execution)
- Story arc (Pacing and narrative arc)
- Pause-and-look (Detail density)

3 High-Level Questions:
- Q1 Shareable Screenshot? (Triggers a pause when scrolling social media)
- Q2 Memorable Sentence? (Leaves a lasting, high-level impression)
- Q3 Timelessness? (Does not look cheap when reviewed 5 years later)

Use Case Allocation (By platform and audience):
- WeChat Official Account / X / Bilibili / WeChat Moments / Dribbble / Client Demo / Private Traffic / ...
```

For details, see REVIEW.md in the same directory as `assets/director-notes-samples/launch-film-30s-sample.md`.

---

## Experimental Deliverables (Facts)

### Document Volume

- v5 baseline director-notes: 11,500 Chinese characters / words
- 6 perspective director-notes: 4,000 to 12,000 Chinese characters / words each
- Total document volume: ~55,000 to 70,000 Chinese characters / words
- Complete 5-part structure: 6/6 versions

### HTML Implementation

- Independent animation.html for each version, 30 seconds, 1920×1080
- File size: 28–74 KB
- All viewable via file:// (no server dependencies)

### Keyframes

- 10–18 PNGs per version, covering the complete 30-second story arc
- Total screenshots: 80+ images
- Average PNG size: 100–200 KB

### Time Elapsed

- 6 subagents running in parallel: ~12–15 minutes (as indicated by duration_ms)
- Parallel idle work on the main thread (fixing v5 + writing methodology): completed concurrently
- Overall "from launching the 6 perspectives to having all deliverables in place": ~60 minutes

---

## Key Insights (For Future Users of huashu-design)

### Insight 1 · The "write a 10k-word director's notes first" methodology is **fully reproducible**

All 6 subagents successfully generated complete specs of 4,000–12,000 words adhering to the 5-part structure, and reached marketing-ready quality when implementing the HTML. This proves that the methodology itself does not depend on the talent of a single executor—**as long as the brief is clear, multiple independent executors can deliver consistently high-quality results**.

### Insight 2 · "Perspectives" must be specific to "work + release year"

In each brief, specific references were mapped:
- Anderson → *The French Dispatch* (2021) + *Moonrise Kingdom* (2012) + Penguin Classics dust jackets + 1960s Olivetti catalogues
- WKW → *In the Mood for Love* (2000) + *2046* (2004)
- Vignelli → 1972 NYC Subway map + Knoll identity manual + *The Vignelli Canon*
- Hara → MUJI brand 1995-2023 + *White* + Junya Ishigami transparency
- Kusama → Infinity Mirrored Rooms (2013-2023) + Polka Dot Obsession installations

**Actual Result**: All subagents accurately captured the core visual DNA of the referenced works, rather than a generic "genre average."

### Insight 3 · Enhanced anti-AI slop tailored to each style is key

Generic anti-slop guidelines (such as purple gradients, emojis, and corporate-style SVG characters) apply across all versions. However, **each style must also feature its own "dedicated anti-slop guidelines"**:

- Bass: Do not use Helvetica (too clean; Bass is rugged)
- Vignelli: Do not use rounded corners (all corners must be 90°)
- Hara: Do not use any gradients + do not use sans display fonts
- Kusama: Do not use a modern SaaS look
- Anderson: Do not use cyber color schemes
- WKW: Do not use Inter (WKW uses serifs)

With these constraints, the stylistic purity of the 6 versions was exceptionally high, without any convergence between them.

### Insight 4 · The real value of multiple perspectives is not "selecting a winner"

The initial idea was to use A/B testing to choose the single best version. However, the actual review revealed that **each of the 6 versions has a distinct use case**:
- v5 baseline → Product landing pages / WeChat Read (high information density)
- Anderson → Cover images for long articles on WeChat Official Accounts (strong editorial/magazine feel)
- WKW → Bilibili / Chinese culture-oriented content (nostalgic warmth)
- Vignelli → Design communities / Dribbble (every frame functions as a printed poster)
- Hara → Client presentations / static screenshots (minimalist philosophy)
- Kusama → X short videos / viral sharing (high visual impact)

**Conclusion**: Marketing is not a single shot, but a platform-specific multiplex. The true value of parallelizing 6 perspectives is to **arm a single project with 6 differentiated weapons**, rather than discarding 5 of them as unusable.

### Insight 5 · A subagent failure rate of ~16% is acceptable

1 out of 6 failed (Bass encountered a socket error in the first round). The overhead was restarting it with a 5-minute simplified brief and waiting another 12-15 minutes. **Compared to waiting for a single agent to run 6 versions sequentially (90+ minutes)**—the parallel + retry approach is significantly more efficient.

### Insight 6 · The main thread must perform substantive work during wait times

Subagents take 12-15 minutes to complete. The main thread should never remain idle during this time. Instead, it should:

- **Fix bugs in the main version** (those already reported by the user)
- **Write the review framework** (to be filled out during evaluation)
- **Codify the methodology into a skill** (such as this case study)
- **Prepare the final summary** (ensuring clarity when the user returns)

This is the core "main thread responsibility" of a parallel multi-agent workflow—not acting as a passive PM waiting for results, but as an active orchestrator driving execution forward.

---

## When to Enable "Multi-Perspective Parallelism"

| Scenario | Enable? | Rationale |
|------|---------|------|
| User explicitly requests "different directions" or "more versions" | ✅ Enable immediately | Direct demand |
| User is unsatisfied with the first draft but cannot articulate what they want | ✅ Enable | A/B selection is superior to guessing what is needed |
| Project is scheduled for multi-platform distribution (X / Official Accounts / Bilibili / WeChat Moments) | ✅ Enable | One tailored version per platform |
| Style has not been finalized by the client, but budget (time + tokens) allows | ✅ Enable | Back-and-forth revisions cost 5x more |
| User has provided a clear style reference and requires only 1 version | ❌ Do not enable | Waste of resources |
| Task is a simple motion graphic or icon animation | ❌ Do not enable | Over-engineering |
| Tight deadline (< 30 minutes) | ❌ Do not enable | Subagents will not finish in time |

---

## Complete Methodology Flowchart

```
User Brief (including quality expectations)
       ↓
[Main Thread] Write v5 baseline director's notes (10k-word level, 5 major parts)
       ↓
[Main Thread] Implement v5 HTML + capture keyframes (marketing baseline)
       ↓
[Decision Point] Enable multi-perspective?
       ↓ YES
[Main Thread] Select 6 differentiated perspectives + write 6 independent briefs (8 fields each)
       ↓
[6 Subagents in Parallel]
   ├── v5a brief → director-notes + html + keyframes + README
   ├── v5b brief → ...
   ├── v5c brief → ...
   ├── v5d brief → ...
   ├── v5e brief → ...
   └── v5f brief → ...
       ↓
[Main Thread Concurrently] Fix v5 bugs · Write review framework · Codify methodology
       ↓
[All 6 Notifications Received]
       ↓
[Main Thread] Failure detection + retry / supplementary screenshots
       ↓
[Main Thread] 5-dimension scoring + 3 high-level questions + use case allocation
       ↓
[Main Thread] Write final REVIEW.md
       ↓
[Delivery] 6 complete versions + review + platform distribution recommendations
```

---

## Related Documents

- Complete Methodology: `references/launch-film-director-notes.md`
- Single Perspective Sample: `assets/director-notes-samples/launch-film-30s-sample.md` (v5 baseline)
- Project Workspace Location: `~/.claude/skills/huashu-md-html/demos/` (includes full set of files for 6 + 1 perspectives)
- Evaluation Review: `~/.claude/skills/huashu-md-html/demos/REVIEW.md`

---

*Last updated: 2026-05-11*
*Real case study: huashu-md-html v2.0 launch film 6-perspective parallel experiment*
