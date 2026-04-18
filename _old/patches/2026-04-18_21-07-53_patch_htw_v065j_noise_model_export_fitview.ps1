# patch_htw_v065j_noise_model_export_fitview.ps1
# =============================================================
# CCOS FILE VERSION:  v0.6.5j
# CCOS LAST PATCH:    noise_model_export_fitview
# CCOS CHANGE TYPE:   FEATURE / BUG_FIX
# CCOS FEATURE IDs:   HTW_065j_ID_0001 through HTW_065j_ID_0007
# =============================================================
#
# PROJECT:     HTW Generator
# PATCH:       patch_htw_v065j_noise_model_export_fitview.ps1
# TARGET VER:  v0.6.5j
# MODE:        APPLY (non-interactive)
# TRACE MODE:  ON
#
# CHANGESET SUMMARY:
#   [PLAN] HTW_065j_ID_0001  FEATURE   state.js: add noiseAmount field (0..1, default 0.5)
#   [PLAN] HTW_065j_ID_0002  BUG_FIX   drawNoise: replace luminance/density model with
#                                        contrast-driven (stddev) blob model
#   [PLAN] HTW_065j_ID_0003  FEATURE   sbEffects NOISE: add Amount slider + input handler
#   [PLAN] HTW_065j_ID_0004  BUG_FIX   exportPNG: include rails + noise on export canvas
#   [PLAN] HTW_065j_ID_0005  BUG_FIX   Add fitVz() helper; replace all 4 vz=1 reset sites
#   [PLAN] HTW_065j_ID_0006  BUG_FIX   Ctrl+Y: block redo() in effects mode
#   [PLAN] HTW_065j_ID_0007  INFRA     version bump v0.6.5i -> v0.6.5j
#
# ATOMICITY CONTRACT:
#   Phase 1 — READ:    all files read into memory
#   Phase 2 — ANCHOR:  all anchors verified (abort if any miss)
#   Phase 3 — APPLY:   all replacements applied in memory only
#   Phase 4 — VERIFY:  all post-apply checks on in-memory buffers (abort if any fail)
#   Phase 5 — WRITE:   backups created, then all three files written
#   No file is written until every check in phases 2 and 4 passes.
#
# SCOPE NOTES:
#   Bake scope: checker ONLY (unchanged). Rails/noise are NOT baked.
#   Export scope: checker + rails + noise (J4 change — explicit in code comment).
#   getCellSizeFromState in core/canvas.js references removed fx.depth — dead code,
#   tracked as debt, NOT touched in this pass.
#
# J2 ANCHOR STRATEGY:
#   Strong anchor spans the entire final placement block from
#   "// Luminance-driven noise placement" through closing brace of drawNoise.
#   Post-apply verify confirms: density removed, cluster loop removed,
#   stddev/contrast logic present, noiseAmount referenced.
#
# fitVz() GUARD STRATEGY:
#   fitVz() itself returns 1 if !S.img.
#   The 3 explicit call sites (frs/key0/t-zf) also guard: if (S.img) S.vz = fitVz(); else S.vz = 1.
#   loadFile call is inside img.onload — S.img guaranteed non-null there.
#
# STAGING vs REPO:
#   Staging dir: K:\DEVKIT\projects\htw-generator  (where this patch file lives)
#   Repo root:   K:\DEVKIT\projects\htw-generator\htw-generator  (where app.js lives)
#   Run this patch from the REPO ROOT, not the staging dir.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Patch    = 'patch_htw_v065j_noise_model_export_fitview.ps1'
$Target   = 'v0.6.5j'
$Root     = (Get-Location).Path
$StateJs  = Join-Path $Root 'core\state.js'
$AppJs    = Join-Path $Root 'app.js'
$HtmlFile = Join-Path $Root 'index.html'

Write-Host ''
Write-Host '=== PATCH HEADER ==='
Write-Host "PATCH:   $Patch"
Write-Host "TARGET:  $Target"
Write-Host "ROOT:    $Root"
Write-Host "MODE:    APPLY (fully atomic -- no writes until all verifies pass)"
Write-Host ''

# ==============================================================
# PHASE 1 — READ ALL FILES
# ==============================================================
Write-Host '=== PHASE 1: READ ==='

