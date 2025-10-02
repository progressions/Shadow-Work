// === STEP EVENT ===
if (keyboard_check_pressed(ord("I"))) {
    is_open = !is_open;

    // Create a global pause variable if it doesn't exist
    global.game_paused = is_open;
}

// Navigation only when inventory is open
if (is_open) {
    var _move_horizontal = 0;
    var _move_vertical = 0;

    // WASD navigation
    if (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up)) {
        _move_vertical = -1;
    }
    if (keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_down)) {
        _move_vertical = 1;
    }
    if (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left)) {
        _move_horizontal = -1;
    }
    if (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right)) {
        _move_horizontal = 1;
    }

    // Calculate current position in grid
    var _current_col = selected_slot % grid_columns;
    var _current_row = floor(selected_slot / grid_columns);

    // Apply movement with wrapping
    _current_col += _move_horizontal;
    _current_row += _move_vertical;

    // Wrap horizontally
    if (_current_col < 0) _current_col = grid_columns - 1;
    if (_current_col >= grid_columns) _current_col = 0;

    // Wrap vertically
    if (_current_row < 0) _current_row = grid_rows - 1;
    if (_current_row >= grid_rows) _current_row = 0;

    // Update selected slot
    selected_slot = (_current_row * grid_columns) + _current_col;

    var _row = floor(selected_slot / grid_columns);
    var _col = selected_slot % grid_columns;
    var _player = instance_find(obj_player, 0);
    var _slot_action = inventory_get_slot_action(_player, selected_slot);

    var _action_text = "none";
    switch (_slot_action) {
        case InventoryContextAction.equip:
            _action_text = "equip";
            break;

        case InventoryContextAction.use:
            _action_text = "use";
            break;
    }

    // Action key stubs
    if (keyboard_check_pressed(vk_space)) {
        if (_slot_action == InventoryContextAction.none) {
            show_debug_message("[Space] No context action for slot: " + string(_row) + ", " + string(_col) + " (index: " + string(selected_slot) + ")");
        } else {
            show_debug_message("[Space] Context action '" + _action_text + "' at slot: " + string(_row) + ", " + string(_col) + " (index: " + string(selected_slot) + ")");
        }
    }

    if (keyboard_check_pressed(ord("E"))) {
        if (_slot_action == InventoryContextAction.equip) {
            show_debug_message("[E] Equip item at slot: " + string(_row) + ", " + string(_col) + " (index: " + string(selected_slot) + ")");
        } else {
            show_debug_message("[E] No equip action available (current context: " + _action_text + ")");
        }
    }

    if (keyboard_check_pressed(ord("P"))) {
        show_debug_message("[P] Drop item at slot: " + string(_row) + ", " + string(_col) + " (index: " + string(selected_slot) + ")");
    }

    if (keyboard_check_pressed(ord("U"))) {
        if (_slot_action == InventoryContextAction.use) {
            show_debug_message("[U] Use/consume item at slot: " + string(_row) + ", " + string(_col) + " (index: " + string(selected_slot) + ")");
        } else {
            show_debug_message("[U] No use action available (current context: " + _action_text + ")");
        }
    }

    if (keyboard_check_pressed(vk_escape)) {
        show_debug_message("[ESC] Closing inventory");
        is_open = false;
        global.game_paused = false;
    }
}
