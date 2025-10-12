// ============================================
// STATUS EFFECT HELPERS (TRAIT-DRIVEN)
// ============================================

/// @function status_effect_resolve_trait(effect_entry)
/// @description Extract trait key from a status effect entry or string
/// @return {string} Trait key or "" if not found
function status_effect_resolve_trait(_effect_entry) {
    if (is_string(_effect_entry)) {
        return _effect_entry;
    }

    if (is_struct(_effect_entry)) {
        if (variable_struct_exists(_effect_entry, "trait")) {
            return _effect_entry.trait;
        }
        if (variable_struct_exists(_effect_entry, "effect")) {
            return _effect_entry.effect;
        }
    }

    return "";
}

/// @function status_effect_normalize_entry(effect_entry)
/// @description Normalise legacy status effect definitions to trait config structs
/// @return {struct|undefined} {trait, chance, stacks, duration} or undefined if invalid
function status_effect_normalize_entry(_effect_entry) {
    var _trait_key = status_effect_resolve_trait(_effect_entry);
    if (_trait_key == "") {
        return undefined;
    }

    var _result = {
        trait: _trait_key,
        chance: 1.0,
        stacks: 1,
        duration: undefined
    };

    if (is_struct(_effect_entry)) {
        if (variable_struct_exists(_effect_entry, "chance")) {
            _result.chance = _effect_entry.chance;
        }

        if (variable_struct_exists(_effect_entry, "stacks")) {
            _result.stacks = _effect_entry.stacks;
        }

        if (variable_struct_exists(_effect_entry, "duration_seconds")) {
            _result.duration = _effect_entry.duration_seconds;
        } else if (variable_struct_exists(_effect_entry, "duration")) {
            _result.duration = _effect_entry.duration;
        }
    }

    return _result;
}

/// @function get_weapon_status_effects(item_stats)
/// @description Retrieve trait effects applied on hit by an item/weapon
/// @return {array} Normalised trait effect structs
function get_weapon_status_effects(_item_stats) {
    if (!is_struct(_item_stats)) {
        return [];
    }

    var _effects = [];

    if (variable_struct_exists(_item_stats, "status_effects")) {
        var _raw_array = _item_stats.status_effects;
        if (is_array(_raw_array)) {
            for (var i = 0; i < array_length(_raw_array); i++) {
                var _normalised = status_effect_normalize_entry(_raw_array[i]);
                if (_normalised != undefined) {
                    array_push(_effects, _normalised);
                }
            }
        }
    } else if (variable_struct_exists(_item_stats, "status_effect")) {
        var _single = {
            trait: status_effect_resolve_trait(_item_stats.status_effect),
            chance: _item_stats[$ "status_chance"] ?? 1.0,
            stacks: _item_stats[$ "status_stacks"] ?? 1
        };

        var _normalized_single = status_effect_normalize_entry(_single);
        if (_normalized_single != undefined) {
            array_push(_effects, _normalized_single);
        }
    }

    return _effects;
}

/// @function status_effect_get_trait_data(trait_key)
/// @description Fetch trait definition from global database
function status_effect_get_trait_data(_trait_key) {
    if (!variable_global_exists("trait_database")) {
        return undefined;
    }
    if (!variable_struct_exists(global.trait_database, _trait_key)) {
        return undefined;
    }
    return global.trait_database[$ _trait_key];
}

/// @function status_effect_spawn_feedback(trait_key, [stacks])
/// @description Spawn floating feedback for applied trait if configured
function status_effect_spawn_feedback(_trait_key, _stacks = 1) {
    var _trait_data = status_effect_get_trait_data(_trait_key);
    if (_trait_data == undefined) return;

    if (variable_struct_exists(_trait_data, "show_feedback") && !_trait_data.show_feedback) {
        return;
    }

    var _name = _trait_data.name ?? string_upper(_trait_key);
    var _color = _trait_data.ui_color ?? c_white;

    if (is_undefined(spawn_floating_text)) return;

    // Spawn at top of bounding box for better visibility
    var _spawn_y = y - 16;
    if (variable_instance_exists(self, "bbox_top")) {
        _spawn_y = bbox_top - 8;
    }

    spawn_floating_text(x, _spawn_y, _name, _color, self);
}

