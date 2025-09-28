image_blend = c_white;

if (hp <= 0) {
	show_debug_message("enemy died");
	state = PlayerState.dead;
	// instance_destroy();
}