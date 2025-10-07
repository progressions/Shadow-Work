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

/// @function add_permanent_trait(trait_key, [stacks])
/// @description Add permanent trait stacks (from tags, quest rewards)
/// @param {string} trait_key The trait to add
/// @param {real} [stacks] Number of stacks to add (default 1)
/// @return {real} Actual stacks added
function add_permanent_trait(_trait_key, _stacks = 1) {
    if (!variable_instance_exists(self, "permanent_traits")) {
        permanent_traits = {};
    }

    if (_stacks <= 0) {
        return 0;
    }

    var _current = variable_struct_exists(permanent_traits, _trait_key) ? permanent_traits[$ _trait_key] : 0;
    var _trait_data = undefined;
    if (variable_global_exists("trait_database") && variable_struct_exists(global.trait_database, _trait_key)) {
        _trait_data = global.trait_database[$ _trait_key];
    }
    var _max_stacks = (_trait_data != undefined && variable_struct_exists(_trait_data, "max_stacks"))
        ? _trait_data.max_stacks
        : 5;

    var _space = max(0, _max_stacks - min(_current, _max_stacks));
    var _stacks_to_add = min(_stacks, _space);

    if (_stacks_to_add <= 0) {
        return 0;
    }

    permanent_traits[$ _trait_key] = _current + _stacks_to_add;
    return _stacks_to_add;
}

/// @function add_temporary_trait(trait_key, [stacks])
/// @description Add temporary trait stacks (from equipment, companions, buffs)
/// @param {string} trait_key The trait to add
/// @param {real} [stacks] Number of stacks to add (default 1)
/// @return {real} Actual stacks added (0 if none)
function add_temporary_trait(_trait_key, _stacks = 1) {
    if (!variable_instance_exists(self, "temporary_traits")) {
        temporary_traits = {};
    }

    if (_stacks <= 0) {
        return 0;
    }

    var _current_temp = variable_struct_exists(temporary_traits, _trait_key) ? temporary_traits[$ _trait_key] : 0;
    var _current_perm = 0;

    if (variable_instance_exists(self, "permanent_traits") && variable_struct_exists(permanent_traits, _trait_key)) {
        _current_perm = permanent_traits[$ _trait_key];
    }

    var _trait_data = undefined;
    if (variable_global_exists("trait_database") && variable_struct_exists(global.trait_database, _trait_key)) {
        _trait_data = global.trait_database[$ _trait_key];
    }
    var _max_stacks = (_trait_data != undefined && variable_struct_exists(_trait_data, "max_stacks"))
        ? _trait_data.max_stacks
        : 5;

    var _current_total = min(_current_perm + _current_temp, _max_stacks);
    var _space = max(0, _max_stacks - _current_total);
    var _stacks_to_add = min(_stacks, _space);

    if (_stacks_to_add <= 0) {
        return 0;
    }

    temporary_traits[$ _trait_key] = _current_temp + _stacks_to_add;
    return _stacks_to_add;
}

/// @function remove_temporary_trait(trait_key, [stacks])
/// @description Remove temporary trait stacks (when unequipping, buff expires)
/// @param {string} trait_key The trait to remove
/// @param {real} [stacks] Number of stacks to remove (default 1)
/// @return {real} Actual stacks removed
function remove_temporary_trait(_trait_key, _stacks = 1) {
    if (!variable_instance_exists(self, "temporary_traits")) return 0;
    if (!variable_struct_exists(temporary_traits, _trait_key)) return 0;

    if (_stacks <= 0) {
        return 0;
    }

    var _current = temporary_traits[$ _trait_key];
    var _removed = min(_current, _stacks);
    _current -= _removed;

    if (_current <= 0) {
        variable_struct_remove(temporary_traits, _trait_key);
    } else {
        temporary_traits[$ _trait_key] = _current;
    }

    return _removed;
}