/// @function init_status_effects()
/// @description Initialise trait-based status tracking
function init_status_effects() {
    timed_traits = [];
    status_effects = []; // Legacy array retained for compatibility; no longer used
}

/// @function tick_status_effects()
/// @description Update timed trait durations (legacy wrapper)
function tick_status_effects() {
    update_timed_traits();
}

/// @function has_status_effect(effect_entry)
/// @description Wrapper using trait stacks
function has_status_effect(_effect_entry) {
    var _trait_key = status_effect_resolve_trait(_effect_entry);
    if (_trait_key == "") return false;
    return get_total_trait_stacks(_trait_key) > 0;
}

/// @function apply_status_effect(effect_entry, [duration_override], [is_permanent])
/// @description Apply trait stacks based on effect config
function apply_status_effect(_effect_entry, _duration_override = -1, _is_permanent = false) {
    var _normalized = is_struct(_effect_entry) ? status_effect_normalize_entry(_effect_entry) : undefined;
    var _trait_source = (_normalized != undefined) ? _normalized : _effect_entry;

    var _trait_key = status_effect_resolve_trait(_trait_source);
    if (_trait_key == "") return false;

    var _trait_data = status_effect_get_trait_data(_trait_key);
    show_debug_message("apply_status_effect - trait_key: " + _trait_key + ", trait_data: " + string(_trait_data != undefined ? "found" : "NOT FOUND"));
    if (_trait_data == undefined) return false;

    var _stacks = 1;
    if (_normalized != undefined && variable_struct_exists(_normalized, "stacks")) {
        _stacks = _normalized.stacks;
    }

    if (_stacks <= 0) return false;

    var _duration_seconds = (_duration_override > -1) ? _duration_override : undefined;
    show_debug_message("Duration override: " + string(_duration_override) + ", initial duration_seconds: " + string(_duration_seconds));

    if (_duration_seconds == undefined) {
        if (_normalized != undefined && variable_struct_exists(_normalized, "duration") && _normalized.duration != undefined) {
            _duration_seconds = _normalized.duration;
            show_debug_message("Got duration from normalized: " + string(_duration_seconds));
        } else if (variable_struct_exists(_trait_data, "default_duration")) {
            _duration_seconds = _trait_data.default_duration;
            show_debug_message("Got duration from trait_data.default_duration: " + string(_duration_seconds));
        } else {
            show_debug_message("NO DURATION FOUND - trait_data has no default_duration!");
        }
    }

    show_debug_message("Final duration_seconds: " + string(_duration_seconds));

    if (_is_permanent) {
        add_permanent_trait(_trait_key, _stacks);
    } else if (_duration_seconds != undefined) {
        show_debug_message("Applying timed trait: " + _trait_key + " for " + string(_duration_seconds) + "s with " + string(_stacks) + " stacks");
        apply_timed_trait(_trait_key, _duration_seconds, _stacks);
    } else {
        add_temporary_trait(_trait_key, _stacks);
    }

    status_effect_spawn_feedback(_trait_key, _stacks);
    return true;
}

