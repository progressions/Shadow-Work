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

// F3 key to toggle VN intro debug overlay - works even when paused
if (keyboard_check_pressed(vk_f3)) {
	global.debug_vn_intro = !global.debug_vn_intro;
	show_debug_message("VN Intro Debug: " + (global.debug_vn_intro ? "ON" : "OFF"));
}

// F4 key to toggle enemy approach variation debug visualization
if (keyboard_check_pressed(vk_f4)) {
	global.debug_enemy_approach = !global.debug_enemy_approach;
	show_debug_message("Enemy Approach Debug: " + (global.debug_enemy_approach ? "ON" : "OFF"));
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
