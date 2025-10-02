
// === DRAW GUI EVENT ===
if (is_open) {
	
	var _x = 40;
	var _y = 40;
	var _width = 600 * 2;
	var _height = 320 * 2;

    // Draw the nine-slice background
    draw_sprite_stretched(spr_box_frame, 0, _x, _y, _width, _height);
    
	// character panel
	draw_sprite_ext(spr_character_panel, 0, _x + 40, _y + 40, 1.5, 1.5, 0, c_white, 1);
	
	// paper doll
	draw_sprite_ext(spr_paper_doll, 0, _x + 270, _y + 40, 1.5, 1.5, 0, c_white, 1);
	
	// inventory grid
	draw_rectangle(_x + 260, _y + 40, _x + 900, _y + 540, true);
	
	// inventory slots - 4x4 grid
	var _slot_scale = 2;
	var _slot_width = sprite_get_width(spr_inventory_slot) * _slot_scale;
	var _slot_height = sprite_get_height(spr_inventory_slot) * _slot_scale;
	var _slot_padding = 32;
	var _grid_start_x = _x + 480;
	var _grid_start_y = _y + 80;
	var _slot_half_w = _slot_width * 0.5;
	var _slot_half_h = _slot_height * 0.5;

	var _item_sprite = spr_items;
	var _item_width = sprite_get_width(_item_sprite);
	var _item_height = sprite_get_height(_item_sprite);
	var _item_origin_x = sprite_get_xoffset(_item_sprite);
	var _item_origin_y = sprite_get_yoffset(_item_sprite);
	var _item_center_offset_x = (_item_width * 0.5) - _item_origin_x;
	var _item_center_offset_y = (_item_height * 0.5) - _item_origin_y;

	// Get player reference
	var _player = instance_find(obj_player, 0);

	for (var i = 0; i < 16; i++) {
		var _col = i % 4;
		var _row = floor(i / 4);

		var _slot_x = _grid_start_x + (_col * (_slot_width + _slot_padding));
		var _slot_y = _grid_start_y + (_row * (_slot_height + _slot_padding));
		var _slot_center_x = _slot_x + _slot_half_w;
		var _slot_center_y = _slot_y + _slot_half_h;

			draw_sprite_ext(spr_inventory_slot, 0, _slot_x, _slot_y, _slot_scale, _slot_scale, 0, c_white, 1);
			var _is_selected = (i == selected_slot);
			var _item = undefined;
			var _base_scale = 0;
			var _draw_scale = 0;
			var _item_x = 0;
			var _item_y = 0;

			// Pre-calculate item info if present
			if (_player != noone && i < array_length(_player.inventory) && _player.inventory[i] != undefined) {
				_item = _player.inventory[i];
				_base_scale = get_item_scale(_item.definition, "inventory_grid");
				_draw_scale = _base_scale;
				if (_is_selected) {
					if (_base_scale >= 4) {
						_draw_scale = 5;
					} else if (_base_scale == 2) {
						_draw_scale = 3;
					}
				}
				_item_x = _slot_center_x - (_item_center_offset_x * _draw_scale);
				_item_y = _slot_center_y - (_item_center_offset_y * _draw_scale);
			}

			// Draw selection cursor on selected slot
			if (_is_selected) {
				draw_set_color(c_yellow);
				draw_rectangle(_slot_x - 2, _slot_y - 2, _slot_x + _slot_width + 2, _slot_y + _slot_height + 2, true);
				draw_rectangle(_slot_x - 3, _slot_y - 3, _slot_x + _slot_width + 3, _slot_y + _slot_height + 3, true);
				draw_set_color(c_white);
			}

			// Draw item if it exists in player inventory
			if (_item != undefined) {
				// Draw item sprite
				draw_sprite_ext(spr_items, _item.definition.world_sprite_frame,
							   _item_x, _item_y,
							   _draw_scale, _draw_scale, 0, c_white, 1);

				// Draw stack count if > 1
				if (_item.count > 1) {
					draw_set_color(c_white);
					draw_set_halign(fa_right);
					draw_set_valign(fa_bottom);
					draw_text(_slot_x + _slot_width - 4, _slot_y + _slot_height - 4, string(_item.count));
					draw_set_halign(fa_left);
					draw_set_valign(fa_top);
				}
			}
	}

	
	// companion panel
	draw_sprite_ext(spr_companions_panel, 0, _x + 940, _y + 40, 1.5, 1.5, 0, c_white, 1);
}
