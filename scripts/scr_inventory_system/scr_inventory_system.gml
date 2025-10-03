// ============================================
// INVENTORY & EQUIPMENT SYSTEM
// ============================================

// Add item to inventory with stacking support
function inventory_add_item(_item_def, _count = 1) {
    // Check if item is stackable and already exists in inventory
    if (_item_def.stats[$ "stack_size"] != undefined) {
        // Look for existing stack
        for (var i = 0; i < array_length(inventory); i++) {
            var _existing = inventory[i];
            if (_existing.definition.item_id == _item_def.item_id) {
                var _max_stack = _item_def.stats.stack_size;
                var _space_left = _max_stack - _existing.count;

                if (_space_left > 0) {
                    var _to_add = min(_space_left, _count);
                    _existing.count += _to_add;
                    _count -= _to_add;

                    if (_count <= 0) return true; // All items added
                }
            }
        }
    }

    // Add remaining items as new stacks
    while (_count > 0 && array_length(inventory) < max_inventory_size) {
        var _stack_size = _item_def.stats[$ "stack_size"] ?? 1;
        var _this_stack = min(_count, _stack_size);

        var _item_instance = {
            definition: _item_def,
            count: _this_stack,
            durability: 100  // Optional durability system
        };

        array_push(inventory, _item_instance);
        _count -= _this_stack;
    }

    // Check if this is a quest item and update quest objectives
    if (_item_def.type == ItemType.quest_item && variable_struct_exists(_item_def, "quest_id")) {
        quest_check_item_collection(_item_def.item_id, _item_def.quest_id);
    }

    return (_count <= 0); // Return true if all items were added
}

// Remove item from inventory
function inventory_remove_item(_inventory_index, _count = 1) {
    if (_inventory_index < 0 || _inventory_index >= array_length(inventory)) return false;

    var _item = inventory[_inventory_index];

    // Prevent removing quest items
    if (_item.definition.type == ItemType.quest_item) {
        show_debug_message("Cannot remove quest item: " + _item.definition.name);
        return false;
    }

    if (_item.count > _count) {
        _item.count -= _count;
        return true;
    } else {
        array_delete(inventory, _inventory_index, 1);
        return true;
    }
}

function drop_selected_item(_inventory_index, _amount = undefined) {
    if (_inventory_index < 0 || _inventory_index >= array_length(inventory)) return false;

    var _entry = inventory[_inventory_index];
    if (_entry == undefined) return false;

    var _def = _entry.definition;
    if (_def == undefined) return false;

    var _drop_count = (_amount == undefined) ? _entry.count : max(1, min(_amount, _entry.count));

    var _spawn_offset = 64;
    var _drop_x = x;
    var _drop_y = y;

    var _dir_x = 0;
    var _dir_y = -_spawn_offset;

    if (variable_instance_exists(id, "facing_dir")) {
        switch (facing_dir) {
            case "up":
                _dir_x = 0;
                _dir_y = -_spawn_offset;
                break;
            case "down":
                _dir_x = 0;
                _dir_y = _spawn_offset;
                break;
            case "left":
                _dir_x = -_spawn_offset;
                _dir_y = 0;
                break;
            case "right":
                _dir_x = _spawn_offset;
                _dir_y = 0;
                break;
        }
    }

    _drop_x = x + _dir_x;
    _drop_y = y + _dir_y;

    var _tilemap_coll = layer_tilemap_get_id("Tiles_Col");
    if (_tilemap_coll != -1) {
        var _tile_value = tilemap_get_at_pixel(_tilemap_coll, _drop_x, _drop_y);
        if (_tile_value != 0) {
            var _alternates = [
                {x: _dir_y, y: -_dir_x},
                {x: -_dir_y, y: _dir_x},
                {x: -_dir_x, y: -_dir_y},
                {x: 0, y: -_spawn_offset},
                {x: 0, y: _spawn_offset},
                {x: -_spawn_offset, y: 0},
                {x: _spawn_offset, y: 0}
            ];

            var _placed = false;
            for (var _ai = 0; _ai < array_length(_alternates); _ai++) {
                var _option = _alternates[_ai];
                var _test_x = x + _option.x;
                var _test_y = y + _option.y;
                if (tilemap_get_at_pixel(_tilemap_coll, _test_x, _test_y) == 0) {
                    _drop_x = _test_x;
                    _drop_y = _test_y;
                    _placed = true;
                    break;
                }
            }

            if (!_placed) {
                _drop_x = x + _dir_x;
                _drop_y = y + _dir_y;
            }
        }
    }

    var _spawn = spawn_item(_drop_x, _drop_y, _def.item_id, _drop_count);
    if (_spawn != noone) {
        _spawn.count = _drop_count;
        if (_entry.durability != undefined) {
            _spawn.durability = _entry.durability;
        }
    }

    if (_entry.count > _drop_count) {
        _entry.count -= _drop_count;
    } else {
        array_delete(inventory, _inventory_index, 1);
    }

    return true;
}

