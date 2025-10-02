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

    return (_count <= 0); // Return true if all items were added
}

// Remove item from inventory
function inventory_remove_item(_inventory_index, _count = 1) {
    if (_inventory_index < 0 || _inventory_index >= array_length(inventory)) return false;

    var _item = inventory[_inventory_index];

    if (_item.count > _count) {
        _item.count -= _count;
        return true;
    } else {
        array_delete(inventory, _inventory_index, 1);
        return true;
    }
}

// Equip item with two-handed weapon handling
function equip_item(_inventory_index, _target_hand = undefined) {
    if (_inventory_index < 0 || _inventory_index >= array_length(inventory)) return false;

    var _item = inventory[_inventory_index];
    var _def = _item.definition;

    if (_def.equip_slot == EquipSlot.none) return false;

    var _slot_name = "";

    // Handle hand slots
    if (_def.equip_slot == EquipSlot.right_hand ||
        _def.equip_slot == EquipSlot.left_hand ||
        _def.equip_slot == EquipSlot.either_hand) {

        // Determine which hand to equip to
        if (_def.equip_slot == EquipSlot.right_hand) {
            _slot_name = "right_hand";
        } else if (_def.equip_slot == EquipSlot.left_hand) {
            _slot_name = "left_hand";
        } else if (_def.equip_slot == EquipSlot.either_hand) {
            // Player can choose, or auto-select empty hand
            if (_target_hand != undefined) {
                _slot_name = _target_hand;
            } else {
                // Auto-select: prefer right hand if empty, then left hand
                if (equipped.right_hand == undefined) {
                    _slot_name = "right_hand";
                } else if (equipped.left_hand == undefined) {
                    _slot_name = "left_hand";
                } else {
                    _slot_name = "right_hand"; // Default to right if both occupied
                }
            }
        }

        // Check for two-handed weapon restrictions
        if (_def.handedness == WeaponHandedness.two_handed) {
            // Clear both hands for two-handed weapons
            if (equipped.right_hand != undefined) {
                inventory_add_item(equipped.right_hand.definition, equipped.right_hand.count);
                equipped.right_hand = undefined;
            }
            if (equipped.left_hand != undefined) {
                inventory_add_item(equipped.left_hand.definition, equipped.left_hand.count);
                equipped.left_hand = undefined;
            }
            _slot_name = "right_hand"; // Two-handed weapons go in right hand
        } else {
            // Check if currently holding a two-handed weapon
            var _current_right = equipped.right_hand;
            if (_current_right != undefined &&
                _current_right.definition.handedness == WeaponHandedness.two_handed) {
                // Can't equip anything else while holding two-handed weapon
                show_message("Cannot equip " + _def.name + " while wielding a two-handed weapon!");
                return false;
            }
        }
    } else {
        // Non-hand slots (helmet, armor, boots)
        _slot_name = get_slot_name(_def.equip_slot);
    }

    // Unequip current item in that slot
    if (equipped[$ _slot_name] != undefined) {
        var _old_item = equipped[$ _slot_name];
        inventory_add_item(_old_item.definition, _old_item.count);
        // Remove wielder effects from old item
        if (variable_struct_exists(_old_item.definition, "stats")) {
            remove_wielder_effects(_old_item.definition.stats);
        }
    }

    // Equip new item
    equipped[$ _slot_name] = _item;

    // For stackable items, only take 1 from the stack
    if (_item.count > 1) {
        _item.count--;
        // Create new instance for equipped item
        equipped[$ _slot_name] = {
            definition: _def,
            count: 1,
            durability: _item.durability
        };
    } else {
        array_delete(inventory, _inventory_index, 1);
    }

    // Apply wielder effects from new item
    if (variable_struct_exists(_def, "stats")) {
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
