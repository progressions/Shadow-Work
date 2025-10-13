show_debug_message("COLLISION DETECTED: enemy hit by attack!");

var _attack_inst = other;

// Check if this enemy has already been hit by this attack
if (ds_list_find_index(_attack_inst.hit_enemies, id) != -1) {
	show_debug_message("Enemy already hit by this attack, skipping damage");
	exit; // Already hit, skip damage
}

// Check if attack has reached its max hit count
if (_attack_inst.current_hit_count >= _attack_inst.max_hit_count) {
	show_debug_message("Attack has reached max hit count (" + string(_attack_inst.max_hit_count) + "), skipping damage");
	exit; // Max hits reached, skip damage but animation continues
}

if (state != EnemyState.dead) {
	show_debug_message("Enemy state check passed, alarm[1] = " + string(alarm[1]));
	if (alarm[1] < 0) {
		// Add this enemy to the hit list
		ds_list_add(_attack_inst.hit_enemies, id);

		// Increment attack hit count
		_attack_inst.current_hit_count++;
		show_debug_message("Attack hit count: " + string(_attack_inst.current_hit_count) + "/" + string(_attack_inst.max_hit_count));

		 var old_hp = hp;
		 var attacker = other.creator; // Declare attacker once at the beginning

		 // Get weapon damage type from attacker's equipped weapon
		 var _weapon_damage_type = DamageType.physical; // Default
		 if (attacker != noone && instance_exists(attacker)) {
		     // Check right hand first
		     if (attacker.equipped.right_hand != undefined) {
		         var _weapon_stats = attacker.equipped.right_hand.definition.stats;
		         if (variable_struct_exists(_weapon_stats, "damage_type")) {
		             _weapon_damage_type = _weapon_stats.damage_type;
		         }
		     }
		     // Check left hand if no right hand weapon
		     else if (attacker.equipped.left_hand != undefined) {
		         var _left_stats = attacker.equipped.left_hand.definition.stats;
		         if (variable_struct_exists(_left_stats, "damage_type")) {
		             _weapon_damage_type = _left_stats.damage_type;
		         }
		     }
		 }

		 // Apply damage type resistance multiplier using trait system v2.0
		 var _base_damage = other.damage;

		 // Debug: Check traits
		 show_debug_message("=== TRAIT DEBUG ===");
		 show_debug_message("permanent_traits: " + json_stringify(permanent_traits));
		 show_debug_message("temporary_traits: " + json_stringify(temporary_traits));
		 show_debug_message("Weapon damage type: " + damage_type_to_string(_weapon_damage_type));

		 var _resistance_multiplier = get_damage_modifier_for_type(_weapon_damage_type);

		 show_debug_message("Resistance multiplier: " + string(_resistance_multiplier));
		 show_debug_message("==================");

		 // Apply armor pierce from Execution Window (reduces enemy DR)
		 var _armor_pierce = get_execution_window_armor_pierce();
		 var _effective_dr = max(0, melee_damage_resistance - _armor_pierce);

		 // Apply damage type resistance, then subtract damage resistance (with armor pierce)
		 var _final_damage = max(0, (_base_damage * _resistance_multiplier) - _effective_dr);

		 // Notify companions of hit (adds on_hit_strike bonus damage)
		 var _bonus_damage = companion_on_player_hit(other.creator, id, _final_damage);
		 _final_damage += _bonus_damage;

		 hp -= _final_damage;

		 // Interrupt ranged attack windup if enemy takes damage during windup
		 if (state == EnemyState.ranged_attacking && !ranged_windup_complete) {
		     state = EnemyState.targeting;
		     ranged_windup_complete = false; // Reset flag
		     ranged_attack_cooldown = 0; // Reset cooldown so they can attack again sooner

		     // Play interrupt sound
		     play_sfx(snd_enemy_interrupted, 0.7, false);

		     if (variable_global_exists("debug_mode") && global.debug_damage_reduction) {
		         show_debug_message("RANGED ATTACK INTERRUPTED - Enemy took damage during windup");
		     }
		 }

		 // Flash and freeze based on crit status
		 if (_attack_inst.is_crit) {
		     // Critical hit: red flash + longer freeze
		     image_blend = c_red;
			 
		     
		 } else {
		     // Normal hit: white flash + short freeze
		    show_debug_message("just set image_blend to c_red");
		    image_blend = c_red;
			// this block doesn't seem to change the image_blend, or something overwrites it
		 }
		 
		 show_debug_message("WHATS UP ENEMY GOT HIT + " + string(image_blend));

		 // Screen shake based on weapon type
		 screen_shake(_attack_inst.shake_intensity);

		 // Spawn hit effect (sparkle) spraying away from attack
		 var _hit_direction = point_direction(_attack_inst.x, _attack_inst.y, x, y);
		 spawn_hit_effect(x, y, _hit_direction);

		 // Reset player combat timer for companion evading behavior
		 var attacker = other.creator;
		 if (attacker != noone && instance_exists(attacker) && attacker.object_index == obj_player) {
		     attacker.combat_timer = 0;
		 }

		 // Spawn damage number or immunity text
		 if (_resistance_multiplier <= 0) {
		     spawn_immune_text(x, y - 16, self);
		 } else {
		     spawn_damage_number(x, y - 16, _final_damage, _weapon_damage_type, self);
		 }

		 // Play enemy hit sound
		 play_enemy_sfx("on_hit");

		 show_debug_message("Damage calculation: base=" + string(_base_damage) +
		                    " type=" + damage_type_to_string(_weapon_damage_type) +
		                    " resist_mult=" + string(_resistance_multiplier) +
		                    " final=" + string(_final_damage));

		 show_debug_message("Enemy hit! HP: " + string(old_hp) + " -> " + string(hp));

		 // Apply stun/stagger from weapon if enemy didn't die and damage was dealt
		 if (hp > 0 && _final_damage > 0 && _resistance_multiplier > 0) {
		     // attacker already declared at the beginning
		     if (attacker != noone && instance_exists(attacker)) {
		         // Get weapon stats from attacker
		         var _weapon_stats = undefined;
		         if (attacker.equipped.right_hand != undefined) {
		             _weapon_stats = attacker.equipped.right_hand.definition.stats;
		         } else if (attacker.equipped.left_hand != undefined) {
		             _weapon_stats = attacker.equipped.left_hand.definition.stats;
		         }

		         // Process stun/stagger effects
		         if (_weapon_stats != undefined) {
		             process_attack_cc_effects(attacker, self, _weapon_stats);
		         }
		     }
		 }

		 // Check if enemy died and award XP
		 if (hp <= 0) {
		     attacker = other.creator;
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

		     // Extra long freeze on crit kill (6 frames), normal kill freeze (4 frames)
		     if (_attack_inst.is_crit) {
		         freeze_frame(6); // Crit kill gets extra impact
		     } else {
		         freeze_frame(4); // Normal kill
		     }

		     // Drop loot (rolls for drop chance and spawns item if successful)
		     enemy_drop_loot(self);

		     // Play enemy death sound
		     play_enemy_sfx("on_death");

		     // Track enemy defeat for quest system
		     increment_quest_counter("enemies_defeated", 1);

		     show_debug_message("Enemy state set to dead");
		 }

		 // Apply weapon status effects
		 // attacker already declared at the beginning
		 if (attacker != noone) {
		     // Check right hand weapon
		     if (attacker.equipped.right_hand != undefined) {
		         var weapon_stats = attacker.equipped.right_hand.definition.stats;
		         var status_effects_array = get_weapon_status_effects(weapon_stats);

		         // Apply each status effect with its own chance
	         for (var i = 0; i < array_length(status_effects_array); i++) {
	             var effect_data = status_effects_array[i];
	             if (random(1) < effect_data.chance) {
	                 apply_status_effect(effect_data);
	                 show_debug_message("Right hand weapon applied trait effect: " + string(status_effect_resolve_trait(effect_data)));
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
	                 apply_status_effect(effect_data);
	                 show_debug_message("Left hand item applied trait effect: " + string(status_effect_resolve_trait(effect_data)));
	             }
	         }
		     }
		 }

		 var _knockback_force = 6;
		 if (variable_instance_exists(other, "knockback_force")) {
		     _knockback_force = other.knockback_force;
		 }
		 var _knockback_dir = point_direction(other.x, other.y, x, y);
		 kb_x = lengthdir_x(_knockback_force, _knockback_dir);
		 kb_y = lengthdir_y(_knockback_force, _knockback_dir);
		 knockback_timer = max(8, round(_knockback_force));
		 alarm[1] = knockback_timer;
	}
}

// Don't destroy attack instance - let it finish animation
// The hit_enemies list prevents multi-hit
