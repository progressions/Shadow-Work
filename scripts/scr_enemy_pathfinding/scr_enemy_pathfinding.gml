// ============================================
// ENEMY PATHFINDING HELPER FUNCTIONS
// ============================================

/// @desc Calculate ideal target position based on enemy archetype
/// @return {struct} {x, y} Target coordinates in room space
function enemy_calculate_target_position() {
    // If in a party, use objective target instead of player position
    if (instance_exists(party_controller)) {
        return { x: objective_target_x, y: objective_target_y };
    }

    var _player_x = obj_player.x;
    var _player_y = obj_player.y;

    // Apply approach variation (flanking behavior)
    if (approach_mode == "flanking" && flank_offset_angle != 0) {
        // Calculate base direction to player
        var base_dir = point_direction(x, y, _player_x, _player_y);

        // Apply perpendicular offset angle
        var approach_dir = base_dir + flank_offset_angle;

        // Calculate target position at offset angle (32 pixels from player)
        var approach_distance = 32;
        var target_x = _player_x + lengthdir_x(approach_distance, approach_dir);
        var target_y = _player_y + lengthdir_y(approach_distance, approach_dir);

        return { x: target_x, y: target_y };
    }

    // Direct approach: path directly to player position
    // Pathfinding grid will route around obstacles automatically
    return { x: _player_x, y: _player_y };
}

/// @desc Find a position with clear cardinal line of sight to target
/// @param {real} target_x
/// @param {real} target_y
/// @return {struct|noone} {x, y} position or noone if none found
function enemy_find_shooting_position(target_x, target_y) {
    var _controller = instance_exists(obj_pathfinding_controller) ? obj_pathfinding_controller : noone;
    if (_controller == noone) return noone;

    var _cell_size = _controller.cell_size;
    var _search_distances = [48, 80, 96, 64, 32]; // Try various distances

    // Try the 4 cardinal directions at different distances
    for (var d = 0; d < array_length(_search_distances); d++) {
        var _dist = _search_distances[d];
        var _directions = [0, 90, 180, 270]; // right, up, left, down

        for (var i = 0; i < array_length(_directions); i++) {
            var _angle = _directions[i];
            var _test_x = target_x + lengthdir_x(_dist, _angle);
            var _test_y = target_y + lengthdir_y(_dist, _angle);

            // Check if position is walkable
            var _grid_x = clamp(floor(_test_x / _cell_size), 0, _controller.horizontal_cells - 1);
            var _grid_y = clamp(floor(_test_y / _cell_size), 0, _controller.vertical_cells - 1);

            if (!mp_grid_get_cell(_controller.grid, _grid_x, _grid_y)) {
                // Check if this position has cardinal line of sight
                var _old_x = x;
                var _old_y = y;
                x = _test_x;
                y = _test_y;
                var _has_los = enemy_has_line_of_sight(target_x, target_y);
                x = _old_x;
                y = _old_y;

                if (_has_los) {
                    return { x: _test_x, y: _test_y };
                }
            }
        }
    }

    return noone;
}

