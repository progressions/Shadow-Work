function inventory_draw_character_panel(_origin_x, _origin_y, _player, _panel_scale = 1.5) {
	var _panel_char_x = _origin_x;
	var _panel_char_y = _origin_y;
	var _panel_width = sprite_get_width(spr_character_panel) * _panel_scale;
	var _panel_height = sprite_get_height(spr_character_panel) * _panel_scale;

	draw_set_color(c_white);
	draw_text(_panel_char_x + 24, _panel_char_y + 24, "STATS");

	var _hp_x = _panel_char_x + 18;
	var _hp_y = _panel_char_y + 50;
	var _hp_w = sprite_get_width(spr_ui_healthbar) - 6;
	var _hp_h = sprite_get_height(spr_ui_healthbar) - 6;

	draw_set_color(c_white);
	ui_draw_health_bar(_player, _hp_x, _hp_y, _hp_w, _hp_h, health_bar_animation);

	var _xp_bar_max_width = 236;
	var _xp_percentage = _player.xp / max(1, _player.xp_to_next);
	var _xp_bar_width = _xp_bar_max_width * _xp_percentage;
	var _xp_x = _panel_char_x + 18;
	var _xp_y = _hp_y + 30;

	draw_sprite_stretched(spr_ui_xp_bar, 0, _xp_x + 1, _xp_y + 1, _xp_bar_width, 5);
	draw_sprite(spr_ui_xp_bar_frame, 0, _xp_x, _xp_y);

	draw_text(_xp_x, _xp_y + 20, "Level " + string(_player.level));
	draw_text(_xp_x, _xp_y + 40, "Tags: " + string(array_length(_player.tags)));

	var _perm_traits_count = 0;
	if (is_struct(_player.permanent_traits)) {
		var _perm_keys = variable_struct_get_names(_player.permanent_traits);
		_perm_traits_count = array_length(_perm_keys);
	}

	draw_text(_xp_x, _xp_y + 60, "Traits: " + string(_perm_traits_count));

	var _loadouts = is_struct(_player.loadouts) ? _player.loadouts : undefined;
	var _melee_right = (is_struct(_loadouts) && is_struct(_loadouts.melee)) ? _loadouts.melee.right_hand : undefined;
	var _melee_left = (is_struct(_loadouts) && is_struct(_loadouts.melee)) ? _loadouts.melee.left_hand : undefined;
	var _ranged_right = (is_struct(_loadouts) && is_struct(_loadouts.ranged)) ? _loadouts.ranged.right_hand : undefined;
	var _ranged_left = (is_struct(_loadouts) && is_struct(_loadouts.ranged)) ? _loadouts.ranged.left_hand : undefined;

	var draw_hand_item = function(_item, _draw_x, _draw_y) {
		if (_item == undefined) return;
		var _frame = _item.definition.world_sprite_frame;
		draw_sprite_ext(spr_items, _frame, _draw_x, _draw_y, 4, 4, 0, c_white, 1);
	};

	var _loadout_label_x = _xp_x;
	var _melee_y = _xp_y + 200;
	var _ranged_y = _melee_y + 80;
	var _left_x = _xp_x + 40;
	var _right_x = _xp_x + 140;

	var _active_loadout = (_loadouts != undefined) ? _loadouts.active : "melee";

	var _melee_label = "Melee Loadout";
	if (_active_loadout == "melee") {
		_melee_label += " [ACTIVE]";
	}
	draw_text(_loadout_label_x, _melee_y - 20, _melee_label);

	if (current_tab == InventoryTab.loadout && loadout_selected_loadout == "melee") {
		var _highlight_x = (loadout_selected_hand == "left") ? _left_x : _right_x;
		var _highlight_y = _melee_y - 64;
		draw_set_color(c_yellow);
		draw_rectangle(_highlight_x - 18, _highlight_y - 18, _highlight_x + 18, _highlight_y + 18, true);
		draw_set_color(c_white);
	}

	draw_hand_item(_melee_left, _left_x, _melee_y);
	draw_hand_item(_melee_right, _right_x, _melee_y);

	var _ranged_label = "Ranged Loadout";
	if (_active_loadout == "ranged") {
		_ranged_label += " [ACTIVE]";
	}
	draw_text(_loadout_label_x, _ranged_y - 20, _ranged_label);

	if (current_tab == InventoryTab.loadout && loadout_selected_loadout == "ranged") {
		var _highlight_x = (loadout_selected_hand == "left") ? _left_x : _right_x;
		var _highlight_y = _ranged_y - 64;
		draw_set_color(c_yellow);
		draw_rectangle(_highlight_x - 18, _highlight_y - 18, _highlight_x + 18, _highlight_y + 18, true);
		draw_set_color(c_white);
	}

	draw_hand_item(_ranged_left, _left_x, _ranged_y);
	draw_hand_item(_ranged_right, _right_x, _ranged_y);
}
