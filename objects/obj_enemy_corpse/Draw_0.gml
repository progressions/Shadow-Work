// Draw shadow first (fade with corpse)
var _shadow_alpha = 0.3 * image_alpha;
draw_sprite_ext(spr_shadow, 0, x, y + 2, 1, 0.5, 0, c_black, _shadow_alpha);

// Draw the corpse
draw_self();
