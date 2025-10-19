// Sync is_active state with PauseLayer visibility
var _was_active = is_active;
is_active = layer_get_visible("PauseLayer");

// When pause menu opens, refresh button list
if (is_active && !_was_active) {
	// Find all buttons and order them by button_id
	var _all_buttons = [];
	with (obj_button) {
		array_push(_all_buttons, {
			instance: id,
			button_id: button_id
		});
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
		show_debug_message("Pause Nav: Restoring selection to index " + string(selected_index));
		selected_index_to_restore = -1; // Reset for next time
	}

	show_debug_message("Pause Nav: Found " + string(array_length(button_list)) + " buttons");
	for (var i = 0; i < array_length(button_list); i++) {
		var _btn = button_list[i];
		if (instance_exists(_btn)) {
			show_debug_message("  Button " + string(i) + ": ID=" + string(_btn.button_id));
		}
	}

	// Skip input processing this frame to avoid consuming the keypress that opened/returned to this menu
	exit;
}

// Call parent Step event to handle navigation input
event_inherited();
