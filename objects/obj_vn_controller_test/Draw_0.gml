draw_set_font(fnt_arial);
draw_set_valign(fa_middle);

var _margin_text = 128;
var _margin_char = 200;

if (IsChatterbox(chatterbox) && text != undefined) {
	var _me = ChatterboxGetContentSpeaker(chatterbox, 0) == "Me";
	draw_sprite_ext(spr_vn_canopy_1, 0, _margin_char, room_height, size[_me], size[_me], 0, color[_me], 1);

	var _yy = room_height - (_margin_text / 2);
	
	draw_rectangle_center(room_width / 2, _yy, room_width, _margin_text, false , c_black, 0.5);
	draw_set_halign(_me ? fa_left : fa_right);
	var _xx = _me ? _margin_text : room_width - _margin_text;
	
	draw_text(_xx, _yy, text);
	
	if (ChatterboxGetOptionCount(chatterbox)) {
		draw_set_halign(fa_center);
		var _width = 400;
		var _height = 64;
		
		for (var i = 0; i < ChatterboxGetOptionCount(chatterbox); i++) {
			if (ChatterboxGetOptionConditionBool(chatterbox, i)) {
				_xx = room_width / 2;
				_yy = (room_height / 6) * (i + 2);
				
				draw_rectangle_center(_xx, _yy, _width, _height, false, c_black, 0.5);
				
				var _icon = "";
				if (option_index == i) _icon = "> ";
				var _option = ChatterboxGetOption(chatterbox, i);
				
				
				draw_text(_xx, _yy, _icon + _option);
			}
		}
	}
}