// ============================================
// COMPLETE DRAW EVENT WITH TORCH SUPPORT AND HEIGHT OFFSET
// ============================================

// Helper functions first
function get_shield_position(_facing) {
    switch(_facing) {
        case "down":  return {x: 0, y: 0, angle: 0};
        case "up":    return {x: 0, y: 0, angle: 0};
        case "left":  return {x: 10, y: 0, angle: 0};
        case "right": return {x: 0, y: 0, angle: 0};
    }
    return {x: 0, y: 0, angle: 0};
}

function get_torch_position(_facing) {
    switch(_facing) {
        case "down":  return {x: 0, y: 0, flip: true};
        case "up":    return {x: 0, y: 1, flip: false};
        case "left":  return {x: 1, y: -1, flip: false};   // Flip when facing left
        case "right": return {x: 0, y: 0, flip: true};
    }
    return {x: 0, y: 0, flip: false};
}

function get_weapon_position(_facing) {
    switch(_facing) {
        case "down":  return {x: 0, y: 2, angle: 0};
        case "up":    return {x: 0, y: 2, angle: 90};
        case "left":  return {x: 0, y: 0, angle: 90};
        case "right": return {x: 0, y: 2, angle: 0};
    }
    return {x: 0, y: 0, angle: 0};
}

function draw_left_hand_item(_item, _facing, _player_x, _player_y) {
    // Check if it's a torch
    if (_item.definition.item_id == "torch") {
        draw_torch_simple(_item, _facing, _player_x, _player_y);
    } else {
        // It's a shield or other left-hand item
        draw_shield_simple(_item, _facing, _player_x, _player_y);
    }
}

function draw_torch_simple(_item, _facing, _player_x, _player_y) {
    var _torch_sprite = get_equipped_sprite(_item.definition.equipped_sprite_key);
    if (_torch_sprite == -1) return;
    
    var _pos = get_torch_position(_facing);
    var _tx = _player_x + _pos.x;
    var _ty = _player_y + _pos.y;
    
	
    // Add bobbing
    if (move_dir == "idle") {
        if (floor(global.idle_bob_timer) % 2 == 1) {
            _ty += 1;
        }
    } else if (!is_dashing) {
        var _bob = (floor(anim_frame) % 2) * 1;
        _ty += _bob;
    
	}
    
	var _torch_frame = 0;
	if (!global.game_paused) {
    // Animate the torch flame (cycle through 8 frames)
      _torch_frame = floor(current_time / 100) % 8;  // Adjust 100 for speed
	}
    // Draw torch with flip if needed
    var _xscale = _pos.flip ? -1 : 1;
    draw_sprite_ext(_torch_sprite, _torch_frame, _tx, _ty, _xscale, 1, 0, c_white, 1);
}

function draw_shield_simple(_item, _facing, _player_x, _player_y) {
    var _shield_sprite = get_equipped_sprite(_item.definition.equipped_sprite_key);
    if (_shield_sprite == -1) return;
    
    var _pos = get_shield_position(_facing);
    var _sx = _player_x + _pos.x;
    var _sy = _player_y + _pos.y;
    
    // Add bobbing
    if (move_dir == "idle") {
        if (floor(global.idle_bob_timer) % 2 == 1) {
            _sy += 1;
        }
    } else if (!is_dashing) {
        var _bob = (floor(anim_frame) % 2) * 1;
        _sy += _bob;
    }
    
    draw_sprite_ext(_shield_sprite, 0, _sx, _sy, 1, 1, _pos.angle, c_white, 1);
}

function draw_weapon_simple(_item, _facing, _player_x, _player_y) {
    var _weapon_sprite = get_equipped_sprite(_item.definition.equipped_sprite_key);
    if (_weapon_sprite == -1) return;
    
    var _pos = get_weapon_position(_facing);
    var _wx = _player_x + _pos.x;
    var _wy = _player_y + _pos.y;
    
    // Add bobbing
    if (move_dir == "idle") {
        if (floor(global.idle_bob_timer) % 2 == 1) {
            _wy += 1;
        }
    } else if (!is_dashing) {
        var _bob = (floor(anim_frame) % 2) * 1;
        _wy += _bob;
    }
    
    draw_sprite_ext(_weapon_sprite, 0, _wx, _wy, 1, 1, _pos.angle, c_white, 1);
}

