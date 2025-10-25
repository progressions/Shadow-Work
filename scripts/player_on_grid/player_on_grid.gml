function player_on_grid(){
    // Safety check - if no grid controller exists, return to idle state
    if (!instance_exists(obj_grid_controller)) {
        state = PlayerState.idle;
        move_dir = "idle";
        return;
    }

    // Stop all footstep sounds when on grid
    stop_all_footstep_sounds();

    // Grid-based movement - only on button press
    if (InputPressed(INPUT_VERB.UP)) {
        obj_grid_controller.move_up();
        facing_dir = "up";
        move_dir = "up";
    }
    else if (InputPressed(INPUT_VERB.DOWN)) {
        obj_grid_controller.move_down();
        facing_dir = "down";
        move_dir = "down";
    }
    else if (InputPressed(INPUT_VERB.LEFT)) {
        obj_grid_controller.move_left();
        facing_dir = "left";
        move_dir = "left";
    }
    else if (InputPressed(INPUT_VERB.RIGHT)) {
        obj_grid_controller.move_right();
        facing_dir = "right";
        move_dir = "right";
    }
    else {
        move_dir = "idle";
    }
}