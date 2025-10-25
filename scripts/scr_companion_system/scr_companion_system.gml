// ============================================
// COMPANION SYSTEM - Helper functions for companion management
// ============================================

/// @function get_companion_by_name(companion_name)
/// @description Find a companion instance by their name (case-insensitive)
/// @param {string} companion_name The companion's name ("Canopy", "Hola", "Yorna")
/// @return {Id.Instance} The companion instance, or noone if not found
function get_companion_by_name(companion_name) {
    if (companion_name == undefined) return noone;

    // Normalize to lowercase for case-insensitive comparison
    var _search_name = string_lower(companion_name);

    // Search all companion instances
    with (obj_companion_parent) {
        if (string_lower(companion_name) == _search_name) {
            return id;
        }
    }

    return noone;
}

/// @function get_affinity_aura_multiplier(affinity)
/// @description Calculate aura effectiveness multiplier based on affinity level
/// @param {real} affinity The companion's affinity level (3.0 to 10.0)
/// @return {real} Multiplier for aura effectiveness (0.6x at affinity 3.0, 3.0x at affinity 10.0)
function get_affinity_aura_multiplier(affinity) {
    // Normalized affinity from 0-1 based on range 3.0-10.0
    var normalized = clamp((affinity - 3.0) / 7.0, 0, 1);

    // Diminishing returns curve: 0.6 + (2.4 * sqrt(normalized))
    // sqrt provides diminishing returns - early gains are stronger
    var multiplier = 0.6 + (2.4 * sqrt(normalized));

    return multiplier;
}

/// @function get_active_companions()
/// @description Returns array of active companion instances
function get_active_companions() {
    var companions = [];
    with (obj_companion_parent) {
        if (is_recruited && (state == CompanionState.following || state == CompanionState.evading)) {
            array_push(companions, id);
        }
    }
    // show_debug_message("get_active_companions returned " + string(array_length(companions)) + " companions");
    return companions;
}

/// @function get_companion_melee_dr_bonus()
/// @description Calculate total melee DR bonus from all active companions
function get_companion_melee_dr_bonus() {
    var total_dr = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Get affinity multiplier for scaling aura values
        var multiplier = get_affinity_aura_multiplier(companion.affinity);

        // Check all auras for melee DR bonuses
        var _aura_names = variable_struct_get_names(companion.auras);
        for (var j = 0; j < array_length(_aura_names); j++) {
            var _aura_name = _aura_names[j];
            var _aura = companion.auras[$ _aura_name];

            if (_aura.active) {
                // General DR bonus (scaled by affinity)
                if (variable_struct_exists(_aura, "dr_bonus")) {
                    total_dr += _aura.dr_bonus * multiplier;
                }
                // General DR applies to melee (scaled by affinity)
                if (variable_struct_exists(_aura, "damage_reduction")) {
                    total_dr += _aura.damage_reduction * multiplier;
                }
                // Melee-specific DR (scaled by affinity)
                if (variable_struct_exists(_aura, "melee_damage_reduction")) {
                    total_dr += _aura.melee_damage_reduction * multiplier;
                }
            }
        }

        // Check triggers for melee DR bonuses (not scaled - triggers use affinity-based unlocks)
        var _trigger_names = variable_struct_get_names(companion.triggers);
        for (var j = 0; j < array_length(_trigger_names); j++) {
            var _trigger_name = _trigger_names[j];
            var _trigger = companion.triggers[$ _trigger_name];

            if (_trigger.active) {
                if (variable_struct_exists(_trigger, "damage_reduction")) {
                    total_dr += _trigger.damage_reduction;
                }
                if (variable_struct_exists(_trigger, "melee_damage_reduction")) {
                    total_dr += _trigger.melee_damage_reduction;
                }
                if (variable_struct_exists(_trigger, "dr_bonus")) {
                    total_dr += _trigger.dr_bonus;
                }
            }
        }
    }

    return total_dr;
}

/// @function get_companion_ranged_dr_bonus()
/// @description Calculate total ranged DR bonus from all active companions
function get_companion_ranged_dr_bonus() {
    var total_dr = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Get affinity multiplier for scaling aura values
        var multiplier = get_affinity_aura_multiplier(companion.affinity);

        // Check all auras for ranged DR bonuses
        var _aura_names = variable_struct_get_names(companion.auras);
        for (var j = 0; j < array_length(_aura_names); j++) {
            var _aura_name = _aura_names[j];
            var _aura = companion.auras[$ _aura_name];

            if (_aura.active) {
                // General DR bonus (scaled by affinity)
                if (variable_struct_exists(_aura, "dr_bonus")) {
                    total_dr += _aura.dr_bonus * multiplier;
                }
                // General DR applies to ranged (scaled by affinity)
                if (variable_struct_exists(_aura, "damage_reduction")) {
                    total_dr += _aura.damage_reduction * multiplier;
                }
                // Ranged-specific DR (Hola's wind_ward uses this, scaled by affinity)
                if (variable_struct_exists(_aura, "ranged_damage_reduction")) {
                    total_dr += _aura.ranged_damage_reduction * multiplier;
                }
            }
        }

        // Check triggers for ranged DR bonuses (not scaled - triggers use affinity-based unlocks)
        var _trigger_names = variable_struct_get_names(companion.triggers);
        for (var j = 0; j < array_length(_trigger_names); j++) {
            var _trigger_name = _trigger_names[j];
            var _trigger = companion.triggers[$ _trigger_name];

            if (_trigger.active) {
                if (variable_struct_exists(_trigger, "damage_reduction")) {
                    total_dr += _trigger.damage_reduction;
                }
                if (variable_struct_exists(_trigger, "ranged_damage_reduction")) {
                    total_dr += _trigger.ranged_damage_reduction;
                }
                if (variable_struct_exists(_trigger, "dr_bonus")) {
                    total_dr += _trigger.dr_bonus;
                }
            }
        }
    }

    return total_dr;
}

