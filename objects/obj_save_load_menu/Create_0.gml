// Save/Load Menu Controller
// Inherits from obj_ui_controller

// Call parent Create event
event_inherited();

// Set my layer name
my_layer = "SaveLoadLayer";

// UI State
current_mode = "save"; // "save" or "load"
save_slot_data = []; // Array of metadata for each slot (index 1-5)

// Cache text element IDs (do this once, not every frame!)
text_ids = {
    header: layer_text_get_id(my_layer, "text_header"),
    mode_indicator: layer_text_get_id(my_layer, "text_mode_indicator"),
    slot_1: layer_text_get_id(my_layer, "text_slot_1"),
    slot_2: layer_text_get_id(my_layer, "text_slot_2"),
    slot_3: layer_text_get_id(my_layer, "text_slot_3"),
    slot_4: layer_text_get_id(my_layer, "text_slot_4"),
    slot_5: layer_text_get_id(my_layer, "text_slot_5")
};

// obj_pointer instances will be placed in the room/layer
// They handle their own initialization (frame 0, alpha 0)

// Selection state (1-5 for slots)
selected_slot = 1;

// ============================================
// POINTER POSITIONING
// ============================================

/// @function update_pointer_visibility()
/// @description Show pointer for selected slot, hide all others
update_pointer_visibility = function() {
    // Safety check - make sure layer is visible
    if (!layer_get_visible(my_layer)) return;

    // Find all obj_pointer instances and update their alpha based on selection
    with (obj_pointer) {
        // Show pointer if its button_id matches the selected slot, hide otherwise
        image_alpha = (button_id == other.selected_slot) ? 1 : 0;
    }
}

// ============================================
// MENU CONTROL FUNCTIONS
// ============================================

/// @function open_menu(mode)
/// @description Open the save/load menu in specified mode
/// @param {string} mode "save" or "load"
open_menu = function(_mode = "save") {
    is_active = true;
    current_mode = _mode;

    // Show save/load layer, hide pause layer
    layer_set_visible(my_layer, true);
    layer_set_visible("PauseLayer", false);

    // Scan save files and update UI
    scan_save_slots();
    update_ui_display();
}

/// @function close_menu()
/// @description Close all menus and return to gameplay
close_menu = function() {
    is_active = false;

    // Close all menu layers
    layer_set_visible(my_layer, false);
    layer_set_visible("PauseLayer", false);
    layer_set_visible("SettingsLayer", false);

    // Unpause the game
    global.game_paused = false;
}

/// @function switch_mode(new_mode)
/// @description Switch between Save and Load modes
/// @param {string} new_mode "save" or "load"
switch_mode = function(_new_mode) {
    if (current_mode != _new_mode) {
        current_mode = _new_mode;
        update_ui_display();
    }
}

// ============================================
// SAVE SLOT MANAGEMENT
// ============================================

/// @function scan_save_slots()
/// @description Read metadata from all save files
scan_save_slots = function() {
    // Initialize array (index 0 unused, 1-5 are slots)
    save_slot_data = array_create(6, undefined);

    // Scan manual save slots 1-5
    for (var i = 1; i <= 5; i++) {
        save_slot_data[i] = get_save_slot_metadata(i);
    }
}

/// @function perform_save(slot)
/// @description Execute save operation
/// @param {real} slot Slot number to save to (1-5)
perform_save = function(_slot) {
    if (save_game(_slot)) {
        show_debug_message("Game saved to slot " + string(_slot));

        // Refresh slot data
        scan_save_slots();
        update_ui_display();

        // Show feedback to player (if you have a feedback system)
        // spawn_floating_text(obj_player.x, obj_player.y - 32, "Game Saved", c_green, obj_player);
    } else {
        show_debug_message("Failed to save to slot " + string(_slot));
    }
}

/// @function perform_load(slot)
/// @description Execute load operation
/// @param {real} slot Slot number to load from (1-5)
perform_load = function(_slot) {
    // Check if slot has save data
    if (save_slot_data[_slot] != undefined) {
        if (load_game(_slot)) {
            show_debug_message("Game loaded from slot " + string(_slot));

            // Close all menus and unpause the game
            is_active = false;
            layer_set_visible(my_layer, false);
            layer_set_visible("PauseLayer", false);
            layer_set_visible("SettingsLayer", false);
            global.game_paused = false;
        } else {
            show_debug_message("Failed to load from slot " + string(_slot));
        }
    } else {
        show_debug_message("Cannot load from empty slot " + string(_slot));
    }
}

// ============================================
// UI UPDATE
// ============================================

/// @function update_ui_display()
/// @description Refresh all text elements with current data
update_ui_display = function() {
    // Update header based on mode
    var _header_text = (current_mode == "save") ? "Save Game" : "Load Game";
    layer_text_text(text_ids.header, _header_text);

    // Update mode indicator
    var _mode_text = (current_mode == "save") ? "Saving Mode (A/D to switch)" : "Loading Mode (A/D to switch)";
    layer_text_text(text_ids.mode_indicator, _mode_text);

    // Update each slot text
    for (var i = 1; i <= 5; i++) {
        var _metadata = save_slot_data[i];
        var _text_id = text_ids[$ ("slot_" + string(i))];

        if (_metadata == undefined) {
            // Empty slot
            if (current_mode == "save") {
                layer_text_text(_text_id, "Slot " + string(i) + " - Empty (New Save)");
            } else {
                layer_text_text(_text_id, "Slot " + string(i) + " - Empty");
            }
        } else {
            // Populated slot - show timestamp and level
            var _time_ago = format_time_ago(_metadata.timestamp);
            var _location = _metadata.room_name;
            var _level_text = "Lv " + string(_metadata.player_level);
            var _hp_text = string(_metadata.player_hp) + "/" + string(_metadata.player_hp_total) + " HP";

            var _info = _time_ago + " - " + _level_text + " - " + _hp_text;
            layer_text_text(_text_id, "Slot " + string(i) + " - " + _info);
        }
    }
}

// ============================================
// BUTTON ACTIVATION OVERRIDE
// ============================================

/// @function on_button_activated(button_id)
/// @description Override parent's button activation to handle slot selection
/// @param {real} button_id The button ID that was activated
on_button_activated = function(_button_id) {
    // Button IDs 1-5 correspond to save slots
    if (_button_id >= 1 && _button_id <= 5) {
        if (current_mode == "save") {
            perform_save(_button_id);
        } else {
            perform_load(_button_id);
        }
    }
    // Add back button handling if needed (button_id 0 or 99)
    else if (_button_id == 0 || _button_id == 99) {
        close_menu();
    }
}
