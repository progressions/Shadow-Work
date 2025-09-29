// Trait System Helper Functions
// Functions for managing and querying character traits

/// @function has_trait(trait_key)
/// @description Check if character has a specific trait
/// @param {string} trait_key The trait to check for
/// @return {bool} True if character has the trait
function has_trait(_trait_key) {
    for (var i = 0; i < array_length(traits); i++) {
        if (traits[i] == _trait_key) {
            return true;
        }
    }
    return false;
}

/// @function add_trait(trait_key)
/// @description Add a trait to the character
/// @param {string} trait_key The trait to add
function add_trait(_trait_key) {
    if (!has_trait(_trait_key)) {
        array_push(traits, _trait_key);
    }
}

/// @function remove_trait(trait_key)
/// @description Remove a trait from the character
/// @param {string} trait_key The trait to remove
function remove_trait(_trait_key) {
    for (var i = 0; i < array_length(traits); i++) {
        if (traits[i] == _trait_key) {
            array_delete(traits, i, 1);
            break;
        }
    }
}

/// @function get_trait_effect(trait_key, effect_name)
/// @description Get a specific effect value from a trait
/// @param {string} trait_key The trait to query
/// @param {string} effect_name The effect property name
/// @return {real|bool|undefined} The effect value or undefined if not found
function get_trait_effect(_trait_key, _effect_name) {
    // Safety check: ensure trait database exists
    if (!variable_global_exists("trait_database")) {
        return undefined;
    }

    if (!variable_struct_exists(global.trait_database, _trait_key)) {
        return undefined;
    }

    var _trait_def = global.trait_database[$ _trait_key];

    // Safety check: ensure trait definition has effects
    if (!is_struct(_trait_def) || !variable_struct_exists(_trait_def, "effects")) {
        return undefined;
    }

    if (!variable_struct_exists(_trait_def.effects, _effect_name)) {
        return undefined;
    }

    return _trait_def.effects[$ _effect_name];
}

/// @function get_all_trait_modifiers(effect_name)
/// @description Get combined modifier from all traits for a specific effect
/// @param {string} effect_name The effect property name
/// @return {real} Combined modifier value (multiplicative)
function get_all_trait_modifiers(_effect_name) {
    var _modifier = 1.0;

    for (var i = 0; i < array_length(traits); i++) {
        var _trait_key = traits[i];
        var _effect_value = get_trait_effect(_trait_key, _effect_name);

        if (_effect_value != undefined) {
            _modifier *= _effect_value;
        }
    }

    return _modifier;
}

/// @function has_trait_immunity(immunity_name)
/// @description Check if character has immunity from any trait
/// @param {string} immunity_name The immunity property name
/// @return {bool} True if any trait grants this immunity
function has_trait_immunity(_immunity_name) {
    for (var i = 0; i < array_length(traits); i++) {
        var _trait_key = traits[i];
        var _immunity = get_trait_effect(_trait_key, _immunity_name);

        if (_immunity == true) {
            return true;
        }
    }

    return false;
}

/// @function get_terrain_at_position(x, y)
/// @description Get terrain type at position by checking all tile layers
/// @param {real} x X position
/// @param {real} y Y position
/// @return {string} Terrain type (grass, path, water, dirt, stone, etc.)
function get_terrain_at_position(_x, _y) {
    // Safety check: ensure terrain map exists
    if (!variable_global_exists("terrain_tile_map")) {
        return "grass"; // Default fallback
    }

    // Check each layer in priority order (water > path > forest)
    var _layers_to_check = ["Tiles_Water_Moving", "Tiles_Water", "Tiles_Path", "Tiles_Forest"];

    for (var i = 0; i < array_length(_layers_to_check); i++) {
        var _layer_name = _layers_to_check[i];
        var _layer_id = layer_get_id(_layer_name);

        if (_layer_id == -1) continue; // Layer doesn't exist, skip

        var _tilemap = layer_tilemap_get_id(_layer_id);
        if (_tilemap == -1) continue; // No tilemap on layer, skip

        var _tile_data = tilemap_get_at_pixel(_tilemap, _x, _y);
        var _tile_index = tile_get_index(_tile_data);

        if (_tile_index == 0) continue; // No tile here, check next layer

        // Look up terrain type from range mapping
        if (variable_struct_exists(global.terrain_tile_map, _layer_name)) {
            var _ranges = global.terrain_tile_map[$ _layer_name];

            // Check each range: [start, end, "name"]
            for (var j = 0; j < array_length(_ranges); j++) {
                var _range = _ranges[j];
                var _start = _range[0];
                var _end = _range[1];
                var _terrain_name = _range[2];

                if (_tile_index >= _start && _tile_index <= _end) {
                    return _terrain_name;
                }
            }
        }
    }

    return "grass"; // Default if no terrain found
}

/// @function get_damage_type(attacker)
/// @description Determine damage type from attacker's weapon or status effects
/// @param {instance} attacker The attacking character instance
/// @return {string} Damage type (fire, ice, lightning, poison, physical, holy, shadow)
function get_damage_type(_attacker) {
    // Default damage type
    var _damage_type = "physical";

    // Check if attacker has a weapon equipped with a damage type
    if (_attacker.equipped.right_hand != undefined) {
        var _weapon_stats = _attacker.equipped.right_hand.definition.stats;

        // Check for explicit damage_type in weapon stats
        if (variable_struct_exists(_weapon_stats, "damage_type")) {
            return _weapon_stats.damage_type;
        }

        // Infer damage type from status effect
        if (variable_struct_exists(_weapon_stats, "status_effect")) {
            switch (_weapon_stats.status_effect) {
                case StatusEffectType.burning:
                    return "fire";
                case StatusEffectType.wet:
                    return "ice";
                // Add more status effect -> damage type mappings as needed
            }
        }
    }

    // Check left hand as well (e.g., torch)
    if (_attacker.equipped.left_hand != undefined) {
        var _left_stats = _attacker.equipped.left_hand.definition.stats;

        if (variable_struct_exists(_left_stats, "damage_type")) {
            return _left_stats.damage_type;
        }

        if (variable_struct_exists(_left_stats, "status_effect")) {
            switch (_left_stats.status_effect) {
                case StatusEffectType.burning:
                    return "fire";
                case StatusEffectType.wet:
                    return "ice";
            }
        }
    }

    return _damage_type;
}