function player_state_dashing() {
    // Handle dash movement
    dash_timer--;
    if (dash_timer <= 0) {
        is_dashing = false;
        state = PlayerState.idle; // Return to idle when dash ends
        move_dir = "idle";
        return;
    }

    var dash_x = 0;
    var dash_y = 0;

    switch(facing_dir) {
        case "up":    dash_y = -dash_speed; break;
        case "down":  dash_y =  dash_speed; break;
        case "left":  dash_x = -dash_speed; break;
        case "right": dash_x =  dash_speed; break;
    }

    move_and_collide(dash_x, dash_y, tilemap);
    move_dir = "dash";

    // Check for pillar interaction while dashing
    player_move_onto_pillar();

    // Update dash cooldown
    if (dash_cooldown > 0) {
        dash_cooldown--;
    }
}