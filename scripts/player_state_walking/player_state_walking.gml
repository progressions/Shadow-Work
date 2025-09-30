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

    // Detect terrain at player position
    var _terrain = get_terrain_at_position(x, y);

    // Set movement speed based on terrain
    if (_terrain == "path") {
        move_speed = 1.25; // Faster on path
    } else {
        move_speed = 1; // Normal speed on grass/other terrain
    }

    // Apply status effect speed modifiers
    var speed_modifier = get_status_effect_modifier("speed");
    var final_move_speed = move_speed * speed_modifier;

    // Movement with collision
    var _collided = move_and_collide(_hor * final_move_speed, _ver * final_move_speed, tilemap);
    if (array_length(_collided) > 0) {
        // play_sfx(snd_bump, 1, false);
    }

    // Get footstep sound for current terrain
    var _footstep_sound = global.terrain_footstep_sounds[$ _terrain];

    // Fallback to grass sound if terrain has no defined sound
    if (_footstep_sound == undefined) {
        _footstep_sound = snd_footsteps_grass;
    }

    // Play appropriate footstep sound
    play_sfx(_footstep_sound, 0.3, 4, true);

    // Stop all other terrain footstep sounds
    var _terrain_names = variable_struct_get_names(global.terrain_footstep_sounds);
    for (var i = 0; i < array_length(_terrain_names); i++) {
        var _other_sound = global.terrain_footstep_sounds[$ _terrain_names[i]];
        if (_other_sound != _footstep_sound) {
            stop_looped_sfx(_other_sound);
        }
    }

    // Check for pillar interaction while walking
    player_move_onto_pillar();

    // Handle knockback
    player_handle_knockback();
}