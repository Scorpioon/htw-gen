# HTWGEN — Effects Ownership Map
**Base version:** `v0.6.5m`  
**Scope:** current operational ownership map for the fragile Effects lane  
**Purpose:** make behavior ownership explicit before any sanitation extraction or further polish.

---

## 0. Why this doc exists

The main problem is not only “bad code”.
The main problem is **hidden ownership**.

In the current Effects lane, a user-visible control can depend on several surfaces at once:
- template generation
- helper rendering
- click routing
- toggle mutation
- keyboard routing
- sidebar rebuild lifecycle

Without an ownership map, tiny changes become guesswork.

This document makes the chain explicit.

---

## 1. System view

## Effects sidebar chain

```text
sbEffects()
  -> helper output (tog / sec / sld / etc.)
  -> sidebar HTML
  -> renderSidebar()
  -> wireUI() event binding
  -> handleToggle() / direct handlers
  -> state mutation
  -> dProc() / updateSidebar() / renderEffects()
  -> visible result
```

## Keyboard chain

```text
visible hint in template
  -> NOT enough by itself
  -> keydown switch must contain explicit case
  -> state mutation
  -> dProc()
  -> visible result
```

## Layer row chain

```text
sbEffects() layer row template
  -> data-layer-delete / data-layer-visible
  -> wireUI() delegated sidebar click handling
  -> bakeStack mutation
  -> renderEffects() + updateSidebar()
  -> visible layer list result
```

---

## 2. Ownership table

| Concern | Owner file | Owner function / surface | Secondary dependency | Notes / danger |
|---|---|---|---|---|
| Effects sidebar visible structure | `app.js` | `sbEffects()` | helper output from `tog()`, `sec()`, `sld()` | High-risk surface. Template edits can break working controls. |
| Section wrapper visuals | `app.js` + `styles.css` | `sec()` + `.sbs`, `.sbl` classes | sidebar rebuild | Visual ownership can be adjusted without touching handlers if structure stays stable. |
| Toggle visual rows | `app.js` | `tog()` | `.tog`, `.togl`, `.togk`, `.togp` CSS | `tog()` renders label + hint + state pill, but does not auto-wire keyboard. |
| Slider rows | `app.js` | `sld()` | `.slrow` CSS | Pure UI helper; event meaning still depends on handler paths elsewhere. |
| Click routing inside sidebar | `app.js` | `wireUI()` | `data-*` attrs emitted by template | Very sensitive. Do not touch casually. |
| Generic toggle state mutation | `app.js` | `handleToggle()` | `data-t` from `tog()` | Works for click toggles only; not for keyboard unless separately wired. |
| Effects keyboard shortcuts | `app.js` | global `keydown` handler | current `S.mode` guard + `dProc()` | Explicit cases only. Visual hint alone does nothing. |
| Sidebar rebuild lifecycle | `app.js` | `renderSidebar()` | `wireUI()` clone/replace behavior | Source of scroll reset / stale references if mishandled. |
| Effects render output | `app.js` | `renderEffects()` | `drawMarkers()`, `drawNoise()`, checker/bake logic | Separate from sidebar sanitation. Do not mix. |
| Border / rail / noise placement | `app.js` | `drawMarkers()`, `drawNoise()` | export parity | Geometry lane. Separate from UI lane. |
| Layer row rendering | `app.js` | inline layer-row build inside `sbEffects()` | `wireUI()` delegated handlers | Proven hotspot. Strong extraction candidate. |
| Layer visibility toggle | `app.js` | layer row markup + `wireUI()` | `data-layer-visible` | Structure must preserve attribute path exactly. |
| Layer delete action | `app.js` | layer row markup + `wireUI()` | `data-layer-delete` | Current pain point: label semantics + text encoding + wrong visual role. |
| Base image color toggle click | `app.js` | `sbEffects()` + `handleToggle('ecolor')` | `data-t="ecolor"` | Click path works. |
| Base image color shortcut `C` | `app.js` | keydown switch | none if case missing | Example of ownership split: visible `[C]` hint but no keyboard case. |
| Actions row behavior | `app.js` | actions markup inside `sbEffects()` | IDs + existing handlers | Another hotspot. Must preserve exact working trigger path. |
| Sidebar readability / contrast | `styles.css` | `.sbl`, `.togk`, `.slrow label` | shared classes across modes | Safe when kept color-only. |
| Layer delete visual feel | mixed | currently `.togk` style applied to delete text | layer row template | Semantically wrong role: key hint style used as micro-action surface. |

---

## 3. Ownership by concrete behavior

## 3.1 BASE IMAGE color toggle (click)

### Visible owner
- `sbEffects()`

### Render helper
- `tog('ecolor', 'Color', fx.colorMode, 'C')`

### Click owner
- `wireUI()` delegated click listener

### Mutation owner
- `handleToggle('ecolor')`

### Repaint owner
- `dProc()`

