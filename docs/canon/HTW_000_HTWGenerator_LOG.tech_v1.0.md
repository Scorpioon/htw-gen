# HTW Generator — Tech Log v1.0

**Current repo version:** 0.6.5k  
**Role:** technical truth / repo reading  
**Not a roadmap. Not a continuity pack. Not a product spec.**

---

## 1. Repo root and current technical frame

- Workspace root: `K:\DEVKIT\projects\htw-generator`
- Repo root: `K:\DEVKIT\projects\htw-generator\htw-generator`
- Current repo truth for this doc: **0.6.5k**
- Historical strong modular reference: **0.6.0a**

Important:
- 0.6.0a remains historically important as last strongly trusted modular base
- current technical audit must still inspect **0.6.5k** as repo truth
- do not reason as if 0.6.0a were the live repo

---

## 2. Current file map (known from handoff bundle)

### Active app files
- `index.html`
- `styles.css`
- `app.js`
- `core/canvas.js`
- `core/dom.js`
- `core/export.js`
- `core/palette.js`
- `core/state.js`
- `engines/icon-engine.js`
- `engines/icon-editor.js`

### Historical / archive surfaces present in handoff bundle
- `_old/backups/...`
- `_old/patches/...`

Reading:
- the repo is modularized, but not yet split into full engine families for all tabs
- Effects and Bitmap logic still appear to live largely inside `app.js`
- Icon already has dedicated engine files

---

## 3. Architecture reading

| Layer | Known role | Current reading |
|---|---|---|
| `index.html` | shell / script loading / UI skeleton | active topbar + toolbar + sidebar shell still central |
| `styles.css` | visual system | current HTW shell styling |
| `app.js` | orchestration / event wiring / rendering control | still heavy and cross-cutting |
| `core/state.js` | global app state | central truth bucket for mode/tool/fx/bm/icon state |
| `core/export.js` | export helpers | export still important and partially coupled to current render flow |
| `core/canvas.js` | canvas/view helpers | utility layer, some dead-code suspicion historically noted |
| `core/dom.js` | DOM helpers / surface access | support layer |
| `core/palette.js` | palettes / color systems | palette truth |
| `engines/icon-engine.js` | icon generation pipeline | dedicated icon logic exists |
| `engines/icon-editor.js` | icon pixel edit helpers | dedicated icon edit surface exists |

---

## 4. Current state model (known)

Known state families from repo truth:

### Global
- mode
- tool
- image
- grid
- viewport / zoom / pan
- mask
- bake stack
- drag / painting flags

### Icon
- size
- threshold
- invert
- fitMode

### Effects
- colorMode
- checker
- structureDepth
- checkerDepth
- brushDepth
- edgeMode
- rail2 / rail3
- seed
- noise
- noiseAmount
- palette index

### Bitmap
- dither
- contrast
- depth
- shape
- color mode / palette indexes

Technical reading:
- state is already richer than a toy app
- current truth supports the “forensic creative tool” reading
- semantics are still at risk where multiple state families interact inside `app.js`

---

## 5. Known runtime/behavior reading from current bundle

### Grid processing
- `processGrid()` still routes both Icon and Bitmap through shared orchestration in `app.js`
- current behavior still sets `S.grid = gridIcon(...)` or `gridBitmap(...)`
- Icon path returns a forced 32x32 output
- Bitmap path still depends on current grid sizing / dithering helpers

### Effects rendering
- `renderEffects()` lives in `app.js`
- base image draw
- baked visible layers
- real-time checker overlay
- marker rails
- noise overlay
- status/sidebar refresh

### Export
- export flow was historically important in j/k and must be re-audited against current repo truth
- export semantics must remain visible in future audit:
  - checker bake behavior
  - rails/noise in export flow
  - warning/progress UX still pending at product level

---

## 6. Current technical strengths

- repo is not monolithic anymore
- Icon already has dedicated engine split
- state model is explicit enough to audit
- current shell looks like one app, not a random file pile
- archive/backup traces exist
- version continuity through 0.6.5j / 0.6.5k is visible in handoff material

---

## 7. Current technical risks / debt

### High
- `app.js` still appears to carry too much shared orchestration
- Effects semantics may be implemented in ways that blur rails / layers / mask / noise
- closed product truths are probably not all reflected in current repo behavior

### Medium-high
- UI encoding / symbol cleanliness issues visible in exported text (`Â·`, garbled toolbar symbols)
- dead or stale utility logic may still exist
- current docs may lag behind actual repo state

### Medium
- file ownership lines between global shell and per-engine logic are still not fully mature
- export truth likely depends on current render coupling
- Bitmap still appears underrepresented as a dedicated engine layer

---

## 8. Technical truths that must be verified in the next audit

Claude CLI should explicitly verify:

1. whether current repo behavior matches Chapter 1/2/3 product closures
2. whether Effects preserves source-image fidelity
3. whether checker preview treatment matches approved direction
4. whether rails remain procedural and baked checker remains layer-like
5. whether noise obeys occupancy rules
6. whether global navigation/feedback/export clarity matches Chapter 3
7. whether Icon’s current engine is still aligned with the original icon reliability direction
8. whether `app.js` is overloaded enough to require future refactor planning
9. whether any current code contradicts the “Mono out of Icon/Bitmap” closure
10. whether current export behavior is semantically honest

---

## 9. Tech-log doctrine for next updates

Update this file when:
- repo audit completes
- real implementation meaning changes
- file ownership changes materially
- export/model/layer semantics change
- dead code is confirmed or removed

Do not use this file for:
- roadmap priorities
- continuity handoff
- motivational history
- reusable learning extraction
