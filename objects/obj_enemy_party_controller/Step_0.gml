/// @description Update party state each frame

// DEBUG: Check if Step event is running
if (object_index == obj_canopy_threat) {
    show_debug_message("CANOPY THREAT STEP EVENT RUNNING - patrol_original_state=" + string(patrol_original_state));
}

// Evaluate weighted decision for patrol vs engage
if (patrol_original_state == PartyState.patrolling || patrol_original_state == PartyState.protecting) {
    if (object_index == obj_canopy_threat) {
        show_debug_message("About to call evaluate_patrol_decision");
    }
    var _decision = evaluate_patrol_decision();

    if (_decision == "engage") {
        // Switch to combat if not already
        if (party_state == patrol_original_state) {
            patrol_home_x = x;
            patrol_home_y = y;
            transition_to_state(PartyState.aggressive);
        }

        // Follow the player
        if (instance_exists(obj_player)) {
            var _move_speed = 1.0;
            var _dir = point_direction(x, y, obj_player.x, obj_player.y);
            x += lengthdir_x(_move_speed, _dir);
            y += lengthdir_y(_move_speed, _dir);
        }
    } else {
        // Return to or continue patrol
        if (party_state != patrol_original_state) {
            // Was engaged, now returning
            transition_to_state(patrol_original_state);
            x = patrol_home_x;
            y = patrol_home_y;
        }

        // Continue patrol movement
        if (patrol_original_state == PartyState.patrolling && patrol_path != -1 && path_exists(patrol_path)) {
            // Move along the path
            patrol_position += patrol_speed / path_get_length(patrol_path);

            // Handle looping
            if (patrol_position >= 1) {
                if (patrol_loop) {
                    patrol_position = 0;
                } else {
                    patrol_position = 1;
                    patrol_speed = -patrol_speed; // Reverse direction
                }
            } else if (patrol_position <= 0) {
                patrol_position = 0;
                if (!patrol_loop) {
                    patrol_speed = -patrol_speed; // Reverse direction
                }
            }

            // Update controller position to current path position
            x = path_get_point_x(patrol_path, patrol_position);
            y = path_get_point_y(patrol_path, patrol_position);
        }
    }
}

// Update party state based on current conditions
update_party_state();

// Update decision weights for party members (staggered round-robin)
// OR put them in party_formation state if in patrol/protect mode
var _should_calculate_weights = true;

if (patrol_original_state == PartyState.patrolling || patrol_original_state == PartyState.protecting) {
    var _decision = evaluate_patrol_decision();
    if (_decision == "patrol") {
        // Party is staying on patrol - put all enemies in party_formation state
        _should_calculate_weights = false;

        // Set all enemies to party_formation state
        for (var i = 0; i < array_length(party_members); i++) {
            var _enemy = party_members[i];
            if (instance_exists(_enemy)) {
                // Put enemy in party_formation state
                if (_enemy.state != EnemyState.party_formation) {
                    _enemy.state = EnemyState.party_formation;
                }

                // Set formation position as target
                var _form_pos = get_formation_position(_enemy);
                if (_form_pos != undefined) {
                    _enemy.formation_target_x = _form_pos.x;
                    _enemy.formation_target_y = _form_pos.y;
                    _enemy.objective_target_x = _form_pos.x;
                    _enemy.objective_target_y = _form_pos.y;
                }
            }
        }
    } else {
        // Party is engaging - transition enemies out of party_formation state
        for (var i = 0; i < array_length(party_members); i++) {
            var _enemy = party_members[i];
            if (instance_exists(_enemy) && _enemy.state == EnemyState.party_formation) {
                _enemy.state = EnemyState.targeting;
            }
        }
    }
}

if (_should_calculate_weights && array_length(party_members) > 0) {
    // Calculate how many to update this frame (1-2 members)
    var _updates_per_frame = min(2, array_length(party_members));

    for (var i = 0; i < _updates_per_frame; i++) {
        // Wrap index around party size
        var _member_index = (decision_update_index + i) mod array_length(party_members);
        var _enemy = party_members[_member_index];

        if (instance_exists(_enemy)) {
            calculate_decision_weights(_enemy);
        }
    }

    // Advance index for next frame
    decision_update_index = (decision_update_index + _updates_per_frame) mod array_length(party_members);
}

// Cleanup: Destroy party controller when all members are dead
if (array_length(party_members) == 0) {
    instance_destroy();
}
