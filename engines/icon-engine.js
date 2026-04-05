// engines/icon-engine.js
// HTW Generator v0.6.0a - small icon reliability pass
// Smart icon generation pipeline

// Helper: compute luminance
function lum(r, g, b) {
    return 0.299 * r + 0.587 * g + 0.114 * b;
}

// Helper: Sobel gradient magnitude
function sobel(data, width, height) {
    const grad = new Float32Array(width * height);
    const kernelX = [-1, 0, 1, -2, 0, 2, -1, 0, 1];
    const kernelY = [-1, -2, -1, 0, 0, 0, 1, 2, 1];
    for (let y = 1; y < height - 1; y++) {
        for (let x = 1; x < width - 1; x++) {
            let gx = 0, gy = 0;
            for (let ky = -1; ky <= 1; ky++) {
                for (let kx = -1; kx <= 1; kx++) {
                    const i = ((y + ky) * width + (x + kx)) * 4;
                    const val = lum(data[i], data[i + 1], data[i + 2]);
                    gx += val * kernelX[(ky + 1) * 3 + (kx + 1)];
                    gy += val * kernelY[(ky + 1) * 3 + (kx + 1)];
                }
            }
            grad[y * width + x] = Math.sqrt(gx * gx + gy * gy);
        }
    }
    return grad;
}

// Detect background color by sampling corners
function detectBackgroundColor(data, width, height) {
    const samples = [];
    const sampleSize = 5;
    // corners
    for (let i = 0; i < sampleSize; i++) {
        for (let j = 0; j < sampleSize; j++) {
            // top-left
            let idx = (j * width + i) * 4;
            samples.push([data[idx], data[idx + 1], data[idx + 2]]);
            // top-right
            idx = (j * width + (width - 1 - i)) * 4;
            samples.push([data[idx], data[idx + 1], data[idx + 2]]);
            // bottom-left
            idx = ((height - 1 - j) * width + i) * 4;
            samples.push([data[idx], data[idx + 1], data[idx + 2]]);
            // bottom-right
            idx = ((height - 1 - j) * width + (width - 1 - i)) * 4;
            samples.push([data[idx], data[idx + 1], data[idx + 2]]);
        }
    }
    // average
    let sumR = 0, sumG = 0, sumB = 0;
    samples.forEach(c => { sumR += c[0]; sumG += c[1]; sumB += c[2]; });
    const len = samples.length;
    return [sumR / len, sumG / len, sumB / len];
}

// Create binary mask based on alpha or background detection
function createMask(data, width, height, bgMode, bgHint) {
    const mask = new Uint8Array(width * height);
    if (bgMode === 'alpha') {
        for (let i = 0; i < width * height; i++) {
            mask[i] = data[i * 4 + 3] > 128 ? 1 : 0; // assume opaque = figure
        }
    } else {
        // Use background hint (rgb array) or detect auto
        const bg = bgHint || detectBackgroundColor(data, width, height);
        const threshold = 40; // simple distance threshold
        for (let i = 0; i < width * height; i++) {
            const r = data[i * 4], g = data[i * 4 + 1], b = data[i * 4 + 2];
            const dist = Math.abs(r - bg[0]) + Math.abs(g - bg[1]) + Math.abs(b - bg[2]);
            mask[i] = dist > threshold ? 1 : 0;
        }
    }
    return mask;
}

// Cleanup pass: remove isolated pixels, fill small gaps
function cleanupMask(mask, width, height) {
    const newMask = new Uint8Array(mask);
    for (let y = 1; y < height - 1; y++) {
        for (let x = 1; x < width - 1; x++) {
            const idx = y * width + x;
            let neighbors = 0;
            for (let dy = -1; dy <= 1; dy++) {
                for (let dx = -1; dx <= 1; dx++) {
                    if (dx === 0 && dy === 0) continue;
                    neighbors += mask[(y + dy) * width + (x + dx)];
                }
            }
            if (mask[idx] === 1 && neighbors <= 2) newMask[idx] = 0; // isolated
            if (mask[idx] === 0 && neighbors >= 6) newMask[idx] = 1; // fill small gap
        }
    }
    return newMask;
}

