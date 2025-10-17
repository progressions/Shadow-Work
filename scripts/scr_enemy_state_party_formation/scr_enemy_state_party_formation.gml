// ============================================
// ENEMY STATE: PARTY_FORMATION
// Follow formation position without attacking - used for patrol/protect parties
// ============================================

function enemy_state_party_formation() {
    // If not in a party, transition to targeting
    if (!instance_exists(party_controller)) {
        state = EnemyState.targeting;
        alarm[0] = 1;
        return;
    }

    // Check if party has decided to engage - if so, transition to targeting
    var _party = party_controller;
    var _is_patrol_mode = (_party.patrol_original_state == PartyState.patrolling ||
                           _party.patrol_original_state == PartyState.protecting);

    if (_is_patrol_mode) {
        var _party_decision = _party.evaluate_patrol_decision();
        if (_party_decision == "engage") {
            // Party is engaging - switch to targeting state
            state = EnemyState.targeting;
            alarm[0] = 1;
            return;
        }
    }

    // Move toward formation position
    var _target_x = objective_target_x;  // Set by party controller
    var _target_y = objective_target_y;

    var _dist_to_formation = point_distance(x, y, _target_x, _target_y);

    // If close enough, idle here
    if (_dist_to_formation <= 16) {
        if (path_exists(path) && path_index != -1) {
            path_end();
        }
        return;
    }

    // Calculate movement with modifiers
    var _speed_modifier = get_status_effect_modifier("speed");
    var _terrain_speed = enemy_get_terrain_speed_modifier();
    var _companion_slow = get_companion_enemy_slow(x, y);
    var _move_speed = move_speed * _speed_modifier * _terrain_speed * _companion_slow;

    if (_move_speed <= 0) {
        _move_speed = max(move_speed, 0.1);
    }

    // Simple direct movement toward formation position
    var _dir = point_direction(x, y, _target_x, _target_y);
    var _dx = lengthdir_x(_move_speed, _dir);
    var _dy = lengthdir_y(_move_speed, _dir);

    move_and_collide(_dx, _dy, [tilemap, obj_enemy_parent, obj_rising_pillar, obj_player]);
}
