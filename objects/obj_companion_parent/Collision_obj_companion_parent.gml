// Companion collision with another companion - hop out of the way

// Only dodge if companion is following/evading (not waiting)
if (state != CompanionState.following && state != CompanionState.evading) {
    exit;
}

// Initialize companion dodge cooldown if it doesn't exist
if (!variable_instance_exists(id, "companion_dodge_cooldown")) {
    companion_dodge_cooldown = 0;
}

// Only dodge if not on cooldown
if (companion_dodge_cooldown > 0) {
    companion_dodge_cooldown--;
    exit;
}

// Calculate dodge direction (away from other companion)
var _dodge_dir = point_direction(other.x, other.y, x, y);
var _dodge_distance = 20; // Jump away 20 pixels

// Try to find a clear spot to dodge to
var _tilemap_col = layer_tilemap_get_id("Tiles_Col");
var _new_x = x + lengthdir_x(_dodge_distance, _dodge_dir);
var _new_y = y + lengthdir_y(_dodge_distance, _dodge_dir);

// Check if target position is clear
var _can_dodge = true;
if (_tilemap_col != -1) {
    var _tile_value = tilemap_get_at_pixel(_tilemap_col, _new_x, _new_y);
    if (_tile_value != 0) {
        _can_dodge = false;

        // Try perpendicular angles if straight back is blocked
        var _alt_angles = [_dodge_dir + 90, _dodge_dir - 90, _dodge_dir + 45, _dodge_dir - 45];
        for (var i = 0; i < array_length(_alt_angles); i++) {
            _new_x = x + lengthdir_x(_dodge_distance, _alt_angles[i]);
            _new_y = y + lengthdir_y(_dodge_distance, _alt_angles[i]);
            _tile_value = tilemap_get_at_pixel(_tilemap_col, _new_x, _new_y);
            if (_tile_value == 0) {
                _can_dodge = true;
                break;
            }
        }
    }
}

// Perform dodge if clear path found
if (_can_dodge) {
    x = _new_x;
    y = _new_y;

    // Set cooldown to prevent jittering (30 frames = 0.5 seconds)
    companion_dodge_cooldown = 30;

    // Reset follow position to avoid snapping back
    if (variable_instance_exists(id, "follow_x")) {
        follow_x = x;
        follow_y = y;
    }
}
