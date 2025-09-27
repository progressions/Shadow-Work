if (alarm[0] < 0) {
	hp -= other.damage;
	
	alarm[0] = 60;
	image_blend = c_red;
	show_debug_message("You got hit");
	audio_play_sound(snd_attack_sword, 1, false);
	
	if (hp <= 0) {
		show_message("You died");
		game_end();
	}
}