/// @function apply_timed_trait(trait_key, duration_seconds, [stacks], [options])
/// @description Apply a temporary trait that expires after a duration
/// @param {string} trait_key The trait to apply
/// @param {real} duration_seconds How long the trait lasts in seconds
/// @param {real} [stacks] Number of stacks to apply (default 1)
/// @param {struct} [options] Optional settings {refresh:true, use_frames:true}
/// @return {real} Actual stacks applied (0 if blocked)
function apply_timed_trait(_trait_key, _duration_seconds, _stacks = 1, _options = undefined) {
    // Initialize timed traits tracking if needed
    if (!variable_instance_exists(self, "timed_traits")) {
        timed_traits = [];
    }

    var _trait_data = undefined;
    if (variable_global_exists("trait_database") && variable_struct_exists(global.trait_database, _trait_key)) {
        _trait_data = global.trait_database[$ _trait_key];
    }
    if (_trait_data == undefined) {
        return 0;
    }

    var _blocked_by = (variable_struct_exists(_trait_data, "blocked_by")) ? _trait_data.blocked_by : undefined;
    if (is_array(_blocked_by)) {
        for (var b = 0; b < array_length(_blocked_by); b++) {
            if (has_trait(_blocked_by[b])) {
                show_debug_message("Timed trait blocked by: " + _blocked_by[b]);
                return 0;
            }
        }
    }

    var _duration_frames;
    if (_options != undefined && variable_struct_exists(_options, "use_frames") && _options.use_frames) {
        _duration_frames = max(1, round(_duration_seconds));
    } else {
        _duration_frames = max(1, round(_duration_seconds * room_speed));
    }

    var _stacks_added = add_temporary_trait(_trait_key, _stacks);
    if (_stacks_added <= 0) {
        return 0;
    }

    var _existing_index = -1;
    for (var i = 0; i < array_length(timed_traits); i++) {
        if (timed_traits[i].trait == _trait_key) {
            _existing_index = i;
            break;
        }
    }

    var _max_stacks = (variable_struct_exists(_trait_data, "max_stacks")) ? _trait_data.max_stacks : 5;
    var _refresh_existing = true;
    if (_options != undefined && variable_struct_exists(_options, "refresh")) {
        _refresh_existing = _options.refresh;
    }

    if (_existing_index == -1) {
        array_push(timed_traits, {
            trait: _trait_key,
            timer: _duration_frames,
            total_duration: _duration_frames,
            stacks_applied: _stacks_added,
            tick_timer: 0
        });
    } else {
        var _entry = timed_traits[_existing_index];
        _entry.stacks_applied = min(_entry.stacks_applied + _stacks_added, _max_stacks);

        if (_refresh_existing) {
            _entry.timer = max(_entry.timer, _duration_frames);
            _entry.total_duration = max(_entry.total_duration, _duration_frames);
        }

        timed_traits[_existing_index] = _entry;
    }

    show_debug_message("Applied timed trait: " + _trait_key + " +" + string(_stacks_added) + " for " + string(_duration_seconds) + " seconds");
    return _stacks_added;
}