function inventory_can_accept_batch(_items) {
    var _sim_inventory = [];
    for (var _i = 0; _i < array_length(inventory); _i++) {
        var _existing = inventory[_i];
        if (_existing != undefined) {
            array_push(_sim_inventory, {definition: _existing.definition, count: _existing.count});
        }
    }

    var _max_slots = max_inventory_size;

    for (var _j = 0; _j < array_length(_items); _j++) {
        var _pending = _items[_j];
        if (_pending == undefined) continue;

        var _def = _pending.definition;
        var _remaining = _pending.count;
        if (_def == undefined || _remaining <= 0) continue;

        var _stack_size = 1;
        if (_def.stats != undefined) {
            _stack_size = _def.stats[$ "stack_size"] ?? 1;
        }

        for (var _k = 0; _k < array_length(_sim_inventory) && _remaining > 0; _k++) {
            var _sim_entry = _sim_inventory[_k];
            if (_sim_entry != undefined && _sim_entry.definition.item_id == _def.item_id) {
                var _sim_stack_size = 1;
                if (_sim_entry.definition.stats != undefined) {
                    _sim_stack_size = _sim_entry.definition.stats[$ "stack_size"] ?? 1;
                }

                var _space = _sim_stack_size - _sim_entry.count;
                if (_space > 0) {
                    var _add = min(_space, _remaining);
                    _sim_entry.count += _add;
                    _remaining -= _add;
                    _sim_inventory[_k] = _sim_entry;
                }
            }
        }

        while (_remaining > 0 && array_length(_sim_inventory) < _max_slots) {
            var _add_new = min(_stack_size, _remaining);
            array_push(_sim_inventory, {definition: _def, count: _add_new});
            _remaining -= _add_new;
        }

        if (_remaining > 0) {
            return false;
        }
    }

    return true;
}

