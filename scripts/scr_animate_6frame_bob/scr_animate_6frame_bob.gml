function animate_6frame_bob(_hor, _ver, _anim_speed) {
    // Initialize timer if it doesn't exist
    if (!variable_instance_exists(id, "anim_timer")) {
        anim_timer = 0;
    }
    
    // Turn off automatic animation
    image_speed = 0;
    
    // Check if moving and update direction
    if (_hor != 0 || _ver != 0) {
        if (_ver < 0 && abs(_ver) > abs(_hor)) {
            // Moving up - use frames 4-5
            if (image_index < 4 || image_index >= 6) {
                image_index = 4;
            }
        }
        else if (_hor < 0 && abs(_hor) > abs(_ver)) {
            // Moving left - use frames 2-3
            if (image_index < 2 || image_index >= 4) {
                image_index = 2;
            }
        }
        else {
            // Moving down or right - use frames 0-1
            if (image_index >= 2) {
                image_index = 0;
            }
        }
    }
    
    // Manual animation
    anim_timer += 1;
    if (anim_timer >= _anim_speed) {
        anim_timer = 0;
        
        if (image_index >= 0 && image_index < 2) {
            // Down/right range (0-1)
            image_index = (image_index == 0) ? 1 : 0;
        }
        else if (image_index >= 2 && image_index < 4) {
            // Left range (2-3)
            image_index = (image_index == 2) ? 3 : 2;
        }
        else if (image_index >= 4 && image_index < 6) {
            // Up range (4-5)
            image_index = (image_index == 4) ? 5 : 4;
        }
    }
}