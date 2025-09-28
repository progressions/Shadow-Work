function player_on_grid(){

    // Grid-based movement - only on key press
    if (keyboard_check_pressed(ord("W"))) {
        obj_grid_controller.move_up();
        facing_dir = "up";
        move_dir = "up";
    }
    else if (keyboard_check_pressed(ord("S"))) {
        obj_grid_controller.move_down();
        facing_dir = "down";
        move_dir = "down";
    }
    else if (keyboard_check_pressed(ord("A"))) {
        obj_grid_controller.move_left();
        facing_dir = "left";
        move_dir = "left";
    }
    else if (keyboard_check_pressed(ord("D"))) {
        obj_grid_controller.move_right();
        facing_dir = "right";
        move_dir = "right";
    }
    else {
        move_dir = "idle";
    }
}