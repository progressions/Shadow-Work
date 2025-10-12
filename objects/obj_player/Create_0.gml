move_speed = 1.0;

// Momentum/velocity system
velocity_x = 0;
velocity_y = 0;
acceleration = 0.3;         // How quickly we reach max speed (higher = snappier)
friction_factor = 0.9;     // Deceleration when no input (higher = more slide)
max_velocity = 1.75;         // Cap on velocity (slightly higher than move_speed for momentum feel)

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

// Terrain effects system
terrain_applied_traits = {};  // Struct: {trait_key: true/false} - tracks which terrain traits are active
current_terrain = "grass";    // String: last detected terrain type
terrain_speed_modifier = 1.0; // Real: speed multiplier from current terrain

// Combat timer for companion evading behavior
combat_timer = 999; // Start high so companions begin in following mode
combat_cooldown = 3; // Seconds of no combat before evading ends

// Critical hit system
crit_chance = 0.1;      // 10% chance to crit
crit_multiplier = 1.75; // 1.75x damage on crit
last_attack_was_crit = false; // Set by get_total_damage(), read by obj_attack

// Stun/Stagger system (crowd control)
is_stunned = false;      // Can't attack or take actions
is_staggered = false;    // Can't move
stun_timer = 0;          // Countdown in frames
stagger_timer = 0;       // Countdown in frames
stun_resistance = 0;     // 0.0 to 1.0 (can be modified by traits)
stagger_resistance = 0;  // 0.0 to 1.0 (can be modified by traits)

// Stun particle system
stun_particle_system = -1;
stun_particle_type = -1;
stun_particle_emitter = -1;

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

// Focus combat system configuration
focus_hold_duration_ms = 275; // tweakable duration for aim/retreat buffers
player_focus_init(self);
focus_state.hold_duration_ms = focus_hold_duration_ms;

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
dash_cooldown_time = 75;

// Dash attack system
dash_attack_window = 0;
dash_attack_window_duration = 0.4; // seconds
dash_attack_damage_multiplier = 1.5; // +50% damage
dash_attack_defense_penalty = 0.75; // -25% damage reduction
last_dash_direction = "";
is_dash_attacking = false;
dash_override_direction = "";

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

// Ranged attack windup system (telegraph/anticipation before projectile spawn)
// Creates visual and audio telegraph by slowing attack animation and delaying projectile spawn
ranged_windup_speed = 0.6;        // Animation speed multiplier during windup (0.1-1.0, default 0.6)
                                  // Lower values = longer telegraph. Can be modified by equipment/traits
ranged_windup_complete = false;   // Tracks if first animation cycle finished (projectile spawns when true)
ranged_windup_active = false;     // Tracks if currently winding up a ranged attack
ranged_windup_direction = "down"; // Stores direction for arrow spawn after windup

// Knockback system
kb_x = 0;
kb_y = 0;

// Status effects system
init_status_effects();

// Trait system
traits = [];

// Add this function to your scripts or at the bottom of Create Event:
function start_dash(_direction, _preserve_facing) {
    if (argument_count < 2) _preserve_facing = false;
    dash_timer = dash_duration;
    last_dash_direction = _direction;
    dash_attack_window = 0;
    dash_cooldown = dash_cooldown_time;
    dash_override_direction = "";

    if (_preserve_facing) {
        dash_override_direction = _direction;
    } else {
        facing_dir = _direction;
    }

    play_sfx(snd_dash, 1, false);
    companion_on_player_dash(id);
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