// Equip item with two-handed weapon handling
function equip_item(_inventory_index, _target_hand = undefined) {
    if (_inventory_index < 0 || _inventory_index >= array_length(inventory)) return false;

    var _item = inventory[_inventory_index];
    var _def = _item.definition;

    if (_def == undefined) return false;
    if (_def.equip_slot == EquipSlot.none) return false;

    var _slot_name = "";
    var _is_hand_slot = false;

    var _loadout_key = undefined;
    var _loadout_struct = undefined;
    var _active_loadout_key = loadouts_get_active_key();
    var _is_active_loadout = true;
    var _has_loadouts = (_active_loadout_key != undefined);

    // Handle hand slots
    if (_def.equip_slot == EquipSlot.right_hand ||
        _def.equip_slot == EquipSlot.left_hand ||
        _def.equip_slot == EquipSlot.either_hand) {

        _is_hand_slot = true;

        if (_has_loadouts) {
            var _stats = _def.stats;
            var _is_ranged_weapon = false;
            if (_stats != undefined) {
                if (_stats[$ "is_ranged"] != undefined) {
                    _is_ranged_weapon = _stats[$ "is_ranged"];
                } else if (_stats[$ "requires_ammo"] != undefined) {
                    _is_ranged_weapon = true;
                }
            }

            _loadout_key = _is_ranged_weapon ? "ranged" : "melee";
            if (_def.equip_slot == EquipSlot.left_hand) {
                _loadout_key = _active_loadout_key;
            }
            if (!variable_struct_exists(loadouts, _loadout_key)) {
                _loadout_key = _active_loadout_key;
            }

            _loadout_struct = loadouts_get_struct(_loadout_key);
            _is_active_loadout = (_loadout_key == _active_loadout_key);
        }

        var _right_item = (_loadout_struct != undefined) ? _loadout_struct.right_hand : equipped.right_hand;
        var _left_item = (_loadout_struct != undefined) ? _loadout_struct.left_hand : equipped.left_hand;

        // Determine which hand slot is being targeted
        if (_def.equip_slot == EquipSlot.right_hand) {
            _slot_name = "right_hand";
        } else if (_def.equip_slot == EquipSlot.left_hand) {
            _slot_name = "left_hand";
        } else {
            if (_right_item != undefined && _right_item.definition.handedness == WeaponHandedness.two_handed) {
                _slot_name = "right_hand";
            } else if (_target_hand != undefined) {
                _slot_name = _target_hand;
            } else if (_right_item == undefined) {
                _slot_name = "right_hand";
            } else if (_left_item == undefined) {
                _slot_name = "left_hand";
            } else {
                _slot_name = "right_hand";
            }
        }

        // Two-handed handling
        if (_def.handedness == WeaponHandedness.two_handed) {
            if (_loadout_struct != undefined) {
                if (_loadout_struct.right_hand != undefined) {
                    inventory_add_item(_loadout_struct.right_hand.definition, _loadout_struct.right_hand.count);
                    if (_is_active_loadout && variable_struct_exists(_loadout_struct.right_hand.definition, "stats")) {
                        remove_wielder_effects(_loadout_struct.right_hand.definition.stats);
                    }
                }
                if (_loadout_struct.left_hand != undefined) {
                    inventory_add_item(_loadout_struct.left_hand.definition, _loadout_struct.left_hand.count);
                    if (_is_active_loadout && variable_struct_exists(_loadout_struct.left_hand.definition, "stats")) {
                        remove_wielder_effects(_loadout_struct.left_hand.definition.stats);
                    }
                }
                _loadout_struct.right_hand = undefined;
                _loadout_struct.left_hand = undefined;
            } else {
                if (equipped.right_hand != undefined) {
                    inventory_add_item(equipped.right_hand.definition, equipped.right_hand.count);
                    if (variable_struct_exists(equipped.right_hand.definition, "stats")) {
                        remove_wielder_effects(equipped.right_hand.definition.stats);
                    }
                    equipped.right_hand = undefined;
                }
                if (equipped.left_hand != undefined) {
                    inventory_add_item(equipped.left_hand.definition, equipped.left_hand.count);
                    if (variable_struct_exists(equipped.left_hand.definition, "stats")) {
                        remove_wielder_effects(equipped.left_hand.definition.stats);
                    }
                    equipped.left_hand = undefined;
                }
            }
            _slot_name = "right_hand";
            if (_is_active_loadout) {
                equipped.left_hand = undefined;
            }
        }
    } else {
        _slot_name = get_slot_name(_def.equip_slot);
    }

    var _slot_container;
    if (_is_hand_slot && _loadout_struct != undefined) {
        _slot_container = _loadout_struct;
    } else {
        _slot_container = equipped;
    }

    var _pending_returns = [];

    if (_is_hand_slot) {
        var _source_struct = (_loadout_struct != undefined) ? _loadout_struct : equipped;

        if (_def.handedness != WeaponHandedness.two_handed) {
            var _two_hand_entry = _source_struct.right_hand;
            if (_two_hand_entry != undefined && _two_hand_entry.definition.handedness == WeaponHandedness.two_handed) {
                var _returns = [{definition: _two_hand_entry.definition, count: _two_hand_entry.count}];
                if (_source_struct.left_hand != undefined) {
                    array_push(_returns, {definition: _source_struct.left_hand.definition, count: _source_struct.left_hand.count});
                }

                if (!inventory_can_accept_batch(_returns)) {
                    show_debug_message("Inventory full!");
                    return false;
                }

                if (_is_active_loadout && variable_struct_exists(_two_hand_entry.definition, "stats")) {
                    remove_wielder_effects(_two_hand_entry.definition.stats);
                }

                inventory_add_item(_two_hand_entry.definition, _two_hand_entry.count);
                _source_struct.right_hand = undefined;
                if (_is_active_loadout) {
                    equipped.right_hand = undefined;
                }

                if (_source_struct.left_hand != undefined) {
                    var _left_entry = _source_struct.left_hand;
                    inventory_add_item(_left_entry.definition, _left_entry.count);
                    if (_is_active_loadout && variable_struct_exists(_left_entry.definition, "stats")) {
                        remove_wielder_effects(_left_entry.definition.stats);
                    }
                    _source_struct.left_hand = undefined;
                    if (_is_active_loadout) {
                        equipped.left_hand = undefined;
                    }
                }
            }
        }
    }

    var _existing_slot_entry = _slot_container[$ _slot_name];
    if (_existing_slot_entry != undefined) {
        array_push(_pending_returns, {definition: _existing_slot_entry.definition, count: 1});
    }

    if (array_length(_pending_returns) > 0) {
        if (!inventory_can_accept_batch(_pending_returns)) {
            show_debug_message("Inventory full!");
            return false;
        }
    }

    // Unequip existing item in target slot
    if (_slot_container[$ _slot_name] != undefined) {
        var _old_item = _slot_container[$ _slot_name];
        inventory_add_item(_old_item.definition, 1);
        if (_is_hand_slot) {
            if (_is_active_loadout && variable_struct_exists(_old_item.definition, "stats")) {
                remove_wielder_effects(_old_item.definition.stats);
            }
        } else if (variable_struct_exists(_old_item.definition, "stats")) {
            remove_wielder_effects(_old_item.definition.stats);
        }
        _slot_container[$ _slot_name] = undefined;
        if (_is_hand_slot) {
            if (_is_active_loadout) {
                equipped[$ _slot_name] = undefined;
            }
        } else {
            equipped[$ _slot_name] = undefined;
        }
    }

    var _equipped_entry = _item;

    if (_item.count > 1) {
        _item.count--;
        _equipped_entry = {
            definition: _def,
            count: 1,
            durability: _item.durability
        };
    } else {
        array_delete(inventory, _inventory_index, 1);
    }

    _slot_container[$ _slot_name] = _equipped_entry;

    if (_is_hand_slot) {
        if (_is_active_loadout) {
            equipped[$ _slot_name] = _equipped_entry;
        } else if (_loadout_struct != undefined && loadouts_get_active_key() != _loadout_key) {
            // Ensure active loadout struct remains in sync with equipped data
            var _active_struct = loadouts_get_struct(loadouts_get_active_key());
            if (_active_struct != undefined) {
                equipped.right_hand = _active_struct.right_hand;
                equipped.left_hand = _active_struct.left_hand;
            }
        }
    } else {
        equipped[$ _slot_name] = _equipped_entry;
    }

    if (_is_hand_slot) {
        if (_is_active_loadout && variable_struct_exists(_def, "stats")) {
            apply_wielder_effects(_def.stats);
        }
    } else if (variable_struct_exists(_def, "stats")) {
        apply_wielder_effects(_def.stats);
    }

    return true;
}

