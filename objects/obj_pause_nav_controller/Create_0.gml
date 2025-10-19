// Pause Menu Navigation Controller
// Inherits from obj_ui_controller

// Call parent Create event
event_inherited();

// Set my layer name
my_layer = "PauseLayer";

// Override the button activation handler
on_button_activated = function(_button_id) {
	switch (_button_id) {
		case 0: // Resume button
			global.game_paused = false;
			obj_pause_controller.update_pause();
			break;

		case 1: // Settings button
			open_child_panel("SettingsLayer");
			break;

		case 2: // Quit button
			game_end();
			break;
	}
}
