/// @description Draw interaction prompt with outline

// Store current draw settings
var _prev_halign = draw_get_halign();
var _prev_valign = draw_get_valign();
var _prev_color = draw_get_color();
var _prev_font = draw_get_font();

// Set font and alignment
draw_set_font(font);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Draw black outline (4-way) with scaling
draw_set_color(c_black);
draw_text_transformed(x - 1, y, text, text_scale, text_scale, 0);
draw_text_transformed(x + 1, y, text, text_scale, text_scale, 0);
draw_text_transformed(x, y - 1, text, text_scale, text_scale, 0);
draw_text_transformed(x, y + 1, text, text_scale, text_scale, 0);

// Draw main text with scaling
draw_set_color(text_color);
draw_text_transformed(x, y, text, text_scale, text_scale, 0);

// Restore previous draw settings
draw_set_font(_prev_font);
draw_set_halign(_prev_halign);
draw_set_valign(_prev_valign);
draw_set_color(_prev_color);
