# CCDV_000_CCOS_PROTOCOL.patch_traceability_execux_v1.1.md

## 0. Purpose

This document defines the **CCOS Patch Traceability + Execution UX Canon v1.1**.

Its purpose is to make every patch:

- traceable
- readable in terminal
- auditable after failure
- attributable to a request, feature block, or hotfix
- easier to debug under drift, Groundhog Day loops, and forensic recovery

This canon applies to:

- PowerShell patch files
- touched code files
- patch output shown in terminal
- LLM-to-LLM coding handoffs
- patch archives and backups

Version `v1.1` adds an explicit **encoding failure founder case**, upgrades archive routing rules for broken patches, and formalizes encoding checks, restore hints, and post-write compile invalidation.

---

## 1. Core principle

A patch is not only a write action.

A patch is also:

- a trace artifact
- a diagnostic artifact
- an execution report
- a recoverability artifact

No patch is considered production-worthy unless its execution is understandable by a human operator reading terminal output under stress or fatigue.

---

## 2. Semantic versioning canon

### 2.1 Format

`MAJOR.BLOCK.FEATURE + hotfix letter`

Example:

- `0.6.0a`

### 2.2 Meaning

- `MAJOR` = large project stage
- `BLOCK` = functional block
- `FEATURE` = specific feature inside that block
- `letter` = hotfix / corrective iteration for that feature

### 2.3 Rule

Every patch must target one explicit version.

That target version must appear in:

- patch filename
- touched-file metadata
- runtime patch output
- any related patchlog or manifest

---

## 3. Patch filename canon

### 3.1 Required format

`patch_<project>_<version>_<purpose>.ps1`

### 3.2 Examples

- `patch_ccos_controller_0.6.0a_operator_memory_strip.ps1`
- `patch_bhyome_0.4.2b_button_color_hotfix.ps1`

### 3.3 Rule

Patch filenames must be descriptive enough that an operator can identify:

- project
- target version
- main purpose

without opening the file.

---

## 4. Patchlog trace ID canon

### 4.1 Required format

`<PROJECT>_<VERSION>_ID_<NNNN>_<SHORT_DESC>`

### 4.2 Examples

- `CCOS_060a_ID_3482_operator_memory_strip`
- `CCOS_060a_ID_3483_mojibake_python_header`
- `BB_060a_ID_3484_slider_menu_x`

### 4.3 Rule

Every meaningful change inside a patch must map to a trace ID.

This allows:

- request → patch → file → failure mapping
- forensic recovery
- clearer bug attribution
- smarter hotfix follow-up

---

## 5. Change type tags

Every touched file and every meaningful patch change must be categorized with a change type tag.

### 5.1 Minimum allowed tags

- `FEATURE`
- `BUG_FIX`
- `HOTFIX`
- `REFACTOR`
- `REMOVAL`
- `UX_CLARITY`
- `TRACEABILITY`
- `INFRA`
- `ENCODING`

### 5.2 Rule

Tags must describe implementation intent.

They must not alter runtime logic by themselves.

---

## 6. Touched-file metadata canon

Every touched file must include visible metadata comments near the top of the file.

### 6.1 Minimum required metadata

- file version
- last patch label
- change type
- feature / change ID where appropriate

### 6.2 Example (Python)

```python
# CCOS FILE VERSION: v0.6.0a
# CCOS LAST PATCH: operator_memory_strip
# CCOS CHANGE TYPE: FEATURE
# CCOS FEATURE ID: CCOS_060a_ID_3482
```

### 6.3 Example (PowerShell)

```powershell
# CCOS FILE VERSION: v0.6.0a
# CCOS LAST PATCH: operator_memory_strip
# CCOS CHANGE TYPE: FEATURE
# CCOS FEATURE ID: CCOS_060a_ID_3482
```

### 6.4 Rule

Metadata must remain readable and stable.

It exists for auditability, not decoration.

---

## 7. Patch execution UX canon

### 7.1 Status tokens

Patch runtime output must use semantic status tokens only:

- `[OK]`
- `[WARN]`
- `[ERROR]`

### 7.2 Color rules

Use only a minimal semantic palette:

- green = `[OK]`
- yellow = `[WARN]`
- red = `[ERROR]`

Optional:
- neutral/white/cyan for section headers

No rainbow color system.

### 7.3 Visual rhythm

Patch runtime should use stable sections such as:

