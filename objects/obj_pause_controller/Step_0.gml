// PAUSE verb (ESC + Settings button) - toggle pause menu
if (InputPressed(INPUT_VERB.PAUSE)) {
	// Prioritize closing active menus before toggling pause
	if (vn_force_close()) {
		exit;
	}

	if (inventory_force_close()) {
		exit;
	}

	var _settings_open = layer_exists("SettingsLayer") && layer_get_visible("SettingsLayer");
	var _save_load_open = layer_exists("SaveLoadLayer") && layer_get_visible("SaveLoadLayer");
	var _pause_open = layer_exists("PauseLayer") && layer_get_visible("PauseLayer") && global.game_paused;

	if (_settings_open || _save_load_open || _pause_open) {
		ui_close_all_menus();
		exit;
	}

	// Otherwise, toggle pause state
	global.game_paused = !global.game_paused;
	update_pause();
}

// UI_CANCEL verb (Circle) - close menus when paused
// Only handle Circle when actually in a menu (let player handle gameplay Circle)
if (InputPressed(INPUT_VERB.UI_CANCEL) && global.game_paused) {
	// Close all menus and return to gameplay
	ui_close_all_menus();
}
