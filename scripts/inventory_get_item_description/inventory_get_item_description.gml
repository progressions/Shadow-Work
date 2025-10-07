function inventory_get_item_description(
	_player,
	_current_tab,
	_selected_slot,
	_paper_doll_selected,
	_loadout_selected_loadout,
	_loadout_selected_hand,
	_wrap_length = 40
) {
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
		return get_status_effect_name(_effect);
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
		switch (_current_tab) {
			case InventoryTab.inventory:
				_slot_label = "Inventory Slot " + string(_selected_slot + 1);
				if (is_array(_player.inventory) && _selected_slot < array_length(_player.inventory)) {
					_selected_entry = _player.inventory[_selected_slot];
				}
				break;

			case InventoryTab.paper_doll:
				_slot_label = _format_title(_paper_doll_selected) + " Slot";
				if (is_struct(_player.equipped) && variable_struct_exists(_player.equipped, _paper_doll_selected)) {
					_selected_entry = _player.equipped[$ _paper_doll_selected];
				}
				break;

			case InventoryTab.loadout:
				_slot_label = _format_title(_loadout_selected_loadout) + " " + _format_title(_loadout_selected_hand) + " Hand";
				var _loadouts_struct = is_struct(_player.loadouts) ? _player.loadouts : undefined;
				if (_loadouts_struct != undefined && variable_struct_exists(_loadouts_struct, _loadout_selected_loadout)) {
					var _active_loadout_struct = _loadouts_struct[$ _loadout_selected_loadout];
					if (is_struct(_active_loadout_struct)) {
						var _hand_key = _loadout_selected_hand + "_hand";
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
				_line1 += " | " + _type_text;
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
                                    var _status_name = _status_effect_to_text(_status_entry);
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
                        var _effect_name = _status_effect_to_text(_effect_entry);
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

	return _wrap_text(_line1 + "\n" + _line2, _wrap_length);
}
