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

// Hopping animation
hop = {
    active: false,
    start_x: 0,
    start_y: 0,
    target_x: 0,
    target_y: 0,
    progress: 0,
    speed: 0.2,  // Adjust for hop speed
    height: 4    // Peak height of hop arc
};

// Create empty grid array
pillars = array_create(grid_width);
for (var i = 0; i < grid_width; i++) {
    pillars[i] = array_create(grid_height);
}

alarm[0] = 1;




#region functions

function update_depths() {
    for (var i = 0; i < grid_width; i++) {
        for (var j = 0; j < grid_height; j++) {
            var pillar = pillars[i][j];
            if (pillar != 0 && pillar != undefined) {
                // Larger j (row further down) gets a LOWER depth → draws in front
                pillar.depth = -j * 10;
            }
        }
    }

    if (current_pillar != noone) {
        // Player just in front of their pillar
        obj_player.depth = current_pillar.depth - 1;
    }
}


function move_onto(_instance) { 
	   if (hop.active) return;
	update_depths();
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
    // Clear highlight on whichever ref is set
    if (current_pillar != noone && instance_exists(current_pillar)) {
        current_pillar.image_blend = c_white;
    }
    if (previous_pillar != noone && instance_exists(previous_pillar)) {
        previous_pillar.image_blend = c_white;
    }

    previous_pillar = noone;
    current_pillar  = noone;

    // Explicitly mark player off-grid
    obj_player.elevation_source = noone;
    obj_player.state            = PlayerState.idle;
}



/// 1) PLAN: figure out what we’re trying to step to
function plan_grid_step(direction_x, direction_y) {
    var plan = {
        // filled below
        off_grid: false,
        next_grid_x: 0,
        next_grid_y: 0,
        target_pillar: noone,
        target_world_x: 0,
        target_world_y: 0
    };

    if (current_pillar == noone) {
        show_debug_message("ERROR: current_pillar is noone!");
        return plan; // off_grid=false, target_pillar=noone → will fail in allow
    }

    var current_grid_x = current_pillar.grid_x;
    var current_grid_y = current_pillar.grid_y;
    plan.next_grid_x = current_grid_x + direction_x;
    plan.next_grid_y = current_grid_y + direction_y;

    show_debug_message("Moving from [" + string(current_grid_x) + "," + string(current_grid_y) + "] to [" + string(plan.next_grid_x) + "," + string(plan.next_grid_y) + "]");
    show_debug_message("Current pillar: " + string(current_pillar) + " height=" + string(current_pillar.height));

    // Off-grid?
    plan.off_grid = (
        plan.next_grid_x < 0 || plan.next_grid_x >= grid_width ||
        plan.next_grid_y < 0 || plan.next_grid_y >= grid_height
    );

    if (plan.off_grid) {
        // Land using your existing origin math
        var origin_x = pillars[0][0].x;
        var origin_y = pillars[0][0].y;
        plan.target_world_x = origin_x + plan.next_grid_x * tile_size;
        plan.target_world_y = origin_y + plan.next_grid_y * tile_size;
    } else {
        // On-grid target pillar
        var p = pillars[plan.next_grid_x][plan.next_grid_y];
        plan.target_pillar = (p == 0 || p == undefined) ? noone : p;
    }

    return plan;
}

/// 2) ALLOW: decide if the step is legal (bounds + height rule)
function allow_grid_step(plan) {
    if (plan.off_grid) return true; // always can leave grid

    if (plan.target_pillar == noone) {
        show_debug_message("Move blocked: no pillar at target position");
        return false;
    }

    var current_height = obj_player.current_elevation; // -1 for ground, else 0/1/2...
    var target_height  = plan.target_pillar.height;

    if (target_height - current_height > 1) {
        show_debug_message("Move blocked: too high (" + string(current_height) + " -> " + string(target_height) + ")");
        return false;
    }

    return true;
}

/// 3) APPLY: perform the movement (hop + state/highlights/elevation)
function apply_grid_step(plan) {
    if (plan.off_grid) {
        // Start hop first so move_onto’s hop guard prevents re-attach this step
        hop.active   = true;
        hop.start_x  = obj_player.x;
        hop.start_y  = obj_player.y;
        hop.target_x = plan.target_world_x;
        hop.target_y = plan.target_world_y;
        hop.progress = 0;

        leave_grid();     // clears highlights + sets state/elevation to ground
        update_depths();
        return true;
    }

    // On-grid: we have a valid target pillar
    var target = plan.target_pillar;
    show_debug_message("Target pillar: " + string(target) + " height=" + string(target.height));

    // Clear old highlight, set new highlight
    if (previous_pillar != noone) previous_pillar.image_blend = c_white;
    target.image_blend = c_grey;

    // Update pillar refs (keeps your original pattern where both point to target)
    previous_pillar = target;
    current_pillar  = target;

    // Start hop to pillar
    hop.active   = true;
    hop.start_x  = obj_player.x;
    hop.start_y  = obj_player.y;
    hop.target_x = target.x;
    hop.target_y = target.y - 8;
    hop.progress = 0;

    // Elevation
    obj_player.elevation_source  = target;
    obj_player.current_elevation = target.height;

    update_depths();
    return true;
}

/// Thin wrapper that composes the three steps
function try_grid_move(direction_x, direction_y) {
    var plan = plan_grid_step(direction_x, direction_y);
    if (!allow_grid_step(plan)) return false;
    return apply_grid_step(plan);
}


function move_down() { return try_grid_move(0, 1); }
function move_up() { return try_grid_move(0, -1); }
function move_left() { return try_grid_move(-1, 0); }
function move_right() { return try_grid_move(1, 0); }

