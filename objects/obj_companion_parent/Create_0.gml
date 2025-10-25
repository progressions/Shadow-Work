// Companion Parent Create Event
// Base object for all companion NPCs

// Call parent create event (obj_interactable_parent)
event_inherited();

// Override interaction properties
interaction_priority = 100;  // Highest priority - companions should be selected over objects
interaction_radius = 32;
interaction_key = "Space";
// interaction_action set dynamically in Step event based on recruitment state

// Get tilemap for collision detection
tilemap = layer_tilemap_get_id("Tiles_Col");

// Identity
companion_id = "undefined"; // Override in child objects
companion_name = "Companion"; // Override in child objects

// Recruitment & State
is_recruited = false;
state = CompanionState.waiting;

// Following behavior
follow_target = noone;
follow_distance = 28; // Pixels to maintain from player
follow_speed = 1.15; // Slightly slower than player base speed
min_follow_distance = 16; // Don't get closer than this
follow_x = x; // Cached follow position
follow_y = y;

// Evading behavior (for combat evasion)
evade_distance_min = 64; // Minimum distance from player/enemies when evading
evade_distance_max = 128; // Maximum distance for visibility when evading
evade_detection_radius = 200; // Range to detect enemies to avoid
evade_recalc_timer = 0; // Timer for throttling pathfinding recalculation
evade_recalc_interval = 20; // Frames between recalculations (20 frames = ~333ms at 60fps)
evade_target_x = x; // Cached evasion target position
evade_target_y = y;
companion_dodge_cooldown = 0; // Cooldown timer for companion collision avoidance

// Pathfinding (for following behavior that avoids hazards)
companion_path = path_add();
current_waypoint = 0;
path_recalc_timer = 0;
path_recalc_interval = 60; // Frames between path updates (1 second)
last_target_x = 0;
last_target_y = 0;

// Trigger sound defaults
sfx_trigger_sound = noone;

// Affinity system (3.0 to 10.0)
affinity = 3.0;
affinity_max = 10.0;

// Quest flags for future story expansion
quest_flags = {
    met_player: false,
    first_conversation: false,
    romantic_quest_unlocked: false,
    romantic_quest_complete: false,
    adventure_quest_active: false,
    adventure_quest_complete: false
};

// Dialogue state
dialogue_history = [];

// Auras (passive bonuses) - override in child objects
auras = {
    protective: { active: false, dr_bonus: 0 },
    regeneration: { active: false, hp_per_tick: 0, tick_interval: 180 }
};

// Triggers (active abilities) - override in child objects
triggers = {
    shield: {
        unlocked: true,  // Unlocked at affinity 0+
        active: false,
        cooldown: 0,
        cooldown_max: 1200, // 20 seconds at 60fps (doubled)
        dr_bonus: 3,
        duration: 180, // 3 seconds
        hp_threshold: 0.3, // Activate at 30% HP
        sfx_trigger_sound: noone
    },
    dash_mend: {
        unlocked: false, // Unlocks at affinity 5+
        active: false,
        cooldown: 0,
        cooldown_max: 120, // doubled to 2 seconds
        heal_amount: 1,
        sfx_trigger_sound: noone
    },
    aegis: {
        unlocked: false, // Unlocks at affinity 8+
        active: false,
        cooldown: 0,
        cooldown_max: 600, // doubled to 10 seconds
        dr_bonus: 2,
        duration: 120,
        heal_amount: 2,
        sfx_trigger_sound: noone
    },
    guardian_veil: {
        unlocked: false, // Unlocks at affinity 10
        active: false,
        cooldown: 0,
        cooldown_max: 4800, // 80 seconds (doubled)
        duration: 90,
        dr_bonus: 5,
        enemy_threshold: 3,
        sfx_trigger_sound: noone
    }
};

// Animation variables
image_speed = 0;
image_index = 0;
last_dir_index = 0; // 0=down, 1=right, 2=left, 3=up
// Animation uses global.idle_bob_timer for synchronized bobbing (set in obj_game_controller)

// Casting animation variables
casting_frame_index = 0;        // Current frame in casting animation (0-2)
casting_animation_speed = 21;   // Frames to hold each animation frame (200ms at 60fps)
casting_timer = 0;              // Timer for frame advancement
previous_state = CompanionState.waiting; // State to return to after casting

