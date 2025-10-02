// === STEP EVENT ===
var _play_ui_sfx = function(_sound, _volume = 1) {

    play_sfx(_sound, _volume);

};

if (keyboard_check_pressed(ord("I"))) {
    is_open = !is_open;

    // Create a global pause variable if it doesn't exist
    global.game_paused = is_open;

    _play_ui_sfx(is_open ? snd_open_inventory : snd_close_inventory);
	
	if (is_open) {
		audio_group_set_gain(audiogroup_sfx_world, 0, 0);
	} else {
		audio_group_set_gain(audiogroup_sfx_world, 1, 0);
	}

}

// Navigation only when inventory is open
if (is_open) {
	audio_group_set_gain(audiogroup_sfx_world, 0, 0);
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
    var _previous_slot = selected_slot;
    selected_slot = (_current_row * grid_columns) + _current_col;
    if (selected_slot != _previous_slot) {
        _play_ui_sfx(snd_open_menu, 0.7);
    }

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
            _play_ui_sfx(snd_denied);
        } else {
            var _swap_method = method(_player, swap_active_loadout);
            var _swap_success = (_swap_method != undefined) && _swap_method();
            if (_swap_success) {
                var _active_key = method(_player, loadouts_get_active_key);
                var _active_name = (_active_key != undefined) ? _active_key() : "unknown";
                show_debug_message("[Q] Active loadout set to " + string(_active_name));
                _play_ui_sfx(snd_change_loadout);
            } else {
                show_debug_message("[Q] Failed to swap loadout");
                _play_ui_sfx(snd_denied);
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
            _play_ui_sfx(snd_denied);
        } else if (_player == noone) {
            show_debug_message("[Space] No player instance found");
            _play_ui_sfx(snd_denied);
        } else {
            var _selected_item = undefined;
            if (_slot_action == InventoryContextAction.equip && selected_slot < array_length(_player.inventory)) {
                _selected_item = _player.inventory[selected_slot];
            }

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
                if (_slot_action == InventoryContextAction.equip) {
                    var _equip_sound = snd_open_menu;
                    if (_selected_item != undefined) {
                        switch (_selected_item.definition.type) {
                            case ItemType.armor:
                                _equip_sound = snd_open_menu;
                                break;
                            case ItemType.weapon:
                                _equip_sound = snd_open_menu;
                                break;
                            case ItemType.tool:
                                _equip_sound = snd_open_menu;
                                break;
                        }
                    }
                    _play_ui_sfx(_equip_sound);
                } else {
                    _play_ui_sfx(snd_using_potion);
                }
            } else {
                _play_ui_sfx(snd_denied);
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
            _play_ui_sfx(snd_denied);
        } else if (_player == noone) {
            show_debug_message("[E] No player instance found");
            _play_ui_sfx(snd_denied);
        } else {
            var _selected_item = (selected_slot < array_length(_player.inventory)) ? _player.inventory[selected_slot] : undefined;
            var _equip_success = inventory_perform_equip_on_player(_player, selected_slot);
            if (_equip_success) {
                var _equip_sound = snd_open_menu;
                if (_selected_item != undefined) {
                    switch (_selected_item.definition.type) {
                        case ItemType.armor:
                            _equip_sound = snd_open_menu;
                            break;
                        case ItemType.weapon:
                            _equip_sound = snd_open_menu;
                            break;
                        case ItemType.tool:
                            _equip_sound = snd_open_menu;
                            break;
                    }
                }
                _play_ui_sfx(_equip_sound);
            } else {
                _play_ui_sfx(snd_denied);
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
            _play_ui_sfx(snd_denied);
        } else if (selected_slot >= array_length(_player.inventory) || _player.inventory[selected_slot] == undefined) {
            show_debug_message("[P] No item to drop in slot " + string(selected_slot));
            _play_ui_sfx(snd_denied);
        } else {
            var _drop_method = method(_player, drop_selected_item);
            var _stack = _player.inventory[selected_slot];
            var _drop_amount = (_stack != undefined) ? _stack.count : 0;
            if (_drop_method != undefined && _drop_amount > 0 && _drop_method(selected_slot, _drop_amount)) {
                _play_ui_sfx(snd_drop_item);
                if (selected_slot >= array_length(_player.inventory)) {
                    selected_slot = max(0, array_length(_player.inventory) - 1);
                }
            } else {
                _play_ui_sfx(snd_denied);
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
            _play_ui_sfx(snd_denied);
        } else if (_player == noone) {
            show_debug_message("[U] No player instance found");
            _play_ui_sfx(snd_denied);
        } else {
            var _use_success = inventory_perform_use_on_player(_player, selected_slot);
            if (_use_success) {
                _play_ui_sfx(snd_using_potion);
            } else {
                _play_ui_sfx(snd_denied);
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
		audio_group_set_gain(audiogroup_sfx_world, 1, 0);
    }
}
