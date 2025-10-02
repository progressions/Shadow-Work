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
    // Enemy returns to targeting or idle after attack completes
    if (instance_exists(creator)) {
        // Check if player is still within aggro range
        if (instance_exists(obj_player)) {
            var _dist = point_distance(creator.x, creator.y, obj_player.x, obj_player.y);
            if (_dist <= creator.aggro_distance) {
                creator.state = EnemyState.targeting;
                creator.alarm[0] = 1; // Trigger immediate path recalculation
            } else {
                creator.state = EnemyState.idle;
            }
        } else {
            creator.state = EnemyState.idle;
        }
    }
    instance_destroy();
}