// Pause Menu Navigation Controller
// Inherits from obj_ui_controller

// Call parent Create event
event_inherited();

// Set my layer name
my_layer = "PauseLayer";

// Override the button activation handler
on_button_activated = function(_button_id) {
	switch (_button_id) {
		case 0: // Save/Load button
			obj_save_load_menu.open_menu("save");
			break;

		case 1: // Resume button
			ui_close_all_menus();
			break;

		case 2: // Settings button
			open_child_panel("SettingsLayer");
			break;

		case 3: // Quit button
			game_end();
			break;
	}
}
