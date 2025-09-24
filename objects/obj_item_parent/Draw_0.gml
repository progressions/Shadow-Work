// Draw shadow first (so it appears under the item)
draw_sprite_ext(spr_shadow, image_index, x, base_y - 2, 1, 0.5, 0, c_black, 0.3);


// DRAW EVENT:
draw_self();
// Draw stack count if more than 1
if (count > 1) {
    draw_set_font(fnt_small);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(c_white);
    draw_text(x, y - 8, string(count));
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}