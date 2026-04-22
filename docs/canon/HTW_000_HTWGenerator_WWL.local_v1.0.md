# WHAT WE LEARNED — HTW Generator local WWL v1.0

## 0. Scope
- Project / area: HTW Generator
- Extraction scope: this project’s current workflow and handoff behavior
- Purpose: preserve local lessons that materially improve future work with Claude CLI / audit-first repo alignment

---

## 1. Strongest project-local learnings

### 1.1 0.6.0a and current repo truth are different kinds of truth
- 0.6.0a is a historically strong modular base
- 0.6.5k is the current repo truth
- future work must not collapse those into one mental model

### 1.2 Product truth was recovered through chapters, not through code alone
- Chapter 1 / 2 / 3 closure was necessary to recover direction
- repo truth alone is not enough to understand intended semantics

### 1.3 Effects is the most drift-sensitive area
- rails
- checker
- noise
- masking
- baked layers
- procedural overlays

These are easy to blur if the docs are weak or the audit is skipped.

### 1.4 Dense / shortcut-rich UX is not a mistake here
The product gains value from feeling like a serious proprietary tool.
Attempts to “clean it up” into a bland simple app would be drift, not improvement.

### 1.5 Raw chat is too noisy for downstream coding models
Claude works better when:
- continuity is compressed
- product truth is condensed
- repo truth is separated
- audit brief is explicit

---

## 2. Repeated failure / friction patterns

### Pattern A — Baseline confusion
- Trigger: historical references and current repo discussed together
- Symptom: model reasons from the wrong version
- Prevention: always state current repo version and historical stable reference separately

### Pattern B — Mixed-role docs
- Trigger: one markdown tries to be roadmap + audit + context + tech log
- Symptom: downstream model loses the real next move
- Prevention: one doc = one dominant job

### Pattern C — Effects semantic blur
- Trigger: implementation talk without product lock visible
- Symptom: rails, checker layers, and noise get narratively merged
- Prevention: always load product lock + master audit before Effects planning

### Pattern D — Chat residue as false canon
- Trigger: raw logs passed directly as authority
- Symptom: old wording reopens closed decisions
- Prevention: distill chat into docs before handoff

---

## 3. Working preferences discovered

Only preferences that materially affect execution quality are included here.

- audit first, implementation later
- direct repo work is fine, but only after continuity is compressed
- dense / forensic vibe should be preserved
- product docs must be read as required context, not optional flavor
- roadmap must absorb findings before implementation resumes
- one next move only

---

## 4. What should be repeated

- condense product truth before coder handoff
- separate POB / roadmap / tech log / audit / product lock
- call out current repo version explicitly
- classify findings before acting
- keep Icon / Effects / Bitmap as one family in reasoning

---

## 5. What should not be repeated

- handing off giant raw logs as the primary source of truth
- treating historical monoliths as live baseline
- blending roadmap, audit, and tech truth into one file
- drifting into implementation before the repo-context audit is reviewed
- narrating Effects as one undifferentiated effect soup

---

## 6. Promotion filter

### Keep local
- 0.6.0a vs 0.6.5k dual-baseline caution
- HTW-specific dense-tool UX reading
- Icon > Effects > Bitmap production priority

### Possible global candidates
- compress chat into role-clean docs before coder handoff
- state historical stable reference separately from current repo truth
- mixed-role markdowns materially degrade downstream LLM quality

### Not for promotion yet
- engine-specific HTW semantics
- local naming choices
- local production priorities
