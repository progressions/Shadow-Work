// ============================================
// COMBAT SYSTEM - Damage, defense, and XP calculations
// ============================================

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

function get_total_defense() {
    var _total_defense = 0;
    var _slots = ["head", "torso", "legs", "left_hand", "right_hand"];

    for (var i = 0; i < array_length(_slots); i++) {
        if (equipped[$ _slots[i]] != undefined) {
            var _stats = equipped[$ _slots[i]].definition.stats;
            if (variable_struct_exists(_stats, "defense")) {
                _total_defense += _stats.defense;
            }
        }
    }

    return _total_defense;
}

function get_block_chance() {
    // Check left hand for shield
    if (equipped.left_hand != undefined && !is_two_handing()) {
        var _stats = equipped.left_hand.definition.stats;
        return _stats[$ "block_chance"] ?? 0;
    }
    return 0;
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
