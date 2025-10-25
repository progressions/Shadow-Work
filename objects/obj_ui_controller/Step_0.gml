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
	// Slider is selected: LEFT/RIGHT adjust value (with hold support), UP/DOWN navigate

	// Decrease slider value (LEFT)
	if (InputCheck(INPUT_VERB.LEFT)) {
		if (slider_input_delay <= 0) {
			_current_button.adjust_value(-1);
			// Use initial delay for first repeat, then faster repeat rate
			slider_input_delay = slider_first_input ? slider_repeat_rate : slider_initial_delay;
			slider_first_input = true;
		} else {
			slider_input_delay--;
		}
	}
	// Increase slider value (RIGHT)
	else if (InputCheck(INPUT_VERB.RIGHT)) {
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
	if (InputPressed(INPUT_VERB.UP)) {
		navigate_previous();
		slider_input_delay = 0;
		slider_first_input = false;
	}

	if (InputPressed(INPUT_VERB.DOWN)) {
		navigate_next();
		slider_input_delay = 0;
		slider_first_input = false;
	}
} else {
	// Normal button/checkbox: UP/LEFT = previous, DOWN/RIGHT = next
	if (InputPressed(INPUT_VERB.UP) || InputPressed(INPUT_VERB.LEFT)) {
		navigate_previous();
	}

	if (InputPressed(INPUT_VERB.DOWN) || InputPressed(INPUT_VERB.RIGHT)) {
		navigate_next();
	}
}

// Activate selected button (Interact) - works for all button types
if (InputPressed(INPUT_VERB.INTERACT)) {
	activate_selected_button();
}
