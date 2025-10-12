/// @description Stun and Stagger System
/// Staggered = Cannot move (but can attack/act)
/// Stunned = Cannot attack or take actions (but can move)
/// Both = Fully immobilized

/// @function create_stun_particles(target)
/// @description Create particle system for stun stars above target's head
/// @param {Id.Instance} target - The instance to attach particles to
function create_stun_particles(target) {
    if (!instance_exists(target)) return;

    // Clean up any existing particles first to avoid duplicates
    if (variable_instance_exists(target, "stun_particle_system") && target.stun_particle_system != -1) {
        destroy_stun_particles(target);
    }

    // Create particle system
    var _ps = part_system_create();
    part_system_depth(_ps, target.depth - 1); // Above character

    // Create particle type
    var _pt = part_type_create();
    part_type_sprite(_pt, spr_stars, true, false, false);
    part_type_size(_pt, 0.9, 1.1, 0, 0);
    part_type_alpha2(_pt, 1.0, 0.9); // Stay fully visible, slight fade at very end
    part_type_life(_pt, 9999, 9999); // Very long lifetime - destroyed manually when stun ends
    part_type_speed(_pt, 0, 0, 0, 0); // No movement - stay in place
    part_type_direction(_pt, 0, 360, 0, 0); // Direction doesn't matter since speed is 0
    part_type_gravity(_pt, 0, 270); // No gravity

    // Add gentle floating animation
    part_type_orientation(_pt, 0, 360, 0.5, 0, false); // Slow rotation

    // Create emitter above target's head
    var _em = part_emitter_create(_ps);
    var _head_y = target.y - target.sprite_height * 0.75; // Above head
    part_emitter_region(_ps, _em, target.x - 8, target.x + 8, _head_y - 8, _head_y + 8, ps_shape_ellipse, ps_distr_gaussian);

    // Emit 3-5 stars in a burst (one-time emission)
    part_emitter_burst(_ps, _em, _pt, irandom_range(3, 5));

    // Store in target instance
    target.stun_particle_system = _ps;
    target.stun_particle_type = _pt;
    target.stun_particle_emitter = _em;

    // Initialize position tracking for movement detection
    target.stun_particle_last_x = target.x;
    target.stun_particle_last_y = target.y;
}

/// @function update_stun_particles(target)
/// @description Update particle system position to follow target
/// @param {Id.Instance} target - The instance with stun particles
function update_stun_particles(target) {
    if (!instance_exists(target)) return;

    if (!variable_instance_exists(target, "stun_particle_system") || target.stun_particle_system == -1) {
        return;
    }

    // Safety check: verify particle system still exists
    if (!part_system_exists(target.stun_particle_system)) {
        target.stun_particle_system = -1;
        target.stun_particle_type = -1;
        target.stun_particle_emitter = -1;
        return;
    }

    // Safety check: make sure position tracking exists
    if (!variable_instance_exists(target, "stun_particle_last_x") ||
        !variable_instance_exists(target, "stun_particle_last_y")) {
        target.stun_particle_last_x = target.x;
        target.stun_particle_last_y = target.y;
        return;
    }

    // Check if character has moved significantly (more than 2 pixels)
    var _moved = point_distance(target.x, target.y, target.stun_particle_last_x, target.stun_particle_last_y) > 2;

    if (_moved) {
        // Recreate particles at new position
        destroy_stun_particles(target);
        create_stun_particles(target);
    }
}

/// @function destroy_stun_particles(target)
/// @description Clean up particle system for stun stars
/// @param {Id.Instance} target - The instance to remove particles from
function destroy_stun_particles(target) {
    if (!instance_exists(target)) return;

    if (!variable_instance_exists(target, "stun_particle_system")) return;

    if (target.stun_particle_system != -1) {
        // Safety check: only destroy if particle system exists
        if (part_system_exists(target.stun_particle_system)) {
            // Stop emitting new particles
            if (variable_instance_exists(target, "stun_particle_emitter") && target.stun_particle_emitter != -1) {
                part_emitter_destroy(target.stun_particle_system, target.stun_particle_emitter);
            }

            // Clean up particle type
            if (variable_instance_exists(target, "stun_particle_type") && target.stun_particle_type != -1) {
                if (part_type_exists(target.stun_particle_type)) {
                    part_type_destroy(target.stun_particle_type);
                }
            }

            // Destroy particle system (existing particles will fade out naturally)
            part_system_destroy(target.stun_particle_system);
        }

        // Always reset variables even if particle system was already destroyed
        target.stun_particle_system = -1;
        target.stun_particle_type = -1;
        target.stun_particle_emitter = -1;
    }

    // Clean up position tracking variables
    if (variable_instance_exists(target, "stun_particle_last_x")) {
        target.stun_particle_last_x = undefined;
        target.stun_particle_last_y = undefined;
    }
}

