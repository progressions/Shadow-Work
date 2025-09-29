draw_self();

// Draw animated health bar using the ui helper function
ui_draw_health_bar(obj_player, x + 10, y + 10, 234, 14, health_bar_animation);

draw_sprite_stretched(spr_ui_xp_bar, 0, x + 9, y + 34, 236, 5);
draw_sprite(spr_ui_xp_bar_frame, 0, x + 8, y + 33);