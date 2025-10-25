// Only process VN input when active
if (!global.vn_active) exit;

// Determine if this is a companion dialogue or generic intro
var _is_intro = (global.vn_intro_instance != undefined);

if (is_struct(dialogue_typist) && variable_global_exists("audio_config")) {
	var _audio_cfg = global.audio_config;
	var _has_sounds = array_length(dialogue_typist_sound_bank) > 0;
	var _final_volume = clamp(_audio_cfg.master_volume, 0, 1) * clamp(_audio_cfg.sfx_volume, 0, 1);
	var _should_enable = _audio_cfg.sfx_enabled && (_final_volume > 0) && _has_sounds;

	if (_should_enable) {
		dialogue_typist_sound_active = true;
		dialogue_typist_gain = dialogue_typist_base_volume * _final_volume;
	} else if (dialogue_typist_sound_active || (dialogue_typist_gain != 0)) {
		dialogue_typist_sound_active = false;
		dialogue_typist_gain = 0;
		dialogue_typist_sound_last_index = -1;
	}
}

// ESC key cancels VN dialogue at any point
if (keyboard_check_pressed(vk_escape)) {
	if (_is_intro) {
		stop_vn_intro();
	} else {
		stop_vn_dialogue();
	}
	exit;
}

// Get current dialogue state
if (global.vn_chatterbox != undefined) {
	var _chatterbox = global.vn_chatterbox;

	// Check if we've reached an exit node FIRST
	var _current_node = ChatterboxGetCurrent(_chatterbox);
	if (_current_node == "Exit" || _current_node == "Quit" || _current_node == "End") {
		if (_is_intro) {
			stop_vn_intro();
		} else {
			stop_vn_dialogue();
		}
		exit;
	}

	// Extract structured speaker/text data from Chatterbox
	var _content = ChatterboxGetContent(_chatterbox, 0);
	var _speaker = ChatterboxGetContentSpeaker(_chatterbox, 0, "");
	var _speech = ChatterboxGetContentSpeech(_chatterbox, 0, "");
	current_line_metadata = ChatterboxGetContentMetadata(_chatterbox, 0);

	if (_content == undefined) {
		_content = "";
		_speaker = "";
		_speech = "";
	}

	if (_content != current_raw_content) {
		current_raw_content = _content;
		dialogue_text_uid++;
		dialogue_text_cache_key = "vn_line:" + string(dialogue_text_uid);

		dialogue_typist.reset();
		dialogue_typist.in(dialogue_typist_speed, dialogue_typist_smoothness);
		dialogue_typist.ignore_delay(false);
	}

	current_speaker = _speaker;
	current_text = _speech;

	// For VN intros, override speaker name if vn_intro_character_name is set
	if (_is_intro && variable_global_exists("vn_intro_character_name") && global.vn_intro_character_name != "") {
		current_speaker = global.vn_intro_character_name;
	}

	var _option_count = ChatterboxGetOptionCount(_chatterbox);

	// Handle input
	if (_option_count > 0) {
		if (dialogue_typist != undefined && dialogue_typist.get_state() < 1) {
			dialogue_typist.skip();
		}

		// Choices available - navigate and select
		// Up or Left = decrease index (move to previous choice)
		if (InputPressed(INPUT_VERB.UP) || InputPressed(INPUT_VERB.LEFT)) {
			selected_choice--;
			if (selected_choice < 0) selected_choice = _option_count - 1;
			play_sfx(snd_vn_option_change, 1);
			show_debug_message("Selected choice: " + string(selected_choice));
		}

		// Down or Right = increase index (move to next choice)
		if (InputPressed(INPUT_VERB.DOWN) || InputPressed(INPUT_VERB.RIGHT)) {
			selected_choice++;
			if (selected_choice >= _option_count) selected_choice = 0;
			play_sfx(snd_vn_option_change, 1);
			show_debug_message("Selected choice: " + string(selected_choice));
		}

		// Use Enter/Interact to select choices
		if (keyboard_check_pressed(vk_enter) || InputPressed(INPUT_VERB.INTERACT)) {
			show_debug_message("Selecting choice: " + string(selected_choice));
			play_sfx(snd_vn_option_select, 1);
			current_raw_content = "";
			current_line_metadata = undefined;
			ChatterboxSelect(_chatterbox, selected_choice);
			selected_choice = 0;
		}
	} else {
		// No choices - advance dialogue
		if (keyboard_check_pressed(vk_enter) || InputPressed(INPUT_VERB.INTERACT)) {
			var _typist_ready = true;

			if (dialogue_typist != undefined && dialogue_typist.get_state() < 1) {
				dialogue_typist.skip();
				_typist_ready = false;
			}

			if (_typist_ready && ChatterboxIsWaiting(_chatterbox)) {
				show_debug_message("Continuing dialogue");
				current_raw_content = "";
				current_line_metadata = undefined;
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
			} else if (_typist_ready) {
				// Check if we've reached the end
				var _current_node = ChatterboxGetCurrent(_chatterbox);
				show_debug_message("Current node: " + _current_node);
				if (_current_node == "Exit" || _current_node == "Quit" || _current_node == "End") {
					show_debug_message("Stopping VN dialogue");
					if (_is_intro) {
						stop_vn_intro();
					} else {
						stop_vn_dialogue();
					}
				}
			}
		}
	}
}
