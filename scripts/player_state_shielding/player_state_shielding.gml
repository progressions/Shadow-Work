/// player_state_shielding
/// Handles shield block state - player raises shield and locks facing direction

function player_state_shielding() {
    // Exit shield if not holding block key
    if (!keyboard_check(ord("O"))) {
        // Release shield, apply cooldown
        block_cooldown = block_cooldown_max;  // Default cooldown
        state = PlayerState.idle;
        shield_raise_complete = false;
        return;
    }

    // Check if shield is equipped
    if (equipped[$ "left_hand"] == undefined) {
        // No shield equipped, exit block
        state = PlayerState.idle;
        return;
    }

    // Lock facing direction (like ranged focus mode)
    facing_dir = shield_facing_dir;

    // Allow WASD movement in any direction while maintaining shield facing
    var _hor = keyboard_check(ord("D")) - keyboard_check(ord("A"));
    var _ver = keyboard_check(ord("S")) - keyboard_check(ord("W"));

    // Apply movement using velocity system (like walking state)
    if (_hor != 0 || _ver != 0) {
        // Normalize diagonal input
        var _input_magnitude = sqrt(_hor * _hor + _ver * _ver);
        if (_input_magnitude > 0) {
            _hor /= _input_magnitude;
            _ver /= _input_magnitude;
        }

        var _speed_modifier = get_status_effect_modifier("speed");
        var _companion_slow = get_companion_enemy_slow(x, y);
        var _final_move_speed = move_speed * terrain_speed_modifier * _speed_modifier * _companion_slow;

        // Acceleration-based movement
        velocity_x += _hor * acceleration * _final_move_speed;
        velocity_y += _ver * acceleration * _final_move_speed;

        // Cap velocity at max_velocity
        var _velocity_magnitude = sqrt(velocity_x * velocity_x + velocity_y * velocity_y);
        if (_velocity_magnitude > max_velocity * _final_move_speed) {
            var _scale = (max_velocity * _final_move_speed) / _velocity_magnitude;
            velocity_x *= _scale;
            velocity_y *= _scale;
        }

        // Apply velocity to position with collision
        var _collided = move_and_collide(velocity_x, velocity_y, tilemap);
        if (array_length(_collided) > 0) {
            // On collision, reduce velocity in that direction
            for (var i = 0; i < array_length(_collided); i++) {
                var _collision = _collided[i];
                var _has_struct = is_struct(_collision);
                var _has_nx = _has_struct && variable_struct_exists(_collision, "nx");
                var _has_ny = _has_struct && variable_struct_exists(_collision, "ny");

                if (_has_nx && abs(_collision.nx) > 0.5) velocity_x *= 0.3;
                if (_has_ny && abs(_collision.ny) > 0.5) velocity_y *= 0.3;

                if (!_has_struct || (!_has_nx && !_has_ny)) {
                    velocity_x *= 0.3;
                    velocity_y *= 0.3;
                }
            }
        }

        move_dir = "walking"; // Set move_dir so we don't use idle animation bobbing
    } else {
        // Apply friction when not moving
        velocity_x *= friction_factor;
        velocity_y *= friction_factor;

        // Stop completely if velocity is very small
        if (abs(velocity_x) < 0.01) velocity_x = 0;
        if (abs(velocity_y) < 0.01) velocity_y = 0;

        // Continue applying momentum even when idle
        if (velocity_x != 0 || velocity_y != 0) {
            var _collided = move_and_collide(velocity_x, velocity_y, tilemap);
            if (array_length(_collided) > 0) {
                for (var i = 0; i < array_length(_collided); i++) {
                    var _collision = _collided[i];
                    var _has_struct = is_struct(_collision);
                    var _has_nx = _has_struct && variable_struct_exists(_collision, "nx");
                    var _has_ny = _has_struct && variable_struct_exists(_collision, "ny");

                    if (_has_nx && abs(_collision.nx) > 0.5) velocity_x = 0;
                    if (_has_ny && abs(_collision.ny) > 0.5) velocity_y = 0;

                    if (!_has_struct || (!_has_nx && !_has_ny)) {
                        velocity_x = 0;
                        velocity_y = 0;
                    }
                }
            }
        }

        move_dir = "idle";
    }

    // Animation is handled by player_handle_animation()
}
