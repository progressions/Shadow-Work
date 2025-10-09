function player_state_dead(){
    // Stop all footstep sounds when dead
    stop_all_footstep_sounds();

    // Play death animation once, then stay on final frame
    if (!variable_instance_exists(self, "death_anim_complete")) {
        death_anim_complete = false;
        death_anim_timer = 0;

        // Clean up stun particles immediately on death
        destroy_stun_particles(self);
    }

    if (!death_anim_complete) {
        // Play death animation (frames 58-60)
        var anim_speed = 0.15; // Animation speed
        death_anim_timer += anim_speed;
        var frame_offset = floor(death_anim_timer);

        // Death animation is 3 frames: 58, 59, 60
        if (frame_offset >= 3) {
            death_anim_complete = true;
            image_index = 60; // Final frame

            // End the game after animation completes (only set once)
            if (!variable_instance_exists(self, "death_alarm_set")) {
                death_alarm_set = true;
                alarm[1] = 60; // Wait 1 second then end game
            }
        } else {
            image_index = 58 + frame_offset;
        }
    } else {
        // Stay on final dead frame
        image_index = 60;
    }

    // Stop all movement and disable input while dead
    move_dir = "dead";

    // Disable all other systems while dead
    return;
}