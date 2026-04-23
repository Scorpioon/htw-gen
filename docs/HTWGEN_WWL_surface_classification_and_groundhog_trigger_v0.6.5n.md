# WHAT WE LEARNED — EXTRACTION PASS

## 0. Chat scope
- Project / area: HTW Generator — Effects lane / sanitation and delivery stabilization
- Approximate phase / moment: late-stage polish attempt after `v0.6.5k`, during efforts to land `v0.6.5l / v0.6.5m / v0.6.5n / v0.6.5x`-style micro-passes
- Primary goal in this chat: finish Effects polish and light cleanup without breaking the current app
- Actual outcome: repeated regressions exposed a fragile surface (`app.js` inline HTML template strings in `sbEffects()`), forcing a method correction and a stronger Groundhog-style response

## 1. Project-local learning (HTW Generator)

### 1.1 The Effects sidebar inline template is a high-risk surface
- The layer row inside `sbEffects()` is not a normal “small text fix” surface.
- It mixes visible text nodes, inline HTML strings, delegated `wireUI()` routing via `data-*`, styling assumptions, and encoding sensitivity.
- Practical consequence: even tiny edits to this row can corrupt layout or silently break behavior.

### 1.2 `sbEffects()` is a hotspot, not a casual edit zone
- Repeated failures showed that `sbEffects()` should be treated as a fragile assembly surface.
- Future changes there should be split into:
  - text-only changes
  - behavior-only changes
  - layout-only changes
  - extraction-only changes
- Do not combine them unless there is a very strong reason.

### 1.3 The delete-label problem was not “just mojibake”
- The DEL control issue revealed multiple layers of fragility:
  - encoding fragility
  - inline-template fragility
  - semantic-role fragility (`.togk` being used for something that reads like an action)
- The user-facing symptom changed between mojibake, ugly fallback text, broken layout, and full UI corruption.
- This means the delete surface is a combined-system problem, not just a copy fix.

### 1.4 Claude was not reliable for direct edits on this exact surface
- Repeated attempts showed that Claude could:
  - reintroduce smart quotes
  - claim self-check PASS even when smart quotes were visibly present
  - perform structurally unsafe rewrites on inline template strings
- Important local conclusion:
  - this specific surface is currently manual-first
  - Claude can still be useful for audit/modeling around it, but direct implementation there is unsafe

### 1.5 Direct implementation reliability depends on the surface, not just on the prompt
- Multiple increasingly strict prompts were used:
  - narrower scopes
  - no git
  - ASCII-only instructions
  - self-check steps
  - copy-exact rules
- Even then, the model still reintroduced smart quotes / corruption.
- This proves that prompt quality alone does not guarantee safe implementation on fragile string-based surfaces.

### 1.6 The `C` shortcut issue was a clean, separate bug
- The `BASE IMAGE` toggle displayed `[C]` as a hint, but keyboard behavior was missing.
- This established a strong local invariant:
  - shortcut hint and shortcut behavior are separate surfaces
  - visual hint does not auto-wire keyboard behavior
- This is a good candidate for future safe micro-passes because it lives in a more stable area than the layer row template.

### 1.7 The layer row extraction idea was conceptually correct but operationally unsafe in the current tooling lane
- Auditing the extraction boundary was useful.
- Trying to implement extraction through Claude on the live inline string was not.
- Practical project rule:
  - keep extraction audits
  - do not assume extraction should be implemented by the same tool that audited it

### 1.8 The user manually fixed the delete label successfully in seconds
- This proves a project-level routing rule:
  - if the cost of manual edit is far lower than the expected retry cost through LLM tooling, manual wins immediately
- For HTW, the DEL label crossed that threshold very clearly.

### 1.9 Current safe interpretation of HTW implementation lanes
- Safe for Claude:
  - audits
  - system inventories
  - invariants
  - dependency maps
  - some isolated keydown-case additions
  - some CSS-only scoped work
- Unsafe for Claude:
  - direct edits to inline HTML template strings in `app.js`
  - extraction passes touching fragile template strings
  - mixed text/structure passes in `sbEffects()`

## 2. Workflow / WRKOPS learning

### 2.1 Groundhog protocol trigger must fire earlier
- The protocol itself was not wrong.
- The failure was timing.
- We should have entered Groundhog mode earlier, after repeated same-surface failures.
- New practical trigger learned from this case:
  - if a surface fails 2–3 times with the same class of regression, stop implementation and reclassify the surface before trying again

