function player_handle_animation() {
    // Build animation key and look it up
    var anim_key;
    if (state == PlayerState.attacking) {
        anim_key = "attack_" + facing_dir;
    } else if (move_dir == "idle") {
        anim_key = "idle_" + facing_dir;
    } else if (state == PlayerState.dashing) {
        anim_key = "dash_" + facing_dir;
    } else {
        anim_key = "walk_" + facing_dir;
    }

    // Check if animation changed
    if (anim_key != current_anim) {
        current_anim = anim_key;
        var anim_info = anim_data[$ anim_key];
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

    if (state == PlayerState.attacking) {
        // Attack animations play once and don't loop
        var _attack_speed_mult = 1.5; // Slightly faster for attack animations

        // Apply ranged windup speed modifier during windup phase
        if (ranged_windup_active && !ranged_windup_complete) {
            _attack_speed_mult = _attack_speed_mult * ranged_windup_speed; // Slow down during windup
        }

        anim_frame += anim_speed_walk * _attack_speed_mult;

        // Handle ranged attack windup completion
        if (ranged_windup_active && !ranged_windup_complete && anim_frame >= current_anim_length) {
            // Windup animation cycle complete - spawn arrow
            ranged_windup_complete = true;
            spawn_player_arrow(ranged_windup_direction);
            anim_frame = 0; // Reset for any remaining animation
            ranged_windup_active = false; // Clear windup flag

            if (variable_global_exists("debug_mode") && global.debug_mode) {
                show_debug_message("PLAYER WINDUP COMPLETE - Arrow spawned after " + string(current_anim_length) + " frames");
            }
        }

        if (anim_frame >= current_anim_length) {
            // Attack animation finished, return to idle state
            state = PlayerState.idle;
            anim_frame = 0;
            ranged_windup_active = false; // Ensure flags are reset
            ranged_windup_complete = false;
        }
    } else if (move_dir == "idle") {
        // For idle, sync with global timer but keep it in the idle animation range
        anim_frame = global.idle_bob_timer % current_anim_length;
    } else {
        // Normal walking animation (also handles dash)
        anim_frame += anim_speed_walk;
        if (anim_frame >= current_anim_length) {
            anim_frame = anim_frame % current_anim_length;
        }
    }

    image_index = current_anim_start + floor(anim_frame);
}