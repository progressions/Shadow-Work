global.game_paused = false;

pause_layer = "PauseLayer";

update_pause = function() {
	if (global.game_paused) {
		layer_set_visible(pause_layer, true);
		audio_group_set_gain(audiogroup_sfx_world, 0, 0);
	} else {
		layer_set_visible(pause_layer, false);
		audio_group_set_gain(audiogroup_sfx_world, 1, 0);
	}
}

update_pause();