/// @function apply_stun(target, duration, source)
/// @description Apply stun effect to target with resistance check
/// @param {Id.Instance} target - The instance to stun
/// @param {Real} duration - Base stun duration in seconds
/// @param {Id.Instance} source - The source of the stun (for logging/effects)
function apply_stun(target, duration, source = noone) {
    if (!instance_exists(target)) return false;

    // Check for stun immunity trait
    if (variable_instance_exists(target, "get_damage_modifier_for_type")) {
        if (target.get_damage_modifier_for_type("stun") == 0) {
            return false; // Immune to stun
        }
    }

    // Apply resistance modifier
    var _resistance = 0;
    if (variable_instance_exists(target, "stun_resistance")) {
        _resistance = target.stun_resistance;
    }

    var _final_duration = duration * (1 - _resistance);

    // Minimum duration check
    if (_final_duration < 0.1) return false;

    // Apply stun
    target.is_stunned = true;
    target.stun_timer = _final_duration * room_speed;

    // Visual feedback - persistent yellow overlay while stunned
    if (variable_instance_exists(target, "image_blend")) {
        target.image_blend = c_yellow;
    }

    // Play stun sound
    if (target.object_index == obj_player) {
        audio_play_sound(snd_player_stunned, 5, false);
    } else if (object_is_ancestor(target.object_index, obj_enemy_parent)) {
        audio_play_sound(snd_enemy_stunned, 5, false);
    }

    // Spawn floating text above target
    var _text_y = target.y - 16;
    if (variable_instance_exists(target, "bbox_top")) {
        _text_y = target.bbox_top - 16;
    }
    spawn_floating_text(target.x, _text_y, "Stunned!", c_yellow, target);

    return true;
}

/// @function apply_stagger(target, duration, source)
/// @description Apply stagger effect to target with resistance check
/// @param {Id.Instance} target - The instance to stagger
/// @param {Real} duration - Base stagger duration in seconds
/// @param {Id.Instance} source - The source of the stagger (for logging/effects)
function apply_stagger(target, duration, source = noone) {
    if (!instance_exists(target)) return false;

    // Check for stagger immunity trait
    if (variable_instance_exists(target, "get_damage_modifier_for_type")) {
        if (target.get_damage_modifier_for_type("stagger") == 0) {
            return false; // Immune to stagger
        }
    }

    // Apply resistance modifier
    var _resistance = 0;
    if (variable_instance_exists(target, "stagger_resistance")) {
        _resistance = target.stagger_resistance;
    }

    var _final_duration = duration * (1 - _resistance);

    // Minimum duration check
    if (_final_duration < 0.1) return false;

    // Apply stagger
    target.is_staggered = true;
    target.stagger_timer = _final_duration * room_speed;

    // Visual feedback - persistent purple overlay while staggered
    if (variable_instance_exists(target, "image_blend")) {
        target.image_blend = make_color_rgb(160, 32, 240); // Purple for stagger
    }

    // Play stagger sound
    if (target.object_index == obj_player) {
        audio_play_sound(snd_player_staggered, 5, false);
    } else if (object_is_ancestor(target.object_index, obj_enemy_parent)) {
        audio_play_sound(snd_enemy_staggered, 5, false);
    }

    // Spawn floating text above target
    var _text_y = target.y - 16;
    if (variable_instance_exists(target, "bbox_top")) {
        _text_y = target.bbox_top - 16;
    }
    spawn_floating_text(target.x, _text_y, "Staggered!", make_color_rgb(160, 32, 240), target);

    return true;
}

/// @function clear_stun(target)
/// @description Remove stun effect from target
/// @param {Id.Instance} target - The instance to clear stun from
function clear_stun(target) {
    if (!instance_exists(target)) return;

    target.is_stunned = false;
    target.stun_timer = 0;

    // Reset image_blend to clear yellow overlay (only if not staggered)
    if (variable_instance_exists(target, "image_blend")) {
        // Only reset to white if not also staggered
        if (!variable_instance_exists(target, "is_staggered") || !target.is_staggered) {
            target.image_blend = c_white;
        } else {
            // Still staggered, reapply stagger color
            target.image_blend = make_color_rgb(160, 32, 240);
        }
    }
}

/// @function clear_stagger(target)
/// @description Remove stagger effect from target
/// @param {Id.Instance} target - The instance to clear stagger from
function clear_stagger(target) {
    if (!instance_exists(target)) return;

    target.is_staggered = false;
    target.stagger_timer = 0;

    // Reset image_blend to clear purple overlay (only if not stunned)
    if (variable_instance_exists(target, "image_blend")) {
        // Only reset to white if not also stunned
        if (!variable_instance_exists(target, "is_stunned") || !target.is_stunned) {
            target.image_blend = c_white;
        } else {
            // Still stunned, reapply stun color
            target.image_blend = c_yellow;
        }
    }
}

/// @function clear_all_cc(target)
/// @description Remove all crowd control effects (stun and stagger)
/// @param {Id.Instance} target - The instance to clear effects from
function clear_all_cc(target) {
    clear_stun(target);
    clear_stagger(target);
}

/// @function roll_stun_chance(chance, resistance)
/// @description Roll for stun with resistance modifier
/// @param {Real} chance - Base chance to stun (0.0 to 1.0)
/// @param {Real} resistance - Target's stun resistance (0.0 to 1.0)
/// @return {Bool} True if stun should be applied
function roll_stun_chance(chance, resistance = 0) {
    var _effective_chance = chance * (1 - resistance);
    return random(1) < _effective_chance;
}