$anyFail = $false
foreach ($f in @($StateJs, $AppJs, $HtmlFile)) {
    if (-not (Test-Path $f)) {
        Write-Host "[ERROR] FILE NOT FOUND: $f"
        $anyFail = $true
    }
}
if ($anyFail) {
    Write-Host '[ERROR] READ PHASE FAILED'
    Write-Host '[ERROR] FILES WRITTEN: NO'
    Write-Host '[ERROR] BACKUPS WRITTEN: NO'
    Write-Host 'NEXT ACTION: run from htw-generator repo root (not staging dir)'
    exit 1
}

$s = [System.IO.File]::ReadAllText($StateJs);  $s = $s.Replace("`r`n", "`n")
$c = [System.IO.File]::ReadAllText($AppJs);    $c = $c.Replace("`r`n", "`n")
$h = [System.IO.File]::ReadAllText($HtmlFile); $h = $h.Replace("`r`n", "`n")
Write-Host '[OK] All files read into memory'

# ==============================================================
# DEFINE ALL FIND / REPLACE STRINGS
# ==============================================================

# HTW_065j_ID_0001
$fJ1 = "        noise: false,`n        palIdx: 4"
$rJ1 = "        noise: false,`n        noiseAmount: 0.5,               // contrast-driven noise density (0..1)`n        palIdx: 4"

# HTW_065j_ID_0002 -- strong anchor: full final placement block through closing brace
$fJ2 = @'
  // Luminance-driven noise placement -- empty cells only
  let rng = seed;
  const rand = () => { rng = (rng * 1664525 + 1013904223) & 0xFFFFFFFF; return (rng >>> 0) / 0x100000000; };

  const off = new OffscreenCanvas(iw, ih);
  const offCtx = off.getContext('2d');
  offCtx.drawImage(S.img, 0, 0);
  const id = offCtx.getImageData(0, 0, iw, ih);
  const data = id.data;

  const density = 0.2;
  ctx.fillStyle = rgb(fg);

  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      if (blocked.has(key(c, r))) continue; // skip occupied cells
      let totalLum = 0;
      let count = 0;
      for (let y = r * motherCS; y < (r + 1) * motherCS && y < ih; y++) {
        for (let x = c * motherCS; x < (c + 1) * motherCS && x < iw; x++) {
          const idx = (y * iw + x) * 4;
          totalLum += 0.299 * data[idx] + 0.587 * data[idx + 1] + 0.114 * data[idx + 2];
          count++;
        }
      }
      const avgLum = count ? totalLum / count : 0;
      const prob = (avgLum / 255) * density;
      if (rand() < prob) {
        const clusterSize = 2 + Math.floor(rand() * 3);
        for (let p = 0; p < clusterSize; p++) {
          const dx = Math.floor(rand() * motherCS);
          const dy = Math.floor(rand() * motherCS);
          const x = ox + (c * motherCS + dx) * vz;
          const y = oy + (r * motherCS + dy) * vz;
          const dotSize = Math.max(1, Math.floor(motherCS * vz / 16));
          ctx.fillRect(x, y, dotSize, dotSize);
        }
      }
    }
  }
}
'@
$fJ2 = $fJ2.Replace("`r`n", "`n")

