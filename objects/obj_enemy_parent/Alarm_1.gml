image_blend = c_white;

// Check if enemy should die (only if not already dead)
if (hp <= 0 && state != EnemyState.dead) {
	show_debug_message("Enemy died in alarm (delayed death)");
	state = EnemyState.dead;
	// Note: XP should have been awarded in the collision event
	// instance_destroy();
}