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
    part_type_size(_pt, 0.8, 1.2, 0, 0);
    part_type_alpha3(_pt, 0.8, 1, 0);
    part_type_life(_pt, 30, 50); // Particles last 0.5-0.8 seconds
    part_type_speed(_pt, 0.3, 0.6, -0.01, 0);
    part_type_direction(_pt, 60, 120, 0, 5); // Upward and slightly outward
    part_type_gravity(_pt, 0.01, 270); // Slight downward drift

    // Create emitter above target's head
    var _em = part_emitter_create(_ps);
    var _head_y = target.y - target.sprite_height * 0.75; // Above head
    part_emitter_region(_ps, _em, target.x - 4, target.x + 4, _head_y - 4, _head_y + 4, ps_shape_ellipse, ps_distr_gaussian);
    part_emitter_stream(_ps, _em, _pt, -40); // Emit 1 star every 40 frames (~1.5 per second)

    // Store in target instance
    target.stun_particle_system = _ps;
    target.stun_particle_type = _pt;
    target.stun_particle_emitter = _em;
}

/// @function update_stun_particles(target)
/// @description Update particle emitter position to follow target
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

    // Update emitter position to follow target
    var _head_y = target.y - target.sprite_height * 0.75;
    part_emitter_region(target.stun_particle_system, target.stun_particle_emitter,
                       target.x - 4, target.x + 4, _head_y - 4, _head_y + 4,
                       ps_shape_ellipse, ps_distr_gaussian);
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

    // Visual/audio feedback
    if (variable_instance_exists(target, "flash_color")) {
        target.flash_color = c_yellow;
        target.flash_timer = 4;
    }

    // Create stun star particles
    create_stun_particles(target);

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

    // Visual/audio feedback
    if (variable_instance_exists(target, "flash_color")) {
        target.flash_color = c_orange;
        target.flash_timer = 4;
    }

    return true;
}

/// @function clear_stun(target)
/// @description Remove stun effect from target
/// @param {Id.Instance} target - The instance to clear stun from
function clear_stun(target) {
    if (!instance_exists(target)) return;

    target.is_stunned = false;
    target.stun_timer = 0;

    // Destroy stun particles
    destroy_stun_particles(target);
}

/// @function clear_stagger(target)
/// @description Remove stagger effect from target
/// @param {Id.Instance} target - The instance to clear stagger from
function clear_stagger(target) {
    if (!instance_exists(target)) return;

    target.is_staggered = false;
    target.stagger_timer = 0;
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
