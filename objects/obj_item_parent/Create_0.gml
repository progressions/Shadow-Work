// ============================================
// obj_item_parent (PARENT OBJECT - your existing parent)
// ============================================
// CREATE EVENT:

// Call parent create event (obj_interactable_parent -> obj_persistent_parent)
event_inherited();

item_def = undefined;
count = 1;
base_y = y;

// Generate unique spawn ID for tracking (must be deterministic based on position)
item_spawn_id = room_get_name(room) + "_item_" + string(x) + "_" + string(y);

sprite_index = spr_items;
image_speed = 0;

// Interaction properties (override parent defaults)
interaction_radius = 32;
interaction_priority = 40;  // Lower than chests (50) and companions (100)
interaction_key = "Space";
interaction_action = "Pick up";
// interaction_prompt inherited from obj_interactable_parent

// Implement interaction methods
/// @function can_interact()
/// @description Returns whether this item can be picked up
function can_interact() {
    return item_def != undefined; // Can interact if item has valid definition
}

/// @function on_interact()
/// @description Called when player presses spacebar to pick up item
function on_interact() {
    var _player = instance_find(obj_player, 0);
    if (_player == noone) return;

    // Try to add to inventory
    var _added_to_inventory = false;
    with (_player) {
        _added_to_inventory = inventory_add_item(other.item_def, other.count);
    }

    if (_added_to_inventory) {
        // Play pickup sound
        play_sfx(snd_item_pickup, 1, false);

        show_debug_message("Picked up " + string(count) + " " + item_def.name);

        // Track item pickup for quest system
        increment_quest_counter("items_collected", count);
        increment_quest_counter("item_" + item_def.item_id, count);

        // Track picked up item for room state persistence
        if (variable_instance_exists(id, "item_spawn_id")) {
            show_debug_message("Tracking picked up item: " + item_spawn_id);
            array_push(global.picked_up_items, item_spawn_id);
            show_debug_message("Total picked up items tracked: " + string(array_length(global.picked_up_items)));
        }

        // Auto-equip logic (simplified from player_handle_pickup)
        with (_player) {
            if (other.item_def.type == ItemType.weapon ||
                other.item_def.type == ItemType.armor ||
                other.item_def.type == ItemType.tool) {

                // Find the item we just added in inventory
                var _inventory_index = -1;
                for (var i = array_length(inventory) - 1; i >= 0; i--) {
                    if (inventory[i].definition.item_id == other.item_def.item_id) {
                        _inventory_index = i;
                        break;
                    }
                }

                if (_inventory_index != -1) {
                    var _should_equip = false;
                    var _target_hand = undefined;

                    // Determine if we should auto-equip based on slot
                    switch(other.item_def.equip_slot) {
                        case EquipSlot.right_hand:
                            // Check if this is a ranged weapon
                            var _is_ranged_weapon = false;
                            var _stats = other.item_def.stats;
                            if (_stats != undefined) {
                                if (_stats[$ "is_ranged"] != undefined) {
                                    _is_ranged_weapon = _stats[$ "is_ranged"];
                                } else if (_stats[$ "requires_ammo"] != undefined) {
                                    _is_ranged_weapon = true;
                                }
                            }

                            // For ranged weapons, check the ranged loadout
                            if (_is_ranged_weapon && variable_struct_exists(loadouts, "ranged")) {
                                _should_equip = (loadouts.ranged.right_hand == undefined);
                            } else {
                                // For melee weapons, check the current equipped slot
                                _should_equip = (equipped.right_hand == undefined);
                            }
                            break;

                        case EquipSlot.left_hand:
                            if (equipped.right_hand == undefined ||
                                equipped.right_hand.definition.handedness != WeaponHandedness.two_handed) {
                                _should_equip = (equipped.left_hand == undefined);
                            }
                            break;

                        case EquipSlot.either_hand:
                            if (equipped.right_hand == undefined) {
                                _should_equip = true;
                                _target_hand = "right_hand";
                            } else if (equipped.left_hand == undefined) {
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
                            show_debug_message("Auto-equipped " + other.item_def.name);
                        }
                    }
                }
            }
        }

        // Destroy the world item
        instance_destroy();
    } else {
        // Inventory full
        show_debug_message("Inventory full!");
    }
}