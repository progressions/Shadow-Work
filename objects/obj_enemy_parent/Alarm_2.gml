// Enemy attack execution
if (global.game_paused) exit;

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

            // Apply damage type resistance multiplier using trait system v2.0
            var _resistance_multiplier = 1.0;
            with (_player) {
                _resistance_multiplier = get_damage_modifier_for_type(other.attack_damage_type);
            }
            var _after_resistance = _status_modified_damage * _resistance_multiplier;

            // Apply player melee damage reduction (enemy melee attacks)
            var _player_dr = 0;
            with (_player) {
                _player_dr = get_melee_damage_reduction();
            }
            var _after_defense = _after_resistance - _player_dr;

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

            // Deal damage to player
            _player.hp -= final_damage;

            // Reset combat timer for companion evading behavior
            _player.combat_timer = 0;

            // Spawn damage number or immunity text
            if (_resistance_multiplier <= 0) {
                spawn_immune_text(_player.x, _player.y - 16, _player);
            } else {
                spawn_damage_number(_player.x, _player.y - 16, final_damage, attack_damage_type, _player);
            }

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

            // Apply attack status effects (like burning from fire imp)
            if (variable_instance_exists(self, "attack_status_effects")) {
                for (var i = 0; i < array_length(attack_status_effects); i++) {
                    var effect_data = attack_status_effects[i];
                    if (random(1) < effect_data.chance) {
                        with (_player) {
                            apply_status_effect(effect_data.effect);
                        }
                        show_debug_message("Enemy applied status effect: " + string(effect_data.effect));
                    }
                }
            }

            show_debug_message("Enemy dealt " + string(final_damage) + " damage to player");
        } else {
            // Player moved out of range, attack missed
            play_sfx(snd_attack_miss, 1, false);
        }
    }

    // Note: state will be reset to idle by obj_enemy_attack when it completes
}