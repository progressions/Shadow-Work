show_debug_message("COLLISION DETECTED: enemy hit by attack!");

if (state != EnemyState.dead) {
show_debug_message("Enemy state check passed, alarm[1] = " + string(alarm[1]));
if (alarm[1] < 0) {
	 var old_hp = hp;

	 // Get weapon damage type from attacker's equipped weapon
	 var _weapon_damage_type = DamageType.physical; // Default
	 if (other.creator != noone && instance_exists(other.creator)) {
	     if (other.creator.equipped.right_hand != undefined) {
	         var _weapon_stats = other.creator.equipped.right_hand.definition.stats;
	         if (variable_struct_exists(_weapon_stats, "damage_type")) {
	             _weapon_damage_type = _weapon_stats.damage_type;
	         }
	     }
	 }

	 // Apply trait-based damage modifiers
	 var _base_damage = other.damage;
	 var _damage_type_string = get_damage_type(other.creator); // For trait system
	 var _modifier_key = _damage_type_string + "_damage_modifier";
	 var _damage_modifier = get_all_trait_modifiers(_modifier_key);
	 var _after_traits = _base_damage * _damage_modifier;

	 // Apply damage type resistance multiplier
	 var _resistance_multiplier = get_damage_type_multiplier(self, _weapon_damage_type);
	 var _final_damage = _after_traits * _resistance_multiplier;

	 hp -= _final_damage;
	 image_blend = c_red;

	 // Spawn damage number or immunity text
	 if (_resistance_multiplier <= 0) {
	     spawn_immune_text(x, y - 16, self);
	 } else {
	     spawn_damage_number(x, y - 16, _final_damage, _weapon_damage_type, self);
	 }

	 // Play enemy hit sound
	 play_enemy_sfx("on_hit");

	 show_debug_message("Damage calculation: base=" + string(_base_damage) +
	                    " type=" + string(_damage_type_string) +
	                    " trait_mod=" + string(_damage_modifier) +
	                    " resist_mult=" + string(_resistance_multiplier) +
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

	     // Play enemy death sound
	     play_enemy_sfx("on_death");

	     show_debug_message("Enemy state set to dead");
	 }

	 // Apply weapon status effects
	 var attacker = other.creator;
	 if (attacker != noone) {
	     // Check right hand weapon
	     if (attacker.equipped.right_hand != undefined) {
	         var weapon_stats = attacker.equipped.right_hand.definition.stats;
	         var status_effects_array = get_weapon_status_effects(weapon_stats);

	         // Apply each status effect with its own chance
	         for (var i = 0; i < array_length(status_effects_array); i++) {
	             var effect_data = status_effects_array[i];
	             if (random(1) < effect_data.chance) {
	                 apply_status_effect(effect_data.effect);
	                 show_debug_message("Right hand weapon applied status effect: " + string(effect_data.effect));
	             }
	         }
	     }

	     // Check left hand weapon/tool (like torch)
	     if (attacker.equipped.left_hand != undefined) {
	         var left_item_stats = attacker.equipped.left_hand.definition.stats;
	         var left_status_effects = get_weapon_status_effects(left_item_stats);

	         // Apply each status effect with its own chance
	         for (var i = 0; i < array_length(left_status_effects); i++) {
	             var effect_data = left_status_effects[i];
	             if (random(1) < effect_data.chance) {
	                 apply_status_effect(effect_data.effect);
	                 show_debug_message("Left hand item applied status effect: " + string(effect_data.effect));
	             }
	         }
	     }
	 }

	 kb_x = sign(x - other.x);
	 kb_y = sign(y - other.y);

	 alarm[1] = 20;
}
}