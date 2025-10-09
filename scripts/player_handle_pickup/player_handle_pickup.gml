function player_handle_pickup() {
    var _instance = noone;
    var pickup_list = ds_list_create();

    // Find items in pickup radius
    var pickup_count = collision_circle_list(x + interaction_offset_x, y + interaction_offset_y,
                                             interaction_radius, obj_item_parent, false, true,
                                             pickup_list, true);

    if (pickup_count > 0) {
        show_debug_message("Found something");
        _instance = pickup_list[| 0];
        show_debug_message(_instance);
    }

    if (_instance != noone && _instance.item_def != undefined) {
        var _item_def = _instance.item_def;
        var _count = _instance.count;
        // Try to add to inventory
        if (inventory_add_item(_item_def, _count)) {
            // Play pickup sound
            play_sfx(snd_item_pickup, 1, false);

            show_debug_message("Picked up " + string(_count) + " " + _item_def.name);

            // Track item pickup for quest system
            increment_quest_counter("items_collected", _count);
            // Track specific item pickups with item_id as counter key
            increment_quest_counter("item_" + _item_def.item_id, _count);

            // Track picked up item for room state persistence
            if (variable_instance_exists(_instance, "item_spawn_id")) {
                show_debug_message("Tracking picked up item: " + _instance.item_spawn_id);
                array_push(global.picked_up_items, _instance.item_spawn_id);
                show_debug_message("Total picked up items tracked: " + string(array_length(global.picked_up_items)));
            }

            // Auto-equip logic
            if (_item_def.type == ItemType.weapon || _item_def.type == ItemType.armor || _item_def.type == ItemType.tool) {

                // Find the item we just added in inventory
                var _inventory_index = -1;
                for (var i = array_length(inventory) - 1; i >= 0; i--) {
                    if (inventory[i].definition.item_id == _item_def.item_id) {
                        _inventory_index = i;
                        break;
                    }
                }

                if (_inventory_index != -1) {
                    var _should_equip = false;
                    var _target_hand = undefined;

                    // Determine if we should auto-equip based on slot
                    switch(_item_def.equip_slot) {
                        case EquipSlot.right_hand:
                            _should_equip = (equipped.right_hand == undefined);
                            break;

                        case EquipSlot.left_hand:
                            // Only auto-equip if not holding two-handed weapon
                            if (equipped.right_hand == undefined ||
                                equipped.right_hand.definition.handedness != WeaponHandedness.two_handed) {
                                _should_equip = (equipped.left_hand == undefined);
                            }
                            break;

                        case EquipSlot.either_hand:
                            // Prefer right hand, then left hand
                            if (equipped.right_hand == undefined) {
                                _should_equip = true;
                                _target_hand = "right_hand";
                            } else if (equipped.left_hand == undefined) {
                                // Check if right hand has two-handed weapon
                                if (equipped.right_hand.definition.handedness != WeaponHandedness.two_handed) {
                                    _should_equip = true;
                                    _target_hand = "left_hand";
                                }
                            }
                            break;

                        case EquipSlot.helmet:
                            _should_equip = (equipped.head == undefined);
                            break;

                        case EquipSlot.armor:
                            _should_equip = (equipped.torso == undefined);
                            break;

                        case EquipSlot.boots:
                            _should_equip = (equipped.legs == undefined);
                            break;
                    }

                    // Try to equip if appropriate
                    if (_should_equip) {
                        if (equip_item(_inventory_index, _target_hand)) {
                            show_debug_message("Auto-equipped " + _item_def.name);
                        }
                    }
                }
            }

            // Destroy the world item
            instance_destroy(_instance);
        } else {
            // Inventory full
            show_debug_message("Inventory full!");
        }
    }

    ds_list_destroy(pickup_list);
}
