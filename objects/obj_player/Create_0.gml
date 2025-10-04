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
is_dashing = false;
dash_duration = 8;  // frames
dash_timer = 0;
dash_speed = 6;

dash_cooldown = 0;
dash_cooldown_time = 30;

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
    is_dashing = true;
    dash_timer = dash_duration;
    facing_dir = _direction;
    dash_cooldown = dash_cooldown_time;
    play_sfx(snd_dash, 1, false);
}


// Torch lighting properties and helpers
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

function player_play_torch_sfx(_asset_name) {
    var _sound = asset_get_index(_asset_name);
    if (_sound != -1) {
        play_sfx(_sound, 1, false);
    }
}

function player_start_torch_loop() {
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

function player_stop_torch_loop() {
    if (torch_sound_loop_instance != -1) {
        audio_stop_sound(torch_sound_loop_instance);
        torch_sound_loop_instance = -1;
    }
    torch_looping = false;
}

function player_supply_companion_torch() {
    return inventory_consume_item_id("torch", 1);
}

function player_has_torch_in_inventory() {
    return inventory_has_item_id("torch");
}

function player_has_equipped_torch() {
    if (equipped.left_hand != undefined && equipped.left_hand.definition != undefined) {
        return (equipped.left_hand.definition.item_id == "torch");
    }
    return false;
}

function player_get_torch_light_radius() {
    var _radius = 100;

    if (equipped.left_hand != undefined) {
        var _def = equipped.left_hand.definition;
        if (_def != undefined) {
            var _stats = _def.stats;
            if (_stats != undefined && variable_struct_exists(_stats, "light_radius")) {
                _radius = _stats[$ "light_radius"];
            }
        }
    }

    if (_radius <= 0) {
        var _torch_stats = global.item_database.torch.stats;
        if (_torch_stats != undefined && variable_struct_exists(_torch_stats, "light_radius")) {
            _radius = _torch_stats[$ "light_radius"];
        }
    }

    return max(0, _radius);
}

function player_remove_torch_from_loadouts() {
    if (equipped.left_hand != undefined && equipped.left_hand.definition != undefined && equipped.left_hand.definition.item_id == "torch") {
        equipped.left_hand = undefined;
    }

    if (is_struct(loadouts)) {
        var _loadout_keys = variable_struct_get_names(loadouts);
        for (var _li = 0; _li < array_length(_loadout_keys); _li++) {
            var _key = _loadout_keys[_li];
            if (_key == "active") continue;

            var _loadout_struct = loadouts[$ _key];
            if (!is_struct(_loadout_struct)) continue;
            if (!variable_struct_exists(_loadout_struct, "left_hand")) continue;

            var _left_entry = _loadout_struct.left_hand;
            if (_left_entry != undefined && _left_entry.definition != undefined && _left_entry.definition.item_id == "torch") {
                _loadout_struct.left_hand = undefined;
            }
        }
    }
}

function player_can_receive_torch() {
    if (equipped.left_hand != undefined) return false;

    if (equipped.right_hand != undefined) {
        var _right_def = equipped.right_hand.definition;
        if (_right_def != undefined && _right_def.handedness == WeaponHandedness.two_handed) {
            return false;
        }
    }

    return true;
}

function player_receive_torch_from_companion(_time_remaining, _light_radius) {
    if (!player_can_receive_torch()) return false;

    player_stop_torch_loop();

    var _torch_def = global.item_database.torch;
    if (_torch_def == undefined) return false;

    var _entry = {
        definition: _torch_def,
        count: 1,
        durability: 100
    };

    equipped.left_hand = _entry;

    var _active_key = loadouts_get_active_key();
    if (_active_key != undefined) {
        var _struct = loadouts_get_struct(_active_key);
        if (_struct != undefined) {
            _struct.left_hand = _entry;
        }
    }

    torch_active = true;
    torch_time_remaining = clamp(_time_remaining, 1, torch_duration);

    player_play_torch_sfx("snd_torch_equip");
    player_start_torch_loop();
    set_torch_carrier("player");

    return true;
}

function player_handle_torch_burnout() {
    player_play_torch_sfx("snd_torch_burnout");
    player_stop_torch_loop();
    player_remove_torch_from_loadouts();

    torch_active = false;
    torch_time_remaining = 0;
    set_torch_carrier("none");

    var _inventory_index = inventory_find_item_id("torch");
    if (_inventory_index != -1) {
        if (equip_item(_inventory_index, "left_hand")) {
            torch_active = true;
            torch_time_remaining = torch_duration;
            player_play_torch_sfx("snd_torch_equip");
            player_start_torch_loop();
            set_torch_carrier("player");
        }
    }
}

function player_update_torch_state() {
    var _torch_equipped = false;
    if (equipped.left_hand != undefined) {
        var _def = equipped.left_hand.definition;
        if (_def != undefined && _def.item_id == "torch") {
            _torch_equipped = true;
        }
    }

    if (_torch_equipped) {
        if (!torch_active) {
            torch_active = true;
            if (torch_time_remaining <= 0) {
                torch_time_remaining = torch_duration;
            }
            player_play_torch_sfx("snd_torch_equip");
            set_torch_carrier("player");
        }

        player_start_torch_loop();

        if (audio_emitter_exists(torch_sound_emitter)) {
            audio_emitter_position(torch_sound_emitter, x, y, 0);
        }

        torch_time_remaining = max(0, torch_time_remaining - 1);

        if (torch_time_remaining <= 0) {
            player_handle_torch_burnout();
        }
    } else if (torch_active) {
        torch_active = false;
        torch_time_remaining = 0;
        player_stop_torch_loop();
        set_torch_carrier("none");
    }
}
