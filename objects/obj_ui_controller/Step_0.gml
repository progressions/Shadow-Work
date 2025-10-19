// Only process input if active and buttons are defined
if (!is_active || array_length(button_list) == 0) {
	exit;
}

// Navigate up/previous (W or A)
if (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(ord("A"))) {
	navigate_previous();
}

// Navigate down/next (S or D)
if (keyboard_check_pressed(ord("S")) || keyboard_check_pressed(ord("D"))) {
	navigate_next();
}

// Activate selected button (Enter or E)
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("E"))) {
	activate_selected_button();
}