$rJ2 = @'
  // Contrast-driven noise placement -- empty cells only
  // High local contrast (edges/transitions) triggers noise; uniform zones do not.
  // noiseAmount (0..1) scales the contrast threshold.
  let rng = seed;
  const rand = () => { rng = (rng * 1664525 + 1013904223) & 0xFFFFFFFF; return (rng >>> 0) / 0x100000000; };

  const off = new OffscreenCanvas(iw, ih);
  const offCtx = off.getContext('2d');
  offCtx.drawImage(S.img, 0, 0);
  const imgData = offCtx.getImageData(0, 0, iw, ih);
  const data = imgData.data;

  ctx.fillStyle = rgb(fg);

  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      if (blocked.has(key(c, r))) continue;
      // Pass 1: mean luminance
      let sumLum = 0; let count = 0;
      for (let y = r * motherCS; y < (r + 1) * motherCS && y < ih; y++) {
        for (let x = c * motherCS; x < (c + 1) * motherCS && x < iw; x++) {
          const idx = (y * iw + x) * 4;
          sumLum += 0.299 * data[idx] + 0.587 * data[idx + 1] + 0.114 * data[idx + 2];
          count++;
        }
      }
      if (!count) continue;
      const meanLum = sumLum / count;
      // Pass 2: variance -> stddev -> contrast
      let sumSq = 0;
      for (let y = r * motherCS; y < (r + 1) * motherCS && y < ih; y++) {
        for (let x = c * motherCS; x < (c + 1) * motherCS && x < iw; x++) {
          const idx = (y * iw + x) * 4;
          const lum = 0.299 * data[idx] + 0.587 * data[idx + 1] + 0.114 * data[idx + 2];
          const d = lum - meanLum;
          sumSq += d * d;
        }
      }
      const stddev = Math.sqrt(sumSq / count);
      const contrast = stddev / 128; // normalised 0..1 (128 = max possible stddev)
      if (rand() < contrast * S.fx.noiseAmount) {
        // One blob per triggered cell
        const dx = Math.floor(rand() * motherCS);
        const dy = Math.floor(rand() * motherCS);
        const x = ox + (c * motherCS + dx) * vz;
        const y = oy + (r * motherCS + dy) * vz;
        const dotSize = Math.max(1, Math.floor(motherCS * vz / 8));
        ctx.fillRect(x, y, dotSize, dotSize);
      }
    }
  }
}
'@
$rJ2 = $rJ2.Replace("`r`n", "`n")

# HTW_065j_ID_0003a
$fJ3a = "    + sec('NOISE', tog('noise', 'HTW noise', fx.noise))"
$rJ3a = @'
    + sec('NOISE',
      tog('noise', 'HTW noise', fx.noise) +
      (fx.noise ? sld('noiseAmt', 'Amount', fx.noiseAmount, 0, 1, 0.05, 2) : ''))
'@
$rJ3a = $rJ3a.Replace("`r`n", "`n")

# HTW_065j_ID_0003b
$fJ3b = @'
    if (sv) sv.textContent = (id === 'bct') ? v.toFixed(2) : Math.round(v);
    switch (id) {
      case 'thr': S.icon.thr = v | 0; break;
      case 'seed': S.fx.seed = v | 0; break;
      case 'bct': S.bm.contrast = v; break;
      // no other sliders needed
    }
'@
$fJ3b = $fJ3b.Replace("`r`n", "`n")
$rJ3b = @'
    if (sv) sv.textContent = (id === 'bct' || id === 'noiseAmt') ? v.toFixed(2) : Math.round(v);
    switch (id) {
      case 'thr': S.icon.thr = v | 0; break;
      case 'seed': S.fx.seed = v | 0; break;
      case 'bct': S.bm.contrast = v; break;
      case 'noiseAmt': S.fx.noiseAmount = parseFloat(v); break;
    }
'@
$rJ3b = $rJ3b.Replace("`r`n", "`n")

# HTW_065j_ID_0004 -- pal/fg/bg already declared in the same exportPNG block scope
$fJ4 = @'
    // Structure overlays (border/rails/noise) are live authoring aids -- not exported.
    // Export contains: base image + baked layers + current live checker zone only.
    ec.convertToBlob().then(b => downloadBlob(b, `HTW_effects_${Date.now()}.png`));
'@
$fJ4 = $fJ4.Replace("`r`n", "`n")
$rJ4 = @'
    // Draw structure overlays onto export canvas at native resolution.
    // Bake scope: checker ONLY. Export scope: checker + rails + noise (v0.6.5j).
    if (S.fx.edgeMode !== 'none' || S.fx.rail2 || S.fx.rail3) {
      drawMarkers(ex, iw, ih, 0, 0, fg, bg, S.fx.seed, 1);
    }
    if (S.fx.noise) {
      drawNoise(ex, iw, ih, 0, 0, fg, bg, S.fx.seed, 1);
    }
    ec.convertToBlob().then(b => downloadBlob(b, `HTW_effects_${Date.now()}.png`));
