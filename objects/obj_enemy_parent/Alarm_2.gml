// Enemy attack execution
if (global.game_paused) exit;

if (state == EnemyState.attacking) {
    // Play enemy melee attack sound
    play_enemy_sfx("on_melee_attack");

    // Create visual attack effect
    var _attack = instance_create_layer(x, y, "Instances", obj_enemy_attack);
    _attack.creator = self;

    var _player = instance_nearest(x, y, obj_player);
    if (_player != noone) {
        var _melee_range = attack_range;
        if (is_struct(melee_attack) && variable_struct_exists(melee_attack, "range")) {
            _melee_range = melee_attack.range;
        }

        var _dist = point_distance(x, y, _player.x, _player.y);
        if (_dist <= _melee_range && _player.state != PlayerState.dead) {
            // Roll for critical hit
            var _is_crit = (random(1) < crit_chance);
            var _crit_multiplier = _is_crit ? crit_multiplier : 1.0;

            // Apply status effect damage modifiers
            var damage_modifier = get_status_effect_modifier("damage");
            var _status_modified_damage = attack_damage * damage_modifier * _crit_multiplier;

            // Apply damage type resistance multiplier using trait system v2.0
            var _resistance_multiplier = 1.0;
            if (instance_exists(_player)) {
                with (_player) {
                    _resistance_multiplier = get_damage_modifier_for_type(other.attack_damage_type);
                }
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
            companion_on_player_damaged(_player, final_damage, attack_damage_type);

            // Interrupt player ranged attack windup if taking damage during windup
            with (_player) {
                if (ranged_windup_active && !ranged_windup_complete) {
                    state = PlayerState.idle;
                    ranged_windup_active = false;
                    ranged_windup_complete = false;
                    anim_frame = 0; // Reset animation

                    // Play interrupt sound
                    play_sfx(snd_player_interrupted, 0.7, false);

                    // Refund arrow since attack was interrupted
                    inventory_add_item(global.item_database.arrows, 1);

                    if (variable_global_exists("debug_mode") && global.debug_damage_reduction) {
                        show_debug_message("PLAYER RANGED ATTACK INTERRUPTED - Took damage during windup, arrow refunded");
                    }
                }
            }

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

            // Visual feedback (stronger for crits)
            if (_is_crit) {
                _player.image_blend = c_red;
                _player.alarm[0] = 15; // Longer flash for crit
                freeze_frame(3); // Freeze on crit
            } else {
                _player.image_blend = c_red;
                _player.alarm[0] = 10; // Normal flash
                freeze_frame(2); // Brief freeze
            }

            // Play hit confirmation sound (player got hit)
            play_sfx(snd_attack_hit, 1, false);

            // Apply attack status effects (like burning from fire imp)
            if (variable_instance_exists(self, "attack_status_effects") && is_array(attack_status_effects)) {
                var _status_effects = attack_status_effects;
                show_debug_message("Checking " + string(array_length(_status_effects)) + " status effects");
                for (var i = 0; i < array_length(_status_effects); i++) {
                    var effect_data = _status_effects[i];
                    var _trait_key = status_effect_resolve_trait(effect_data);
                    var _chance = effect_data.chance;
                    var _roll = random(1);
                    show_debug_message("Status effect " + _trait_key + ": chance=" + string(_chance) + " roll=" + string(_roll));
                    if (_roll < _chance) {
                        show_debug_message("Applying status effect: " + _trait_key);
                        with (_player) {
                            var _applied = apply_status_effect(effect_data);
                            show_debug_message("Status effect apply result: " + string(_applied));
                        }
                        show_debug_message("Enemy applied trait effect: " + _trait_key);
                    } else {
                        show_debug_message("Status effect " + _trait_key + " did not proc (roll too high)");
                    }
                }
            } else {
                show_debug_message("Enemy has no attack_status_effects variable");
            }

            show_debug_message("Enemy dealt " + string(final_damage) + " damage to player");
        } else {
            // Player moved out of range, attack missed
            play_sfx(snd_attack_miss, 1, false);
        }
    }

    // Note: state will be reset to idle by obj_enemy_attack when it completes
}
