move_speed = 1.25;

tilemap = layer_tilemap_get_id("Tiles_Col");

move_dir = "right";
facing_dir = "down";

// In obj_player CREATE EVENT, add:
walking_sound = -1;  // Track the sound instance

equipped = {
	right_hand: undefined,
	left_hand: undefined,
	head: undefined,
	torso: undefined,
    legs: undefined,
}

inventory = [];
max_inventory_size = 10;

debug = false;

interaction_offset_x = 0;
interaction_offset_y = -8;
interaction_radius = 1;

// instance_create_depth(x, y, depth - 1, obj_player_hands);

// Initialize the global frame tracker
global_frame = 0;

// Create the frame mapping (optional - for the first approach)
frame_mapping = ds_map_create();
frame_mapping[? "idle_down_start"] = 0;
frame_mapping[? "idle_right_start"] = 2;
frame_mapping[? "idle_left_start"] = 4;
frame_mapping[? "idle_up_start"] = 6;
frame_mapping[? "walk_down_start"] = 8;
frame_mapping[? "walk_right_start"] = 12;
frame_mapping[? "walk_left_start"] = 17;
frame_mapping[? "walk_up_start"] = 22;

#region player sprite choice

// Set the sprite once
sprite_index = spr_player;
image_speed = 0;  // IMPORTANT: Disable automatic animation

anim_data = {
    // Existing animations (frames 0-25)
    idle_down: {start: 0, length: 2},
    idle_left: {start: 2, length: 2},
    idle_right: {start: 4, length: 2},
    idle_up: {start: 6, length: 2},
    walk_down: {start: 8, length: 5},
    walk_right: {start: 13, length: 5},
    walk_left: {start: 18, length: 4},
    walk_up: {start: 22, length: 4},
    
    // New dash animations (frames 26-41)
    dash_down: {start: 26, length: 4},
    dash_right: {start: 30, length: 4},
    dash_left: {start: 34, length: 4},
    dash_up: {start: 38, length: 4}
};

// State tracking
facing_dir = "down";
move_dir = "idle";
current_anim = "idle_down";
current_anim_start = 0;
current_anim_length = 2;

// Animation control
anim_frame = 0;  // Track current frame within animation
anim_speed_idle = 0.05;  // How fast to animate (adjust as needed)
anim_speed_walk = 0.15;