/// @desc Update the active path towards the supplied target position
/// @param {real} target_x
/// @param {real} target_y
/// @return {bool} True when a path is successfully generated
function enemy_update_path(target_x, target_y) {
    if (!instance_exists(obj_pathfinding_controller)) {
        return false;
    }

    var _controller = obj_pathfinding_controller;
    var _grid = _controller.grid;

    if (_grid == -1) {
        return false;
    }

    var _cell_size = _controller.cell_size;
    var _max_cell_x = _controller.horizontal_cells - 1;
    var _max_cell_y = _controller.vertical_cells - 1;

    // Clamp target within the room bounds
    target_x = clamp(target_x, 0, room_width - 1);
    target_y = clamp(target_y, 0, room_height - 1);

    // Ensure we are not reusing a stale path resource
    if (path_exists(path)) {
        path_end();
        path_delete(path);
    }

    path = path_add();
    path_set_precision(path, 1);

    var _target_cell_x = clamp(floor(target_x / _cell_size), 0, _max_cell_x);
    var _target_cell_y = clamp(floor(target_y / _cell_size), 0, _max_cell_y);

    var _start_left = clamp(floor(bbox_left / _cell_size), 0, _max_cell_x);
    var _start_right = clamp(floor((bbox_right - 1) / _cell_size), 0, _max_cell_x);
    var _start_top = clamp(floor(bbox_top / _cell_size), 0, _max_cell_y);
    var _start_bottom = clamp(floor((bbox_bottom - 1) / _cell_size), 0, _max_cell_y);

    mp_grid_clear_rectangle(_grid, _start_left, _start_top, _start_right, _start_bottom);

    // Mark player position as obstacle to prevent overlap
    if (instance_exists(obj_player)) {
        var _player_left = clamp(floor(obj_player.bbox_left / _cell_size), 0, _max_cell_x);
        var _player_right = clamp(floor((obj_player.bbox_right - 1) / _cell_size), 0, _max_cell_x);
        var _player_top = clamp(floor(obj_player.bbox_top / _cell_size), 0, _max_cell_y);
        var _player_bottom = clamp(floor((obj_player.bbox_bottom - 1) / _cell_size), 0, _max_cell_y);

        mp_grid_add_rectangle(_grid, _player_left, _player_top, _player_right, _player_bottom);
    }

    // Mark companion positions as obstacles to prevent overlap and enable routing around them
    with (obj_companion_parent) {
        if (is_recruited && state != CompanionState.waiting) {
            var _comp_left = clamp(floor(bbox_left / _cell_size), 0, _max_cell_x);
            var _comp_right = clamp(floor((bbox_right - 1) / _cell_size), 0, _max_cell_x);
            var _comp_top = clamp(floor(bbox_top / _cell_size), 0, _max_cell_y);
            var _comp_bottom = clamp(floor((bbox_bottom - 1) / _cell_size), 0, _max_cell_y);

            mp_grid_add_rectangle(_grid, _comp_left, _comp_top, _comp_right, _comp_bottom);
        }
    }

    // If the destination cell is blocked, search nearby cells for a walkable alternative
    if (mp_grid_get_cell(_grid, _target_cell_x, _target_cell_y)) {
        var _found_open = false;

        for (var _radius = 1; _radius <= 3 && !_found_open; _radius++) {
            for (var _ox = -_radius; _ox <= _radius && !_found_open; _ox++) {
                for (var _oy = -_radius; _oy <= _radius; _oy++) {
                    var _cx = clamp(_target_cell_x + _ox, 0, _max_cell_x);
                    var _cy = clamp(_target_cell_y + _oy, 0, _max_cell_y);

                    if (!mp_grid_get_cell(_grid, _cx, _cy)) {
                        target_x = (_cx * _cell_size) + (_cell_size * 0.5);
                        target_y = (_cy * _cell_size) + (_cell_size * 0.5);
                        _target_cell_x = _cx;
                        _target_cell_y = _cy;
                        _found_open = true;
                    }
                }
            }
        }

        if (!_found_open) {
            return false;
        }
    }

    var _path_found = mp_grid_path(_grid, path, x, y, target_x, target_y, false);

    // If direct path fails, try waypoint halfway to target
    if (!_path_found) {
        var _waypoint_x = lerp(x, target_x, 0.5);
        var _waypoint_y = lerp(y, target_y, 0.5);
        _path_found = mp_grid_path(_grid, path, x, y, _waypoint_x, _waypoint_y, false);

        if (_path_found) {
            // show_debug_message("Using waypoint path to halfway point");
        }
    }

    if (_path_found) {
        current_path_target_x = target_x;
        current_path_target_y = target_y;

        var _speed_modifier = get_status_effect_modifier("speed");
        var _terrain_speed = enemy_get_terrain_speed_modifier();
        var _final_speed = move_speed * _speed_modifier * _terrain_speed;

        if (_final_speed <= 0) {
            _final_speed = max(move_speed, 0.1);
        }

        path_start(path, _final_speed, path_action_stop, true);
        return true;
    }

    return false;
}

/// @desc Check if there's a clear cardinal line of sight to the target for ranged attacks
/// @param {real} target_x
/// @param {real} target_y
/// @return {bool} True if clear cardinal line of sight exists
function enemy_has_line_of_sight(target_x, target_y) {
    var _tilemap_col = layer_tilemap_get_id("Tiles_Col");
    if (_tilemap_col == -1) return true;

    var _dx = target_x - x;
    var _dy = target_y - y;

    // Determine which cardinal direction the player is in
    var _shoot_dir = "";
    var _shoot_x = x;
    var _shoot_y = y;
    var _alignment_threshold = 16; // How close to axis player must be

    // Check if player is aligned on a cardinal axis
    if (abs(_dx) > abs(_dy)) {
        // Horizontal shot (left or right)
        if (abs(_dy) > _alignment_threshold) {
            return false; // Player not aligned on horizontal axis
        }
        _shoot_dir = (_dx > 0) ? "right" : "left";
        _shoot_y = y; // Lock to horizontal
    } else {
        // Vertical shot (up or down)
        if (abs(_dx) > _alignment_threshold) {
            return false; // Player not aligned on vertical axis
        }
        _shoot_dir = (_dy > 0) ? "down" : "up";
        _shoot_x = x; // Lock to vertical
    }

    // Check line of sight along the cardinal direction
    var _dist = point_distance(x, y, target_x, target_y);
    var _steps = ceil(_dist / 8); // Check every 8 pixels

    for (var i = 1; i < _steps; i++) {
        var _check_x = lerp(_shoot_x, target_x, i / _steps);
        var _check_y = lerp(_shoot_y, target_y, i / _steps);
        var _tile_value = tilemap_get_at_pixel(_tilemap_col, _check_x, _check_y);

        if (_tile_value != 0) {
            return false; // Blocked by wall
        }
    }

    return true; // Clear cardinal line of sight
}

/// @desc Determine movement speed bonus from terrain preferences
/// @return {real} Multiplier applied to base move speed
function enemy_get_terrain_speed_modifier() {
    if (array_length(tags) == 0) {
        return 1.0;
    }

    var _terrain = get_terrain_at_position(x, y);
    var _speed_mult = 1.0;

    if (_terrain == "water" && array_contains(tags, "aquatic")) {
        _speed_mult = 1.5;
    } else if (_terrain == "lava" && array_contains(tags, "fireborne")) {
        _speed_mult = 1.5;
    } else if (_terrain == "sand" && array_contains(tags, "sandcrawler")) {
        _speed_mult = 1.25;
    }

    return _speed_mult;
}
