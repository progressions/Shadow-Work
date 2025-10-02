


// === DRAW GUI EVENT ===
if (is_open) {
	
	var _x = 40;
	var _y = 40;
	var _width = 600 * 2;
	var _height = 320 * 2;

    // Draw the nine-slice background
    draw_sprite_stretched(spr_box_frame, 0, _x, _y, _width, _height);
    
	var _player = obj_player;

	#region Character Panel
	
	// Health bar

	var _panel_char_x = _x + 40;
	var _panel_char_y = _y + 40;
	var _panel_scale = 1.5;
	var _panel_width = sprite_get_width(spr_character_panel) * _panel_scale;
	var _panel_height = sprite_get_height(spr_character_panel) * _panel_scale;

	draw_set_color(c_white);
	draw_text(_panel_char_x + 24, _panel_char_y + 24, "STATS");

	var _hp_x = _panel_char_x + 18;
	var _hp_y = _panel_char_y + 50;
	var _hp_w = sprite_get_width(spr_ui_healthbar) - 6;
	var _hp_h = sprite_get_height(spr_ui_healthbar) - 6;

	draw_set_color(c_white);
	ui_draw_health_bar(obj_player, _hp_x, _hp_y, _hp_w, _hp_h, health_bar_animation);

	// XP bar
	var _xp_bar_max_width = 236;
	var _xp_percentage = obj_player.xp / max(1, obj_player.xp_to_next);
	var _xp_bar_width = _xp_bar_max_width * _xp_percentage;
	var _xp_x = _panel_char_x + 18;
	var _xp_y = _hp_y + 30;

	draw_sprite_stretched(spr_ui_xp_bar, 0, _xp_x + 1, _xp_y + 1, _xp_bar_width, 5);
	draw_sprite(spr_ui_xp_bar_frame, 0, _xp_x, _xp_y);
	
	// Level

	draw_text(_xp_x, _xp_y + 20, "Level " + string(obj_player.level));
	
	// Tags
	draw_text(_xp_x, _xp_y + 40, "Tags: " + string(array_length(obj_player.tags)));
	
	// Traits
	var _perm_traits_count = 0;
	if (is_struct(obj_player.permanent_traits)) {
		var _perm_keys = variable_struct_get_names(obj_player.permanent_traits);
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

	// Draw yellow highlight for selected loadout hand if on loadout tab
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

	// Draw yellow highlight for selected loadout hand if on loadout tab
	if (current_tab == InventoryTab.loadout && loadout_selected_loadout == "ranged") {
		var _highlight_x = (loadout_selected_hand == "left") ? _left_x : _right_x;
		var _highlight_y = _ranged_y - 64;
		draw_set_color(c_yellow);
		draw_rectangle(_highlight_x - 18, _highlight_y - 18, _highlight_x + 18, _highlight_y + 18, true);
		draw_set_color(c_white);
	}

	draw_hand_item(_ranged_left, _left_x, _ranged_y);
	draw_hand_item(_ranged_right, _right_x, _ranged_y);
	
	#endregion Character Panel
	
	#region Paper Doll
	// paper doll
	// draw_sprite_ext(spr_paper_doll, 0, _x + 300, _y + 40, 1.5, 1.5, 0, c_white, 1);

	var _armor_scale = 6;

	var _paper_doll_x = _x + 300;
	var _paper_doll_y = _y + 40;

	var _head_x = _paper_doll_x + 90;
	var _head_y = _paper_doll_y + 160;
	var _torso_x = _paper_doll_x + 90;
	var _torso_y = _paper_doll_y + 250;
	var _leg_x = _paper_doll_x + 90;
	var _leg_y = _paper_doll_y + 350;

	// Draw yellow highlight for selected paper doll slot if on paper doll tab
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
		var _frame = _player.equipped.head.definition.world_sprite_frame;
		draw_sprite_ext(spr_items, _frame, _head_x, _head_y, _armor_scale, _armor_scale, 0, c_white, 1);
	}
	if (_player.equipped.torso != undefined) {
		var _frame = _player.equipped.torso.definition.world_sprite_frame;
		draw_sprite_ext(spr_items, _frame, _torso_x, _torso_y, _armor_scale, _armor_scale, 0, c_white, 1);
	}
	if (_player.equipped.legs != undefined) {
		var _frame = _player.equipped.legs.definition.world_sprite_frame;
		draw_sprite_ext(spr_items, _frame, _leg_x, _leg_y, _armor_scale, _armor_scale, 0, c_white, 1);
	}

	#endregion Paper Doll
	
	#region Inventory Grid
	// inventory grid
	// draw_rectangle(_x + 260, _y + 40, _x + 900, _y + 540, true);
	
	// inventory slots - 4x4 grid
	var _slot_scale = 2;
	var _slot_width = sprite_get_width(spr_inventory_slot) * _slot_scale;
	var _slot_height = sprite_get_height(spr_inventory_slot) * _slot_scale;
	var _slot_padding = 32;
	var _grid_start_x = _x + 520;
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

			// Draw selection cursor on selected slot (only when inventory tab is active)
			if (_is_selected && current_tab == InventoryTab.inventory) {
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
	
		// Info section
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

    // Arrows
	var _arrow_text = "Arrows: " + string(obj_player.arrow_count) + "/" + string(obj_player.arrow_max);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_text(_info_x, _info_y + 92, _arrow_text);

	#endregion Inventory Grid

	#region Companion Panel

	// companion panel
	var _comp_panel_x = _x + 940;
	var _comp_panel_y = _y + 40;
	// draw_sprite_ext(spr_companions_panel, 0, _comp_panel_x, _comp_panel_y, 1.5, 1.5, 0, c_white, 1);

	var _comp_slot_x = _comp_panel_x + 36;
	var _comp_slot_y = _comp_panel_y + 60;
	var _comp_slot_spacing = 72;

	// Get recruited companions
	var _recruited_companions = get_active_companions();

	for (var _i = 0; _i < 3; _i++) {
		draw_sprite_ext(spr_inventory_slot, 0, _comp_slot_x, _comp_slot_y + (_i * _comp_slot_spacing), 1, 1, 0, c_white, 0.5);

		// Show companion name if recruited, otherwise show empty slot
		var _display_name = "Empty";
		if (_i < array_length(_recruited_companions)) {
			var _companion = _recruited_companions[_i];
			_display_name = _companion.companion_name;
		}

		draw_text(_comp_slot_x + 40, _comp_slot_y + (_i * _comp_slot_spacing) + 12, _display_name);
	}

	#endregion Companion Panel
}
