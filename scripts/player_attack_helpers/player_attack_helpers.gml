/// @description Helper utilities for applying player-origin attacks to enemies

/// @function player_attack_apply_damage(attacker, enemy, info)
/// @param attacker {Id.Instance} Player instance dealing damage
/// @param enemy {Id.Instance} Enemy instance receiving damage
/// @param info {Struct} Attack metadata
///        Required fields: damage, damage_type
///        Optional fields:
///            attack_category (defaults to AttackCategory.melee)
///            is_crit (bool)
///            knockback_force (real)
///            shake_intensity (real)
///            hit_source_x (real)
///            hit_source_y (real)
///            apply_status_effects (bool, default true)
///            allow_interrupt (bool, default true)
///            armor_pierce (real, defaults to get_execution_window_armor_pierce())
///            flash_on_hit (bool, default true)
/// @return {Struct} Result payload {applied, damage_dealt, resistance_multiplier, enemy_alive, was_immune}
function player_attack_apply_damage(_attacker, _enemy, _info) {
    if (!instance_exists(_attacker) || !instance_exists(_enemy)) {
        return {
            applied: false,
            damage_dealt: 0,
            resistance_multiplier: 1,
            enemy_alive: instance_exists(_enemy),
            was_immune: false
        };
    }

    if (!variable_struct_exists(_info, "attack_category")) {
        _info.attack_category = AttackCategory.melee;
    }

    if (!variable_struct_exists(_info, "armor_pierce")) {
        _info.armor_pierce = get_execution_window_armor_pierce();
    }

    if (!variable_struct_exists(_info, "apply_status_effects")) {
        _info.apply_status_effects = true;
    }

    if (!variable_struct_exists(_info, "allow_interrupt")) {
        _info.allow_interrupt = true;
    }

    if (!variable_struct_exists(_info, "flash_on_hit")) {
        _info.flash_on_hit = true;
    }

    if (!variable_struct_exists(_info, "is_crit")) {
        _info.is_crit = false;
    }

    if (!variable_struct_exists(_info, "shake_intensity")) {
        _info.shake_intensity = 0;
    }

    if (!variable_struct_exists(_info, "knockback_force")) {
        _info.knockback_force = 0;
    }

    if (!variable_struct_exists(_info, "hit_source_x")) {
        _info.hit_source_x = _attacker.x;
    }

    if (!variable_struct_exists(_info, "hit_source_y")) {
        _info.hit_source_y = _attacker.y;
    }

    // Stash info/result on the attacker so we can access inside with() call
    _attacker.__attack_info_temp = _info;
    _attacker.__attack_result_temp = {
        applied: false,
        damage_dealt: 0,
        resistance_multiplier: 1,
        enemy_alive: true,
        was_immune: false
    };

    var _attacker_id = _attacker;

    with (_enemy) {
        if (!instance_exists(_attacker_id)) {
            exit;
        }

        var _attack_info = _attacker_id.__attack_info_temp;

        if (_attack_info == undefined) {
            exit;
        }

        // Avoid double-processing dead enemies
        if (state == EnemyState.dead) {
            other.__attack_result_temp.applied = false;
            other.__attack_result_temp.enemy_alive = false;
            exit;
        }

        var _base_damage = _attack_info.damage;
        var _damage_type = _attack_info.damage_type;
        var _attack_category = _attack_info.attack_category;
        var _is_crit = _attack_info.is_crit;
        var _knockback_force = _attack_info.knockback_force;
        var _hit_source_x = _attack_info.hit_source_x;
        var _hit_source_y = _attack_info.hit_source_y;
        var _apply_status_effects = _attack_info.apply_status_effects;
        var _allow_interrupt = _attack_info.allow_interrupt;
        var _flash_on_hit = _attack_info.flash_on_hit;
        var _shake_intensity = _attack_info.shake_intensity;
        var _armor_pierce = _attack_info.armor_pierce;

        var _resistance_multiplier = get_damage_modifier_for_type(_damage_type);
        var _damage_after_resistance = _base_damage * _resistance_multiplier;

        var _raw_dr = melee_damage_resistance;
        if (_attack_category == AttackCategory.ranged) {
            _raw_dr = ranged_damage_resistance;
        }

        var _effective_dr = max(0, _raw_dr - _armor_pierce);
        var _final_damage = max(0, _damage_after_resistance - _effective_dr);

        // Companion on-hit bonuses (Yorna, etc.) – only applies to the player
        if (_attacker_id.object_index == obj_player) {
            var _bonus_damage = companion_on_player_hit(_attacker_id, id, _final_damage);
            _final_damage += _bonus_damage;
        }

        hp -= _final_damage;

        if (_allow_interrupt && state == EnemyState.ranged_attacking && !ranged_windup_complete) {
            state = EnemyState.targeting;
            ranged_windup_complete = false;
            ranged_attack_cooldown = 0;
            play_sfx(snd_enemy_interrupted, 0.7, false);

            if (variable_global_exists("debug_mode") && global.debug_damage_reduction) {
                show_debug_message("RANGED ATTACK INTERRUPTED - Enemy took damage");
            }
        }

        if (_flash_on_hit) {
            flash_color = _is_crit ? c_red : c_white;
            flash_timer = _is_crit ? 12 : 8;
            image_blend = c_red;
        }

        // Damage numbers / immunity feedback
        if (_resistance_multiplier <= 0) {
            spawn_immune_text(x, y - 16, self);
            _attacker_id.__attack_result_temp.was_immune = true;
        } else {
            spawn_damage_number(x, y - 16, _final_damage, _damage_type, self);
        }

        play_enemy_sfx("on_hit");
        screen_shake(_shake_intensity);

        var _hit_direction = point_direction(_hit_source_x, _hit_source_y, x, y);
        spawn_hit_effect(x, y, _hit_direction);

        // Apply crowd control effects if damage went through
        if (_apply_status_effects && _final_damage > 0 && _resistance_multiplier > 0) {
            var _weapon_stats_primary = undefined;
            if (variable_instance_exists(_attacker_id, "equipped") && _attacker_id.equipped != undefined) {
                if (_attacker_id.equipped.right_hand != undefined) {
                    _weapon_stats_primary = _attacker_id.equipped.right_hand.definition.stats;
                } else if (_attacker_id.equipped.left_hand != undefined) {
                    _weapon_stats_primary = _attacker_id.equipped.left_hand.definition.stats;
                }
            }

            if (_weapon_stats_primary != undefined) {
                process_attack_cc_effects(_attacker_id, self, _weapon_stats_primary);
            }

            if (variable_instance_exists(_attacker_id, "equipped") && _attacker_id.equipped != undefined) {
                if (_attacker_id.equipped.right_hand != undefined) {
                    var _right_stats = _attacker_id.equipped.right_hand.definition.stats;
                    var _right_effects = get_weapon_status_effects(_right_stats);

                    for (var _i = 0; _i < array_length(_right_effects); _i++) {
                        var _effect = _right_effects[_i];
                        if (random(1) < _effect.chance) {
                            apply_status_effect(_effect);

                            if (variable_global_exists("debug_mode") && global.debug_damage_reduction) {
                                show_debug_message("Weapon applied trait effect: " + string(status_effect_resolve_trait(_effect)));
                            }
                        }
                    }
                }

                if (_attacker_id.equipped.left_hand != undefined) {
                    var _left_stats = _attacker_id.equipped.left_hand.definition.stats;
                    var _left_effects = get_weapon_status_effects(_left_stats);

                    for (var _j = 0; _j < array_length(_left_effects); _j++) {
                        var _left_effect = _left_effects[_j];
                        if (random(1) < _left_effect.chance) {
                            apply_status_effect(_left_effect);

                            if (variable_global_exists("debug_mode") && global.debug_damage_reduction) {
                                show_debug_message("Offhand applied trait effect: " + string(status_effect_resolve_trait(_left_effect)));
                            }
                        }
                    }
                }
            }
        }

        // Knockback
        if (_knockback_force > 0) {
            var _knockback_dir = _hit_direction;
            kb_x = lengthdir_x(_knockback_force, _knockback_dir);
            kb_y = lengthdir_y(_knockback_force, _knockback_dir);
            knockback_timer = max(8, round(_knockback_force));
            alarm[1] = knockback_timer;
        }

        // Award XP and handle death
        var _enemy_dead = (hp <= 0);
        if (_enemy_dead) {
            if (_attacker_id.object_index == obj_player) {
                var xp_reward = 5;
                with (_attacker_id) {
                    gain_xp(xp_reward);
                }
            }

            state = EnemyState.dead;

            if (_is_crit) {
                freeze_frame(6);
            } else {
                freeze_frame(4);
            }

            enemy_drop_loot(self);
            play_enemy_sfx("on_death");
            increment_quest_counter("enemies_defeated", 1);
        }

        // Reset combat timer so companions know combat is active
        if (variable_instance_exists(_attacker_id, "combat_timer")) {
            _attacker_id.combat_timer = 0;
        }

        _attacker_id.__attack_result_temp.applied = true;
        _attacker_id.__attack_result_temp.damage_dealt = _final_damage;
        _attacker_id.__attack_result_temp.resistance_multiplier = _resistance_multiplier;
        _attacker_id.__attack_result_temp.enemy_alive = !_enemy_dead;
        _attacker_id.__attack_result_temp.was_immune = (_resistance_multiplier <= 0);
    }

    var _result = _attacker_id.__attack_result_temp;

    _attacker_id.__attack_info_temp = undefined;
    _attacker_id.__attack_result_temp = undefined;

    return _result;
}
