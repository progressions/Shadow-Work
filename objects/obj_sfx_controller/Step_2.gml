
// Calculate final volume, considering enabled state
var _final_volume = global.audio_config.sfx_enabled
	? global.audio_config.sfx_volume * global.audio_config.master_volume
	: 0;

#region Play all queued sounds

for (i = 0; i < array_length(sounds_to_play); i++) {
	
	sound_data = sounds_to_play[i];
	
	if (sound_data.loop == false) {
		var _sound_instance = audio_play_sound(sound_data.sound, sound_data.priority, sound_data.loop);
		audio_sound_gain(_sound_instance, _final_volume, 0);

		array_delete(sounds_to_play, i, 1);
		i--;
	} else {
		// Check if this sound is already playing
		var _found = false;
		for (var j = 0; j < array_length(sounds_playing); j++) {
			if (sounds_playing[j].sound == sound_data.sound) {
				// Re-trigger: set target volume back to 1
				sounds_playing[j].target_volume = 1;
				_found = true;
				break;
			}
		}

		// If not found, start playing and add to sounds_playing
		if (!_found) {
			var _sound_instance = audio_play_sound(sound_data.sound, sound_data.priority, true);
			array_push(sounds_playing, {
				sound: sound_data.sound,
				instance: _sound_instance,
				current_volume: 0,
				target_volume: 1,
				fade_in_speed: sound_data.fade_in_speed,
				fade_out_speed: sound_data.fade_out_speed,
				priority: sound_data.priority
			});
		}

		// Remove from queue
		array_delete(sounds_to_play, i, 1);
		i--;
	}
}

#endregion Playing all sounds


#region Active looped sounds management

for (var i = 0; i < array_length(sounds_playing); i++) {
	var _loop_data = sounds_playing[i];

	// If SFX disabled, stop all looped sounds
	if (!global.audio_config.sfx_enabled) {
		if (audio_is_playing(_loop_data.instance)) {
			audio_stop_sound(_loop_data.instance);
		}
		array_delete(sounds_playing, i, 1);
		i--;
		continue;
	}

	// Update volume toward target
	if (_loop_data.current_volume < _loop_data.target_volume) {
		_loop_data.current_volume += _loop_data.fade_in_speed;
		if (_loop_data.current_volume > _loop_data.target_volume) {
			_loop_data.current_volume = _loop_data.target_volume;
		}
	} else if (_loop_data.current_volume > _loop_data.target_volume) {
		_loop_data.current_volume -= _loop_data.fade_out_speed;
		if (_loop_data.current_volume < _loop_data.target_volume) {
			_loop_data.current_volume = _loop_data.target_volume;
		}
	}

	// Apply volume
	if (audio_is_playing(_loop_data.instance)) {
		audio_sound_gain(_loop_data.instance, _loop_data.current_volume * _final_volume, 0);
	}

	// Remove if faded out completely
	if (_loop_data.target_volume <= 0 && _loop_data.current_volume <= 0) {
		audio_stop_sound(_loop_data.instance);
		array_delete(sounds_playing, i, 1);
		i--;
	}
}

#endregion Active looped sounds management
