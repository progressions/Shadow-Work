function player_handle_dash_input() {
    // Check for double-tap dash input
    if (state != PlayerState.dashing && dash_cooldown <= 0) {
        // W key double-tap
        if (keyboard_check_pressed(ord("W"))) {
            if (current_time - last_key_time_w < double_tap_time) {
                start_dash("up");
                state = PlayerState.dashing;
                return true;
            }
            last_key_time_w = current_time;
        }

        // A key double-tap
        if (keyboard_check_pressed(ord("A"))) {
            if (current_time - last_key_time_a < double_tap_time) {
                start_dash("left");
                state = PlayerState.dashing;
                return true;
            }
            last_key_time_a = current_time;
        }

        // S key double-tap
        if (keyboard_check_pressed(ord("S"))) {
            if (current_time - last_key_time_s < double_tap_time) {
                start_dash("down");
                state = PlayerState.dashing;
                return true;
            }
            last_key_time_s = current_time;
        }

        // D key double-tap
        if (keyboard_check_pressed(ord("D"))) {
            if (current_time - last_key_time_d < double_tap_time) {
                start_dash("right");
                state = PlayerState.dashing;
                return true;
            }
            last_key_time_d = current_time;
        }
    }

    return false; // No dash triggered
}