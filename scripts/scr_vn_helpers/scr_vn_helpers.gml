function wrap(_val, _min, _max) {
	if (_val > _max) return _min;
	else if (_val < _min) return max;
	else return _val;
}

function draw_rectangle_center(_x, _y, _width, _height, _outline, _color, _alpha) {
	var _old_color = draw_get_color();
	var _old_alpha = draw_get_alpha();
	
	draw_set_color(_color);
	draw_set_alpha(_alpha);
	
	draw_rectangle(_x - _width / 2, _y - _height / 2, _x + _width / 2, _y + _height / 2, _outline);
	
	draw_set_color(_old_color);
	draw_set_alpha(_old_alpha);
}

function background_set_index(_index) {
	var lay_id = layer_get_id("Background");
	var back_id = layer_background_get_id(lay_id);

	layer_background_index(back_id, _index);
}

function chatterbox_update() {
	node = ChatterboxGetCurrent(chatterbox);
	text = ChatterboxGetContent(chatterbox, 0);
}

// Start VN dialogue mode with a specific companion and yarn file
function start_vn_dialogue(_companion_instance, _yarn_file, _start_node) {
	// Play VN open sound
	play_sfx(snd_vn_open, 1);

	// Save current song to restore later (only save on first VN open, not nested ones)
	if (!variable_global_exists("vn_previous_song")) {
		global.vn_previous_song = noone;
	}

	if (global.vn_previous_song == noone) {
		global.vn_previous_song = obj_music_controller.song_asset;
	}

	// Play companion theme if they have one (always switch, even if reopening)
	if (_companion_instance != noone && instance_exists(_companion_instance)) {
		if (variable_instance_exists(_companion_instance, "theme_song")) {
			// Switch to companion theme
			set_song_ingame(_companion_instance.theme_song, 0, 0);
		}
	}

	// Set global VN state
	global.vn_active = true;
	global.game_paused = true;
	global.vn_companion = _companion_instance;
	global.vn_yarn_file = _yarn_file;

	// Stop all currently playing looped sounds (footsteps, etc.)
	stop_all_footstep_sounds();

	// Always reload yarn file from disk to pick up changes
	ChatterboxLoadFromFile(_yarn_file);
	global.vn_chatterbox = ChatterboxCreate(_yarn_file);

	// Initialize return_to_menu flag
	if (!variable_global_exists("return_to_menu")) {
		ChatterboxVariableDefault("return_to_menu", false);
	}

	// Initialize recruitment variables (only if we have a companion instance)
	if (_companion_instance != noone && instance_exists(_companion_instance)) {
		if (_companion_instance.companion_id == "canopy") {
			ChatterboxVariableSet("canopy_recruited", _companion_instance.is_recruited);
		}
		if (_companion_instance.companion_id == "hola") {
			ChatterboxVariableSet("hola_recruited", _companion_instance.is_recruited);
		}
		if (_companion_instance.companion_id == "yorna") {
			ChatterboxVariableSet("yorna_recruited", _companion_instance.is_recruited);
		}
	}

	// Jump to starting node
	ChatterboxJump(global.vn_chatterbox, _start_node);
}

// Stop VN dialogue mode and return to gameplay
function stop_vn_dialogue() {
	// Check if we need to return to menu or open a companion talk
	var selected_companion = undefined;
	var return_to_menu = false;
	var should_restore_sfx = true;

	if (global.vn_chatterbox != undefined) {
		if (global.vn_yarn_file == "CompanionTalkMenu.yarn") {
			selected_companion = ChatterboxVariableGet("selected_companion");
		} else {
			// Check if we're returning to menu from a talk dialogue
			var _found = ChatterboxVariablesFind("return_to_menu", 0, true);
			if (array_length(_found) > 0) {
				return_to_menu = ChatterboxVariableGet("return_to_menu");
			}
		}
	}

	// Store whether we'll be reopening a VN
	var will_reopen_vn = (return_to_menu == true) || (selected_companion != undefined && selected_companion != "");

	// Play VN close sound and restore music only if not reopening another VN
	if (!will_reopen_vn) {
		play_sfx(snd_vn_close, 1);
		// Restore previous music if we saved it
		if (variable_global_exists("vn_previous_song") && global.vn_previous_song != noone) {
			set_song_ingame(global.vn_previous_song, 0, 0);
			global.vn_previous_song = noone;
		}
	}

	global.vn_active = false;
	global.game_paused = false;
	global.vn_companion = undefined;
	global.vn_chatterbox = undefined;
	global.vn_yarn_file = "";

	// If returning to menu, reopen it
	if (return_to_menu == true) {
		open_companion_talk_menu();
	}
	// If a companion was selected from the menu, open their talk dialogue
	else if (selected_companion != undefined && selected_companion != "") {
		// Find the companion instance
		var companion_instance = noone;
		with (obj_companion_parent) {
			if (companion_id == selected_companion) {
				companion_instance = id;
				break;
			}
		}

		if (companion_instance != noone) {
			start_vn_dialogue(companion_instance, selected_companion + "_talk.yarn", "Start");
		}
	}
}

// Open the companion talk menu
function open_companion_talk_menu() {
	// Declare and set availability flags for each companion based on recruitment
	with (obj_companion_parent) {
		var _var_name = companion_id + "_available";
		// Declare variable if it doesn't exist
		if (!variable_global_exists(_var_name)) {
			ChatterboxVariableDefault(_var_name, false);
		}
		ChatterboxVariableSet(_var_name, is_recruited);
	}

	// Declare and clear any previous selection
	if (!variable_global_exists("selected_companion")) {
		ChatterboxVariableDefault("selected_companion", "");
	}
	ChatterboxVariableSet("selected_companion", "");

	// Declare and clear return to menu flag
	if (!variable_global_exists("return_to_menu")) {
		ChatterboxVariableDefault("return_to_menu", false);
	}
	ChatterboxVariableSet("return_to_menu", false);

	// Open the companion menu
	start_vn_dialogue(noone, "CompanionTalkMenu.yarn", "Start");
}