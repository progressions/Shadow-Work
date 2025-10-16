/// @function movement_profile_hazard_spawner_update(enemy)
/// @description Movement profile for hazard-spawning enemies - slow approach, stop at range, no retreat
/// @param {Id.Instance} _enemy - The enemy instance using this profile
function movement_profile_hazard_spawner_update(_enemy) {
    if (!instance_exists(_enemy)) return;

    // Get player reference
    var _player = instance_find(obj_player, 0);
    if (_player == noone) return;

    // Handle crowd control effects
    // Stunned: Can't attack or take actions (skip all logic)
    if (_enemy.is_stunned) {
        return;
    }

    // Staggered: Can't move (skip movement logic only)
    if (_enemy.is_staggered) {
        return;
    }

    // Calculate distance to player
    var _dist_to_player = point_distance(_enemy.x, _enemy.y, _player.x, _player.y);

    // Get ideal range (configured per enemy, default is attack_range)
    var _ideal_range = _enemy.ideal_range;

    // Hazard spawner behavior:
    // 1. If beyond ideal_range: Move slowly toward player
    // 2. If within ideal_range: Stop and prepare to spawn hazard
    // 3. Never retreat (unlike ranged enemies)

    if (_dist_to_player > _ideal_range) {
        // Too far - move slowly toward player
        // Apply speed multiplier for slow, deliberate approach
        var _speed_multiplier = 0.6;  // 60% of normal speed

        // Apply additional speed modifiers (status effects, terrain, companion slow)
        var _status_speed_mod = 1.0;
        with (_enemy) {
            _status_speed_mod = get_status_effect_modifier("speed");
            var _terrain_speed = enemy_get_terrain_speed_modifier();
            var _companion_slow = get_companion_enemy_slow(x, y);
            _status_speed_mod *= _terrain_speed * _companion_slow;
        }

        // Calculate final speed
        var _final_speed = _enemy.move_speed * _speed_multiplier * _status_speed_mod;

        // Update pathfinding target to player position
        // Check if we need to update path (target moved significantly or no path)
        var _path_needs_update = false;

        if (!path_exists(_enemy.path) || _enemy.path_speed == 0) {
            _path_needs_update = true;
        } else {
            // Check if player moved significantly since last path
            var _dist_to_path_target = point_distance(
                _player.x,
                _player.y,
                _enemy.current_path_target_x,
                _enemy.current_path_target_y
            );
            if (_dist_to_path_target > 64) {  // Player moved 64+ pixels
                _path_needs_update = true;
            }
        }

        if (_path_needs_update) {
            // Use existing enemy pathfinding system
            with (_enemy) {
                var _path_found = enemy_update_path(_player.x, _player.y);

                if (_path_found) {
                    current_path_target_x = _player.x;
                    current_path_target_y = _player.y;
                }
            }
        }

        // Update facing direction based on movement
        var _dx = _enemy.x - _enemy.xprevious;
        var _dy = _enemy.y - _enemy.yprevious;

        if (abs(_dx) > abs(_dy)) {
            _enemy.facing_dir = (_dx > 0) ? "right" : "left";
        } else if (abs(_dy) > 0.1) {
            _enemy.facing_dir = (_dy > 0) ? "down" : "up";
        }

    } else {
        // Within ideal range - stop and prepare hazard spawn
        // Stop pathfinding
        with (_enemy) {
            if (path_exists(path)) {
                path_end();
            }
        }

        // Update facing direction to face player
        var _angle_to_player = point_direction(_enemy.x, _enemy.y, _player.x, _player.y);

        if (_angle_to_player >= 315 || _angle_to_player < 45) {
            _enemy.facing_dir = "right";
        } else if (_angle_to_player >= 45 && _angle_to_player < 135) {
            _enemy.facing_dir = "down";
        } else if (_angle_to_player >= 135 && _angle_to_player < 225) {
            _enemy.facing_dir = "left";
        } else {
            _enemy.facing_dir = "up";
        }

        // Check conditions for hazard spawn trigger:
        // 1. Cooldown expired
        // 2. Clear line of sight to player
        // 3. Currently in targeting state (not already spawning)
        // 4. Hazard spawning is enabled

        if (_enemy.enable_hazard_spawning &&
            _enemy.hazard_spawn_cooldown_timer <= 0 &&
            _enemy.state == EnemyState.targeting &&
            enemy_has_line_of_sight(_player.x, _player.y)) {

            // All conditions met - trigger hazard spawn state
            _enemy.state = EnemyState.hazard_spawning;

            // Reset windup timer to start countdown
            _enemy.hazard_spawn_windup_timer = _enemy.hazard_spawn_windup_time;
        }
    }
}
