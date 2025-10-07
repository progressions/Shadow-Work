function player_state_idle() {
    // Stop all footstep sounds when entering idle
    stop_all_footstep_sounds();

    // Check for dash input first
    if (player_handle_dash_input()) {
        return; // Dash was triggered, state changed
    }

    // Check for input to transition to walking
    var _hor = keyboard_check(ord("D")) - keyboard_check(ord("A"));
    var _ver = keyboard_check(ord("S")) - keyboard_check(ord("W"));

    if (_hor != 0 || _ver != 0) {
        state = PlayerState.walking;
        return;
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
                if (abs(_collision.nx) > 0.5) velocity_x = 0;
                if (abs(_collision.ny) > 0.5) velocity_y = 0;
            }
        }
    }

    // Handle knockback
    player_handle_knockback();
}