// core/palette.js
// HTW colour constants and palette definitions

const C = {
  BK: [18, 18, 18],
  WH: [242, 242, 242],
  BL: [0, 68, 253],
  BD: [0, 28, 130],
  GR: [0, 250, 158],
  GY: [155, 155, 155]
};

const P2 = [
  { n: 'Black / White', c: [C.BK, C.WH] },
  { n: 'White / Black', c: [C.WH, C.BK] },
  { n: 'Blue / White', c: [C.BL, C.WH] },
  { n: 'White / Blue', c: [C.WH, C.BL] },
  { n: 'Black / Blue', c: [C.BK, C.BL] },
  { n: 'Blue / Black', c: [C.BL, C.BK] },
  { n: 'Airdrop / Black', c: [C.GR, C.BK] },
  { n: 'Black / Airdrop', c: [C.BK, C.GR] },
  { n: 'Blue / Airdrop', c: [C.BL, C.GR] },
  { n: 'Airdrop / Blue', c: [C.GR, C.BL] },
];

const P3 = [
  { n: 'Black · Blue · White', c: [C.BK, C.BL, C.WH] },
  { n: 'Black · Airdrop · White', c: [C.BK, C.GR, C.WH] },
  { n: 'Blue · Airdrop · White', c: [C.BL, C.GR, C.WH] },
  { n: 'Deep · Blue · White', c: [C.BD, C.BL, C.WH] },
  { n: 'Black · Deep · Blue', c: [C.BK, C.BD, C.BL] },
  { n: 'Black · Blue · Airdrop', c: [C.BK, C.BL, C.GR] },
];

const P4 = [
  { n: 'Black · Deep · Blue · White', c: [C.BK, C.BD, C.BL, C.WH] },
  { n: 'Black · Blue · Airdrop · White', c: [C.BK, C.BL, C.GR, C.WH] },
  { n: 'Black · Deep · Airdrop · White', c: [C.BK, C.BD, C.GR, C.WH] },
  { n: 'Black · Blue · Airdrop · Grey', c: [C.BK, C.BL, C.GR, C.GY] },
];

const DEPTHS = [2, 4, 8, 16, 32, 64, 128, 256];
const SHAPES = ['Square', 'Dot', 'Cross', 'X', 'Ring', 'Bars', 'Halftone', 'ASCII'];
const BAYER8 = [
  [0, 32, 8, 40, 2, 34, 10, 42], [48, 16, 56, 24, 50, 18, 58, 26],
  [12, 44, 4, 36, 14, 46, 6, 38], [60, 28, 52, 20, 62, 30, 54, 22],
  [3, 35, 11, 43, 1, 33, 9, 41], [51, 19, 59, 27, 49, 17, 57, 25],
  [15, 47, 7, 39, 13, 45, 5, 37], [63, 31, 55, 23, 61, 29, 53, 21],
];

const ASCII_CHARS = ' .`-_\':,;~=+!?|()1tlI/r7jYTLvfxneoa3u5sEcb4hd6VkmpgywUX28OQ0ZKWNMB#@$%';

function rgb(c) {
  return `rgb(${c[0]},${c[1]},${c[2]})`;
}

function lum(r, g, b) {
  return 0.299 * r + 0.587 * g + 0.114 * b;
}