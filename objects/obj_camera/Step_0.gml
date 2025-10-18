// Update target position if following an object
if (follow != noone && instance_exists(follow)) {
	// Base target is the follow object's position
	x_to = follow.x;
	y_to = follow.y;

	// If following the player, offset camera to look ahead in facing direction
	if (follow.object_index == obj_player) {
		var _look_ahead_distance = 32;

		// Add offset based on player's facing direction
		switch (follow.facing_dir) {
			case "down":
				y_to += _look_ahead_distance;
				break;
			case "up":
				y_to -= _look_ahead_distance;
				break;
			case "left":
				x_to -= _look_ahead_distance;
				break;
			case "right":
				x_to += _look_ahead_distance;
				break;
		}
	}
}

// Smooth camera movement (lerp)
x += (x_to - x) / 25;
y += (y_to - y) / 25;

// Update camera position
camera_set_view_pos(cam, x - (cam_width * 0.5), y - (cam_height * 0.5));

