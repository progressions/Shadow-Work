// === STEP EVENT ===
if (keyboard_check_pressed(ord("I"))) {
    is_open = !is_open;

    // Create a global pause variable if it doesn't exist
    global.game_paused = is_open;

    global.audio_config.sfx_enabled = !is_open;
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
    var _player = instance_exists(obj_player) ? obj_player : noone;
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

    if (keyboard_check_pressed(ord("Q"))) {
        if (_player == noone) {
            show_debug_message("[Q] No player instance found");
        } else {
            var _swap_method = method(_player, swap_active_loadout);
            if (_swap_method != undefined && _swap_method()) {
                var _active_key = method(_player, loadouts_get_active_key);
                var _active_name = (_active_key != undefined) ? _active_key() : "unknown";
                show_debug_message("[Q] Active loadout set to " + string(_active_name));
            } else {
                show_debug_message("[Q] Failed to swap loadout");
            }
        }

        _slot_action = inventory_get_slot_action(_player, selected_slot);
        _action_text = "none";
        switch (_slot_action) {
            case InventoryContextAction.equip:
                _action_text = "equip";
                break;

            case InventoryContextAction.use:
                _action_text = "use";
                break;
        }
    }

    // Action keys
    if (keyboard_check_pressed(vk_space)) {
        if (_slot_action == InventoryContextAction.none) {
            show_debug_message("[Space] No context action for slot: " + string(_row) + ", " + string(_col) + " (index: " + string(selected_slot) + ")");
        } else if (_player == noone) {
            show_debug_message("[Space] No player instance found");
        } else {
            var _success = false;
            switch (_slot_action) {
                case InventoryContextAction.equip:
                    _success = inventory_perform_equip_on_player(_player, selected_slot);
                    break;

                case InventoryContextAction.use:
                    _success = inventory_perform_use_on_player(_player, selected_slot);
                    break;
            }

            if (_success) {
                show_debug_message("[Space] Executed '" + _action_text + "' on slot: " + string(_row) + ", " + string(_col) + " (index: " + string(selected_slot) + ")");
            } else {
                show_debug_message("[Space] Failed to execute '" + _action_text + "' on slot: " + string(_row) + ", " + string(_col) + " (index: " + string(selected_slot) + ")");
            }
            _slot_action = inventory_get_slot_action(_player, selected_slot);
            _action_text = "none";
            switch (_slot_action) {
                case InventoryContextAction.equip:
                    _action_text = "equip";
                    break;

                case InventoryContextAction.use:
                    _action_text = "use";
                    break;
            }
        }
    }

    if (keyboard_check_pressed(ord("E"))) {
        if (_slot_action != InventoryContextAction.equip) {
            show_debug_message("[E] No equip action available (current context: " + _action_text + ")");
        } else if (_player == noone) {
            show_debug_message("[E] No player instance found");
        } else {
            var _equip_success = inventory_perform_equip_on_player(_player, selected_slot);
            if (_equip_success) {
                show_debug_message("[E] Equipped item from slot: " + string(_row) + ", " + string(_col) + " (index: " + string(selected_slot) + ")");
            } else {
                show_debug_message("[E] Equip failed for slot: " + string(_row) + ", " + string(_col) + " (index: " + string(selected_slot) + ")");
            }
            _slot_action = inventory_get_slot_action(_player, selected_slot);
            _action_text = "none";
            switch (_slot_action) {
                case InventoryContextAction.equip:
                    _action_text = "equip";
                    break;

                case InventoryContextAction.use:
                    _action_text = "use";
                    break;
            }
        }
    }

    if (keyboard_check_pressed(ord("P"))) {
        if (_player == noone) {
            show_debug_message("[P] No player instance found");
        } else if (selected_slot >= array_length(_player.inventory) || _player.inventory[selected_slot] == undefined) {
            show_debug_message("[P] No item to drop in slot " + string(selected_slot));
        } else {
            var _drop_method = method(_player, drop_selected_item);
            var _stack = _player.inventory[selected_slot];
            var _drop_amount = (_stack != undefined) ? _stack.count : 0;
            if (_drop_method != undefined && _drop_amount > 0 && _drop_method(selected_slot, _drop_amount)) {
                show_debug_message("[P] Dropped item from slot: " + string(_row) + ", " + string(_col) + " (index: " + string(selected_slot) + ")");
                if (selected_slot >= array_length(_player.inventory)) {
                    selected_slot = max(0, array_length(_player.inventory) - 1);
                }
            } else {
                show_debug_message("[P] Drop failed for slot: " + string(selected_slot));
            }

            _slot_action = inventory_get_slot_action(_player, selected_slot);
            _action_text = "none";
            switch (_slot_action) {
                case InventoryContextAction.equip:
                    _action_text = "equip";
                    break;

                case InventoryContextAction.use:
                    _action_text = "use";
                    break;
            }
        }
    }

    if (keyboard_check_pressed(ord("U"))) {
        if (_slot_action != InventoryContextAction.use) {
            show_debug_message("[U] No use action available (current context: " + _action_text + ")");
        } else if (_player == noone) {
            show_debug_message("[U] No player instance found");
        } else {
            var _use_success = inventory_perform_use_on_player(_player, selected_slot);
            if (_use_success) {
                show_debug_message("[U] Used item from slot: " + string(_row) + ", " + string(_col) + " (index: " + string(selected_slot) + ")");
            } else {
                show_debug_message("[U] Use failed for slot: " + string(_row) + ", " + string(_col) + " (index: " + string(selected_slot) + ")");
            }
            _slot_action = inventory_get_slot_action(_player, selected_slot);
            _action_text = "none";
            switch (_slot_action) {
                case InventoryContextAction.equip:
                    _action_text = "equip";
                    break;

                case InventoryContextAction.use:
                    _action_text = "use";
                    break;
            }
        }
    }

    if (keyboard_check_pressed(vk_escape)) {
        show_debug_message("[ESC] Closing inventory");
        is_open = false;
        global.game_paused = false;
    }
}
