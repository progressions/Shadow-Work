/// @description Dash attack helpers for the player

/// @function player_get_dash_target_cap()
/// @returns {Real} Maximum number of enemies that can be damaged during the current dash
function player_get_dash_target_cap() {
    var _base_targets = 1;

    if (level >= 5)  _base_targets = 2;
    if (level >= 10) _base_targets = 3;
    if (level >= 15) _base_targets = 4;

    dash_multi_bonus_active = false;
    dash_multi_bonus_cap = 0;

    var _multi_params = get_companion_multi_target_params();
    if (_multi_params != undefined) {
        if (random(1) < _multi_params.chance) {
            _base_targets = max(_base_targets, _multi_params.max_targets);
            dash_multi_bonus_active = true;
            dash_multi_bonus_cap = _multi_params.max_targets;
        }
    }

    return max(1, _base_targets);
}

/// @function player_dash_begin()
/// @description Prepare dash damage tracking at dash start
function player_dash_begin() {
    if (!variable_instance_exists(self, "dash_hit_enemies") || !ds_exists(dash_hit_enemies, ds_type_list)) {
        dash_hit_enemies = ds_list_create();
    } else {
        ds_list_clear(dash_hit_enemies);
    }

    dash_hit_count = 0;
    dash_target_cap = player_get_dash_target_cap();
    dash_impact_sound_played = false;
}

/// @function player_dash_end()
/// @description Reset dash damage state after dash ends
function player_dash_end() {
    dash_hit_count = 0;
    dash_target_cap = 1;
    dash_impact_sound_played = false;

    if (variable_instance_exists(self, "dash_hit_enemies") && ds_exists(dash_hit_enemies, ds_type_list)) {
        ds_list_clear(dash_hit_enemies);
    }
}

/// @function player_dash_handle_collisions(prev_x, prev_y)
/// @description Deal damage to enemies intersected during a dash
/// @param prev_x {Real} Player X position prior to dash movement this step
/// @param prev_y {Real} Player Y position prior to dash movement this step
function player_dash_handle_collisions(_prev_x, _prev_y) {
    if (dash_hit_count >= dash_target_cap) return;
    if (!instance_exists(obj_enemy_parent)) return;

    if (!variable_instance_exists(self, "dash_hit_enemies") || !ds_exists(dash_hit_enemies, ds_type_list)) {
        dash_hit_enemies = ds_list_create();
    }

    var _prev_dash_flag = is_dash_attacking;
    is_dash_attacking = true;
    var _dash_damage = get_total_damage();
    var _dash_crit = last_attack_was_crit;
    is_dash_attacking = _prev_dash_flag;

    var _damage_type = DamageType.physical;
    if (equipped.right_hand != undefined) {
        var _weapon_stats = equipped.right_hand.definition.stats;
        if (variable_struct_exists(_weapon_stats, "damage_type")) {
            _damage_type = _weapon_stats.damage_type;
        }
    } else if (equipped.left_hand != undefined) {
        var _left_stats = equipped.left_hand.definition.stats;
        if (variable_struct_exists(_left_stats, "damage_type")) {
            _damage_type = _left_stats.damage_type;
        }
    }

    var _knockback_force = 6;
    if (equipped.right_hand != undefined) {
        var _knockback_stats = equipped.right_hand.definition.stats;
        if (variable_struct_exists(_knockback_stats, "knockback_force")) {
            _knockback_force = _knockback_stats.knockback_force;
        }
    }

    var _shake_intensity = 2;
    if (equipped.right_hand != undefined) {
        var _handedness = equipped.right_hand.definition.handedness;
        switch (_handedness) {
            case WeaponHandedness.two_handed:
                _shake_intensity = 8;
                break;
            case WeaponHandedness.versatile:
                _shake_intensity = is_two_handing() ? 6 : 4;
                break;
            case WeaponHandedness.one_handed:
                _shake_intensity = 4;
                break;
            default:
                _shake_intensity = 2;
                break;
        }
    }

    var _armor_pierce = get_execution_window_armor_pierce();

    dash_prev_x_temp = _prev_x;
    dash_prev_y_temp = _prev_y;
    dash_cached_damage = _dash_damage;
    dash_cached_is_crit = _dash_crit;
    dash_cached_damage_type = _damage_type;
    dash_cached_knockback = _knockback_force;
    dash_cached_shake = _shake_intensity;
    dash_cached_armor_pierce = _armor_pierce;

    with (obj_enemy_parent) {
        if (other.dash_hit_count >= other.dash_target_cap) continue;
        if (!instance_exists(self)) continue;
        if (ds_list_find_index(other.dash_hit_enemies, id) != -1) continue;
        if (state == EnemyState.dead) continue;
        if (alarm[1] >= 0) continue;

        var _prev_x_local = other.dash_prev_x_temp;
        var _prev_y_local = other.dash_prev_y_temp;

        var _overlap_now = !(bbox_right < other.bbox_left || bbox_left > other.bbox_right || bbox_bottom < other.bbox_top || bbox_top > other.bbox_bottom);

        var _line_hit = false;
        if (!_overlap_now) {
            var _line_result = collision_line(_prev_x_local, _prev_y_local, other.x, other.y, id, false, true);
            _line_hit = (_line_result == id);
        }

        if (!_overlap_now && !_line_hit) continue;

        ds_list_add(other.dash_hit_enemies, id);

        var _attack_info = {
            damage: other.dash_cached_damage,
            damage_type: other.dash_cached_damage_type,
            attack_category: AttackCategory.melee,
            is_crit: other.dash_cached_is_crit,
            knockback_force: other.dash_cached_knockback,
            shake_intensity: other.dash_cached_shake,
            hit_source_x: _prev_x_local,
            hit_source_y: _prev_y_local,
            apply_status_effects: true,
            allow_interrupt: true,
            armor_pierce: other.dash_cached_armor_pierce,
            flash_on_hit: true
        };

        var _result = player_attack_apply_damage(other, id, _attack_info);

        if (_result.applied) {
            other.dash_hit_count++;

            if (!other.dash_impact_sound_played) {
                play_sfx(snd_dash_attack, 1, false);
                other.dash_impact_sound_played = true;
            }
        }
    }

    dash_prev_x_temp = undefined;
    dash_prev_y_temp = undefined;
}
