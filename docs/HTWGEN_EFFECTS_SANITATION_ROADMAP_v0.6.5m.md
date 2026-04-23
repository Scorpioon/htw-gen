# HTWGEN — Effects Sanitation Roadmap
**Base version:** `v0.6.5m`  
**Scope:** technical sanitation of fragile Effects surfaces  
**Purpose:** reduce regression risk, improve maintainability, and separate product polish from structural cleanup.

---

## 0. Why this roadmap exists

Recent work exposed a repeated pattern:

- tiny UI changes caused behavior regressions
- text-only changes touched structural wiring
- layout changes broke action triggers
- keyboard hints and real shortcuts were not owned by the same surface
- repeated retries increased confusion instead of clarity

This is the signature of a fragile local system, not necessarily a bad whole repo.

The right answer is not:
- “rewrite app.js”
- “refactor everything”
- “let the coding LLM clean it up freely”

The right answer is:
- map ownership
- isolate fragile chains
- extract only proven stable sub-surfaces
- move from accidental coupling to explicit coupling

---

## 1. Guiding rules

### Rule 1 — Delivery and sanitation stay separate
Do not mix:
- bugfix/polish passes
- refactor/sanitation passes

If a pass changes both user-visible behavior and internal structure, it is too broad unless explicitly planned.

### Rule 2 — One fragile surface per sanitation version
For sanitation work:
- one version
- one concern
- one ownership boundary

### Rule 3 — Model before refactor
Before any sanitation pass:
- identify file owner
- identify function owner
- identify handler path
- identify invariants
- identify safe extraction boundary

### Rule 4 — Wrapper before rebuild
If a control already works:
- preserve it
- wrap it
- extract around it
Do not rebuild it from scratch unless unavoidable.

### Rule 5 — Extraction beats redesign
Prefer:
- `renderLayerRow()`
over:
- “new sidebar system”

Prefer:
- `toggleKeyHintLabel`
documentation
over:
- “shortcut architecture rewrite”

---

## 2. Current diagnosis

## 2.1 Main fragile zone
The highest-friction zone is the Effects sidebar chain:

- `sbEffects()` → visible structure
- `tog()` / `sec()` / `sld()` → UI helper layer
- `wireUI()` → click routing
- `handleToggle()` → toggle state mutations
- keydown handler → keyboard path
- `renderSidebar()` → rebuild lifecycle

This chain currently has several symptoms:
- visual labels can imply behavior that is not actually wired
- one small markup change can break working handlers
- rebuilding the sidebar has side effects
- layer rows combine structure, label, action, inline style, and interaction in one template region

## 2.2 Secondary fragile zone
Geometry placement in Effects:
- `drawMarkers()`
- `drawNoise()`
- export parity
- remainder handling

This is fragile for a different reason:
- math consistency
- viewport/export parity
- origin assumptions

Important:
This zone must remain separate from sidebar sanitation.

---

## 3. Sanitation goals

### Goal A — make ownership explicit
Anyone touching Effects should be able to answer:
- where is this behavior rendered?
- where is it clicked?
- where is it toggled?
- where is the shortcut wired?
- what breaks if the markup changes?

### Goal B — reduce “template surprise”
A label or control should not secretly depend on three unrelated surfaces unless clearly documented.

### Goal C — make tiny edits truly tiny
A label-only change should be a label-only change.
A layout-only change should not require re-understanding handler wiring.

### Goal D — reduce future LLM drift
The system should become easier to patch safely with:
- shorter prompts
- clearer invariants
- smaller allowed deltas

---

## 4. Workstreams

## S1 — Ownership mapping
**Purpose:** document current behavior before any structural extraction.

### Deliverables
- `HTWGEN_EFFECTS_OWNERSHIP_MAP_v0.6.5m.md`
- `HTWGEN_EFFECTS_INVARIANTS_v0.6.5m.md`

### Must map
- `sbEffects()`
- `renderSidebar()`
- `wireUI()`
- `handleToggle()`
- keydown handler
- layer row path
- base image toggle path
- actions row path
- keyboard hint vs real shortcut relationship

### Output format recommendation
For each concern:
- concern
- owner file
- owner function
- render path
- click path
- keyboard path
- invariants
- danger notes

### Risk
Low. Documentation only.

### Value
Very high. This lowers future patch ambiguity immediately.

---

## S2 — Helper semantics clarification
**Purpose:** remove misleading assumptions without changing behavior.

### Target
Document and, if helpful, lightly annotate:
- `tog()` helper
- `sec()` helper
- `sld()` helper

### Known issue
`tog(..., 'C')` visually suggests a shortcut, but does not register one.

### Desired outcome
Make it explicit that:
- helper `k` is visual-only
- keyboard support must be wired separately

### Possible safe outputs
- comments only
- local docs only

### Avoid
- renaming helper signatures during delivery lane
- changing helper behavior globally unless explicitly planned

### Risk
Low if documentation-only. Medium if code comments touch shared helpers.

---

