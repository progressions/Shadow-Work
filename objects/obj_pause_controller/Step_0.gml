if (keyboard_check_pressed(vk_escape)) {
	global.game_paused = !global.game_paused;
	obj_inventory.is_open = false;
	update_pause();
}

