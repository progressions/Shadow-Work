// Only process if menu is active
if (!is_active) exit;

// Update pointer visibility every frame
update_pointer_visibility();

// W/S to navigate slots
if (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up)) {
    selected_slot--;
    if (selected_slot < 1) {
        selected_slot = 5; // Wrap to last slot
    }
}

if (keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_down)) {
    selected_slot++;
    if (selected_slot > 5) {
        selected_slot = 1; // Wrap to first slot
    }
}

// A/D to switch between Save and Load tabs
if (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left)) {
    switch_mode("load");
}

if (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right)) {
    switch_mode("save");
}

// Enter to execute action on selected slot
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    if (current_mode == "save") {
        perform_save(selected_slot);
    } else {
        perform_load(selected_slot);
    }
}

// Escape to close menu
if (keyboard_check_pressed(vk_escape)) {
    close_menu();
}
