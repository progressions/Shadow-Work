return;
if (alarm[0] < 0 && other.state != EnemyState.dead && state != PlayerState.dead) {

	// Apply trait-based damage modifiers
	var _base_damage = other.attack_damage;
	var _damage_type = "physical"; // Enemies default to physical damage for now
	var _modifier_key = _damage_type + "_damage_modifier";
	var _damage_modifier = get_all_trait_modifiers(_modifier_key);
	var _final_damage = _base_damage * _damage_modifier;

	hp -= _final_damage;

	alarm[0] = 60;
	image_blend = c_red;
	show_debug_message("You got hit");
	play_sfx(snd_attack_sword, 1, false);
	
	if (hp <= 0) {
		state = PlayerState.dead;
		show_debug_message("Player died");
	}
}