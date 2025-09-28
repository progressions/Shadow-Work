function player_handle_animation() {
    // Build animation key and look it up
    var anim_key;
    if (state == PlayerState.attacking) {
        anim_key = "attack_" + facing_dir;
    } else if (move_dir == "idle") {
        anim_key = "idle_" + facing_dir;
    } else if (is_dashing) {
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
        anim_frame += anim_speed_walk * 1.5; // Slightly faster for attack animations
        if (anim_frame >= current_anim_length) {
            // Attack animation finished, return to idle state
            state = PlayerState.idle;
            anim_frame = 0;
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