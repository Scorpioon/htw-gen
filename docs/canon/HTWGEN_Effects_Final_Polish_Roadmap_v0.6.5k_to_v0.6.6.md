# HTW / GEN — Effects Final Polish Roadmap

**Current version:** `0.6.5k`  
**Target release line:** controlled micro-passes toward `0.6.6`  
**Mode:** roadmap / delivery control  
**Purpose:** stop bundling too much in one pass and close the remaining Effects polish little by little, without destabilizing the working base.

---

## 0. Source-of-truth reading

This roadmap is based on the currently re-established stable base `0.6.5k` and on the polish requests repeatedly raised in the recent lane:

### What is still wanted
- better overall **tool feel** in Effects
- stronger **semantic grouping** in the sidebar
- better **dark-mode readability / contrast**
- `Apply Layer / Undo last step / Delete all layers` in **3 horizontal columns**
- `LAYERS` in its own **local scroll box**
- no full-sidebar scroll hijack from layers
- cleaner / more coherent **delete control**
- explicit re-check of **EFX-3** (`Apply Layer` / rerender / jump / sidebar stability)
- fix for **border remainder conflict** when image dimensions do not divide cleanly by active grid size
- preserve exact final output dimensions
- avoid useless black residual strip in viewport/export

### What is explicitly out
- no engine extraction
- no architecture refactor
- no broad product redesign
- no Icon / Bitmap reopening
- no state-model rewrite
- no giant “one pass does everything”

---

## 1. Master rule for the remaining work

**One surface per version.**

No more mixed mega-passes like:
- sidebar reorder + actions row + layers local scroll + border math + export changes

Instead:
- one version = one small visible family of change
- test
- lock
- continue

If a pass touches both **sidebar structure** and **render math**, it is too broad.

---

## 2. Full remaining change list

### A. Delivery / confidence fixes
1. **EFX-2 export feedback**
   - visible feedback on export
   - avoid “button appears to do nothing”

2. **EFX-3 sidebar jump on Apply**
   - preserve sidebar scroll position across sidebar rebuild
   - confirm actual symptom, not guessed symptom

### B. Sidebar readability / semantics
3. **Contrast pass**
   - stronger text/readability in dark mode
   - avoid grey text that looks disabled

4. **Semantic reorder**
   - cleaner order of sections
   - better ownership:
     - base/source
     - generation
     - authoring
     - output

5. **Actions row**
   - `Apply Layer / Undo last step / Delete all layers`
   - horizontal, same family, same band

6. **Layers local scroll**
   - `LAYERS` gets its own local box
   - does not consume full sidebar scroll
   - visible even when empty

7. **Delete control coherence**
   - replace wrong-feeling delete control
   - use sober, readable system language

### C. Geometry / border / export finish
8. **Centered border working rect**
   - stop the border from behaving like it starts from top-left origin

9. **Centered rail / noise remainder behavior**
   - border / rail / noise should visually align with the centered working rect

10. **Residual strip finish**
   - solve the thin leftover black / empty strip problem
   - preserve exact output size
   - no destructive crop

### D. Release closure
11. **Final validation + version bump**
   - only after all accepted micro-passes validate cleanly

---

## 3. Proposed version roadmap

## `0.6.5l` — Effects confidence hotfix
**Scope**
- EFX-2 export feedback only
- EFX-3 sidebar jump diagnosis/fix only

**Why first**
- these are confidence killers in real use
- very small surface
- high delivery value

**Files likely touched**
- `app.js`

**Validation**
- export gives visible feedback
- applying a layer no longer jumps sidebar position unexpectedly

**Out**
- no sidebar reorder
- no CSS pass
- no border math

---

## `0.6.5m` — Contrast / readability only
**Scope**
- dark-mode readability pass only
- section labels, key hints, slider labels
- no structure movement

**Files likely touched**
- `styles.css`

**Validation**
- labels readable for non-perfect vision
- nothing important looks disabled by mistake

**Out**
- no `sbEffects()` restructure
- no actions row
- no layers box
- no geometry

---

## `0.6.5n` — Actions row only
**Scope**
- `Apply Layer / Undo last step / Delete all layers` into one horizontal row
- preserve existing working trigger path exactly
- no custom manual button reinvention if helper/ids already exist