/// @function roll_stagger_chance(chance, resistance)
/// @description Roll for stagger with resistance modifier
/// @param {Real} chance - Base chance to stagger (0.0 to 1.0)
/// @param {Real} resistance - Target's stagger resistance (0.0 to 1.0)
/// @return {Bool} True if stagger should be applied
function roll_stagger_chance(chance, resistance = 0) {
    var _effective_chance = chance * (1 - resistance);
    return random(1) < _effective_chance;
}

/// @function is_fully_immobilized(target)
/// @description Check if target is both stunned and staggered (fully immobilized)
/// @param {Id.Instance} target - The instance to check
/// @return {Bool} True if both stunned and staggered
function is_fully_immobilized(target) {
    if (!instance_exists(target)) return false;

    return target.is_stunned && target.is_staggered;
}

/// @function update_stun_stagger_timers(target)
/// @description Update stun and stagger timers (call in Step event)
/// @param {Id.Instance} target - The instance to update
function update_stun_stagger_timers(target) {
    if (!instance_exists(target)) return;

    // Update stun timer
    if (target.is_stunned) {
        target.stun_timer -= 1;
        if (target.stun_timer <= 0) {
            clear_stun(target);
        }
    }

    // Update stagger timer
    if (target.is_staggered) {
        target.stagger_timer -= 1;
        if (target.stagger_timer <= 0) {
            clear_stagger(target);
        }
    }
}

/// @function get_weapon_stun_chance(weapon_stats)
/// @description Get stun chance from weapon stats with default fallback
/// @param {Struct} weapon_stats - Weapon stats struct
/// @return {Real} Stun chance (0.0 to 1.0)
function get_weapon_stun_chance(weapon_stats) {
    if (is_undefined(weapon_stats)) return 0.05; // Default 5%

    if (variable_struct_exists(weapon_stats, "chance_to_stun")) {
        return weapon_stats.chance_to_stun;
    }

    return 0.05; // Default 5%
}

/// @function get_weapon_stagger_chance(weapon_stats)
/// @description Get stagger chance from weapon stats with default fallback
/// @param {Struct} weapon_stats - Weapon stats struct
/// @return {Real} Stagger chance (0.0 to 1.0)
function get_weapon_stagger_chance(weapon_stats) {
    if (is_undefined(weapon_stats)) return 0.10; // Default 10%

    if (variable_struct_exists(weapon_stats, "chance_to_stagger")) {
        return weapon_stats.chance_to_stagger;
    }

    return 0.10; // Default 10%
}

/// @function get_weapon_stun_duration(weapon_stats)
/// @description Get stun duration from weapon stats with default fallback
/// @param {Struct} weapon_stats - Weapon stats struct
/// @return {Real} Stun duration in seconds
function get_weapon_stun_duration(weapon_stats) {
    if (is_undefined(weapon_stats)) return 1.5; // Default 1.5s

    if (variable_struct_exists(weapon_stats, "stun_duration")) {
        return weapon_stats.stun_duration;
    }

    return 1.5; // Default 1.5s
}

/// @function get_weapon_stagger_duration(weapon_stats)
/// @description Get stagger duration from weapon stats with default fallback
/// @param {Struct} weapon_stats - Weapon stats struct
/// @return {Real} Stagger duration in seconds
function get_weapon_stagger_duration(weapon_stats) {
    if (is_undefined(weapon_stats)) return 1.0; // Default 1.0s

    if (variable_struct_exists(weapon_stats, "stagger_duration")) {
        return weapon_stats.stagger_duration;
    }

    return 1.0; // Default 1.0s
}

/// @function process_attack_cc_effects(attacker, target, attack_stats)
/// @description Process stun/stagger effects from an attack
/// @param {Id.Instance} attacker - The attacking instance
/// @param {Id.Instance} target - The target instance
/// @param {Struct} attack_stats - Attack stats struct with CC properties
function process_attack_cc_effects(attacker, target, attack_stats) {
    if (!instance_exists(target)) return;
    if (is_undefined(attack_stats)) return;

    // Get target resistances
    var _stun_resistance = 0;
    var _stagger_resistance = 0;

    if (variable_instance_exists(target, "stun_resistance")) {
        _stun_resistance = target.stun_resistance;
    }
    if (variable_instance_exists(target, "stagger_resistance")) {
        _stagger_resistance = target.stagger_resistance;
    }

    // Roll for stun
    var _stun_chance = get_weapon_stun_chance(attack_stats);
    if (roll_stun_chance(_stun_chance, _stun_resistance)) {
        var _stun_duration = get_weapon_stun_duration(attack_stats);
        apply_stun(target, _stun_duration, attacker);
    }

    // Roll for stagger
    var _stagger_chance = get_weapon_stagger_chance(attack_stats);
    if (roll_stagger_chance(_stagger_chance, _stagger_resistance)) {
        var _stagger_duration = get_weapon_stagger_duration(attack_stats);
        apply_stagger(target, _stagger_duration, attacker);
    }
}