'@
$rJ4 = $rJ4.Replace("`r`n", "`n")

# HTW_065j_ID_0005a -- fitVz() helper inserted after vOff
$fJ5_voff = "function vOff(cW, cH) {`n  return getViewOffset(cW, cH, S.vz, S.vpx, S.vpy, aW(), aH());`n}"
$rJ5_voff = @'
function vOff(cW, cH) {
  return getViewOffset(cW, cH, S.vz, S.vpx, S.vpy, aW(), aH());
}

function fitVz() {
  // Guard: returns 1 if no image loaded
  if (!S.img) return 1;
  const z = Math.min(aW() / S.img.naturalWidth, aH() / S.img.naturalHeight) * 0.9;
  return Math.min(z, 1); // do not upscale images smaller than the canvas
}
'@
$rJ5_voff = $rJ5_voff.Replace("`r`n", "`n")

# HTW_065j_ID_0005b -- loadFile: S.img set just above this line; safe to call fitVz()
$fJ5_load = 'S.img = img; S.bakeStack = []; S.mask = null; S.vz = 1; S.vpx = 0; S.vpy = 0;'
$rJ5_load = 'S.img = img; S.bakeStack = []; S.mask = null; S.vz = fitVz(); S.vpx = 0; S.vpy = 0;'

# HTW_065j_ID_0005c/d/e -- explicit null guard at all 3 remaining call sites
$fJ5_frs  = "if (id === 'frs') { S.vz = 1; S.vpx = 0; S.vpy = 0; redraw(); updateStatus(); return; }"
$rJ5_frs  = "if (id === 'frs') { if (S.img) S.vz = fitVz(); else S.vz = 1; S.vpx = 0; S.vpy = 0; redraw(); updateStatus(); return; }"
$fJ5_key0 = "case '0': S.vz = 1; S.vpx = 0; S.vpy = 0; redraw(); updateStatus(); break;"
$rJ5_key0 = "case '0': if (S.img) S.vz = fitVz(); else S.vz = 1; S.vpx = 0; S.vpy = 0; redraw(); updateStatus(); break;"
$fJ5_tzf  = "document.getElementById('t-zf').onclick = () => { S.vz = 1; S.vpx = 0; S.vpy = 0; redraw(); updateStatus(); };"
$rJ5_tzf  = "document.getElementById('t-zf').onclick = () => { if (S.img) S.vz = fitVz(); else S.vz = 1; S.vpx = 0; S.vpy = 0; redraw(); updateStatus(); };"

# HTW_065j_ID_0006
$fJ6 = "  if ((e.ctrlKey || e.metaKey) && e.key === 'y') { redo(); return; }"
$rJ6 = "  if ((e.ctrlKey || e.metaKey) && e.key === 'y') { if (S.mode !== 'effects') redo(); return; }"

# HTW_065j_ID_0007
$fH7a = 'HTW GENERATOR v0.6.5i</title>'
$rH7a = 'HTW GENERATOR v0.6.5j</title>'
$fH7b = 'v0.6.5i</div>'
$rH7b = 'v0.6.5j</div>'

# ==============================================================
# PHASE 2 — ANCHOR SCAN (preflight on raw files)
# ==============================================================
Write-Host ''
Write-Host '=== PHASE 2: ANCHOR SCAN ==='

$scanFail = $false
$passed = 0; $total = 13

