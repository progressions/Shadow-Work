// ============================================
// SPAWNER SYSTEM HELPERS
// Helper functions for enemy spawner functionality
// ============================================

/// @desc Select an enemy from weighted spawn table
/// @param {Array<Struct>} spawn_table Array of {enemy_object, weight} structs
/// @return {Asset.GMObject|undefined} Selected enemy object or undefined
function spawner_select_enemy(spawn_table) {
    if (!is_array(spawn_table) || array_length(spawn_table) == 0) {
        show_debug_message("WARNING: spawner_select_enemy called with invalid or empty spawn_table");
        return undefined;
    }

    // Calculate total weight (default weight = 1 if not specified)
    var total_weight = 0;
    for (var i = 0; i < array_length(spawn_table); i++) {
        var entry = spawn_table[i];
        var weight = entry[$ "weight"] ?? 1;
        total_weight += weight;
    }

    if (total_weight <= 0) {
        show_debug_message("WARNING: spawner_select_enemy - total weight is zero or negative");
        return undefined;
    }

    // Random selection based on weights
    var roll = random(total_weight);
    var cumulative = 0;

    for (var i = 0; i < array_length(spawn_table); i++) {
        var entry = spawn_table[i];
        var weight = entry[$ "weight"] ?? 1;
        cumulative += weight;

        if (roll <= cumulative) {
            return entry.enemy_object;
        }
    }

    // Fallback to first enemy (should never reach here)
    return spawn_table[0].enemy_object;
}

/// @desc Check if spawner can spawn based on all conditions
/// @param {Id.Instance} spawner The spawner instance to check
/// @return {Bool} True if spawner can spawn, false otherwise
function spawner_can_spawn(spawner) {
    with (spawner) {
        // Check if spawner is destroyed or inactive
        if (is_destroyed || !is_active) {
            return false;
        }

        // Check enemy cap - count active alive enemies
        var active_count = array_length(active_spawned_enemies);
        if (active_count >= max_concurrent_enemies) {
            return false;
        }

        // Check spawn mode limits
        if (spawn_mode == SpawnerMode.finite) {
            if (spawned_count >= max_total_spawns) {
                return false;
            }
        }

        return true;
    }
}

/// @desc Clean up dead enemy references from active_spawned_enemies array
/// @param {Id.Instance} spawner The spawner instance to clean
function spawner_cleanup_dead_enemies(spawner) {
    with (spawner) {
        var cleaned = [];
        for (var i = 0; i < array_length(active_spawned_enemies); i++) {
            var enemy_id = active_spawned_enemies[i];
            // Only keep enemies that still exist
            if (instance_exists(enemy_id)) {
                array_push(cleaned, enemy_id);
            }
        }
        active_spawned_enemies = cleaned;
    }
}

/// @desc Check distance between spawner and player for proximity activation
/// @param {Id.Instance} spawner The spawner instance
/// @return {Real} Distance to player in pixels
function spawner_check_proximity(spawner) {
    if (!instance_exists(obj_player)) {
        return -1;
    }

    with (spawner) {
        return point_distance(x, y, obj_player.x, obj_player.y);
    }
}

/// @desc Spawn an enemy from the spawner's spawn table
/// @param {Id.Instance} spawner The spawner instance
/// @return {Id.Instance} The spawned enemy instance or noone if spawn failed
function spawner_spawn_enemy(spawner) {
    with (spawner) {
        // Select enemy from weighted table
        var enemy_type = spawner_select_enemy(spawn_table);

        if (enemy_type == undefined) {
            show_debug_message("ERROR: spawner_spawn_enemy - no valid enemy selected from spawn_table");
            return noone;
        }

        // Calculate spawn position with small random offset to prevent stacking
        var spawn_x = x + random_range(-8, 8);
        var spawn_y = y + random_range(-8, 8);

        // Create enemy instance
        var enemy = instance_create_depth(spawn_x, spawn_y, depth, enemy_type);

        if (!instance_exists(enemy)) {
            show_debug_message("ERROR: spawner_spawn_enemy - failed to create enemy instance");
            return noone;
        }

        // Track the spawned enemy
        array_push(active_spawned_enemies, enemy);
        spawned_count++;

        // Play spawn sound if configured
        if (spawn_sound != noone && audio_exists(spawn_sound)) {
            play_sfx(spawn_sound, 1, 1);
        }

        // Reset spawn timer
        spawn_timer = spawn_period;

        // Check if finite spawner has reached its limit
        if (spawn_mode == SpawnerMode.finite && spawned_count >= max_total_spawns) {
            is_active = false;
        }

        show_debug_message("Spawner created enemy: " + object_get_name(enemy_type) + " (Total: " + string(spawned_count) + ")");

        return enemy;
    }
}

/// @desc Handle damage to a spawner
/// @param {Id.Instance} spawner The spawner instance
/// @param {Real} damage_amount Amount of damage to apply
function spawner_take_damage(spawner, damage_amount) {
    with (spawner) {
        if (!is_damageable || is_destroyed) {
            return;
        }

        hp_current -= damage_amount;

        show_debug_message("Spawner took " + string(damage_amount) + " damage. HP: " + string(hp_current) + "/" + string(hp_total));

        if (hp_current <= 0) {
            hp_current = 0;
            is_destroyed = true;
            is_active = false;

            show_debug_message("Spawner destroyed!");

            // Optional: Play destruction sound/effect here
            // Note: Spawned enemies are NOT affected when spawner is destroyed
        }
    }
}
