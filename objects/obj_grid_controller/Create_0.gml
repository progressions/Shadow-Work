// =====================
// obj_grid_controller : Create (FULL)
// =====================

// Grid configuration
grid_width  = 4;
grid_height = 4;
tile_size   = 16; // Adjust based on your pillar spacing

// Visual offset so player appears centered on a pillar tile
GRID_Y_OFFSET = -8;

// Exit policy — block leaving the grid by edge (set true to allow, false to block)
ALLOW_EXIT_LEFT  = true;
ALLOW_EXIT_RIGHT = true;
ALLOW_EXIT_UP    = false;
ALLOW_EXIT_DOWN  = false;

// How far past the edge to land when exiting the grid (prevents sticking on borders)
LEAVE_CLEAR = 16; // was the “leave_clear” you remembered

// Create empty grid array
pillars = array_create(grid_width);
for (var i = 0; i < grid_width; i++) {
    pillars[i] = array_create(grid_height);
}

// State
previous_pillar = noone;
current_pillar  = noone;

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

alarm[0] = 1;


// =====================
// FUNCTIONS (FULL)
// =====================

function update_depths() {
    for (var gx = 0; gx < grid_width; gx++) {
        for (var gy = 0; gy < grid_height; gy++) {
            var pillar = pillars[gx][gy];
            if (pillar != 0 && pillar != undefined) {
                // Larger row index draws in front (lower depth)
                pillar.depth = -gy * 10;
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
        if (_instance.height - current_elevation <= 1) {
            // Restore previous pillar's color
            if (other.previous_pillar != noone && instance_exists(other.previous_pillar)) {
                other.previous_pillar.image_blend = c_white;
            }

            // Highlight new pillar
            _instance.image_blend = c_grey;
            other.previous_pillar = _instance;
            other.current_pillar  = _instance;

            // If this pillar toggles another, do it now
            if (_instance.object_index == obj_rising_pillar) {
                with (_instance) {
                    toggle_target();
                }
            }

            // Snap player to pillar center with visual offset
            x = _instance.x;
            y = _instance.y + other.GRID_Y_OFFSET;

            elevation_source   = _instance;
            current_elevation  = _instance.height;
            state              = PlayerState.on_grid;
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
    obj_player.elevation_source  = noone;
    obj_player.current_elevation = -1; // ground
    obj_player.state             = PlayerState.idle;
}

/// 1) PLAN: figure out what we’re trying to step to
function plan_grid_step(direction_x, direction_y) {
    var plan = {
        off_grid: false,
        next_grid_x: 0,
        next_grid_y: 0,
        target_pillar: noone,
        target_world_x: 0,
        target_world_y: 0,
        edge: "",         // "left"|"right"|"up"|"down" or ""
        dx: direction_x,  // preserve for exit clearance
        dy: direction_y
    };

    if (current_pillar == noone) {
        show_debug_message("ERROR: current_pillar is noone!");
        return plan;
    }

    var current_grid_x = current_pillar.grid_x;
    var current_grid_y = current_pillar.grid_y;
    plan.next_grid_x = current_grid_x + direction_x;
    plan.next_grid_y = current_grid_y + direction_y;

    // Off-grid?
    plan.off_grid =
        (plan.next_grid_x < 0) || (plan.next_grid_x >= grid_width) ||
        (plan.next_grid_y < 0) || (plan.next_grid_y >= grid_height);

    if (plan.off_grid) {
        if (plan.next_grid_x < 0)                  plan.edge = "left";
        else if (plan.next_grid_x >= grid_width)   plan.edge = "right";
        else if (plan.next_grid_y < 0)             plan.edge = "up";
        else if (plan.next_grid_y >= grid_height)  plan.edge = "down";

        // Compute a world target at the edge cell, then push outward by LEAVE_CLEAR
        var origin_x = pillars[0][0].x;
        var origin_y = pillars[0][0].y;
        var base_x   = origin_x + plan.next_grid_x * tile_size;
        var base_y   = origin_y + plan.next_grid_y * tile_size + GRID_Y_OFFSET;

        // Nudge further outward to avoid getting stuck on edge collisions
        plan.target_world_x = base_x + plan.dx * LEAVE_CLEAR;
        plan.target_world_y = base_y + plan.dy * LEAVE_CLEAR;

    } else {
        // On-grid target pillar
        var p = pillars[plan.next_grid_x][plan.next_grid_y];
        plan.target_pillar = (p == 0 || p == undefined) ? noone : p;
    }

    return plan;
}

/// 2) ALLOW: decide if the step is legal (bounds + height rule + exit policy)
function allow_grid_step(plan) {
    // Edge guarding: prevent leaving the grid unless explicitly allowed by edge
    if (plan.off_grid) {
        switch (plan.edge) {
            case "left":
                if (!ALLOW_EXIT_LEFT)  { play_sfx(snd_bump, 1, false); return false; }
                break;
            case "right":
                if (!ALLOW_EXIT_RIGHT) { play_sfx(snd_bump, 1, false); return false; }
                break;
            case "up":
                if (!ALLOW_EXIT_UP)    { play_sfx(snd_bump, 1, false); return false; }
                break;
            case "down":
                if (!ALLOW_EXIT_DOWN)  { play_sfx(snd_bump, 1, false); return false; }
                break;
        }
        // If allowed by policy, we’ll let apply_grid_step handle the off-grid hop.
        return true;
    }

    // On-grid checks
    if (plan.target_pillar == noone) {
        show_debug_message("Move blocked: no pillar at target position");
        return false;
    }

    // Height rule: can go down any amount; can only go up by 1
    var current_height = obj_player.current_elevation; // -1 for ground, else 0/1/2...
    var target_height  = plan.target_pillar.height;

    if (target_height - current_height > 1) {
        play_sfx(snd_bump, 1, false);
        show_debug_message("Move blocked: too high (" + string(current_height) + " -> " + string(target_height) + ")");
        return false;
    }

    return true;
}

/// 3) APPLY: perform the movement (hop + state/highlights/elevation)
function apply_grid_step(plan) {
    if (plan.off_grid) {
        // Only executed if the edge policy allowed exiting
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

    // Clear old highlight, set new highlight
    if (previous_pillar != noone) previous_pillar.image_blend = c_white;
    target.image_blend = c_grey;

    // Update pillar refs (your original pattern)
    previous_pillar = target;
    current_pillar  = target;

    // Trigger the target toggle on the newly current pillar (if rising pillar)
    if (current_pillar.object_index == obj_rising_pillar) {
        with (current_pillar) {
            toggle_target();
        }
    }

    // Start hop to pillar (apply consistent visual offset on landing)
    hop.active   = true;
    hop.start_x  = obj_player.x;
    hop.start_y  = obj_player.y;
    hop.target_x = target.x;
    hop.target_y = target.y + GRID_Y_OFFSET;
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

function move_down()  { return try_grid_move(0,  1); }
function move_up()    { return try_grid_move(0, -1); }
function move_left()  { return try_grid_move(-1, 0); }
function move_right() { return try_grid_move(1,  0); }


// =====================
// RESET (unchanged except for clarity)
// =====================

function reset_all_pillars_to_original() {
    with (obj_rising_pillar) {
        var changed = (height != original_height);

        // Reset height — touch whatever fields your pillar logic uses
        height         = original_height;
        target_height  = original_height;
        display_height = original_height;
        current_height = original_height;

        // Reset state/visuals
        is_toggled      = false;
        highlight_timer = 0;
        emphasis_timer  = 0;
        image_blend     = c_white;

        // Emphasize if this pillar changed
        if (changed) {
            emphasize_pillar_feedback();
        }
    }

    // Clear controller highlights
    if (previous_pillar != noone && instance_exists(previous_pillar)) previous_pillar.image_blend = c_white;
    if (current_pillar  != noone && instance_exists(current_pillar))  current_pillar.image_blend  = c_white;
}
