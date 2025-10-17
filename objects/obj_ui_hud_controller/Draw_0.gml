draw_self();

// Draw animated health bar using the ui helper function
ui_draw_health_bar(obj_player, x + 10, y + 10, 234, 14, health_bar_animation);


// XP bar with dynamic width based on progress
var _xp_bar_max_width = 236;
var _xp_percentage = obj_player.xp / obj_player.xp_to_next;
var _xp_bar_width = _xp_bar_max_width * _xp_percentage;

// Draw XP bar background (empty)
// draw_sprite_stretched(spr_ui_xp_bar, 1, x + 9, y + 34, _xp_bar_max_width, 5);

// Draw XP bar fill (current XP)
draw_sprite_stretched(spr_ui_xp_bar, 0, x + 9, y + 34, _xp_bar_width, 5);

// Draw XP bar frame
draw_sprite(spr_ui_xp_bar_frame, 0, x + 8, y + 33);

if (obj_player.equipped.right_hand != undefined) {
	var _frame = obj_player.equipped.right_hand.definition.world_sprite_frame;
	draw_sprite_stretched(spr_items, _frame, x - 12, y + 50, 72, 72);
}


