if (keyboard_check_pressed(ord("M"))) {
	global.audio_config.sfx_enabled = !global.audio_config.sfx_enabled;
	global.audio_config.music_enabled = !global.audio_config.music_enabled;
}