## S3 — Layer row extraction
**Purpose:** isolate the highest-friction mini-template in Effects.

### Candidate extraction
From:
- inline layer row build inside `sbEffects()`

To:
- `renderLayerRow(layer, i)` or equivalent tiny helper

### Why this first
The layer row already carries:
- label
- delete control
- visibility toggle
- data attrs
- style assumptions

It is a proven hotspot.

### Invariants
- preserve `data-layer-delete`
- preserve `data-layer-visible`
- preserve visibility toggle behavior
- preserve row ordering
- no CSS redesign in the same pass

### Risk
Medium.
This is the first real sanitation extraction and must be audited carefully.

### Value
High.
It turns one brittle string blob into a named surface.

---

## S4 — Actions row extraction
**Purpose:** isolate the action controls from the rest of `sbEffects()`.

### Candidate extraction
From:
- inline actions markup inside `sbEffects()`

To:
- `renderEffectsActions(hasMask, hasLayers)` or equivalent

### Why after S3
The actions row is also fragile, but it already produced regressions when rewritten.
It should only be extracted after ownership and layer row are understood.

### Invariants
- exact working IDs survive
- disabled logic survives
- no handler changes
- no new interaction model

### Risk
Medium-high.
Must only happen after action behavior is fully documented.

---

## S5 — Sidebar section boundary cleanup
**Purpose:** make section ownership clearer without changing logic.

### Target
Split `sbEffects()` into conceptual sections:
- base image
- palette
- generation
- checker
- layers
- actions

### Important
This is not a redesign.
This is a structural readability pass only after smaller extractions succeed.

### Risk
Medium-high.
Should not happen before S3 and S4.

---

## S6 — Rebuild lifecycle clarification
**Purpose:** make `renderSidebar()` rebuild semantics explicit.

### Current issue
Rebuild + clone/replace behavior creates hidden constraints:
- stale references
- scroll reset if mishandled
- subtle DOM lifecycle assumptions

### Target
Document and, if later justified, wrap the rebuild lifecycle in a named local helper.

### Example direction
Not implementation yet, but conceptually:
- save sidebar state
- rebuild
- rebind
- restore sidebar state

### Risk
Medium.
Helpful, but should come after documentation and smaller extractions.

---

## S7 — Shortcut registry sanity
**Purpose:** stop visual shortcut hints from drifting away from actual key routing.

### Current issue
Shortcut ownership is split:
- visual hint in helper/template
- actual behavior in keydown switch

### Goal
Create a lightweight sanity layer:
- documentation map of existing shortcuts
- audit of hint-vs-real parity
- optional later cleanup if worth it

### Important
Do not over-engineer this into a generic shortcut framework unless the product clearly needs it.

### Risk
Low-medium.
High value as documentation, medium risk if pushed into abstraction too early.

---

## S8 — Geometry sanitation lane
**Purpose:** separate placement math cleanup from sidebar fragility.

### Surfaces
- `drawMarkers()`
- `drawNoise()`
- export parity logic

### Why separate
This is a different failure class:
- math consistency
- origin alignment
- remainder handling
- export/view parity

### Rule
Do not combine with sidebar sanitation.

---

## 5. Recommended sanitation order

### Phase A — Understanding
1. S1 Ownership mapping
2. S2 Helper semantics clarification

### Phase B — Tiny extractions
3. S3 Layer row extraction
4. S4 Actions row extraction

### Phase C — Structural readability
5. S5 Sidebar section boundary cleanup
6. S6 Rebuild lifecycle clarification

### Phase D — Behavior integrity
7. S7 Shortcut registry sanity

### Phase E — Separate technical lane
8. S8 Geometry sanitation lane

---

## 6. What not to do

Do not:
- refactor all of `app.js`
- rebuild the whole sidebar
- redesign Effects while sanitizing
- merge geometry cleanup with sidebar cleanup
- let an LLM “clean things up” without ownership mapping first
- rename shared helpers casually
- change working handlers for elegance alone

---

## 7. Suggested versioning strategy

These sanitation passes should use their own clearly named micro versions or tags, separate from delivery polish when possible.

Recommended pattern:
- sanitation docs pass
- sanitation extraction pass
- sanitation lifecycle pass

Examples:
- `v0.6.5m-s1`
- `v0.6.5m-s2`
or equivalent local branch/tag naming if you prefer not to clutter public semantic versions.

If public version continuity matters more, keep a local sanitation ledger instead of exposing every sanitation step in the visible app version.

---

## 8. Success criteria

Sanitation is working if, after a few passes:

- a label fix is truly a label fix
- a layout fix does not break actions
- a shortcut issue can be diagnosed in one read pass
- prompts get shorter
- LLMs need less hand-holding to avoid structural mistakes
- ownership questions can be answered from docs, not guesswork

---

## 9. Immediate next move

Do not start with code refactor.

Start with:
1. ownership map
2. invariants doc

Only after those exist, decide whether S3 (layer row extraction) is ready.

---

## 10. One-line doctrine

**Sanitize understanding first, then sanitize code.**
