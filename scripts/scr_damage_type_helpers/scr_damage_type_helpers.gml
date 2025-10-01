// ============================================
// DAMAGE TYPE HELPERS - Functions for damage type system
// ============================================

/// @description Gets the damage type resistance multiplier for a target entity
/// @param {Id.Instance} _target The entity to check resistance for
/// @param {Real} _damage_type The DamageType enum value
/// @return {Real} The resistance multiplier (0.0 = immune, 0.5 = resistant, 1.0 = normal, 1.5 = vulnerable, 2.0 = weak)
function get_damage_type_multiplier(_target, _damage_type) {
    if (!instance_exists(_target)) return 1.0;
    if (!variable_instance_exists(_target, "damage_resistances")) return 1.0;

    var _key = damage_type_to_string(_damage_type);
    if (variable_struct_exists(_target.damage_resistances, _key)) {
        return _target.damage_resistances[$ _key];
    }
    return 1.0;
}

/// @description Sets the damage type resistance multiplier for a target entity
/// @param {Id.Instance} _target The entity to modify
/// @param {Real} _damage_type The DamageType enum value
/// @param {Real} _multiplier The resistance multiplier (0.0 = immune, 1.0 = normal, 1.5 = vulnerable)
function set_damage_resistance(_target, _damage_type, _multiplier) {
    if (!instance_exists(_target)) return;

    // Initialize damage_resistances struct if it doesn't exist
    if (!variable_instance_exists(_target, "damage_resistances")) {
        _target.damage_resistances = {
            physical: 1.0,
            magical: 1.0,
            fire: 1.0,
            holy: 1.0,
            unholy: 1.0
        };
    }

    var _key = damage_type_to_string(_damage_type);
    _target.damage_resistances[$ _key] = _multiplier;
}

/// @description Converts a DamageType enum value to a string key
/// @param {Real} _damage_type The DamageType enum value
/// @return {String} The string representation of the damage type
function damage_type_to_string(_damage_type) {
    switch(_damage_type) {
        case DamageType.physical: return "physical";
        case DamageType.magical: return "magical";
        case DamageType.fire: return "fire";
        case DamageType.ice: return "ice";
        case DamageType.lightning: return "lightning";
        case DamageType.poison: return "poison";
        case DamageType.disease: return "disease";
        case DamageType.holy: return "holy";
        case DamageType.unholy: return "unholy";
        default: return "physical";
    }
}

/// @description Converts a DamageType enum value to a color for visual feedback
/// @param {Real} _damage_type The DamageType enum value
/// @return {Constant.Color} The color constant for this damage type
function damage_type_to_color(_damage_type) {
    switch(_damage_type) {
        case DamageType.physical: return c_red;
        case DamageType.magical: return make_color_rgb(138, 43, 226); // Blue-violet
        case DamageType.fire: return make_color_rgb(255, 140, 0); // Dark orange
        case DamageType.ice: return make_color_rgb(135, 206, 250); // Light sky blue
        case DamageType.lightning: return make_color_rgb(255, 255, 0); // Bright yellow
        case DamageType.poison: return make_color_rgb(0, 255, 0); // Bright green
        case DamageType.disease: return make_color_rgb(139, 69, 19); // Saddle brown
        case DamageType.holy: return make_color_rgb(255, 215, 0); // Gold
        case DamageType.unholy: return make_color_rgb(128, 0, 128); // Purple
        default: return c_white;
    }
}