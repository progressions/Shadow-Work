sounds_to_play = array_create(0);
sounds_playing = array_create(0);

audio_group_load(audiogroup_sfx_ui);
audio_group_load(audiogroup_sfx_world);

// Pitch variation settings
pitch_variation_enabled = true;  // Enable/disable pitch variation
pitch_variation_min = 0.85;      // Minimum pitch multiplier (5% lower)
pitch_variation_max = 1.25;      // Maximum pitch multiplier (5% higher)


function play_sfx(_sound, _volume=1, _priority=8, _loop=false, _fade_in_speed=0, _fade_out_speed=0) {
	array_push(obj_sfx_controller.sounds_to_play, { sound: _sound, volume: _volume, loop: _loop, priority: _priority, fade_in_speed: _fade_in_speed, fade_out_speed: _fade_out_speed });
}

function stop_looped_sfx(_sound) {
	// Find the sound in sounds_playing and set target_volume to 0 to trigger fade out
	for (var i = 0; i < array_length(obj_sfx_controller.sounds_playing); i++) {
		if (obj_sfx_controller.sounds_playing[i].sound == _sound) {
			obj_sfx_controller.sounds_playing[i].target_volume = 0;
			break;
		}
	}
}