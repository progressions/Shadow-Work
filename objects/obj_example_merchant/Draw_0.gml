// Draw the merchant
draw_self();

// Draw interaction prompt
if (instance_exists(obj_player)) {
    var _dist = point_distance(x, y, obj_player.x, obj_player.y);
    if (_dist < 64 && !global.vn_active) {
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_text(x, y - 48, "[SPACE] Talk to Merchant");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}
