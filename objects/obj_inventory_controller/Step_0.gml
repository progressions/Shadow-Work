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

    // TAB key to switch between tabs
    if (keyboard_check_pressed(vk_tab)) {
        current_tab = (current_tab + 1) % 3;
        _play_ui_sfx(snd_open_menu, 0.7);

        // Reset selections when switching tabs
        if (current_tab == InventoryTab.loadout) {
            var _player = instance_exists(obj_player) ? obj_player : noone;
            if (_player != noone) {
                loadout_selected_loadout = _player.loadouts.active;
                loadout_selected_hand = "left";
            }
        }
    }

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

    // Handle navigation based on current tab
    if (current_tab == InventoryTab.inventory) {
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
    } else if (current_tab == InventoryTab.paper_doll) {
        // Paper doll navigation: W/S and A/D both cycle through head -> torso -> legs
        if (_move_vertical != 0 || _move_horizontal != 0) {
            var _direction = (_move_vertical != 0) ? _move_vertical : _move_horizontal;

            if (paper_doll_selected == "head") {
                paper_doll_selected = (_direction > 0) ? "torso" : "legs";
            } else if (paper_doll_selected == "torso") {
                paper_doll_selected = (_direction > 0) ? "legs" : "head";
            } else if (paper_doll_selected == "legs") {
                paper_doll_selected = (_direction > 0) ? "head" : "torso";
            }
            _play_ui_sfx(snd_open_menu, 0.7);
        }
    } else if (current_tab == InventoryTab.loadout) {
        // Loadout navigation: W/S switches loadouts, A/D switches hands
        if (_move_vertical != 0) {
            loadout_selected_loadout = (loadout_selected_loadout == "melee") ? "ranged" : "melee";
            _play_ui_sfx(snd_open_menu, 0.7);
        }
        if (_move_horizontal != 0) {
            loadout_selected_hand = (loadout_selected_hand == "left") ? "right" : "left";
            _play_ui_sfx(snd_open_menu, 0.7);
        }
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
        // U key: Use consumables in inventory tab, OR unequip items in loadout/paper doll tabs
        if (current_tab == InventoryTab.inventory) {
            // Inventory tab: Use consumables
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
        } else if (current_tab == InventoryTab.paper_doll) {
            // Paper doll tab: Unequip armor
            if (_player == noone) {
                _play_ui_sfx(snd_denied);
            } else {
                var _unequip_method = method(_player, unequip_item);
                if (_unequip_method != undefined && _unequip_method(paper_doll_selected)) {
                    show_debug_message("[U] Unequipped " + paper_doll_selected);
                    _play_ui_sfx(snd_open_menu);
                } else {
                    show_debug_message("[U] Failed to unequip " + paper_doll_selected + " (slot empty or inventory full)");
                    _play_ui_sfx(snd_denied);
                }
            }
        } else if (current_tab == InventoryTab.loadout) {
            // Loadout tab: Unequip weapon/shield from selected loadout hand
            if (_player == noone) {
                _play_ui_sfx(snd_denied);
            } else {
                var _loadout = _player.loadouts[$ loadout_selected_loadout];
                var _hand_slot = loadout_selected_hand + "_hand";
                var _equipped_item = _loadout[$ _hand_slot];

                if (_equipped_item == undefined) {
                    show_debug_message("[U] No item equipped in " + loadout_selected_loadout + " " + loadout_selected_hand + " hand");
                    _play_ui_sfx(snd_denied);
                } else {
                    // Unequip from loadout back to inventory
                    var _can_add = inventory_add_item(_equipped_item.definition, _equipped_item.count);
                    if (_can_add) {
                        // Remove wielder effects if this is the active loadout
                        if (loadout_selected_loadout == _player.loadouts.active) {
                            if (variable_struct_exists(_equipped_item.definition, "stats")) {
                                var _remove_method = method(_player, remove_wielder_effects);
                                if (_remove_method != undefined) {
                                    _remove_method(_equipped_item.definition.stats);
                                }
                            }
                        }

                        _loadout[$ _hand_slot] = undefined;
                        show_debug_message("[U] Unequipped from " + loadout_selected_loadout + " " + loadout_selected_hand + " hand");
                        _play_ui_sfx(snd_open_menu);
                    } else {
                        show_debug_message("[U] Inventory full, cannot unequip");
                        _play_ui_sfx(snd_denied);
                    }
                }
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
