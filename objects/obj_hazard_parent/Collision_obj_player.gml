/// obj_hazard_parent : Collision with obj_player
/// Handle player entering hazard - add to tracking, apply damage/traits

var player = other;

// Check if player is already in the list
var already_inside = (ds_list_find_index(entities_inside, player.id) != -1);

if (!already_inside) {
    // Add player to tracking list
    ds_list_add(entities_inside, player.id);

    // Play enter SFX
    if (sfx_enter != undefined) {
        play_sfx(sfx_enter, 1, false);
    }

    show_debug_message("Player entered hazard: " + object_get_name(object_index));
}

// ==============================
// ON-ENTER DAMAGE
// ==============================

if (damage_mode == "on_enter" && damage_amount > 0) {
    // Check damage immunity
    var has_immunity = ds_map_exists(damage_immunity_map, player.id);

    if (!has_immunity) {
        with (player) {
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

                // Apply player DR
                var _dr = get_equipment_general_dr() + get_companion_dr_bonus();
                var _final_damage = max(1, ceil(_after_resistance - _dr));

                // Apply damage
                hp -= _final_damage;

                // Visual feedback
                image_blend = c_red;
                alarm[0] = 10;

                // Play damage sound
                if (other.sfx_damage != undefined) {
                    play_sfx(other.sfx_damage, 1, false);
                } else {
                    play_sfx(snd_player_hit, 1, false);
                }

                // Spawn damage number
                spawn_damage_number(x, y - 16, _final_damage, other.damage_type, self);

                // Reset combat timer (companion evading)
                combat_timer = 0;

                // Check for death
                if (hp <= 0) {
                    state = PlayerState.dead;
                    play_sfx(snd_player_death, 1, false);
                }
            }
        }

        // Set damage immunity
        damage_immunity_map[? player.id] = damage_immunity_duration;
    }
}

// ==============================
// ON-ENTER EFFECT APPLICATION
// ==============================

// Only apply effect on first entry, not every frame
if (effect_mode == "on_enter" && effect_to_apply != undefined && !already_inside) {
    with (player) {
        if (other.effect_type == "trait") {
            // Apply trait using existing trait system
            // The trait system handles duration, stacking, and refreshing
            apply_timed_trait(other.effect_to_apply, other.effect_duration);
            show_debug_message("Hazard applied trait: " + other.effect_to_apply + " for " + string(other.effect_duration) + "s");
        } else if (other.effect_type == "status") {
            // Apply status effect (burning, wet, slowed, etc.)
            // Status effects have their own built-in durations
            apply_status_effect(other.effect_to_apply);
            show_debug_message("Hazard applied status effect: " + string(other.effect_to_apply));
        }
    }
}
