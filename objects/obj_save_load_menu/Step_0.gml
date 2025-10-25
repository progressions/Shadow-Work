// Only process if menu is active
if (!is_active) exit;

// Update pointer visibility every frame
update_pointer_visibility();

// Debounce input so opening the menu doesn't immediately activate a slot
if (input_cooldown > 0) {
    input_cooldown--;
    exit;
}

// UP/DOWN to navigate slots (keyboard + gamepad)
if (InputPressed(INPUT_VERB.UP)) {
    selected_slot--;
    if (selected_slot < 1) {
        selected_slot = 5; // Wrap to last slot
    }
}

if (InputPressed(INPUT_VERB.DOWN)) {
    selected_slot++;
    if (selected_slot > 5) {
        selected_slot = 1; // Wrap to first slot
    }
}

// LEFT/RIGHT to switch between Save and Load tabs (keyboard + gamepad)
if (InputPressed(INPUT_VERB.LEFT)) {
    switch_mode("load");
}

if (InputPressed(INPUT_VERB.RIGHT)) {
    switch_mode("save");
}

// Interact to execute action on selected slot
if (InputPressed(INPUT_VERB.INTERACT)) {
    if (current_mode == "save") {
        perform_save(selected_slot);
    } else {
        perform_load(selected_slot);
    }
}

// Cancel to close all menus and return to gameplay (ESC or Circle on gamepad)
if (InputPressed(INPUT_VERB.UI_CANCEL)) {
    ui_close_all_menus();
}
