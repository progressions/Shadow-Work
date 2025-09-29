draw_self();

var _healthbar_width = 234;
// total_width is 234

var _percentage = obj_player.hp / obj_player.hp_total;
var _width = _healthbar_width * _percentage;

show_debug_message("health percentage " + string(_percentage));

var _healthbar_frame = 0;

if (_percentage < 0.33) { _healthbar_frame = 2; }
else if (_percentage < 0.66) { _healthbar_frame = 1; }


draw_sprite_stretched(spr_ui_healthbar_filler, 3, x+5, y+5, _healthbar_width, 14);
draw_sprite_stretched(spr_ui_healthbar_filler, _healthbar_frame, x+5, y+5, _width, 14);

draw_sprite(spr_ui_healthbar, 0, x+6, y+6);