- `=== PATCH HEADER ===`
- `=== PRECHECK ===`
- `=== CHANGESET SUMMARY ===`
- `=== WRITE PHASE ===`
- `=== VERIFY ===`
- `=== RESULT ===`
- `=== SMOKE TEST CHECKLIST ===`

Reason: reading terminal output is tiring, so visual grouping is mandatory.

---

## 8. Patch header canon

Every patch must begin with a small execution header.

### 8.1 Minimum fields

- project
- patch filename
- target version
- root path
- mode (`DRY_RUN` or `APPLY`)
- trace mode status

### 8.2 Example

```text
=== PATCH HEADER ===
PROJECT: CCOS
PATCH: patch_ccos_controller_0.6.0a_operator_memory_strip.ps1
TARGET VERSION: 0.6.0a
ROOT: K:\COLLAPSE_OS\ccos_controller\ccos_controller
MODE: APPLY
TRACE MODE: ON
```

---

## 9. Dry-run canon

### 9.1 Rule

Every non-trivial patch should support `DRY_RUN` or at minimum a preflight-only execution path.

### 9.2 Dry-run must:

- detect files
- validate anchors / selectors
- validate write scope
- report intended changes
- write nothing

### 9.3 Output example

```text
[OK] PRECHECK: all files found
[OK] ANCHOR SCAN: 7/7
[OK] WRITE PLAN: 3 files would change
[WARN] DRY RUN ACTIVE: no files written
```

---

## 10. No-write-on-preflight-fail canon

### 10.1 Rule

If preflight fails, **no files may be written**.

This includes failures in:

- file discovery
- anchor scan
- parser validation
- scope validation
- dangerous target detection

### 10.2 Required failure wording

```text
[ERROR] PRECHECK FAILED
[ERROR] No files written
```

This must be explicit.

---

## 11. Changeset summary canon

Before any write, every patch must print a concise changeset summary.

### 11.1 Example

```text
=== CHANGESET SUMMARY ===
[PLAN] CCOS_060a_ID_3482 FEATURE operator_memory_strip
[PLAN] CCOS_060a_ID_3483 ENCODING mojibake_python_header
[PLAN] CCOS_060a_ID_3484 BUG_FIX apply_prompt_alias
```

### 11.2 Purpose

This gives the operator one final semantic view of what the patch intends to do.

---

## 12. Anchor map report canon

If a patch relies on anchors, selectors, or replace targets, the patch must report them.

### 12.1 Example

```text
[OK] ANCHOR SCAN: 6/6
```

or

```text
[ERROR] ANCHOR SCAN: 5/6
[ERROR] Missing anchor: session/process overview helpers
```

### 12.2 Rule

Anchor failures must name the missing anchor.

Generic “patch failed” is not acceptable.

---

## 13. Encoding check canon

### 13.1 Rule

Every patch touching source code should run an encoding sanity check.

Minimum concerns:

- UTF-8 vs non-UTF-8
- BOM presence
- mojibake risk
- unexpected literalized marker bytes at file start

### 13.2 Example

```text
[OK] ENCODING CHECK: UTF-8 without BOM
[WARN] ENCODING CHECK: BOM detected
[ERROR] ENCODING CHECK: mojibake literalized before Python header
```

### 13.3 Purpose

This directly prevents silent breakage such as mojibake before Python headers.

---

## 14. Written file manifest canon

After the write phase, patch runtime must report exactly what was written.

### 14.1 Example

```text
=== FILE WRITE REPORT ===
[OK] main.py written
[WARN] run.ccos.ps1 untouched
[WARN] ccos_terminal_v0_1.ps1 untouched
```

### 14.2 Rule

The operator must not need to guess which files changed.

---

## 15. Post-write verify canon

### 15.1 Rule

Verification must exist at two levels:

- file level
- feature level

### 15.2 File-level verification examples

- file exists
- version marker present
- expected line written
- parser / compile passes

### 15.3 Feature-level verification examples

```text
[OK] VERIFY CCOS_060a_ID_3482 operator memory header present
[OK] VERIFY CCOS_060a_ID_3483 recap labels present
[ERROR] VERIFY CCOS_060a_ID_3484 apply prompt alias missing
```

### 15.4 Rule

Verification should identify **which feature failed**, not only which file failed.

---

## 16. Failure report canon

When a patch fails, runtime must print a failure block.

### 16.1 Minimum fields

