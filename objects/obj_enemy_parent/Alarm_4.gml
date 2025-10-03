// Stuck detection - if enemy hasn't moved in 1 second while targeting, try to unstick
if (state == EnemyState.targeting) {
    // Don't re-trigger if already in unstuck mode
    if (variable_instance_exists(self, "unstuck_mode") && unstuck_mode > 0) {
        // Still unsticking, wait
        alarm[4] = 60;
        return;
    }

    var _dist_moved = point_distance(x, y, stuck_check_x, stuck_check_y);

    if (_dist_moved < 5) {
        // Stuck! End path and enter unstuck mode
        show_debug_message("STUCK DETECTED - entering unstuck mode");

        // End current path if it exists
        if (path_exists(path)) {
            path_end();
        }

        // Enter unstuck mode - move in random direction
        if (!variable_instance_exists(self, "unstuck_mode")) {
            unstuck_mode = 0;
        }

        if (!variable_instance_exists(self, "unstuck_attempts")) {
            unstuck_attempts = 0;
        }

        unstuck_mode = 45; // Move for 45 frames (3/4 second)
        unstuck_attempts++;

        // Try different directions based on attempt count
        var _directions = [0, 90, 180, 270, 45, 135, 225, 315];
        unstuck_direction = _directions[unstuck_attempts % array_length(_directions)];

        show_debug_message("ALARM4: Set unstuck_mode=" + string(unstuck_mode) + " direction=" + string(unstuck_direction) + " attempt #" + string(unstuck_attempts));

        // Force path recalculation after unstuck finishes
        alarm[0] = 50;
    } else {
        // Moved successfully, reset attempt counter
        if (variable_instance_exists(self, "unstuck_attempts")) {
            unstuck_attempts = 0;
        }
    }
}

// Update position and reset alarm
stuck_check_x = x;
stuck_check_y = y;
alarm[4] = 60; // Check again in 1 second
