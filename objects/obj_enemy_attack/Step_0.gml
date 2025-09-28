// Animate the swing
swing_progress += swing_speed;

// Calculate current angle
image_angle = start_angle + (swing_range * (swing_progress / 100));

// Follow creator enemy
x = creator.x;
y = creator.y;

// Destroy when swing is complete
if (swing_progress >= 100) {
    instance_destroy();
    // Enemy returns to idle after attack completes
    if (instance_exists(creator)) {
        creator.state = PlayerState.idle;
    }
}