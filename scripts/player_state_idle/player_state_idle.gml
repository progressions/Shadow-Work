function player_state_idle() {
    // Stop all footstep sounds when entering idle
    stop_all_footstep_sounds();

    // Check for shield block input
    if (InputPressed(INPUT_VERB.SHIELD)) {
        // Check if shield is equipped
        if (equipped[$ "left_hand"] != undefined && block_cooldown <= 0) {
            // Enter shielding state
            state = PlayerState.shielding;
            shield_facing_dir = facing_dir;  // Lock to current facing direction
            shield_raise_complete = false;
            play_sfx(snd_shield_raise, 0.8);
            return;
        }
    }

    // If staggered, can't move - skip movement input
    if (!is_staggered) {
        // Check for dash input first
        if (player_handle_dash_input()) {
            return; // Dash was triggered, state changed
        }

        // Check for input to transition to walking - use InputX/InputY for analog support
        var _hor = InputX(INPUT_CLUSTER.NAVIGATION);
        var _ver = InputY(INPUT_CLUSTER.NAVIGATION);

        if (_hor != 0 || _ver != 0) {
            state = PlayerState.walking;
            return;
        }
    }

    // Stay in idle
    move_dir = "idle";

    // Apply friction to decelerate
    velocity_x *= friction_factor;
    velocity_y *= friction_factor;

    // Stop completely if velocity is very small (prevents eternal drifting)
    if (abs(velocity_x) < 0.01) velocity_x = 0;
    if (abs(velocity_y) < 0.01) velocity_y = 0;

    // Continue applying momentum even in idle state
    if (velocity_x != 0 || velocity_y != 0) {
        var _collided = move_and_collide(velocity_x, velocity_y, tilemap);
        if (array_length(_collided) > 0) {
            // On collision, kill velocity
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

    // Handle knockback
    player_handle_knockback();
}
