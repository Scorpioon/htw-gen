# patch_htw_v065k_structure_coherence.ps1
# =============================================================
# CCOS FILE VERSION:  v0.6.5k
# CCOS LAST PATCH:    structure_coherence
# CCOS CHANGE TYPE:   BUG_FIX
# CCOS FEATURE IDs:   HTW_065k_ID_0001 / HTW_065k_ID_0002
# =============================================================
#
# PROJECT:     HTW Generator
# PATCH:       patch_htw_v065k_structure_coherence.ps1
# TARGET VER:  v0.6.5k
# MODE:        APPLY (fully atomic)
# TRACE MODE:  ON
#
# CHANGESET SUMMARY:
#   [PLAN] HTW_065k_ID_0001  BUG_FIX  drawNoise: structure-coherent blob model
#            - one procedural decision per structure cell (unchanged)
#            - contrast drives probability (unchanged)
#            - noiseAmount modulates frequency only (unchanged)
#            - blob size = floor(motherCS * vz / 3), min 2px
#              (was vz/8 scalar -- now directly structure-cell-derived)
#            - blob position spans full structure cell area in screen coords
#            - no dust/scatter, no cluster loop
#   [PLAN] HTW_065k_ID_0002  INFRA    version bump v0.6.5j -> v0.6.5k
#
# SCOPE:
#   ONLY the final placement block inside drawNoise() is touched.
#   Blocking sections (checker-mask, edgeMode/rail2/rail3, baked-layer)
#   are structurally preserved and NOT touched.
#   Export flow unchanged: drawMarkers + drawNoise on export canvas at vz=1.
#   Bake scope unchanged: checker only.
#   No sidebar, no undo/redo, no masks, no icon/bitmap, no state.js.
#
# ATOMICITY CONTRACT:
#   Phase 1 READ   -> files into memory
#   Phase 2 ANCHOR -> all anchors checked (abort if any miss)
#   Phase 3 APPLY  -> all changes in memory only
#   Phase 4 VERIFY -> all checks on in-memory buffers (abort if any fail)
#   Phase 5 WRITE  -> backups then files
#   FILES WRITTEN: NO if any phase 2 or phase 4 check fails.
#   BACKUPS WRITTEN: NO if abort before phase 5.
#
# STAGING vs REPO:
#   Staging dir: K:\DEVKIT\projects\htw-generator  (where this patch lives)
#   Repo root:   K:\DEVKIT\projects\htw-generator\htw-generator
#   Run from REPO ROOT.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Patch    = 'patch_htw_v065k_structure_coherence.ps1'
$Target   = 'v0.6.5k'
$Root     = (Get-Location).Path
$AppJs    = Join-Path $Root 'app.js'
$HtmlFile = Join-Path $Root 'index.html'

Write-Host ''
Write-Host '=== PATCH HEADER ==='
Write-Host "PATCH:   $Patch"
Write-Host "TARGET:  $Target"
Write-Host "ROOT:    $Root"
Write-Host "MODE:    APPLY (atomic -- no writes until all verifies pass)"
Write-Host ''

# ==============================================================
# PHASE 1 — READ
# ==============================================================
Write-Host '=== PHASE 1: READ ==='

$anyFail = $false
foreach ($f in @($AppJs, $HtmlFile)) {
    if (-not (Test-Path $f)) {
        Write-Host "[ERROR] FILE NOT FOUND: $f"
        $anyFail = $true
    }
}
if ($anyFail) {
    Write-Host '[ERROR] READ FAILED'
    Write-Host '[ERROR] FILES WRITTEN: NO'
    Write-Host '[ERROR] BACKUPS WRITTEN: NO'
    Write-Host 'NEXT ACTION: run from repo root, not staging dir'
    exit 1
}

$c = [System.IO.File]::ReadAllText($AppJs);    $c = $c.Replace("`r`n", "`n")
$h = [System.IO.File]::ReadAllText($HtmlFile); $h = $h.Replace("`r`n", "`n")
Write-Host '[OK] All files read into memory'

# ==============================================================
# DEFINE ANCHORS
# ==============================================================

# HTW_065k_ID_0001
# Anchor: the full v0.6.5j final placement block (from contrast comment through closing brace)
# Preserves everything above this point: blocking logic, motherCS/cols/rows setup
$fK1 = @'
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
$fK1 = $fK1.Replace("`r`n", "`n")