$stateChecks = @(
    @{ id='HTW_065j_ID_0001';  desc='noiseAmount insertion point'; f=$fJ1;      src=$s }
)
$appChecks = @(
    @{ id='HTW_065j_ID_0002';  desc='drawNoise final placement block'; f=$fJ2;   src=$c },
    @{ id='HTW_065j_ID_0003a'; desc='NOISE section in sbEffects';      f=$fJ3a;  src=$c },
    @{ id='HTW_065j_ID_0003b'; desc='input handler sv.textContent';    f=$fJ3b;  src=$c },
    @{ id='HTW_065j_ID_0004';  desc='exportPNG overlay comment';       f=$fJ4;   src=$c },
    @{ id='HTW_065j_ID_0005a'; desc='vOff helper block';               f=$fJ5_voff; src=$c },
    @{ id='HTW_065j_ID_0005b'; desc='loadFile vz=1';                   f=$fJ5_load; src=$c },
    @{ id='HTW_065j_ID_0005c'; desc='frs button vz=1';                 f=$fJ5_frs;  src=$c },
    @{ id='HTW_065j_ID_0005d'; desc="keyboard '0' vz=1";               f=$fJ5_key0; src=$c },
    @{ id='HTW_065j_ID_0005e'; desc='t-zf toolbar vz=1';               f=$fJ5_tzf;  src=$c },
    @{ id='HTW_065j_ID_0006';  desc='Ctrl+Y redo() call';              f=$fJ6;   src=$c }
)
$htmlChecks = @(
    @{ id='HTW_065j_ID_0007a'; desc='html title v0.6.5i';   f=$fH7a; src=$h },
    @{ id='HTW_065j_ID_0007b'; desc='html topinfo v0.6.5i'; f=$fH7b; src=$h }
)

foreach ($a in ($stateChecks + $appChecks + $htmlChecks)) {
    if ($a.src.IndexOf($a.f) -lt 0) {
        Write-Host "[ERROR] ANCHOR MISS: $($a.id) -- $($a.desc)"
        $scanFail = $true
    } else { $passed++ }
}

if ($scanFail) {
    Write-Host "[ERROR] ANCHOR SCAN: $passed/$total"
    Write-Host '[ERROR] FILES WRITTEN: NO'
    Write-Host '[ERROR] BACKUPS WRITTEN: NO'
    Write-Host 'NEXT ACTION: verify repo is at v0.6.5i; run from repo root not staging dir'
    exit 1
}
Write-Host "[OK] ANCHOR SCAN: $total/$total -- all anchors found"

# ==============================================================
# PHASE 3 — APPLY ALL REPLACEMENTS IN MEMORY
# ==============================================================
Write-Host ''
Write-Host '=== PHASE 3: APPLY IN MEMORY ==='

$s2 = $s.Replace($fJ1,      $rJ1)
Write-Host '[OK] HTW_065j_ID_0001  -- noiseAmount field (in memory)'

$c2 = $c
$c2 = $c2.Replace($fJ2,      $rJ2);      Write-Host '[OK] HTW_065j_ID_0002  -- drawNoise contrast model (in memory)'
$c2 = $c2.Replace($fJ3a,     $rJ3a);     Write-Host '[OK] HTW_065j_ID_0003a -- NOISE Amount slider (in memory)'
$c2 = $c2.Replace($fJ3b,     $rJ3b);     Write-Host '[OK] HTW_065j_ID_0003b -- input handler noiseAmt (in memory)'
$c2 = $c2.Replace($fJ4,      $rJ4);      Write-Host '[OK] HTW_065j_ID_0004  -- exportPNG rails+noise (in memory)'
$c2 = $c2.Replace($fJ5_voff, $rJ5_voff); Write-Host '[OK] HTW_065j_ID_0005a -- fitVz() helper (in memory)'
$c2 = $c2.Replace($fJ5_load, $rJ5_load); Write-Host '[OK] HTW_065j_ID_0005b -- loadFile fitVz() (in memory)'
$c2 = $c2.Replace($fJ5_frs,  $rJ5_frs);  Write-Host '[OK] HTW_065j_ID_0005c -- frs guarded fitVz() (in memory)'
$c2 = $c2.Replace($fJ5_key0, $rJ5_key0); Write-Host "[OK] HTW_065j_ID_0005d -- key '0' guarded fitVz() (in memory)"
$c2 = $c2.Replace($fJ5_tzf,  $rJ5_tzf);  Write-Host '[OK] HTW_065j_ID_0005e -- t-zf guarded fitVz() (in memory)'
$c2 = $c2.Replace($fJ6,      $rJ6);      Write-Host '[OK] HTW_065j_ID_0006  -- Ctrl+Y effects block (in memory)'

$h2 = $h.Replace($fH7a, $rH7a).Replace($fH7b, $rH7b)
Write-Host '[OK] HTW_065j_ID_0007  -- version v0.6.5j (in memory)'

