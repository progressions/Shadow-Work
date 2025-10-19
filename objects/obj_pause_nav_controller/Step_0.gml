// Sync is_active state with pause menu visibility
var _was_active = is_active;
is_active = global.game_paused;

// When pause menu opens, refresh button list and reset selection
if (is_active && !_was_active) {
	// Find all buttons on the PauseLayer and order them by button_id
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

	// Initialize the button list
	init_buttons(_button_instances);
}

// Call parent Step event to handle navigation input
event_inherited();
