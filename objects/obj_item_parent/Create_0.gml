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
    if (!instance_exists(obj_player)) return;

    var _player = obj_player;
    var _is_ammo_pickup = (item_def.type == ItemType.ammo) ||
                          ((item_def.stats != undefined) && (item_def.stats[$ "is_ammo"] ?? false));

    // Handle ammo pickup
    if (_is_ammo_pickup) {
        with (_player) {
            var _max_arrows = arrow_max ?? 25;
            var _space_available = clamp(_max_arrows - arrow_count, 0, _max_arrows);

            if (_space_available <= 0) {
                show_debug_message("Arrow pouch is full");
                return;
            }

            var _taken = min(_space_available, other.count);
            arrow_count += _taken;

            play_sfx(snd_chest_open, 1, false);
            show_debug_message("Picked up " + string(_taken) + " arrows (" + string(arrow_count) + "/" + string(_max_arrows) + ")");

            increment_quest_counter("items_collected", _taken);
            increment_quest_counter("item_" + other.item_def.item_id, _taken);

            if (other.count > _taken) {
                other.count = other.count - _taken;
            } else {
                if (variable_instance_exists(other, "item_spawn_id")) {
                    array_push(global.picked_up_items, other.item_spawn_id);
                }
                instance_destroy(other);
            }
        }
        return;
    }

    // Try to add to inventory
    var _added_to_inventory = false;
    with (_player) {
        _added_to_inventory = inventory_add_item(other.item_def, other.count);
    }

    if (_added_to_inventory) {
        // Play pickup sound
        play_sfx(snd_chest_open, 1, false);

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
                            _should_equip = (equipped.right_hand == undefined);
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