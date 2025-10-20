/// @description Room Start - Ensure menu is closed

// Make sure the save/load menu is hidden when entering any room
is_active = false;

// Hide all UI layers explicitly
layer_set_visible("SaveLoadLayer", false);
layer_set_visible("PauseLayer", false);
layer_set_visible("SettingsLayer", false);

show_debug_message("Save/Load Menu Room Start - All UI layers hidden");

// If we just loaded a game, make sure we're unpaused
if (variable_global_exists("is_loading") && global.is_loading) {
    global.game_paused = false;
    show_debug_message("Game unpaused in save/load Room Start");
}