/// @function update_timed_traits()
/// @description Update all timed trait timers and remove expired traits (call in Step event)
function update_timed_traits() {
    if (!variable_instance_exists(self, "timed_traits")) return;

    var _traits_to_remove = [];

    // Update timers
    for (var i = 0; i < array_length(timed_traits); i++) {
        var _entry = timed_traits[i];
        var _trait_key = _entry.trait;
        var _trait_data = global.trait_database[$ _trait_key];

        _entry.timer--;

        if (_entry.timer <= 0) {
            _entry.timer = 0;
            timed_traits[i] = _entry;

            var _removed = remove_temporary_trait(_trait_key, _entry.stacks_applied);
            show_debug_message("Timed trait expired: " + _trait_key + " (-" + string(_removed) + ")");
            array_push(_traits_to_remove, i);
            continue;
        }

        if (_trait_data != undefined && variable_struct_exists(_trait_data, "tick_damage")) {
            if (!variable_struct_exists(_entry, "tick_timer")) {
                _entry.tick_timer = 0;
            }

            _entry.tick_timer++;

            var _tick_rate = room_speed;
            if (variable_struct_exists(_trait_data, "tick_rate_seconds")) {
                _tick_rate = max(1, round(_trait_data.tick_rate_seconds * room_speed));
            } else if (variable_struct_exists(_trait_data, "tick_rate")) {
                _tick_rate = _trait_data.tick_rate;
            }

            if (_entry.timer > 0 && _entry.tick_timer >= _tick_rate) {
                var _net_stacks = get_effective_trait_stacks(_trait_key);
                if (_net_stacks > 0) {
                    var _damage = _trait_data.tick_damage * _net_stacks;
                    hp -= _damage;

                    spawn_damage_number(x, y - 16, _damage, _trait_data.damage_type, self);

                    if (hp <= 0) {
                        if (object_index == obj_player) {
                            state = PlayerState.dead;
                            show_debug_message("Player died from " + _trait_data.name);
                        } else if (object_is_ancestor(object_index, obj_enemy_parent)) {
                            state = EnemyState.dead;
                            show_debug_message("Enemy died from " + _trait_data.name);
                        }
                    }
                }
                _entry.tick_timer = 0;
            }
        }

        timed_traits[i] = _entry;

        // Timer already handled above; any entry reaching zero has been queued for removal
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

/// @function get_effective_trait_stacks(trait_key)
/// @description Net positive stacks after cancelling opposing trait stacks
/// @param {string} trait_key
/// @return {real} Net stacks (0 if fully cancelled)
function get_effective_trait_stacks(_trait_key) {
    var _stacks = get_total_trait_stacks(_trait_key);
    if (_stacks <= 0) {
        return 0;
    }

    var _trait_data = global.trait_database[$ _trait_key];
    if (_trait_data != undefined && variable_struct_exists(_trait_data, "opposite_trait")) {
        var _opposite = _trait_data.opposite_trait;
        if (_opposite != undefined) {
            var _opp_stacks = get_total_trait_stacks(_opposite);
            _stacks = max(0, _stacks - _opp_stacks);
        }
    }

    return _stacks;
}

/// @function get_trait_modifier(modifier_key)
/// @description Aggregate multiplicative modifier from active traits
/// @param {string} modifier_key ("speed", "damage", etc.)
/// @return {real} Multiplier (1.0 = unchanged)
function get_trait_modifier(_modifier_key) {
    var _modifier = 1.0;

    if (!variable_global_exists("trait_database")) {
        return _modifier;
    }

    var _trait_keys = variable_struct_get_names(global.trait_database);
    for (var i = 0; i < array_length(_trait_keys); i++) {
        var _trait_key = _trait_keys[i];
        var _trait_data = global.trait_database[$ _trait_key];

        if (_trait_data == undefined) continue;
        if (!variable_struct_exists(_trait_data, "modifiers")) continue;
        if (!variable_struct_exists(_trait_data.modifiers, _modifier_key)) continue;

        var _net_stacks = get_effective_trait_stacks(_trait_key);
        if (_net_stacks <= 0) continue;

        var _per_stack = _trait_data.modifiers[$ _modifier_key];
        if (_per_stack == undefined) continue;

        _modifier *= power(_per_stack, _net_stacks);
    }

    return _modifier;
}

/// @function get_active_timed_trait_data()
/// @description Get array of active timed trait info for UI display
/// @return {array} [{trait, remaining, total, stacks, effective_stacks}]
function get_active_timed_trait_data() {
    if (!variable_instance_exists(self, "timed_traits")) {
        return [];
    }

    var _results = [];

    for (var i = 0; i < array_length(timed_traits); i++) {
        var _entry = timed_traits[i];
        var _trait_key = _entry.trait;
        var _trait_data = global.trait_database[$ _trait_key];
        if (_trait_data == undefined) continue;

        var _show = !variable_struct_exists(_trait_data, "show_timer") || _trait_data.show_timer;
        if (!_show) continue;

        var _remaining = max(0, _entry.timer);
        var _total = max(_remaining, _entry.total_duration ?? _remaining);
        var _effective = get_effective_trait_stacks(_trait_key);
        var _total_stacks = get_total_trait_stacks(_trait_key);

        array_push(_results, {
            trait: _trait_key,
            remaining: _remaining,
            total: _total,
            stacks: _total_stacks,
            effective_stacks: _effective
        });
    }

    return _results;
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

    // Check each layer in priority order (lava > water > path > forest)
    var _layers_to_check = ["Tiles_Lava", "Tiles_Water_Moving", "Tiles_Water", "Tiles_Path", "Tiles_Forest"];

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
            var _trait_key = status_effect_resolve_trait(_status_effects[0]);
            switch (_trait_key) {
                case "burning":
                    return "fire";
                case "wet":
                    return "ice";
                case "poisoned":
                    return "poison";
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
            var _left_trait = status_effect_resolve_trait(_left_status_effects[0]);
            switch (_left_trait) {
                case "burning":
                    return "fire";
                case "wet":
                    return "ice";
                case "poisoned":
                    return "poison";
            }
        }
    }

    return _damage_type;
}

/// @function apply_terrain_effects()
/// @description Apply terrain-based traits and speed modifiers (call in Step event)
function apply_terrain_effects() {
    var _terrain = get_terrain_at_position(x, y);
    var _terrain_data = global.terrain_effects_map[$ _terrain];

    if (_terrain_data == undefined) {
        _terrain_data = global.terrain_effects_map[$ "grass"]; // Default
    }

    // Apply speed modifier (direct modification)
    terrain_speed_modifier = _terrain_data.speed_modifier;

    // Track terrain traits
    var _new_terrain_traits = {};

    // Apply traits from current terrain
    var _traits_to_apply = _terrain_data.traits;
    for (var i = 0; i < array_length(_traits_to_apply); i++) {
        var _trait_key = _traits_to_apply[i];
        _new_terrain_traits[$ _trait_key] = true;

        // Only apply trait if we haven't already applied it from this terrain
        if (!variable_struct_exists(terrain_applied_traits, _trait_key)) {
            apply_status_effect(_trait_key); // Shows floating text feedback
        }
    }

    // Terrain traits persist after leaving (expire naturally via timer)
    terrain_applied_traits = _new_terrain_traits;
    current_terrain = _terrain;
}
