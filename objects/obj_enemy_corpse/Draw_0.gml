// Draw shadow first
draw_sprite_ext(spr_shadow, 0, x, y + 2, 1, 0.5, 0, c_black, 0.3);

// Draw the corpse
draw_self();
