// Update depth for proper layering
depth = -y;

// Move projectile in direction
x += lengthdir_x(move_speed, direction);
y += lengthdir_y(move_speed, direction);

// Calculate distance traveled from spawn point
distance_traveled = point_distance(starting_x, starting_y, x, y);

// Update range profile if spawning code assigned a new id
if (!variable_instance_exists(self, "range_profile_id_cached")) {
    range_profile_id_cached = range_profile_id;
}

if (range_profile == undefined || range_profile_id_cached != range_profile_id) {
    range_profile = projectile_get_range_profile(range_profile_id);
    range_profile_id_cached = range_profile_id;
    max_travel_distance = range_profile.max_distance + range_profile.overshoot_buffer;
}

// Track damage multiplier based on distance
previous_damage_multiplier = current_damage_multiplier;
current_damage_multiplier = projectile_calculate_damage_multiplier(range_profile, distance_traveled);

// Check if reached max travel distance - spawn hazard and destroy
if (distance_traveled >= travel_distance && !hazard_spawned) {
    spawn_hazard_and_destroy();
    exit;
}

// Auto-destroy if beyond allowable travel distance
if (projectile_distance_should_cull(range_profile, distance_traveled)) {
    instance_destroy();
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
