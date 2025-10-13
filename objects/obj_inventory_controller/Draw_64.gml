


// === DRAW GUI EVENT ===
if (is_open) {
	var _x = 40;
	var _y = 40;
	var _width = 600 * 2;
	var _height = 320 * 2;

	// Draw the nine-slice background
	draw_sprite_stretched(spr_box_frame, 0, _x, _y, _width, _height);

	var _player = instance_find(obj_player, 0);
	if (_player == noone) return;

	#region Character Panel
	var _panel_char_x = _x + 40;
	var _panel_char_y = _y + 40;
	inventory_draw_character_panel(_panel_char_x, _panel_char_y, _player, 1.5);
	#endregion Character Panel

	#region Paper Doll
	var _paper_doll_x = _x + 300;
	var _paper_doll_y = _y + 40;
	inventory_draw_paper_doll(_paper_doll_x, _paper_doll_y, _player, 6);
	#endregion Paper Doll

	#region Inventory Grid
	var _grid_start_x = _x + 520;
	var _grid_start_y = _y + 80;
	inventory_draw_inventory_grid(_grid_start_x, _grid_start_y, _player);
	#endregion Inventory Grid

	#region Companion Panel
	var _comp_panel_x = _x + 940;
	var _comp_panel_y = _y + 40;
	inventory_draw_companion_panel(_comp_panel_x, _comp_panel_y);
	#endregion Companion Panel
}