/// @function get_companion_attack_bonus()
/// @description Calculate total attack damage bonus from all active companions
function get_companion_attack_bonus() {
    var total_attack = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Get affinity multiplier for scaling aura values
        var multiplier = get_affinity_aura_multiplier(companion.affinity);

        // Check all auras for attack bonuses
        var _aura_names = variable_struct_get_names(companion.auras);
        for (var j = 0; j < array_length(_aura_names); j++) {
            var _aura_name = _aura_names[j];
            var _aura = companion.auras[$ _aura_name];

            if (_aura.active) {
                // Attack bonus (Yorna's warriors_presence uses this, scaled by affinity)
                if (variable_struct_exists(_aura, "attack_bonus")) {
                    total_attack += _aura.attack_bonus * multiplier;
                }
            }
        }
    }

    return total_attack;
}

/// @function get_companion_range_bonus()
/// @description Calculate total attack range bonus from all active companions
function get_companion_range_bonus() {
    var total_range = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Get affinity multiplier for scaling aura values
        var multiplier = get_affinity_aura_multiplier(companion.affinity);

        // Check all auras for range bonuses
        var _aura_names = variable_struct_get_names(companion.auras);
        for (var j = 0; j < array_length(_aura_names); j++) {
            var _aura_name = _aura_names[j];
            var _aura = companion.auras[$ _aura_name];

            if (_aura.active) {
                // Range bonus (Yorna's warriors_presence uses this, scaled by affinity)
                if (variable_struct_exists(_aura, "range_bonus")) {
                    total_range += _aura.range_bonus * multiplier;
                }
            }
        }
    }

    return total_range;
}

/// @function get_execution_window_multiplier()
/// @description Check if any companion has Execution Window active and return damage multiplier
/// @return {real} Damage multiplier (1.0 if not active, 2.0 if active)
function get_execution_window_multiplier() {
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Check for Execution Window trigger (Yorna affinity 10)
        if (variable_struct_exists(companion.triggers, "execution_window")) {
            var trigger = companion.triggers.execution_window;

            if (trigger.active && variable_instance_exists(companion, "execution_window_timer") && companion.execution_window_timer > 0) {
                return trigger.damage_multiplier; // Should be 2.0
            }
        }
    }

    return 1.0; // No execution window active
}

/// @function get_execution_window_armor_pierce()
/// @description Check if any companion has Execution Window active and return armor pierce amount
/// @return {real} Armor pierce amount (0 if not active, 3 if active)
function get_execution_window_armor_pierce() {
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Check for Execution Window trigger (Yorna affinity 10)
        if (variable_struct_exists(companion.triggers, "execution_window")) {
            var trigger = companion.triggers.execution_window;

            if (trigger.active && variable_instance_exists(companion, "execution_window_timer") && companion.execution_window_timer > 0) {
                return trigger.armor_pierce; // Should be 3
            }
        }
    }

    return 0; // No execution window active
}

/// @function get_companion_multi_target_params()
/// @description Calculate multi-target attack parameters from companions (Yorna's aura)
/// @return {struct} Returns {max_targets: number, chance: number} or undefined if no multi-target
function get_companion_multi_target_params() {
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Check for multi-target auras (Yorna's warriors_presence)
        var _aura_names = variable_struct_get_names(companion.auras);
        for (var j = 0; j < array_length(_aura_names); j++) {
            var _aura_name = _aura_names[j];
            var _aura = companion.auras[$ _aura_name];

            if (_aura.active && variable_struct_exists(_aura, "multi_target_thresholds")) {
                var thresholds = _aura.multi_target_thresholds;
                var affinity = companion.affinity;

                // Find highest threshold that companion meets
                var best_threshold = undefined;
                for (var k = 0; k < array_length(thresholds); k++) {
                    var threshold = thresholds[k];
                    if (affinity >= threshold.min_affinity) {
                        best_threshold = threshold;
                    }
                }

                // Return the best threshold found
                if (best_threshold != undefined) {
                    return {
                        max_targets: best_threshold.max_targets,
                        chance: best_threshold.chance
                    };
                }
            }
        }
    }

    return undefined; // No multi-target auras active
}

/// @function get_companion_enemy_slow(enemy_x, enemy_y)
/// @description Get enemy speed slow multiplier from companion auras (e.g., Hola's slowing aura)
/// @param {real} enemy_x Enemy x position
/// @param {real} enemy_y Enemy y position
/// @return {real} Speed multiplier (0.0-1.0, where 0.5 = 50% slow, 1.0 = normal speed)
function get_companion_enemy_slow(enemy_x, enemy_y) {
    var total_slow = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Get affinity multiplier for scaling aura values
        var multiplier = get_affinity_aura_multiplier(companion.affinity);

        // Check all auras for slowing effects
        var _aura_names = variable_struct_get_names(companion.auras);
        for (var j = 0; j < array_length(_aura_names); j++) {
            var _aura = companion.auras[$ _aura_names[j]];

            if (_aura.active && variable_struct_exists(_aura, "slow_percent")) {
                // Check radius if defined (otherwise apply globally)
                if (variable_struct_exists(_aura, "radius")) {
                    var dist = point_distance(enemy_x, enemy_y, obj_player.x, obj_player.y);
                    if (dist > _aura.radius) continue; // Outside radius, skip this aura
                }

                // Apply scaled slow percentage
                total_slow += _aura.slow_percent * multiplier;
            }
        }
    }

    // Return speed multiplier (clamped to prevent negative or zero speed)
    // total_slow of 0.5 = 50% slow = speed multiplier 0.5
    return clamp(1.0 - total_slow, 0.1, 1.0);
}

/// @function get_companion_dash_cd_reduction()
/// @description Get total dash cooldown reduction from companion auras and triggers
/// @return {real} Cooldown reduction multiplier (additive, e.g., 0.2 = 20% faster recovery)
function get_companion_dash_cd_reduction() {
    var total_reduction = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Get affinity multiplier for scaling aura values
        var multiplier = get_affinity_aura_multiplier(companion.affinity);

        // Check all auras for dash cooldown reduction
        var _aura_names = variable_struct_get_names(companion.auras);
        for (var j = 0; j < array_length(_aura_names); j++) {
            var _aura = companion.auras[$ _aura_names[j]];

            if (_aura.active && variable_struct_exists(_aura, "dash_cd_reduction")) {
                // Passive auras scale with affinity
                total_reduction += _aura.dash_cd_reduction * multiplier;
            }
        }

        // Also check triggers for active dash CD boosts (triggers don't scale with affinity)
        var _trigger_names = variable_struct_get_names(companion.triggers);
        for (var j = 0; j < array_length(_trigger_names); j++) {
            var _trigger = companion.triggers[$ _trigger_names[j]];

            if (_trigger.active && variable_struct_exists(_trigger, "dash_cd_boost")) {
                // Check if there's a timer variable for this trigger
                var timer_var = _trigger_names[j] + "_timer";
                if (variable_instance_exists(companion, timer_var)) {
                    if (companion[$ timer_var] > 0) {
                        total_reduction += _trigger.dash_cd_boost;
                    }
                } else {
                    // No timer check needed, trigger is just active
                    total_reduction += _trigger.dash_cd_boost;
                }
            }
        }
    }

    return total_reduction;
}

