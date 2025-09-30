
// Calculate final volume, considering enabled state
var _final_volume = global.audio_config.music_enabled
	? global.audio_config.music_volume * global.audio_config.master_volume
	: 0;


if (song_asset != target_song_asset) {
	
	if (audio_is_playing(song_instance)) {
		array_push(fade_out_instances, song_instance);
		array_push(fade_out_instance_volume, fade_in_instance_volume);
		array_push(fade_out_instance_time, end_fade_out_time);
		
		song_instance = noone;
		song_asset = noone;
	}
	
	if (array_length(fade_out_instances) == 0) {
		
		if (audio_exists(target_song_asset)) {
			song_instance = audio_play_sound(target_song_asset, 4, true);
	
			// start the song's volume at 0
			audio_sound_gain(song_instance, 0, 0);
			fade_in_instance_volume = 0;
		}
	
		song_asset = target_song_asset;
	
	}
	
}

// Volume control

	if (audio_is_playing(song_instance)) {
		if (start_fade_in_time > 0) {
			if (fade_in_instance_volume < 1) { fade_in_instance_volume += 1/start_fade_in_time; };
		} else {
			fade_in_instance_volume = 1;
		}
	
		audio_sound_gain(song_instance, fade_in_instance_volume * _final_volume, 0);
	}
	
	for (var i = 0; i < array_length(fade_out_instances); i++) {
		if (fade_out_instance_time[i] > 0) {
			if (fade_out_instance_volume[i] > 0) { fade_out_instance_volume[i] -= 1/fade_out_instance_time[i]; }
		} else {
			fade_out_instance_volume[i] = 0;
		}
		
		audio_sound_gain(fade_out_instances[i], fade_out_instance_volume[i] * _final_volume, 0);
		
		if (fade_out_instance_volume[i] <= 0) {
			if (audio_is_playing(fade_out_instances[i])) { audio_stop_sound(fade_out_instances[i]); }
		}
		
		array_delete(fade_out_instances, i, 1);
		array_delete(fade_out_instance_volume, i, 1);
		array_delete(fade_out_instance_time, i, 1);
		
		i--;
	}
