/// @description Draw interaction prompt with outline

// Store current draw settings
var _prev_halign = draw_get_halign();
var _prev_valign = draw_get_valign();
var _prev_color = draw_get_color();
var _prev_font = draw_get_font();

// Draw text with baked outline font
scribble(text)
	.starting_format("fnt_ui", text_color)
	.scale(text_scale)
	.align(fa_center, fa_bottom)
	.sdf_outline(c_black, 1)
	.sdf_shadow(c_black, 0.3, -2, 2, 0.1)
	.draw(x, y - 6);

// Restore previous draw settings
draw_set_font(_prev_font);
draw_set_halign(_prev_halign);
draw_set_valign(_prev_valign);
draw_set_color(_prev_color);
