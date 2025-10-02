
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
	var _slot_size = 64;
	var _slot_padding = 32;
	var _grid_start_x = _x + 480;
	var _grid_start_y = _y + 80;

	// Get player reference
	var _player = instance_find(obj_player, 0);

	for (var i = 0; i < 16; i++) {
		var _col = i % 4;
		var _row = floor(i / 4);

		var _slot_x = _grid_start_x + (_col * (_slot_size + _slot_padding));
		var _slot_y = _grid_start_y + (_row * (_slot_size + _slot_padding));

		draw_sprite_ext(spr_inventory_slot, 0, _slot_x, _slot_y, 2, 2, 0, c_white, 1);

		// Draw item if it exists in player inventory
		if (_player != noone && i < array_length(_player.inventory) && _player.inventory[i] != undefined) {
			var _item = _player.inventory[i];
			var _item_scale = get_item_scale(_item.definition, "inventory_grid");

			// Draw item sprite centered in slot
			draw_sprite_ext(spr_items, _item.definition.world_sprite_frame,
						   _slot_x + (_slot_size),
						   _slot_y + (_slot_size),
						   _item_scale, _item_scale, 0, c_white, 1);

			// Draw stack count if > 1
			if (_item.count > 1) {
				draw_set_color(c_white);
				draw_set_halign(fa_right);
				draw_set_valign(fa_bottom);
				draw_text(_slot_x + (_slot_size * 2) - 4, _slot_y + (_slot_size * 2) - 4, string(_item.count));
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
			}
		}

		// Draw selection cursor on selected slot
		if (i == selected_slot) {
			draw_set_color(c_yellow);
			draw_rectangle(_slot_x - 2, _slot_y - 2, _slot_x + (_slot_size * 2) + 2, _slot_y + (_slot_size * 2) + 2, true);
			draw_rectangle(_slot_x - 3, _slot_y - 3, _slot_x + (_slot_size * 2) + 3, _slot_y + (_slot_size * 2) + 3, true);
			draw_set_color(c_white);
		}
	}

	
	// companion panel
	draw_sprite_ext(spr_companions_panel, 0, _x + 940, _y + 40, 1.5, 1.5, 0, c_white, 1);
}