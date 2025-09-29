if (state != EnemyState.dead) {
if (alarm[1] < 0) {
	 hp -= other.damage;
	 image_blend = c_red;

	 // Apply weapon status effects
	 var attacker = other.creator;
	 if (attacker != noone) {
	     // Check right hand weapon
	     if (attacker.equipped.right_hand != undefined) {
	         var weapon_stats = attacker.equipped.right_hand.definition.stats;
	         if (variable_struct_exists(weapon_stats, "status_effect") &&
	             variable_struct_exists(weapon_stats, "status_chance")) {
	             if (random(1) < weapon_stats.status_chance) {
	                 apply_status_effect(weapon_stats.status_effect);
	                 show_debug_message("Weapon applied status effect");
	             }
	         }
	     }

	     // Check left hand weapon/tool (like torch)
	     if (attacker.equipped.left_hand != undefined) {
	         var left_item_stats = attacker.equipped.left_hand.definition.stats;
	         if (variable_struct_exists(left_item_stats, "status_effect") &&
	             variable_struct_exists(left_item_stats, "status_chance")) {
	             if (random(1) < left_item_stats.status_chance) {
	                 apply_status_effect(left_item_stats.status_effect);
	                 show_debug_message("Off-hand item applied status effect");
	             }
	         }
	     }
	 }

	 kb_x = sign(x - other.x);
	 kb_y = sign(y - other.y);

	 alarm[1] = 20;

	 audio_play_sound(snd_attack_sword, 1, false);
}
}