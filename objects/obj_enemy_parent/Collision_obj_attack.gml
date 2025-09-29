show_debug_message("COLLISION DETECTED: enemy hit by attack!");

if (state != EnemyState.dead) {
show_debug_message("Enemy state check passed, alarm[1] = " + string(alarm[1]));
if (alarm[1] < 0) {
	 var old_hp = hp;

	 // Apply trait-based damage modifiers
	 var _base_damage = other.damage;
	 var _damage_type = get_damage_type(other.creator);
	 var _modifier_key = _damage_type + "_damage_modifier";
	 var _damage_modifier = get_all_trait_modifiers(_modifier_key);
	 var _final_damage = _base_damage * _damage_modifier;

	 hp -= _final_damage;
	 image_blend = c_red;

	 show_debug_message("Damage calculation: base=" + string(_base_damage) +
	                    " type=" + _damage_type +
	                    " modifier=" + string(_damage_modifier) +
	                    " final=" + string(_final_damage));

	 show_debug_message("Enemy hit! HP: " + string(old_hp) + " -> " + string(hp));

	 // Check if enemy died and award XP
	 if (hp <= 0) {
	     var attacker = other.creator;
	     show_debug_message("Enemy died! Attacker: " + (attacker != noone ? object_get_name(attacker.object_index) : "none"));
	     show_debug_message("Checking if attacker == obj_player: attacker=" + string(attacker) + ", obj_player=" + string(obj_player));
	     show_debug_message("Attacker is instance? " + string(instance_exists(attacker)));

	     if (attacker != noone && attacker.object_index == obj_player) {
	         // Base XP reward (can be customized per enemy type)
	         var xp_reward = 5;

	         show_debug_message("Awarding " + string(xp_reward) + " XP to player");
	         show_debug_message("About to call gain_xp with attacker: " + object_get_name(attacker.object_index));

	         // Award XP to player
	         with (attacker) {
	             show_debug_message("Inside with block, calling gain_xp(" + string(xp_reward) + ")");
	             gain_xp(xp_reward);
	             show_debug_message("gain_xp call completed");
	         }

	         show_debug_message("Enemy killed! Player gained " + string(xp_reward) + " XP");
	     }

	     // Set enemy death state immediately
	     state = EnemyState.dead;
	     show_debug_message("Enemy state set to dead");
	 }

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

	 play_sfx(snd_attack_sword, 1, false);
}
}