
// spr_companion_badges: 0 -> Canopy, 1 -> Hola, 2 -> Yorna

var _companions = [];
with (obj_companion_parent) {
	if (is_recruited) {
		array_push(_companions, id);
	}
}

if (array_length(_companions) == 0) exit;

var _draw_ids = ["canopy", "hola", "yorna"];
var _label_scale = 0.25;
var _top_padding = 8;
var _badge_scale = 2;
var _base_badge_width = sprite_get_width(spr_companion_badges);
var _base_badge_height = sprite_get_height(spr_companion_badges);
var _badge_width = _base_badge_width * _badge_scale;
var _badge_height = _base_badge_height * _badge_scale;
var _badge_padding = 6;
var _current_y = y + _top_padding;

for (var _i = 0; _i < array_length(_draw_ids); _i++) {
	var _target_id = _draw_ids[_i];
	var _companion = noone;

	for (var _j = 0; _j < array_length(_companions); _j++) {
		var _candidate = _companions[_j];
		if (_candidate.companion_id == _target_id) {
			_companion = _candidate;
			break;
		}
	}

	if (_companion == noone) continue;

	var _badge_frame = 0;
	switch (_companion.companion_id) {
		case "hola": _badge_frame = 1; break;
		case "yorna": _badge_frame = 2; break;
		default: _badge_frame = 0; break;
	}

	var _label = scribble(_companion.companion_name)
		.starting_format("fnt_ui", c_white)
		.align(fa_right, fa_top)
		.scale(_label_scale);

	var _badge_x = x - _label.get_width() - _badge_padding - _badge_width;

	draw_sprite_ext(spr_companion_badges, _badge_frame, _badge_x, _current_y, _badge_scale, _badge_scale, 0, c_white, 1);
	var _affinity = _companion.affinity ?? 0;
	var _frame_total = max(1, sprite_get_number(spr_companion_badge_frames));
	var _frame_index = clamp(floor(max(0, _affinity)), 0, _frame_total - 1);
	draw_sprite_ext(spr_companion_badge_frames, _frame_index, _badge_x, _current_y, _badge_scale, _badge_scale, 0, c_white, 1);

	_label.draw(x, _current_y);

	// Check if companion has any active auras or triggers
	var _has_active_aura = false;
	if (variable_instance_exists(_companion, "auras")) {
		var _aura_names = variable_struct_get_names(_companion.auras);
		for (var _k = 0; _k < array_length(_aura_names); _k++) {
			var _aura_key = _aura_names[_k];
			var _aura = _companion.auras[$ _aura_key];
			if (is_struct(_aura) && variable_struct_exists(_aura, "active") && _aura.active) {
				_has_active_aura = true;
				break;
			}
		}
	}

	// Build status text (aura name + active triggers)
	var _status_text = "";

	// Show aura name if any auras are active
	if (_has_active_aura) {
		switch (_companion.companion_id) {
			case "canopy":
				_status_text = "Guardian Aura";
				break;
			case "hola":
				_status_text = "Wind Mastery";
				break;
			case "yorna":
				_status_text = "Warrior's Presence";
				break;
		}
	}

	// Check for active triggers
	if (variable_instance_exists(_companion, "triggers")) {
		var _trigger_names = variable_struct_get_names(_companion.triggers);
		for (var _t = 0; _t < array_length(_trigger_names); _t++) {
			var _trigger_key = _trigger_names[_t];
			var _trigger = _companion.triggers[$ _trigger_key];

			// Only show triggers that are active and have a duration (not passive triggers)
			if (is_struct(_trigger) && variable_struct_exists(_trigger, "active") && _trigger.active) {
				// Skip on_hit_strike (passive trigger that's always active)
				if (_trigger_key == "on_hit_strike") continue;

				// Convert trigger key to display name
				var _trigger_display = string_upper(string_char_at(_trigger_key, 1)) + string_copy(_trigger_key, 2, string_length(_trigger_key) - 1);
				_trigger_display = string_replace_all(_trigger_display, "_", " ");

				// Capitalize each word
				var _words = string_split(_trigger_display, " ");
				_trigger_display = "";
				for (var _w = 0; _w < array_length(_words); _w++) {
					var _word = _words[_w];
					if (string_length(_word) > 0) {
						_word = string_upper(string_char_at(_word, 1)) + string_copy(_word, 2, string_length(_word) - 1);
					}
					_trigger_display += _word;
					if (_w < array_length(_words) - 1) _trigger_display += " ";
				}

				// Add exclamation mark to make it stand out
				_trigger_display += "!";

				// Add to status text (on new line if aura is already showing)
				if (_status_text != "") _status_text += " - ";
				_status_text += _trigger_display;
			}
		}
	}

	// Draw status text
	if (_status_text != "") {
		scribble(_status_text)
			.starting_format("fnt_hud", c_white)
			.align(fa_right, fa_top)
			.scale(_label_scale)
			.wrap(300)  // Wrap text at 200 pixels width
			.draw(x, _current_y + 32);
	}

	var _row_height = max(_badge_height, _label.get_height()) + 50;
	_current_y += _row_height;
}
