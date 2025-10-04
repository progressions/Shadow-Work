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

    return _base_damage;
}

function get_attack_range() {
    var _base_range = 16; // Base punch range

    if (equipped.right_hand != undefined && equipped.right_hand.definition.type == ItemType.weapon) {
        var _weapon_stats = equipped.right_hand.definition.stats;

        // Check if using versatile weapon two-handed
        if (is_two_handing() && equipped.right_hand.definition.handedness == WeaponHandedness.versatile) {
            return _weapon_stats[$ "two_handed_range"] ?? _weapon_stats.range;
        } else {
            return _weapon_stats.range;
        }
    }

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

    // Trait modifiers (future)
    // Status effect modifiers (future)

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

    // Trait modifiers (future)
    // Status effect modifiers (future)

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
