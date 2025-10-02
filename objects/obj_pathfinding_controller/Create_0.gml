// Pathfinding Controller - Create Event
// Creates and configures the pathfinding grid for the current room

// Grid cell size (matches tile_size from grid puzzle system)
cell_size = 16;

// Calculate grid dimensions based on room size
horizontal_cells = room_width div cell_size;
vertical_cells = room_height div cell_size;

// Create the pathfinding grid
// mp_grid_create(left, top, hcells, vcells, cellwidth, cellheight)
grid = mp_grid_create(0, 0, horizontal_cells, vertical_cells, cell_size, cell_size);

// Mark collision tilemap as obstacles ONLY (no buffer - let collision handle wall avoidance)
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

// Mark object instances as obstacles
mp_grid_add_instances(grid, obj_rising_pillar, true);  // true = precise collision shape
mp_grid_add_instances(grid, obj_companion_parent, true);
mp_grid_add_instances(grid, obj_reset_pad, true);
// Enemies are handled per-instance during path updates so they can leave their starting cell

// Periodically refresh grid to capture dynamic obstacle movement
alarm[0] = 60;

show_debug_message("Pathfinding grid created: " + string(horizontal_cells) + "x" + string(vertical_cells) + " cells");
