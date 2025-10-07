/// @description Projectile range profile helpers and data
/// Spec: @.agent-os/specs/2025-10-07-projectile-range-falloff/spec.md

enum RangeProfile {
    generic_arrow,
    wooden_bow,
    longbow,
    crossbow,
    heavy_crossbow,
    enemy_shortbow
}

/// @function projectile_range_profiles_init(_force)
/// @description Populate global projectile range profile data
/// @param {boolean} _force Rebuild profiles even if already initialized
function projectile_range_profiles_init(_force = false) {
    if (!variable_global_exists("projectile_range_profiles_initialized")) {
        global.projectile_range_profiles_initialized = false;
    }

    if (global.projectile_range_profiles_initialized && !_force) {
        return;
    }

    var _profile_template = [
        {
            id: RangeProfile.generic_arrow,
            name: "generic_arrow",
            point_blank_distance: 32,
            point_blank_multiplier: 0.7,
            optimal_start: 96,
            optimal_end: 144,
            max_distance: 224,
            long_range_multiplier: 0.55,
            overshoot_buffer: 32
        },
        {
            id: RangeProfile.wooden_bow,
            name: "wooden_bow",
            point_blank_distance: 32,
            point_blank_multiplier: 0.6,
            optimal_start: 96,
            optimal_end: 160,
            max_distance: 240,
            long_range_multiplier: 0.5,
            overshoot_buffer: 32
        },
        {
            id: RangeProfile.longbow,
            name: "longbow",
            point_blank_distance: 148,
            point_blank_multiplier: 0.5,
            optimal_start: 160,
            optimal_end: 260,
            max_distance: 340,
            long_range_multiplier: 0.6,
            overshoot_buffer: 48
        },
        {
            id: RangeProfile.crossbow,
            name: "crossbow",
            point_blank_distance: 24,
            point_blank_multiplier: 0.55,
            optimal_start: 64,
            optimal_end: 120,
            max_distance: 200,
            long_range_multiplier: 0.4,
            overshoot_buffer: 24
        },
        {
            id: RangeProfile.heavy_crossbow,
            name: "heavy_crossbow",
            point_blank_distance: 32,
            point_blank_multiplier: 0.6,
            optimal_start: 96,
            optimal_end: 160,
            max_distance: 260,
            long_range_multiplier: 0.5,
            overshoot_buffer: 32
        },
        {
            id: RangeProfile.enemy_shortbow,
            name: "enemy_shortbow",
            point_blank_distance: 32,
            point_blank_multiplier: 0.65,
            optimal_start: 80,
            optimal_end: 140,
            max_distance: 220,
            long_range_multiplier: 0.55,
            overshoot_buffer: 32
        }
    ];

    var _count = array_length(_profile_template);
    global.projectile_range_profiles = array_create(_count);

    for (var i = 0; i < _count; i++) {
        var _profile = _profile_template[i];
        global.projectile_range_profiles[_profile.id] = _profile;
    }

    global.projectile_range_profiles_initialized = true;
}

/// @function projectile_get_range_profile(_profile_id)
/// @description Retrieve a copy of the projectile range profile for the given id
function projectile_get_range_profile(_profile_id) {
    if (!global.projectile_range_profiles_initialized) {
        projectile_range_profiles_init();
    }

    if (is_undefined(_profile_id)) {
        _profile_id = RangeProfile.generic_arrow;
    }

    var _profile = undefined;

    if (is_array(global.projectile_range_profiles)) {
        if (_profile_id >= 0 && _profile_id < array_length(global.projectile_range_profiles)) {
            _profile = global.projectile_range_profiles[_profile_id];
        }
    }

    if (_profile == undefined) {
        _profile = projectile_create_default_profile();
    }

    return projectile_clone_profile(_profile);
}

/// @function projectile_get_range_profile_ref(_profile_id)
/// @description Retrieve a direct reference (no copy) to the stored profile
function projectile_get_range_profile_ref(_profile_id) {
    if (!global.projectile_range_profiles_initialized) {
        projectile_range_profiles_init();
    }

    if (is_undefined(_profile_id)) {
        _profile_id = RangeProfile.generic_arrow;
    }

    if (!is_array(global.projectile_range_profiles)) {
        projectile_range_profiles_init(true);
    }

    if (!is_array(global.projectile_range_profiles)) {
        return projectile_create_default_profile();
    }

    if (_profile_id < 0 || _profile_id >= array_length(global.projectile_range_profiles)) {
        return projectile_create_default_profile();
    }

    var _profile = global.projectile_range_profiles[_profile_id];
    if (_profile == undefined) {
        return projectile_create_default_profile();
    }

    return _profile;
}

