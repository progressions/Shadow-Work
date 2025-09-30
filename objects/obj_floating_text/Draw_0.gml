// Draw floating text with outline for readability
var _draw_x = x;
var _draw_y = y - y_offset;

// Set font if specified
if (draw_font != -1 && font_exists(draw_font)) {
    draw_set_font(draw_font);
}

// Set alignment
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Draw black outline (4-way) with scaling
draw_set_alpha(alpha);
draw_set_color(c_black);
draw_text_transformed(_draw_x - 1, _draw_y, text, text_scale, text_scale, 0);
draw_text_transformed(_draw_x + 1, _draw_y, text, text_scale, text_scale, 0);
draw_text_transformed(_draw_x, _draw_y - 1, text, text_scale, text_scale, 0);
draw_text_transformed(_draw_x, _draw_y + 1, text, text_scale, text_scale, 0);

// Draw main text with scaling
draw_set_color(text_color);
draw_text_transformed(_draw_x, _draw_y, text, text_scale, text_scale, 0);

// Reset draw settings
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
