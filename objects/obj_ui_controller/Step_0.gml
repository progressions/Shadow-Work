// Only process input if active and buttons are defined
if (!is_active || array_length(button_list) == 0) {
	exit;
}

// Check if currently selected button is a slider
var _current_button = noone;
var _is_slider = false;
if (selected_index >= 0 && selected_index < array_length(button_list)) {
	_current_button = button_list[selected_index];
	if (instance_exists(_current_button)) {
		_is_slider = (_current_button.object_index == obj_slider);
	}
}

if (_is_slider) {
	// Slider is selected: A/D adjust value, W/S navigate
	if (keyboard_check_pressed(ord("A"))) {
		_current_button.adjust_value(-1);
	}

	if (keyboard_check_pressed(ord("D"))) {
		_current_button.adjust_value(1);
	}

	if (keyboard_check_pressed(ord("W"))) {
		navigate_previous();
	}

	if (keyboard_check_pressed(ord("S"))) {
		navigate_next();
	}
} else {
	// Normal button/checkbox: W/A = previous, S/D = next
	if (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(ord("A"))) {
		navigate_previous();
	}

	if (keyboard_check_pressed(ord("S")) || keyboard_check_pressed(ord("D"))) {
		navigate_next();
	}
}

// Activate selected button (Enter or E) - works for all button types
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("E"))) {
	activate_selected_button();
}
