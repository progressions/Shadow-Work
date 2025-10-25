function player_handle_dash_input() {
    // Check for double-tap dash input OR dash button
    if (state != PlayerState.dashing && dash_cooldown <= 0) {
        var _focus_active = focus_enabled && variable_struct_exists(self, "focus_state") && focus_state.active;
        var _has_ranged_weapon = false;
        if (equipped.right_hand != undefined && equipped.right_hand.definition != undefined) {
            var _stats = equipped.right_hand.definition.stats;
            if (variable_struct_exists(_stats, "requires_ammo")) {
                _has_ranged_weapon = true;
            }
        }

        // Dash button (Shift on keyboard only - gamepad uses double-tap directional)
        // Only process when in gameplay state
        if (InputPressed(INPUT_VERB.DASH) && global.state == GameState.gameplay) {
            if (!_focus_active) {
                start_dash(facing_dir);
                state = PlayerState.dashing;
                return true;
            }
        }

        // UP double-tap
        if (InputPressed(INPUT_VERB.UP)) {
            if (current_time - last_key_time_w < double_tap_time) {
                if (_focus_active) {
                    if (_has_ranged_weapon && player_focus_is_retreat_direction(facing_dir, "up")) {
                        if (player_focus_execute_ranged_volley(self, facing_dir, "up", undefined, true)) {
                            focus_state.active = false;
                            focus_state.buffer_ready = false;
                            focus_state.suppress_next_release = true;
                            return true;
                        }
                    }
                    if (!_has_ranged_weapon && player_focus_try_melee_combo(self, "up")) {
                        return true;
                    }
                    player_focus_set_retreat(self, "up");
                } else {
                    start_dash("up");
                    state = PlayerState.dashing;
                    return true;
                }
            }
            last_key_time_w = current_time;
        }

        // LEFT double-tap
        if (InputPressed(INPUT_VERB.LEFT)) {
            if (current_time - last_key_time_a < double_tap_time) {
                if (_focus_active) {
                    if (_has_ranged_weapon && player_focus_is_retreat_direction(facing_dir, "left")) {
                        if (player_focus_execute_ranged_volley(self, facing_dir, "left", undefined, true)) {
                            focus_state.active = false;
                            focus_state.buffer_ready = false;
                            focus_state.suppress_next_release = true;
                            return true;
                        }
                    }
                    if (!_has_ranged_weapon && player_focus_try_melee_combo(self, "left")) {
                        return true;
                    }
                    player_focus_set_retreat(self, "left");
                } else {
                    start_dash("left");
                    state = PlayerState.dashing;
                    return true;
                }
            }
            last_key_time_a = current_time;
        }

        // DOWN double-tap
        if (InputPressed(INPUT_VERB.DOWN)) {
            if (current_time - last_key_time_s < double_tap_time) {
                if (_focus_active) {
                    if (_has_ranged_weapon && player_focus_is_retreat_direction(facing_dir, "down")) {
                        if (player_focus_execute_ranged_volley(self, facing_dir, "down", undefined, true)) {
                            focus_state.active = false;
                            focus_state.buffer_ready = false;
                            focus_state.suppress_next_release = true;
                            return true;
                        }
                    }
                    if (!_has_ranged_weapon && player_focus_try_melee_combo(self, "down")) {
                        return true;
                    }
                    player_focus_set_retreat(self, "down");
                } else {
                    start_dash("down");
                    state = PlayerState.dashing;
                    return true;
                }
            }
            last_key_time_s = current_time;
        }

        // RIGHT double-tap
        if (InputPressed(INPUT_VERB.RIGHT)) {
            if (current_time - last_key_time_d < double_tap_time) {
                if (_focus_active) {
                    if (_has_ranged_weapon && player_focus_is_retreat_direction(facing_dir, "right")) {
                        if (player_focus_execute_ranged_volley(self, facing_dir, "right", undefined, true)) {
                            focus_state.active = false;
                            focus_state.buffer_ready = false;
                            focus_state.suppress_next_release = true;
                            return true;
                        }
                    }
                    if (!_has_ranged_weapon && player_focus_try_melee_combo(self, "right")) {
                        return true;
                    }
                    player_focus_set_retreat(self, "right");
                } else {
                    start_dash("right");
                    state = PlayerState.dashing;
                    return true;
                }
            }
            last_key_time_d = current_time;
        }
    }

    return false; // No dash triggered
}
