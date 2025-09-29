function player_state_walking() {
    // Check for dash input first
    if (player_handle_dash_input()) {
        return; // Dash was triggered, state changed
    }

    // Check for input
    var _hor = keyboard_check(ord("D")) - keyboard_check(ord("A"));
    var _ver = keyboard_check(ord("S")) - keyboard_check(ord("W"));

    // If no input, transition to idle
    if (_hor == 0 && _ver == 0) {
        state = PlayerState.idle;
        move_dir = "idle";
        return;
    }

    // Update facing direction and move_dir
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

    // Get the tilemap from your path layer
    var tile_layer = layer_get_id("Tiles_Path");
    var tilemap_path = layer_tilemap_get_id(tile_layer);
    // Check if there's a path tile at the player's position
    var tile = tilemap_get_at_pixel(tilemap_path, x, y);
    // If there's no path tile (tile is 0 or empty), player is on grass
    if (tile == 0) {
        move_speed = 1; // Slower on grass
    } else {
        move_speed = 1.25; // normal speed on path
    }

    // Apply status effect speed modifiers
    var speed_modifier = get_status_effect_modifier("speed");
    var final_move_speed = move_speed * speed_modifier;

    // Movement with collision
    var _collided = move_and_collide(_hor * final_move_speed, _ver * final_move_speed, tilemap);
    if (array_length(_collided) > 0) {
        play_sfx(snd_bump, 1, false);
    }

    // Check for pillar interaction while walking
    player_move_onto_pillar();

    // Handle knockback
    player_handle_knockback();
}