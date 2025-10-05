// Trait System Helper Functions (VERSION 2.0 - Stacking Mechanics)
// Functions for managing and querying character traits with stack counts

/// @function has_trait(trait_key)
/// @description Check if character has a specific trait (checks both permanent and temporary)
/// @param {string} trait_key The trait to check for
/// @return {bool} True if character has the trait with 1+ stacks
function has_trait(_trait_key) {
    return get_total_trait_stacks(_trait_key) > 0;
}

/// @function get_total_trait_stacks(trait_key)
/// @description Get total stacks of a trait from both permanent and temporary
/// @param {string} trait_key The trait to check
/// @return {real} Total stack count (0 if trait not present)
function get_total_trait_stacks(_trait_key) {
    var _perm_stacks = 0;
    var _temp_stacks = 0;

    if (variable_instance_exists(self, "permanent_traits") && variable_struct_exists(permanent_traits, _trait_key)) {
        _perm_stacks = permanent_traits[$ _trait_key];
    }

    if (variable_instance_exists(self, "temporary_traits") && variable_struct_exists(temporary_traits, _trait_key)) {
        _temp_stacks = temporary_traits[$ _trait_key];
    }

    return min(_perm_stacks + _temp_stacks, 5); // Cap at 5 stacks
}

/// @function add_permanent_trait(trait_key)
/// @description Add a permanent trait stack (from tags, quest rewards)
/// @param {string} trait_key The trait to add
function add_permanent_trait(_trait_key) {
    if (!variable_instance_exists(self, "permanent_traits")) {
        permanent_traits = {};
    }

    var _current = variable_struct_exists(permanent_traits, _trait_key) ? permanent_traits[$ _trait_key] : 0;
    permanent_traits[$ _trait_key] = min(_current + 1, 5); // Cap at 5 stacks
}

/// @function add_temporary_trait(trait_key)
/// @description Add a temporary trait stack (from equipment, companions, buffs)
/// @param {string} trait_key The trait to add
function add_temporary_trait(_trait_key) {
    if (!variable_instance_exists(self, "temporary_traits")) {
        temporary_traits = {};
    }

    var _current = variable_struct_exists(temporary_traits, _trait_key) ? temporary_traits[$ _trait_key] : 0;
    temporary_traits[$ _trait_key] = min(_current + 1, 5); // Cap at 5 stacks
}

/// @function remove_temporary_trait(trait_key)
/// @description Remove a temporary trait stack (when unequipping, buff expires)
/// @param {string} trait_key The trait to remove
function remove_temporary_trait(_trait_key) {
    if (!variable_instance_exists(self, "temporary_traits")) return;
    if (!variable_struct_exists(temporary_traits, _trait_key)) return;

    var _current = temporary_traits[$ _trait_key];
    _current--;

    if (_current <= 0) {
        variable_struct_remove(temporary_traits, _trait_key);
    } else {
        temporary_traits[$ _trait_key] = _current;
    }
}

/// @function apply_timed_trait(trait_key, duration_seconds)
/// @description Apply a temporary trait that expires after a duration
/// @param {string} trait_key The trait to apply
/// @param {real} duration_seconds How long the trait lasts in seconds
function apply_timed_trait(_trait_key, _duration_seconds) {
    // Initialize timed traits tracking if needed
    if (!variable_instance_exists(self, "timed_traits")) {
        timed_traits = [];
    }

    // Add the temporary trait stack
    add_temporary_trait(_trait_key);

    // Track this timed trait for automatic removal
    array_push(timed_traits, {
        trait: _trait_key,
        timer: _duration_seconds * room_speed, // Convert to frames
        stacks_applied: 1
    });

    show_debug_message("Applied timed trait: " + _trait_key + " for " + string(_duration_seconds) + " seconds");
}

/// @function update_timed_traits()
/// @description Update all timed trait timers and remove expired traits (call in Step event)
function update_timed_traits() {
    if (!variable_instance_exists(self, "timed_traits")) return;

    var _traits_to_remove = [];

    // Update timers
    for (var i = 0; i < array_length(timed_traits); i++) {
        timed_traits[i].timer--;

        if (timed_traits[i].timer <= 0) {
            // Timer expired - remove the trait
            var _trait_key = timed_traits[i].trait;
            var _stacks = timed_traits[i].stacks_applied;

            for (var j = 0; j < _stacks; j++) {
                remove_temporary_trait(_trait_key);
            }

            show_debug_message("Timed trait expired: " + _trait_key);
            array_push(_traits_to_remove, i);
        }
    }

    // Remove expired traits from tracking (reverse order to preserve indices)
    for (var i = array_length(_traits_to_remove) - 1; i >= 0; i--) {
        array_delete(timed_traits, _traits_to_remove[i], 1);
    }
}

