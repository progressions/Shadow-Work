/// @function is_instance_in_camera_view(_instance)
/// @description Check if an instance's bounding box is visible within view camera 0
/// @param _instance The instance to check
/// @return {bool} True if instance is visible in camera view
function is_instance_in_camera_view(_instance) {
	if (!instance_exists(_instance)) return false;

	// Get camera 0 bounds
	var _cam = view_camera[0];
	var _cam_x = camera_get_view_x(_cam);
	var _cam_y = camera_get_view_y(_cam);
	var _cam_w = camera_get_view_width(_cam);
	var _cam_h = camera_get_view_height(_cam);

	// Get instance bounding box
	var _inst_left = _instance.bbox_left;
	var _inst_right = _instance.bbox_right;
	var _inst_top = _instance.bbox_top;
	var _inst_bottom = _instance.bbox_bottom;

	// Check if instance bbox intersects with camera viewport
	var _in_view = !(_inst_right < _cam_x ||
	                  _inst_left > _cam_x + _cam_w ||
	                  _inst_bottom < _cam_y ||
	                  _inst_top > _cam_y + _cam_h);

	return _in_view;
}

/// @function check_vn_intro_triggers()
/// @description Check all instances with has_vn_intro flag and trigger if visible and not seen
function check_vn_intro_triggers() {
	// Exit early if VN already active or camera pan in progress
	if (global.vn_active) return;
	if (global.camera_pan_state.active) return;  // Don't trigger new intros during camera pan

	// Loop through all instances looking for VN intro flags
	with (all) {
		// Check if this instance has VN intro enabled
		if (!variable_instance_exists(id, "has_vn_intro")) continue;
		if (!has_vn_intro) continue;

		// Check if visible in camera
		if (!is_instance_in_camera_view(id)) continue;

		// Check if intro ID is defined
		if (!variable_instance_exists(id, "vn_intro_id")) {
			show_debug_message("Warning: Instance " + object_get_name(object_index) + " has has_vn_intro=true but no vn_intro_id");
			continue;
		}

		// Check if already seen
		if (variable_global_exists("vn_intro_seen")) {
			if (global.vn_intro_seen[$ vn_intro_id] == true) {
				continue; // Already seen, skip
			}
		}

		// Valid intro trigger found!
		show_debug_message("VN intro triggered for: " + vn_intro_id);

		// Get intro configuration from instance
		var _yarn_file = variable_instance_exists(id, "vn_intro_yarn_file") ? vn_intro_yarn_file : "";
		var _start_node = variable_instance_exists(id, "vn_intro_node") ? vn_intro_node : "Start";
		var _character_name = variable_instance_exists(id, "vn_intro_character_name") ? vn_intro_character_name : "";
		var _portrait_sprite = variable_instance_exists(id, "vn_intro_portrait_sprite") ? vn_intro_portrait_sprite : noone;
		var _intro_sfx = variable_instance_exists(id, "vn_intro_sfx") ? vn_intro_sfx : snd_vn_intro_discovered;

		// Validate yarn file exists
		if (_yarn_file == "") {
			show_debug_message("Error: VN intro triggered but no vn_intro_yarn_file specified");
			continue;
		}

		// Play intro discovery sound effect
		play_sfx(_intro_sfx, 1);

		// Immediately pause gameplay so the player can't move during the camera pan
		if (!global.game_paused) {
			global.game_paused = true;
		}

		// Store intro data for callback
		// IMPORTANT: Store the instance ID as a real number, not a reference
		var _intro_instance_id = id;  // This captures the numeric ID
		var _intro_id = vn_intro_id;

		// Create callback function to start VN intro after camera pan
		var _callback = method({
			intro_inst_id: _intro_instance_id,  // Numeric ID
			yarn_file: _yarn_file,
			start_node: _start_node,
			character_name: _character_name,
			portrait_sprite: _portrait_sprite,
			intro_id: _intro_id
		}, function() {
			show_debug_message("=== CAMERA PAN CALLBACK EXECUTING ===");

			// Find the instance by ID (or use noone if it no longer exists)
			var _inst = instance_exists(intro_inst_id) ? intro_inst_id : noone;

			// Start the VN intro
			start_vn_intro(_inst, yarn_file, start_node, character_name, portrait_sprite);

			// Mark as seen after VN is opened
			if (!variable_global_exists("vn_intro_seen")) {
				global.vn_intro_seen = {};
			}
			global.vn_intro_seen[$ intro_id] = true;
		});

		// Start camera pan to the instance, with callback to open VN when complete
		// Pan for 30 frames (0.5s), hold for 60 frames (1s), then open VN
		show_debug_message("About to call camera_pan_to_target for instance at x=" + string(x) + " y=" + string(y));
		camera_pan_to_target(id, 30, 60, _callback);

		// Fallback: if camera pan failed to start, execute the VN intro right away
		if (!global.camera_pan_state.active && is_method(_callback)) {
			show_debug_message("Camera pan failed to start; executing VN intro callback immediately");
			_callback();
		}

		// Only trigger one intro per frame
		break;
		}
	}

