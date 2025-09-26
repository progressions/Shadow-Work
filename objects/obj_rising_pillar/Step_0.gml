var player = instance_place(x, y, obj_player);
if (player != noone) {
    // Get player's actual height
    var player_height = 0;
    if (player.elevation_source != noone) {
        player_height = player.elevation_source.height;
    }
    
    // If we're not the highest pillar being touched, don't process
    if (player.current_highest_touching > height) {
        return;
    }
    
    // Check if player can step to this height
    if (height - player_height > 1) {
        // Too high - block movement
        with (player) {
            x = xprevious;
            y = yprevious;
        }
    } else if (player.x >= bbox_left && player.x <= bbox_right) {
        // Apply elevation only if center is over us
        player.elevation_source = self;
        player.y_offset = -y_offset;
    }
}