// Unequip item back to inventory
function unequip_item(_slot_name) {
    if (equipped[$ _slot_name] == undefined) return false;

    var _item = equipped[$ _slot_name];

    // Remove wielder effects before unequipping
    if (variable_struct_exists(_item.definition, "stats")) {
        remove_wielder_effects(_item.definition.stats);
    }

    if (inventory_add_item(_item.definition, _item.count)) {
        equipped[$ _slot_name] = undefined;
        return true;
    }

    show_debug_message("Inventory full!");
    return false;
}

// Helper function to get slot name
function get_slot_name(_slot) {
    switch(_slot) {
        case EquipSlot.right_hand: return "right_hand";
        case EquipSlot.left_hand: return "left_hand";
        case EquipSlot.helmet: return "head";
        case EquipSlot.armor: return "torso";
        case EquipSlot.boots: return "legs";
        default: return "none";
    }
}

// Check if using weapon two-handed
function is_two_handing() {
    if (equipped.right_hand != undefined) {
        var _handedness = equipped.right_hand.definition.handedness;
        if (_handedness == WeaponHandedness.two_handed) return true;
    }
    return false;
}

// Check if dual-wielding
function is_dual_wielding() {
    return (equipped.right_hand != undefined &&
            equipped.left_hand != undefined &&
            equipped.right_hand.definition.type == ItemType.weapon &&
            equipped.left_hand.definition.type == ItemType.weapon);
}

