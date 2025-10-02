function inventory_draw_companion_panel(_origin_x, _origin_y) {
	var _comp_panel_x = _origin_x;
	var _comp_panel_y = _origin_y;

	var _comp_slot_x = _comp_panel_x + 36;
	var _comp_slot_y = _comp_panel_y + 60;
	var _comp_slot_spacing = 72;

	var _recruited_companions = get_active_companions();

	for (var _i = 0; _i < 3; _i++) {
		draw_sprite_ext(spr_inventory_slot, 0, _comp_slot_x, _comp_slot_y + (_i * _comp_slot_spacing), 1, 1, 0, c_white, 0.5);

		var _display_name = "Empty";
		if (_i < array_length(_recruited_companions)) {
			var _companion = _recruited_companions[_i];
			_display_name = _companion.companion_name;
		}

		draw_text(_comp_slot_x + 40, _comp_slot_y + (_i * _comp_slot_spacing) + 12, _display_name);
	}
}
