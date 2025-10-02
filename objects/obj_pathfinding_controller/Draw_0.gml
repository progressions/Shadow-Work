// Pathfinding Controller - Draw Event
// Debug visualization of the pathfinding grid

if (global.debug_pathfinding) {
    draw_set_alpha(0.3);
    mp_grid_draw(grid);
    draw_set_alpha(1);
}
