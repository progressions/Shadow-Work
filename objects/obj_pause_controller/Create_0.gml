global.game_paused = false;

pause_layer = "PauseLayer";

update_pause = function() {
	if (global.game_paused) {
		layer_set_visible(pause_layer, true);
	} else {
		layer_set_visible(pause_layer, false);
	}
}

update_pause();