/// @function remove_status_effect(effect_entry, [stacks_override])
/// @description Remove temporary/timed stacks of a trait
function remove_status_effect(_effect_entry, _stacks_override = -1) {
    var _normalized = is_struct(_effect_entry) ? status_effect_normalize_entry(_effect_entry) : undefined;
    var _trait_key = status_effect_resolve_trait((_normalized != undefined) ? _normalized : _effect_entry);
    if (_trait_key == "") return false;

    var _stacks = _stacks_override;
    if (_stacks <= 0 && _normalized != undefined && variable_struct_exists(_normalized, "stacks")) {
        _stacks = _normalized.stacks;
    }

    var _temp_available = 0;
    if (variable_instance_exists(self, "temporary_traits") && variable_struct_exists(temporary_traits, _trait_key)) {
        _temp_available = temporary_traits[$ _trait_key];
    }

    if (_stacks <= 0) {
        _stacks = _temp_available;
    } else {
        _stacks = min(_stacks, _temp_available);
    }

    if (_stacks > 0) {
        remove_temporary_trait(_trait_key, _stacks);
    }

    if (variable_instance_exists(self, "timed_traits")) {
        for (var i = array_length(timed_traits) - 1; i >= 0; i--) {
            if (timed_traits[i].trait == _trait_key) {
                if (_stacks >= timed_traits[i].stacks_applied || _stacks_override <= 0) {
                    array_delete(timed_traits, i, 1);
                } else {
                    timed_traits[i].stacks_applied = max(0, timed_traits[i].stacks_applied - _stacks);
                }
                break;
            }
        }
    }

    return _stacks > 0;
}

/// @function get_status_effect_modifier(modifier_type)
/// @description Wrapper that returns multiplicative modifier from traits
function get_status_effect_modifier(_modifier_type) {
    return get_trait_modifier(_modifier_type);
}

/// @function apply_wielder_effects(item_stats)
/// @description Apply trait effects provided while an item is equipped
function apply_wielder_effects(_item_stats) {
    if (!is_struct(_item_stats)) return;

    if (variable_struct_exists(_item_stats, "wielder_effects")) {
        var _effects = _item_stats.wielder_effects;
        if (is_array(_effects)) {
            for (var i = 0; i < array_length(_effects); i++) {
                var _entry = status_effect_normalize_entry(_effects[i]);
                if (_entry == undefined) continue;

                var _duration = (_entry.duration != undefined) ? _entry.duration : undefined;
                if (_duration != undefined) {
                    apply_timed_trait(_entry.trait, _duration, _entry.stacks ?? 1);
                } else {
                    add_temporary_trait(_entry.trait, _entry.stacks ?? 1);
                }
            }
        }
    }

    if (variable_struct_exists(_item_stats, "trait_grants")) {
        var _trait_grants = _item_stats.trait_grants;
        if (is_array(_trait_grants)) {
            for (var j = 0; j < array_length(_trait_grants); j++) {
                var _grant = _trait_grants[j];
                if (!is_struct(_grant) || !variable_struct_exists(_grant, "trait")) continue;
                var _stacks = _grant.stacks ?? 1;
                add_temporary_trait(_grant.trait, _stacks);
            }
        }
    }
}

/// @function remove_wielder_effects(item_stats)
/// @description Remove trait effects previously applied by an equipped item
function remove_wielder_effects(_item_stats) {
    if (!is_struct(_item_stats)) return;

    if (variable_struct_exists(_item_stats, "wielder_effects")) {
        var _effects = _item_stats.wielder_effects;
        if (is_array(_effects)) {
            for (var i = 0; i < array_length(_effects); i++) {
                var _entry = status_effect_normalize_entry(_effects[i]);
                if (_entry == undefined) continue;

                remove_status_effect(_entry, _entry.stacks ?? -1);
            }
        }
    }

    if (variable_struct_exists(_item_stats, "trait_grants")) {
        var _trait_grants = _item_stats.trait_grants;
        if (is_array(_trait_grants)) {
            for (var j = 0; j < array_length(_trait_grants); j++) {
                var _grant = _trait_grants[j];
                if (!is_struct(_grant) || !variable_struct_exists(_grant, "trait")) continue;
                var _stacks = _grant.stacks ?? 1;
                remove_temporary_trait(_grant.trait, _stacks);
            }
        }
    }
}

/// @function get_status_effect_name(effect_entry)
/// @description Retrieve display name from trait database
function get_status_effect_name(_effect_entry) {
    var _trait_key = status_effect_resolve_trait(_effect_entry);
    if (_trait_key == "") {
        return "Unknown";
    }

    var _trait_data = status_effect_get_trait_data(_trait_key);
    if (_trait_data == undefined) {
        return string_upper(_trait_key);
    }

    return _trait_data.name ?? string_upper(_trait_key);
}
