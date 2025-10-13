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

    if (audio_exists(snd_torch_burning_loop)) {
        audio_emitter_position(torch_sound_emitter, x, y, 0);
        torch_sound_loop_instance = audio_play_sound_on(torch_sound_emitter, snd_torch_burning_loop, 0, true);
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

/// @function evade_from_combat()
/// @description Calculate and move to evasion position during combat
function evade_from_combat() {
    if (!instance_exists(follow_target)) return;

    // Throttle pathfinding recalculation
    evade_recalc_timer++;

    if (evade_recalc_timer >= evade_recalc_interval) {
        evade_recalc_timer = 0;

        // Calculate avoidance vector from player
        var avoid_x = x - follow_target.x;
        var avoid_y = y - follow_target.y;

        // Find nearby enemies to avoid
        var nearby_enemies = ds_list_create();
        collision_circle_list(x, y, evade_detection_radius, obj_enemy_parent, false, true, nearby_enemies, false);

        // Add enemy avoidance vectors
        for (var i = 0; i < ds_list_size(nearby_enemies); i++) {
            var enemy = nearby_enemies[| i];
            if (instance_exists(enemy) && enemy.state != EnemyState.dead) {
                var enemy_avoid_x = x - enemy.x;
                var enemy_avoid_y = y - enemy.y;
                avoid_x += enemy_avoid_x;
                avoid_y += enemy_avoid_y;
            }
        }
        ds_list_destroy(nearby_enemies);

        // Calculate target evasion position
        var avoid_dir = point_direction(0, 0, avoid_x, avoid_y);
        var target_dist = evade_distance_min + ((evade_distance_max - evade_distance_min) / 2);

        // Set cached target position
        evade_target_x = follow_target.x + lengthdir_x(target_dist, avoid_dir);
        evade_target_y = follow_target.y + lengthdir_y(target_dist, avoid_dir);
    }

    // Check current distance from player
    var dist_from_player = point_distance(x, y, follow_target.x, follow_target.y);

    // Move toward cached evasion position if not at proper distance
    if (dist_from_player < evade_distance_min || dist_from_player > evade_distance_max) {
        var move_dir = point_direction(x, y, evade_target_x, evade_target_y);
        var move_x = lengthdir_x(follow_speed, move_dir);
        var move_y = lengthdir_y(follow_speed, move_dir);

        move_dir_x = move_x;
        move_dir_y = move_y;

        // Store position before move to detect if stuck
        var old_x = x;
        var old_y = y;

        // Move with collision detection
        move_and_collide(move_x, move_y, [tilemap, obj_rising_pillar, obj_companion_parent]);

        // Edge case: If completely stuck (didn't move), try moving perpendicular
        if (x == old_x && y == old_y && (abs(move_x) > 0.1 || abs(move_y) > 0.1)) {
            var perp_dir = move_dir + 90;
            var perp_x = lengthdir_x(follow_speed, perp_dir);
            var perp_y = lengthdir_y(follow_speed, perp_dir);
            move_and_collide(perp_x, perp_y, [tilemap, obj_rising_pillar, obj_companion_parent]);
        }
    } else {
        // At proper distance, stay idle
        move_dir_x = 0;
        move_dir_y = 0;
    }
}

/// @function companion_update_path()
/// @description Calculate pathfinding path that avoids hazardous terrain
function companion_update_path() {
    if (!instance_exists(follow_target)) return false;
    if (!instance_exists(obj_pathfinding_controller)) return false;

    var _controller = obj_pathfinding_controller;
    var _grid = _controller.grid;
    if (_grid == -1) return false;

    // Clear grid to base state (obstacles only, no hazards yet)
    mp_grid_clear_all(_grid);

    // Add collision tilemap obstacles
    if (tilemap != -1) {
        for (var i = 0; i < _controller.horizontal_cells; i++) {
            for (var j = 0; j < _controller.vertical_cells; j++) {
                var tile_data = tilemap_get(tilemap, i, j);
                if (tile_data != 0) {
                    mp_grid_add_cell(_grid, i, j);
                }
            }
        }
    }

    // Add object obstacles
    mp_grid_add_instances(_grid, obj_rising_pillar, true);

    // Mark hazardous terrain as obstacles (companions always avoid hazards, no immunity)
    var _cell_size = _controller.cell_size;
    var _grid_width = _controller.horizontal_cells;
    var _grid_height = _controller.vertical_cells;

    for (var _gx = 0; _gx < _grid_width; _gx++) {
        for (var _gy = 0; _gy < _grid_height; _gy++) {
            var _world_x = _gx * _cell_size + _cell_size / 2;
            var _world_y = _gy * _cell_size + _cell_size / 2;

            var _terrain = get_terrain_at_position(_world_x, _world_y);
            var _terrain_data = global.terrain_effects_map[$ _terrain];

            if (_terrain_data != undefined && _terrain_data.is_hazard) {
                mp_grid_add_cell(_grid, _gx, _gy);
            }
        }
    }

    // Calculate path from companion to player
    path_clear_points(companion_path);
    var _path_found = mp_grid_path(_grid, companion_path, x, y, follow_target.x, follow_target.y, false);

    if (_path_found) {
        current_waypoint = 0;
        return true;
    }

    return false;
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
