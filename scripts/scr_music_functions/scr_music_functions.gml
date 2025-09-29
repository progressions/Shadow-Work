function set_song_ingame(_song, _fade_out_time = 0, _fade_in_time = 0) {
	with (obj_music_controller) {
		target_song_asset = _song;
		end_fade_out_time = _fade_out_time;
		start_fade_in_time = _fade_in_time;
	}
}