// PAUSE verb (ESC + Settings button) - toggle pause menu
if (InputPressed(INPUT_VERB.PAUSE)) {
	// If settings menu is open, close everything and unpause
	if (layer_exists("SettingsLayer") && layer_get_visible("SettingsLayer")) {
		ui_close_all_menus();
	} else {
		// Otherwise, toggle pause state
		global.game_paused = !global.game_paused;
		update_pause();
	}
}

// UI_CANCEL verb (ESC + Circle) - always close all menus
if (InputPressed(INPUT_VERB.UI_CANCEL)) {
	// Always close all menus and return to gameplay
	ui_close_all_menus();
}