// Check if player has ammo for ranged weapons
function has_ammo(_ammo_type) {
    for (var i = 0; i < array_length(inventory); i++) {
        var _item = inventory[i];
        if (_item.definition.item_id == _ammo_type && _item.count > 0) {
            return true;
        }
    }
    return false;
}

// Consume ammo when firing ranged weapons
function consume_ammo(_ammo_type, _amount = 1) {
    for (var i = 0; i < array_length(inventory); i++) {
        var _item = inventory[i];
        if (_item.definition.item_id == _ammo_type) {
            if (_item.count >= _amount) {
                inventory_remove_item(i, _amount);
                return true;
            }
        }
    }
    return false;
}

// Get item scale based on context and item properties
function get_item_scale(_item_def, _context) {
    switch (_context) {
        case "inventory_grid":
            // Large items (greatsword, bow, etc.) render at 2x, normal items at 4x
            // (spr_items is 32x32 base, needs scaling to be visible in 128px slots)
            return (_item_def.large_sprite ?? false) ? 2 : 4;

        case "loadout_slot":
            return 2;

        case "paperdoll_armor":
            return 4;

        default:
            return 1;
    }
}

function loadouts_get_active_key() {
    if (!variable_instance_exists(id, "loadouts")) return undefined;
    return loadouts.active;
}

function loadouts_get_struct(_loadout_key) {
    if (!variable_instance_exists(id, "loadouts")) return undefined;
    if (!variable_struct_exists(loadouts, _loadout_key)) return undefined;
    return loadouts[$ _loadout_key];
}

function loadouts_set_active(_loadout_key) {
    if (!variable_instance_exists(id, "loadouts")) return false;
    if (!variable_struct_exists(loadouts, _loadout_key)) return false;

    if (loadouts.active == _loadout_key) {
        return true;
    }

    // Store current equipped into existing active loadout before switching
    var _current_key = loadouts.active;
    if (variable_struct_exists(loadouts, _current_key)) {
        if (equipped.right_hand != undefined && variable_struct_exists(equipped.right_hand.definition, "stats")) {
            remove_wielder_effects(equipped.right_hand.definition.stats);
        }
        if (equipped.left_hand != undefined && variable_struct_exists(equipped.left_hand.definition, "stats")) {
            remove_wielder_effects(equipped.left_hand.definition.stats);
        }

        var _current_struct = loadouts[$ _current_key];
        _current_struct.right_hand = equipped.right_hand;
        _current_struct.left_hand = equipped.left_hand;
    }

    loadouts.active = _loadout_key;

    var _target_struct = loadouts[$ _loadout_key];
    equipped.right_hand = _target_struct.right_hand;
    equipped.left_hand = _target_struct.left_hand;

    if (equipped.right_hand != undefined && variable_struct_exists(equipped.right_hand.definition, "stats")) {
        apply_wielder_effects(equipped.right_hand.definition.stats);
    }
    if (equipped.left_hand != undefined && variable_struct_exists(equipped.left_hand.definition, "stats")) {
        apply_wielder_effects(equipped.left_hand.definition.stats);
    }

    return true;
}

function swap_active_loadout() {
    var _current = loadouts_get_active_key();
    if (_current == undefined) return false;

    var _next = (_current == "melee") ? "ranged" : "melee";
    if (!loadouts_set_active(_next)) return false;

    return true;
}

function inventory_get_slot_action(_player_instance, _slot_index) {
    if (_player_instance == noone) return InventoryContextAction.none;
    if (_slot_index < 0) return InventoryContextAction.none;

    var _inventory = _player_instance.inventory;
    if (_slot_index >= array_length(_inventory)) return InventoryContextAction.none;

    var _entry = _inventory[_slot_index];
    if (_entry == undefined) return InventoryContextAction.none;

    var _def = _entry.definition;
    if (_def == undefined) return InventoryContextAction.none;

    if (_def.equip_slot != EquipSlot.none) {
        return InventoryContextAction.equip;
    }

    if (_def.type == ItemType.consumable) {
        return InventoryContextAction.use;
    }

    return InventoryContextAction.none;
}

