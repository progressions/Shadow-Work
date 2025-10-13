function player_state_dashing() {
    // If staggered, cancel dash immediately
    if (is_staggered) {
        state = PlayerState.idle;
        move_dir = "idle";
        dash_timer = 0;
        dash_override_direction = "";
        player_dash_end();
        return;
    }

    // Stop all footstep sounds when dashing
    stop_all_footstep_sounds();

    // Handle dash movement
    dash_timer--;
    if (dash_timer <= 0) {
        state = PlayerState.idle; // Return to idle when dash ends
        move_dir = "idle";

        // Transfer dash momentum to velocity for smooth transition
        var _dash_dir = facing_dir;
        if (dash_override_direction != undefined && dash_override_direction != "") {
            _dash_dir = dash_override_direction;
        }

        // Set velocity based on dash direction (creates momentum carry-over)
        var momentum_factor = 0.6; // 60% of dash speed carries over as momentum
        switch(_dash_dir) {
            case "up":    velocity_y = -dash_speed * momentum_factor; break;
            case "down":  velocity_y =  dash_speed * momentum_factor; break;
            case "left":  velocity_x = -dash_speed * momentum_factor; break;
            case "right": velocity_x =  dash_speed * momentum_factor; break;
        }

        dash_override_direction = "";

        // Start dash attack window
        dash_attack_window = dash_attack_window_duration;
        last_dash_direction = facing_dir;
        show_debug_message("Dash attack window started (" + string(dash_attack_window_duration) + "s) - direction: " + last_dash_direction);

        if (focus_enabled && variable_struct_exists(self, "focus_state")) {
            player_focus_fire_ranged_followup(self);
        }

        player_dash_end();
        return;
    }

    // Reset velocity during dash for precise movement (momentum is set at end)
    velocity_x = 0;
    velocity_y = 0;

    var dash_x = 0;
    var dash_y = 0;

    var _dash_dir = facing_dir;
    if (dash_override_direction != undefined && dash_override_direction != "") {
        _dash_dir = dash_override_direction;
    }

    // Apply terrain and status effect speed modifiers to dash
    var speed_modifier = get_status_effect_modifier("speed");
    var final_dash_speed = dash_speed * terrain_speed_modifier * speed_modifier;

    switch(_dash_dir) {
        case "up":    dash_y = -final_dash_speed; break;
        case "down":  dash_y =  final_dash_speed; break;
        case "left":  dash_x = -final_dash_speed; break;
        case "right": dash_x =  final_dash_speed; break;
    }

    var _prev_x = x;
    var _prev_y = y;

    move_and_collide(dash_x, dash_y, tilemap);
    move_dir = "dash";

    player_dash_handle_collisions(_prev_x, _prev_y);

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
