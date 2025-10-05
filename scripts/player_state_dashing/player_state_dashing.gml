function player_state_dashing() {
    // Stop all footstep sounds when dashing
    stop_all_footstep_sounds();

    // Handle dash movement
    dash_timer--;
    if (dash_timer <= 0) {
        state = PlayerState.idle; // Return to idle when dash ends
        move_dir = "idle";

        // Start dash attack window
        dash_attack_window = dash_attack_window_duration;
        last_dash_direction = facing_dir;
        show_debug_message("Dash attack window started (" + string(dash_attack_window_duration) + "s) - direction: " + last_dash_direction);

        return;
    }

    var dash_x = 0;
    var dash_y = 0;

    // Apply status effect speed modifiers to dash
    var speed_modifier = get_status_effect_modifier("speed");
    var final_dash_speed = dash_speed * speed_modifier;

    switch(facing_dir) {
        case "up":    dash_y = -final_dash_speed; break;
        case "down":  dash_y =  final_dash_speed; break;
        case "left":  dash_x = -final_dash_speed; break;
        case "right": dash_x =  final_dash_speed; break;
    }

    move_and_collide(dash_x, dash_y, tilemap);
    move_dir = "dash";

    // Check for pillar interaction while dashing (only in grid puzzle rooms)
    if (instance_exists(obj_grid_controller)) {
        player_move_onto_pillar();
    }

    // Update dash cooldown
    if (dash_cooldown > 0) {
        dash_cooldown--;
    }

    // Handle knockback
    player_handle_knockback();
}