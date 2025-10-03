// ============================================
// SPAWNER PARENT - Create Event
// Initialize spawner configuration and state
// ============================================

// Call parent create event to inherit persistent functionality
event_inherited();

// ========== CONFIGURATION VARIABLES ==========
// These can be overridden by child objects or set per-instance

// Spawn table: Array of {enemy_object, weight} structs
// Example: [{enemy_object: obj_orc, weight: 70}, {enemy_object: obj_burglar, weight: 30}]
spawn_table = [
    {enemy_object: obj_burglar, weight: 1}
];

// Spawn timing
spawn_period = 180; // Frames between spawn attempts (180 = 3 seconds at 60 FPS)

// Spawn mode
spawn_mode = SpawnerMode.continuous; // finite or continuous

// Spawn limits
max_total_spawns = -1;        // Maximum total enemies to spawn (-1 = unlimited, used in finite mode)
max_concurrent_enemies = 2;    // Maximum enemies alive at once

// Proximity settings
proximity_enabled = false;     // Whether to check player distance
proximity_radius = 200;        // Activation radius in pixels

// Visibility and damage
is_visible = false;            // Whether to draw the spawner sprite
is_damageable = false;         // Whether spawner can take damage
hp_total = 10;                 // Maximum health (if damageable)
hp_current = 10;               // Current health

// Audio
spawn_sound = noone;           // Sound to play when spawning (can be a sound asset)

// ========== STATE VARIABLES ==========
// These track runtime state and should not be modified directly

spawned_count = 0;             // Total enemies spawned so far
active_spawned_enemies = [];   // Array of enemy instance IDs currently alive
is_active = true;              // Whether spawner is currently active
spawn_timer = spawn_period;    // Countdown timer until next spawn
is_destroyed = false;          // Whether spawner has been destroyed

// Deactivate proximity spawners by default (they activate when player is near)
if (proximity_enabled) {
    is_active = false;
}

show_debug_message("Spawner created at (" + string(x) + ", " + string(y) + ") - Mode: " +
    (spawn_mode == SpawnerMode.finite ? "Finite" : "Continuous") +
    " | Proximity: " + (proximity_enabled ? "Yes" : "No") +
    " | Visible: " + (is_visible ? "Yes" : "No") +
    " | Damageable: " + (is_damageable ? "Yes" : "No"));

// ========== SAVE/LOAD FUNCTIONS ==========
// Override parent serialize/deserialize methods

/// @function serialize()
/// @description Serialize spawner state for saving
function serialize() {
    show_debug_message("SERIALIZING SPAWNER at (" + string(x) + ", " + string(y) + ")");

    // Serialize spawn table
    var spawn_table_data = [];
    for (var i = 0; i < array_length(spawn_table); i++) {
        var entry = spawn_table[i];
        array_push(spawn_table_data, {
            enemy_object: object_get_name(entry.enemy_object),
            weight: entry.weight
        });
    }

    return {
        object_type: object_get_name(object_index),
        x: x,
        y: y,
        persistent_id: persistent_id,

        // Configuration
        spawn_table: spawn_table_data,
        spawn_period: spawn_period,
        spawn_mode: spawn_mode,
        max_total_spawns: max_total_spawns,
        max_concurrent_enemies: max_concurrent_enemies,
        proximity_enabled: proximity_enabled,
        proximity_radius: proximity_radius,
        is_visible: is_visible,
        is_damageable: is_damageable,
        hp_total: hp_total,
        spawn_sound: (spawn_sound != noone && audio_exists(spawn_sound)) ? audio_get_name(spawn_sound) : undefined,

        // State
        spawned_count: spawned_count,
        is_active: is_active,
        is_destroyed: is_destroyed,
        hp_current: hp_current,
        spawn_timer: spawn_timer
        // Note: active_spawned_enemies is NOT saved - enemies are saved independently
    };
}

/// @function deserialize(data)
/// @description Restore spawner state from save data
function deserialize(data) {
    show_debug_message("DESERIALIZING SPAWNER at (" + string(data.x) + ", " + string(data.y) + ")");

    // Restore position
    x = data.x;
    y = data.y;

    // Restore spawn table
    spawn_table = [];
    for (var i = 0; i < array_length(data.spawn_table); i++) {
        var entry = data.spawn_table[i];
        var enemy_obj = asset_get_index(entry.enemy_object);
        if (enemy_obj != -1) {
            array_push(spawn_table, {
                enemy_object: enemy_obj,
                weight: entry.weight
            });
        }
    }

    // Restore configuration
    spawn_period = data.spawn_period;
    spawn_mode = data.spawn_mode;
    max_total_spawns = data.max_total_spawns;
    max_concurrent_enemies = data.max_concurrent_enemies;
    proximity_enabled = data.proximity_enabled;
    proximity_radius = data.proximity_radius;
    is_visible = data.is_visible;
    is_damageable = data.is_damageable;
    hp_total = data.hp_total;

    // Restore spawn sound
    if (variable_struct_exists(data, "spawn_sound") && data.spawn_sound != undefined) {
        spawn_sound = asset_get_index(data.spawn_sound);
        if (spawn_sound == -1) {
            spawn_sound = noone;
        }
    } else {
        spawn_sound = noone;
    }

    // Restore state
    spawned_count = data.spawned_count;
    is_active = data.is_active;
    is_destroyed = data.is_destroyed;
    hp_current = data.hp_current;
    spawn_timer = data.spawn_timer;

    // Reset active enemies array (will be repopulated as game runs)
    active_spawned_enemies = [];

    show_debug_message("  Restored: Spawned=" + string(spawned_count) + " Active=" + string(is_active) + " Destroyed=" + string(is_destroyed));
}
