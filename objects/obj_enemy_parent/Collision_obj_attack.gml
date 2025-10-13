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

		 var attacker = other.creator;
         if (attacker == noone || !instance_exists(attacker)) {
             exit;
         }

         if (attacker.object_index != obj_player) {
             exit;
         }

         if (!instance_exists(other)) {
             exit;
         }

         var _weapon_damage_type = DamageType.physical;
         if (attacker.equipped.right_hand != undefined) {
		     var _weapon_stats = attacker.equipped.right_hand.definition.stats;
		     if (variable_struct_exists(_weapon_stats, "damage_type")) {
		         _weapon_damage_type = _weapon_stats.damage_type;
		     }
		 } else if (attacker.equipped.left_hand != undefined) {
		     var _left_stats = attacker.equipped.left_hand.definition.stats;
		     if (variable_struct_exists(_left_stats, "damage_type")) {
		         _weapon_damage_type = _left_stats.damage_type;
		     }
		 }

		 var _attack_info = {
		     damage: other.damage,
		     damage_type: _weapon_damage_type,
		     attack_category: _attack_inst.attack_category,
		     is_crit: _attack_inst.is_crit,
		     knockback_force: variable_instance_exists(other, "knockback_force") ? other.knockback_force : 6,
		     shake_intensity: _attack_inst.shake_intensity,
		     hit_source_x: _attack_inst.x,
		     hit_source_y: _attack_inst.y,
		     apply_status_effects: true,
		     allow_interrupt: true,
		     armor_pierce: get_execution_window_armor_pierce()
		 };

		 var _result = player_attack_apply_damage(attacker, id, _attack_info);

		 show_debug_message("Damage calculation: type=" + damage_type_to_string(_weapon_damage_type) +
		                    " resist_mult=" + string(_result.resistance_multiplier) +
		                    " final=" + string(_result.damage_dealt));
	}
}

// Don't destroy attack instance - let it finish animation
// The hit_enemies list prevents multi-hit
