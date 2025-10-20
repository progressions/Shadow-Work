if (keyboard_check_pressed(vk_escape)) {
	// If settings menu is open, close everything and unpause
	if (layer_exists("SettingsLayer") && layer_get_visible("SettingsLayer")) {
		layer_set_visible("SettingsLayer", false);
		layer_set_visible("PauseLayer", false);
		global.game_paused = false;
		update_pause();
	} else {
		// Otherwise, toggle pause state normally
		global.game_paused = !global.game_paused;
		update_pause();
	}
}