$rK1 = @'
  // Structure-coherent noise placement (v0.6.5k)
  // One procedural decision per structure cell.
  // Contrast drives probability; motherCS drives blob scale.
  // noiseAmount modulates frequency only -- blob size is purely structure-derived.
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
      // Pass 1: mean luminance for this structure cell
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
      // Pass 2: stddev -> local contrast
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
      const contrast = stddev / 128; // 0..1, 128 = theoretical max stddev
      if (rand() < contrast * S.fx.noiseAmount) {
        // Blob placed at random position within the structure cell screen area
        // blobSize is a fixed fraction of the structure cell -- always structure-coherent
        const dx = Math.floor(rand() * motherCS * vz);
        const dy = Math.floor(rand() * motherCS * vz);
        const blobSize = Math.max(2, Math.floor(motherCS * vz / 3));
        ctx.fillRect(ox + c * motherCS * vz + dx, oy + r * motherCS * vz + dy, blobSize, blobSize);
      }
    }
  }
}
'@
$rK1 = $rK1.Replace("`r`n", "`n")

# HTW_065k_ID_0002
$fH2a = 'HTW GENERATOR v0.6.5j</title>'
$rH2a = 'HTW GENERATOR v0.6.5k</title>'
$fH2b = 'v0.6.5j</div>'
$rH2b = 'v0.6.5k</div>'

# ==============================================================
# PHASE 2 — ANCHOR SCAN
# ==============================================================
Write-Host ''
Write-Host '=== PHASE 2: ANCHOR SCAN ==='

$scanFail = $false
$passed = 0; $total = 3

if ($c.IndexOf($fK1) -lt 0) {
    Write-Host '[ERROR] ANCHOR MISS: HTW_065k_ID_0001 -- drawNoise final placement block'
    $scanFail = $true
} else { $passed++; Write-Host '[OK] HTW_065k_ID_0001 -- drawNoise placement block found' }

if ($h.IndexOf($fH2a) -lt 0) {
    Write-Host '[ERROR] ANCHOR MISS: HTW_065k_ID_0002a -- html title v0.6.5j'
    $scanFail = $true
} else { $passed++ }

if ($h.IndexOf($fH2b) -lt 0) {
    Write-Host '[ERROR] ANCHOR MISS: HTW_065k_ID_0002b -- html topinfo v0.6.5j'
    $scanFail = $true
} else { $passed++ }

if ($scanFail) {
    Write-Host "[ERROR] ANCHOR SCAN: $passed/$total"
    Write-Host '[ERROR] FILES WRITTEN: NO'
    Write-Host '[ERROR] BACKUPS WRITTEN: NO'
    Write-Host 'NEXT ACTION: verify repo is at v0.6.5j before applying'
    exit 1
}
Write-Host "[OK] ANCHOR SCAN: $total/$total"

# ==============================================================
# PHASE 3 — APPLY IN MEMORY
# ==============================================================
Write-Host ''
Write-Host '=== PHASE 3: APPLY IN MEMORY ==='

$c2 = $c.Replace($fK1, $rK1)
Write-Host '[OK] HTW_065k_ID_0001 -- placement block replaced (in memory)'

$h2 = $h.Replace($fH2a, $rH2a).Replace($fH2b, $rH2b)
Write-Host '[OK] HTW_065k_ID_0002 -- version v0.6.5k (in memory)'

# ==============================================================
# PHASE 4 — VERIFY IN-MEMORY BUFFERS
# ==============================================================
Write-Host ''
Write-Host '=== PHASE 4: VERIFY (in memory -- no writes yet) ==='

$verifyFail = $false

