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

paused_frame = 0;

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

// In CREATE EVENT add:
// Double-tap detection
double_tap_time = 300;  // milliseconds
last_key_time_w = -999;
last_key_time_a = -999;
last_key_time_s = -999;
last_key_time_d = -999;

// Dash state
is_dashing = false;
dash_duration = 8;  // frames
dash_timer = 0;
dash_speed = 6;

dash_cooldown = 0;
dash_cooldown_time = 30;

anim_data = {
    // Existing animations (frames 0-25)
    idle_down: {start: 0, length: 2},
    idle_right: {start: 2, length: 2},
    idle_left: {start: 4, length: 2},
    idle_up: {start: 6, length: 2},
    walk_down: {start: 8, length: 5},
    walk_right: {start: 12, length: 5},
    walk_left: {start: 17, length: 4},
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
state = PlayerState.idle;

// Animation control
anim_frame = 0;  // Track current frame within animation
anim_speed_idle = 0.05;  // How fast to animate (adjust as needed)
anim_speed_walk = 0.15;

elevation_source = noone;
current_elevation = -1;
y_offset = 0;
previous_y_offset = 0;

// Add this function to your scripts or at the bottom of Create Event:
function start_dash(_direction) {
    is_dashing = true;
    dash_timer = dash_duration;
    facing_dir = _direction;
    dash_cooldown = dash_cooldown_time;
    audio_play_sound(snd_dash, 1, false);
}
