// Draw floating text using Scribble
var _draw_x = x;
var _draw_y = y - y_offset;

// Use custom font if specified, otherwise use default
var _font_name = "fnt_quest"; // Default font
if (draw_font != -1 && font_exists(draw_font)) {
    _font_name = font_get_name(draw_font);
}

// Store current alpha for restoration
var _prev_alpha = draw_get_alpha();

// Draw text with Scribble (color passed directly to starting_format)
scribble(text)
    .starting_format(_font_name, text_color)
    .align(fa_center, fa_middle)
    .scale(text_scale)
	.sdf_outline(c_black, 2)
    .draw(_draw_x, _draw_y);
