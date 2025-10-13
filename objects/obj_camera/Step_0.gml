// Update target position if following an object
if (follow != noone && instance_exists(follow)) {
	x_to = follow.x;
	y_to = follow.y;
}

// Smooth camera movement (lerp)
x += (x_to - x) / 25;
y += (y_to - y) / 25;

// Update camera position
camera_set_view_pos(cam, x - (cam_width * 0.5), y - (cam_height * 0.5));

