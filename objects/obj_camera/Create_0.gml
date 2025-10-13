// Camera settings
cam_width = 320;
cam_height = 180;

// Get the camera from view[0] and take full control
cam = view_camera[0];
camera_set_view_size(cam, cam_width, cam_height);

follow = obj_player;
// follow = obj_canopy;

// Initialize camera position to player's position if player exists
if (instance_exists(follow)) {
    x = follow.x;
    y = follow.y;
} else {
    // Fallback to room center if player doesn't exist yet
    x = room_width / 2;
    y = room_height / 2;
}

x_to = x;
y_to = y;

// Set initial camera position immediately (don't wait for Step)
camera_set_view_pos(cam, x - (cam_width * 0.5), y - (cam_height * 0.5));
