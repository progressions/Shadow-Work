// Sync is_active state with PauseLayer visibility
var _was_active = is_active;
is_active = layer_get_visible("PauseLayer");

// When pause menu opens, refresh button list
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

	// Initialize the button list (this will select button 0 by default)
	init_buttons(_button_instances);

	// If returning from a child panel, restore the saved selection
	if (selected_index_to_restore >= 0) {
		selected_index = selected_index_to_restore;
		update_button_visuals();
		selected_index_to_restore = -1; // Reset for next time
	}

	// Skip input processing this frame to avoid consuming the keypress that opened/returned to this menu
	exit;
}

// Escape to close all menus and return to gameplay
if (is_active && keyboard_check_pressed(vk_escape)) {
	// Close all menu layers
	layer_set_visible("PauseLayer", false);
	layer_set_visible("SettingsLayer", false);
	layer_set_visible("SaveLoadLayer", false);

	// Unpause the game
	global.game_paused = false;

	// Exit early to skip normal input processing
	exit;
}

// Call parent Step event to handle navigation input
event_inherited();
