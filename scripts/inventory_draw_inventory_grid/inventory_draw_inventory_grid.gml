function inventory_draw_inventory_grid(_origin_x, _origin_y, _player) {
	var _slot_scale = 2;
	var _slot_width = sprite_get_width(spr_inventory_slot) * _slot_scale;
	var _slot_height = sprite_get_height(spr_inventory_slot) * _slot_scale;
	var _slot_padding = 32;
	var _grid_start_x = _origin_x;
	var _grid_start_y = _origin_y;
	var _slot_half_w = _slot_width * 0.5;
	var _slot_half_h = _slot_height * 0.5;

	var _item_sprite = spr_items;
	var _item_width = sprite_get_width(_item_sprite);
	var _item_height = sprite_get_height(_item_sprite);
	var _item_origin_x = sprite_get_xoffset(_item_sprite);
	var _item_origin_y = sprite_get_yoffset(_item_sprite);
	var _item_center_offset_x = (_item_width * 0.5) - _item_origin_x;
	var _item_center_offset_y = (_item_height * 0.5) - _item_origin_y;

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

		if (_player != noone && i < array_length(_player.inventory) && _player.inventory[i] != undefined) {
			_item = _player.inventory[i];
			_base_scale = get_item_scale(_item.definition, "inventory_grid");
			_draw_scale = _base_scale;
			if (_is_selected && current_tab == InventoryTab.inventory) {
				if (_base_scale >= 4) {
					_draw_scale = 5;
				} else if (_base_scale == 2) {
					_draw_scale = 3;
				}
			}
			_item_x = _slot_center_x - (_item_center_offset_x * _draw_scale);
			_item_y = _slot_center_y - (_item_center_offset_y * _draw_scale);
		}

		if (_is_selected && current_tab == InventoryTab.inventory) {
			draw_set_color(c_yellow);
			draw_rectangle(_slot_x - 2, _slot_y - 2, _slot_x + _slot_width + 2, _slot_y + _slot_height + 2, true);
			draw_rectangle(_slot_x - 3, _slot_y - 3, _slot_x + _slot_width + 3, _slot_y + _slot_height + 3, true);
			draw_set_color(c_white);
		}

		if (_item != undefined) {
			draw_sprite_ext(spr_items, _item.definition.world_sprite_frame,
					   _item_x, _item_y,
					   _draw_scale, _draw_scale, 0, c_white, 1);

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

	var _info_x = _grid_start_x;
	var _info_y = _grid_start_y + (_slot_height + _slot_padding) * 4;

	var _item_text = inventory_get_item_description(
		_player,
		current_tab,
		selected_slot,
		paper_doll_selected,
		loadout_selected_loadout,
		loadout_selected_hand,
		40
	);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_text(_info_x, _info_y, _item_text);

	var _arrow_text = "Arrows: " + string(_player.arrow_count) + "/" + string(_player.arrow_max);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_text(_info_x, _info_y + 92, _arrow_text);
}
