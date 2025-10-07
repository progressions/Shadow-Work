// ============================================
// COMBAT SYSTEM - Damage, defense, and XP calculations
// ============================================

// Attack Category Enum - Distinguishes melee vs ranged attacks
enum AttackCategory {
    melee,
    ranged
}

function get_total_damage() {
    var _base_damage = 1; // Base unarmed damage

    // Right hand weapon
    if (equipped.right_hand != undefined && equipped.right_hand.definition.type == ItemType.weapon) {
        var _weapon_stats = equipped.right_hand.definition.stats;

        // Check if using versatile weapon two-handed
        if (is_two_handing() && equipped.right_hand.definition.handedness == WeaponHandedness.versatile) {
            _base_damage = _weapon_stats[$ "two_handed_damage"] ?? _weapon_stats.damage;
        } else {
            _base_damage = _weapon_stats.damage;
        }
    }

    // Add left hand weapon damage if dual-wielding
    if (is_dual_wielding()) {
        var _left_damage = equipped.left_hand.definition.stats.damage;
        _base_damage += _left_damage * 0.5; // Off-hand does 50% damage
    }

    // Apply status effect damage modifiers
    var damage_modifier = get_status_effect_modifier("damage");
    _base_damage *= damage_modifier;

    // Apply dash attack damage boost
    if (is_dash_attacking) {
        _base_damage *= dash_attack_damage_multiplier;
        show_debug_message("Dash attack damage boost applied! Base: " + string(_base_damage / dash_attack_damage_multiplier) + " -> Boosted: " + string(_base_damage));
    }

    // Add companion attack bonuses
    _base_damage += get_companion_attack_bonus();

    // Apply Execution Window damage multiplier (Yorna affinity 10 trigger)
    var _execution_multiplier = get_execution_window_multiplier();
    if (_execution_multiplier > 1.0) {
        _base_damage *= _execution_multiplier;
        show_debug_message("EXECUTION WINDOW ACTIVE! Damage boosted: " + string(_base_damage / _execution_multiplier) + " -> " + string(_base_damage));
    }

    // Roll for critical hit
    last_attack_was_crit = false; // Reset crit flag
    if (random(1) < crit_chance) {
        last_attack_was_crit = true;
        _base_damage *= crit_multiplier;
        show_debug_message("CRITICAL HIT! Damage: " + string(_base_damage / crit_multiplier) + " -> " + string(_base_damage));
    }

    return _base_damage;
}

function get_attack_range() {
    var _base_range = 16; // Base punch range

    if (equipped.right_hand != undefined && equipped.right_hand.definition.type == ItemType.weapon) {
        var _weapon_stats = equipped.right_hand.definition.stats;

        // Check if using versatile weapon two-handed
        if (is_two_handing() && equipped.right_hand.definition.handedness == WeaponHandedness.versatile) {
            _base_range = _weapon_stats[$ "two_handed_range"] ?? _weapon_stats.range;
        } else {
            _base_range = _weapon_stats.range;
        }
    }

    // Add companion range bonuses
    _base_range += get_companion_range_bonus();

    return _base_range;
}

function gain_xp(_amount) {
    if (_amount <= 0) return; // No negative or zero XP

    xp += _amount;
    show_debug_message("Gained " + string(_amount) + " XP");

    // Check for level ups
    while (xp >= xp_to_next) {
        xp -= xp_to_next;
        level++;

        // Increase XP requirement for next level (25% increase per level)
        xp_to_next = ceil(xp_to_next * 1.25);

        // Level up bonuses
        var old_hp_total = hp_total;
        hp_total += 2; // Gain 2 max HP per level
        hp += 2; // Also heal 2 HP when leveling up

        show_debug_message("LEVEL UP! Now level " + string(level));
        show_debug_message("Max HP increased from " + string(old_hp_total) + " to " + string(hp_total));
        show_debug_message("Next level requires " + string(xp_to_next) + " XP");

        // TODO: Add level up sound effect
        // audio_play_sound(snd_level_up, 1, false);
    }
}

/// @function get_equipment_general_dr()
/// @description Sum general damage_reduction from all equipped items (applies to both melee and ranged)
function get_equipment_general_dr() {
    var _total = 0;
    var _slots = ["head", "torso", "legs", "left_hand", "right_hand"];

    for (var i = 0; i < array_length(_slots); i++) {
        if (equipped[$ _slots[i]] != undefined) {
            var _stats = equipped[$ _slots[i]].definition.stats;
            if (variable_struct_exists(_stats, "damage_reduction")) {
                _total += _stats.damage_reduction;
            }
        }
    }
    return _total;
}

/// @function get_equipment_melee_dr()
/// @description Sum melee_damage_reduction from all equipped items
function get_equipment_melee_dr() {
    var _total = 0;
    var _slots = ["head", "torso", "legs", "left_hand", "right_hand"];

    for (var i = 0; i < array_length(_slots); i++) {
        if (equipped[$ _slots[i]] != undefined) {
            var _stats = equipped[$ _slots[i]].definition.stats;
            if (variable_struct_exists(_stats, "melee_damage_reduction")) {
                _total += _stats.melee_damage_reduction;
            }
        }
    }
    return _total;
}

