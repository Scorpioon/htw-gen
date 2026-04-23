# HTWGEN — Effects Invariants
**Base version:** `v0.6.5m`  
**Scope:** non-negotiable behavior and structure constraints for the fragile Effects lane  
**Purpose:** define what must survive before any further polish, hotfix, or sanitation extraction.

---

## 0. Why this doc exists

The Effects lane is not only fragile because of complexity.
It is fragile because many edits have been attempted without a hard list of invariants.

This document answers:
- what must keep working
- what exact paths must survive
- what kinds of edits are safe
- what kinds of edits require audit first

It is not a redesign brief.
It is not a wishlist.
It is a guardrail document.

---

## 1. Core doctrine

For Effects:
- **working behavior outranks elegance**
- **existing handler paths outrank cleaner markup**
- **wrapper-only changes outrank rebuilt controls**
- **one surface per pass outranks “finishing more”**

If a change violates those priorities, it needs re-scoping.

---

## 2. Product-behavior invariants

These are behavior truths that must not break during delivery or sanitation unless explicitly targeted.

## 2.1 Effects render baseline
Must keep working:
- base image render
- color / grayscale base image toggle
- checker rendering
- rail / border rendering
- noise rendering
- baked layer rendering
- viewport redraw after state changes

No sanitation pass may casually alter output semantics.

## 2.2 Bake workflow
Must keep working:
- Apply Layer / bake action
- baked layers added to stack
- Undo last step
- Delete all layers
- layer visibility toggle
- layer delete action

These are critical user trust actions.

## 2.3 Mask workflow
Must keep working:
- brush painting
- eraser
- rect selection
- checker-size relation
- mask clear behavior
- repaint after mask changes

## 2.4 Export workflow
Must keep working:
- export path invocation
- visible feedback after export
- no accidental removal of existing export behavior

## 2.5 Keyboard workflow
Must keep working:
- already-wired shortcuts
- mode guards where required
- `dProc()` after state changes that need redraw

---

## 3. Structural invariants

These are not product semantics but structural truths that currently protect working behavior.

## 3.1 `wireUI()` is fragile and must be preserved
Unless a pass explicitly targets event routing:

Do not:
- change delegated selector set casually
- invent new handler routes when an old one works
- move working behavior from one attribute path to another for style reasons

Default rule:
- preserve existing `data-*` paths and IDs

## 3.2 `handleToggle()` only owns click toggles
Do not assume:
- a toggle helper automatically wires keyboard
- a visible hint means keyboard support exists

Invariant:
- click and keyboard are different ownership surfaces

## 3.3 `renderSidebar()` lifecycle is special
Because sidebar rebuild/rebind can replace nodes:

Do not:
- restore state on stale sidebar references
- assume a DOM node survives the rebuild path
- add rebuild-adjacent changes casually

If a pass touches sidebar lifecycle:
- audit first
- keep the change minimal

---

## 4. Surface-specific invariants

## 4.1 `sbEffects()` invariants
`sbEffects()` is a hotspot.

Unless a pass explicitly targets structure:
- do not rewrite the full function
- do not reorder sections casually
- do not rebuild control markup if the current control path works
- do not touch unrelated blocks “while you are here”

Safe changes here are:
- tiny text-node change
- wrapper-only layout change
- clearly bounded section-local change

Unsafe changes here are:
- whole-function reorder
- helper-path changes
- multi-section mixed edits

## 4.2 Layer row invariants
For the layer row inside `sbEffects()`:

Must preserve:
- `data-layer-delete="${i}"`
- `data-layer-visible="${i}"`
- row ordering
- visibility toggle semantics
- delete behavior

Do not:
- replace the interaction path for cosmetic reasons
- change both text and structure in a “label hotfix”
- introduce non-ASCII risky characters during text fixes

## 4.3 Actions row invariants
For Apply / Undo / Delete all:

Must preserve:
- exact working IDs
- existing disabled logic
- existing trigger path
- button meaning and order unless explicitly planned

Do not:
- recreate buttons manually unless unavoidable
- change IDs during a layout-only pass
- mix actions-row layout change with unrelated sidebar restructure

## 4.4 BASE IMAGE toggle invariants
Must preserve:
- click path via `data-t="ecolor"`
- state mutation via `handleToggle('ecolor')`
- redraw path via `dProc()`

If adding keyboard support:
- add it in keydown handler only
- keep `S.mode === 'effects'` guard
- do not alter click path

---

## 5. Text / encoding invariants

This area needs explicit rules because it already failed more than once.

## 5.1 ASCII-safe patching
For text-only fixes:
- use ASCII quotes only
- use ASCII labels where possible
- do not paste decorative Unicode unless explicitly justified
- do not let the coding LLM introduce smart quotes

## 5.2 Text-only means text-only
If the goal is to fix visible text:
- change the text node only
- do not change element type
- do not change attributes
- do not change handler path
- do not change surrounding structure

## 5.3 If a text fix looks ugly but works, that is a semantic/UI issue, not a wiring issue
That must be handled in a later pass as:
- visual-role correction
not as:
- repeated unsafe text surgery

---

## 6. CSS invariants

## 6.1 Contrast passes are safe only when color-only
If touching shared sidebar CSS:
- color-only changes are safe
- spacing/layout/size changes are a different pass

## 6.2 Shared selectors must be treated as shared
Classes like:
- `.sbl`
- `.togk`
- `.slrow label`

may affect multiple modes.

Do not assume:
- Effects-only visual change
unless that selector is truly local.

---

## 7. Geometry invariants

Geometry is its own lane.

Do not combine with sidebar/UI passes:
- border centering
- rail/noise placement
- export parity
- remainder handling

If touching geometry:
- do not touch sidebar
- do not touch handler paths
- do not touch template structure

---

## 8. Pass-class invariants

These rules define what each pass type is allowed to do.

## 8.1 Hotfix pass
Allowed:
- one or two tiny deltas
- one file if possible
- visible bug fix
- no cleanup

Not allowed:
- opportunistic refactor
- section reorder
- helper rewrite

## 8.2 Contrast/readability pass
Allowed:
- color-only CSS changes

Not allowed:
- spacing
- structure
- behavior
- new selectors unless clearly needed

## 8.3 Layout pass
Allowed:
- wrapping existing controls
- stable local grouping
- CSS changes required for layout

Not allowed unless explicitly approved:
- rebuilding controls
- changing IDs
- changing handler route

## 8.4 Sanitation extraction pass
Allowed:
- extract one mini-surface
- preserve behavior exactly
- add local helper if ownership gain is clear

Requires before implementation:
- ownership map
- invariants known
- exact preserved paths listed

---

## 9. Red-flag conditions

Stop and re-audit if any of these happen:

- a layout change requires rewriting handlers
- a text change changes structure
- a hint and a keyboard behavior disagree
- a helper appears to promise behavior it does not own
- a pass touches both sidebar structure and geometry
- a pass touches both delivery bugfix and sanitation extraction
- an LLM says “small change” but the diff spans multiple unrelated regions

---

## 10. What “safe” actually means here

A change is safe if:
- ownership is known
- invariant list is explicit
- delta is tiny
- rollback is easy
- behavior path remains intact

A change is not safe just because:
- the request sounds small
- the file count is one
- the LLM says it is simple

---

## 11. Recommended use

Before any future Effects pass:
1. read ownership map
2. read invariants
3. run READ + MODEL
4. then patch

If a proposed patch cannot explicitly say which invariants it preserves, it is not ready.

---

## 12. One-line doctrine

**In fragile systems, the first refactor is naming what must not break.**
