// Animate the swing
swing_progress += swing_speed;

// Calculate current angle
image_angle = start_angle + (swing_range * (swing_progress / 100));

// Follow creator enemy
if (instance_exists(creator)) {
    x = creator.x;
    y = creator.y;
} else {
    instance_destroy();
}

// Destroy when swing is complete
if (swing_progress >= 100) {
    // Enemy returns to idle after attack completes
    if (instance_exists(creator)) {
        creator.state = EnemyState.idle;
    }
    instance_destroy();
}