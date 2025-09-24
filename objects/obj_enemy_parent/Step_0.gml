var _hor = clamp(target_x - x, -1, 1);
var _ver = clamp(target_y - y, -1, 1);
move_and_collide(_hor * move_speed, _ver * move_speed, [tilemap, obj_enemy_parent]);

// Simple animation
image_speed = 0; // Manual control

// Determine base frame from direction ONLY when actually moving
if (abs(_hor) > 0.1 || abs(_ver) > 0.1) {  // Only update when moving
    var base_frame = 0;
    if (abs(_ver) > abs(_hor)) {
        if (_ver < 0) base_frame = 4; // Up
        else base_frame = 0; // Down
    } else {
        if (_hor < 0) base_frame = 2; // Left
        else base_frame = 0; // Down/Right
    }
    
    // Store the base frame
    if (!variable_instance_exists(id, "current_base_frame")) current_base_frame = 0;
    current_base_frame = base_frame;
}

// Initialize variables if needed
if (!variable_instance_exists(id, "current_base_frame")) current_base_frame = 0;
if (!variable_instance_exists(id, "frame_counter")) frame_counter = 0;

// Simple frame toggle
frame_counter++;
if (frame_counter >= 20) {
    frame_counter = 0;
    // Toggle between the two frames
    if (image_index == current_base_frame) {
        image_index = current_base_frame + 1;
    } else {
        image_index = current_base_frame;
    }
}