function inventory_perform_equip_on_player(_player_instance, _slot_index, _target_hand = undefined) {
    if (_player_instance == noone) return false;
    if (!is_undefined(_slot_index) && _slot_index < 0) return false;
    var _equip_method = method(_player_instance, equip_item);
    if (_equip_method == undefined) return false;
    return _equip_method(_slot_index, _target_hand);
}

function inventory_use_item(_inventory_index) {
    if (_inventory_index < 0 || _inventory_index >= array_length(inventory)) return false;

    var _item_entry = inventory[_inventory_index];
    if (_item_entry == undefined) return false;

    var _def = _item_entry.definition;
    if (_def == undefined) return false;

    if (_def.type != ItemType.consumable) return false;

    var _stats = _def.stats;
    if (_stats == undefined) {
        return false;
    }

    var _consumed = false;

    if (_stats[$ "heal_amount"] != undefined) {
        if (variable_instance_exists(id, "hp") && variable_instance_exists(id, "hp_total")) {
            if (hp < hp_total) {
                var _heal_amount = _stats[$ "heal_amount"];
                var _new_hp = clamp(hp + _heal_amount, 0, hp_total);
                if (_new_hp > hp) {
                    hp = _new_hp;
                    _consumed = true;
                }
            }
        }
    }

    if (_stats[$ "stamina_restore"] != undefined) {
        var _stamina_var = undefined;
        if (variable_instance_exists(id, "stamina")) {
            _stamina_var = "stamina";
        } else if (variable_instance_exists(id, "stamina_current")) {
            _stamina_var = "stamina_current";
        }

        if (_stamina_var != undefined) {
            var _stamina_max_var = undefined;
            if (variable_instance_exists(id, "stamina_max")) {
                _stamina_max_var = "stamina_max";
            } else if (variable_instance_exists(id, "stamina_total")) {
                _stamina_max_var = "stamina_total";
            }

            if (_stamina_max_var != undefined) {
                var _restore = _stats[$ "stamina_restore"];
                var _current_val = variable_instance_get(id, _stamina_var);
                var _max_val = variable_instance_get(id, _stamina_max_var);
                var _new_stamina = clamp(_current_val + _restore, 0, _max_val);
                if (_new_stamina > _current_val) {
                    variable_instance_set(id, _stamina_var, _new_stamina);
                    _consumed = true;
                }
            }
        }
    }

    if (_stats[$ "mana_restore"] != undefined) {
        var _mana_var = undefined;
        if (variable_instance_exists(id, "mana")) {
            _mana_var = "mana";
        } else if (variable_instance_exists(id, "mana_current")) {
            _mana_var = "mana_current";
        }

        if (_mana_var != undefined) {
            var _mana_max_var = undefined;
            if (variable_instance_exists(id, "mana_max")) {
                _mana_max_var = "mana_max";
            } else if (variable_instance_exists(id, "mana_total")) {
                _mana_max_var = "mana_total";
            }

            if (_mana_max_var != undefined) {
                var _restore_mana = _stats[$ "mana_restore"];
                var _mana_current = variable_instance_get(id, _mana_var);
                var _mana_max = variable_instance_get(id, _mana_max_var);
                var _new_mana = clamp(_mana_current + _restore_mana, 0, _mana_max);
                if (_new_mana > _mana_current) {
                    variable_instance_set(id, _mana_var, _new_mana);
                    _consumed = true;
                }
            }
        }
    }

    if (_stats[$ "damage_buff"] != undefined) {
        // Placeholder: apply temporary buff handling later
        _consumed = true;
    }

    if (!_consumed) {
        return false;
    }

    inventory_remove_item(_inventory_index, 1);
    return true;
}

function inventory_perform_use_on_player(_player_instance, _slot_index) {
    if (_player_instance == noone) return false;
    var _use_method = method(_player_instance, inventory_use_item);
    if (_use_method == undefined) return false;
    return _use_method(_slot_index);
}
