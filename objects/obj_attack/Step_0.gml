// Animate the swing
swing_progress += swing_speed;

// Calculate current angle
image_angle = start_angle + (swing_range * (swing_progress / 100));

// Follow player
x = creator.x;
y = creator.y;

// Destroy when swing is complete
if (swing_progress >= 100) {
    instance_destroy();
	creator.state = PlayerState.idle;
}