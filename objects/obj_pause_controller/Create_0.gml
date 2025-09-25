global.game_paused = false;
layer_name = "PauseLayer";

update_pause = function() {
	if (global.game_paused) {
		layer_set_visible(layer_name, true);
		
		with (obj_player) {
			paused_frame = image_index;
		}
	} else {
		layer_set_visible(layer_name, false);
	}
}

update_pause();