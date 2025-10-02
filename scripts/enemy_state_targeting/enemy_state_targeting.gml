// ============================================
// ENEMY STATE: TARGETING
// Handles pathfinding and pursuit behavior
// ============================================

/// @desc Enemy targeting state - handles pathfinding and pursuit
function enemy_state_targeting() {
    if (!instance_exists(obj_player)) {
        state = EnemyState.idle;
        if (path_exists(path)) {
            path_end();
        }
        return;
    }

    var _player_x = obj_player.x;
    var _player_y = obj_player.y;
    var _dist_to_player = point_distance(x, y, _player_x, _player_y);

    // Force quicker recalculation when the player repositions sharply
    if ((abs(_player_x - last_target_x) > 24 || abs(_player_y - last_target_y) > 24) && alarm[0] > 15) {
        alarm[0] = 0;
    }

    // Lose aggro when the player is far enough away
    if (_dist_to_player > aggro_distance + 32) {
        state = EnemyState.idle;
        if (path_exists(path)) {
            path_end();
        }
        alarm[0] = 60;
        return;
    }

    // Attack gating
    if (is_ranged_attacker) {
        if (_dist_to_player <= attack_range && can_ranged_attack) {
            enemy_handle_ranged_attack();
        }
    } else {
        if (_dist_to_player <= attack_range && can_attack) {
            state = EnemyState.attacking;
            attack_cooldown = round(90 / attack_speed);
            can_attack = false;
            alarm[2] = 15; // Attack hits after 15 frames
            if (path_exists(path)) {
                path_end();
            }
            return;
        }
    }

    // Recalculate the path periodically
    if (alarm[0] <= 0) {
        var _target_pos = enemy_calculate_target_position();
        var _path_created = enemy_update_path(_target_pos.x, _target_pos.y);

        if (!_path_created) {
            if (path_exists(path)) {
                path_end();
            }
            // Fall back to short wander before retrying
            target_x = x + random_range(-48, 48);
            target_y = y + random_range(-48, 48);
            state = EnemyState.idle;
            alarm[0] = 45; // Retry pathing soon after wandering
            return;
        }

        last_target_x = _player_x;
        last_target_y = _player_y;
        alarm[0] = 120; // Next recalculation in ~2 seconds (at 60fps)
    }
}