// FIXED FUNCTION: Selective hand drawing
function draw_player_hands(_base_frame) {

    // Determine which hands to show
    var _holding_torch = (equipped.left_hand != undefined && 
                         equipped.left_hand.definition.item_id == "torch");
    var _has_weapon = (equipped.right_hand != undefined);
    
    // If holding a weapon, weapon sprite includes the right hand
    // If holding a torch, torch sprite includes the left hand (but flips when facing left)
    var _hands_sprite = spr_player_hands;
    var _sprite_width = sprite_get_width(_hands_sprite);
    var _sprite_height = sprite_get_height(_hands_sprite);
    var _half = _sprite_width / 2;
        
    if (_has_weapon && _holding_torch) {
        // Both hands covered by item sprites
        return;
    } else if (_has_weapon && !_holding_torch) {
		
		// if the weapon is two-handed, no need to draw the hands
		if (equipped.right_hand.definition.stats.handedness == WeaponHandedness.TWO_HANDED) return;
		
        // Right hand covered by weapon, need to show left hand only
        draw_sprite_part_ext(
            _hands_sprite,
            _base_frame,
            0, 0,              // Start from left edge
            _half,             // Width of left half
            _sprite_height,    // Full height
            x - 8, y - 16 + y_offset, 
            image_xscale, image_yscale,
            c_white, 1
        );
    } else if (!_has_weapon && _holding_torch) {
        // Torch covers one hand, but which one depends on facing direction
        
        if (facing_dir == "left") {
            // When facing left, torch is on the right side, so show left hand
            draw_sprite_part_ext(
                _hands_sprite,
                _base_frame,
                0, 0,              // Start from left edge
                _half,             // Width of left half
                _sprite_height,    // Full height
                x - 8, y - 16 + y_offset, 
                image_xscale, image_yscale,
                c_white, 1
            );
        } else {
            // For all other directions, torch is on left side, so show right hand
            draw_sprite_part_ext(
                _hands_sprite,
                _base_frame,
                _half, 0,          // Start from middle of sprite (RIGHT HALF)
                _half,             // Width of right half (not full width!)
                _sprite_height,    // Full height
                x - 8 + _half, y - 16 + y_offset,  // Offset x position by half width
                image_xscale, image_yscale,
                c_white, 1
            );
        }
    } else if (!_has_weapon && !_holding_torch) {
        // Show both hands normally
        draw_sprite_part_ext(
            spr_player_hands, 
            _base_frame, 
            0, 0,                    // Start from top-left of source sprite
            _sprite_width,           // Full width
            _sprite_height,          // Full height
            x - 8, y - 16 + y_offset,           // Draw position
            image_xscale, 
            image_yscale, 
            c_white, 
            1
        );
    }
}

// Draw shadow first
draw_sprite_ext(spr_shadow, image_index, x, y + 2 + y_offset, 1, 0.5, 0, c_black, 0.3);

function draw_player_with_equipment() {
    var _base_frame = image_index;
	if (global.game_paused) _base_frame = paused_frame; 
    
    var _x_offset = 0;
    var _y_offset = 0;
    
    var _item_x = x + _x_offset;
    
    // Different layering for each direction
    switch(facing_dir) {
        case "up":
            // Shield/torch behind player
            if (equipped.left_hand != undefined && !is_two_handing()) {
                draw_left_hand_item(equipped.left_hand, facing_dir, x, y + y_offset);
            }
            
            // Player
            draw_sprite_ext(sprite_index, _base_frame, x, y + y_offset, image_xscale, image_yscale, 0, c_white, 1);
            
            // Draw hands conditionally
            draw_player_hands(_base_frame);
            
            // Armor layers
            draw_armor_layers(_base_frame, _item_x, y + y_offset);
            
            // Weapon in front
            if (equipped.right_hand != undefined) {
                draw_weapon_simple(equipped.right_hand, facing_dir, x, y + y_offset);
            }
            break;
            
        case "right":
        case "down":
            // Player first
            draw_sprite_ext(sprite_index, _base_frame, x, y + y_offset, image_xscale, image_yscale, 0, c_white, 1);
            
            // Draw hands conditionally
            draw_player_hands(_base_frame);
            
            draw_armor_layers(_base_frame, _item_x, y + y_offset);
            
            // Weapon
            if (equipped.right_hand != undefined) {
                draw_weapon_simple(equipped.right_hand, facing_dir, x, y + y_offset);
            }
            
            // Shield/torch on top
            if (equipped.left_hand != undefined && !is_two_handing()) {
                draw_left_hand_item(equipped.left_hand, facing_dir, x, y + y_offset);
            }
            break;
            
        case "left":
            // Player
            draw_sprite_ext(sprite_index, _base_frame, x, y + y_offset, image_xscale, image_yscale, 0, c_white, 1);
            
            // Draw hands conditionally
            draw_player_hands(_base_frame);
            
            draw_armor_layers(_base_frame, _item_x, y + y_offset);
            
            // Weapon
            if (equipped.right_hand != undefined) {
                draw_weapon_simple(equipped.right_hand, facing_dir, x, y + y_offset);
            }
            
            // Shield/torch in front
            if (equipped.left_hand != undefined && !is_two_handing()) {
                draw_left_hand_item(equipped.left_hand, facing_dir, x, y + y_offset);
            }
            break;
    }
}

function draw_armor_layers(_frame, _x, _y) {
    if (equipped.torso != undefined) {
        var _armor_sprite = get_equipped_sprite(equipped.torso.definition.equipped_sprite_key);
        if (_armor_sprite != -1) {
            draw_sprite_ext(_armor_sprite, _frame, _x, _y, image_xscale, image_yscale, 0, c_white, 1);
        }
    }
    
    if (equipped.head != undefined) {
        var _helmet_sprite = get_equipped_sprite(equipped.head.definition.equipped_sprite_key);
        if (_helmet_sprite != -1) {
            draw_sprite_ext(_helmet_sprite, _frame, _x, _y, image_xscale, image_yscale, 0, c_white, 1);
        }
    }
    
    if (equipped.legs != undefined) {
        var _boots_sprite = get_equipped_sprite(equipped.legs.definition.equipped_sprite_key);
        if (_boots_sprite != -1) {
            draw_sprite_ext(_boots_sprite, _frame, _x, _y, image_xscale, image_yscale, 0, c_white, 1);
        }
    }
}

function get_equipped_sprite(_sprite_key) {
    var _sprite_name = "spr_wielded_" + _sprite_key;
    var _sprite = asset_get_index(_sprite_name);
    
    if (sprite_exists(_sprite)) {
        return _sprite;
    }
    
    _sprite_name = "spr_worn_" + _sprite_key;
    _sprite = asset_get_index(_sprite_name);
    
    if (sprite_exists(_sprite)) {
        return _sprite;
    }
    
    return -1;
}

draw_player_with_equipment();