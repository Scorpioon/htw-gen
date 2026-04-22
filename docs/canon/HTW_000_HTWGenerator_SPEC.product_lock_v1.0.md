# HTW Generator — Product Lock v1.0

**Source basis:** Chapter 1 CLOSED v1 + Chapter 2 CLOSED v1 + Chapter 3 CLOSED v1  
**Role:** condensed product truth for handoff and audit  
**Do not use as:** tech log or roadmap

---

## 1. Product identity

HTW Generator is a **creative-suite-style visual tool**.

It is:
- dense
- exploratory
- forensic / tool-heavy
- proprietary-feeling
- production-oriented

It is not:
- a toy filter app
- a simplified casual converter
- a generic trendy design widget

---

## 2. Product family

The product is one family with three engines:

1. **Icon**
2. **Effects**
3. **Bitmap**

They are not unrelated mini-tools.
They share:
- system grammar
- density logic
- control philosophy
- state visibility expectations
- suite-level UX behavior

---

## 3. Core system truths

### Canon symbolic grid
- **32x32** remains the noble icon reference grid

### Wider density family
- 2
- 4
- 8
- 16
- 32
- 64
- 128
- 256

### Grid meaning
The grid is not decorative.
It represents actual selected system structure.

### UI doctrine
- no fake UI
- no visual dead ends
- stable IDs / hooks
- future-logic ready
- modularity always

---

## 4. Engine truths

## 4.1 Icon

### Role
Primary symbolic / branding engine.

### Locked truths
- 32x32 remains the key symbolic authoring/reference space
- Icon belongs to the wider density family, not a disconnected one-off mode
- output must favor readability and identity coherence
- clean SVG export matters
- Icon must not be casually destabilized by unrelated work

### Product reading
Icon is the symbolic heart of the suite.

---

## 4.2 Effects

### Role
Controlled visual editing workspace built on top of the source image.

### Locked truths
- original image must always remain visible
- Effects preview must stay faithful to the source image
- user must understand:
  - original image
  - overlay preview
  - editable mask area
  - committed baked layer
  - procedural toggle content
- masking is real logic state
- rails remain procedural toggles
- checker actions are commit-capable layer outputs
- noise may only occupy free space; it must not overwrite checker or marker zones
- tool separation between masking and painting should become clearer
- stronger state readability is mandatory

### Product reading
Effects is not a toy filter tab.
It is an editor surface.

---

## 4.3 Bitmap

### Role
Raster / dither / shape translation engine.

### Locked truths
- Bitmap belongs to the same product family as Icon and Effects
- production usability matters
- controls should be judged by production value, not novelty alone
- Mono mode is out of Bitmap
- future expansion is allowed, but controlled

### Product reading
Bitmap is not just “cool output”.
It is one of the core asset-generation engines.

---

## 5. Global UX/UI truths

### Suite shell
The current shell structure is valid and should not be casually replaced.

### Global navigation
Navigation must behave consistently across all 3 modes.

### State visibility
If something is:
- active
- selected
- recalculating
- exporting
- preview-only
- baked
- procedural

the system should communicate that clearly.

### Legibility
Legibility outranks gratuitous weirdness.

### Progress / export feedback
Heavy operations must never feel like a silent hang.
Warnings / progress / recalculation feedback are part of product truth.

### Shortcuts and dense vibe
The tool may remain dense and shortcut-rich.
That density is part of the desired feel.
But it must remain legible and actionable.

---

## 6. Color / mono truth

### Locked rule
Mono mode is:
- **out of Icon**
- **out of Bitmap**
- may remain in **Effects** only

### Checker in mono
Checker remains `mono color + white`.

---

## 7. Production truth

The product target is:

- **production usable**
- but still **future ready**

This means:
- no feature creep without control
- no fake polish over broken semantics
- no architecture flattening
- no redesign drift

---

## 8. What is out of scope for audit interpretation

Do not infer from this spec that:
- every closed decision is already implemented
- the repo is already product-complete
- any unresolved area may be redesigned freely

The correct use of this file is:
- compare it against repo truth
- detect mismatches
- phase the roadmap accordingly