### 2.2 “One more prompt” is not always the right move
- This chat showed a classic trap:
  - better prompt
  - stricter prompt
  - even stricter prompt
  - patch
  - still broken
- New WRKOPS learning:
  - once evidence shows the tool is unstable on a surface, more prompt tightening may only increase token burn without increasing reliability

### 2.3 Surface classification matters more than tool loyalty
- The real question is:
  - what kind of surface is this
  - what failure mode does it invite
  - which tool is allowed to touch it
- This is a strong reusable workflow lesson.

### 2.4 LLMs are better used here as auditors and modelers than as direct surgeons
- The most useful outputs in this chat were:
  - sanitation roadmap
  - ownership map
  - invariants
  - cleanup ranking
  - extraction boundary audit
- The least useful outputs were direct repeated implementation attempts on the fragile row surface.
- Reusable rule:
  - in fragile code zones, LLM = modeling tool first, implementation tool second

### 2.5 Self-checks from the model are not enough on corruption-prone surfaces
- Claude reported PASS on smart-quote checks while the diff visibly contained smart quotes.
- Reusable learning:
  - self-check outputs from the model cannot be trusted as sole validation for encoding-sensitive surfaces
  - human diff inspection remains required

### 2.6 “Manual-only” is a valid workflow classification, not a failure
- Saying “manual-only” is not giving up.
- It is an optimization move when retry cost exceeds edit cost.
- This should be added to future workdocs as an explicit allowed classification.

### 2.7 When a system is fragile, audit artifacts are still valuable even if implementation fails
- The attempts were not pure waste because they produced:
  - ownership understanding
  - invariants
  - unsafe-surface classifications
  - safer future execution rules
- Reusable lesson:
  - a failed implementation phase can still be a successful learning / control phase if the results are captured properly

## 3. Operational mistakes that should be remembered

### 3.1 We stayed too long in implementation mode
- Repeated same-surface failures should have switched us into:
  - restore
  - inspect
  - classify
  - manual-or-safe-lane decision
- Instead, we stayed in implementation mode too long.

### 3.2 We allowed the tool to keep touching the same dangerous template
- Even after evidence of smart-quote corruption, the same surface kept being handed back for implementation.
- Future correction:
  - once a surface is marked unsafe, it should be blocked until explicitly reclassified.

### 3.3 We let git actions happen through Claude earlier than desired
- This reinforced a standing preference:
  - Claude should not touch git in this workflow
  - staging/committing should remain human-controlled unless explicitly authorized

## 4. Positive outcomes from this chat

### 4.1 The Effects lane now has much better documentation around fragility
- Ownership map
- Invariants
- Cleanup/sanitation roadmap
- Boundary audit
- Unsafe vs safe surface classification

### 4.2 A real decision boundary was discovered
- There is now a real decision tree:
  - audit-only
  - LLM-safe micro-pass
  - manual-only
  - Groundhog restore required

### 4.3 The delete-label issue was ultimately solved manually
- That matters because the chat ends with a corrected local state and a cleaner understanding of future method.

## 5. Proposed additions to workdocs / protocol memory

### 5.1 Add an explicit “manual-only surface” rule
- If a surface repeatedly corrupts under LLM implementation, classify it as `MANUAL ONLY` until re-audited.

### 5.2 Add an early Groundhog trigger
- Two or three repeated regressions on the same surface are enough to stop implementation and switch to restore/inspect/classify mode.

### 5.3 Add a “surface-type before tool-type” rule
- Decide the tool from the surface risk, not from general preference for one LLM.

### 5.4 Add a “LLM self-check is not validation” reminder
- On encoding-sensitive or inline-template-sensitive surfaces, model self-checks do not replace human diff inspection.

## 6. Current recommended next posture for HTW
- Keep repo on the last healthy checkpoint after the manual DEL fix
- Treat `sbEffects()` inline template strings as manual-first
- Use Claude for:
  - audits
  - planning
  - controlled low-risk changes only
- Avoid:
  - direct extraction passes on fragile inline strings
  - mixed-surface implementation prompts
  - automatic git actions from Claude

## 7. One-line summary
**This chat taught that HTW does not mainly have a prompting problem; it has a surface-classification problem, and progress starts once fragile surfaces are explicitly downgraded from LLM-implementation to manual-first or audit-only.**
