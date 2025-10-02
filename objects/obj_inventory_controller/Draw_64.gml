
// === DRAW GUI EVENT ===
if (is_open) {
	
	var _x = 40;
	var _y = 40;
	var _width = 600 * 2;
	var _height = 320 * 2;

    // Draw the nine-slice background
    draw_sprite_stretched(spr_box_frame, 0, _x, _y, _width, _height);
    
	var _player_exists = instance_exists(obj_player);
	var _player = _player_exists ? obj_player : noone;

	// character panel
	// draw_sprite_ext(spr_character_panel, 0, _x + 40, _y + 40, 1.5, 1.5, 0, c_white, 1);

	var _panel_char_x = _x + 40;
	var _panel_char_y = _y + 40;
	var _panel_scale = 1.5;
	var _panel_width = sprite_get_width(spr_character_panel) * _panel_scale;
	var _panel_height = sprite_get_height(spr_character_panel) * _panel_scale;

	if (_player_exists) {
		draw_set_color(c_white);
		draw_text(_panel_char_x + 24, _panel_char_y + 24, "STATS");

		var _hp_ratio = clamp(obj_player.hp / max(1, obj_player.hp_total), 0, 1);
		var _hp_bar_x = _panel_char_x + 24;
		var _hp_bar_y = _panel_char_y + 52;
		var _hp_bar_w = _panel_width - 48;
		draw_set_color(make_colour_rgb(60, 60, 60));
		draw_rectangle(_hp_bar_x, _hp_bar_y, _hp_bar_x + _hp_bar_w, _hp_bar_y + 12, false);
		draw_set_color(make_colour_rgb(200, 40, 40));
		draw_rectangle(_hp_bar_x, _hp_bar_y, _hp_bar_x + (_hp_bar_w * _hp_ratio), _hp_bar_y + 12, false);
		draw_set_color(c_white);
		draw_text(_hp_bar_x, _hp_bar_y - 16, "HP " + string(obj_player.hp) + "/" + string(obj_player.hp_total));

		var _xp_ratio = clamp(obj_player.xp / max(1, obj_player.xp_to_next), 0, 1);
		var _xp_bar_y = _hp_bar_y + 32;
		draw_set_color(make_colour_rgb(60, 60, 60));
		draw_rectangle(_hp_bar_x, _xp_bar_y, _hp_bar_x + _hp_bar_w, _xp_bar_y + 12, false);
		draw_set_color(make_colour_rgb(80, 120, 220));
		draw_rectangle(_hp_bar_x, _xp_bar_y, _hp_bar_x + (_hp_bar_w * _xp_ratio), _xp_bar_y + 12, false);
		draw_set_color(c_white);
		draw_text(_hp_bar_x, _xp_bar_y - 16, "XP " + string(obj_player.xp) + "/" + string(obj_player.xp_to_next));

		draw_text(_hp_bar_x, _xp_bar_y + 28, "Level " + string(obj_player.level));
		draw_text(_hp_bar_x, _xp_bar_y + 52, "Tags: " + string(array_length(obj_player.tags)));
		var _perm_traits_count = 0;
		if (is_struct(obj_player.permanent_traits)) {
			var _perm_keys = variable_struct_get_names(obj_player.permanent_traits);
			_perm_traits_count = array_length(_perm_keys);
		}
		draw_text(_hp_bar_x, _xp_bar_y + 76, "Traits: " + string(_perm_traits_count));
	}
	
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

	if (_player != noone) {
		var _arrow_text = "Arrows: " + string(obj_player.arrow_count) + "/" + string(obj_player.arrow_max);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_text(_grid_start_x, _grid_start_y + (_slot_height + _slot_padding) * 4 + 12, _arrow_text);
	}

	
	// companion panel
	var _comp_panel_x = _x + 940;
	var _comp_panel_y = _y + 40;
	// draw_sprite_ext(spr_companions_panel, 0, _comp_panel_x, _comp_panel_y, 1.5, 1.5, 0, c_white, 1);

	var _comp_slot_x = _comp_panel_x + 36;
	var _comp_slot_y = _comp_panel_y + 60;
	var _comp_slot_spacing = 72;

	for (var _i = 0; _i < 3; _i++) {
		draw_sprite_ext(spr_inventory_slot, 0, _comp_slot_x, _comp_slot_y + (_i * _comp_slot_spacing), 1, 1, 0, c_white, 0.5);
		draw_text(_comp_slot_x + 40, _comp_slot_y + (_i * _comp_slot_spacing) + 12, "Companion " + string(_i + 1));
	}
}
