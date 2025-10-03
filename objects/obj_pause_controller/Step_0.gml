// Don't allow ESC to toggle pause if VN interface is active
if (keyboard_check_pressed(vk_escape) && !global.vn_active) {
	global.game_paused = !global.game_paused;
	obj_inventory_controller.is_open = false;
	update_pause();
}

