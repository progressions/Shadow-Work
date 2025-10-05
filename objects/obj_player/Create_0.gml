move_speed = 1.25;

tilemap = layer_tilemap_get_id("Tiles_Col");

#region Stats

hp = 20;
hp_total = hp;
damage = 1;
facing_angle = 0;
level = 1;
xp = 0;
xp_to_next = 25;

// Trait system v2.0 - Stacking traits (replaces old damage_resistances)
tags = []; // Thematic descriptors (fireborne, venomous, etc.)
permanent_traits = {}; // From tags, quests (permanent)
temporary_traits = {};  // From equipment, companions, buffs (temporary)

// Combat timer for companion evading behavior
combat_timer = 999; // Start high so companions begin in following mode
combat_cooldown = 3; // Seconds of no combat before evading ends

#endregion Stats

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

loadouts = {
    active: "melee",
    melee: {
        right_hand: undefined,
        left_hand: undefined
    },
    ranged: {
        right_hand: undefined,
        left_hand: undefined
    }
};

inventory = [];
max_inventory_size = 16;

arrow_count = 0;
arrow_max = 25;

// Quest system
active_quests = {};

debug = false;

interaction_offset_x = 0;
interaction_offset_y = -8;
interaction_radius = 1;


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
dash_duration = 8;  // frames
dash_timer = 0;
dash_speed = 6;

dash_cooldown = 0;
dash_cooldown_time = 30;

// Dash attack system
dash_attack_window = 0;
dash_attack_window_duration = 0.4; // seconds
dash_attack_damage_multiplier = 1.5; // +50% damage
dash_attack_defense_penalty = 0.75; // -25% damage reduction
last_dash_direction = "";
is_dash_attacking = false;

// Player animation data based on sprite frame tags
anim_data = {
    // Idle animations (2 frames each)
    idle_down: {start: 0, length: 2},
    idle_right: {start: 2, length: 2},
    idle_left: {start: 4, length: 2},
    idle_up: {start: 6, length: 2},

    // Walk animations (4-5 frames each)
    walk_down: {start: 8, length: 4},
    walk_right: {start: 12, length: 5},
    walk_left: {start: 17, length: 5},
    walk_up: {start: 22, length: 4},

    // Dash animations (4 frames each)
    dash_down: {start: 26, length: 4},
    dash_right: {start: 30, length: 4},
    dash_left: {start: 34, length: 4},
    dash_up: {start: 38, length: 4},

    // Attack animations (4 frames each)
    attack_down: {start: 42, length: 4},
    attack_right: {start: 46, length: 4},
    attack_left: {start: 50, length: 4},
    attack_up: {start: 54, length: 4}
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

// Attack system
attack_cooldown = 0;
can_attack = true;

// Knockback system
kb_x = 0;
kb_y = 0;

// Status effects system
init_status_effects();

// Trait system
traits = [];

// Add this function to your scripts or at the bottom of Create Event:
function start_dash(_direction) {
    dash_timer = dash_duration;
    facing_dir = _direction;
    last_dash_direction = _direction;
    dash_attack_window = 0;
    dash_cooldown = dash_cooldown_time;
    play_sfx(snd_dash, 1, false);
}

// Check if player is in active combat (for companion evading behavior)
function is_in_combat() {
    return combat_timer < combat_cooldown;
}


// Torch lighting properties (functions moved to scr_lighting)
torch_active = false;
torch_time_remaining = 0;

var _torch_stats = global.item_database.torch.stats;
var _torch_burn_seconds = 60;
if (_torch_stats != undefined && variable_struct_exists(_torch_stats, "burn_time_seconds")) {
    _torch_burn_seconds = max(1, _torch_stats[$ "burn_time_seconds"]);
}
torch_duration = max(1, floor(_torch_burn_seconds * room_speed));

torch_sound_emitter = audio_emitter_create();
torch_sound_loop_instance = -1;
torch_looping = false;
