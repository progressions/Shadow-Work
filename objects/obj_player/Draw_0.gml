// ============================================
// COMPLETE DRAW EVENT
// ============================================

// Helper functions first
function get_shield_position(_facing) {
    switch(_facing) {
        case "down":  return {x: 0, y: 0, angle: 0};
        case "up":    return {x: 0, y: 0, angle: 0};
        case "left":  return {x: 0, y: 0, angle: 0};
        case "right": return {x: 0, y: 0, angle: 0};
    }
    return {x: 0, y: 0, angle: 0};
}

function get_weapon_position(_facing) {
    switch(_facing) {
        case "down":  return {x: -2, y: -8, angle: 270};
        case "up":    return {x: 0, y: 0, angle: 90};
        case "left":  return {x: 0, y: 0, angle: 90};
        case "right": return {x: 0, y: 0, angle: 0};
    }
    return {x: 0, y: 0, angle: 0};
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

// Draw shadow first
draw_sprite_ext(spr_shadow, image_index, x, y + 2, 1, 0.5, 0, c_black, 0.3);

function draw_player_with_equipment() {
    var _base_frame = image_index;
    
    var _x_offset = 0;
    var _y_offset = 0;
    
    if (facing_dir == "left") {
        // _x_offset = -16;
    }
    
    var _item_x = x + _x_offset;
    
    // Different layering for each direction
    switch(facing_dir) {
        case "up":
            // Shield behind player
            if (equipped.left_hand != undefined && !is_two_handing()) {
                draw_shield_simple(equipped.left_hand, facing_dir, x, y);
            }
            
            // Player
            draw_sprite_ext(sprite_index, _base_frame, x, y, image_xscale, image_yscale, 0, c_white, 1);
            if (equipped.right_hand == undefined) {
                draw_sprite_ext(spr_player_hands, _base_frame, x, y, image_xscale, image_yscale, 0, c_white, 1);
            }
            
            // Armor layers
            draw_armor_layers(_base_frame, _item_x, y);
            
            // Weapon in front
            if (equipped.right_hand != undefined) {
                draw_weapon_simple(equipped.right_hand, facing_dir, x, y);
            }
            break;
            
        case "right":
        case "down":
            // Player first
            draw_sprite_ext(sprite_index, _base_frame, x, y, image_xscale, image_yscale, 0, c_white, 1);
            if (equipped.right_hand == undefined) {
                draw_sprite_ext(spr_player_hands, _base_frame, x, y, image_xscale, image_yscale, 0, c_white, 1);
            }
            
            draw_armor_layers(_base_frame, _item_x, y);
            
            // Weapon
            if (equipped.right_hand != undefined) {
                draw_weapon_simple(equipped.right_hand, facing_dir, x, y);
            }
            
            // Shield on top
            if (equipped.left_hand != undefined && !is_two_handing()) {
                draw_shield_simple(equipped.left_hand, facing_dir, x, y);
            }
            break;
            
        case "left":
            // Player
            draw_sprite_ext(sprite_index, _base_frame, x, y, image_xscale, image_yscale, 0, c_white, 1);
            if (equipped.right_hand == undefined) {
                draw_sprite_ext(spr_player_hands, _base_frame, x, y, image_xscale, image_yscale, 0, c_white, 1);
            }
            
            draw_armor_layers(_base_frame, _item_x, y);
            
            // Weapon
            if (equipped.right_hand != undefined) {
                draw_weapon_simple(equipped.right_hand, facing_dir, x, y);
            }
            
            // Shield in front
            if (equipped.left_hand != undefined && !is_two_handing()) {
                draw_shield_simple(equipped.left_hand, facing_dir, x, y);
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