/// @function get_companion_deflection_bonus(companion_id)
/// @description Get total projectile deflection bonus from companion triggers
/// @param {string} companion_id Optional: specific companion to check (e.g., "hola"), or undefined for all
/// @return {real} Deflection chance bonus (0.0-1.0, e.g., 0.25 = +25% deflection)
function get_companion_deflection_bonus(companion_id = undefined) {
    var total_deflection = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Filter by companion_id if specified
        if (companion_id != undefined && companion.companion_id != companion_id) {
            continue;
        }

        // Check for active deflection bonuses from triggers (e.g., Hola's Maelstrom)
        var _trigger_names = variable_struct_get_names(companion.triggers);
        for (var j = 0; j < array_length(_trigger_names); j++) {
            var _trigger = companion.triggers[$ _trigger_names[j]];

            if (_trigger.active && variable_struct_exists(_trigger, "deflect_bonus")) {
                // Check for corresponding timer variable (e.g., maelstrom_deflect_timer)
                var timer_var = _trigger_names[j] + "_deflect_timer";
                if (variable_instance_exists(companion, timer_var)) {
                    if (companion[$ timer_var] > 0) {
                        total_deflection += _trigger.deflect_bonus;
                    }
                } else {
                    // No timer, just check if trigger is active
                    total_deflection += _trigger.deflect_bonus;
                }
            }
        }
    }

    return total_deflection;
}

/// @function apply_companion_regeneration_auras(player_instance)
/// @description Apply HP regeneration from companion auras
/// @param {Id.Instance} player_instance The player to heal
function apply_companion_regeneration_auras(player_instance) {
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Apply regeneration aura (only if companion has this aura)
        if (variable_struct_exists(companion.auras, "regeneration") && companion.auras.regeneration.active) {
            if (!variable_instance_exists(player_instance, "companion_regen_timer")) {
                player_instance.companion_regen_timer = 0;
            }

            player_instance.companion_regen_timer++;

            if (player_instance.companion_regen_timer >= companion.auras.regeneration.tick_interval) {
                // Scale regeneration by affinity multiplier
                var base_regen = companion.auras.regeneration.hp_per_tick;
                var multiplier = get_affinity_aura_multiplier(companion.affinity);
                var scaled_regen = base_regen * multiplier;

                player_instance.hp = min(
                    player_instance.hp + scaled_regen,
                    player_instance.hp_total
                );
                player_instance.companion_regen_timer = 0;
            }
        }
    }
}

function companion_play_trigger_sfx(_companion_instance, _trigger_name) {
    if (_companion_instance == undefined || _companion_instance == noone) {
        return;
    }

    // Ensure SFX audio group is available before attempting playback
    if (!audio_group_is_loaded(audiogroup_sfx_world)) {
        audio_group_load(audiogroup_sfx_world);
    }

    var _resolve_sound = function(_candidate) {
        if (_candidate == undefined || _candidate == noone) {
            return undefined;
        }

        // Leave strings as-is so play_sfx() can handle variant randomization
        if (is_string(_candidate)) {
            return _candidate;
        }

        return _candidate;
    };

    var _sound = undefined;

    if (variable_struct_exists(_companion_instance.triggers, _trigger_name)) {
        var _trigger = _companion_instance.triggers[$ _trigger_name];
        if (variable_struct_exists(_trigger, "sfx_trigger_sound")) {
            _sound = _resolve_sound(_trigger.sfx_trigger_sound);
        }
    }

    if (_sound == undefined && variable_instance_exists(_companion_instance, "sfx_trigger_sound")) {
        _sound = _resolve_sound(_companion_instance.sfx_trigger_sound);
    }

    if (_sound == undefined) {
        _sound = _resolve_sound(snd_companion_trigger_activate);
    }

    var _companion_id = "unknown";
    if (variable_instance_exists(_companion_instance, "companion_id")) {
        _companion_id = _companion_instance.companion_id;
    }

    show_debug_message("Trigger activated: " + _companion_id + "." + string(_trigger_name));

    if (_sound != undefined) {
        play_sfx(_sound, 1, 8, false);
    } else if (variable_global_exists("debug_mode") && global.debug_damage_reduction) {
        show_debug_message("No trigger sound found for " + _companion_id + "." + string(_trigger_name));
    }
}

