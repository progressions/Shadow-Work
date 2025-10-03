// Only process VN input when active
if (!global.vn_active) exit;

// Get current dialogue state
if (global.vn_chatterbox != undefined) {
	var _chatterbox = global.vn_chatterbox;

	// Check if we've reached an exit node FIRST
	var _current_node = ChatterboxGetCurrent(_chatterbox);
	if (_current_node == "Exit" || _current_node == "Quit" || _current_node == "End") {
		stop_vn_dialogue();
		exit;
	}

	// Parse current text for speaker name
	var _content = ChatterboxGetContent(_chatterbox, 0);

	// Extract speaker name (format: "Name: Text")
	if (string_pos(":", _content) > 0) {
		var _colon_pos = string_pos(":", _content);
		current_speaker = string_copy(_content, 1, _colon_pos - 1);
		current_text = string_delete(_content, 1, _colon_pos + 1);
		current_text = string_trim(current_text);
	} else {
		current_speaker = "";
		current_text = _content;
	}

	var _option_count = ChatterboxGetOptionCount(_chatterbox);

	// Handle input
	if (_option_count > 0) {
		// Choices available - navigate and select
		// Up = decrease index (move up the list)
		if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
			selected_choice--;
			if (selected_choice < 0) selected_choice = _option_count - 1;
			show_debug_message("Selected choice: " + string(selected_choice));
		}

		// Down = increase index (move down the list)
		if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
			selected_choice++;
			if (selected_choice >= _option_count) selected_choice = 0;
			show_debug_message("Selected choice: " + string(selected_choice));
		}

		// Use Enter to select choices (Space might be consumed elsewhere)
		if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("E"))) {
			show_debug_message("Selecting choice: " + string(selected_choice));
			ChatterboxSelect(_chatterbox, selected_choice);
			selected_choice = 0;
		}
	} else {
		// No choices - advance dialogue
		if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("E"))) {
			if (ChatterboxIsWaiting(_chatterbox)) {
				show_debug_message("Continuing dialogue");
				ChatterboxContinue(_chatterbox);

				// Check if companion was recruited AFTER continuing (so the <<set>> command has executed)
				if (global.vn_companion != undefined) {
					var _companion_id = global.vn_companion.companion_id;

					// Check Canopy recruitment
					if (_companion_id == "canopy") {
						var _recruited = ChatterboxVariableGet("canopy_recruited");
						show_debug_message("canopy_recruited variable: " + string(_recruited));
						show_debug_message("is_recruited flag: " + string(global.vn_companion.is_recruited));
						if (_recruited == true && !global.vn_companion.is_recruited) {
							// Recruit Canopy using the proper function (activates auras)
							recruit_companion(global.vn_companion, obj_player);
							show_debug_message("Canopy recruited!");

							// Close dialogue immediately after recruitment
							stop_vn_dialogue();
							exit;
						}
					}

					// Check Hola recruitment
					if (_companion_id == "hola") {
						var _recruited = ChatterboxVariableGet("hola_recruited");
						show_debug_message("hola_recruited variable: " + string(_recruited));
						show_debug_message("is_recruited flag: " + string(global.vn_companion.is_recruited));
						if (_recruited == true && !global.vn_companion.is_recruited) {
							// Recruit Hola using the proper function (activates auras)
							recruit_companion(global.vn_companion, obj_player);
							show_debug_message("Hola recruited!");

							// Close dialogue immediately after recruitment
							stop_vn_dialogue();
							exit;
						}
					}

					// Check Yorna recruitment
					if (_companion_id == "yorna") {
						var _recruited = ChatterboxVariableGet("yorna_recruited");
						show_debug_message("yorna_recruited variable: " + string(_recruited));
						show_debug_message("is_recruited flag: " + string(global.vn_companion.is_recruited));
						if (_recruited == true && !global.vn_companion.is_recruited) {
							// Recruit Yorna using the proper function (activates auras)
							recruit_companion(global.vn_companion, obj_player);
							show_debug_message("Yorna recruited!");

							// Close dialogue immediately after recruitment
							stop_vn_dialogue();
							exit;
						}
					}
				}
			} else {
				// Check if we've reached the end
				var _current_node = ChatterboxGetCurrent(_chatterbox);
				show_debug_message("Current node: " + _current_node);
				if (_current_node == "Exit" || _current_node == "Quit" || _current_node == "End") {
					show_debug_message("Stopping VN dialogue");
					stop_vn_dialogue();
				}
			}
		}
	}
}