/// @function get_equipment_ranged_dr()
/// @description Sum ranged_damage_reduction from all equipped items
function get_equipment_ranged_dr() {
    var _total = 0;
    var _slots = ["head", "torso", "legs", "left_hand", "right_hand"];

    for (var i = 0; i < array_length(_slots); i++) {
        if (equipped[$ _slots[i]] != undefined) {
            var _stats = equipped[$ _slots[i]].definition.stats;
            if (variable_struct_exists(_stats, "ranged_damage_reduction")) {
                _total += _stats.ranged_damage_reduction;
            }
        }
    }
    return _total;
}

/// @function get_melee_damage_reduction()
/// @description Calculate total melee DR from equipment, traits, status effects, companions
function get_melee_damage_reduction() {
    var _total_dr = 0;

    // Equipment DR (general applies to all, plus melee-specific)
    _total_dr += get_equipment_general_dr();
    _total_dr += get_equipment_melee_dr();

    // Companion DR bonuses
    _total_dr += get_companion_melee_dr_bonus();

    // Apply defense modifier from traits (bolstered/sundered defense)
    var _defense_modifier = get_defense_modifier();
    _total_dr *= _defense_modifier;

    return _total_dr;
}

/// @function get_ranged_damage_reduction()
/// @description Calculate total ranged DR from equipment, traits, status effects, companions
function get_ranged_damage_reduction() {
    var _total_dr = 0;

    // Equipment DR (general applies to all, plus ranged-specific)
    _total_dr += get_equipment_general_dr();
    _total_dr += get_equipment_ranged_dr();

    // Companion DR bonuses
    _total_dr += get_companion_ranged_dr_bonus();

    // Apply defense modifier from traits (bolstered/sundered defense)
    var _defense_modifier = get_defense_modifier();
    _total_dr *= _defense_modifier;

    return _total_dr;
}


function get_speed_modifier() {
    var _speed = 1.0;
    var _slots = ["head", "torso", "legs", "left_hand", "right_hand"];

    for (var i = 0; i < array_length(_slots); i++) {
        if (equipped[$ _slots[i]] != undefined) {
            var _stats = equipped[$ _slots[i]].definition.stats;
            if (variable_struct_exists(_stats, "speed_modifier")) {
                _speed *= _stats.speed_modifier;
            }
        }
    }

    return _speed;
}

/// @function freeze_frame(duration)
/// @description Activate a freeze frame effect for the specified number of frames
/// @param {Real} duration Number of frames to freeze (2-4 recommended)
function freeze_frame(_duration) {
    if (!instance_exists(obj_game_controller)) return;

    with (obj_game_controller) {
        freeze_active = true;
        freeze_timer = _duration;
    }
}

/// @function enemy_flash(color, duration)
/// @description Flash an enemy with a specific color for visual feedback
/// @param {Constant.Color} color Color to flash (c_white for hit, c_red for crit)
/// @param {Real} duration Number of frames to flash (6-10 recommended)
function enemy_flash(_color, _duration) {
    // Only works when called from an enemy instance
    if (object_index == obj_enemy_parent || object_is_ancestor(object_index, obj_enemy_parent)) {
        flash_color = _color;
        flash_timer = _duration;
    }
}

/// @function screen_shake(intensity)
/// @description Trigger a screen shake effect with specified intensity
/// @param {Real} intensity Shake magnitude in pixels (2-12 recommended)
function screen_shake(_intensity) {
    if (!instance_exists(obj_game_controller)) return;

    with (obj_game_controller) {
        // Set shake to the maximum of current or new intensity (don't interrupt bigger shakes)
        shake_intensity = max(shake_intensity, _intensity);
        shake_timer = 20; // Shake duration in frames
    }
}

/// @function spawn_hit_effect(x, y, direction)
/// @description Spawn a hit sparkle effect at the hit location
/// @param {Real} x X position to spawn effect
/// @param {Real} y Y position to spawn effect
/// @param {Real} direction Direction away from attacker (degrees)
function spawn_hit_effect(_x, _y, _direction) {
    var _effect = instance_create_depth(_x, _y, -100, obj_hit_effect);

    // Randomize angle slightly (±30 degrees from impact direction)
    var _angle_variance = random_range(-30, 30);
    _effect.direction = _direction + _angle_variance;

    // Small outward movement for spray effect
    _effect.speed = random_range(0.5, 1.5);
    _effect.friction = 0.1; // Slow down quickly

    // Random rotation for variety
    _effect.image_angle = random(360);
}

/// @function activate_slowmo(duration_seconds)
/// @description Activate slow-motion effect for companion triggers
/// @param {Real} duration_seconds Duration in seconds (0.5 recommended)
function activate_slowmo(_duration_seconds) {
    if (!instance_exists(obj_game_controller)) return;

    with (obj_game_controller) {
        slowmo_active = true;
        slowmo_timer = _duration_seconds * 60; // Convert to frames at 60fps
        slowmo_recovery_timer = 15; // 0.25 seconds to recover to normal speed
        slowmo_target_speed = 30; // 50% speed (30fps instead of 60fps)

        // Immediately set game speed to slow-mo
        game_set_speed(slowmo_target_speed, gamespeed_fps);
        slowmo_current_speed = slowmo_target_speed;
    }
}
