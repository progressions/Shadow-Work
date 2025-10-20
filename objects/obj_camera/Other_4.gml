/// @description Room Start - Reinitialize camera position

// When entering a new room, snap camera to follow target immediately
if (follow != noone && instance_exists(follow)) {
    x = follow.x;
    y = follow.y;
    x_to = x;
    y_to = y;

    // Immediately update camera position (no lerp)
    camera_set_view_pos(cam, x - (cam_width * 0.5), y - (cam_height * 0.5));

    show_debug_message("Camera reinitialized to position: " + string(x) + ", " + string(y));
}
