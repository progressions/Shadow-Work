// ============================================
// ENEMY PATHFINDING HELPER FUNCTIONS
// ============================================

/// @desc Calculate ideal target position based on enemy archetype
/// @return {struct} {x, y} Target coordinates in room space
function enemy_calculate_target_position() {
    if (!instance_exists(obj_player)) {
        return { x: x, y: y };
    }

    var _player_x = obj_player.x;
    var _player_y = obj_player.y;

    // Melee enemies pursue the player directly
    if (!is_ranged_attacker) {
        return { x: _player_x, y: _player_y };
    }

    var _distance = point_distance(x, y, _player_x, _player_y);
    var _target_distance = ideal_range;

    // Adjust distance to maintain a comfortable firing window
    if (_distance < ideal_range - 20) {
        _target_distance = ideal_range + 20;
    } else if (_distance > ideal_range + 20) {
        _target_distance = max(ideal_range - 20, 16);
    } else {
        // In preferred range — attempt a perpendicular circle strafe
        var _angle_to_player = point_direction(x, y, _player_x, _player_y);
        if (!variable_instance_exists(self, "strafe_direction")) {
            strafe_direction = choose(-90, 90);
        }

        var _controller = instance_exists(obj_pathfinding_controller) ? obj_pathfinding_controller : noone;

        if (_controller != noone) {
            var _cell_size = _controller.cell_size;

            for (var _attempt = 0; _attempt < 2; _attempt++) {
                var _strafe_angle = _angle_to_player + strafe_direction;
                var _strafe_x = _player_x + lengthdir_x(ideal_range, _strafe_angle);
                var _strafe_y = _player_y + lengthdir_y(ideal_range, _strafe_angle);
                var _grid_x = clamp(floor(_strafe_x / _cell_size), 0, _controller.horizontal_cells - 1);
                var _grid_y = clamp(floor(_strafe_y / _cell_size), 0, _controller.vertical_cells - 1);

                if (!mp_grid_get_cell(_controller.grid, _grid_x, _grid_y)) {
                    return { x: _strafe_x, y: _strafe_y };
                }

                // Flip direction and retry if blocked
                strafe_direction = -strafe_direction;
            }
        }

        // Fallback: mirror player vector to maintain arc distance
        return {
            x: _player_x + lengthdir_x(ideal_range, _angle_to_player),
            y: _player_y + lengthdir_y(ideal_range, _angle_to_player)
        };
    }

    var _angle_from_player = point_direction(_player_x, _player_y, x, y);

    return {
        x: _player_x + lengthdir_x(_target_distance, _angle_from_player),
        y: _player_y + lengthdir_y(_target_distance, _angle_from_player)
    };
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
