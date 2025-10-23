// Top of obj_player Step Event - BEFORE everything else:

// Ensure lighting controller exists every frame
if (!instance_exists(obj_lighting_controller)) {
    var _layer = "Instances";
    if (!layer_exists(_layer)) {
        var _first_layer_id = layer_get_id(0);
        _layer = layer_get_name(_first_layer_id);
    }
    instance_create_layer(0, 0, _layer, obj_lighting_controller);
}

// Apply camera pan position override BEFORE anything draws
if (global.camera_pan_state.active) {
	
	// Disable room's automatic camera following during pan
	var _cam = view_camera[0];
	camera_set_view_target(_cam, noone);

	var _progress = global.camera_pan_state.timer / global.camera_pan_state.duration;

	// Clamp progress to 1.0 when holding (so camera stays at target)
	if (_progress > 1) _progress = 1;

	// Use smoothstep for ease-in-out interpolation (smoother than linear lerp)
	_progress = _progress * _progress * (3 - 2 * _progress);

	var _current_x = lerp(global.camera_pan_state.start_x, global.camera_pan_state.target_x, _progress);
	var _current_y = lerp(global.camera_pan_state.start_y, global.camera_pan_state.target_y, _progress);

	camera_set_view_pos(_cam, _current_x, _current_y);
} else if (global.vn_active) {
	// Keep camera detached during VN (it's positioned at the target from the pan)
	camera_set_view_target(view_camera[0], noone);
} else {
	
	// Re-enable camera following player when not panning and VN not active
	var _player = instance_find(obj_player, 0);
	if (instance_exists(_player)) {
		camera_set_view_target(view_camera[0], _player);
	}
}

// M key to toggle audio - works even when paused
if (keyboard_check_pressed(ord("M"))) {
	global.audio_config.sfx_enabled = !global.audio_config.sfx_enabled;
	global.audio_config.music_enabled = !global.audio_config.music_enabled;
}


// Update camera pan state (increment timer, detect completion)
// IMPORTANT: This must run even when paused so VN intros work correctly

if (global.camera_pan_state.active) {
	global.camera_pan_state.timer++;

	if (global.camera_pan_state.timer % 10 == 0) {
		show_debug_message("Camera pan progress: " + string(global.camera_pan_state.timer) + "/" + string(global.camera_pan_state.duration));
	}

	// Check if pan is complete
	if (global.camera_pan_state.timer >= global.camera_pan_state.duration) {
		// Pan motion complete, now hold at target
		global.camera_pan_state.hold_timer++;

		if (global.camera_pan_state.hold_timer == 1) {
			show_debug_message("Camera pan completed, holding for " + string(global.camera_pan_state.hold_duration) + " frames");
		}

		// Check if hold duration complete
		if (global.camera_pan_state.hold_timer >= global.camera_pan_state.hold_duration) {
			global.camera_pan_state.active = false;
			show_debug_message("Camera hold complete, executing callback");

			// Execute callback if one was provided
			if (global.camera_pan_state.on_complete != undefined) {
				var _callback = global.camera_pan_state.on_complete;
				global.camera_pan_state.on_complete = undefined; // Clear callback
				_callback(); // Execute callback
			}
		}
	}
}

// Handle slow-motion effect
if (slowmo_active) {
    slowmo_timer--;

    // When slowmo duration ends, start recovery
    if (slowmo_timer <= 0) {
        slowmo_active = false;
        slowmo_timer = 0;
    }
}

// Handle slow-motion recovery (smooth transition back to normal speed)
if (!slowmo_active && slowmo_current_speed < 60) {
    slowmo_recovery_timer--;

    // Lerp back to normal speed over recovery period
    var _recovery_progress = 1 - (slowmo_recovery_timer / 15);
    slowmo_current_speed = lerp(30, 60, _recovery_progress);

    // Apply interpolated speed
    game_set_speed(slowmo_current_speed, gamespeed_fps);

    // Reset when fully recovered
    if (slowmo_recovery_timer <= 0) {
        slowmo_current_speed = 60;
        game_set_speed(60, gamespeed_fps);
        slowmo_recovery_timer = 0;
    }
}

// Tick slow-motion cooldown so repeated triggers space out
if (slowmo_cooldown_timer > 0) {
    slowmo_cooldown_timer--;
}

// Handle screen shake (applies camera offset)
if (shake_timer > 0) {
    shake_timer--;

    // Apply random offset to camera
    var _cam = view_camera[0];
    var _shake_x = random_range(-shake_intensity, shake_intensity);
    var _shake_y = random_range(-shake_intensity, shake_intensity);

    var _base_x = camera_get_view_x(_cam);
    var _base_y = camera_get_view_y(_cam);

    camera_set_view_pos(_cam, _base_x + _shake_x, _base_y + _shake_y);

    // Decay shake intensity
    shake_intensity *= shake_decay;

    // Stop shaking when intensity is very low
    if (shake_intensity < 0.5) {
        shake_intensity = 0;
        shake_timer = 0;
    }
}

// Handle freeze frame countdown
if (freeze_active) {
    freeze_timer--;
    if (freeze_timer <= 0) {
        freeze_active = false;
        freeze_timer = 0;
    }
    // While freeze is active, pause most game logic (but not camera or debug keys)
    return;
}

if (global.game_paused) return;

global.idle_bob_timer += 0.05;
if (global.idle_bob_timer >= 2) {
    global.idle_bob_timer -= 2;
}

// Decrement startup delay timer
if (global.vn_intro_startup_delay > 0) {
    global.vn_intro_startup_delay--;
}

// Check for VN intro triggers (only when game is not paused and after startup delay)
if (global.vn_intro_startup_delay <= 0) {
    check_vn_intro_triggers();
}

// Autosave timer (only when game is not paused and player exists)
if (autosave_enabled && instance_exists(obj_player)) {
    autosave_timer--;

    if (autosave_timer <= 0) {
        // Trigger autosave
        auto_save();

        // Reset timer
        autosave_timer = autosave_interval;
    }
}