**Files likely touched**
- `app.js`
- `styles.css`

**Validation**
- all 3 buttons work
- same widths
- no regression in Apply
- no change to bake semantics

**Out**
- no layers scroll box
- no section reorder
- no border math

---

## `0.6.5o` — Layers box only
**Scope**
- `LAYERS` always visible
- local scroll box
- no disappearance when empty

**Files likely touched**
- `app.js`
- `styles.css`

**Validation**
- empty state still shows `LAYERS`
- 5+ layers scroll locally
- sidebar stays stable
- delete / visibility controls still work

**Out**
- no actions changes
- no reorder
- no border math

---

## `0.6.5p` — Delete control coherence only
**Scope**
- replace the awkward delete control with a sober, readable one
- preserve exact delete handler path

**Files likely touched**
- `app.js`
- maybe `styles.css`

**Validation**
- looks coherent
- deletes correct layer
- does not read like decorative icon noise

**Out**
- no other sidebar changes
- no geometry

---

## `0.6.5q` — Semantic reorder only
**Scope**
- reorder sections, nothing else

**Preferred target order**
1. `BASE IMAGE`
2. `PALETTE`
3. `EDGE MODE`
4. `STRUCTURE SIZE`
5. `RAILS`
6. `SEED`
7. `NOISE`
8. `CHECKER`
9. `LAYERS`
10. `ACTIONS`

**Files likely touched**
- `app.js`

**Validation**
- ownership clearer
- no control lost
- no handler regression

**Out**
- no CSS contrast changes
- no actions rework
- no geometry

---

## `0.6.5r` — Border centering in viewport
**Scope**
- centered working rect for border placement in viewport only
- smallest possible placement math change

**Files likely touched**
- `app.js`

**Validation**
- border no longer feels top-left anchored
- right/bottom remainder behaves more symmetrically

**Out**
- no export parity yet
- no checker changes
- no sidebar

---

## `0.6.5s` — Rail / noise centering parity
**Scope**
- align rail / noise rendering with centered border behavior
- keep checker untouched

**Files likely touched**
- `app.js`

**Validation**
- rail / noise visually align with new centered border logic
- noise blocking still works

**Out**
- no export finishing yet
- no sidebar

---

## `0.6.5t` — Export remainder finish
**Scope**
- export/view parity for the border remainder case
- solve residual black strip problem
- preserve exact final output size

**Files likely touched**
- `app.js`

**Validation**
- exported PNG matches viewport intent
- no useless residual strip
- no forced resize
- no destructive crop

**Out**
- no sidebar

---

## `0.6.6` — Final closure
**Scope**
- final validation pass
- smoke checklist
- version bump only now

**Files likely touched**
- version surfaces only after all previous passes are accepted

**Validation**
- Effects usable
- sidebar readable
- actions stable
- layers stable
- border finish correct
- export exact size preserved

---

## 4. Recommended execution order

### Delivery-first order
1. `0.6.5l` — confidence hotfix
2. `0.6.5m` — contrast
3. `0.6.5n` — actions row
4. `0.6.5o` — layers box
5. `0.6.5p` — delete control
6. `0.6.5q` — semantic reorder
7. `0.6.5r` — border centering viewport
8. `0.6.5s` — rail/noise parity
9. `0.6.5t` — export remainder finish
10. `0.6.6` — closure

### If Friday is too close
Use this compressed minimum:
1. `0.6.5l`
2. `0.6.5m`
3. `0.6.5n`
4. `0.6.5r`
5. `0.6.5t`
6. `0.6.6`

That is the shortest plausible road that still produces real value.

---

## 5. Priority classes

### Blockers for delivery confidence
- export feedback
- apply/sidebar jump
- residual strip in final output

### High-value polish
- contrast readability
- actions row
- border centering

### Useful but deferrable
- delete control coherence
- semantic reorder
- layers local scroll if layer count stays low in demo

---

## 6. Rule for every next pass

Before each pass:
- restate current version
- restate exact target version
- touch only the files for that pass
- do not sneak in cleanup
- validate before moving on

---

## 7. Final working doctrine

The remaining work is not:
- one big final cleanup

The remaining work is:
- **a staircase of tiny controlled wins**

That is how this actually gets shipped.
