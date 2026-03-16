// core/state.js
// HTW Generator v0.6.0a - small icon reliability pass
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
    bakeStack: [],
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
        fitMode: 'contain'   // 'contain' or 'cover'
    },
    fx: {
        colorMode: true,
        grid: false,
        checker: true,
        depth: 3,                     // index into DEPTHS (16px default)
        markers: false,
        mc: 10,
        ms: 42,                       // master seed (layer1 = ms, layer2 = ms+1)
        m2c: false,
        ml2: false,
        mc2: 6,
        palIdx: 4,
        brushSize: 2
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

// Simple state access (for consistency, direct mutation is still used elsewhere)
function getState() {
    return S;
}