/// @function apply_tag_traits([tag_key])
/// @description Apply all traits from a tag (or all tags array) as permanent traits
/// @param {string} [tag_key] Optional - specific tag to apply. If omitted, applies all tags in tags array
function apply_tag_traits(_tag_key = undefined) {
    if (!variable_global_exists("tag_database")) return;

    // If no parameter provided, apply all tags from tags array
    if (_tag_key == undefined) {
        if (!variable_instance_exists(self, "tags")) return;

        for (var i = 0; i < array_length(tags); i++) {
            var _tag_name = tags[i];
            if (variable_struct_exists(global.tag_database, _tag_name)) {
                var _tag = global.tag_database[$ _tag_name];
                var _traits = _tag.grants_traits;

                for (var j = 0; j < array_length(_traits); j++) {
                    add_permanent_trait(_traits[j]);
                }
            }
        }
        return;
    }

    // Apply specific tag if parameter provided
    if (!variable_struct_exists(global.tag_database, _tag_key)) return;

    var _tag = global.tag_database[$ _tag_key];
    var _traits = _tag.grants_traits;

    for (var i = 0; i < array_length(_traits); i++) {
        add_permanent_trait(_traits[i]);
    }
}

/// @function get_defense_modifier()
/// @description Calculate defense multiplier from defense traits (affects damage reduction)
/// @return {Real} Defense multiplier (1.0 = normal, 1.33 = bolstered, 0.75 = sundered)
function get_defense_modifier() {
    var _resistance_stacks = get_total_trait_stacks("defense_resistance");
    var _vulnerability_stacks = get_total_trait_stacks("defense_vulnerability");

    // Calculate net stacks (resistance - vulnerability)
    var _net_stacks = _resistance_stacks - _vulnerability_stacks;

    if (_net_stacks > 0) {
        // Net resistance (bolstered defense) - increases damage reduction
        return power(1.33, _net_stacks); // Each stack adds +33% DR
    } else if (_net_stacks < 0) {
        // Net vulnerability (sundered defense) - decreases damage reduction
        return power(0.75, abs(_net_stacks)); // Each stack reduces DR by 25%
    } else {
        // Perfect cancellation or no traits
        return 1.0;
    }
}

/// @function get_damage_modifier_for_type(damage_type)
/// @description Calculate final damage modifier for a damage type with opposite trait cancellation
/// @param {Real} damage_type The DamageType enum value
/// @return {Real} Final damage multiplier (0.0 = immune, 1.0 = normal, etc.)
function get_damage_modifier_for_type(_damage_type) {
    // Convert DamageType enum to string
    var _type_str = damage_type_to_string(_damage_type);

    // Build trait names for this damage type
    var _immunity_trait = _type_str + "_immunity";
    var _resistance_trait = _type_str + "_resistance";
    var _vulnerability_trait = _type_str + "_vulnerability";

    // Get stacks for each trait type
    var _immunity_stacks = get_total_trait_stacks(_immunity_trait);
    var _resistance_stacks = get_total_trait_stacks(_resistance_trait);
    var _vulnerability_stacks = get_total_trait_stacks(_vulnerability_trait);

    // Immunity check - if any immunity stacks, check if cancelled by vulnerability
    if (_immunity_stacks > 0) {
        if (_vulnerability_stacks > 0) {
            // Cancel stack-by-stack
            var _net_immunity = _immunity_stacks - _vulnerability_stacks;
            if (_net_immunity > 0) {
                return 0.0; // Still immune
            } else {
                // Immunity cancelled, vulnerability remains
                var _net_vuln = _vulnerability_stacks - _immunity_stacks;
                return power(1.5, _net_vuln);
            }
        } else {
            return 0.0; // Immune, no cancellation
        }
    }

    // No immunity, check resistance vs vulnerability
    if (_resistance_stacks > 0 || _vulnerability_stacks > 0) {
        var _net_stacks = _resistance_stacks - _vulnerability_stacks;

        if (_net_stacks > 0) {
            // Net resistance
            return power(0.75, _net_stacks);
        } else if (_net_stacks < 0) {
            // Net vulnerability
            return power(1.5, abs(_net_stacks));
        } else {
            // Perfect cancellation
            return 1.0;
        }
    }

    // No traits affecting this damage type
    return 1.0;
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

    // Check if attacker has a RIGHT HAND weapon equipped
    if (_attacker.equipped.right_hand != undefined) {
        var _weapon_stats = _attacker.equipped.right_hand.definition.stats;

        // Check for explicit damage_type in weapon stats
        if (variable_struct_exists(_weapon_stats, "damage_type")) {
            return _weapon_stats.damage_type;
        }

        // Infer damage type from status effects on right hand weapon
        var _status_effects = get_weapon_status_effects(_weapon_stats);
        if (array_length(_status_effects) > 0) {
            // Use first status effect to determine damage type
            switch (_status_effects[0].effect) {
                case StatusEffectType.burning:
                    return "fire";
                case StatusEffectType.wet:
                    return "ice";
                // Add more status effect -> damage type mappings as needed
            }
        }

        // If right hand weapon exists but has no special damage type, it's physical
        // Do NOT check left hand when right hand weapon exists
        return "physical";
    }

    // ONLY check left hand if NO right hand weapon is equipped
    if (_attacker.equipped.left_hand != undefined) {
        var _left_stats = _attacker.equipped.left_hand.definition.stats;

        if (variable_struct_exists(_left_stats, "damage_type")) {
            return _left_stats.damage_type;
        }

        // Infer from left hand status effects
        var _left_status_effects = get_weapon_status_effects(_left_stats);
        if (array_length(_left_status_effects) > 0) {
            switch (_left_status_effects[0].effect) {
                case StatusEffectType.burning:
                    return "fire";
                case StatusEffectType.wet:
                    return "ice";
            }
        }
    }

    return _damage_type;
}