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
state = CompanionState.not_recruited;

// Following behavior
follow_target = noone;
follow_distance = 28; // Pixels to maintain from player
follow_speed = 1.15; // Slightly slower than player base speed
min_follow_distance = 16; // Don't get closer than this

// Affinity system (1.0 to 10.0)
affinity = 1.0;
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
relationship_stage = 0; // 0=stranger, 1=acquaintance, 2=friend, 3=close, 4=romance

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
        cooldown_max: 600, // 10 seconds at 60fps
        dr_bonus: 3,
        duration: 180, // 3 seconds
        hp_threshold: 0.3 // Activate at 30% HP
    },
    dash_mend: {
        unlocked: false, // Unlocks at affinity 5+
        active: false,
        cooldown: 0,
        cooldown_max: 60,
        heal_amount: 1
    },
    aegis: {
        unlocked: false, // Unlocks at affinity 8+
        active: false,
        cooldown: 0,
        cooldown_max: 300,
        dr_bonus: 2,
        duration: 120,
        heal_amount: 2
    },
    guardian_veil: {
        unlocked: false, // Unlocks at affinity 10
        active: false,
        cooldown: 0,
        cooldown_max: 2400, // 40 seconds
        duration: 90,
        dr_bonus: 5,
        enemy_threshold: 3
    }
};

// Animation variables
image_speed = 0;
image_index = 0;
last_dir_index = 0; // 0=down, 1=right, 2=left, 3=up
// Animation uses global.idle_bob_timer for synchronized bobbing (set in obj_game_controller)

// Standard companion animation data (same for all companions)
anim_data = {
    // Idle animations (2 frames each)
    idle_down: { start: 0, length: 2 },   // frames 0-1
    idle_right: { start: 2, length: 2 },  // frames 2-3
    idle_left: { start: 4, length: 2 },   // frames 4-5
    idle_up: { start: 6, length: 2 },     // frames 6-7

    // Walk animations
    walk_down: { start: 8, length: 4 },   // frames 8-11 (4 frames)
    walk_right: { start: 12, length: 5 }, // frames 12-16 (5 frames)
    walk_left: { start: 17, length: 5 },  // frames 17-21 (5 frames)
    walk_up: { start: 22, length: 4 }     // frames 22-25 (4 frames)
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
torch_duration = max(1, floor(_torch_burn_seconds * room_speed));
torch_light_radius = (_torch_stats != undefined && variable_struct_exists(_torch_stats, "light_radius"))
    ? _torch_stats[$ "light_radius"]
    : 100;

torch_sound_emitter = audio_emitter_create();
torch_sound_loop_instance = -1;
torch_looping = false;

function companion_play_torch_sfx(_asset_name) {
    var _sound = asset_get_index(_asset_name);
    if (_sound != -1) {
        play_sfx(_sound, 1, false);
    }
}

function companion_start_torch_loop() {
    if (!audio_emitter_exists(torch_sound_emitter)) {
        torch_sound_emitter = audio_emitter_create();
    }

    if (torch_looping) return;

    var _loop_sound = asset_get_index("snd_torch_burning_loop");
    if (_loop_sound != -1) {
        audio_emitter_position(torch_sound_emitter, x, y, 0);
        torch_sound_loop_instance = audio_play_sound_on(torch_sound_emitter, _loop_sound, 0, true);
        torch_looping = true;
    }
}

function companion_stop_torch_loop() {
    if (torch_sound_loop_instance != -1) {
        audio_stop_sound(torch_sound_loop_instance);
        torch_sound_loop_instance = -1;
    }
    torch_looping = false;
}

function companion_take_torch_from_player(_time_remaining, _light_radius) {
    carrying_torch = true;

    if (_time_remaining <= 0) {
        torch_time_remaining = torch_duration;
    } else {
        torch_time_remaining = clamp(_time_remaining, 1, torch_duration);
    }

    if (_light_radius != undefined) {
        torch_light_radius = _light_radius;
    } else {
        var _torch_stats = global.item_database.torch.stats;
        if (_torch_stats != undefined && variable_struct_exists(_torch_stats, "light_radius")) {
            torch_light_radius = _torch_stats[$ "light_radius"];
        }
    }

    companion_play_torch_sfx("snd_torch_equip");
    companion_start_torch_loop();

    if (audio_emitter_exists(torch_sound_emitter)) {
        audio_emitter_position(torch_sound_emitter, x, y, 0);
    }

    set_torch_carrier(companion_id);
}

function companion_handle_torch_burnout() {
    companion_play_torch_sfx("snd_torch_burnout");
    companion_stop_torch_loop();
    carrying_torch = false;
    torch_time_remaining = 0;
    set_torch_carrier("none");

    var _player = instance_find(obj_player, 0);
    if (_player != noone) {
        with (_player) {
            if (player_supply_companion_torch()) {
                other.companion_take_torch_from_player(other.torch_duration, undefined);
                return;
            }
        }
    }

    companion_stop_torch_loop();
}

function companion_update_torch_state() {
    if (carrying_torch) {
        if (audio_emitter_exists(torch_sound_emitter)) {
            audio_emitter_position(torch_sound_emitter, x, y, 0);
        }

        torch_time_remaining = max(0, torch_time_remaining - 1);

        if (torch_time_remaining <= 0) {
            companion_handle_torch_burnout();
        }
    } else {
        companion_stop_torch_loop();
    }
}

function companion_give_torch_to_player() {
    if (!carrying_torch) return false;

    var _player = instance_find(obj_player, 0);
    if (_player == noone) return false;

    var _can_receive = false;
    with (_player) {
        _can_receive = player_can_receive_torch();
    }

    if (!_can_receive) {
        return false;
    }

    var _remaining = torch_time_remaining;
    var _radius = torch_light_radius;

    companion_stop_torch_loop();
    carrying_torch = false;
    torch_time_remaining = 0;

    var _accepted = false;
    with (_player) {
        other._torch_transfer_temp = player_receive_torch_from_companion(_remaining, _radius);
    }

    _accepted = _torch_transfer_temp;
    _torch_transfer_temp = undefined;

    if (!_accepted) {
        // Player couldn't take it, resume holding the torch
        companion_take_torch_from_player(_remaining, _radius);
        return false;
    }

    set_torch_carrier("player");

    return true;
}

/// @function can_interact()
/// @description Override - companion can only be interacted with when not recruited
function can_interact() {
    return !is_recruited;  // Only interactable when not recruited
}

/// @function on_interact()
/// @description Override - start VN dialogue with companion (recruitment only)
function on_interact() {
    // Trigger VN dialogue system (only for recruitment)
    if (instance_exists(obj_player) && !is_recruited) {
        start_vn_dialogue(id, companion_id + ".yarn", "Start");
    }
}

// Persistent so companions persist across room changes
persistent = true;