/// @function evaluate_companion_triggers(player_instance)
/// @description Check and activate companion triggers based on game state
/// @param {Id.Instance} player_instance The player to check conditions for
function evaluate_companion_triggers(player_instance) {
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // CANOPY: Shield Trigger - Activate when player HP is low
        if (variable_struct_exists(companion.triggers, "shield")) {
            if (companion.triggers.shield.unlocked &&
                !companion.triggers.shield.active &&
                companion.triggers.shield.cooldown == 0) {

                var hp_percent = player_instance.hp / player_instance.hp_total;

                if (hp_percent <= companion.triggers.shield.hp_threshold) {
                    // Enter casting state
                    companion.previous_state = companion.state;
                    companion.state = CompanionState.casting;
                    companion.casting_frame_index = 0;
                    companion.casting_timer = 0;

                    companion.triggers.shield.active = true;
                    companion.triggers.shield.cooldown = companion.triggers.shield.cooldown_max;
                    companion.shield_timer = companion.triggers.shield.duration;

                    // Slow-motion on trigger activation
                    activate_slowmo(0.5);

                    // Visual impact effects
                    spawn_floating_text(companion.x, companion.bbox_top - 10, "Shield!", c_aqua, companion);
                    spawn_floating_text(companion.x - 10, companion.bbox_top - 22, "✦", c_yellow, companion);
                    spawn_floating_text(companion.x + 10, companion.bbox_top - 22, "✦", c_yellow, companion);

                    companion_play_trigger_sfx(companion, "shield");
                }
            }

            // Update shield duration
            if (companion.triggers.shield.active) {
                if (!variable_instance_exists(companion, "shield_timer")) companion.shield_timer = 0;
                companion.shield_timer--;
                if (companion.shield_timer <= 0) companion.triggers.shield.active = false;
            }
        }

        // CANOPY: Guardian Veil - Activate when surrounded
        if (variable_struct_exists(companion.triggers, "guardian_veil")) {
            if (companion.triggers.guardian_veil.unlocked &&
                !companion.triggers.guardian_veil.active &&
                companion.triggers.guardian_veil.cooldown == 0) {

                var nearby_enemies = 0;
                with (obj_enemy_parent) {
                    if (state != EnemyState.dead &&
                        point_distance(x, y, player_instance.x, player_instance.y) < 64) {
                        nearby_enemies++;
                    }
                }

                if (nearby_enemies >= companion.triggers.guardian_veil.enemy_threshold) {
                    // Enter casting state
                    companion.previous_state = companion.state;
                    companion.state = CompanionState.casting;
                    companion.casting_frame_index = 0;
                    companion.casting_timer = 0;

                    companion.triggers.guardian_veil.active = true;
                    companion.triggers.guardian_veil.cooldown = companion.triggers.guardian_veil.cooldown_max;
                    companion.guardian_veil_timer = companion.triggers.guardian_veil.duration;

                    // Slow-motion on trigger activation
                    activate_slowmo(0.5);

                    companion_play_trigger_sfx(companion, "guardian_veil");
                }
            }

            // Update guardian veil duration
            if (companion.triggers.guardian_veil.active) {
                if (!variable_instance_exists(companion, "guardian_veil_timer")) companion.guardian_veil_timer = 0;
                companion.guardian_veil_timer--;
                if (companion.guardian_veil_timer <= 0) companion.triggers.guardian_veil.active = false;
            }
        }

        // CANOPY: Aegis duration management
        if (variable_struct_exists(companion.triggers, "aegis")) {
            if (companion.triggers.aegis.active) {
                if (!variable_instance_exists(companion, "aegis_timer")) companion.aegis_timer = 0;
                companion.aegis_timer--;
                if (companion.aegis_timer <= 0) companion.triggers.aegis.active = false;
            }
        }

        // CANOPY: Dash Mend short-lived state
        if (variable_struct_exists(companion.triggers, "dash_mend")) {
            if (companion.triggers.dash_mend.active) {
                if (!variable_instance_exists(companion, "dash_mend_timer")) companion.dash_mend_timer = 0;
                companion.dash_mend_timer--;
                if (companion.dash_mend_timer <= 0) companion.triggers.dash_mend.active = false;
            }
        }

        // YORNA: Execution Window duration management
        if (variable_struct_exists(companion.triggers, "execution_window")) {
            if (companion.triggers.execution_window.active) {
                if (!variable_instance_exists(companion, "execution_window_timer")) companion.execution_window_timer = 0;
                companion.execution_window_timer--;
                if (companion.execution_window_timer <= 0) companion.triggers.execution_window.active = false;
            }
        }

        // HOLA: Slipstream Boost duration management
        if (variable_struct_exists(companion.triggers, "slipstream_boost")) {
            if (companion.triggers.slipstream_boost.active) {
                if (!variable_instance_exists(companion, "slipstream_boost_timer")) companion.slipstream_boost_timer = 0;
                companion.slipstream_boost_timer--;
                if (companion.slipstream_boost_timer <= 0) companion.triggers.slipstream_boost.active = false;
            }
        }

        // HOLA: Maelstrom deflection bonus duration management
        if (variable_struct_exists(companion.triggers, "maelstrom")) {
            if (companion.triggers.maelstrom.active) {
                if (!variable_instance_exists(companion, "maelstrom_deflect_timer")) companion.maelstrom_deflect_timer = 0;
                companion.maelstrom_deflect_timer--;
                if (companion.maelstrom_deflect_timer <= 0) companion.triggers.maelstrom.active = false;
            }
        }

        // HOLA: Gust - Push back nearby enemies
        if (variable_struct_exists(companion.triggers, "gust")) {
            if (companion.triggers.gust.unlocked &&
                !companion.triggers.gust.active &&
                companion.triggers.gust.cooldown == 0) {

                var nearby_enemies = 0;
                with (obj_enemy_parent) {
                    if (state != EnemyState.dead &&
                        point_distance(x, y, player_instance.x, player_instance.y) < companion.triggers.gust.trigger_distance) {
                        nearby_enemies++;
                    }
                }

                if (nearby_enemies >= companion.triggers.gust.enemy_threshold) {
                    // Enter casting state
                    companion.previous_state = companion.state;
                    companion.state = CompanionState.casting;
                    companion.casting_frame_index = 0;
                    companion.casting_timer = 0;

                    companion.triggers.gust.active = true;
                    companion.triggers.gust.cooldown = companion.triggers.gust.cooldown_max;

                    // Slow-motion on trigger activation
                    activate_slowmo(0.5);

                    // Push back enemies
                    with (obj_enemy_parent) {
                        if (state != EnemyState.dead &&
                            point_distance(x, y, player_instance.x, player_instance.y) < companion.triggers.gust.trigger_distance) {
                            var push_dir = point_direction(player_instance.x, player_instance.y, x, y);
                            x += lengthdir_x(companion.triggers.gust.knockback_distance, push_dir);
                            y += lengthdir_y(companion.triggers.gust.knockback_distance, push_dir);
                        }
                    }
                    spawn_floating_text(player_instance.x, player_instance.bbox_top - 10, "Gust!", c_white, player_instance);
                    companion_play_trigger_sfx(companion, "gust");
                }
            }
        }

        // HOLA: Maelstrom - Powerful AoE knockback, slow, and deflection boost (affinity 10)
        if (variable_struct_exists(companion.triggers, "maelstrom")) {
            if (companion.triggers.maelstrom.unlocked &&
                companion.triggers.maelstrom.cooldown == 0 &&
                companion.state != CompanionState.casting) {

                // Capture trigger radius before with block
                var _trigger_radius = companion.triggers.maelstrom.radius;

                var nearby_enemies = 0;
                with (obj_enemy_parent) {
                    if (state != EnemyState.dead &&
                        point_distance(x, y, player_instance.x, player_instance.y) < _trigger_radius) {
                        nearby_enemies++;
                    }
                }

                if (nearby_enemies >= companion.triggers.maelstrom.enemy_threshold) {
                    // Enter casting state
                    companion.previous_state = companion.state;
                    companion.state = CompanionState.casting;
                    companion.casting_frame_index = 0;
                    companion.casting_timer = 0;

                    companion.triggers.maelstrom.active = true;
                    companion.triggers.maelstrom.cooldown = companion.triggers.maelstrom.cooldown_max;
                    companion.maelstrom_deflect_timer = companion.triggers.maelstrom.deflect_duration;

                    // Slow-motion on trigger activation
                    activate_slowmo(0.5);

                    // Capture trigger values before with block
                    var _radius = companion.triggers.maelstrom.radius;
                    var _knockback = companion.triggers.maelstrom.knockback_distance;
                    var _enemies_affected = 0;

                    // Apply knockback and slow to all nearby enemies
                    with (obj_enemy_parent) {
                        if (state != EnemyState.dead &&
                            point_distance(x, y, player_instance.x, player_instance.y) < _radius) {
                            // Knockback
                            var push_dir = point_direction(player_instance.x, player_instance.y, x, y);
                            x += lengthdir_x(_knockback, push_dir);
                            y += lengthdir_y(_knockback, push_dir);

                            // Apply slow status effect
                            apply_status_effect("slowed");

                            _enemies_affected++;

                            // Visual feedback on enemy
                            spawn_floating_text(x, bbox_top - 16, "Slowed!", c_purple, id);
                        }
                    }

                    // Visual feedback
                    spawn_floating_text(companion.x, companion.bbox_top - 10, "Maelstrom!", c_aqua, companion);
                    spawn_floating_text(player_instance.x, player_instance.bbox_top - 20, string(_enemies_affected) + " swept!", c_aqua, player_instance);

                    companion_play_trigger_sfx(companion, "maelstrom");

                    show_debug_message("=== MAELSTROM ACTIVATED ===");
                    show_debug_message("Enemies affected: " + string(_enemies_affected));
                    show_debug_message("Deflection boost duration: " + string(companion.triggers.maelstrom.deflect_duration) + " frames");
                }
            }
        }
    }
}

