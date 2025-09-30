
function play_sfx(_sound, _volume=1, _priority=8, _loop=false, _fade_in_speed=0, _fade_out_speed=0) {
	obj_sfx_controller.play_sfx(_sound, _volume, _priority, _loop, _fade_in_speed, _fade_out_speed);
}

function stop_looped_sfx(_sound) {
	obj_sfx_controller.stop_looped_sfx(_sound);
}
