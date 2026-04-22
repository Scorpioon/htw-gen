# POB — HTW Generator

## Scope
- Project / area: HTW Generator
- Lane / phase: audit-first repo alignment for Claude CLI
- Mode: AUDIT MODE
- Baseline:
  - current repo truth: **0.6.5k**
  - last historically trusted modular base: **0.6.0a**
  - current work must audit **0.6.5k**, not retreat blindly to 0.6.0a

## Current truth
- HTW Generator is an ongoing modular web tool with three engines: Icon, Effects, Bitmap.
- The current repo is already modular and includes:
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
- The app header/version surface in the handoff bundle already shows **v0.6.5k**.
- Product docs for Chapters 1 / 2 / 3 are conceptually closed.
- Continuity now needs a tighter doc pack so Claude can audit docs vs repo without chat-noise contamination.

## State
- Product direction is mostly clear.
- Repo truth exists and is usable.
- Documentation is not yet compressed into the best Claude-facing bundle.
- Current task is documentation alignment and audit preparation, not coding.

## Delta
- Repo version has been clarified as **0.6.5k**.
- The lane has shifted from “patch-style assistance” to **direct repo audit through Claude CLI**.
- The target is no longer “write a patch now”; the target is “audit what the app is vs what the product says it should be”.
- Product truth from Chapter 1 / 2 / 3 must now be consolidated into cleaner handoff docs.

## Next move
- Load the repo plus the condensed HTW doc pack into Claude CLI and request a strict audit + roadmap proposal only.

## Dangers
- confusing 0.6.0a with the current repo baseline
- treating donor/history files as current truth
- giving Claude raw chats instead of distilled docs
- mixing roadmap, tech truth, and continuity into one blob
- letting audit drift into implementation too early
- reopening locked product decisions because of local code friction

## Blockers / classifications
- blocker: missing clean Claude-facing doc compression
- blocker: product-docs vs repo-docs audit not yet run on 0.6.5k
- debt: technical truth still partially dispersed across chat logs and old audits
- debt: `app.js` likely still carries too much orchestration load
- later: local WWL / reusable lessons package
- interesting: future richer coder-facing protocol subset for HTW only

## Active rules
- WRKOPS / CCOS governance
- audit before implementation
- user is source of truth
- docs first, chat second
- one dominant job per markdown
- roadmap integrity outranks reactive fixing
- no autonomous redesign
- modularity always

## Surfaces that matter next
- `HTW_Chapter_1_CLOSED_v1.md`
- `HTW_Chapter_2_CLOSED_v1.md`
- `HTW_Chapter_3_CLOSED_v1.md`
- `master_audit_doc_v1.md`
- current repo at `0.6.5k`
- handoff bundle file map and current code surfaces

## What not to assume
- do not assume all current docs are authority-clean
- do not assume all spec items from closed chapters are already implemented
- do not assume Effects semantics are finished
- do not assume export UX is fully production-ready
- do not assume old patch notes equal current repo truth

## Resume advice
- start from product docs + repo reality
- classify findings
- build roadmap from blockers first
- keep one next move only
- do not code until the audit is reviewed