// Standard companion animation data (18 frames - all companions use this structure)
// Based on companions-casting.json frame tags
anim_data = {
    // Idle animations (2 frames each)
    idle_down: { start: 0, length: 2 },   // frames 0-1 (down-right)
    idle_right: { start: 0, length: 2 },  // frames 0-1 (down-right, same as down)
    idle_left: { start: 2, length: 2 },   // frames 2-3
    idle_up: { start: 4, length: 2 },     // frames 4-5

    // Walk animations - no separate walk frames, use idle frames
    walk_down: { start: 0, length: 2 },   // frames 0-1 (use idle)
    walk_right: { start: 0, length: 2 },  // frames 0-1 (use idle)
    walk_left: { start: 2, length: 2 },   // frames 2-3 (use idle)
    walk_up: { start: 4, length: 2 },     // frames 4-5 (use idle)

    // Casting animations (3 frames each)
    casting_down: { start: 6, length: 3 },   // frames 6-8
    casting_right: { start: 9, length: 3 },  // frames 9-11
    casting_left: { start: 12, length: 3 },  // frames 12-14
    casting_up: { start: 15, length: 3 }     // frames 15-17
};

// Movement tracking
move_dir_x = 0;
move_dir_y = 0;
target_x = x;
target_y = y;

// Teleport system - if too far from player for too long, teleport to them
teleport_distance_threshold = 100; // If farther than this
teleport_time_threshold = 90;      // For this many frames (1.5 seconds at 60fps)
time_far_from_player = 0;

// Torch lighting state
carrying_torch = false;
torch_time_remaining = 0;

// Interaction prompt tracking
interaction_prompt = noone;

var _torch_stats = global.item_database.torch.stats;
var _torch_burn_seconds = 60;
if (_torch_stats != undefined && variable_struct_exists(_torch_stats, "burn_time_seconds")) {
    _torch_burn_seconds = max(1, _torch_stats[$ "burn_time_seconds"]);
}
torch_duration = max(1, floor(_torch_burn_seconds * game_get_speed(gamespeed_fps)));
torch_light_radius = (_torch_stats != undefined && variable_struct_exists(_torch_stats, "light_radius"))
    ? _torch_stats[$ "light_radius"]
    : 100;

torch_looping = false;


/// @function can_interact()
function can_interact() {
    return !is_recruited;  // Only interactable when not recruited
}

/// @function on_interact()
function on_interact() {
    // Trigger VN dialogue system (only for recruitment)
    if (instance_exists(obj_player) && !is_recruited) {
        // Action tracker: talked to NPC/companion (use specific action name)
        action_tracker_log("npc_interaction_" + companion_id);
        start_vn_dialogue(id, companion_id + ".yarn", "Start");
    }
}


// Persistent so companions persist across room changes
persistent = true;

function serialize() {
    var _struct = {
        // Base persistent_parent fields
        object_type: object_get_name(object_index),
        persistent_id: persistent_id,
        x: x,
        y: y,
        room_name: room_get_name(room),
        sprite_index: sprite_get_name(sprite_index),
        image_index: image_index,
        image_xscale: image_xscale,
        image_yscale: image_yscale,
		last_dir_index: last_dir_index,
		
		companion_name: companion_name,
		companion_id: companion_id,

        // Companion-specific fields
        is_recruited: is_recruited,
        affinity: affinity,
        quest_flags: quest_flags,
		triggers: triggers,
		auras: auras,
		carrying_torch: carrying_torch,
		torch_duration: torch_duration;
		torch_looping: torch_looping;
    };

    return _struct;
}

function deserialize(_obj_data) {
	x = _obj_data[$ "x"];
	y = _obj_data[$ "y"];
	last_dir_index = _obj_data[$ "last_dir_index"];
	
	is_recruited = _obj_data[$ "is_recruited"];
	affinity = _obj_data[$ "affinity"];
	quest_flags = _obj_data[$ "quest_flags"];
	triggers = _obj_data[$ "triggers"];
	auras = _obj_data[$ "auras"];
	
	carrying_torch = _obj_data[$ "carrying_torch"];
	torch_duration = _obj_data[$ "torch_duration"];
	torch_looping = _obj_data[$ "torch_looping"];
}