### Important note
The `[C]` hint is rendered by `tog()`, but keyboard support is **not** owned here.

### Invariants
- preserve `data-t="ecolor"` path
- preserve click toggle behavior
- do not assume helper hint equals keyboard support

---

## 3.2 BASE IMAGE color toggle (keyboard)

### Visible hint owner
- `sbEffects()` via `tog(..., 'C')`

### Real keyboard owner
- global `keydown` handler

### Current fragility
If the `keydown` switch lacks `case 'c' / 'C'`, then:
- click works
- visual hint exists
- keyboard does nothing

### Invariants
- keyboard support must be wired explicitly
- keep `S.mode === 'effects'` guard
- call `dProc()` after mutation

---

## 3.3 Layer delete control

### Visible owner
- layer row template inside `sbEffects()`

### Handler owner
- `wireUI()` delegated sidebar listener

### Mutation owner
- splice/removal on `S.bakeStack`

### Refresh owner
- `renderEffects()` + `updateSidebar()`

### Current fragility
The visible label is not a neutral surface:
- it sits in a row template hotspot
- it uses `.togk`, a style semantically closer to key hints than actions
- text encoding mistakes are highly visible
- structure changes can break working delete behavior

### Invariants
- preserve `data-layer-delete="${i}"`
- preserve handler path in `wireUI()`
- preserve row ordering
- avoid unnecessary structural change during delivery lane

---

## 3.4 Layer visibility toggle

### Visible owner
- same row template in `sbEffects()`

### Handler owner
- `wireUI()` on `data-layer-visible`

### Mutation owner
- layer visibility mutation in app state

### Risk
Because delete and visibility live in the same row template, careless edits to one often threaten the other.

### Invariants
- preserve `data-layer-visible`
- preserve ON/OFF pill structure unless intentionally redesigning later

---

## 3.5 Actions row

### Visible owner
- actions block inside `sbEffects()`

### Handler owner
- existing IDs / event path already working

### Fragility
This is not “just markup”.
It is a working interaction cluster.
Rebuilding buttons manually previously caused regressions.

### Invariants
- preserve exact working button path
- wrapper-only changes preferred
- do not rebuild IDs / disabled logic unless explicitly required

---

## 3.6 Sidebar rebuild + scroll

### Lifecycle owner
- `renderSidebar()`

### Secondary dependency
- `wireUI()` replaces the sidebar node

### Fragility
Any code that:
- stores old sidebar reference
- restores state on stale node
will appear to “work” in theory but fail in practice.

### Invariants
- re-query live sidebar after rebind/replacement
- keep state-preservation fixes minimal

---

## 4. Known hotspot ranking

## Hotspot 1 — layer row template
Why:
- delete label
- delete handler
- visibility toggle
- inline structure
- fragile semantics

This is the best future extraction candidate.

## Hotspot 2 — actions markup in `sbEffects()`
Why:
- high-visibility controls
- regression history
- layout requests can accidentally rebuild working behavior

## Hotspot 3 — keyboard hints vs actual keyboard routing
Why:
- visual promise and real behavior are split
- easy to misread
- causes “looks wired but isn’t” bugs

## Hotspot 4 — `renderSidebar()` lifecycle
Why:
- stale references
- scroll restore issues
- hidden DOM replacement behavior

---

## 5. Extraction candidates

These are sanitation candidates, not immediate delivery changes.

### Candidate A — `renderLayerRow(layer, i)`
Best first extraction candidate.

Why:
- contained surface
- repeated pain
- clear ownership win

### Candidate B — `renderEffectsActions(hasMask, hasLayers)`
Good second extraction candidate.

Why:
- high-value cluster
- easier to protect working IDs once isolated

### Candidate C — shortcut parity map
Could be documentation-first before any code cleanup.

Why:
- clarifies what hints exist
- clarifies what shortcuts are truly wired

---

## 6. Things that are explicitly not the same concern

Do not merge these in one pass:

### UI lane
- section order
- action row layout
- contrast
- layer scroll box
- delete control visuals

### behavior lane
- click handlers
- toggle mutation
- keyboard switch cases

### geometry lane
- border centering
- rail/noise placement
- export remainder parity

These may touch the same file, but they are not the same problem.

---

## 7. Practical doctrine for future patches

Before touching any Effects concern, answer these:

1. Where is it rendered?
2. Where is it clicked?
3. Where is it keyboard-wired, if at all?
4. What exact attribute/ID path must survive?
5. What is the smallest safe delta?
6. Am I touching UI, behavior, or geometry?
7. If more than one, is the pass too broad?

If these are not answered, do not patch yet.

---

## 8. Immediate recommendation

Use this map before any future sanitation extraction.

Recommended next sanitation docs:
1. `HTWGEN_EFFECTS_INVARIANTS_v0.6.5m.md`
2. then decide whether `renderLayerRow()` extraction is ready

---

## 9. One-line doctrine

**A fragile system becomes patchable when ownership stops being implicit.**
