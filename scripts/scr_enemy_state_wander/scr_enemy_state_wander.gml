// ============================================
// ENEMY STATE: WANDER
// Roams locally without pathfinding and re-aggros when player is nearby
// ============================================

function enemy_state_wander() {
    // Ensure any leftover paths are halted while wandering
    if (path_exists(path) && path_index != -1) {
        path_end();
    }
    path_speed = 0;

    // Immediate aggro detection without waiting for alarm window
    if (instance_exists(obj_player)) {
        var _player_distance = point_distance(x, y, obj_player.x, obj_player.y);
        if (_player_distance <= aggro_distance) {
            state = EnemyState.targeting;
            play_enemy_sfx("on_aggro");
            alarm[0] = 1;
            return;
        }
    }

    var _center_x = variable_instance_exists(self, "wander_center_x") ? wander_center_x : xstart;
    var _center_y = variable_instance_exists(self, "wander_center_y") ? wander_center_y : ystart;
    var _radius = variable_instance_exists(self, "wander_radius") ? wander_radius : 100;

    // Nudge back toward the home center if we drift too far
    var _distance_from_center = point_distance(x, y, _center_x, _center_y);
    if (_distance_from_center > _radius * 1.25) {
        target_x = _center_x;
        target_y = _center_y;
        if (alarm[0] > 30 || alarm[0] < 0) {
            alarm[0] = 30;
        }
    }

    var _distance_to_target = point_distance(x, y, target_x, target_y);

    // If we reached our wander destination, shorten the next idle delay
    if (_distance_to_target <= 8) {
        wander_stuck_timer = 0;
        if (alarm[0] > 15 || alarm[0] < 0) {
            alarm[0] = 15;
        }
        return;
    }

    var _speed_modifier = get_status_effect_modifier("speed");
    var _terrain_speed = enemy_get_terrain_speed_modifier();
    var _companion_slow = get_companion_enemy_slow(x, y);
    var _move_speed = move_speed * _speed_modifier * _terrain_speed * _companion_slow;
    if (_move_speed <= 0) {
        _move_speed = max(move_speed, 0.1);
    }

    var _direction = point_direction(x, y, target_x, target_y);
    var _step_x = lengthdir_x(_move_speed, _direction);
    var _step_y = lengthdir_y(_move_speed, _direction);

    var _prev_x = x;
    var _prev_y = y;

    move_and_collide(_step_x, _step_y, [tilemap, obj_enemy_parent, obj_rising_pillar, obj_player]);

    var _moved = (abs(x - _prev_x) > 0.1) || (abs(y - _prev_y) > 0.1);

    if (_moved) {
        wander_stuck_timer = 0;
    } else {
        if (!variable_instance_exists(self, "wander_stuck_timer")) {
            wander_stuck_timer = 0;
        }
        wander_stuck_timer++;
        if (wander_stuck_timer > 30) {
            alarm[0] = 0;
            wander_stuck_timer = 0;
        }
    }
}
