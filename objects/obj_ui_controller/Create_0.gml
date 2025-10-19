// UI Controller - Parent class for keyboard-navigable interfaces
// Child classes should override on_button_activated() to define button actions

// Button navigation state
button_list = [];        // Array of button instance IDs (define in child Create event)
selected_index = 0;      // Current selected button index
is_active = false;       // Whether this controller is currently active

// Panel linking state
my_layer = "";           // The layer this controller manages (set in child Create)
selected_index_to_restore = -1;  // Index to restore when returning from child panel

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
			show_debug_message("UI Controller: Calling on_button_activated with button_id=" + string(_button.button_id));
			on_button_activated(_button.button_id);
		} else {
			show_debug_message("UI Controller: Button instance does not exist");
		}
	} else {
		show_debug_message("UI Controller: Invalid state - button_list length=" + string(array_length(button_list)) + ", selected_index=" + string(selected_index));
	}
}

// Open a child panel from current selection
// Automatically stores current selection for restoration when returning
open_child_panel = function(_child_layer) {
	selected_index_to_restore = selected_index;
	layer_set_visible(_child_layer, true);
	layer_set_visible(my_layer, false);
	show_debug_message("UI Controller (" + my_layer + "): Opening child panel " + _child_layer + ", saving selection index " + string(selected_index));
}

// Close this panel and return to parent
// Parent will automatically restore its selection
close_and_return_to_parent = function(_parent_layer) {
	layer_set_visible(my_layer, false);
	layer_set_visible(_parent_layer, true);
	show_debug_message("UI Controller (" + my_layer + "): Closing and returning to " + _parent_layer);
}

// Override this function in child classes to define button actions
on_button_activated = function(_button_id) {
	// Default implementation does nothing
	// Child classes should override this to handle specific button actions
}