/// @function companion_on_player_hit(player_instance, enemy_instance, base_damage)
/// @description Notify companions that the player hit an enemy (used for On-Hit Strike trigger)
/// @param {Id.Instance} player_instance The player who landed the hit
/// @param {Id.Instance} enemy_instance The enemy that was hit
/// @param {real} base_damage The base damage before companion bonuses
/// @return {real} Bonus damage to add to the hit
function companion_on_player_hit(player_instance, enemy_instance, base_damage) {
    if (player_instance == undefined || player_instance == noone) {
        return 0;
    }

    if (enemy_instance == undefined || enemy_instance == noone) {
        return 0;
    }

    var total_bonus_damage = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Check for On-Hit Strike trigger (Yorna)
        if (variable_struct_exists(companion.triggers, "on_hit_strike")) {
            var trigger = companion.triggers.on_hit_strike;

            if (trigger.unlocked && trigger.active && trigger.cooldown == 0) {
                // Add bonus damage
                var bonus = trigger.bonus_damage;
                total_bonus_damage += bonus;

                // Set cooldown
                trigger.cooldown = trigger.cooldown_max;

                // Visual feedback
                spawn_floating_text(companion.x, companion.bbox_top - 10, "Strike!", c_orange, companion);
                spawn_floating_text(enemy_instance.x + 8, enemy_instance.bbox_top - 20, "+" + string(bonus), c_orange, enemy_instance);

                // Play trigger sound
                companion_play_trigger_sfx(companion, "on_hit_strike");

                show_debug_message("=== ON-HIT STRIKE ACTIVATED ===");
                show_debug_message("Companion: " + companion.companion_name);
                show_debug_message("Bonus damage: " + string(bonus));
                show_debug_message("Cooldown set to: " + string(trigger.cooldown_max));
            }
        }
    }

    return total_bonus_damage;
}

