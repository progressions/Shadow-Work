// UI Controller - Parent class for keyboard-navigable interfaces
// Child classes should override on_button_activated() to define button actions

// Button navigation state
button_list = [];        // Array of button instance IDs (define in child Create event)
selected_index = 0;      // Current selected button index
is_active = false;       // Whether this controller is currently active

// Initialize button list and select first button
init_buttons = function(_button_list) {
	button_list = _button_list;
	selected_index = 0;
	update_button_visuals();
}

// Update button sprite frames based on selection
update_button_visuals = function() {
	for (var i = 0; i < array_length(button_list); i++) {
		var _button = button_list[i];
		if (instance_exists(_button)) {
			_button.image_index = (i == selected_index) ? 1 : 0;
		}
	}
}

// Navigate to previous button in list (W/A keys)
navigate_previous = function() {
	selected_index--;
	if (selected_index < 0) {
		selected_index = array_length(button_list) - 1; // Wrap around
	}
	update_button_visuals();
}

// Navigate to next button in list (S/D keys)
navigate_next = function() {
	selected_index++;
	if (selected_index >= array_length(button_list)) {
		selected_index = 0; // Wrap around
	}
	update_button_visuals();
}

// Activate currently selected button (Enter/E keys)
activate_selected_button = function() {
	if (array_length(button_list) > 0 && selected_index >= 0 && selected_index < array_length(button_list)) {
		var _button = button_list[selected_index];
		if (instance_exists(_button)) {
			on_button_activated(_button.button_id);
		}
	}
}

// Override this function in child classes to define button actions
on_button_activated = function(_button_id) {
	// Default implementation does nothing
	// Child classes should override this to handle specific button actions
}
