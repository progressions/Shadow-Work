function inventory_draw_paper_doll(_origin_x, _origin_y, _player, _armor_scale = 6) {
	var _paper_doll_x = _origin_x;
	var _paper_doll_y = _origin_y;

	var _head_x = _paper_doll_x + 90;
	var _head_y = _paper_doll_y + 160;
	var _torso_x = _paper_doll_x + 90;
	var _torso_y = _paper_doll_y + 250;
	var _leg_x = _paper_doll_x + 90;
	var _leg_y = _paper_doll_y + 350;

	if (current_tab == InventoryTab.paper_doll) {
		var _highlight_y = _head_y - 60;
		if (paper_doll_selected == "torso") _highlight_y = _torso_y - 60;
		else if (paper_doll_selected == "legs") _highlight_y = _leg_y - 60;
		_highlight_y -= 32;

		draw_set_color(c_yellow);
		draw_rectangle(_paper_doll_x + 42, _highlight_y - 48, _paper_doll_x + 138, _highlight_y + 48, true);
		draw_set_color(c_white);
	}

	if (_player.equipped.head != undefined) {
		var _frame_head = _player.equipped.head.definition.world_sprite_frame;
		draw_sprite_ext(spr_items, _frame_head, _head_x, _head_y, _armor_scale, _armor_scale, 0, c_white, 1);
	}
	if (_player.equipped.torso != undefined) {
		var _frame_torso = _player.equipped.torso.definition.world_sprite_frame;
		draw_sprite_ext(spr_items, _frame_torso, _torso_x, _torso_y, _armor_scale, _armor_scale, 0, c_white, 1);
	}
	if (_player.equipped.legs != undefined) {
		var _frame_legs = _player.equipped.legs.definition.world_sprite_frame;
		draw_sprite_ext(spr_items, _frame_legs, _leg_x, _leg_y, _armor_scale, _armor_scale, 0, c_white, 1);
	}
}
