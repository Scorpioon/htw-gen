# HTW Generator — Local Work Contract v1.0

**Project:** HTW Generator  
**Repo current version:** 0.6.5k  
**Stable historical reference:** 0.6.0a modular  
**Primary repo root:** `K:\DEVKIT\projects\htw-generator\htw-generator`  
**Workflow:** CCOS / WRKOPS-governed, adapted for direct repo work with Claude CLI  
**Status:** ACTIVE FOR THIS LANE

---

## 1. Purpose

This document gives Claude CLI the local rules that matter for this project.

It is not a replacement for WRKOPS.
It is the project-local execution contract for the current audit-and-roadmap lane.

---

## 2. Current lane

**Mode:** AUDIT MODE  
**Immediate output goal:** repo-context audit + roadmap alignment  
**Not allowed in this turn by default:**
- no direct implementation
- no blind rewrite
- no architecture flattening
- no scope expansion disguised as cleanup

Current objective:

1. read the product docs first
2. inspect the real repo state second
3. compare docs vs app reality
4. detect drift, contradictions, and risk
5. propose the safest implementation order by layers
6. stop there unless explicitly advanced

---

## 3. Source of truth hierarchy

Priority order for this project:

1. explicit user decisions
2. approved product docs
3. current real repo state
4. approved historical audits
5. chat discussion
6. donor/reference material

Rules:

- if docs and chat disagree, docs win until updated
- if docs and real repo disagree, name the contradiction explicitly
- do not smooth contradictions into fake harmony
- historical files are not automatic baseline truth
- donor references are reference only, not replacement candidates

---

## 4. Locked product truths

These are already closed and should not be casually reopened:

- HTW Generator is a **creative-suite-style tool**, not a casual filter toy
- the product family is **Icon / Effects / Bitmap**
- **32x32** remains the noble icon reference grid
- the wider density family **2 / 4 / 8 / 16 / 32 / 64 / 128 / 256** remains part of the product system
- grid is not decorative; it expresses actual system structure
- UI may remain dense / forensic / tool-heavy, but must communicate state clearly
- no fake UI
- modularity always
- future-logic readiness always
- Effects remains an editor-like workspace, not a gimmick preview tab
- Rails and baked checker layers are not the same semantic system
- Mono mode is out of Icon and Bitmap; it may remain in Effects only

---

## 5. Current product priority order

Implementation priority remains:

1. **Icon**
2. **Effects**
3. **Bitmap**

This does **not** mean the audit should ignore Effects or Bitmap.
It means roadmap alignment should keep this production priority visible.

---

## 6. Repo / architecture rules

Claude CLI must respect these rules while auditing:

- do not flatten the modular structure back into a monolith
- do not silently merge responsibilities into `app.js` just because it is convenient
- preserve clear ownership between:
  - `index.html`
  - `styles.css`
  - `app.js`
  - `core/*`
  - `engines/*`
- if a file is overloaded, call it out as debt instead of auto-redesigning it
- if naming is weak, flag it, but do not rename half the app in an audit pass

---

## 7. Drift detection duties

Claude CLI must explicitly watch for:

- product drift
- architecture drift
- semantic drift
- UX drift
- source-of-truth drift
- roadmap drift
- baseline drift
- export drift
- masking / layer drift
- rail / noise drift
- version drift

If drift is detected:

1. name it
2. classify it
3. say whether it is blocker / debt / later / interesting / not now
4. place it in roadmap logic
5. do not auto-fix it

---

## 8. What Claude CLI must compare

When auditing, compare at least these layers:

### Product docs
- Chapter 1 CLOSED v1
- Chapter 2 CLOSED v1
- Chapter 3 CLOSED v1
- product lock / condensed product truth

### Continuity / status docs
- POB
- roadmap
- master audit
- dev log if needed
- tech log if needed

### Real repo state
- actual file map
- actual engine split
- current version references
- current UI / export / state model
- current known weak spots

---

## 9. Required behavior in audit output

Claude CLI should return:

- current status snapshot
- drift + risk audit
- roadmap proposal
- future implementation order
- things that must not be touched yet
- acceptance criteria per phase
- explicit uncertainty where repo truth is incomplete

It should **not** return:

- giant prose walls
- implementation code
- direct file rewrites
- speculative redesigns
- “best practices” detached from this repo

---

## 10. One-lane rule

This lane has one next move only:

**Audit product docs vs repo 0.6.5k and propose the safest roadmap to align app reality with product truth.**

Do not turn this into a coding session unless explicitly requested after the audit is reviewed.

---

## 11. Red lines

Do not:

- treat historical monoliths as the active base
- assume 0.6.0a can simply replace 0.6.5k
- collapse Rails, Checker layers, and Noise into one idea
- redesign the UI skeleton
- simplify away the forensic / proprietary-tool feel
- remove shortcuts or dense-tool vibe just to look cleaner
- use donor references as hidden replacement architecture

---

## 12. Success condition for this lane

This lane is successful only if Claude CLI leaves behind:

- a clear reading of what the app is now
- a clear reading of what the product is supposed to be
- a clean mismatch map
- a safe phase order
- no accidental implementation drift
