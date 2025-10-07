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

function get_melee_weapon_position(_facing) {
    switch(_facing) {
        case "down":  return {x: 0, y: 2, angle: 0};
        case "up":    return {x: 0, y: 2, angle: 90};
        case "left":  return {x: 0, y: 0, angle: 90};
        case "right": return {x: 0, y: 2, angle: 0};
    }
    return {x: 0, y: 0, angle: 0};
}

function get_ranged_weapon_position(_facing) {
    switch(_facing) {
        case "down":  return {x: -4, y: -4, angle: -90};
        case "up":    return {x: 4, y: -6, angle: 90};
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
    } else if (state != PlayerState.dashing) {
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
    draw_sprite_ext(_torch_sprite, _torch_frame, _tx, _ty, _xscale, 1, 0, image_blend, 1);
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
    } else if (state != PlayerState.dashing) {
        var _bob = (floor(anim_frame) % 2) * 1;
        _sy += _bob;
    }
    
    draw_sprite_ext(_shield_sprite, 0, _sx, _sy, 1, 1, _pos.angle, image_blend, 1);
}

function draw_weapon_simple(_item, _facing, _player_x, _player_y) {
	// Check if weapon is ranged
	var _is_ranged_weapon = (_item.definition.stats[$ "requires_ammo"] != undefined);

	// Only hide weapon during melee attacks (ranged weapons should stay visible)
	if (state == PlayerState.attacking) {
		if (!_is_ranged_weapon) return; // Hide only for melee attacks
	}

    var _weapon_sprite = get_equipped_sprite(_item.definition.equipped_sprite_key);
    if (_weapon_sprite == -1) return;

    // Get position based on weapon type
    var _pos = _is_ranged_weapon ? get_ranged_weapon_position(_facing) : get_melee_weapon_position(_facing);
    var _wx = _player_x + _pos.x;
    var _wy = _player_y + _pos.y;

    // Add bobbing
    if (move_dir == "idle") {
        if (floor(global.idle_bob_timer) % 2 == 1) {
            _wy += 1;
        }
    } else if (state != PlayerState.dashing) {
        var _bob = (floor(anim_frame) % 2) * 1;
        _wy += _bob;
    }

    // Adjust angle and scale for bows when facing left
    var _draw_angle = _pos.angle;
    var _draw_yscale = 1;
    if (_is_ranged_weapon && _facing == "left") {
        _draw_angle = 180; // Rotate 90 degrees counter-clockwise from 90
        _draw_yscale = -1; // Flip vertically to correct orientation
    }

    draw_sprite_ext(_weapon_sprite, 0, _wx, _wy, 1, _draw_yscale, _draw_angle, image_blend, 1);
}

// FIXED FUNCTION: Selective hand drawing
function draw_player_hands(_base_frame) {
	if (state == PlayerState.attacking) return;

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
		if (equipped.right_hand.definition.handedness == WeaponHandedness.two_handed) return;

        // Right hand covered by weapon, left hand visibility depends on facing direction
        if (facing_dir == "left") {
            // When facing left, weapon sprite includes left hand, so show right hand only
            draw_sprite_part_ext(
                _hands_sprite,
                _base_frame,
                _half, 0,          // Start from middle of sprite (RIGHT HALF)
                _half,             // Width of right half
                _sprite_height,    // Full height
                x - 8 + _half, y - 16 + y_offset,  // Offset x position by half width
                image_xscale, image_yscale,
                image_blend, 1
            );
        } else {
            // For other directions, show left hand only
            draw_sprite_part_ext(
                _hands_sprite,
                _base_frame,
                0, 0,              // Start from left edge
                _half,             // Width of left half
                _sprite_height,    // Full height
                x - 8, y - 16 + y_offset,
                image_xscale, image_yscale,
                image_blend, 1
            );
        }
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
                image_blend, 1
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
                image_blend, 1
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
            image_blend, 
            1
        );
    }
}

// Draw shadow first
draw_sprite_ext(spr_shadow, image_index, x, y + 2 + y_offset, 1, 0.5, 0, c_black, 0.3);

// Attack ready indicator
if (can_attack && equipped.right_hand != undefined) {
    // Draw a small glow around weapon when ready to attack
    var _alpha = 0.3 + sin(current_time * 0.01) * 0.2; // Pulsing effect
    draw_sprite_ext(sprite_index, image_index, x, y + y_offset, image_xscale, image_yscale, 0, c_yellow, _alpha);
}

