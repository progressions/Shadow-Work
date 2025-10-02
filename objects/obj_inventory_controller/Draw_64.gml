


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
	
		var _format_title = function(_value) {
			var _text = string(_value);
			_text = string_replace_all(_text, "_", " ");
			var _result = "";
			var _capitalize = true;
			for (var _i = 1; _i <= string_length(_text); _i++) {
				var _ch = string_char_at(_text, _i);
				if (_capitalize && _ch != " ") {
					_result += string_upper(_ch);
					_capitalize = false;
				} else {
					_result += string_lower(_ch);
				}
				if (_ch == " ") _capitalize = true;
			}
			return _result;
		};

		var _get_stat = function(_stats, _key) {
			if (!is_struct(_stats)) return undefined;
			if (!variable_struct_exists(_stats, _key)) return undefined;
			return _stats[$ _key];
		};

		var _join_parts = function(_arr) {
			if (!is_array(_arr) || array_length(_arr) <= 0) return "";
			var _joined = string(_arr[0]);
			for (var _ji = 1; _ji < array_length(_arr); _ji++) {
				_joined += " | " + string(_arr[_ji]);
			}
			return _joined;
		};

		var _item_type_to_text = function(_type) {
			switch (_type) {
				case ItemType.weapon: return "Weapon";
				case ItemType.armor: return "Armor";
				case ItemType.consumable: return "Consumable";
				case ItemType.tool: return "Tool";
				case ItemType.ammo: return "Ammo";
			}
			return "Item";
		};

		var _handedness_to_text = function(_handedness) {
			switch (_handedness) {
				case WeaponHandedness.two_handed: return "Two-Handed";
				case WeaponHandedness.versatile: return "Versatile";
				case WeaponHandedness.one_handed:
			default:
				return "One-Handed";
			}
		};

		var _damage_type_to_text = function(_damage_type) {
			switch (_damage_type) {
				case DamageType.physical: return "Physical";
				case DamageType.magical: return "Magical";
				case DamageType.fire: return "Fire";
				case DamageType.ice: return "Ice";
				case DamageType.lightning: return "Lightning";
				case DamageType.poison: return "Poison";
				case DamageType.disease: return "Disease";
				case DamageType.holy: return "Holy";
				case DamageType.unholy: return "Unholy";
			}
			return "Damage";
		};

		var _status_effect_to_text = function(_effect) {
			switch (_effect) {
				case StatusEffectType.burning: return "Burning";
				case StatusEffectType.wet: return "Wet";
				case StatusEffectType.empowered: return "Empowered";
				case StatusEffectType.weakened: return "Weakened";
				case StatusEffectType.swift: return "Swift";
				case StatusEffectType.slowed: return "Slowed";
			}
			return "Status";
		};

		var _to_number_text = function(_value) {
			if (_value == undefined) return "";
			var _rounded = round(_value);
			if (abs(_value - _rounded) < 0.01) {
				return string(_rounded);
			}
			return string(real(floor(_value * 100 + 0.5) / 100));
		};

		var _percent_text = function(_value) {
			if (_value == undefined) return "";
			return string(round(_value * 100)) + "%";
		};

		var _wrap_text = function(_text, _max_chars) {
			if (_max_chars <= 0) return _text;
			var _result = "";
			var _line_length = 0;
			var _word = "";
			var _len = string_length(_text);
			for (var _i = 1; _i <= _len; _i++) {
				var _ch = string_char_at(_text, _i);
				if (_ch == " " || _ch == "\t") {
					if (string_length(_word) > 0) {
						var _word_len = string_length(_word);
						if (_line_length == 0) {
							_result += _word;
							_line_length = _word_len;
						} else if (_line_length + 1 + _word_len <= _max_chars) {
							_result += " " + _word;
							_line_length += 1 + _word_len;
						} else {
							_result += "\n" + _word;
							_line_length = _word_len;
						}
						_word = "";
					}
					continue;
				}
				if (_ch == "\n") {
					if (string_length(_word) > 0) {
						var _word_len = string_length(_word);
						if (_line_length == 0) {
							_result += _word;
						} else if (_line_length + 1 + _word_len <= _max_chars) {
							_result += " " + _word;
						} else {
							_result += "\n" + _word;
						}
						_line_length = string_length(_word);
						_word = "";
					}
					_result += "\n";
					_line_length = 0;
					continue;
				}
				_word += _ch;
			}
			if (string_length(_word) > 0) {
				var _word_len = string_length(_word);
				if (_line_length == 0) {
					_result += _word;
				} else if (_line_length + 1 + _word_len <= _max_chars) {
					_result += " " + _word;
				} else {
					_result += "\n" + _word;
				}
			}
			return _result;
		};
	
		var _selected_entry = undefined;
		var _slot_label = "";
		
		if (_player != undefined && _player != noone) {
			switch (current_tab) {
				case InventoryTab.inventory:
					_slot_label = "Inventory Slot " + string(selected_slot + 1);
					if (is_array(_player.inventory) && selected_slot < array_length(_player.inventory)) {
						_selected_entry = _player.inventory[selected_slot];
					}
					break;

				case InventoryTab.paper_doll:
					_slot_label = _format_title(paper_doll_selected) + " Slot";
					if (is_struct(_player.equipped) && variable_struct_exists(_player.equipped, paper_doll_selected)) {
						_selected_entry = _player.equipped[$ paper_doll_selected];
					}
					break;

				case InventoryTab.loadout:
					_slot_label = _format_title(loadout_selected_loadout) + " " + _format_title(loadout_selected_hand) + " Hand";
					var _loadouts_struct = is_struct(_player.loadouts) ? _player.loadouts : undefined;
					if (_loadouts_struct != undefined && variable_struct_exists(_loadouts_struct, loadout_selected_loadout)) {
						var _active_loadout_struct = _loadouts_struct[$ loadout_selected_loadout];
						if (is_struct(_active_loadout_struct)) {
							var _hand_key = loadout_selected_hand + "_hand";
							if (variable_struct_exists(_active_loadout_struct, _hand_key)) {
								_selected_entry = _active_loadout_struct[$ _hand_key];
							}
						}
					}
					break;
			}
		}

		if (_slot_label == "") {
			_slot_label = "Inventory";
		}

		var _line1 = _slot_label;
		var _line2 = "Slot empty.";
		
		if (_selected_entry != undefined) {
			var _item_def = (_selected_entry != undefined) ? _selected_entry.definition : undefined;
			if (_item_def != undefined) {
				var _count = (_selected_entry.count != undefined) ? _selected_entry.count : 1;
				var _type_text = _item_type_to_text(_item_def.type);
				_line1 = _item_def.name;
				if (_count > 1) {
					_line1 += " x" + string(_count);
				}
				if (_type_text != "") {
					_line1 += " — " + _type_text;
				}

				var _stat_parts = [];
				var _stats = _item_def.stats;

				if (is_struct(_stats)) {
					switch (_item_def.type) {
						case ItemType.weapon:
							var _damage = _get_stat(_stats, "damage");
							if (_damage != undefined) array_push(_stat_parts, "DMG " + string(_damage));

							var _two_hand_damage = _get_stat(_stats, "two_handed_damage");
							if (_two_hand_damage != undefined) array_push(_stat_parts, "2H DMG " + string(_two_hand_damage));

							var _attack_speed = _get_stat(_stats, "attack_speed");
							if (_attack_speed != undefined) array_push(_stat_parts, "Rate " + _to_number_text(_attack_speed));

							var _range = _get_stat(_stats, "range");
							if (_range != undefined) array_push(_stat_parts, "Range " + string(_range));

							var _two_hand_range = _get_stat(_stats, "two_handed_range");
							if (_two_hand_range != undefined) array_push(_stat_parts, "2H Range " + string(_two_hand_range));

							var _armor_pen = _get_stat(_stats, "armor_penetration");
							if (_armor_pen != undefined) array_push(_stat_parts, "Armor Pen " + _percent_text(_armor_pen));

							var _magic_power = _get_stat(_stats, "magic_power");
							if (_magic_power != undefined) array_push(_stat_parts, "Magic +" + string(_magic_power));

							var _requires_ammo = _get_stat(_stats, "requires_ammo");
							if (_requires_ammo != undefined) array_push(_stat_parts, "Requires " + _format_title(_requires_ammo));

							var _damage_type = _get_stat(_stats, "damage_type");
							if (_damage_type != undefined) array_push(_stat_parts, _damage_type_to_text(_damage_type));

							if (_item_def.handedness != undefined) {
								array_push(_stat_parts, _handedness_to_text(_item_def.handedness));
							}
							break;

						case ItemType.armor:
							var _defense = _get_stat(_stats, "defense");
							if (_defense != undefined) array_push(_stat_parts, "DEF " + string(_defense));

							var _block = _get_stat(_stats, "block_chance");
							if (_block != undefined) array_push(_stat_parts, "Block " + _percent_text(_block));

							var _speed_mod = _get_stat(_stats, "speed_modifier");
							if (_speed_mod != undefined) array_push(_stat_parts, "Speed x" + _to_number_text(_speed_mod));

							var _traits = _get_stat(_stats, "trait_grants");
							if (is_array(_traits)) {
								for (var _ti = 0; _ti < array_length(_traits); _ti++) {
									var _trait_entry = _traits[_ti];
									if (is_struct(_trait_entry)) {
										var _trait_name = variable_struct_exists(_trait_entry, "trait") ? _trait_entry.trait : "";
										var _trait_stacks = variable_struct_exists(_trait_entry, "stacks") ? _trait_entry.stacks : 1;
										var _trait_text = "Trait " + _format_title(_trait_name);
										if (_trait_stacks != undefined) {
											_trait_text += " +" + string(_trait_stacks);
										}
										array_push(_stat_parts, _trait_text);
									}
								}
							}
							break;

						case ItemType.consumable:
							var _heal = _get_stat(_stats, "heal_amount");
							if (_heal != undefined) array_push(_stat_parts, "Heal " + string(_heal));

							var _stamina = _get_stat(_stats, "stamina_restore");
							if (_stamina != undefined) array_push(_stat_parts, "Stamina " + string(_stamina));

							var _mana = _get_stat(_stats, "mana_restore");
							if (_mana != undefined) array_push(_stat_parts, "Mana " + string(_mana));

							var _damage_buff = _get_stat(_stats, "damage_buff");
							if (_damage_buff != undefined) array_push(_stat_parts, "Damage +" + string(_damage_buff));

							var _duration = _get_stat(_stats, "duration");
							if (_duration != undefined) array_push(_stat_parts, "Duration " + string(_duration));

							var _stack_size = _get_stat(_stats, "stack_size");
							if (_stack_size != undefined) array_push(_stat_parts, "Stack " + string(_stack_size));
							break;

						case ItemType.tool:
							var _light = _get_stat(_stats, "light_radius");
							if (_light != undefined) array_push(_stat_parts, "Light " + string(_light));

							var _status_effects = _get_stat(_stats, "status_effects");
							if (is_array(_status_effects)) {
								for (var _si = 0; _si < array_length(_status_effects); _si++) {
									var _status_entry = _status_effects[_si];
									if (is_struct(_status_entry)) {
										var _status_name = variable_struct_exists(_status_entry, "effect") ? _status_effect_to_text(_status_entry.effect) : "Status";
										var _status_chance = variable_struct_exists(_status_entry, "chance") ? _status_entry.chance : undefined;
										var _status_text = "Applies " + _status_name;
										if (_status_chance != undefined) {
											_status_text += " (" + _percent_text(_status_chance) + ")";
										}
										array_push(_stat_parts, _status_text);
									}
								}
							}

							var _stack_tool = _get_stat(_stats, "stack_size");
							if (_stack_tool != undefined) array_push(_stat_parts, "Stack " + string(_stack_tool));
							break;

						case ItemType.ammo:
							var _ammo_stack = _get_stat(_stats, "stack_size");
							if (_ammo_stack != undefined) array_push(_stat_parts, "Stack " + string(_ammo_stack));
							array_push(_stat_parts, "Ammo");
							break;
					}

					var _wielder_effects = _get_stat(_stats, "wielder_effects");
					if (is_array(_wielder_effects)) {
						for (var _wi = 0; _wi < array_length(_wielder_effects); _wi++) {
							var _effect_entry = _wielder_effects[_wi];
							if (is_struct(_effect_entry)) {
								var _effect_name = variable_struct_exists(_effect_entry, "effect") ? _status_effect_to_text(_effect_entry.effect) : "Effect";
								array_push(_stat_parts, "Wielder: " + _effect_name);
							}
						}
					}

					var _requires_ammo_generic = _get_stat(_stats, "requires_ammo");
					if (_requires_ammo_generic != undefined && _item_def.type != ItemType.weapon) {
						array_push(_stat_parts, "Requires " + _format_title(_requires_ammo_generic));
					}
				}

				if (array_length(_stat_parts) <= 0) {
					_line2 = "No notable properties.";
				} else {
					_line2 = _join_parts(_stat_parts);
				}
			} else {
				_line2 = "Unknown item.";
			}
		}

		var _item_text = _wrap_text(_line1 + "\n" + _line2, 40);
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
