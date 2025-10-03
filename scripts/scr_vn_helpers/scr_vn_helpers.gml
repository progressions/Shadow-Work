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
	// Set global VN state
	global.vn_active = true;
	global.game_paused = true;
	global.vn_companion = _companion_instance;
	global.vn_yarn_file = _yarn_file;

	// Save and disable SFX to stop all looped sounds
	global.vn_saved_sfx_enabled = global.audio_config.sfx_enabled;
	global.audio_config.sfx_enabled = false;

	// Always reload yarn file from disk to pick up changes
	ChatterboxLoadFromFile(_yarn_file);
	global.vn_chatterbox = ChatterboxCreate(_yarn_file);

	// Initialize recruitment variables
	if (_companion_instance.companion_id == "canopy") {
		ChatterboxVariableSet("canopy_recruited", _companion_instance.is_recruited);
	}
	if (_companion_instance.companion_id == "hola") {
		ChatterboxVariableSet("hola_recruited", _companion_instance.is_recruited);
	}
	if (_companion_instance.companion_id == "yorna") {
		ChatterboxVariableSet("yorna_recruited", _companion_instance.is_recruited);
	}

	// Jump to starting node
	ChatterboxJump(global.vn_chatterbox, _start_node);
}

// Stop VN dialogue mode and return to gameplay
function stop_vn_dialogue() {
	global.vn_active = false;
	global.game_paused = false;
	global.vn_companion = undefined;
	global.vn_chatterbox = undefined;
	global.vn_yarn_file = "";

	// Restore SFX state (looped sounds will restart automatically from player state)
	global.audio_config.sfx_enabled = global.vn_saved_sfx_enabled;
}