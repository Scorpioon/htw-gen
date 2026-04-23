# WHAT WE LEARNED — LLM Collaboration Control Pass
**Project:** HTW Generator  
**Version anchor:** `v0.6.5k`  
**Purpose:** Save reusable operational learning about how to work with coding LLMs on fragile UI+logic systems like HTW.

---

## 0. Chat scope

- Project / area: HTW Generator / Effects polish lane
- Approximate phase: post-reset stabilization after repeated failed sidebar / micro-fix attempts
- Trigger: repeated regressions during “small” UI and text changes
- Goal of extraction: reduce future LLM drift and improve patch success rate

---

## 1. Project-local learnings

### 1.1 “Small UI changes” are not small in HTW
In HTW Effects, template structure, handlers, and behavior are tightly coupled.

What looked like tiny requests:
- actions row horizontal
- delete control label
- layer box wrapper
could break:
- Apply
- layer rendering
- click routing
- scroll behavior

Rule:
HTW sidebar work must be treated as fragile systems work, not cosmetic markup tweaking.

### 1.2 One surface per version is the correct approach
Bundling:
- sidebar reorder
- actions row
- layers local scroll
- delete control
- contrast
- geometry math
into one pass created chaos.

What worked:
- `0.6.5l` style micro-pass
- one version = one surface family
- validate immediately
- then continue

### 1.3 Stable progress comes from isolating families
The remaining work separated cleanly into:
- confidence hotfixes
- contrast
- actions row
- layers box
- delete control
- semantic reorder
- border centering
- rail/noise parity
- export remainder finish

This structure is far more reliable than “final polish pass”.

### 1.4 Some passes are too fragile to do before foundation passes
Trying to do sidebar restructure before restoring confidence was a mistake.

Correct order:
- confidence first
- then CSS/readability
- then one sidebar behavior at a time
- geometry later

---

## 2. LLM-operation learnings

### 2.1 Do not ask for broad “tool feel” changes on fragile systems
Phrases like:
- improve the UI
- reorganize the sidebar
- tool feel pass
gave the coding LLM too much freedom.

Result:
- structural rewrites
- broken handlers
- widened scope
- regressions

Better pattern:
define:
- exact surface
- invariants
- allowed delta

### 2.2 The LLM must rebuild the local model before patching
The model cannot be assumed.

Required before implementation:
- what file owns this behavior?
- what function owns this behavior?
- what helper / id / data-attr path must survive?
- what exact region is touched?
- what exact line-level delta is allowed?

If the LLM cannot answer that, it should not patch.

### 2.3 Wrapper-only changes are safer than rebuilt markup
When a working control already exists, the safest move is often:
- wrap existing markup
- preserve ids
- preserve handlers
- preserve helper output

Not:
- rebuild button markup manually
- invent new attributes
- restate controls from scratch

### 2.4 Text-only hotfixes must be treated as encoding-sensitive
The mojibake delete fix showed that even changing visible text can go wrong if the LLM introduces:
- smart quotes
- non-ASCII punctuation
- malformed copied characters

Rule:
For text-only hotfixes, explicitly require:
- ASCII quotes only
- preserve structure exactly
- change visible text node only

### 2.5 CLI instead of web chat does not solve discipline problems by itself
Moving to CLI did not automatically fix:
- scope drift
- wrong assumptions
- fragile template rewrites
- over-broad passes

The problem was not mainly the interface.
The problem was the lack of a hard execution rail.

---

## 3. Workflow learnings

### 3.1 Use READ -> MODEL -> IMPLEMENT, not straight to IMPLEMENT
For HTW-like systems, the winning sequence is:

1. READ relevant files only
2. MODEL current behavior
3. STATE invariants
4. DEFINE smallest delta
5. IMPLEMENT

Skipping the model step caused repeated failures.

### 3.2 Manual approval is better than auto-accept for fragile UI passes
Manual approval was the right control point once the lane involved:
- sidebar structure
- actions row
- layer controls
- geometry placement

### 3.3 A roadmap with micro-versions improved control
Turning the remaining polish into:
- `0.6.5l`
- `0.6.5m`
- `0.6.5n`
...
created:
- clearer sequencing
- better rollback points
- less psychological overload
- easier prompts

### 3.4 Some roadmap steps still need audit before implementation
Not every roadmap item is equally “plug-and-play”.

Examples:
- border centering
- rail/noise parity
- export remainder finish

These should stay hypothesis-driven until isolated validation confirms them.

---

## 4. Candidate reusable law for workdocs

These are strong candidates for future workdocs / WRKOPS ingestion.

### Candidate 1
For fragile UI systems, never ask a coding LLM for “general polish”.
Always constrain by:
- surface
- invariants
- allowed delta

### Candidate 2
When handlers depend on template structure, wrapper-only changes outrank rebuilt markup.

### Candidate 3
One surface per version is the safest delivery pattern for late-stage polish.

### Candidate 4
Text-only hotfixes still need explicit encoding discipline.

### Candidate 5
CLI use does not remove the need for strict patch rails.

### Candidate 6
Require a READ + MODEL pass before implementation on fragile surfaces.

---

## 5. Drift warnings

- “Looks tiny” is not a real risk signal in HTW
- full-template rewrites create regression magnets
- broad polish prompts invite silent redesign
- repeated failure usually means the task is underspecified, not that more attempts will fix it
- when in doubt, reduce the pass, do not explain harder

---

## 6. One-line doctrine

For fragile systems:
**do not ask the LLM to be smart — ask it to be exact.**
