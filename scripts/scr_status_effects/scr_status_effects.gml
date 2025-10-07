// ============================================
// STATUS EFFECTS SYSTEM
// ============================================

// Helper function to get status effects from weapon/item (backward compatible)
function get_weapon_status_effects(_item_stats) {
    // New format: array of effects
    if (variable_struct_exists(_item_stats, "status_effects")) {
        return _item_stats.status_effects;
    }

    // Old format: single effect - convert to array
    if (variable_struct_exists(_item_stats, "status_effect")) {
        return [{
            effect: _item_stats.status_effect,
            chance: _item_stats[$ "status_chance"] ?? 1.0
        }];
    }

    return []; // No effects
}

// Status effect definitions
global.status_effect_data = {
    burning: {
        duration: 180,     // 3 seconds at 60fps
        tick_rate: 30,     // Damage every 0.5 seconds
        damage: 1,
        opposing: StatusEffectType.wet
    },
    wet: {
        duration: 300,     // 5 seconds at 60fps
        speed_modifier: 0.9, // 10% speed reduction
        opposing: StatusEffectType.burning
    },
    empowered: {
        duration: 600,     // 10 seconds at 60fps
        damage_modifier: 1.5, // 50% damage increase
        opposing: StatusEffectType.weakened
    },
    weakened: {
        duration: 600,     // 10 seconds at 60fps
        damage_modifier: 0.7, // 30% damage reduction
        opposing: StatusEffectType.empowered
    },
    swift: {
        duration: 480,     // 8 seconds at 60fps
        speed_modifier: 1.3, // 30% speed increase
        opposing: StatusEffectType.slowed
    },
    slowed: {
        duration: 300,     // 5 seconds at 60fps
        speed_modifier: 0.6, // 40% speed reduction
        opposing: StatusEffectType.swift
    },
    poisoned: {
        duration: 300,     // 5 seconds at 60fps
        tick_rate: 60,     // Damage every 1 seconds
        damage: 0.5,
        opposing: undefined // No opposing effect
    }
};

// Helper function to get status effect data
function get_status_effect_data(_effect_type) {
    switch(_effect_type) {
        case StatusEffectType.burning: return global.status_effect_data.burning;
        case StatusEffectType.wet: return global.status_effect_data.wet;
        case StatusEffectType.empowered: return global.status_effect_data.empowered;
        case StatusEffectType.weakened: return global.status_effect_data.weakened;
        case StatusEffectType.swift: return global.status_effect_data.swift;
        case StatusEffectType.slowed: return global.status_effect_data.slowed;
        case StatusEffectType.poisoned: return global.status_effect_data.poisoned;
        default: return undefined;
    }
}

// Core status effects management functions
function init_status_effects() {
    status_effects = [];
}

function apply_status_effect(_effect_type, _duration_override = -1, _is_permanent = false) {
    var effect_data = get_status_effect_data(_effect_type);
    if (effect_data == undefined) return false;

    // Check for trait immunity
    var _immunity_name = "";
    switch(_effect_type) {
        case StatusEffectType.burning:
            _immunity_name = "fire_immunity";
            break;
        case StatusEffectType.wet:
            _immunity_name = "wet_immunity";
            break;
        case StatusEffectType.slowed:
            _immunity_name = "slow_immunity";
            break;
        case StatusEffectType.poisoned:
            _immunity_name = "poison_immunity";
            break;
        // Add more immunity checks as needed
    }

    if (_immunity_name != "" && has_trait(_immunity_name)) {
        show_debug_message("Status effect blocked by trait immunity: " + _immunity_name);
        return false;
    }

    // Check for opposing effect
    var opposing_type = effect_data.opposing;
    if (has_status_effect(opposing_type)) {
        // Neutralize both effects instead of removing
        var opposing_index = find_status_effect(opposing_type);
        if (opposing_index != -1) {
            status_effects[opposing_index].neutralized = true;
        }
    }

    // Check if effect already exists
    var existing_index = find_status_effect(_effect_type);
    if (existing_index != -1) {
        // Refresh duration (unless permanent)
        if (!_is_permanent) {
            var duration = (_duration_override != -1) ? _duration_override : effect_data.duration;
            status_effects[existing_index].remaining_duration = duration;
            status_effects[existing_index].tick_timer = 0;
        }
        // Check if it should be un-neutralized
        if (status_effects[existing_index].neutralized && !has_status_effect(opposing_type)) {
            status_effects[existing_index].neutralized = false;
        }
        return true;
    }

    // Add new effect
    var duration = _is_permanent ? -1 : ((_duration_override != -1) ? _duration_override : effect_data.duration);
    var new_effect = {
        type: _effect_type,
        remaining_duration: duration,
        tick_timer: 0,
        data: effect_data,
        is_permanent: _is_permanent,
        neutralized: has_status_effect(opposing_type) // Start neutralized if opposing effect exists
    };

    array_push(status_effects, new_effect);

    // Spawn floating text showing effect name
    var effect_name = get_status_effect_name(_effect_type);
    var effect_color = ui_get_status_effect_color(_effect_type);
    spawn_floating_text(x, y - 16, effect_name, effect_color, self);

    return true;
}

