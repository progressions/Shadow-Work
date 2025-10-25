function player_state_focus() {
    // If staggered, exit focus mode - return to idle
    if (is_staggered) {
        state = PlayerState.idle;
        move_dir = "idle";
        return;
    }

    // Check for dash input first
    if (player_handle_dash_input()) {
        return; // Dash was triggered, state changed
    }

    // Check if R1 is no longer held - exit focus mode
    if (!InputCheck(INPUT_VERB.SHIELD)) {
        // Return to idle or walking depending on movement
        var _hor = InputX(INPUT_CLUSTER.NAVIGATION);
        var _ver = InputY(INPUT_CLUSTER.NAVIGATION);

        if (_hor == 0 && _ver == 0) {
            state = PlayerState.idle;
            move_dir = "idle";
        } else {
            state = PlayerState.walking;
        }
        return;
    }

    // Check for input - use InputX/InputY for proper analog stick support
	var _hor = InputX(INPUT_CLUSTER.NAVIGATION);
	var _ver = InputY(INPUT_CLUSTER.NAVIGATION);

    // If no input, move_dir becomes idle (but stay in focus state)
    if (_hor == 0 && _ver == 0) {
        move_dir = "idle";

        // Apply friction to decelerate when no input
        velocity_x *= friction_factor;
        velocity_y *= friction_factor;

        // Stop completely if velocity is very small (prevents eternal drifting)
        if (abs(velocity_x) < 0.01) velocity_x = 0;
        if (abs(velocity_y) < 0.01) velocity_y = 0;
    } else {
        // Update move_dir based on input (but NOT facing_dir - that's locked)
        if (abs(_ver) > abs(_hor)) {
            // Vertical is stronger
            if (_ver > 0) {
                move_dir = "down";
            } else if (_ver < 0) {
                move_dir = "up";
            }
        } else {
            // Horizontal is stronger (or equal)
            if (_hor > 0) {
                move_dir = "right";
            } else if (_hor < 0) {
                move_dir = "left";
            }
        }
    }

    // Detect terrain at player position (for footstep sounds)
    var _terrain = get_terrain_at_position(x, y);

    // Apply terrain speed modifier and status effect speed modifiers
    var speed_modifier = get_status_effect_modifier("speed");

    // Apply shield movement penalty if shield equipped in focus mode
    var _shield_penalty = 1.0;
    if (equipped[$ "left_hand"] != undefined) {
        _shield_penalty = 0.7; // 30% movement speed reduction when blocking with shield
    }

    var final_move_speed = move_speed * terrain_speed_modifier * speed_modifier * _shield_penalty;

    // Normalize diagonal input
    var _input_magnitude = sqrt(_hor * _hor + _ver * _ver);
    if (_input_magnitude > 0) {
        _hor /= _input_magnitude;
        _ver /= _input_magnitude;
    }

    // Acceleration-based movement (add to velocity instead of direct position change)
    velocity_x += _hor * acceleration * final_move_speed;
    velocity_y += _ver * acceleration * final_move_speed;

    // Cap velocity at max_velocity
    var _velocity_magnitude = sqrt(velocity_x * velocity_x + velocity_y * velocity_y);
    if (_velocity_magnitude > max_velocity * final_move_speed) {
        var _scale = (max_velocity * final_move_speed) / _velocity_magnitude;
        velocity_x *= _scale;
        velocity_y *= _scale;
    }

    // Apply velocity to position with collision
    var _collided = move_and_collide(velocity_x, velocity_y, tilemap);
    if (array_length(_collided) > 0) {
        // On collision, kill velocity in that direction
        for (var i = 0; i < array_length(_collided); i++) {
            var _collision = _collided[i];
            var _has_struct = is_struct(_collision);
            var _has_nx = _has_struct && variable_struct_exists(_collision, "nx");
            var _has_ny = _has_struct && variable_struct_exists(_collision, "ny");

            // Reduce velocity when hitting walls
            if (_has_nx && abs(_collision.nx) > 0.5) velocity_x *= 0.3;
            if (_has_ny && abs(_collision.ny) > 0.5) velocity_y *= 0.3;

            // Fallback dampening when no normal data is provided (e.g. dynamic bodies)
            if (!_has_struct || (!_has_nx && !_has_ny)) {
                velocity_x *= 0.3;
                velocity_y *= 0.3;
            }
        }
    }

    // Get footstep sound for current terrain
    var _footstep_sound = global.terrain_footstep_sounds[$ _terrain] ?? snd_footsteps_grass;

    // Play appropriate footstep sound (only if moving)
    if (move_dir != "idle") {
        play_sfx(_footstep_sound, 0.3, 4, true);
    }

    // Stop all other terrain footstep sounds
    var _terrain_names = variable_struct_get_names(global.terrain_footstep_sounds);
    for (var i = 0; i < array_length(_terrain_names); i++) {
        var _other_sound = global.terrain_footstep_sounds[$ _terrain_names[i]];
        if (_other_sound != _footstep_sound) {
            stop_looped_sfx(_other_sound);
        }
    }

    // Handle knockback
    player_handle_knockback();
}
