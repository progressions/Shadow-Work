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

// Serialize method to save item data
/// @function serialize()
/// @description Save item-specific data for persistence
function serialize() {
    // Base persistent_parent fields (can't use event_inherited in custom functions)
    var _struct = {
        // Identity & Location
        object_type: object_get_name(object_index),
        persistent_id: persistent_id,
        x: x,
        y: y,
        room_name: room_get_name(room),
        sprite_index: sprite_get_name(sprite_index),
        image_index: image_index,
        image_xscale: image_xscale,
        image_yscale: image_yscale,
    };

    // Add item-specific data
    if (item_def != undefined) {
        // Store item_key to look up in database on load
        if (variable_struct_exists(item_def, "item_key")) {
            _struct.item_key = item_def.item_key;
            show_debug_message("Saving item with item_key: " + item_def.item_key);
        } else if (variable_struct_exists(item_def, "item_id")) {
            _struct.item_key = item_def.item_id;
            show_debug_message("Saving item with item_id: " + item_def.item_id);
        }
    } else {
        show_debug_message("WARNING: Saving item with undefined item_def!");
    }

    _struct.count = count;
    _struct.base_y = base_y;

    return _struct;
}

/// @function deserialize(_data)
/// @description Restore item-specific data from save
/// @param {struct} _data The saved data struct
function deserialize(_data) {
    show_debug_message("  Deserializing item at (" + string(_data.x) + ", " + string(_data.y) + ")");

    // Restore item definition from item_key
    if (variable_struct_exists(_data, "item_key")) {
        var _item_key = _data.item_key;
        show_debug_message("    Item key: " + _item_key);

        if (variable_struct_exists(global.item_database, _item_key)) {
            item_def = global.item_database[$ _item_key];
            show_debug_message("    Item def restored: " + item_def.name);
        } else {
            show_debug_message("    ERROR: Item key not found in database: " + _item_key);
        }
    } else {
        show_debug_message("    ERROR: No item_key in saved data");
    }

    // Restore count for stackable items
    if (variable_struct_exists(_data, "count")) {
        count = _data.count;
    }

    // Restore base_y for bobbing animation
    if (variable_struct_exists(_data, "base_y")) {
        base_y = _data.base_y;
    }

    show_debug_message("    can_interact(): " + string(can_interact()));
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

        // Save system tracking removed during rebuild

        // Auto-equip logic
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
        play_sfx(snd_pickup_denied);
        show_debug_message("Inventory full!");
    }
}