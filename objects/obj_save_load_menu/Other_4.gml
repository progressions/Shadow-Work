/// @description Room Start - Ensure menu is closed

// Make sure the save/load menu is hidden when entering any room
is_active = false;

// Hide all UI layers explicitly
layer_set_visible("SaveLoadLayer", false);
layer_set_visible("PauseLayer", false);
layer_set_visible("SettingsLayer", false);

show_debug_message("Save/Load Menu Room Start - All UI layers hidden");

// Save system check removed during rebuild
// Previously unpaused game after loading
