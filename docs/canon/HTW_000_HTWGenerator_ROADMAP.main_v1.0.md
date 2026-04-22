# HTW Generator — Main Roadmap v1.0

**Current repo version:** 0.6.5k  
**Roadmap role:** navigation and implementation order  
**Do not use this file as:** tech log, continuity pack, or master audit

---

## 1. Current roadmap reading

The product direction is already defined.
The work now is alignment.

This roadmap is therefore not “invent the product”.
It is:

1. audit current repo truth
2. align app to locked product truth
3. harden engines in the right order
4. improve production readiness without redesign drift

---

## 2. Top-level phase order

| Phase | Name | Main goal | Status |
|---|---|---|---|
| 0 | Repo-context audit | Compare product docs vs repo 0.6.5k | current |
| 1 | Icon alignment hardening | Make Icon match closed product truth and production need | next |
| 2 | Effects semantic alignment | Make Effects read as a true editor and honor closed Chapter 2 rules | planned |
| 3 | Bitmap production pass | Align Bitmap with Chapter 1 + 3 product logic and production value | planned |
| 4 | Global UX / export / feedback pass | Consistent suite behavior, warnings, progress, readability | planned |
| 5 | Integration / stabilization | close regression risk, polish, handoff cleanliness | later |

---

## 3. Phase 0 — Repo-context audit

### Goal
Audit the current codebase against the locked product docs and produce the safest forward execution order.

### Must produce
- current status snapshot
- stable / unstable areas
- drift map
- contradiction map
- blockers / debt / later / interesting / not now classification
- recommended implementation order
- acceptance criteria per future phase

### Acceptance criteria
- repo is described from real files, not memory
- product docs are actually compared against repo
- Icon / Effects / Bitmap are read as one family
- roadmap is phase-safe and regression-aware
- no implementation yet

---

## 4. Phase 1 — Icon alignment hardening

### Goal
Bring Icon mode into clean alignment with the locked product truth and immediate production needs.

### Why first
- Icon is the product’s symbolic / branding engine
- 32x32 noble reference is already locked
- Icon is closest to deliverable production pressure
- current product priority order is Icon > Effects > Bitmap

### Focus
- 32x32 reference integrity
- wider density family compatibility
- small-icon readability
- clean SVG / export readiness
- safe editing semantics
- label/order clarity in sidebar
- no drift into Effects or Bitmap internals

### Acceptance criteria
- current Icon behavior is audited against locked truth
- missing / blurred semantics are named
- implementation can be split into small direct-repo passes
- no semantic confusion with Bitmap
- export story is explicit

---

## 5. Phase 2 — Effects semantic alignment

### Goal
Align Effects with Chapter 2 closure and make it read as a controlled editing workspace.

### Focus
- faithful source-image preview
- visible original image at all times
- clear distinction between preview / mask / baked / procedural
- checker preview treatment
- masking as real logic state
- rails remain procedural
- checker commits become layer-capable
- noise obeys occupancy rules
- tool-family clarity
- stronger state readability
- Bootstrap Icons direction where applicable

### Acceptance criteria
- rails vs layers semantic split is explicit
- noise does not violate checker / marker occupancy law
- layer UX is believable and not fake
- UI indicators become readable enough for serious tool use
- no collapse into a toy filter tab

---

## 6. Phase 3 — Bitmap production pass

### Goal
Bring Bitmap into a cleaner production-ready state without losing the locked product logic.

### Focus
- Chapter 1 family alignment
- Chapter 3 navigation / feedback / readability discipline
- dither controls with production criteria
- shape logic clarity
- export policy
- mono-mode constraints
- future-ready but controlled expansion

### Acceptance criteria
- Bitmap philosophy is visible and coherent
- controls are not muddy or overgrown
- output and export expectations are explicit
- UX is improved without redesign drift

---

## 7. Phase 4 — Global UX / export / feedback pass

### Goal
Make the whole suite behave like one coherent tool.

### Focus
- consistent navigation across all 3 modes
- recalculation feedback
- export warnings
- progress / KPI / “working” visibility
- stronger system-state indicators
- readability first
- no fake hangs
- no mode-specific UI chaos

### Acceptance criteria
- all three tabs read as one suite
- heavy operations never feel frozen or blind
- state indicators are visible
- legibility beats weirdness

---

## 8. Phase 5 — Integration / stabilization

### Goal
Reduce regression risk and prepare the project for healthier future work.

### Focus
- re-audit of file ownership
- cleanup of overloaded areas
- version truth consistency
- doc refresh
- handoff hygiene
- smoke-test / acceptance grid

### Acceptance criteria
- repo truth and docs no longer diverge silently
- continuity docs are fresh
- engine boundaries are clearer
- future work can resume without chat archaeology

---

## 9. Current classifications

### Blockers
- repo-context audit not yet finalized
- Claude-facing condensed doc pack not yet fully consumed in an audit run
- some closed product truths likely remain unverified against current repo

### Debt
- semantic fragility in Effects
- possible over-centralization in `app.js`
- old patch-history residue still influences reasoning too much
- system-state readability still weak

### Later
- broader WWL extraction
- richer dev-log history
- enhanced coder-facing startup subset

### Interesting
- stronger export pipelines
- richer per-engine technical fichas
- future docs automation

### Not now
- broad redesign
- speculative architecture replacement
- feature creep unrelated to the current roadmap

---

## 10. Roadmap doctrine

Roadmap integrity outranks reactive local fixes.

Any new issue found during audit must be:
1. classified
2. placed in the roadmap
3. only then scheduled for action
