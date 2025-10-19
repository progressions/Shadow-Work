// Pause Menu Navigation Controller
// Inherits from obj_ui_controller

// Call parent Create event
event_inherited();

show_debug_message("Pause Nav Controller: Created");

// Override the button activation handler
on_button_activated = function(_button_id) {
	switch (_button_id) {
		case 0: // Resume button
			global.game_paused = false;
			obj_pause_controller.update_pause();
			is_active = false;
			break;

		case 1: // Settings button
			// TODO: Open settings menu
			show_debug_message("Settings button pressed - not yet implemented");
			break;

		case 2: // Quit button
			// TODO: Implement quit functionality
			show_debug_message("Quit button pressed - not yet implemented");
			game_end();
			break;
	}
}
