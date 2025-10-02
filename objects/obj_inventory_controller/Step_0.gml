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
}
