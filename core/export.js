// core/export.js
// HTW Generator v0.6.0a - small icon reliability pass
// Download and export helpers

function downloadBlob(blob, name) {
    const a = document.createElement('a');
    a.download = name;
    a.href = URL.createObjectURL(blob);
    a.click();
    URL.revokeObjectURL(a.href);
}

function createOffscreenCanvas(width, height) {
    return new OffscreenCanvas(width, height);
}