- file
- phase
- feature/change ID
- error detail
- whether files were written
- whether backups were written
- recommended next action

### 16.2 Example

```text
=== FAILURE REPORT ===
STATUS: ERROR
PATCH ID: CCOS_060a_ID_3484
FILE: main.py
PHASE: post-write verify
DETAIL: expected alias prompt not found
FILES WRITTEN: YES
BACKUPS WRITTEN: YES
NEXT ACTION: restore backup or run targeted hotfix
```

---

## 17. Restore hint canon

If a patch fails after writing files, it must print a restore hint.

### 17.1 Example

```text
[WARN] RESTORE AVAILABLE:
K:\COLLAPSE_OS\ccos_controller\_old\backups\2026-04-07_12-12-49_main.py
```

---

## 18. Patch archive canon

### 18.1 Required folders

```text
_old\\backups
_old\\patches
_old\\patches_broken
```

### 18.2 Rules

- successful/applied patch copies → `_old\\patches`
- broken/non-running patch copies → `_old\\patches_broken`
- touched-file backups → `_old\\backups`

### 18.3 Important invalidation rule

If a patch writes files but fails post-write compile or verify, it must be treated as:

- write occurred
- backup exists
- patch invalid
- archive route = `_old\\patches_broken`

It must not be considered an applied patch.

---

## 19. Patch manifest canon

Each patch should produce a machine-readable manifest when practical.

### 19.1 Minimum suggested fields

- patch filename
- target version
- root path
- changed files
- patchlog IDs
- execution status
- backup paths
- failure details
- timestamp

### 19.2 Purpose

Supports:

- audit
- forensic recovery
- comparison across patch attempts
- easier debugging after drift

---

## 20. Interactive mode canon

Every patch should declare whether it is:

- `INTERACTIVE`
- `NON_INTERACTIVE`

This prevents confusion when PowerShell appears to “hang” but is actually waiting for input.

---

## 21. Elapsed time canon

Patch runtime should report total elapsed time.

Example:

```text
[OK] ELAPSED: 4.2s
```

This helps identify hangs and suspicious slowdowns.

---

## 22. Smoke test checklist canon

Every patch must end with a compact smoke test checklist.

### 22.1 Example

```text
=== SMOKE TEST CHECKLIST ===
[ ] Run controller
[ ] Verify version header
[ ] Test SAVE_AS_PLAN
[ ] Test POSTPONE
[ ] Test cancel pre-call
```

### 22.2 Rule

Smoke tests must be:

- short
- exact
- directly actionable

---

## 23. Request/feature linkage canon

Every patch should be attributable to a request or feature block.

### 23.1 Minimum linkage fields

- request label
- feature ID
- change type
- target version

This lets the operator compare request vs implementation vs failure.

---

## 24. Handoff canon for coding LLMs

Before handing work to another coding LLM, the upstream LLM must require:

- patch trace IDs
- touched-file metadata
- version markers
- change type tags
- runtime `[OK]/[WARN]/[ERROR]` output
- failure report block
- compile/verify step
- smoke checklist

No exception.

---

## 25. Integration with other CCOS protocols

This canon works together with:

- Groundhog Day Protocol
- Forensic Analysis Sub-Protocol

### Combined purpose

- drift detection
- patch auditability
- faster bug attribution
- clearer recovery after partial failure
- reduced “red error with no context” situations

---

## 26. Founder case: encoding corruption before Python header

### 26.1 Canonical founder case ID

`CCOS_060a_ID_3483_mojibake_python_header`

### 26.2 Observed symptom

A patch wrote `main.py`, but post-write compile failed because the start of the file became:

```text
ï»¿from __future__ import annotations
```

instead of:

```python
from __future__ import annotations
```

### 26.3 Correct classification

This class of incident must be treated as:

- file written = yes
- backup written = yes
- patch valid = no
- restore path available = yes
- archive route = `_old\\patches_broken`

### 26.4 Root cause category

- `BUG_FIX`
- `TRACEABILITY`
- `ENCODING`

### 26.5 Mandatory response

All code-touching patches must therefore include:

- encoding sanity checks
- post-write compile verification
- explicit failure report blocks
- restore hints
- broken-patch archive routing

---

## 27. Enforcement note

This is not optional style guidance.

For CCOS, patch traceability and execution UX are part of the operating protocol.

A patch that writes but is not readable, attributable, diagnosable, and recoverable is incomplete.
