// Update depth for proper layering
depth = -y;

// Move projectile in direction
x += lengthdir_x(move_speed, direction);
y += lengthdir_y(move_speed, direction);

// Calculate distance traveled from spawn point
distance_traveled = point_distance(starting_x, starting_y, x, y);

// Check if reached max travel distance - spawn hazard and destroy
if (distance_traveled >= travel_distance && !hazard_spawned) {
    spawn_hazard_and_destroy();
    exit;
}

// Check for collision with Tiles_Col layer (walls/obstacles)
var _tilemap_col = layer_tilemap_get_id("Tiles_Col");
if (_tilemap_col != -1) {
    var _tile_value = tilemap_get_at_pixel(_tilemap_col, x, y);
    if (_tile_value != 0) {
        // Hit a wall - spawn hazard at collision point
        if (!hazard_spawned) {
            spawn_hazard_and_destroy();
        }
        exit;
    }
}

// Check if projectile is out of room bounds
if (x < -32 || x > room_width + 32 || y < -32 || y > room_height + 32) {
    // Out of bounds - just destroy without spawning hazard
    instance_destroy();
    exit;
}

/// @function spawn_hazard_and_destroy
/// @description Spawns explosion (if enabled), then hazard, then destroys projectile
function spawn_hazard_and_destroy() {
    hazard_spawned = true;

    // Spawn explosion first (if enabled)
    if (explosion_enabled && object_exists(explosion_object)) {
        var _explosion = instance_create_depth(x, y, depth - 1, explosion_object);

        if (instance_exists(_explosion)) {
            // Pass damage configuration to explosion
            _explosion.damage_amount = explosion_damage;
            _explosion.damage_type = explosion_damage_type;
            _explosion.creator = creator;
        }
    }

    // Spawn the hazard object at current position (use depth instead of layer)
    if (object_exists(hazard_object)) {
        var _hazard = instance_create_depth(x, y, depth, hazard_object);

        // Pass creator information to hazard for damage attribution
        if (instance_exists(_hazard) && variable_instance_exists(_hazard, "creator")) {
            _hazard.creator = creator;
        }

        // Optional: Pass damage type to hazard if it supports it
        if (instance_exists(_hazard) && variable_instance_exists(_hazard, "damage_type")) {
            _hazard.damage_type = damage_type;
        }

        // Pass lifetime to hazard if configured
        if (instance_exists(_hazard) && hazard_lifetime > 0) {
            // Set alarm to destroy hazard after lifetime (convert seconds to frames)
            _hazard.alarm[0] = hazard_lifetime * 60;  // 60 fps
        }
    }

    // Play landing sound effect (optional - can be customized)
    if (audio_exists(snd_bump)) {
        play_sfx(snd_bump, 0.8, false);
    }

    // Destroy the projectile
    instance_destroy();
}
