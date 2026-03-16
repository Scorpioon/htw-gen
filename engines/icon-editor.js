// engines/icon-editor.js
// HTW Generator v0.6.0a - small icon reliability pass
// Minimal grid editing (toggle pixel)

function togglePixel(grid, x, y, size = 32) {
    if (x < 0 || x >= size || y < 0 || y >= size) return grid;
    const idx = y * size + x;
    const newGrid = grid.slice();
    const cell = { ...newGrid[idx] };
    // Toggle the background color between fg and bg
    // Since icon cells use bg to store the color, we swap fg and bg
    const temp = cell.bg;
    cell.bg = cell.fg;
    cell.fg = temp;
    newGrid[idx] = cell;
    return newGrid;
}