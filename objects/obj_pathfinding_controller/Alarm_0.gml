// Pathfinding Controller - Alarm 0
// Rebuild grid to account for dynamic obstacles (rising pillars, companions)

// Clear all cells
mp_grid_clear_all(grid);

// Re-mark collision tilemap ONLY (no buffer)
var tilemap = layer_tilemap_get_id("Tiles_Col");
if (tilemap != -1) {
    for (var i = 0; i < horizontal_cells; i++) {
        for (var j = 0; j < vertical_cells; j++) {
            var tile_data = tilemap_get(tilemap, i, j);
            if (tile_data != 0) {
                mp_grid_add_cell(grid, i, j);
            }
        }
    }
}

// Re-add dynamic obstacles at current positions
mp_grid_add_instances(grid, obj_rising_pillar, true);  // Pillars rise/lower dynamically
mp_grid_add_instances(grid, obj_companion_parent, true);  // Companions can move
mp_grid_add_instances(grid, obj_reset_pad, true);
// Enemies are excluded so they do not mark their own cell when path recalculates

// Reset alarm for next update (60 frames = 1 second)
alarm[0] = 60;
