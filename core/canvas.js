// core/canvas.js
// Canvas sizing, viewport, coordinate conversion

function getCanvasWidth() {
    return getCanvasWrapper().clientWidth;
}

function getCanvasHeight() {
    return getCanvasWrapper().clientHeight;
}

function getCellSizeFromState(state) {
    if (state.mode === 'icon') return state.icon.size;
    if (state.mode === 'bitmap') return DEPTHS[state.bm.depth];
    if (state.mode === 'effects') return DEPTHS[state.fx.depth];  // mother-grid for effects
    return 1;
}

function getViewOffset(cW, cH, vz, vpx, vpy, canvasWidth, canvasHeight) {
    return {
        ox: (canvasWidth - cW * vz) / 2 + vpx,
        oy: (canvasHeight - cH * vz) / 2 + vpy
    };
}

function resizeCanvasToWrapper(canvas) {
    canvas.width = getCanvasWidth();
    canvas.height = getCanvasHeight();
}