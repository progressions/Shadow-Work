/// @description Stun and Stagger System
/// Staggered = Cannot move (but can attack/act)
/// Stunned = Cannot attack or take actions (but can move)
/// Both = Fully immobilized

/// @function create_stun_particles(target)
/// @description Ensure the scripted stun stars are set up for the target
/// @param {Id.Instance} target - The instance to attach the stars to
function create_stun_particles(target) {
    if (!instance_exists(target)) return;

    if (!variable_instance_exists(target, "stun_star_state")) {
        target.stun_star_state = undefined;
    }

    if (is_struct(target.stun_star_state)) {
        return;
    }

    var _stars = [];
    var _slots = array_shuffle([-12, 0, 12]);

    for (var i = 0; i < 3; i++) {
        var _slot_x = _slots[i];
        var _star = {
            base_x: _slot_x + random_range(-1.5, 1.5),
            base_y: random_range(-3, 1),
            amplitude: irandom_range(1, 2),
            phase: random_range(0, pi * 2),
            speed: random_range(0.05, 0.12)
        };
        array_push(_stars, _star);
    }

    target.stun_star_state = {
        stars: _stars,
        jitter_timer: irandom_range(0, 30),
        baseline_offset: -12
    };

    stun_stars_ensure_spacing(target.stun_star_state);
}

/// @function stun_stars_ensure_spacing(state)
/// @description Push stars apart so 8x8 sprites don't overlap
/// @param {Struct} state - Stun star state struct
function stun_stars_ensure_spacing(state) {
    if (!is_struct(state)) return;
    if (!variable_struct_exists(state, "stars")) return;

    var _stars = state.stars;
    if (!is_array(_stars) || array_length(_stars) < 2) return;

    var _iterations = 0;
    var _min_sep = 8;

    while (_iterations < 5) {
        var _changed = false;

        for (var i = 0; i < array_length(_stars); i++) {
            var _a = _stars[i];
            if (!is_struct(_a)) continue;

            for (var j = i + 1; j < array_length(_stars); j++) {
                var _b = _stars[j];
                if (!is_struct(_b)) continue;

                var _needed = _min_sep + max(0, _a.amplitude) + max(0, _b.amplitude);
                var _dx = _b.base_x - _a.base_x;
                var _abs_dx = abs(_dx);

                if (_abs_dx < _needed) {
                    var _direction = (_dx >= 0) ? 1 : -1;
                    if (_direction == 0) {
                        _direction = choose(-1, 1);
                    }

                    var _adjust = (_needed - _abs_dx) * 0.5;
                    _a.base_x -= _adjust * _direction;
                    _b.base_x += _adjust * _direction;

                    _a.base_x = clamp(_a.base_x, -16, 16);
                    _b.base_x = clamp(_b.base_x, -16, 16);

                    _stars[i] = _a;
                    _stars[j] = _b;
                    _changed = true;
                }
            }
        }

        if (!_changed) break;
        _iterations += 1;
    }

    state.stars = _stars;
}

/// @function update_stun_particles(target)
/// @description Update the scripted stun stars while the target is disabled
/// @param {Id.Instance} target - The instance with stun stars
function update_stun_particles(target) {
    if (!instance_exists(target)) return;

    var _has_stun = (variable_instance_exists(target, "is_stunned") && target.is_stunned);
    var _has_stagger = (variable_instance_exists(target, "is_staggered") && target.is_staggered);

    if (!_has_stun && !_has_stagger) {
        destroy_stun_particles(target);
        return;
    }

    if (!variable_instance_exists(target, "stun_star_state") || !is_struct(target.stun_star_state)) {
        create_stun_particles(target);
    }

    var _state = target.stun_star_state;
    if (!is_struct(_state)) return;

    if (!is_array(_state.stars) || array_length(_state.stars) == 0) {
        create_stun_particles(target);
        _state = target.stun_star_state;
    }

    var _two_pi = pi * 2;

    for (var i = 0; i < array_length(_state.stars); i++) {
        var _star = _state.stars[i];

        if (!is_struct(_star)) {
            _star = {
                base_x: random_range(-6, 6),
                base_y: random_range(-2, 2),
                amplitude: irandom_range(1, 2),
                phase: random_range(0, _two_pi),
                speed: random_range(0.05, 0.12)
            };
        } else {
            _star.phase += _star.speed;
            if (_star.phase >= _two_pi) {
                _star.phase -= _two_pi;
            }
        }

        _state.stars[i] = _star;
    }

    if (!variable_struct_exists(_state, "jitter_timer")) {
        _state.jitter_timer = 0;
    }

    _state.jitter_timer += 1;
    if (_state.jitter_timer >= 90) {
        _state.jitter_timer = irandom_range(0, 30);
        for (var j = 0; j < array_length(_state.stars); j++) {
            var _jstar = _state.stars[j];
            _jstar.base_x = clamp(_jstar.base_x + random_range(-1, 1), -14, 14);
            _jstar.base_y = clamp(_jstar.base_y + random_range(-0.5, 0.5), -4, 2);
            _state.stars[j] = _jstar;
        }

        stun_stars_ensure_spacing(_state);
    }

    target.stun_star_state = _state;
}