# 1. Old tiny-dot/dust formula removed
if ($c2.IndexOf('Math.floor(motherCS * vz / 8)') -ge 0) {
    Write-Host '[ERROR] VERIFY -- old dotSize vz/8 formula still present'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY -- old tiny-dust dotSize formula removed' }

# 2. Old cluster loop removed
if ($c2.IndexOf('const clusterSize') -ge 0) {
    Write-Host '[ERROR] VERIFY -- old cluster loop still present'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY -- old cluster loop absent' }

# 3. blobSize tied to motherCS
if ($c2.IndexOf('Math.floor(motherCS * vz / 3)') -lt 0) {
    Write-Host '[ERROR] VERIFY -- blobSize formula not found'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY -- blobSize = floor(motherCS * vz / 3) present' }

# 4. noiseAmount in probability logic
if ($c2.IndexOf('contrast * S.fx.noiseAmount') -lt 0) {
    Write-Host '[ERROR] VERIFY -- noiseAmount not in probability expression'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY -- noiseAmount in probability expression' }

# 5. Blocking logic above placement block preserved
if ($c2.IndexOf('blocked.has(key(c, r))') -lt 0) {
    Write-Host '[ERROR] VERIFY -- blocked-cell logic missing from app buffer'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY -- blocked-cell logic preserved' }

# 6. Export flow: drawMarkers still present
if ($c2.IndexOf('drawMarkers(ex, iw, ih, 0, 0') -lt 0) {
    Write-Host '[ERROR] VERIFY -- drawMarkers not in exportPNG buffer'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY -- drawMarkers in export flow' }

# 7. Export flow: drawNoise still present
if ($c2.IndexOf('drawNoise(ex, iw, ih, 0, 0') -lt 0) {
    Write-Host '[ERROR] VERIFY -- drawNoise not in exportPNG buffer'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY -- drawNoise in export flow' }

# 8. Version in html buffer
if ($h2.IndexOf('v0.6.5k</title>') -lt 0) {
    Write-Host '[ERROR] VERIFY -- v0.6.5k not in html buffer'; $verifyFail = $true
} else { Write-Host '[OK] VERIFY -- v0.6.5k in html buffer' }

if ($verifyFail) {
    Write-Host ''
    Write-Host '=== FAILURE REPORT ==='
    Write-Host 'STATUS:          ERROR'
    Write-Host 'PHASE:           in-memory verify (Phase 4)'
    Write-Host 'FILES WRITTEN:   NO'
    Write-Host 'BACKUPS WRITTEN: NO'
    Write-Host 'NEXT ACTION:     no files touched. Diagnose anchor or replacement issue.'
    exit 1
}

Write-Host ''
Write-Host '[OK] All in-memory verifies passed -- proceeding to write'

# ==============================================================
# PHASE 5 — BACKUP + WRITE
# ==============================================================
Write-Host ''
Write-Host '=== PHASE 5: BACKUP + WRITE ==='

$BackupDir = Join-Path $Root '_old\backups'
if (-not (Test-Path $BackupDir)) { New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null }
$ts = (Get-Date).ToString('yyyy-MM-dd_HH-mm-ss')

Copy-Item $AppJs    (Join-Path $BackupDir "${ts}_app.js")
Copy-Item $HtmlFile (Join-Path $BackupDir "${ts}_index.html")
Write-Host "[OK] BACKUPS WRITTEN: _old\backups\${ts}_app.js"
Write-Host "[OK] BACKUPS WRITTEN: _old\backups\${ts}_index.html"

[System.IO.File]::WriteAllText($AppJs,    $c2.Replace("`n", "`r`n"), (New-Object System.Text.UTF8Encoding $false))
Write-Host '[OK] FILE WRITTEN: app.js'

[System.IO.File]::WriteAllText($HtmlFile, $h2.Replace("`n", "`r`n"), (New-Object System.Text.UTF8Encoding $false))
Write-Host '[OK] FILE WRITTEN: index.html'

# Archive patch (staging dir is one level up from repo root)
$PatchSrc = Join-Path (Split-Path $Root -Parent) $Patch
$PatchDir = Join-Path $Root '_old\patches'
if (-not (Test-Path $PatchDir)) { New-Item -ItemType Directory -Path $PatchDir -Force | Out-Null }
if (Test-Path $PatchSrc) {
    Copy-Item $PatchSrc (Join-Path $PatchDir "${ts}_${Patch}")
    Write-Host "[OK] Patch archived: _old\patches\${ts}_${Patch}"
} else {
    Write-Host "[WARN] Patch file not found in staging dir -- archive skipped"
}

# ==============================================================
# RESULT
# ==============================================================
Write-Host ''
Write-Host '=== RESULT ==='
Write-Host '[OK] Patch v0.6.5k complete.'
Write-Host '[OK] HTW_065k_ID_0001 -- structure-coherent noise blob model'
Write-Host '[OK] HTW_065k_ID_0002 -- version v0.6.5k'
Write-Host ''
Write-Host '=== SMOKE TEST CHECKLIST ==='
Write-Host '[ ] Header reads v0.6.5k'
Write-Host '[ ] Load image -> switch to Effects -> enable noise'
Write-Host '[ ] High-contrast image: noise blobs appear at edge zones'
Write-Host '[ ] Flat/uniform image: minimal or no noise'
Write-Host '[ ] Structure Size small (e.g. 8px): small blobs, dense grid'
Write-Host '[ ] Structure Size large (e.g. 64px): larger blobs, coarser grid'
Write-Host '[ ] Amount = 0: no noise regardless of image'
Write-Host '[ ] Amount = 1: max noise at high-contrast zones'
Write-Host '[ ] Enable rails + noise -> Export PNG -> confirm both in export'
Write-Host '[ ] Bake a zone -> confirm bake = checker only, not noise'
