// ============================================
// ENEMY STATE: TARGETING
// Handles pathfinding pursuit and aggro transitions
// ============================================

function enemy_state_targeting() {
    // Use objective target if in a party, otherwise target player directly
    var _target_x = instance_exists(party_controller) ? objective_target_x : obj_player.x;
    var _target_y = instance_exists(party_controller) ? objective_target_y : obj_player.y;

    var _player_x = obj_player.x;
    var _player_y = obj_player.y;
    var _dist_to_player = point_distance(x, y, _player_x, _player_y);

    // Unstuck mode - move directly in a random direction to get around obstacle
    if (variable_instance_exists(self, "unstuck_mode") && unstuck_mode > 0) {
        if (unstuck_mode == 44) { // Only log once at start
            show_debug_message("STEP: UNSTUCK MODE ACTIVE - unstuck_mode=" + string(unstuck_mode) + " direction=" + string(unstuck_direction));
        }

        unstuck_mode--;

        var _speed_modifier = get_status_effect_modifier("speed");
        var _terrain_speed = enemy_get_terrain_speed_modifier();
        var _move_speed = move_speed * _speed_modifier * _terrain_speed * 2.0; // Move faster when unsticking

        if (_move_speed <= 0) {
            _move_speed = max(move_speed, 0.1);
        }

        var _dx = lengthdir_x(_move_speed, unstuck_direction);
        var _dy = lengthdir_y(_move_speed, unstuck_direction);

        // Just try to move with collision - don't force through walls
        move_and_collide(_dx, _dy, [tilemap, obj_enemy_parent, obj_rising_pillar, obj_player]);

        return; // Skip normal pathfinding while unsticking
    }

    // If player moved significantly and we have a long-running path, recalculate sooner
    if ((abs(_player_x - last_target_x) > 64 || abs(_player_y - last_target_y) > 64) && alarm[0] > 60) {
        show_debug_message("RESETTING ALARM: Player moved, setting alarm from " + string(alarm[0]) + " to 30");
        alarm[0] = 30; // Shorten the wait, don't immediately recalc
    }

    // Debug: check if alarm is actually frozen
    static last_alarm_value = -999;
    if (alarm[0] == 120 && last_alarm_value == 120) {
        show_debug_message("ALARM FROZEN AT 120!");
    }
    last_alarm_value = alarm[0];

    if (is_ranged_attacker) {
        if (_dist_to_player <= attack_range && can_ranged_attack) {
            var _has_los = enemy_has_line_of_sight(_player_x, _player_y);
            if (_has_los) {
                enemy_handle_ranged_attack();
            } else {
                // In range but no clear shot - force immediate path recalculation
                alarm[0] = 0;
            }
        }
    } else {
        if (_dist_to_player <= attack_range && can_attack) {
            state = EnemyState.attacking;
            attack_cooldown = round(90 / attack_speed);
            can_attack = false;
            alarm[2] = 15;
            if (path_exists(path)) {
                path_end();
            }
            return;
        }
    }

    // Don't create paths while in unstuck mode - just move directly
    if (variable_instance_exists(self, "unstuck_mode") && unstuck_mode > 0) {
        // Skip pathfinding entirely during unstuck
        return;
    }

    // Create path when alarm expires OR when we have no active path
    var _needs_path = !path_exists(path) || path_index == -1 || path_position >= 1;

    // Also check if path exists but we're not moving along it (stuck at position 0)
    if (path_index != -1 && path_position <= 0.01 && path_speed > 0) {
        // We have a path but aren't moving - path might be blocked
        if (!variable_instance_exists(self, "path_stuck_timer")) {
            path_stuck_timer = 0;
        }
        path_stuck_timer++;

        if (path_stuck_timer > 30) {
            // Stuck for half second - force new path
            show_debug_message("Path exists but not moving - forcing recalc");
            _needs_path = true;
            path_stuck_timer = 0;
        }
    } else {
        path_stuck_timer = 0;
    }

    if (alarm[0] == -1 || alarm[0] == 0 || _needs_path) {
        var _target_pos = enemy_calculate_target_position();
        var _path_created = enemy_update_path(_target_pos.x, _target_pos.y);

        last_target_x = _player_x;
        last_target_y = _player_y;

        if (!_path_created) {
            if (path_exists(path)) {
                path_end();
            }
            // Path failed - move directly toward player using simple movement
            var _speed_modifier = get_status_effect_modifier("speed");
            var _terrain_speed = enemy_get_terrain_speed_modifier();
            var _final_speed = move_speed * _speed_modifier * _terrain_speed;

            if (_final_speed <= 0) {
                _final_speed = max(move_speed, 0.1);
            }

            var _dir = point_direction(x, y, _player_x, _player_y);
            var _dx = lengthdir_x(_final_speed, _dir);
            var _dy = lengthdir_y(_final_speed, _dir);

            move_and_collide(_dx, _dy, [tilemap, obj_enemy_parent, obj_rising_pillar, obj_player]);

            // Try pathfinding again soon
            alarm[0] = 60;
            return;
        }

        // Path created successfully
        alarm[0] = 120;
    }
}
