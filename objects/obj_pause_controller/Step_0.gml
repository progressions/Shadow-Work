if (keyboard_check_pressed(vk_escape)) {
	show_debug_message("WTF");
	global.game_paused = !global.game_paused;
	update_pause();
}

