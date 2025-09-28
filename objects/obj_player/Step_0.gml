/// obj_player : Step

if (global.game_paused) exit;

// Make pillars slightly behind player at same position
depth = -bbox_bottom;

var _hor = 0;
var _ver = 0;

// Update elevation and offset
if (elevation_source != noone) {
    y_offset = elevation_source.y_offset;
    current_elevation = elevation_source.height;
} else {
    y_offset = 0;
    current_elevation = -1;
}

// Read grid visual offset (fallback if controller not present)
var GRID_Y_OFFSET = -8;
if (instance_exists(obj_grid_controller)) {
    GRID_Y_OFFSET = obj_grid_controller.GRID_Y_OFFSET;
}

#region Movement

if (state == PlayerState.on_grid && !obj_grid_controller.hop.active) {
	player_on_grid();
    
} else {
    player_dashing();

    // ============================================
    // KNOCKBACK SYSTEM
    // ============================================
    if (kb_x != 0 || kb_y != 0) {
        // Apply knockback movement
        move_and_collide(kb_x, kb_y, tilemap);

        // Reduce knockback over time
        kb_x *= 0.8;
        kb_y *= 0.8;

        // Stop knockback when it's very small
        if (abs(kb_x) < 0.1) kb_x = 0;
        if (abs(kb_y) < 0.1) kb_y = 0;
    }
    
    #region Pillar collision checking - ONLY when NOT on grid
    // Use un-offset probe Y so entering from LEFT/RIGHT registers correctly.
	if (state != PlayerState.on_grid && !obj_grid_controller.hop.active) {
	    var _instance = noone;
	    var pillar_list = ds_list_create();

	    // Find items in pillar radius — PROBE at (y - GRID_Y_OFFSET)
	    var probe_cx = x + interaction_offset_x;
	    var probe_cy = (y - GRID_Y_OFFSET) + interaction_offset_y;

	    var pillar_count = collision_circle_list(
	        probe_cx, probe_cy,
	        interaction_radius,
	        obj_rising_pillar,
	        false, true, 
	        pillar_list, true
	    );

	    if (pillar_count > 0) { 
	        _instance = pillar_list[| 0];
        
	        // Call move_onto to handle the transition
	        obj_grid_controller.move_onto(_instance);
	    }

	    ds_list_destroy(pillar_list);
	}
	#endregion
}
#endregion Movement

// ============================================
// PLAYER STEP EVENT - PICKUP CODE
// ============================================

#region Pickup items
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
        audio_play_sound(snd_chest_open, 1, false);
        
        show_debug_message("Picked up " + string(_count) + " " + _item_def.name);
        
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
                        _should_equip = (equipped.helmet == undefined);
                        break;
                        
                    case EquipSlot.armor:
                        _should_equip = (equipped.armor == undefined);
                        break;
                        
                    case EquipSlot.boots:
                        _should_equip = (equipped.boots == undefined);
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
        show_message("Inventory full!");
    }
}

ds_list_destroy(pickup_list);
#endregion


#region Animation
// ============================================
// ANIMATION
// ============================================

// Build animation key and look it up
var anim_key;
if (state == PlayerState.attacking) {
    anim_key = "attack_" + facing_dir;
} else if (move_dir == "idle") {
    anim_key = "idle_" + facing_dir;
} else if (is_dashing) {
    anim_key = "dash_" + facing_dir;
} else {
    anim_key = "walk_" + facing_dir;
}

// Check if animation changed
if (anim_key != current_anim) {
    current_anim = anim_key;
    var anim_info = anim_data[$ anim_key];
    current_anim_start = anim_info.start;
    current_anim_length = anim_info.length;
    
    // Reset animation frame on state changes
    if (state == PlayerState.attacking || move_dir != "idle") {
        anim_frame = 0;
    } else {
        anim_frame = global.idle_bob_timer % current_anim_length;
    }
    
    show_debug_message("Switched to: " + anim_key + " (frames " + string(current_anim_start) + "-" + string(current_anim_start + current_anim_length - 1) + ")");
}

if (state == PlayerState.attacking) {
    // Attack animations play once and don't loop
    anim_frame += anim_speed_walk * 1.5; // Slightly faster for attack animations
    if (anim_frame >= current_anim_length) {
        // Attack animation finished, return to idle state
        state = PlayerState.idle;
        anim_frame = 0;
    }
} else if (move_dir == "idle") {
    // For idle, sync with global timer but keep it in the idle animation range
    anim_frame = global.idle_bob_timer % current_anim_length;
} else {
    // Normal walking animation (also handles dash)
    anim_frame += anim_speed_walk;
    if (anim_frame >= current_anim_length) {
        anim_frame = anim_frame % current_anim_length;
    }
}

image_index = current_anim_start + floor(anim_frame);

#endregion Animation

#region Attack System

player_attacking();

#endregion Attack System
