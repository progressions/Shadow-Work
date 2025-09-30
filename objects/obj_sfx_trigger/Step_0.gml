
if (place_meeting(x, y, obj_player)) {
	if (standing_on_it) return;
	standing_on_it = true;
	
	if (active == true) {
		image_blend = c_white;
		active = false;
	} else {
		image_blend = c_red;
		active = true;
	}
}
if (!place_meeting(x, y, obj_player)) {
	standing_on_it = false;
}

if (active == true) {
	obj_sfx_controller.play_sfx(snd_attack_miss, 1, 6, true, 10, 10);
} else {
	obj_sfx_controller.stop_looped_sfx(snd_attack_miss);
}