// Main smart icon generation
function generateSmartIconGrid(img, params) {
    // params: { fitMode, invert, threshold, fgColor, bgColor }
    const { fitMode, invert, threshold, fgColor, bgColor } = params;
    const analysisSize = 128; // work at 128x128 for detail
    const canvas = document.createElement('canvas');
    canvas.width = analysisSize;
    canvas.height = analysisSize;
    const ctx = canvas.getContext('2d');
    ctx.imageSmoothingEnabled = false;

    // Normalization: draw image centered, aspect preserved
    const iw = img.naturalWidth;
    const ih = img.naturalHeight;
    const scaleContain = Math.min(analysisSize / iw, analysisSize / ih);
    const scaleCover = Math.max(analysisSize / iw, analysisSize / ih);
    const scale = fitMode === 'contain' ? scaleContain : scaleCover;
    const dw = iw * scale;
    const dh = ih * scale;
    const dx = (analysisSize - dw) / 2;
    const dy = (analysisSize - dh) / 2;
    ctx.clearRect(0, 0, analysisSize, analysisSize);
    ctx.drawImage(img, dx, dy, dw, dh);

    const id = ctx.getImageData(0, 0, analysisSize, analysisSize);
    const data = id.data;

    // Figure/background separation
    const hasAlpha = data.some((_, i) => i % 4 === 3 && data[i] > 0 && data[i] < 255);
    const bgMode = hasAlpha ? 'alpha' : 'auto';
    let mask = createMask(data, analysisSize, analysisSize, bgMode, null);

    // Apply cleanup
    mask = cleanupMask(mask, analysisSize, analysisSize);

    // Gradient for edge importance
    const grad = sobel(data, analysisSize, analysisSize);
    // Normalize gradient to 0-1 range
    let maxGrad = 0;
    for (let i = 0; i < grad.length; i++) if (grad[i] > maxGrad) maxGrad = grad[i];
    const normGrad = grad.map(v => maxGrad > 0 ? v / maxGrad : 0);

    // Map threshold (0-255) to a base coverage threshold (0.2-0.6)
    const baseThresh = 0.4 + (threshold - 128) / 255 * 0.2;

    const gridSize = 32;
    const blockSize = analysisSize / gridSize; // 4
    const out = new Array(gridSize * gridSize).fill(false);

    for (let gy = 0; gy < gridSize; gy++) {
        for (let gx = 0; gx < gridSize; gx++) {
            const x0 = Math.floor(gx * blockSize);
            const y0 = Math.floor(gy * blockSize);
            const x1 = Math.floor((gx + 1) * blockSize);
            const y1 = Math.floor((gy + 1) * blockSize);
            let coverage = 0;
            let edgeSum = 0;
            let count = 0;
            for (let y = y0; y < y1; y++) {
                for (let x = x0; x < x1; x++) {
                    const idx = y * analysisSize + x;
                    coverage += mask[idx];
                    edgeSum += normGrad[idx];
                    count++;
                }
            }
            const avgCoverage = coverage / count;
            const avgEdge = edgeSum / count;
            // Edge bias: lower threshold where edges are strong (to preserve them)
            const edgeBias = avgEdge * 0.15;
            const thresh = Math.max(0.1, Math.min(0.9, baseThresh - edgeBias));
            const on = avgCoverage > thresh;
            out[gy * gridSize + gx] = on;
        }
    }

    // Second cleanup on 32x32 grid
    for (let iter = 0; iter < 2; iter++) {
        const newOut = out.slice();
        for (let y = 0; y < 32; y++) {
            for (let x = 0; x < 32; x++) {
                const idx = y * 32 + x;
                let neighbors = 0;
                for (let dy = -1; dy <= 1; dy++) {
                    for (let dx = -1; dx <= 1; dx++) {
                        if (dx === 0 && dy === 0) continue;
                        const nx = x + dx, ny = y + dy;
                        if (nx >= 0 && nx < 32 && ny >= 0 && ny < 32) {
                            neighbors += out[ny * 32 + nx] ? 1 : 0;
                        }
                    }
                }
                if (out[idx] && neighbors <= 2) newOut[idx] = false;
                if (!out[idx] && neighbors >= 6) newOut[idx] = true;
            }
        }
        out.splice(0, out.length, ...newOut);
    }

    // Apply invert if needed
    if (invert) {
        for (let i = 0; i < out.length; i++) out[i] = !out[i];
    }

    return out;
}