/// @function companion_on_player_dash(player_instance)
/// @description Notify companions that the player started a dash (used for Dash Mend, Expose Weakness, and Execution Window triggers)
/// @param {Id.Instance} player_instance The player who dashed
function companion_on_player_dash(player_instance) {
    if (player_instance == undefined || player_instance == noone) {
        return;
    }

    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // CANOPY: Dash Mend trigger
        if (variable_struct_exists(companion.triggers, "dash_mend")) {
            var trigger = companion.triggers.dash_mend;

            if (trigger.unlocked && trigger.cooldown == 0 && companion.state != CompanionState.casting) {
                // Apply heal scaled by affinity
                var heal_base = (trigger.heal_amount != undefined) ? trigger.heal_amount : 0;
                var multiplier = get_affinity_aura_multiplier(companion.affinity);
                var heal_amount = heal_base * multiplier;

                var previous_hp = player_instance.hp;
                player_instance.hp = min(player_instance.hp_total, player_instance.hp + heal_amount);

                // Visual feedback
                spawn_floating_text(companion.x, companion.bbox_top - 10, "Mend!", c_lime, companion);
                if (player_instance.hp > previous_hp) {
                    var healed = player_instance.hp - previous_hp;
                    spawn_floating_text(player_instance.x, player_instance.bbox_top - 12, "+ " + string_format(healed, 1, 1), c_lime, player_instance);
                }

                trigger.cooldown = trigger.cooldown_max;
                trigger.active = true;
                companion.dash_mend_timer = 12; // brief window for potential VFX

                companion_play_trigger_sfx(companion, "dash_mend");
            }
        }

        // YORNA: Expose Weakness trigger (affinity 8+)
        if (variable_struct_exists(companion.triggers, "expose_weakness")) {
            var trigger = companion.triggers.expose_weakness;

            if (trigger.unlocked && trigger.cooldown == 0 && companion.state != CompanionState.casting) {
                // Enter casting state
                companion.previous_state = companion.state;
                companion.state = CompanionState.casting;
                companion.casting_frame_index = 0;
                companion.casting_timer = 0;

                trigger.cooldown = trigger.cooldown_max;

                // Capture trigger radius before with block
                var _trigger_radius = trigger.radius;

                // Apply defense vulnerability trait to all nearby enemies
                var _enemies_affected = 0;
                with (obj_enemy_parent) {
                    if (state != EnemyState.dead &&
                        point_distance(x, y, player_instance.x, player_instance.y) < _trigger_radius) {

                        // Apply timed trait (automatic timer management via trait system)
                        apply_timed_trait("defense_vulnerability", 3.0);

                        _enemies_affected++;

                        // Visual feedback on enemy
                        spawn_floating_text(x, bbox_top - 16, "Weakness!", c_purple, id);
                    }
                }

                // Slow-motion on trigger activation
                activate_slowmo(0.5);

                // Visual feedback
                spawn_floating_text(companion.x, companion.bbox_top - 10, "Expose Weakness!", c_purple, companion);
                spawn_floating_text(player_instance.x, player_instance.bbox_top - 20, string(_enemies_affected) + " weakened", c_purple, player_instance);

                companion_play_trigger_sfx(companion, "expose_weakness");

                show_debug_message("=== EXPOSE WEAKNESS ACTIVATED ===");
                show_debug_message("Enemies affected: " + string(_enemies_affected));
                show_debug_message("Duration: 3.0 seconds (trait system managed)");
            }
        }

        // YORNA: Execution Window trigger (affinity 10)
        if (variable_struct_exists(companion.triggers, "execution_window")) {
            var trigger = companion.triggers.execution_window;

            if (trigger.unlocked && trigger.cooldown == 0 && companion.state != CompanionState.casting) {
                // Enter casting state
                companion.previous_state = companion.state;
                companion.state = CompanionState.casting;
                companion.casting_frame_index = 0;
                companion.casting_timer = 0;

                trigger.cooldown = trigger.cooldown_max;
                trigger.active = true; // Keep this for duration tracking
                companion.execution_window_timer = trigger.duration;

                // Slow-motion on trigger activation
                activate_slowmo(0.5);

                // Visual feedback
                spawn_floating_text(companion.x, companion.bbox_top - 10, "Execution!", c_red, companion);
                spawn_floating_text(player_instance.x, player_instance.bbox_top - 20, "Power Surge!", c_red, player_instance);

                companion_play_trigger_sfx(companion, "execution_window");

                show_debug_message("=== EXECUTION WINDOW ACTIVATED ===");
                show_debug_message("Duration: " + string(trigger.duration) + " frames");
                show_debug_message("Damage multiplier: " + string(trigger.damage_multiplier));
                show_debug_message("Armor pierce: " + string(trigger.armor_pierce));
            }
        }

        // HOLA: Slipstream Boost trigger (affinity 8+)
        if (variable_struct_exists(companion.triggers, "slipstream_boost")) {
            var trigger = companion.triggers.slipstream_boost;

            if (trigger.unlocked && trigger.cooldown == 0 && companion.state != CompanionState.casting) {
                // Enter casting state
                companion.previous_state = companion.state;
                companion.state = CompanionState.casting;
                companion.casting_frame_index = 0;
                companion.casting_timer = 0;

                trigger.cooldown = trigger.cooldown_max;
                trigger.active = true;
                companion.slipstream_boost_timer = trigger.duration;

                // Visual feedback
                spawn_floating_text(companion.x, companion.bbox_top - 10, "Slipstream!", c_aqua, companion);
                spawn_floating_text(player_instance.x, player_instance.bbox_top - 20, "Tailwind!", c_aqua, player_instance);

                companion_play_trigger_sfx(companion, "slipstream_boost");

                show_debug_message("=== SLIPSTREAM BOOST ACTIVATED ===");
                show_debug_message("Duration: " + string(trigger.duration) + " frames");
                show_debug_message("Dash CD boost: " + string(trigger.dash_cd_boost * 100) + "%");
            }
        }
    }
}

/// @function companion_on_player_damaged(player_instance, damage_amount, damage_type)
/// @description Notify companions that the player has taken damage (used for Aegis trigger)
/// @param {Id.Instance} player_instance The player who was damaged
/// @param {real} damage_amount The amount of damage taken
/// @param {real} damage_type Optional damage type enum
function companion_on_player_damaged(player_instance, damage_amount, damage_type = undefined) {
    if (player_instance == undefined || player_instance == noone) {
        return;
    }

    if (damage_amount == undefined || damage_amount <= 0) {
        return;
    }

    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        if (!variable_struct_exists(companion.triggers, "aegis")) {
            continue;
        }

        var trigger = companion.triggers.aegis;

        if (!trigger.unlocked || trigger.cooldown > 0 || trigger.active) {
            continue;
        }

        trigger.active = true;
        trigger.cooldown = trigger.cooldown_max;
        var _duration = (trigger.duration != undefined) ? trigger.duration : 0;
        companion.aegis_timer = max(1, _duration);

        // Heal based on affinity scaling
        var heal_base = (trigger.heal_amount != undefined) ? trigger.heal_amount : 0;
        var multiplier = get_affinity_aura_multiplier(companion.affinity);
        var heal_amount = heal_base * multiplier;

        var previous_hp = player_instance.hp;
        player_instance.hp = min(player_instance.hp_total, player_instance.hp + heal_amount);
        var healed = player_instance.hp - previous_hp;

        spawn_floating_text(companion.x, companion.bbox_top - 12, "Aegis!", c_aqua, companion);
        if (healed > 0) {
            spawn_floating_text(player_instance.x, player_instance.bbox_top - 16, "+ " + string_format(healed, 1, 1), c_aqua, player_instance);
        }

        activate_slowmo(0.4);
        companion_play_trigger_sfx(companion, "aegis");
    }
}

