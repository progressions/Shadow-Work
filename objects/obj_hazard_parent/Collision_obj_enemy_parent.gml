/// obj_hazard_parent : Collision with obj_enemy_parent
/// Handle enemy entering hazard - add to tracking, apply damage/traits

var enemy = other;

// Skip if enemy is dead
if (enemy.state == EnemyState.dead) {
    exit;
}

// Check if enemy is already in the list
var already_inside = (ds_list_find_index(entities_inside, enemy.id) != -1);

if (!already_inside) {
    // Add enemy to tracking list
    ds_list_add(entities_inside, enemy.id);

    // Play enter SFX
    if (sfx_enter != undefined) {
        play_sfx(sfx_enter, 1, false);
    }

    show_debug_message("Enemy entered hazard: " + object_get_name(enemy.object_index));
}

// ==============================
// ON-ENTER DAMAGE
// ==============================

if (damage_mode == "on_enter" && damage_amount > 0) {
    // Check damage immunity
    var has_immunity = ds_map_exists(damage_immunity_map, enemy.id);

    if (!has_immunity) {
        with (enemy) {
            // Get damage modifier from traits
            var _resistance_multiplier = get_damage_modifier_for_type(other.damage_type);

            // Check for immunity
            if (_resistance_multiplier <= 0) {
                play_sfx(snd_attack_miss, 1, false);
                spawn_immune_text(x, y - 16, self);
            } else {
                // Calculate final damage
                var _base_damage = other.damage_amount;
                var _after_resistance = _base_damage * _resistance_multiplier;

                // Apply enemy DR
                var _dr = melee_damage_resistance; // Use melee DR for environmental hazards
                var _final_damage = max(1, ceil(_after_resistance - _dr));

                // Apply damage
                hp -= _final_damage;

                // Visual feedback
                enemy_flash(c_white, 8);

                // Play damage sound
                if (other.sfx_damage != undefined) {
                    play_sfx(other.sfx_damage, 1, false);
                } else {
                    play_enemy_sfx("on_hit");
                }

                // Spawn damage number
                spawn_damage_number(x, y - 16, _final_damage, other.damage_type, self);

                // Check for death
                if (hp <= 0) {
                    state = EnemyState.dead;
                    play_enemy_sfx("on_death");
                }
            }
        }

        // Set damage immunity
        damage_immunity_map[? enemy.id] = damage_immunity_duration;
    }
}

// ==============================
// ON-ENTER EFFECT APPLICATION
// ==============================

if (effect_mode == "on_enter" && effect_to_apply != undefined) {
    // Check if enemy has immunity traits
    var _is_immune = false;
    with (enemy) {
        for (var i = 0; i < array_length(other.immunity_traits); i++) {
            if (has_trait(other.immunity_traits[i])) {
                _is_immune = true;
                show_debug_message(object_get_name(object_index) + " is immune to hazard (has " + other.immunity_traits[i] + ")");
                break;
            }
        }
    }

    if (_is_immune) {
        exit; // Don't apply effect if immune
    }

    // Check effect immunity (cooldown)
    var has_effect_immunity = ds_map_exists(effect_immunity_map, enemy.id);

    if (!has_effect_immunity) {
        with (enemy) {
            if (other.effect_type == "trait") {
                apply_timed_trait(other.effect_to_apply, other.effect_duration);
                show_debug_message("Hazard applied trait: " + other.effect_to_apply + " to " + object_get_name(object_index));
            } else if (other.effect_type == "status") {
                apply_status_effect(other.effect_to_apply, other.effect_duration);
                show_debug_message("Hazard applied status trait: " + string(status_effect_resolve_trait(other.effect_to_apply)) + " to " + object_get_name(object_index));
            }
        }

        // Set effect immunity
        effect_immunity_map[? enemy.id] = effect_immunity_duration;
    }
}
