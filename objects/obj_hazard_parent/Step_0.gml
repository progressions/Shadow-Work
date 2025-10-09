/// obj_hazard_parent : Step Event
/// Update timers and apply continuous damage

if (global.game_paused) exit;

// ==============================
// CLEAN UP ENTITIES THAT LEFT
// ==============================

// Remove entities that are no longer colliding (handles cases where collision end doesn't fire)
for (var i = ds_list_size(entities_inside) - 1; i >= 0; i--) {
    var entity_id = entities_inside[| i];

    if (!instance_exists(entity_id) || !place_meeting(x, y, entity_id)) {
        ds_list_delete(entities_inside, i);
        show_debug_message("[HAZARD CLEANUP] Removed entity from tracking (no longer colliding)");
    }
}

// ==============================
// UPDATE DAMAGE IMMUNITY TIMERS
// ==============================

// Decrement all damage immunity timers
var immunity_keys = ds_map_keys_to_array(damage_immunity_map);
for (var i = 0; i < array_length(immunity_keys); i++) {
    var entity_id = immunity_keys[i];
    var timer = damage_immunity_map[? entity_id];

    if (timer > 0) {
        timer -= delta_time / 1000000; // Convert microseconds to seconds

        if (timer <= 0) {
            ds_map_delete(damage_immunity_map, entity_id);
        } else {
            damage_immunity_map[? entity_id] = timer;
        }
    }
}

// ==============================
// UPDATE EFFECT IMMUNITY TIMERS
// ==============================

// Decrement all effect immunity timers
var effect_immunity_keys = ds_map_keys_to_array(effect_immunity_map);
for (var i = 0; i < array_length(effect_immunity_keys); i++) {
    var entity_id = effect_immunity_keys[i];
    var timer = effect_immunity_map[? entity_id];

    if (timer > 0) {
        timer -= delta_time / 1000000; // Convert microseconds to seconds

        if (timer <= 0) {
            ds_map_delete(effect_immunity_map, entity_id);
        } else {
            effect_immunity_map[? entity_id] = timer;
        }
    }
}

// ==============================
// CONTINUOUS DAMAGE MODE
// ==============================

if (damage_mode == "continuous" && damage_amount > 0) {
    // Update damage timer
    continuous_damage_timer += delta_time / 1000000; // Convert to seconds

    // Check if it's time to apply damage
    if (continuous_damage_timer >= damage_interval) {
        continuous_damage_timer = 0; // Reset timer

        // Apply damage to all entities currently inside
        for (var i = 0; i < ds_list_size(entities_inside); i++) {
            var entity_id = entities_inside[| i];

            // Check if entity still exists
            if (!instance_exists(entity_id)) {
                ds_list_delete(entities_inside, i);
                i--; // Adjust index after deletion
                continue;
            }

            // Check damage immunity
            var has_immunity = ds_map_exists(damage_immunity_map, entity_id);
            if (has_immunity) {
                continue; // Skip this entity
            }

            var entity = entity_id;

            // Apply damage using entity's damage pipeline
            with (entity) {
                // Get damage modifier from traits
                var _resistance_multiplier = get_damage_modifier_for_type(other.damage_type);

                // Check for immunity - skip if immune
                if (_resistance_multiplier > 0) {
                    // Calculate final damage
                    var _base_damage = other.damage_amount;
                    var _after_resistance = _base_damage * _resistance_multiplier;

                    // Apply DR if entity has it
                    var _dr = 0;
                    if (object_index == obj_player) {
                        // Player has both equipment DR and companion DR
                        // Check if functions exist before calling
                        if (variable_instance_exists(id, "get_equipment_general_dr")) {
                            _dr += get_equipment_general_dr();
                        }
                        if (variable_instance_exists(id, "get_companion_dr_bonus")) {
                            _dr += get_companion_dr_bonus();
                        }
                    } else if (object_is_ancestor(object_index, obj_enemy_parent)) {
                        // Enemies use melee DR for environmental hazards
                        if (variable_instance_exists(id, "melee_damage_resistance")) {
                            _dr = melee_damage_resistance;
                        }
                    }

                    var _final_damage = max(1, ceil(_after_resistance - _dr));

                    // Apply damage
                    hp -= _final_damage;

                    // Visual feedback
                    image_blend = c_red;
                    alarm[0] = 10; // Flash duration

                    // Play damage sound
                    if (other.sfx_damage != undefined) {
                        play_sfx(other.sfx_damage, 1, false);
                    } else {
                        play_sfx(snd_player_hit, 1, false);
                    }

                    // Spawn damage number
                    spawn_damage_number(x, y - 16, _final_damage, other.damage_type, self);

                    // Reset combat timer for player (companion evading)
                    if (object_index == obj_player) {
                        combat_timer = 0;
                    }

                    // Check for death
                    if (hp <= 0) {
                        if (object_index == obj_player) {
                            state = PlayerState.dead;
                            play_sfx(snd_player_death, 1, false);
                        } else if (object_is_ancestor(object_index, obj_enemy_parent)) {
                            state = EnemyState.dead;
                            play_enemy_sfx("on_death");
                        }
                    }
                    // Set damage immunity timer only when damage is applied
                    other.damage_immunity_map[? id] = other.damage_immunity_duration;
                } else {
                    // Entity is immune to this damage type
                    play_sfx(snd_attack_miss, 1, false);
                    spawn_immune_text(x, y - 16, self);
                }
            }
        }
    }
}
