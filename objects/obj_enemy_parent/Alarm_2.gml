// Enemy attack execution
if (state == EnemyState.attacking) {
    // Play enemy attack sound
    play_enemy_sfx("on_attack");

    // Create visual attack effect
    var _attack = instance_create_layer(x, y, "Instances", obj_enemy_attack);
    _attack.creator = self;

    var _player = instance_nearest(x, y, obj_player);
    if (_player != noone) {
        var _dist = point_distance(x, y, _player.x, _player.y);
        if (_dist <= attack_range && _player.state != PlayerState.dead) {
            // Apply status effect damage modifiers
            var damage_modifier = get_status_effect_modifier("damage");
            var _status_modified_damage = attack_damage * damage_modifier;

            // Apply player armor defense (DR)
            var _defense = 0;
            with (_player) {
                _defense = get_total_defense();
            }
            var _after_defense = _status_modified_damage - _defense;

            // Apply chip damage floor only if armor fully blocked the attack
            var _chip = 1;
            var final_damage;
            if (_after_defense <= 0) {
                // Armor blocked everything, apply chip damage
                final_damage = _chip;
            } else {
                // Some damage got through
                final_damage = _after_defense;
            }
            var _mitigated_damage = final_damage;

            // Debug logging
            show_debug_message("Enemy Attack: base=" + string(attack_damage) +
                             " defense=" + string(_defense) +
                             " mitigated=" + string(_mitigated_damage) +
                             " chip=" + string(_chip) +
                             " final=" + string(final_damage));

            // Deal damage to player
            _player.hp -= final_damage;

            // Check if player died
            if (_player.hp <= 0) {
                _player.state = PlayerState.dead;
                show_debug_message("Player died");
            }

            // Add knockback to player
            var _angle = point_direction(x, y, _player.x, _player.y);
            _player.kb_x = lengthdir_x(3, _angle);
            _player.kb_y = lengthdir_y(3, _angle);

            // Visual feedback
            _player.image_blend = c_red;
            _player.alarm[0] = 10; // Flash red briefly

            // Play hit confirmation sound (player got hit)
            play_sfx(snd_attack_hit, 1, false);

            show_debug_message("Enemy dealt " + string(final_damage) + " damage to player");
        } else {
            // Player moved out of range, attack missed
            play_sfx(snd_attack_miss, 1, false);
        }
    }

    // Note: state will be reset to idle by obj_enemy_attack when it completes
}