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
	// Slider is selected: A/D adjust value (with hold support), W/S navigate

	// Decrease slider value (A key)
	if (keyboard_check(ord("A"))) {
		if (slider_input_delay <= 0) {
			_current_button.adjust_value(-1);
			// Use initial delay for first repeat, then faster repeat rate
			slider_input_delay = slider_first_input ? slider_repeat_rate : slider_initial_delay;
			slider_first_input = true;
		} else {
			slider_input_delay--;
		}
	}
	// Increase slider value (D key)
	else if (keyboard_check(ord("D"))) {
		if (slider_input_delay <= 0) {
			_current_button.adjust_value(1);
			// Use initial delay for first repeat, then faster repeat rate
			slider_input_delay = slider_first_input ? slider_repeat_rate : slider_initial_delay;
			slider_first_input = true;
		} else {
			slider_input_delay--;
		}
	}
	// Reset delay when keys are released
	else {
		slider_input_delay = 0;
		slider_first_input = false;
	}

	// Navigate away from slider
	if (keyboard_check_pressed(ord("W"))) {
		navigate_previous();
		slider_input_delay = 0;
		slider_first_input = false;
	}

	if (keyboard_check_pressed(ord("S"))) {
		navigate_next();
		slider_input_delay = 0;
		slider_first_input = false;
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
