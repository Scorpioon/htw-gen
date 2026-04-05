// core/dom.js
// DOM element references and helpers

function getCanvasWrapper() {
    return document.getElementById('cw');
}

function getCanvas() {
    return document.getElementById('cv');
}

function getSidebar() {
    return document.getElementById('sidebar');
}

function getStatusMode() {
    return document.getElementById('st-mode');
}

function getStatusGrid() {
    return document.getElementById('st-grid');
}

function getStatusImage() {
    return document.getElementById('st-img');
}

function getStatusZoom() {
    return document.getElementById('st-zoom');
}

function getStatusPalette() {
    return document.getElementById('st-pal');
}

function getStatusMessage() {
    return document.getElementById('st-msg');
}

function getDropOverlay() {
    return document.getElementById('drop');
}

function getFileInput() {
    return document.getElementById('file-input');
}

// Debounce utility (shared)
function debounce(fn, ms) {
    let t;
    return (...a) => {
        clearTimeout(t);
        t = setTimeout(() => fn(...a), ms);
    };
}