// Update target position if following an object
if (follow != noone && instance_exists(follow)) {
	// Base target is the follow object's position
	x_to = follow.x;
	y_to = follow.y;

	// If following the player, offset camera to look ahead in facing direction
	if (follow.object_index == obj_player) {
		var _base_look_ahead = 32; // Base distance when stationary
		// i will try different values to see if i want this:
		var _velocity_multiplier = 0; // Additional distance per unit of velocity

		// Calculate velocity magnitude in the facing direction
		var _directional_velocity = 0;
		switch (follow.facing_dir) {
			case "down":
				_directional_velocity = max(0, follow.velocity_y); // Only positive (moving down)
				break;
			case "up":
				_directional_velocity = max(0, -follow.velocity_y); // Only negative (moving up)
				break;
			case "left":
				_directional_velocity = max(0, -follow.velocity_x); // Only negative (moving left)
				break;
			case "right":
				_directional_velocity = max(0, follow.velocity_x); // Only positive (moving right)
				break;
		}

		// Calculate total look-ahead distance (base + velocity-based)
		var _look_ahead_distance = _base_look_ahead + (_directional_velocity * _velocity_multiplier);

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

