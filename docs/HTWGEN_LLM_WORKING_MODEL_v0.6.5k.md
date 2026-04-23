# HTWGEN — LLM Working Model
**Version anchor:** `v0.6.5k`  
**Purpose:** Give coding LLMs the minimum operational model they must reconstruct before touching the HTW Generator repo.

---

## 0. Why this exists

Recent failures showed the same pattern:

- small visual requests caused structural edits
- template rewrites broke handlers
- helper usage was not respected
- seemingly tiny changes introduced non-ASCII quotes or wrong attributes
- “UI polish” widened into regressions

This document exists to stop that.

It is not a product roadmap.
It is not a redesign brief.
It is not a feature spec.

It is a working model + invariants surface.

---

## 1. Repo truth

- Stable base for this lane: `v0.6.5k`
- Current focus: `Effects`
- Do not reopen `Icon` or `Bitmap` unless explicitly asked
- Do not widen into architecture refactor
- Do not widen into engine extraction
- Do not assume prior failed attempts are the source of truth

---

## 2. Core mental model

The Effects system is fragile because UI, template structure, handlers, and behavior are tightly coupled.

### Practical consequence
A “small UI change” can break:
- click handling
- layer controls
- Apply / Undo / Clear
- section rendering
- scroll behavior

So every change must respect the existing chain:

**template -> IDs / data-attrs -> handler routing -> runtime behavior**

If you change one surface casually, you can break the chain.

---

## 3. High-risk surfaces

### 3.1 `sbEffects()`
This is the main sidebar template surface for Effects.

It is high risk because it controls:
- section order
- row structure
- layer controls
- button markup
- the visible ownership model of the tool

Rules:
- do not rewrite casually
- do not rebuild existing controls unless explicitly required
- preserve working helper usage when possible
- preserve data attributes exactly unless the goal is to change handler routing

### 3.2 `wireUI()`
This is the event-routing surface.

Rules:
- do not touch unless absolutely necessary
- do not invent new interaction paths when an existing path already works
- if a control already works through an existing attribute/ID path, reuse that path

### 3.3 `renderSidebar()`
This is a rebuild surface.

Important:
- sidebar rebuilds can reset scroll
- `wireUI()` may replace cloned nodes, making stale references useless

Rules:
- if fixing scroll behavior, re-query live DOM after the rebuild path
- keep fixes minimal
- do not turn this into a general state manager

### 3.4 Geometry / border / noise render functions
These are separate from sidebar polish.

Rules:
- do not mix sidebar passes with placement math passes
- do not touch geometry in a UI-only pass
- do not touch sidebar structure in a geometry-only pass

---

## 4. Invariants that must be preserved

Before changing anything, the coding LLM must explicitly preserve these unless the task says otherwise.

### 4.1 Effects semantics
Do not break:
- bake logic
- noise logic
- checker painting
- palette behavior
- export composite behavior
- keyboard flow

### 4.2 Existing working handler path
If a button/control already works:
- keep the same ID
- keep the same data attribute
- keep the same helper path
- wrap it if needed
- do not rebuild it for style reasons alone

### 4.3 ASCII-safe source editing
Do not introduce:
- curly quotes
- smart quotes
- fancy punctuation copied from rich text
- raw symbols when a plain text alternative is safer

Use:
- plain ASCII quotes
- plain text labels where possible

---

## 5. Known failure patterns

### 5.1 “Looks small” but is not
Example pattern:
- “just make Actions horizontal”
- result: button path rebuilt
- Apply stops working

Lesson:
layout requests must preserve control generation path.

### 5.2 New attribute path invented
Example pattern:
- new `data-*` path introduced for one mode
- existing routing no longer matches real click behavior

Lesson:
reuse proven handler routes whenever possible.

### 5.3 Text-only hotfix that was not text-only
Example pattern:
- replace mojibake text
- result: smart quotes introduced
- markup breaks or behaves inconsistently

Lesson:
for textual hotfixes, the diff must be textual only.

### 5.4 Multiple families changed in one pass
Example pattern:
- sidebar reorder
- layer controls
- actions row
- scroll behavior
- geometry math
all in one pass

Lesson:
one surface per version.

---

## 6. Mandatory pre-change reconstruction

Before implementation, the coding LLM must be able to answer:

1. What exact file owns the behavior?
2. What exact function owns the behavior?
3. What IDs / data-attrs / helper calls are critical?
4. What must remain unchanged?
5. What exact allowed delta is requested?

If it cannot answer these, it is not ready to patch.

---

## 7. Safe working pattern

For fragile HTW changes, use this order every time:

### Step 1 — READ
Read only the files/functions needed.

### Step 2 — MODEL
Explain current behavior in local terms.

### Step 3 — INVARIANTS
State what must not change.

### Step 4 — ALLOWED DELTA
State the smallest allowed edit.

### Step 5 — IMPLEMENT
Only after the above is accepted.

---

## 8. Patch discipline for HTW fragile surfaces

Preferred format for tiny or medium changes:

- one file
- one region
- one visible goal
- exact before/after lines
- no bundled cleanup
- no “while I’m here” edits

For UI-sensitive changes:
- preserve working handlers first
- visual improvement second

---

## 9. Current priority ladder

For this phase, value order is:

1. keep the system working
2. isolate tiny wins
3. validate each win
4. only then move to the next roadmap step

Do not optimize for elegance first.
Optimize for stable progress.

---

## 10. One-line doctrine

For HTW fragile surfaces:
**model first, preserve invariants second, patch last.**