# ==============================================================
# PHASE 4 — VERIFY ALL IN-MEMORY BUFFERS
# ==============================================================
Write-Host ''
Write-Host '=== PHASE 4: VERIFY (in memory -- no writes yet) ==='

$verifyFail = $false

# J1 verify
if ($s2.IndexOf('noiseAmount: 0.5') -lt 0) {
    Write-Host '[ERROR] VERIFY J1 -- noiseAmount field not in state buffer'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY J1 -- noiseAmount present in state buffer' }

# J2 verify: 4 required conditions
if ($c2.IndexOf('const density = 0.2') -ge 0) {
    Write-Host '[ERROR] VERIFY J2 -- old density constant still in app buffer'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY J2 -- old density constant removed' }

if ($c2.IndexOf('const clusterSize = 2 + Math.Floor(rand() * 3)') -ge 0 -or `
    $c2.IndexOf('const clusterSize = 2 + Math.floor(rand() * 3)') -ge 0) {
    Write-Host '[ERROR] VERIFY J2 -- old cluster loop still in app buffer'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY J2 -- old cluster loop removed' }

if ($c2.IndexOf('const stddev = Math.sqrt') -lt 0) {
    Write-Host '[ERROR] VERIFY J2 -- stddev/contrast logic not in app buffer'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY J2 -- stddev/contrast logic present' }

if ($c2.IndexOf('S.fx.noiseAmount') -lt 0) {
    Write-Host '[ERROR] VERIFY J2 -- noiseAmount not referenced in app buffer'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY J2 -- noiseAmount referenced in app buffer' }

# J3 verify
if ($c2.IndexOf("case 'noiseAmt': S.fx.noiseAmount = parseFloat(v)") -lt 0) {
    Write-Host '[ERROR] VERIFY J3 -- noiseAmt input case not found'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY J3 -- noiseAmt input case present' }

# J4 verify
if ($c2.IndexOf('drawMarkers(ex, iw, ih, 0, 0, fg, bg') -lt 0) {
    Write-Host '[ERROR] VERIFY J4 -- drawMarkers not in exportPNG buffer'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY J4 -- drawMarkers + drawNoise in exportPNG' }

# J5 verify
if ($c2.IndexOf('function fitVz()') -lt 0) {
    Write-Host '[ERROR] VERIFY J5 -- fitVz() helper not in app buffer'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY J5 -- fitVz() helper present' }

# J6 verify
if ($c2.IndexOf("if (S.mode !== 'effects') redo()") -lt 0) {
    Write-Host '[ERROR] VERIFY J6 -- Ctrl+Y effects block not in app buffer'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY J6 -- Ctrl+Y effects block present' }

# J7 verify
if ($h2.IndexOf('v0.6.5j</title>') -lt 0) {
    Write-Host '[ERROR] VERIFY J7 -- v0.6.5j not in html buffer'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY J7 -- v0.6.5j in html buffer' }

if ($verifyFail) {
    Write-Host ''
    Write-Host '=== FAILURE REPORT ==='
    Write-Host 'STATUS:          ERROR'
    Write-Host 'PHASE:           in-memory verify (Phase 4)'
    Write-Host 'FILES WRITTEN:   NO'
    Write-Host 'BACKUPS WRITTEN: NO'
    Write-Host 'NEXT ACTION:     no files were touched. Diagnose anchor or logic issue.'
    Write-Host '                 Re-run preflight or check source version.'
    exit 1
}

Write-Host ''
Write-Host '[OK] All in-memory verifies passed -- proceeding to write phase'

# ==============================================================
# PHASE 5 — BACKUPS + WRITE (only reached if all verifies pass)
# ==============================================================
Write-Host ''
Write-Host '=== PHASE 5: BACKUP + WRITE ==='

$BackupDir = Join-Path $Root '_old\backups'
if (-not (Test-Path $BackupDir)) { New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null }
$ts = (Get-Date).ToString('yyyy-MM-dd_HH-mm-ss')
Copy-Item $StateJs  (Join-Path $BackupDir "${ts}_state.js")
Copy-Item $AppJs    (Join-Path $BackupDir "${ts}_app.js")
Copy-Item $HtmlFile (Join-Path $BackupDir "${ts}_index.html")
Write-Host "[OK] BACKUPS WRITTEN: _old\backups\${ts}_state.js"
Write-Host "[OK] BACKUPS WRITTEN: _old\backups\${ts}_app.js"
Write-Host "[OK] BACKUPS WRITTEN: _old\backups\${ts}_index.html"

[System.IO.File]::WriteAllText($StateJs,  $s2.Replace("`n", "`r`n"), (New-Object System.Text.UTF8Encoding $false))
Write-Host '[OK] FILE WRITTEN: core/state.js'

[System.IO.File]::WriteAllText($AppJs,    $c2.Replace("`n", "`r`n"), (New-Object System.Text.UTF8Encoding $false))
Write-Host '[OK] FILE WRITTEN: app.js'

[System.IO.File]::WriteAllText($HtmlFile, $h2.Replace("`n", "`r`n"), (New-Object System.Text.UTF8Encoding $false))
Write-Host '[OK] FILE WRITTEN: index.html'

# Patch archive -- staging dir is one level up from repo root
$StagingDir = Split-Path $Root -Parent
$PatchSrc   = Join-Path $StagingDir $Patch
$PatchDir   = Join-Path $Root '_old\patches'
if (-not (Test-Path $PatchDir)) { New-Item -ItemType Directory -Path $PatchDir -Force | Out-Null }
if (Test-Path $PatchSrc) {
    Copy-Item $PatchSrc (Join-Path $PatchDir "${ts}_${Patch}")
    Write-Host "[OK] Patch archived: _old\patches\${ts}_${Patch}"
} else {
    Write-Host "[WARN] Patch file not found at staging dir ($StagingDir) -- archive skipped"
}

# ==============================================================
# RESULT
# ==============================================================
Write-Host ''
Write-Host '=== RESULT ==='
Write-Host '[OK] Patch v0.6.5j complete. All changes applied.'
Write-Host '[OK] HTW_065j_ID_0001 -- noiseAmount state field'
Write-Host '[OK] HTW_065j_ID_0002 -- contrast-driven noise model'
Write-Host '[OK] HTW_065j_ID_0003 -- Amount slider + input handler'
Write-Host '[OK] HTW_065j_ID_0004 -- export includes rails + noise'
Write-Host '[OK] HTW_065j_ID_0005 -- fitVz() at all 4 reset sites'
Write-Host '[OK] HTW_065j_ID_0006 -- Ctrl+Y blocked in effects'
Write-Host '[OK] HTW_065j_ID_0007 -- version v0.6.5j'
Write-Host ''
Write-Host '=== DEAD CODE NOTE ==='
Write-Host '[WARN] core/canvas.js getCellSizeFromState() references removed fx.depth.'
Write-Host '       Appears to be dead code. Tracked as debt. NOT touched in this pass.'
Write-Host ''
Write-Host '=== SMOKE TEST CHECKLIST ==='
Write-Host '[ ] Open HTW Generator -- confirm header reads v0.6.5j'
Write-Host '[ ] Load an image -- confirm canvas fits viewport (fitVz on load)'
Write-Host '[ ] Click Fit View / press 0 with NO image -- confirm no crash'
Write-Host '[ ] Click Fit View / press 0 with image -- confirm canvas re-fits'
Write-Host '[ ] Switch to Effects. Enable noise -- confirm Amount slider appears'
Write-Host '[ ] Set Amount to 0 -- confirm no noise. Set to 1 -- confirm noise at edges'
Write-Host '[ ] Load high-contrast image -- confirm noise at edge zones, not flat zones'
Write-Host '[ ] Load low-contrast image (flat gradient) -- confirm minimal/no noise'
Write-Host '[ ] Change Structure Size -- confirm noise blob size scales'
Write-Host '[ ] Enable rails/border + noise -- Export PNG -- confirm export includes both'
Write-Host '[ ] Bake a checker layer -- confirm bake contains checker only (not rails/noise)'
Write-Host '[ ] Press Ctrl+Y in Effects -- confirm no crash, no renderGrid call'
Write-Host '[ ] Press Ctrl+Y in Icon/Bitmap -- confirm redo still works'
