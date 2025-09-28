switch(button_id) {
	case ButtonType.resume:
		global.game_paused = false;
		obj_pause_controller.update_pause();
		break;
	case ButtonType.settings:
		break;
	case ButtonType.quit:
		game_end();
		break;
}