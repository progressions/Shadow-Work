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

/// @function serialize()
/// @description Save item state for persistence
function serialize() {
    // Create base data struct (from obj_persistent_parent)
    var data = {
        object_type: object_get_name(object_index),
        x: x,
        y: y,
        persistent_id: persistent_id
    };

    // Add item-specific data
    if (item_def != undefined) {
        data.item_id = item_def.item_id;
    } else {
        data.item_id = undefined;
    }
    data.count = count;
    data.base_y = base_y;
    data.item_spawn_id = item_spawn_id;

    return data;
}

/// @function deserialize(data)
/// @description Restore item state from save data
function deserialize(data) {
    // Restore base data (from obj_persistent_parent)
    x = data.x;
    y = data.y;

    // Restore item-specific data (check if field exists first)
    if (variable_struct_exists(data, "item_id") && data.item_id != undefined && variable_global_exists("item_database")) {
        // Restore item_def reference from global database
        item_def = global.item_database[$ data.item_id];

        if (item_def != undefined) {
            // Set sprite frame based on item_id
            image_index = item_def.world_sprite_frame;
        }
    } else {
        item_def = undefined;
    }

    if (variable_struct_exists(data, "count")) {
        count = data.count;
    }

    if (variable_struct_exists(data, "base_y")) {
        base_y = data.base_y;
    }

    if (variable_struct_exists(data, "item_spawn_id")) {
        item_spawn_id = data.item_spawn_id;
    }
}

/// @function on_interact()
/// @description Called when player presses spacebar to pick up item
function on_interact() {
    show_debug_message("on_interact called on: " + object_get_name(object_index));
    show_debug_message("item_def: " + (item_def != undefined ? item_def.name : "undefined"));

    var _player = instance_find(obj_player, 0);
    if (_player == noone) return;

    // Try to add to inventory
    var _added_to_inventory = false;
    with (_player) {
        _added_to_inventory = inventory_add_item(other.item_def, other.count);
    }

    if (_added_to_inventory) {
        // Play pickup sound
        show_debug_message("About to call play_sfx from item");
        play_sfx(snd_item_pickup);
        show_debug_message("play_sfx call completed");

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