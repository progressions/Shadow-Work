// Settings Menu Navigation Controller
// Inherits from obj_ui_controller

// Call parent Create event
event_inherited();

// Set my layer name
my_layer = "SettingsLayer";

// Override the button activation handler
on_button_activated = function(_button_id) {
	switch (_button_id) {
		case 5: // Back button
			close_and_return_to_parent("PauseLayer");
			break;
	}
}
