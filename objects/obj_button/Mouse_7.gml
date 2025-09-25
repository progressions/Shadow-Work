switch(button_id) {
	case ButtonType.Resume:
		global.game_paused = false;
		obj_pause_controller.update_pause();
		break;
	case ButtonType.Settings:
		break;
	case ButtonType.Quit:
		game_end();
		break;
}