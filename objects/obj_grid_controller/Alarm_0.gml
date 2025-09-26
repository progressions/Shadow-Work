// Find the top-left pillar to determine grid origin
var min_x = 9999;
var min_y = 9999;

with (obj_rising_pillar) {
    if (x < min_x) min_x = x;
    if (y < min_y) min_y = y;
}

// Now organize pillars into grid based on the actual grid position
with (obj_rising_pillar) {
    // Calculate grid position based on the top-left pillar position
    var grid_x = round((x - min_x) / other.tile_size);
    var grid_y = round((y - min_y) / other.tile_size);
    
    show_debug_message("Pillar at x:" + string(x) + " y:" + string(y) + 
                       " -> grid_x:" + string(grid_x) + " grid_y:" + string(grid_y));
    
    // Check if this pillar is within our grid
    if (grid_x >= 0 && grid_x < other.grid_width && 
        grid_y >= 0 && grid_y < other.grid_height) {
        // Store reference to this pillar
        other.pillars[grid_x][grid_y] = id;
        
        // Tell the pillar its grid position
        self.grid_x = grid_x;
        self.grid_y = grid_y;
        self.grid_controller = other.id;
    }
}

// Debug: Print the grid
show_debug_message("Pillar grid initialized:");
for (var j = 0; j < grid_height; j++) {
    var row = "";
    for (var i = 0; i < grid_width; i++) {
        var pillar = pillars[i][j];
        if (pillar != 0 && pillar != undefined) {
            row += string(pillar.height) + " ";
        } else {
            row += "X ";
        }
    }
    show_debug_message(row);
}