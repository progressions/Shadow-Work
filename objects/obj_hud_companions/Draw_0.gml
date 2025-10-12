
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

	var _row_height = max(_badge_height, _label.get_height()) + 4;
	_current_y += _row_height;
}
