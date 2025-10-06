// Enemy collision with companion - prevent overlap/stacking

// Only apply pushback if enemy is alive and moving
if (state == EnemyState.dead) {
    exit;
}

// Calculate pushback direction (away from companion)
var _push_dir = point_direction(other.x, other.y, x, y);
var _push_force = 2; // Pixels to push away

// Apply pushback
var _push_x = lengthdir_x(_push_force, _push_dir);
var _push_y = lengthdir_y(_push_force, _push_dir);

// Check collision with tilemap before moving
var _tilemap_col = layer_tilemap_get_id("Tiles_Col");
var _new_x = x + _push_x;
var _new_y = y + _push_y;

// Only move if not colliding with walls
if (_tilemap_col != -1) {
    var _tile_value = tilemap_get_at_pixel(_tilemap_col, _new_x, _new_y);
    if (_tile_value == 0) {
        x = _new_x;
        y = _new_y;
    }
} else {
    x = _new_x;
    y = _new_y;
}

// End current path to force recalculation on next update
if (path_exists(path)) {
    path_end();
}
