# Centralized Aura Processing System Architecture

This document describes the centralized aura processing system that automatically handles affinity scaling for all companion auras.

## Current Pattern (Already Implemented)

The codebase already has a centralized pattern for DR auras:

```gml
function get_companion_ranged_dr_bonus() {
    var total_dr = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];
        var multiplier = get_affinity_aura_multiplier(companion.affinity);

        var _aura_names = variable_struct_get_names(companion.auras);
        for (var j = 0; j < array_length(_aura_names); j++) {
            var _aura = companion.auras[$ _aura_names[j]];
            if (_aura.active && variable_struct_exists(_aura, "ranged_damage_reduction")) {
                total_dr += _aura.ranged_damage_reduction * multiplier;
            }
        }
    }
    return total_dr;
}
```

**Key insight:** Auras automatically scale with affinity when processed through these centralized functions!

## Proposed Extension: Universal Aura Getter

Create a generic function that can retrieve any aura property with automatic affinity scaling:

```gml
/// @function get_companion_aura_value(property_name, [sum_mode])
/// @description Get scaled aura values for a specific property from all active companions
/// @param {string} property_name The aura property to query (e.g., "slow_percent", "dash_cd_reduction")
/// @param {bool} [sum_mode=true] If true, sum all values; if false, return highest value
/// @return {real} The scaled aura value (summed or max)
function get_companion_aura_value(property_name, sum_mode = true) {
    var total_value = 0;
    var max_value = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];
        var multiplier = get_affinity_aura_multiplier(companion.affinity);

        // Check all auras for the requested property
        var _aura_names = variable_struct_get_names(companion.auras);
        for (var j = 0; j < array_length(_aura_names); j++) {
            var _aura = companion.auras[$ _aura_names[j]];

            if (_aura.active && variable_struct_exists(_aura, property_name)) {
                var scaled_value = _aura[$ property_name] * multiplier;

                if (sum_mode) {
                    total_value += scaled_value;
                } else {
                    max_value = max(max_value, scaled_value);
                }
            }
        }
    }

    return sum_mode ? total_value : max_value;
}
```

## Specialized Aura Getters (Recommended Approach)

Instead of one generic function, create specialized functions for each aura category:

### 1. Speed Modifier Auras

```gml
/// @function get_companion_enemy_slow()
/// @description Get enemy speed slow multiplier from companion auras
/// @param {real} enemy_x Enemy x position
/// @param {real} enemy_y Enemy y position
/// @return {real} Speed multiplier (0.0-1.0, where 0.5 = 50% slow)
function get_companion_enemy_slow(enemy_x, enemy_y) {
    var total_slow = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];
        var multiplier = get_affinity_aura_multiplier(companion.affinity);

        // Check slowing auras
        var _aura_names = variable_struct_get_names(companion.auras);
        for (var j = 0; j < array_length(_aura_names); j++) {
            var _aura = companion.auras[$ _aura_names[j]];

            if (_aura.active && variable_struct_exists(_aura, "slow_percent")) {
                // Check radius if defined
                if (variable_struct_exists(_aura, "radius")) {
                    var dist = point_distance(enemy_x, enemy_y, obj_player.x, obj_player.y);
                    if (dist > _aura.radius) continue;
                }

                total_slow += _aura.slow_percent * multiplier;
            }
        }
    }

    // Return speed multiplier (clamped to prevent negative speed)
    return clamp(1.0 - total_slow, 0.1, 1.0);
}
```

### 2. Cooldown Reduction Auras

```gml
/// @function get_companion_dash_cd_reduction()
/// @description Get total dash cooldown reduction from companion auras
/// @return {real} Cooldown reduction multiplier (additive)
function get_companion_dash_cd_reduction() {
    var total_reduction = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];
        var multiplier = get_affinity_aura_multiplier(companion.affinity);

        // Check all auras for dash CD reduction
        var _aura_names = variable_struct_get_names(companion.auras);
        for (var j = 0; j < array_length(_aura_names); j++) {
            var _aura = companion.auras[$ _aura_names[j]];

            if (_aura.active && variable_struct_exists(_aura, "dash_cd_reduction")) {
                total_reduction += _aura.dash_cd_reduction * multiplier;
            }
        }

        // Also check triggers for active CD reduction bonuses
        var _trigger_names = variable_struct_get_names(companion.triggers);
        for (var j = 0; j < array_length(_trigger_names); j++) {
            var _trigger = companion.triggers[$ _trigger_names[j]];

            if (_trigger.active && variable_struct_exists(_trigger, "dash_cd_boost")) {
                total_reduction += _trigger.dash_cd_boost; // Triggers don't scale
            }
        }
    }

    return total_reduction;
}
```

### 3. Deflection Bonus Auras

```gml
/// @function get_companion_deflection_bonus()
/// @description Get total projectile deflection bonus from companion auras/triggers
/// @param {string} companion_id Optional: specific companion to check
/// @return {real} Deflection chance bonus (0.0-1.0)
function get_companion_deflection_bonus(companion_id = undefined) {
    var total_deflection = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Filter by companion_id if specified
        if (companion_id != undefined && companion.companion_id != companion_id) {
            continue;
        }

        // Check for active deflection bonuses from triggers (e.g., Maelstrom)
        var _trigger_names = variable_struct_get_names(companion.triggers);
        for (var j = 0; j < array_length(_trigger_names); j++) {
            var _trigger = companion.triggers[$ _trigger_names[j]];

            if (_trigger.active && variable_struct_exists(_trigger, "deflect_bonus")) {
                // Check for timer variable if needed
                var timer_var = _trigger_names[j] + "_deflect_timer";
                if (variable_instance_exists(companion, timer_var)) {
                    if (companion[$ timer_var] > 0) {
                        total_deflection += _trigger.deflect_bonus;
                    }
                } else {
                    total_deflection += _trigger.deflect_bonus;
                }
            }
        }
    }

    return total_deflection;
}
```

