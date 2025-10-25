function player_handle_animation() {
    // Build animation key based on state (single source of truth)
    var anim_key;

    // State-based animation selection
    switch (state) {
        case PlayerState.attacking:
            // During ranged charge, use walk/idle animations if moving
            if (ranged_charge_active) {
                if (move_dir == "idle") {
                    anim_key = "idle_" + facing_dir;
                } else {
                    anim_key = "walk_" + move_dir;
                }
            } else {
                // Normal melee attack
                anim_key = "attack_" + facing_dir;
            }
            break;

        case PlayerState.dashing:
            anim_key = "dash_" + facing_dir;
            break;

        case PlayerState.focus:
            // In focus mode with shield equipped - use shielding animation
            if (equipped[$ "left_hand"] != undefined) {
                anim_key = "shielding_" + facing_dir;
            } else if (move_dir == "idle") {
                anim_key = "idle_" + facing_dir;
            } else {
                anim_key = "walk_" + facing_dir;
            }
            break;

        case PlayerState.idle:
        case PlayerState.walking:
        default:
            if (move_dir == "idle") {
                anim_key = "idle_" + facing_dir;
            } else {
                anim_key = "walk_" + facing_dir;
            }
            break;
    }

    // Check if animation changed
    if (anim_key != current_anim) {
        current_anim = anim_key;
        var anim_info = anim_data[$ anim_key];

        if (anim_info == undefined) {
            show_debug_message("ERROR: No anim_data found for key: " + anim_key);
            return;
        }

        current_anim_start = anim_info.start;
        current_anim_length = anim_info.length;

        // Reset animation frame on state changes
        if (state == PlayerState.attacking || move_dir != "idle") {
            anim_frame = 0;
        } else {
            anim_frame = global.idle_bob_timer % current_anim_length;
        }

        show_debug_message("Switched to: " + anim_key + " (frames " + string(current_anim_start) + "-" + string(current_anim_start + current_anim_length - 1) + ")");
    }

    // State-specific animation advancement
    switch (state) {
        case PlayerState.attacking:
            // Handle ranged charge state
            if (ranged_charge_active) {
                // If moving during charge, play walk/idle animation normally
                if (move_dir != "idle") {
                    // Normal walking animation
                    anim_frame += anim_speed_walk;
                    if (anim_frame >= current_anim_length) {
                        anim_frame = anim_frame % current_anim_length;
                    }
                    // Increment charge timer
                    ranged_charge_time++;
                } else {
                    // Standing still during charge - use idle animation (synced with global timer)
                    anim_frame = global.idle_bob_timer % current_anim_length;
                    // Increment charge timer
                    ranged_charge_time++;
                }
            }
            // Apply ranged windup speed modifier during windup phase (non-charge mode)
            else if (ranged_windup_active && !ranged_windup_complete) {
                var _attack_speed_mult = 1.5 * ranged_windup_speed; // Slow down during windup
                anim_frame += anim_speed_walk * _attack_speed_mult;

                // Handle ranged attack windup completion (old system, for non-charge attacks)
                if (anim_frame >= current_anim_length) {
                    // Windup animation cycle complete - spawn arrow
                    ranged_windup_complete = true;
                    spawn_player_arrow(ranged_windup_direction);
                    anim_frame = 0; // Reset for any remaining animation
                    ranged_windup_active = false; // Clear windup flag

                    if (variable_global_exists("debug_mode") && global.debug_damage_reduction) {
                        show_debug_message("PLAYER WINDUP COMPLETE - Arrow spawned after " + string(current_anim_length) + " frames");
                    }
                }
            }
            else {
                // Normal attack (melee)
                var _attack_speed_mult = 1.5; // Slightly faster for attack animations
                anim_frame += anim_speed_walk * _attack_speed_mult;
            }

            // Check if animation finished (don't return to idle if we're still charging)
            if (!ranged_charge_active && anim_frame >= current_anim_length) {
                // Attack animation finished - return to previous state
                state = state_before_attack;
                state_before_attack = PlayerState.idle;
                anim_frame = 0;
                ranged_windup_active = false; // Ensure flags are reset
                ranged_windup_complete = false;
            }
            break;

        case PlayerState.idle:
        case PlayerState.walking:
        case PlayerState.focus:
            if (move_dir == "idle") {
                // For idle, sync with global timer but keep it in the idle animation range
                anim_frame = global.idle_bob_timer % current_anim_length;
            } else {
                // Normal walking animation (also handles dash)
                anim_frame += anim_speed_walk;
                if (anim_frame >= current_anim_length) {
                    anim_frame = anim_frame % current_anim_length;
                }
            }
            break;

        case PlayerState.dashing:
            // Dash animation loops
            anim_frame += anim_speed_walk;
            if (anim_frame >= current_anim_length) {
                anim_frame = anim_frame % current_anim_length;
            }
            break;
    }

    image_index = current_anim_start + floor(anim_frame);
}