# HTW Generator — Audit Brief for Claude CLI v1.0

CONTRACT ACTIVE.

MODE: AUDIT MODE  
OUTPUT: PLAN_MIN

---

## 1. What you are entering

You are entering an ongoing product-development workflow for **HTW Generator**.

Current repo truth:
- version: **0.6.5k**
- repo root: `K:\DEVKIT\projects\htw-generator\htw-generator`

This is a **direct repo workflow**.
Do not think in patch-delivery terms for this turn.

---

## 2. Your job in this turn

Read the provided HTW docs first, then inspect the real repo, then produce a strict audit.

You must:

1. audit the current repo against the product docs
2. detect product drift, architecture drift, semantic drift, UX drift, and source-of-truth drift
3. classify findings
4. propose the safest roadmap by layers
5. stop there

---

## 3. What you must return

Return only **PLAN_MIN** with these sections:

### A. Current status snapshot
- what the app currently is
- major systems present
- known stable / unstable areas
- current engine split reading

### B. Drift + risk audit
- what drifted
- what was lost or blurred
- biggest warnings
- logic inconsistencies
- UI / UX inconsistencies
- export / layer / masking / rail / noise / palette warnings where relevant

### C. Future implementation order
- best order by layers / passes
- what must be fixed first
- what must be deferred
- what should not be touched yet
- how to reduce regression risk

### D. Roadmap proposal
- phase list
- goal of each phase
- why that order is best
- acceptance criteria per phase

### E. Classification block
Use:
- blocker
- debt
- later
- interesting
- not now

---

## 4. Hard rules

- do **not** implement anything yet
- do **not** rewrite architecture
- do **not** flatten modular structure
- do **not** assume older historical baselines are current truth
- do **not** use donor/history files as replacement candidates
- do **not** reopen locked product truths casually
- if repo truth is uncertain, say so explicitly
- if a contradiction exists, name both sides and say which layer outranks

---

## 5. Important reading discipline

Treat the docs as real source-of-truth layers, not optional background flavor.

Priority order:
1. explicit user decision
2. product lock docs
3. current real repo state
4. historical audits
5. chat residue

---

## 6. What success looks like

A successful answer leaves behind:

- a clear current-state reading
- a trustworthy mismatch map
- a safe phase order
- a clear “do not touch yet” list
- no accidental implementation drift