function remove_status_effect(_effect_type) {
    var index = find_status_effect(_effect_type);
    if (index != -1) {
        var effect = status_effects[index];
        var effect_data = effect.data;

        // Before removing, check if this effect had an opposing effect
        if (variable_struct_exists(effect_data, "opposing")) {
            var opposing_type = effect_data.opposing;
            var opposing_index = find_status_effect(opposing_type);

            // If the opposing effect exists and was neutralized, un-neutralize it
            if (opposing_index != -1 && status_effects[opposing_index].neutralized) {
                status_effects[opposing_index].neutralized = false;
            }
        }

        array_delete(status_effects, index, 1);
        return true;
    }
    return false;
}

function has_status_effect(_effect_type) {
    return find_status_effect(_effect_type) != -1;
}

function find_status_effect(_effect_type) {
    for (var i = 0; i < array_length(status_effects); i++) {
        if (status_effects[i].type == _effect_type) {
            return i;
        }
    }
    return -1;
}

function tick_status_effects() {
    for (var i = array_length(status_effects) - 1; i >= 0; i--) {
        var effect = status_effects[i];

        // Skip permanent effects
        if (effect.is_permanent) {
            continue;
        }

        // Handle damage over time effects
        if (effect.type == StatusEffectType.burning || effect.type == StatusEffectType.poisoned) {
            effect.tick_timer++;
            if (effect.tick_timer >= effect.data.tick_rate) {
                var _dot_damage = effect.data.damage;
                var _damage_type = (effect.type == StatusEffectType.burning) ? DamageType.fire : DamageType.poison;
                var _death_message = (effect.type == StatusEffectType.burning) ? "burning" : "poison";

                hp -= _dot_damage;
                if (object_index == obj_player) {
                    companion_on_player_damaged(id, _dot_damage, _damage_type);
                }

                // Check if entity died from DoT
                if (hp <= 0) {
                    if (object_index == obj_player) {
                        state = PlayerState.dead;
                        show_debug_message("Player died from " + _death_message);
                    } else if (object_is_ancestor(object_index, obj_enemy_parent)) {
                        state = EnemyState.dead;
                        show_debug_message("Enemy died from " + _death_message);

                        // Award XP to player for DoT kill
                        if (instance_exists(obj_player)) {
                            var xp_reward = 5;
                            with (obj_player) {
                                gain_xp(xp_reward);
                            }
                            show_debug_message("Enemy died from " + _death_message + "! Player gained " + string(xp_reward) + " XP");
                        }
                    }
                }

                effect.tick_timer = 0;
            }
        }

        // Reduce duration
        effect.remaining_duration--;

        // Remove expired effects
        if (effect.remaining_duration <= 0) {
            array_delete(status_effects, i, 1);
        }
    }
}

function get_status_effect_modifier(_modifier_type) {
    var modifier = 1.0;

    for (var i = 0; i < array_length(status_effects); i++) {
        var effect = status_effects[i];

        // Skip neutralized effects
        if (effect.neutralized) {
            continue;
        }

        switch(_modifier_type) {
            case "speed":
                if (variable_struct_exists(effect.data, "speed_modifier")) {
                    modifier *= effect.data.speed_modifier;
                }
                break;

            case "damage":
                if (variable_struct_exists(effect.data, "damage_modifier")) {
                    modifier *= effect.data.damage_modifier;
                }
                break;
        }
    }

    return modifier;
}

// Apply wielder effects from equipped item
function apply_wielder_effects(_item_stats) {
    // Apply status effects
    if (variable_struct_exists(_item_stats, "wielder_effects")) {
        var _wielder_effects = _item_stats.wielder_effects;
        for (var i = 0; i < array_length(_wielder_effects); i++) {
            var _effect_data = _wielder_effects[i];
            apply_status_effect(_effect_data.effect, -1, true);
        }
    }

    // Apply trait grants (Trait System v2.0)
    if (variable_struct_exists(_item_stats, "trait_grants")) {
        var _trait_grants = _item_stats.trait_grants;
        for (var i = 0; i < array_length(_trait_grants); i++) {
            var _trait_data = _trait_grants[i];
            add_temporary_trait(_trait_data.trait, _trait_data.stacks);
        }
    }
}

// Remove wielder effects from equipped item
function remove_wielder_effects(_item_stats) {
    // Remove status effects
    if (variable_struct_exists(_item_stats, "wielder_effects")) {
        var _wielder_effects = _item_stats.wielder_effects;
        for (var i = 0; i < array_length(_wielder_effects); i++) {
            var _effect_data = _wielder_effects[i];
            remove_status_effect(_effect_data.effect);
        }
    }

    // Remove trait grants (Trait System v2.0)
    if (variable_struct_exists(_item_stats, "trait_grants")) {
        var _trait_grants = _item_stats.trait_grants;
        for (var i = 0; i < array_length(_trait_grants); i++) {
            var _trait_data = _trait_grants[i];
            remove_temporary_trait(_trait_data.trait, _trait_data.stacks);
        }
    }
}

// Get status effect display name
function get_status_effect_name(_effect_type) {
    switch(_effect_type) {
        case StatusEffectType.burning: return "Burning";
        case StatusEffectType.wet: return "Wet";
        case StatusEffectType.empowered: return "Empowered";
        case StatusEffectType.weakened: return "Weakened";
        case StatusEffectType.swift: return "Swift";
        case StatusEffectType.slowed: return "Slowed";
        case StatusEffectType.poisoned: return "Poisoned";
        default: return "Unknown";
    }
}