function draw_player_with_equipment() {
    var _base_frame = image_index;
	if (global.game_paused) _base_frame = paused_frame; 
    
    var _x_offset = 0;
    var _y_offset = 0;
    
    var _item_x = x + _x_offset;
    
    // Different layering for each direction
    switch(facing_dir) {
        case "up":
            // Weapon behind player
            if (equipped.right_hand != undefined) {
                draw_weapon_simple(equipped.right_hand, facing_dir, x, y + y_offset);
            }

            // Shield/torch behind player
            if (equipped.left_hand != undefined && !is_two_handing()) {
                draw_left_hand_item(equipped.left_hand, facing_dir, x, y + y_offset);
            }

            // Player
            draw_sprite_ext(sprite_index, _base_frame, x, y + y_offset, image_xscale, image_yscale, 0, image_blend, 1);

            // Draw hands conditionally
            draw_player_hands(_base_frame);

            // Armor layers
            draw_armor_layers(_base_frame, _item_x, y + y_offset);
            break;
            
        case "right":
        case "down":
            // Player first
            draw_sprite_ext(sprite_index, _base_frame, x, y + y_offset, image_xscale, image_yscale, 0, image_blend, 1);
            
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
            draw_sprite_ext(sprite_index, _base_frame, x, y + y_offset, image_xscale, image_yscale, 0, image_blend, 1);
            
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
            draw_sprite_ext(_armor_sprite, _frame, _x, _y, image_xscale, image_yscale, 0, image_blend, 1);
        }
    }
    
    if (equipped.head != undefined) {
        var _helmet_sprite = get_equipped_sprite(equipped.head.definition.equipped_sprite_key);
        if (_helmet_sprite != -1) {
            draw_sprite_ext(_helmet_sprite, _frame, _x, _y, image_xscale, image_yscale, 0, image_blend, 1);
        }
    }
    
    if (equipped.legs != undefined) {
        var _boots_sprite = get_equipped_sprite(equipped.legs.definition.equipped_sprite_key);
        if (_boots_sprite != -1) {
            draw_sprite_ext(_boots_sprite, _frame, _x, _y, image_xscale, image_yscale, 0, image_blend, 1);
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

// Debug display for attack system (remove this later)
if (debug) {
    draw_set_color(c_white);
    draw_set_font(-1);
    var _debug_y = y - 40;

    if (equipped.right_hand != undefined) {
        var _weapon = equipped.right_hand.definition;
        draw_text(x - 50, _debug_y, "Weapon: " + _weapon.name);
        draw_text(x - 50, _debug_y - 15, "Speed: " + string(_weapon.stats.attack_speed));
        draw_text(x - 50, _debug_y - 30, "Damage: " + string(get_total_damage()));
    } else {
        draw_text(x - 50, _debug_y, "Unarmed");
        draw_text(x - 50, _debug_y - 15, "Speed: 1.0");
        draw_text(x - 50, _debug_y - 30, "Damage: 1");
    }

    draw_text(x - 50, _debug_y - 45, "Cooldown: " + string(attack_cooldown));
    draw_text(x - 50, _debug_y - 60, "Can Attack: " + (can_attack ? "YES" : "NO"));
}

// Health bar above player
if (hp < hp_total) { // Only show when damaged
    var bar_x1 = x - 10;
    var bar_y1 = bbox_top - 10;
    var bar_x2 = x + 10;
    var bar_y2 = bbox_top - 8;

    draw_healthbar(bar_x1, bar_y1, bar_x2, bar_y2, (hp / hp_total) * 100, c_black, c_red, c_lime, 0, true, false);
}

// Status effect duration bars above player (no icons)
var _timed_traits = get_active_timed_trait_data();
if (array_length(_timed_traits) > 0) {
    var _bar_width = 20;
    var _bar_height = 3;
    var _bar_spacing = 2;
    var _visible_traits = [];

    for (var _i = 0; _i < array_length(_timed_traits); _i++) {
        var _entry = _timed_traits[_i];
        if (_entry.total <= 0) continue;

        var _trait_info = status_effect_get_trait_data(_entry.trait);
        if (_trait_info == undefined) continue;

        if (_entry.effective_stacks <= 0) continue;

        var _color = c_white;
        if (variable_struct_exists(_trait_info, "ui_color")) {
            _color = _trait_info.ui_color;
        }

        array_push(_visible_traits, {
            trait: _entry.trait,
            remaining: _entry.remaining,
            total: _entry.total,
            stacks: _entry.effective_stacks,
            color: _color
        });
    }

    if (array_length(_visible_traits) > 0) {
        var _total_height = (array_length(_visible_traits) * (_bar_height + _bar_spacing)) - _bar_spacing;
        var _start_y = bbox_top - 15 - _total_height;

        for (var _j = 0; _j < array_length(_visible_traits); _j++) {
            var _effect = _visible_traits[_j];
            var _bar_y = _start_y + (_j * (_bar_height + _bar_spacing));
            var _bar_x1 = x - _bar_width / 2;
            var _bar_x2 = x + _bar_width / 2;
            var _percent = clamp(_effect.remaining / max(1, _effect.total), 0, 1);

            draw_set_color(c_black);
            draw_rectangle(_bar_x1, _bar_y, _bar_x2, _bar_y + _bar_height, false);
            draw_set_color(_effect.color);
            draw_rectangle(_bar_x1, _bar_y, _bar_x1 + (_bar_width * _percent), _bar_y + _bar_height, false);

            if (_effect.stacks > 1) {
                draw_set_color(_effect.color);
                draw_text(_bar_x2 + 2, _bar_y - 2, "x" + string(_effect.stacks));
            }
        }

        draw_set_color(c_white);
        draw_set_alpha(1);
    }
}

// Ensure alpha is always reset at end of draw
draw_set_alpha(1);

// Debug: Display damage reduction values
if (global.debug_mode) {
    var _melee_dr = get_melee_damage_reduction();
    var _ranged_dr = get_ranged_damage_reduction();

    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_text(x - 32, bbox_top - 40, "Melee DR: " + string(_melee_dr));
    draw_text(x - 32, bbox_top - 50, "Ranged DR: " + string(_ranged_dr));
}
