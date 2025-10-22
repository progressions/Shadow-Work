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

/// @function serialize()
/// @description Serialize spawner state for save system
function serialize() {
    // Convert active enemy instance IDs to persistent_ids
    var _enemy_ids = [];
    for (var i = 0; i < array_length(active_spawned_enemies); i++) {
        var _enemy = active_spawned_enemies[i];
        if (instance_exists(_enemy) && variable_instance_exists(_enemy, "persistent_id")) {
            array_push(_enemy_ids, _enemy.persistent_id);
        }
    }

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

        // Spawner-specific state
        spawned_count: spawned_count,
        active_spawned_enemy_ids: _enemy_ids,  // Array of persistent_ids
        is_active: is_active,
        spawn_timer: spawn_timer,
        is_destroyed: is_destroyed,
        hp_current: hp_current
    };

    return _struct;
}