/// @function recruit_companion(companion_instance, player_instance)
/// @description Recruit a companion to the party
/// @param {Id.Instance} companion_instance The companion to recruit
/// @param {Id.Instance} player_instance The player recruiting
function recruit_companion(companion_instance, player_instance) {
    with (companion_instance) {
        is_recruited = true;
        state = CompanionState.following;
        follow_target = player_instance;

        // Mark first meeting
        quest_flags.met_player = true;

        // Activate all auras (companions have different aura sets)
        var _aura_names = variable_struct_get_names(auras);
        for (var i = 0; i < array_length(_aura_names); i++) {
            var _aura_name = _aura_names[i];
            auras[$ _aura_name].active = true;
        }

        // Play recruitment sound effect
        play_sfx(snd_companion_recruited, 1, 8, false);

        // Visual feedback
        show_debug_message("✓ " + companion_name + " has joined your party!");
        show_debug_message("  - Activated " + string(array_length(_aura_names)) + " auras");
        show_debug_message("  - is_recruited: " + string(is_recruited));
        show_debug_message("  - state: " + string(state) + " (following=" + string(CompanionState.following) + ")");
        show_debug_message("  - follow_target: " + string(follow_target));

        // Check quest objectives for companion recruitment
        quest_check_companion_recruitment(companion_id);
    }
}


/// @function companion_receive_torch(companion_instance, time_remaining, light_radius)
/// @description Transfer a lit torch to the given companion instance
/// @param {Id.Instance} companion_instance Companion receiving torch
/// @param {real} time_remaining Remaining burn time to inherit
/// @return {bool} True if transfer succeeded
function companion_receive_torch(companion_instance, time_remaining, light_radius) {
    if (companion_instance == undefined) return false;

    with (companion_instance) {
        if (!variable_instance_exists(id, "companion_take_torch_from_player")) {
            return false;
        }
        companion_take_torch_from_player(time_remaining, light_radius);
    }

    return true;
}

/// @function companion_take_torch_function()
/// @description VN dialogue hook: companion takes torch from player (equipped or inventory)
function companion_take_torch_function() {
    global.vn_torch_transfer_success = false;
    if (variable_global_exists("ChatterboxVariableSet")) {
        ChatterboxVariableSet("vn_torch_transfer_success", false);
    }

    var _companion = global.vn_companion;
    if (_companion == undefined) return;

    var _player = instance_find(obj_player, 0);
    if (_player == noone) return;

    // If companion already has the torch, success
    if (_companion.carrying_torch) {
        global.vn_torch_transfer_success = true;
        if (variable_global_exists("ChatterboxVariableSet")) {
            ChatterboxVariableSet("vn_torch_transfer_success", true);
        }
        return;
    }

    var _torch_time = 0;
    var _torch_radius = 100;
    var _player_had_torch = false;

    with (_player) {
        // Check if player is actively carrying a torch
        if (torch_active) {
            _torch_time = torch_time_remaining;
            _torch_radius = player_get_torch_light_radius();
            _player_had_torch = true;

            // Take torch from player
            player_stop_torch_loop();
            player_remove_torch_from_loadouts();
            torch_active = false;
            torch_time_remaining = 0;
        }
        // Otherwise try to consume one from inventory
        else if (inventory_consume_item_id("torch", 1)) {
            _torch_time = torch_duration;
            var _torch_stats = global.item_database.torch.stats;
            if (_torch_stats != undefined && variable_struct_exists(_torch_stats, "light_radius")) {
                _torch_radius = _torch_stats[$ "light_radius"];
            }
            _player_had_torch = true;
        }
    }

    // If we got a torch, give it to the companion
    if (_player_had_torch) {
        with (_companion) {
            companion_take_torch_from_player(_torch_time, _torch_radius);
        }

        global.vn_torch_transfer_success = true;
        if (variable_global_exists("ChatterboxVariableSet")) {
            ChatterboxVariableSet("vn_torch_transfer_success", true);
        }

        // Log action for onboarding quest tracking
        action_tracker_log("torch_given");
    }
}

/// @function companion_stop_carrying_torch_function()
/// @description VN dialogue hook: companion hands torch back to the player
function companion_stop_carrying_torch_function() {
    global.vn_torch_transfer_success = false;
    if (variable_global_exists("ChatterboxVariableSet")) {
        ChatterboxVariableSet("vn_torch_transfer_success", false);
    }

    var _companion = global.vn_companion;
    if (_companion == undefined) return;

    var _player = instance_find(obj_player, 0);
    if (_player == noone) return;

    if (!_companion.carrying_torch) return;

    var _can_receive = false;
    with (_player) {
        _can_receive = player_can_receive_torch();
    }

    if (!_can_receive) return;

    with (_companion) {
        if (companion_give_torch_to_player()) {
            global.vn_torch_transfer_success = true;
            if (variable_global_exists("ChatterboxVariableSet")) {
                ChatterboxVariableSet("vn_torch_transfer_success", true);
            }
        }
    }
}


function companion_play_torch_sfx(_asset_name) {
    var _sound = asset_get_index(_asset_name);
    if (_sound != -1) {
        play_sfx(_sound, 1, false);
    }
}

function companion_start_torch_loop() {
    // Only start loop if not already playing
    if (torch_looping) return;

    if (audio_exists(snd_torch_burning_loop)) {
        play_sfx(snd_torch_burning_loop, 1, 8, true);
        torch_looping = true;
    }
}

function companion_stop_torch_loop() {
    // Only stop if currently looping
    if (!torch_looping) return;

    if (audio_exists(snd_torch_burning_loop)) {
        stop_looped_sfx(snd_torch_burning_loop);
    }
    torch_looping = false;
}

function companion_take_torch_from_player(_time_remaining, _light_radius) {
    carrying_torch = true;

    if (_time_remaining <= 0) {
        torch_time_remaining = torch_duration;
    } else {
        torch_time_remaining = clamp(_time_remaining, 1, torch_duration);
    }

    if (_light_radius != undefined) {
        torch_light_radius = _light_radius;
    } else {
        var _torch_stats = global.item_database.torch.stats;
        if (_torch_stats != undefined && variable_struct_exists(_torch_stats, "light_radius")) {
            torch_light_radius = _torch_stats[$ "light_radius"];
        }
    }

    companion_play_torch_sfx("snd_torch_equip");
    companion_start_torch_loop();
    set_torch_carrier(companion_id);
}

function companion_handle_torch_burnout() {
    companion_play_torch_sfx("snd_torch_burnout");
    companion_stop_torch_loop();
    carrying_torch = false;
    torch_time_remaining = 0;
    set_torch_carrier("none");

    var _player = instance_find(obj_player, 0);
    if (_player != noone) {
        with (_player) {
            if (player_supply_companion_torch()) {
                with (other) {
                    companion_take_torch_from_player(torch_duration, undefined);
                }
                return;
            }
        }
    }

    companion_stop_torch_loop();
}

