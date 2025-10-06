// Draw shadow first (so it appears under the item)
draw_sprite_ext(spr_shadow, image_index, x, base_y - 2, 1, 0.5, 0, c_black, 0.3);


// DRAW EVENT:
draw_self();