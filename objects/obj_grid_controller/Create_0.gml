// Grid configuration
grid_width = 4;
grid_height = 4;
tile_size = 16; // Adjust based on your pillar spacing

// Create empty grid array
pillars = array_create(grid_width);
for (var i = 0; i < grid_width; i++) {
    pillars[i] = array_create(grid_height);
}

// This will run after all pillars are created
alarm[0] = 1;

// Grid configuration
grid_width = 4;
grid_height = 4;
tile_size = 16;
previous_pillar = noone;
current_pillar = noone;

// Create empty grid array
pillars = array_create(grid_width);
for (var i = 0; i < grid_width; i++) {
    pillars[i] = array_create(grid_height);
}

alarm[0] = 1;
function move_onto(_instance) {
    show_debug_message("moving onto " + string(_instance));
    
    with (obj_player) {
        show_debug_message("current_elevation " + string(current_elevation));
        show_debug_message("_instance.height " + string(_instance.height));
        
        if (_instance.height - current_elevation <= 1) {
            // Restore previous pillar's color
            if (other.previous_pillar != noone && instance_exists(other.previous_pillar)) {
                other.previous_pillar.image_blend = c_white;
            }
            
            // Set new pillar to grey
            _instance.image_blend = c_grey;
            other.previous_pillar = _instance;
            other.current_pillar = _instance;
            
            // Snap player to grid position
            x = _instance.x;
            y = _instance.y;
            
            elevation_source = _instance;
            state = PlayerState.on_grid;  // Set flag that player is on grid
        } else {
            x = xprevious;
            y = yprevious;
        }
    }
}

function leave_grid() {
    if (previous_pillar != noone) previous_pillar.image_blend = c_white;
    previous_pillar = noone;
    current_pillar = noone;
    obj_player.on_grid = false;
}

function try_grid_move(dx, dy) {
    if (current_pillar == noone) return false;
    
    // Get position from the pillar's stored grid coordinates
    var curr_x = current_pillar.grid_x;
    var curr_y = current_pillar.grid_y;
    var new_x = curr_x + dx;
    var new_y = curr_y + dy;
    
    show_debug_message("Trying to move from (" + string(curr_x) + "," + string(curr_y) + ") to (" + string(new_x) + "," + string(new_y) + ")");
    
    // Moving off grid?
    if (new_x < 0 || new_x >= grid_width || new_y < 0 || new_y >= grid_height) {
        show_debug_message("Moving off grid!");
        leave_grid();
        // Calculate off-grid position
        var world_x = pillars[0][0].x + new_x * tile_size;
        var world_y = pillars[0][0].y + new_y * tile_size;
        obj_player.x = world_x;
        obj_player.y = world_y;
        obj_player.elevation_source = noone;
        obj_player.state = undefined;
        return true;
    }
    
    // Get target pillar
    var target = pillars[new_x][new_y];
    show_debug_message("Target pillar: " + string(target));
    
    if (target == 0 || target == undefined) {
        show_debug_message("No pillar at target position");
        return false;
    }
    
    // Move to target
    if (previous_pillar != noone) previous_pillar.image_blend = c_white;
    target.image_blend = c_grey;
    previous_pillar = target;
    current_pillar = target;
    
    obj_player.x = target.x;
    obj_player.y = target.y;
    obj_player.elevation_source = target;
    
    return true;
}


function move_down() { return try_grid_move(0, 1); }
function move_up() { return try_grid_move(0, -1); }
function move_left() { return try_grid_move(-1, 0); }
function move_right() { return try_grid_move(1, 0); }