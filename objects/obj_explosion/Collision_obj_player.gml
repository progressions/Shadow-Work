/// Collision with player - apply explosion damage once

// Only damage if player is alive and we haven't damaged yet
if (other.hp > 0 && other.state != PlayerState.dead && !has_damaged) {
    has_damaged = true;  // Mark as damaged to prevent multiple hits

    // Calculate final damage with player's damage reduction
    var _base_damage = damage_amount;

    // Apply damage type modifier from player's traits
    var _damage_modifier = 1.0;
    if (variable_instance_exists(other, "get_damage_modifier_for_type")) {
        _damage_modifier = other.get_damage_modifier_for_type(damage_type);
    }
    var _modified_damage = _base_damage * _damage_modifier;

    // Apply equipment DR (ranged DR for explosions)
    var _player_dr = 0;
    if (variable_instance_exists(other, "get_equipment_ranged_dr")) {
        _player_dr += other.get_equipment_ranged_dr();
    }

    // Add companion DR bonus if applicable
    if (variable_instance_exists(other, "get_companion_dr_bonus")) {
        _player_dr += other.get_companion_dr_bonus();
    }

    // Apply defense trait modifier to DR (bolstered/sundered)
    if (variable_instance_exists(other, "get_total_trait_stacks")) {
        var _defense_mod = 1.0;
        var _bolstered = other.get_total_trait_stacks("defense_resistance");
        var _sundered = other.get_total_trait_stacks("defense_vulnerability");

        if (_bolstered > 0) {
            _defense_mod *= power(1.33, _bolstered);
        }
        if (_sundered > 0) {
            _defense_mod *= power(0.75, _sundered);
        }

        _player_dr *= _defense_mod;
    }

    // Calculate final damage after DR
    var _final_damage = max(1, _modified_damage - _player_dr);  // Min 1 chip damage

    // Apply damage to player
    other.hp -= _final_damage;

    // Vibrate gamepad on hit
    InputVibrateConstant(0.5, 0, 200);

    // Spawn damage number
    if (script_exists(spawn_damage_number)) {
        spawn_damage_number(other.x, other.y - 16, _final_damage, damage_type, other);
    }

    // Visual feedback - flash player
    other.image_blend = c_red;
    other.alarm[0] = 10;  // Reset color after 10 frames

    // Apply knockback (explosion pushes outward from center)
    var _kb_force = 3;
    var _angle = point_direction(x, y, other.x, other.y);
    other.kb_x = lengthdir_x(_kb_force, _angle);
    other.kb_y = lengthdir_y(_kb_force, _angle);

    // Play hit sound
    if (audio_exists(snd_player_hit)) {
        play_sfx(snd_player_hit, 1, false);
    }

    // Set player combat timer
    if (variable_instance_exists(other, "combat_timer")) {
        other.combat_timer = 0;  // Reset to max combat duration
    }

    // Check if player died
    if (other.hp <= 0) {
        other.state = PlayerState.dead;
    }
}
