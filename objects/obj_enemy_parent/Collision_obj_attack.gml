if (state != EnemyState.dead) {
if (alarm[1] < 0) {
	 hp -= other.damage;
	 image_blend = c_red;
	 
	 kb_x = sign(x - other.x);
	 kb_y = sign(y - other.y);
	 
	 alarm[1] = 20;
	 
	 audio_play_sound(snd_attack_sword, 1, false);
}
}