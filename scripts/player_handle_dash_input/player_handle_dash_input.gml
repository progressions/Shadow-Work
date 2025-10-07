function player_handle_dash_input() {
    // Check for double-tap dash input
    if (state != PlayerState.dashing && dash_cooldown <= 0) {
        var _focus_active = focus_enabled && variable_struct_exists(self, "focus_state") && focus_state.active;
        var _has_ranged_weapon = false;
        if (equipped.right_hand != undefined && equipped.right_hand.definition != undefined) {
            var _stats = equipped.right_hand.definition.stats;
            if (variable_struct_exists(_stats, "requires_ammo")) {
                _has_ranged_weapon = true;
            }
        }

        // W key double-tap
        if (keyboard_check_pressed(ord("W"))) {
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

        // A key double-tap
        if (keyboard_check_pressed(ord("A"))) {
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

        // S key double-tap
        if (keyboard_check_pressed(ord("S"))) {
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

        // D key double-tap
        if (keyboard_check_pressed(ord("D"))) {
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
