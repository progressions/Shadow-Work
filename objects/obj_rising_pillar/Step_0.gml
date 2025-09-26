var player = instance_place(x, y, obj_player);
if (player != noone) {
    // Check if player is truly on ground (no elevation source) or on a pillar
    var player_on_ground = (player.elevation_source == noone);
    var player_height = 0;
    
    if (!player_on_ground) {
        player_height = player.elevation_source.height;
    }
    
    // If we're not the highest pillar being touched, don't process
    if (player.current_highest_touching > height) {
        return;
    }
    
    // Check if player can step to this height
    if (player_on_ground && height > 0) {
        // On actual ground, can only step to low pillars (height 0)
        with (player) {
            x = xprevious;
            y = yprevious;
        }
    } else if (!player_on_ground && height - player_height > 1) {
        // On a pillar, can step up by 1
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