## Usage Examples

### Enemy Movement Speed (Slowing Aura)

**Before (manual):**
```gml
// In enemy step event - VERBOSE!
var slow_mult = 1.0;
var companions = get_active_companions();
for (var i = 0; i < array_length(companions); i++) {
    var companion = companions[i];
    if (companion.companion_id == "hola" &&
        variable_struct_exists(companion.auras, "slowing") &&
        companion.auras.slowing.active) {
        var dist = point_distance(x, y, obj_player.x, obj_player.y);
        if (dist < companion.auras.slowing.radius) {
            var multiplier = get_affinity_aura_multiplier(companion.affinity);
            slow_mult = 1.0 - (companion.auras.slowing.slow_percent * multiplier);
        }
    }
}
var final_speed = move_speed * slow_mult;
```

**After (centralized):**
```gml
// In enemy step event - CLEAN!
var slow_mult = get_companion_enemy_slow(x, y);
var final_speed = move_speed * slow_mult;
```

### Dash Cooldown Reduction

**Before (manual):**
```gml
// In player_handle_dash_cooldown - VERBOSE!
var _reduction = 1;
var companions = get_active_companions();
for (var i = 0; i < array_length(companions); i++) {
    var companion = companions[i];

    // Check trigger
    if (variable_struct_exists(companion.triggers, "slipstream_boost")) {
        if (companion.triggers.slipstream_boost.active) {
            _reduction += companion.triggers.slipstream_boost.dash_cd_boost;
        }
    }

    // Check passive aura
    if (variable_struct_exists(companion.auras, "slipstream")) {
        if (companion.auras.slipstream.active) {
            var multiplier = get_affinity_aura_multiplier(companion.affinity);
            _reduction += companion.auras.slipstream.dash_cd_reduction * multiplier;
        }
    }
}
dash_cooldown = max(0, dash_cooldown - _reduction);
```

**After (centralized):**
```gml
// In player_handle_dash_cooldown - CLEAN!
var _reduction = 1 + get_companion_dash_cd_reduction();
dash_cooldown = max(0, dash_cooldown - _reduction);
```

### Deflection Bonus

**Before (manual):**
```gml
// In obj_enemy_arrow - VERBOSE!
var base_deflect = 0.25;
var bonus_deflect = 0;

var companions = get_active_companions();
for (var i = 0; i < array_length(companions); i++) {
    var companion = companions[i];
    if (companion.companion_id == "hola") {
        if (variable_struct_exists(companion.triggers, "maelstrom") &&
            companion.triggers.maelstrom.active &&
            companion.maelstrom_deflect_timer > 0) {
            bonus_deflect += companion.triggers.maelstrom.deflect_bonus;
        }
    }
}

var total_deflect = base_deflect + bonus_deflect;
```

**After (centralized):**
```gml
// In obj_enemy_arrow - CLEAN!
var base_deflect = 0.25;
var total_deflect = base_deflect + get_companion_deflection_bonus("hola");
```

## Implementation Benefits

1. **No Manual Scaling:** Individual implementations never need to call `get_affinity_aura_multiplier()` - it's automatic
2. **Consistent Behavior:** All auras scale the same way across the entire codebase
3. **Easy to Add Auras:** Just add the property to the aura struct, the system picks it up automatically
4. **Readable Code:** Implementation code is clean and self-documenting
5. **Single Source of Truth:** Affinity scaling logic lives in one place
6. **Easy Testing:** Can test aura system independently of game logic

## Aura Property Naming Conventions

To work with the centralized system, aura structs should use these standard property names:

### Speed & Movement
- `slow_percent` - Enemy speed reduction (0.0-1.0)
- `speed_boost` - Player speed increase (0.0-1.0)
- `radius` - Effect radius in pixels (optional, defaults to global)

### Damage Reduction
- `damage_reduction` - General DR (applies to all damage)
- `melee_damage_reduction` - Melee-specific DR
- `ranged_damage_reduction` - Ranged-specific DR
- `dr_bonus` - Generic DR bonus

### Cooldown Reduction
- `dash_cd_reduction` - Dash cooldown reduction multiplier (0.2 = 20%)
- `ability_cd_reduction` - Generic ability cooldown reduction

### Offensive Bonuses
- `attack_bonus` - Flat attack damage increase
- `crit_bonus` - Critical hit chance increase (0.0-1.0)

### Defensive Bonuses
- `deflect_chance` - Projectile deflection chance (0.0-1.0)
- `deflect_bonus` - Temporary deflection bonus from triggers

### Regeneration
- `hp_per_tick` - HP regeneration per tick
- `tick_interval` - Frames between ticks

## Migration Strategy

1. **Phase 1:** Add new centralized getter functions (non-breaking)
2. **Phase 2:** Refactor Hola's missing features to use new functions (immediate benefit)
3. **Phase 3:** Gradually migrate existing aura code to use centralized system
4. **Phase 4:** Deprecate manual affinity scaling in implementation code

## Example: Complete Hola Aura Struct

With centralized processing, Hola's auras just need clean property definitions:

```gml
auras = {
    slowing: {
        active: false,
        slow_percent: 0.50,  // ← Automatically scaled by affinity
        radius: 120
    },
    wind_ward: {
        active: false,
        ranged_damage_reduction: 3  // ← Automatically scaled by affinity
    },
    wind_deflection: {
        active: false,
        deflect_chance: 0.25,  // ← Automatically scaled by affinity
        radius: 64
    },
    slipstream: {
        active: false,
        dash_cd_reduction: 0.20  // ← Automatically scaled by affinity
    }
};
```

**No multiplier code needed anywhere else!**