/// @function destroy_stun_particles(target)
/// @description Clear the scripted stun stars from the target
/// @param {Id.Instance} target - The instance to remove the stars from
function destroy_stun_particles(target) {
    if (!instance_exists(target)) return;

    if (!variable_instance_exists(target, "stun_star_state")) return;

    target.stun_star_state = undefined;
}

/// @function cleanup_stun_stars_if_inactive(target)
/// @description Destroy stun stars when both stun and stagger have cleared
/// @param {Id.Instance} target - The instance to evaluate
function cleanup_stun_stars_if_inactive(target) {
    if (!instance_exists(target)) return;

    var _has_stun = (variable_instance_exists(target, "is_stunned") && target.is_stunned);
    var _has_stagger = (variable_instance_exists(target, "is_staggered") && target.is_staggered);

    if (!_has_stun && !_has_stagger) {
        destroy_stun_particles(target);
    }
}

/// @function draw_stun_particles(target)
/// @description Draw the scripted stun stars for the target instance
/// @param {Id.Instance} target - The instance whose stars should be drawn
function draw_stun_particles(target) {
    if (!instance_exists(target)) return;
    if (!variable_instance_exists(target, "stun_star_state")) return;

    var _state = target.stun_star_state;
    if (!is_struct(_state)) return;

    var _stars = _state.stars;
    if (!is_array(_stars) || array_length(_stars) == 0) return;

    if (!sprite_exists(spr_stars)) return;

    var _frame_total = sprite_get_number(spr_stars);

    var _baseline_offset = -8;
    if (variable_struct_exists(_state, "baseline_offset")) {
        _baseline_offset = _state.baseline_offset;
    }

    var _top = target.bbox_top;
    if (_top == 0 && target.sprite_height != undefined) {
        _top = target.y - (target.sprite_height * 0.5);
    }

    var _base_y = _top + _baseline_offset;
    if (variable_instance_exists(target, "y_offset")) {
        _base_y += target.y_offset;
    }

    for (var i = 0; i < array_length(_stars); i++) {
        var _star = _stars[i];
        if (!is_struct(_star)) continue;

        var _phase = _star.phase;
        var _amplitude = _star.amplitude;
        var _x = target.x + _star.base_x + sin(_phase) * _amplitude;
        var _y = _base_y + _star.base_y + cos(_phase * 0.5) * 0.4;
        var _frame = 0;

        if (_frame_total > 1) {
            _frame = (floor(current_time / 120) + i) mod _frame_total;
        }

        draw_sprite_ext(spr_stars, _frame, _x, _y, 1, 1, 0, c_white, 1);
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
    target.stun_timer = _final_duration * game_get_speed(gamespeed_fps);

    // Visual feedback - persistent yellow overlay while stunned
    if (variable_instance_exists(target, "image_blend")) {
        target.image_blend = c_yellow;
    }

    // Play stun sound
    if (target.object_index == obj_player) {
        play_sfx(snd_player_stunned, 1, 5);
    } else if (object_is_ancestor(target.object_index, obj_enemy_parent)) {
        play_sfx(snd_enemy_stunned, 1, 5);
    }

    // Spawn floating text using status effect feedback system
    with (target) {
        status_effect_spawn_feedback("stunned");
    }

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
    target.stagger_timer = _final_duration * game_get_speed(gamespeed_fps);

    // Visual feedback - persistent purple overlay while staggered
    if (variable_instance_exists(target, "image_blend")) {
        target.image_blend = make_color_rgb(160, 32, 240); // Purple for stagger
    }

    // Play stagger sound
    if (target.object_index == obj_player) {
        play_sfx(snd_player_staggered, 1, 5);
    } else if (object_is_ancestor(target.object_index, obj_enemy_parent)) {
        play_sfx(snd_enemy_staggered, 1, 5);
    }

    // Spawn floating text using status effect feedback system
    with (target) {
        status_effect_spawn_feedback("staggered");
    }

    create_stun_particles(target);

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

    cleanup_stun_stars_if_inactive(target);
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

    cleanup_stun_stars_if_inactive(target);
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

    update_stun_particles(target);
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
