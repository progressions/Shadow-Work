
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

	for (var i = 0; i < 16; i++) {
		var _col = i % 4;
		var _row = floor(i / 4);

		var _slot_x = _grid_start_x + (_col * (_slot_size + _slot_padding));
		var _slot_y = _grid_start_y + (_row * (_slot_size + _slot_padding));

		draw_sprite_ext(spr_inventory_slot, 0, _slot_x, _slot_y, 2, 2, 0, c_white, 1);
	}

	
	// companion panel
	draw_sprite_ext(spr_companions_panel, 0, _x + 940, _y + 40, 1.5, 1.5, 0, c_white, 1);
}