function companion_update_torch_state() {
    if (carrying_torch) {
        torch_time_remaining = max(0, torch_time_remaining - 1);

        if (torch_time_remaining <= 0) {
            companion_handle_torch_burnout();
        }
    } else {
        companion_stop_torch_loop();
    }
}

function companion_give_torch_to_player() {
    if (!carrying_torch) return false;

    var _player = instance_find(obj_player, 0);
    if (_player == noone) return false;

    var _can_receive = false;
    with (_player) {
        _can_receive = player_can_receive_torch();
    }

    if (!_can_receive) {
        return false;
    }

    var _remaining = torch_time_remaining;
    var _radius = torch_light_radius;

    companion_stop_torch_loop();
    carrying_torch = false;
    torch_time_remaining = 0;

    var _accepted = false;
    with (_player) {
        other._torch_transfer_temp = player_receive_torch_from_companion(_remaining, _radius);
    }

    _accepted = _torch_transfer_temp;
    _torch_transfer_temp = undefined;

    if (!_accepted) {
        // Player couldn't take it, resume holding the torch
        companion_take_torch_from_player(_remaining, _radius);
        return false;
    }

    set_torch_carrier("player");

    return true;
}

/// @function evade_from_combat()
/// @description Calculate and move to evasion position during combat
function evade_from_combat() {
    if (!instance_exists(follow_target)) return;

    // Throttle pathfinding recalculation
    evade_recalc_timer++;

    if (evade_recalc_timer >= evade_recalc_interval) {
        evade_recalc_timer = 0;

        // Calculate avoidance vector from player
        var avoid_x = x - follow_target.x;
        var avoid_y = y - follow_target.y;

        // Find nearby enemies to avoid
        var nearby_enemies = ds_list_create();
        collision_circle_list(x, y, evade_detection_radius, obj_enemy_parent, false, true, nearby_enemies, false);

        // Add enemy avoidance vectors
        for (var i = 0; i < ds_list_size(nearby_enemies); i++) {
            var enemy = nearby_enemies[| i];
            if (instance_exists(enemy) && enemy.state != EnemyState.dead) {
                var enemy_avoid_x = x - enemy.x;
                var enemy_avoid_y = y - enemy.y;
                avoid_x += enemy_avoid_x;
                avoid_y += enemy_avoid_y;
            }
        }
        ds_list_destroy(nearby_enemies);

        // Calculate target evasion position
        var avoid_dir = point_direction(0, 0, avoid_x, avoid_y);
        var target_dist = evade_distance_min + ((evade_distance_max - evade_distance_min) / 2);

        // Set cached target position
        evade_target_x = follow_target.x + lengthdir_x(target_dist, avoid_dir);
        evade_target_y = follow_target.y + lengthdir_y(target_dist, avoid_dir);
    }

    // Check current distance from player
    var dist_from_player = point_distance(x, y, follow_target.x, follow_target.y);

    // Move toward cached evasion position if not at proper distance
    if (dist_from_player < evade_distance_min || dist_from_player > evade_distance_max) {
        var move_dir = point_direction(x, y, evade_target_x, evade_target_y);
        var move_x = lengthdir_x(follow_speed, move_dir);
        var move_y = lengthdir_y(follow_speed, move_dir);

        move_dir_x = move_x;
        move_dir_y = move_y;

        // Store position before move to detect if stuck
        var old_x = x;
        var old_y = y;

        // Move with collision detection
        move_and_collide(move_x, move_y, [tilemap, obj_rising_pillar, obj_companion_parent]);

        // Edge case: If completely stuck (didn't move), try moving perpendicular
        if (x == old_x && y == old_y && (abs(move_x) > 0.1 || abs(move_y) > 0.1)) {
            var perp_dir = move_dir + 90;
            var perp_x = lengthdir_x(follow_speed, perp_dir);
            var perp_y = lengthdir_y(follow_speed, perp_dir);
            move_and_collide(perp_x, perp_y, [tilemap, obj_rising_pillar, obj_companion_parent]);
        }
    } else {
        // At proper distance, stay idle
        move_dir_x = 0;
        move_dir_y = 0;
    }
}

/// @function companion_update_path()
/// @description Calculate pathfinding path that avoids hazardous terrain
function companion_update_path() {
    if (!instance_exists(follow_target)) return false;
    if (!instance_exists(obj_pathfinding_controller)) return false;

    var _controller = obj_pathfinding_controller;
    var _grid = _controller.grid;
    if (_grid == -1) return false;

    // Clear grid to base state (obstacles only, no hazards yet)
    mp_grid_clear_all(_grid);

    // Add collision tilemap obstacles
    if (tilemap != -1) {
        for (var i = 0; i < _controller.horizontal_cells; i++) {
            for (var j = 0; j < _controller.vertical_cells; j++) {
                var tile_data = tilemap_get(tilemap, i, j);
                if (tile_data != 0) {
                    mp_grid_add_cell(_grid, i, j);
                }
            }
        }
    }

    // Add object obstacles
    mp_grid_add_instances(_grid, obj_rising_pillar, true);

    // Mark hazardous terrain as obstacles (companions always avoid hazards, no immunity)
    var _cell_size = _controller.cell_size;
    var _grid_width = _controller.horizontal_cells;
    var _grid_height = _controller.vertical_cells;

    for (var _gx = 0; _gx < _grid_width; _gx++) {
        for (var _gy = 0; _gy < _grid_height; _gy++) {
            var _world_x = _gx * _cell_size + _cell_size / 2;
            var _world_y = _gy * _cell_size + _cell_size / 2;

            var _terrain = get_terrain_at_position(_world_x, _world_y);
            var _terrain_data = global.terrain_effects_map[$ _terrain];

            if (_terrain_data != undefined && _terrain_data.is_hazard) {
                mp_grid_add_cell(_grid, _gx, _gy);
            }
        }
    }

    // Calculate path from companion to player
    path_clear_points(companion_path);
    var _path_found = mp_grid_path(_grid, companion_path, x, y, follow_target.x, follow_target.y, false);

    if (_path_found) {
        current_waypoint = 0;
        return true;
    }

    return false;
}
