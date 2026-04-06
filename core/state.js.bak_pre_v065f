// core/state.js
// HTW Generator v0.6.5 - Effects polish release
// Global application state

const S = {
    mode: 'icon',
    tool: 'move',
    img: null,
    grid: null,
    gw: 0,
    gh: 0,
    mask: null,
    mw: 0,
    mh: 0,
    bakeStack: [],          // array of { overlayCanvas: OffscreenCanvas, visible: boolean }
    vz: 1,
    vpx: 0,
    vpy: 0,
    dragging: false,
    dragX: 0,
    dragY: 0,
    painting: false,
    paintVal: true,
    rectStart: null,
    spaceDown: false,
    icon: {
        size: 16,
        thr: 128,
        invert: false,
        grid: false,
        fitMode: 'contain'
    },
    fx: {
        colorMode: true,
        grid: false,
        checker: true,
        depth: 3,                     // index into DEPTHS (16px default)
        rail1: false,
        rail2: false,
        rail3: false,
        rail1Border: false,
        seed: 42,                     // global seed for effects
        noise: false,
        palIdx: 4,
        brushSize: 20                 // now in pixels (range 4-128)
    },
    bm: {
        dither: 2,
        contrast: 1.0,
        depth: 2,
        shape: 0,
        cm: 2,
        pi2: 4,
        pi3: 0,
        pi4: 0,
        psh: 0
    }
};

function getState() {
    return S;
}