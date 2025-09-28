
// Draw shadow first
draw_sprite_ext(spr_shadow, image_index, x, y + 2, 1, 0.5, 0, c_black, 0.3);

draw_self();

// Health bar above enemy
if (hp < hp_total && state != PlayerState.dead) { // Only show when damaged and alive
    var bar_x1 = x - 8;
    var bar_y1 = bbox_top - 8;
    var bar_x2 = x + 8;
    var bar_y2 = bbox_top - 4;

    draw_healthbar(bar_x1, bar_y1, bar_x2, bar_y2, (hp / hp_total) * 100, c_black, c_red, c_lime, 0, true, true);
}