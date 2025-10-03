// ============================================
// ENEMY LOOT SYSTEM
// Weighted loot table system for enemy item drops
// ============================================

/// @desc Select an item from weighted loot table
/// @param {Array<Struct>} loot_table Array of {item_key, weight} structs
/// @return {String|undefined} Selected item key from global.item_database
function select_weighted_loot_item(loot_table) {
    if (!is_array(loot_table) || array_length(loot_table) == 0) {
        return undefined;
    }

    // Calculate total weight (default weight = 1 if not specified)
    var total_weight = 0;
    for (var i = 0; i < array_length(loot_table); i++) {
        var entry = loot_table[i];
        var weight = entry[$ "weight"] ?? 1;
        total_weight += weight;
    }

    if (total_weight <= 0) {
        return undefined;
    }

    // Random selection based on weights
    var roll = random(total_weight);
    var cumulative = 0;

    for (var i = 0; i < array_length(loot_table); i++) {
        var entry = loot_table[i];
        var weight = entry[$ "weight"] ?? 1;
        cumulative += weight;

        if (roll <= cumulative) {
            return entry.item_key;
        }
    }

    // Fallback to first item (should never reach here)
    return loot_table[0].item_key;
}

/// @desc Find valid spawn position for dropped loot
/// @param {Real} origin_x Enemy x position
/// @param {Real} origin_y Enemy y position
/// @return {Struct|noone} {x, y} position or noone if no valid position found
function find_loot_spawn_position(origin_x, origin_y) {
    var scatter_distance = 16;
    var max_attempts = 8;
    var tilemap = layer_tilemap_get_id("Tiles_Col");

    for (var attempt = 0; attempt < max_attempts; attempt++) {
        var angle = random(360);
        var test_x = origin_x + lengthdir_x(scatter_distance, angle);
        var test_y = origin_y + lengthdir_y(scatter_distance, angle);

        // Check if position is within room bounds
        if (test_x < 0 || test_x >= room_width || test_y < 0 || test_y >= room_height) {
            continue;
        }

        // Check collision tilemap
        if (tilemap != -1) {
            var tile_value = tilemap_get_at_pixel(tilemap, test_x, test_y);
            if (tile_value != 0) {
                continue; // Blocked tile
            }
        }

        // Check for collisions with solid objects
        if (place_meeting(test_x, test_y, obj_rising_pillar) ||
            place_meeting(test_x, test_y, obj_companion_parent)) {
            continue; // Object blocking
        }

        // Valid position found
        return {x: test_x, y: test_y};
    }

    // Fallback to enemy position if no valid scatter position found
    return {x: origin_x, y: origin_y};
}

/// @desc Roll for loot drop and spawn item if successful
/// @param {Id.Instance} enemy The enemy instance that died
function enemy_drop_loot(enemy) {
    // Check if enemy has loot table
    if (!variable_instance_exists(enemy, "loot_table") ||
        !is_array(enemy.loot_table) ||
        array_length(enemy.loot_table) == 0) {
        return; // No loot table configured
    }

    // Ensure drop_chance exists (default 30%)
    if (!variable_instance_exists(enemy, "drop_chance")) {
        enemy.drop_chance = 0.3;
    }

    // Roll for drop chance
    if (random(1) > enemy.drop_chance) {
        show_debug_message("Enemy loot roll failed (drop_chance: " + string(enemy.drop_chance) + ")");
        return; // No drop this time
    }

    // Select item from weighted loot table
    var selected_item_key = select_weighted_loot_item(enemy.loot_table);

    if (selected_item_key == undefined) {
        show_debug_message("Failed to select item from loot table");
        return; // Failed to select item
    }

    // Verify item exists in database
    if (!variable_struct_exists(global.item_database, selected_item_key)) {
        show_debug_message("Item key '" + selected_item_key + "' not found in global.item_database");
        return;
    }

    // Find valid spawn position
    var spawn_pos = find_loot_spawn_position(enemy.x, enemy.y);

    if (spawn_pos != noone) {
        spawn_item(spawn_pos.x, spawn_pos.y, selected_item_key);
        show_debug_message("Dropped loot: " + selected_item_key + " at (" + string(spawn_pos.x) + ", " + string(spawn_pos.y) + ")");

        // Play loot drop sound if it exists
        if (audio_exists(snd_loot_drop)) {
            play_sfx(snd_loot_drop, 0.5, false);
        }
    } else {
        show_debug_message("Failed to find valid spawn position for loot");
    }
}