/// @function draw_vn_intro_debug()
/// @description Draw debug overlay showing camera bounds and VN intro flagged instances
function draw_vn_intro_debug() {
	// Get camera bounds
	var _cam = view_camera[0];
	var _cam_x = camera_get_view_x(_cam);
	var _cam_y = camera_get_view_y(_cam);
	var _cam_w = camera_get_view_width(_cam);
	var _cam_h = camera_get_view_height(_cam);

	// Draw camera viewport bounds (yellow outline)
	draw_set_color(c_yellow);
	draw_rectangle(_cam_x, _cam_y, _cam_x + _cam_w, _cam_y + _cam_h, true);

	// Draw all instances with has_vn_intro flag
	with (all) {
		if (!variable_instance_exists(id, "has_vn_intro")) continue;
		if (!has_vn_intro) continue;

		// Check if this intro has been seen
		var _seen = false;
		if (variable_instance_exists(id, "vn_intro_id") && variable_global_exists("vn_intro_seen")) {
			_seen = (global.vn_intro_seen[$ vn_intro_id] == true);
		}

		// Draw bbox in different colors: green = not seen, red = seen
		draw_set_color(_seen ? c_red : c_lime);
		draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);

		// Draw intro ID text above instance
		if (variable_instance_exists(id, "vn_intro_id")) {
			draw_set_halign(fa_center);
			draw_set_color(c_white);
			draw_text(x, bbox_top - 10, vn_intro_id);
			draw_set_halign(fa_left);
		}
	}

	// Draw seen intro IDs in top-left corner
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	var _y_offset = 10;
	draw_text(10, _y_offset, "VN Intro Debug (F3 to toggle)");
	_y_offset += 20;
	draw_text(10, _y_offset, "Green = not seen, Red = seen");
	_y_offset += 20;

	if (variable_global_exists("vn_intro_seen")) {
		var _seen_count = 0;
		var _keys = variable_struct_get_names(global.vn_intro_seen);
		for (var i = 0; i < array_length(_keys); i++) {
			if (global.vn_intro_seen[$ _keys[i]] == true) {
				_seen_count++;
				draw_text(10, _y_offset, "Seen: " + _keys[i]);
				_y_offset += 15;
			}
		}
		if (_seen_count == 0) {
			draw_text(10, _y_offset, "No intros seen yet");
		}
	}

	draw_set_color(c_white);
}

/// @function camera_pan_to_target(_target_instance, _duration, _hold_duration, _on_complete)
/// @description Start a camera pan from current position to center on target instance
/// @param _target_instance The instance to center the camera on
/// @param _duration Duration of pan in frames (default 30)
/// @param _hold_duration Frames to hold at target before callback (default 0)
/// @param _on_complete Optional callback function to execute when pan completes
function camera_pan_to_target(_target_instance, _duration = 30, _hold_duration = 0, _on_complete = undefined) {
	if (!instance_exists(_target_instance)) {
		show_debug_message("Warning: camera_pan_to_target called with invalid instance");
		return;
	}

	// Get current camera position
	var _cam = view_camera[0];
	var _current_x = camera_get_view_x(_cam);
	var _current_y = camera_get_view_y(_cam);

	// Calculate target camera position (centered on instance)
	var _cam_w = camera_get_view_width(_cam);
	var _cam_h = camera_get_view_height(_cam);
	var _target_x = _target_instance.x - (_cam_w / 2);
	var _target_y = _target_instance.y - (_cam_h / 2);

	show_debug_message("Camera pan setup: current=(" + string(_current_x) + "," + string(_current_y) + ") target=(" + string(_target_x) + "," + string(_target_y) + ")");

	// Set up pan state
	global.camera_pan_state.active = true;
	global.camera_pan_state.start_x = _current_x;
	global.camera_pan_state.start_y = _current_y;
	global.camera_pan_state.target_x = _target_x;
	global.camera_pan_state.target_y = _target_y;
	global.camera_pan_state.timer = 0;
	global.camera_pan_state.duration = _duration;
	global.camera_pan_state.hold_duration = _hold_duration;
	global.camera_pan_state.hold_timer = 0;
	global.camera_pan_state.on_complete = _on_complete;

	show_debug_message("Camera pan started to (" + string(_target_x) + ", " + string(_target_y) + ") over " + string(_duration) + " frames");
}

/// @function camera_pan_to_player(_duration, _hold_duration, _on_complete)
/// @description Start a camera pan from current position back to player
/// @param _duration Duration of pan in frames (default 30)
/// @param _hold_duration Frames to hold at player before callback (default 0)
/// @param _on_complete Optional callback function to execute when pan completes
function camera_pan_to_player(_duration = 30, _hold_duration = 0, _on_complete = undefined) {
	var _player = instance_find(obj_player, 0);

	if (!instance_exists(_player)) {
		show_debug_message("Warning: camera_pan_to_player called but obj_player doesn't exist");
		// Snap camera to 0,0 as fallback
		global.camera_pan_state.active = false;
		return;
	}

	// Get current camera position
	var _cam = view_camera[0];
	var _current_x = camera_get_view_x(_cam);
	var _current_y = camera_get_view_y(_cam);

	// Calculate target camera position (centered on player)
	var _cam_w = camera_get_view_width(_cam);
	var _cam_h = camera_get_view_height(_cam);
	var _target_x = _player.x - (_cam_w / 2);
	var _target_y = _player.y - (_cam_h / 2);

	// Set up pan state
	global.camera_pan_state.active = true;
	global.camera_pan_state.start_x = _current_x;
	global.camera_pan_state.start_y = _current_y;
	global.camera_pan_state.target_x = _target_x;
	global.camera_pan_state.target_y = _target_y;
	global.camera_pan_state.timer = 0;
	global.camera_pan_state.duration = _duration;
	global.camera_pan_state.hold_duration = _hold_duration;
	global.camera_pan_state.hold_timer = 0;
	global.camera_pan_state.on_complete = _on_complete;

	show_debug_message("Camera pan started back to player over " + string(_duration) + " frames");
}
