// Sync is_active state with SettingsLayer visibility
var _was_active = is_active;
is_active = layer_get_visible("SettingsLayer");

// When settings menu opens, refresh button list and reset selection
if (is_active && !_was_active) {
	// Find all buttons on MY layer and order them by button_id
	var _all_buttons = [];
	var _my_layer_id = layer_get_id(my_layer);

	with (obj_button) {
		// Only include buttons that are on this controller's layer
		if (layer_get_id(layer_get_name(layer)) == _my_layer_id) {
			array_push(_all_buttons, {
				instance: id,
				button_id: button_id
			});
		}
	}

	// Sort buttons by button_id to ensure correct ordering
	array_sort(_all_buttons, function(_a, _b) {
		return _a.button_id - _b.button_id;
	});

	// Extract instance IDs into button_list
	var _button_instances = [];
	for (var i = 0; i < array_length(_all_buttons); i++) {
		array_push(_button_instances, _all_buttons[i].instance);
	}

	// Initialize checkbox and slider states from global audio config BEFORE calling init_buttons()
	show_debug_message("Settings menu opened - found " + string(array_length(_button_instances)) + " buttons");
	for (var i = 0; i < array_length(_button_instances); i++) {
		var _button = _button_instances[i];
		show_debug_message("  Button " + string(i) + ": button_id=" + string(_button.button_id) + " object=" + object_get_name(_button.object_index));

		if (_button.button_id == 0) {
			// Master volume slider
			_button.value = global.audio_config.master_volume;
			show_debug_message("    -> Initialized master volume slider to " + string(_button.value));
		} else if (_button.button_id == 1) {
			// Music checkbox
			_button.enabled = global.audio_config.music_enabled;
			show_debug_message("    -> Initialized music checkbox to " + string(_button.enabled));
		} else if (_button.button_id == 2) {
			// Music volume slider
			_button.value = global.audio_config.music_volume;
			show_debug_message("    -> Initialized music volume slider to " + string(_button.value));
		} else if (_button.button_id == 3) {
			// SFX checkbox
			_button.enabled = global.audio_config.sfx_enabled;
			show_debug_message("    -> Initialized SFX checkbox to " + string(_button.enabled));
		} else if (_button.button_id == 4) {
			// SFX volume slider
			_button.value = global.audio_config.sfx_volume;
			show_debug_message("    -> Initialized SFX volume slider to " + string(_button.value));
		}
	}

	// Initialize the button list (this will call update_button_visuals which updates checkboxes)
	init_buttons(_button_instances);

	// Skip input processing this frame to avoid consuming the keypress that opened this menu
	exit;
}

// Escape to close all menus and return to gameplay
if (is_active && keyboard_check_pressed(vk_escape)) {
	// Close all menu layers
	layer_set_visible("SettingsLayer", false);
	layer_set_visible("PauseLayer", false);
	layer_set_visible("SaveLoadLayer", false);

	// Unpause the game
	global.game_paused = false;

	// Exit early to skip normal input processing
	exit;
}

// Call parent Step event to handle navigation input
event_inherited();

// Sync checkbox and slider states back to global audio config
if (is_active) {
	for (var i = 0; i < array_length(button_list); i++) {
		var _button = button_list[i];

		if (_button.button_id == 0) {
			// Master volume slider - sync to global config
			if (global.audio_config.master_volume != _button.value) {
				show_debug_message("SYNC: Master volume changed from " + string(global.audio_config.master_volume) + " to " + string(_button.value));
				global.audio_config.master_volume = _button.value;
			}
		} else if (_button.button_id == 1) {
			// Music checkbox - sync to global config
			if (global.audio_config.music_enabled != _button.enabled) {
				show_debug_message("SYNC: Music checkbox changed from " + string(global.audio_config.music_enabled) + " to " + string(_button.enabled));
				global.audio_config.music_enabled = _button.enabled;
			}
		} else if (_button.button_id == 2) {
			// Music volume slider - sync to global config
			if (global.audio_config.music_volume != _button.value) {
				show_debug_message("SYNC: Music volume changed from " + string(global.audio_config.music_volume) + " to " + string(_button.value));
				global.audio_config.music_volume = _button.value;
			}
		} else if (_button.button_id == 3) {
			// SFX checkbox - sync to global config
			if (global.audio_config.sfx_enabled != _button.enabled) {
				show_debug_message("SYNC: SFX checkbox changed from " + string(global.audio_config.sfx_enabled) + " to " + string(_button.enabled));
				global.audio_config.sfx_enabled = _button.enabled;
			}
		} else if (_button.button_id == 4) {
			// SFX volume slider - sync to global config
			if (global.audio_config.sfx_volume != _button.value) {
				show_debug_message("SYNC: SFX volume changed from " + string(global.audio_config.sfx_volume) + " to " + string(_button.value));
				global.audio_config.sfx_volume = _button.value;
			}
		}
	}
}
