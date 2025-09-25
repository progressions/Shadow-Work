// Draw shadow first (so it appears under the item)
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
            // When facing up: shield behind, weapon in front
            
            // Shield behind
            if (equipped.left_hand != undefined && !is_two_handing()) {
                var _left_sprite = get_equipped_sprite(equipped.left_hand.definition.equipped_sprite_key);
                if (_left_sprite != -1) {
                    draw_sprite_ext(_left_sprite, _base_frame, _item_x, y, image_xscale, image_yscale, 0, c_white, 1);
                }
            }
            
            // Player
            draw_sprite_ext(sprite_index, _base_frame, x, y, image_xscale, image_yscale, 0, c_white, 1);
			    // Draw empty hands if no weapon
			if (equipped.right_hand == undefined) {
			    draw_sprite_ext(spr_player_hands, _base_frame, x, y, image_xscale, image_yscale, 0, c_white, 1);
			}

            
            // Armor layers
            draw_armor_layers(_base_frame, _item_x, y);
            
            // Weapon in front
            if (equipped.right_hand != undefined) {
                var _right_sprite = get_equipped_sprite(equipped.right_hand.definition.equipped_sprite_key);
                if (_right_sprite != -1) {
                    draw_sprite_ext(_right_sprite, _base_frame, _item_x, y, image_xscale, image_yscale, 0, c_white, 1);
                }
            }
            break;
			
        case "right":
        case "down":
            // When facing down: everything in front of player
            
            // Player first
            draw_sprite_ext(sprite_index, _base_frame, x, y, image_xscale, image_yscale, 0, c_white, 1);
			if (equipped.right_hand == undefined) {
			    draw_sprite_ext(spr_player_hands, _base_frame, x, y, image_xscale, image_yscale, 0, c_white, 1);
			}
            
            
            draw_armor_layers(_base_frame, _item_x, y);
            
            if (equipped.right_hand != undefined) {
                var _right_sprite = get_equipped_sprite(equipped.right_hand.definition.equipped_sprite_key);
                if (_right_sprite != -1) {
                    draw_sprite_ext(_right_sprite, _base_frame, x, y, image_xscale, image_yscale, 0, c_white, 1);
                }
            }
			
            // Then all equipment on top
            if (equipped.left_hand != undefined && !is_two_handing()) {
                var _left_sprite = get_equipped_sprite(equipped.left_hand.definition.equipped_sprite_key);
                if (_left_sprite != -1) {
                    draw_sprite_ext(_left_sprite, _base_frame, _item_x, y, image_xscale, image_yscale, 0, c_white, 1);
                }
            }
            break;
            
        case "left":
            // When facing left: shield in front on right side
            
            
            // Player
            draw_sprite_ext(sprite_index, _base_frame, x, y, image_xscale, image_yscale, 0, c_white, 1);
			if (equipped.right_hand == undefined) {
			    draw_sprite_ext(spr_player_hands, _base_frame, x, y, image_xscale, image_yscale, 0, c_white, 1);
			}
            
            // Armor and weapon on top
            draw_armor_layers(_base_frame, _item_x, y);
            
            if (equipped.right_hand != undefined) {
                var _right_sprite = get_equipped_sprite(equipped.right_hand.definition.equipped_sprite_key);
                if (_right_sprite != -1) {
                    draw_sprite_ext(_right_sprite, _base_frame, _item_x, y, image_xscale, image_yscale, 0, c_white, 1);
                }
            }
			
			
            // Shield in front
            if (equipped.left_hand != undefined && !is_two_handing()) {
                var _left_sprite = get_equipped_sprite(equipped.left_hand.definition.equipped_sprite_key);
                if (_left_sprite != -1) {
                    draw_sprite_ext(_left_sprite, _base_frame, _item_x, y, image_xscale, image_yscale, 0, c_white, 1);
                }
            }
            break;
            
    }
    
}

// Helper function to draw armor layers
function draw_armor_layers(_frame, _x, _y) {
    // Draw armor
    if (equipped.torso != undefined) {
        var _armor_sprite = get_equipped_sprite(equipped.torso.definition.equipped_sprite_key);
        if (_armor_sprite != -1) {
            draw_sprite_ext(_armor_sprite, _frame, _x, _y, image_xscale, image_yscale, 0, c_white, 1);
        }
    }
    
    // Draw helmet
    if (equipped.head != undefined) {
        var _helmet_sprite = get_equipped_sprite(equipped.head.definition.equipped_sprite_key);
        if (_helmet_sprite != -1) {
            draw_sprite_ext(_helmet_sprite, _frame, _x, _y, image_xscale, image_yscale, 0, c_white, 1);
        }
    }
    
    // Draw boots
    if (equipped.legs != undefined) {
        var _boots_sprite = get_equipped_sprite(equipped.legs.definition.equipped_sprite_key);
        if (_boots_sprite != -1) {
            draw_sprite_ext(_boots_sprite, _frame, _x, _y, image_xscale, image_yscale, 0, c_white, 1);
        }
    }
}


// ============================================
// ALTERNATIVE: Simpler version if you want to add sprites gradually
// ============================================

function get_equipped_sprite(_sprite_key) {
    // Build the sprite name dynamically
    var _sprite_name = "spr_wielded_" + _sprite_key;
    var _sprite = asset_get_index(_sprite_name);
    
    // Check if it exists
    if (sprite_exists(_sprite)) {
        return _sprite;
    }
    
    // Try "worn" prefix for armor
    _sprite_name = "spr_worn_" + _sprite_key;
    _sprite = asset_get_index(_sprite_name);
    
    if (sprite_exists(_sprite)) {
        return _sprite;
    }
    
    // Sprite doesn't exist yet
    return -1;
}

draw_player_with_equipment();


