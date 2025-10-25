function player_dashing(){
// ============================================
    // CHECK FOR DOUBLE-TAP DASH (simplified)
    // ============================================
    if (state != PlayerState.dashing && dash_cooldown <= 0) {
        // Up button double-tap
        if (InputPressed(INPUT_VERB.UP)) {
            if (current_time - last_key_time_w < double_tap_time) {
                start_dash("up");
            }
            last_key_time_w = current_time;
        }

        // Left button double-tap
        if (InputPressed(INPUT_VERB.LEFT)) {
            if (current_time - last_key_time_a < double_tap_time) {
                start_dash("left");
            }
            last_key_time_a = current_time;
        }

        // Down button double-tap
        if (InputPressed(INPUT_VERB.DOWN)) {
            if (current_time - last_key_time_s < double_tap_time) {
                start_dash("down");
            }
            last_key_time_s = current_time;
        }

        // Right button double-tap
        if (InputPressed(INPUT_VERB.RIGHT)) {
            if (current_time - last_key_time_d < double_tap_time) {
                start_dash("right");
            }
            last_key_time_d = current_time;
        }
    }

    // ============================================
    // MOVEMENT
    // ============================================
    if (state == PlayerState.dashing) {
		obj_sfx_controller.play_sfx("dash", snd_dash)
		
        // Handle dash movement
        dash_timer--;
        if (dash_timer <= 0) {
            state = PlayerState.idle;
        }
        
        var dash_x = 0;
        var dash_y = 0;
        
        switch(facing_dir) {
            case "up":    dash_y = -dash_speed; break;
            case "down":  dash_y =  dash_speed; break;
            case "left":  dash_x = -dash_speed; break;
            case "right": dash_x =  dash_speed; break;
        }
        
        move_and_collide(dash_x, dash_y, tilemap);
        move_dir = "dash";
        
    } else {
        // idle movement
        _hor = InputX(INPUT_CLUSTER.NAVIGATION);
        _ver = InputY(INPUT_CLUSTER.NAVIGATION);
		 
        move_dir = "idle";
        if (_hor != 0 or _ver != 0) {
            if (_ver > 0) {
                move_dir = "down";
                facing_dir = "down";
            }
            else if (_ver < 0) {
                move_dir = "up";
                facing_dir = "up";
            }
            else if (_hor > 0) {
                move_dir = "right";
                facing_dir = "right";
            }
            else if (_hor < 0) {
                move_dir = "left";
                facing_dir = "left";
            }
        }
        
        // Get the tilemap from your path layer
        var tile_layer = layer_get_id("Tiles_Path");
        var tilemap_path = layer_tilemap_get_id(tile_layer);
        // Check if there's a path tile at the player's position
        var tile = tilemap_get_at_pixel(tilemap_path, x, y);
        // If there's no path tile (tile is 0 or empty), player is on grass
        if (tile == 0) {
            move_speed = 1; // Slower on grass
        } else {
            move_speed = 1.25; // idle speed on path
        }
        
        // Movement with collision
        var _collided = move_and_collide(_hor * move_speed, _ver * move_speed, tilemap);
        if (array_length(_collided) > 0) {
            // play_sfx(snd_bump, 1, false);
        }
		
    }

    if (dash_cooldown > 0) {
        dash_cooldown--;
    }
}