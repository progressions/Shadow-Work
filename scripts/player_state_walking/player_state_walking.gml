function player_state_walking() {
    // If staggered, can't continue walking - return to idle
    if (is_staggered) {
        state = PlayerState.idle;
        move_dir = "idle";
        return;
    }

    // Check for shield block input
    if (keyboard_check_pressed(ord("O"))) {
        // Check if shield is equipped
        if (equipped[$ "left_hand"] != undefined && block_cooldown <= 0) {
            // Enter shielding state
            state = PlayerState.shielding;
            shield_facing_dir = facing_dir;  // Lock to current facing direction
            shield_raise_complete = false;
            play_sfx(snd_shield_raise, 0.8);
            return;
        }
    }

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

    var _allow_focus_facing = player_focus_allows_facing_updates(self);

    // Update facing direction and move_dir
    if (_ver > 0) {
        move_dir = "down";
        if (_allow_focus_facing) facing_dir = "down";
    }
    else if (_ver < 0) {
        move_dir = "up";
        if (_allow_focus_facing) facing_dir = "up";
    }
    else if (_hor > 0) {
        move_dir = "right";
        if (_allow_focus_facing) facing_dir = "right";
    }
    else if (_hor < 0) {
        move_dir = "left";
        if (_allow_focus_facing) facing_dir = "left";
    }

    // Detect terrain at player position (for footstep sounds)
    var _terrain = get_terrain_at_position(x, y);

    // Apply terrain speed modifier (set by apply_terrain_effects in Step event)
    // and status effect speed modifiers
    var speed_modifier = get_status_effect_modifier("speed");
    var final_move_speed = move_speed * terrain_speed_modifier * speed_modifier;

    // Normalize diagonal input
    var _input_magnitude = sqrt(_hor * _hor + _ver * _ver);
    if (_input_magnitude > 0) {
        _hor /= _input_magnitude;
        _ver /= _input_magnitude;
    }

    // Acceleration-based movement (add to velocity instead of direct position change)
    velocity_x += _hor * acceleration * final_move_speed;
    velocity_y += _ver * acceleration * final_move_speed;

    // Cap velocity at max_velocity
    var _velocity_magnitude = sqrt(velocity_x * velocity_x + velocity_y * velocity_y);
    if (_velocity_magnitude > max_velocity * final_move_speed) {
        var _scale = (max_velocity * final_move_speed) / _velocity_magnitude;
        velocity_x *= _scale;
        velocity_y *= _scale;
    }

    // Apply velocity to position with collision
    var _collided = move_and_collide(velocity_x, velocity_y, tilemap);
    if (array_length(_collided) > 0) {
        // On collision, kill velocity in that direction
        for (var i = 0; i < array_length(_collided); i++) {
            var _collision = _collided[i];
            var _has_struct = is_struct(_collision);
            var _has_nx = _has_struct && variable_struct_exists(_collision, "nx");
            var _has_ny = _has_struct && variable_struct_exists(_collision, "ny");

            // Reduce velocity when hitting walls
            if (_has_nx && abs(_collision.nx) > 0.5) velocity_x *= 0.3;
            if (_has_ny && abs(_collision.ny) > 0.5) velocity_y *= 0.3;

            // Fallback dampening when no normal data is provided (e.g. dynamic bodies)
            if (!_has_struct || (!_has_nx && !_has_ny)) {
                velocity_x *= 0.3;
                velocity_y *= 0.3;
            }
        }
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

    // Check for pillar interaction while walking (only in grid puzzle rooms)
    if (instance_exists(obj_grid_controller)) {
        player_move_onto_pillar();
    }

    // Handle knockback
    player_handle_knockback();
}