/// @function projectile_clone_profile(_profile)
/// @description Create a shallow copy of a projectile range profile (avoids struct_copy dependency)
function projectile_clone_profile(_profile) {
    if (_profile == undefined) {
        return undefined;
    }

    return {
        id: _profile.id,
        name: _profile.name,
        point_blank_distance: _profile.point_blank_distance,
        point_blank_multiplier: _profile.point_blank_multiplier,
        optimal_start: _profile.optimal_start,
        optimal_end: _profile.optimal_end,
        max_distance: _profile.max_distance,
        long_range_multiplier: _profile.long_range_multiplier,
        overshoot_buffer: _profile.overshoot_buffer
    };
}

/// @function projectile_calculate_damage_multiplier(_profile, _distance)
/// @description Calculate the damage multiplier for a travelled distance using the provided profile
function projectile_calculate_damage_multiplier(_profile, _distance) {
    if (_profile == undefined) {
        _profile = projectile_get_range_profile(RangeProfile.generic_arrow);
    }

    _distance = max(0, _distance);

    var _pb_dist = max(1, _profile.point_blank_distance);

    if (_distance <= _profile.point_blank_distance) {
        var _t = _distance / _pb_dist;
        return lerp(_profile.point_blank_multiplier, 1.0, clamp(_t, 0, 1));
    }

    if (_distance <= _profile.optimal_end) {
        return 1.0;
    }

    var _falloff_span = max(1, _profile.max_distance - _profile.optimal_end);
    var _t_falloff = clamp((_distance - _profile.optimal_end) / _falloff_span, 0, 1);
    return lerp(1.0, _profile.long_range_multiplier, _t_falloff);
}

/// @function projectile_distance_should_cull(_profile, _distance)
/// @description Determine if the projectile should be cleaned up based on max distance and buffer
function projectile_distance_should_cull(_profile, _distance) {
    if (_profile == undefined) {
        _profile = projectile_get_range_profile(RangeProfile.generic_arrow);
    }

    return _distance > (_profile.max_distance + _profile.overshoot_buffer);
}

/// @function projectile_debug_collect_range_samples(_profile_id, _distances)
/// @description Return multipliers for a list of travel distances (used for manual tuning)
function projectile_debug_collect_range_samples(_profile_id, _distances) {
    var _profile = projectile_get_range_profile(_profile_id);
    var _results = [];

    if (!is_array(_distances)) {
        return _results;
    }

    for (var i = 0; i < array_length(_distances); i++) {
        var _distance = _distances[i];
        var _multiplier = projectile_calculate_damage_multiplier(_profile, _distance);
        array_push(_results, {
            distance: _distance,
            multiplier: _multiplier
        });
    }

    return _results;
}

/// @function projectile_range_profiles_self_test()
/// @description Run quick sanity checks across all profiles (logs failures in debug mode)
function projectile_range_profiles_self_test() {
    var _profiles = [
        RangeProfile.generic_arrow,
        RangeProfile.wooden_bow,
        RangeProfile.longbow,
        RangeProfile.crossbow,
        RangeProfile.heavy_crossbow,
        RangeProfile.enemy_shortbow
    ];

    var _results = [];

    for (var i = 0; i < array_length(_profiles); i++) {
        var _profile_id = _profiles[i];
        var _profile = projectile_get_range_profile(_profile_id);

        var _checks = [
            { label: "PB", distance: _profile.point_blank_distance, expected: _profile.point_blank_multiplier },
            { label: "OPT", distance: (_profile.optimal_start + _profile.optimal_end) * 0.5, expected: 1.0 },
            { label: "FAR", distance: _profile.max_distance + 16, expected: _profile.long_range_multiplier }
        ];

        for (var j = 0; j < array_length(_checks); j++) {
            var _check = _checks[j];
            var _value = projectile_calculate_damage_multiplier(_profile, _check.distance);
            var _diff = abs(_value - _check.expected);
            var _passed = _diff <= 0.01;

            array_push(_results, {
                profile_id: _profile_id,
                profile_name: _profile.name,
                label: _check.label,
                distance: _check.distance,
                expected: _check.expected,
                observed: _value,
                passed: _passed
            });

            if (!_passed && variable_global_exists("debug_mode") && global.debug_mode) {
                show_debug_message("[RangeProfile Self-Test] " + _profile.name + " " + _check.label + " FAILED -> expected " + string_format(_check.expected, 0, 3) + ", observed " + string_format(_value, 0, 3));
            }
        }
    }

    return _results;
}

/// @function projectile_create_default_profile()
/// @description Fallback profile used when requested data is missing
function projectile_create_default_profile() {
    return {
        id: RangeProfile.generic_arrow,
        name: "fallback_generic_arrow",
        point_blank_distance: 32,
        point_blank_multiplier: 0.75,
        optimal_start: 96,
        optimal_end: 144,
        max_distance: 224,
        long_range_multiplier: 0.55,
        overshoot_buffer: 32
    };
}
