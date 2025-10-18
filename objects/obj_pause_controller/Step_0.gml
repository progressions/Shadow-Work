if (keyboard_check_pressed(vk_escape)) {
	global.game_paused = !global.game_paused;
	update_pause();
}