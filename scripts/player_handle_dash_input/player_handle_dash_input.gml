function player_handle_dash_input() {
    // Check for double-tap dash input OR dash button
    if (state != PlayerState.dashing && state != PlayerState.focus && dash_cooldown <= 0) {
        // Dash button (Shift on keyboard only - gamepad uses double-tap directional)
        // Only process when in gameplay state
        if (InputPressed(INPUT_VERB.DASH) && global.state == GameState.gameplay) {
            start_dash(facing_dir);
            state = PlayerState.dashing;
            return true;
        }

        // UP double-tap
        if (InputPressed(INPUT_VERB.UP)) {
            if (current_time - last_key_time_w < double_tap_time) {
                start_dash("up");
                state = PlayerState.dashing;
                return true;
            }
            last_key_time_w = current_time;
        }

        // LEFT double-tap
        if (InputPressed(INPUT_VERB.LEFT)) {
            if (current_time - last_key_time_a < double_tap_time) {
                start_dash("left");
                state = PlayerState.dashing;
                return true;
            }
            last_key_time_a = current_time;
        }

        // DOWN double-tap
        if (InputPressed(INPUT_VERB.DOWN)) {
            if (current_time - last_key_time_s < double_tap_time) {
                start_dash("down");
                state = PlayerState.dashing;
                return true;
            }
            last_key_time_s = current_time;
        }

        // RIGHT double-tap
        if (InputPressed(INPUT_VERB.RIGHT)) {
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
