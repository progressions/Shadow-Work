# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-08-hola-companion-abilities/spec.md

> Created: 2025-10-08
> Version: 1.0.0

## Technical Requirements

### 1. Slowing Aura Implementation

**Location:** `/scripts/scr_companion_system/scr_companion_system.gml`

**New Function:** `apply_companion_slowing_auras(player_instance)`

```gml
/// @function apply_companion_slowing_auras(player_instance)
/// @description Apply slowing effects from companion auras to nearby enemies
/// @param {instance} player_instance The player instance
function apply_companion_slowing_auras(player_instance) {
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Hola's slowing aura
        if (variable_struct_exists(companion.auras, "slowing") && companion.auras.slowing.active) {
            var aura = companion.auras.slowing;
            var multiplier = get_affinity_aura_multiplier(companion.affinity);
            var scaled_slow = aura.slow_percent * multiplier;
            var radius = aura.radius;

            // Apply to all enemies in radius
            with (obj_enemy_parent) {
                if (state != EnemyState.dead &&
                    point_distance(x, y, player_instance.x, player_instance.y) < radius) {

                    // Apply slowing effect via status effect system
                    if (!has_status_effect("companion_slowing")) {
                        apply_status_effect({
                            trait: "slowed",
                            slow_percent: scaled_slow,
                            duration: 2, // Refresh every 2 frames
                            source: "companion_slowing"
                        });
                    }
                }
            }
        }
    }
}
```

**Integration Point:** Call in `update_companion_effects(player_instance)` function, executed every frame from companion Step event management

**Alternative Approach (Direct Speed Modifier):**
Instead of using status effects, directly modify enemy `move_speed` with a companion slow multiplier:

```gml
// In obj_enemy_parent/Step_0.gml or state functions
var companion_slow_mult = 1.0;

// Check for Hola's slowing aura
var companions = get_active_companions();
for (var i = 0; i < array_length(companions); i++) {
    var companion = companions[i];
    if (companion.companion_id == "hola" &&
        variable_struct_exists(companion.auras, "slowing") &&
        companion.auras.slowing.active) {

        var dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);
        if (dist_to_player < companion.auras.slowing.radius) {
            var multiplier = get_affinity_aura_multiplier(companion.affinity);
            var slow_amount = companion.auras.slowing.slow_percent * multiplier;
            companion_slow_mult = 1.0 - slow_amount;
        }
    }
}

// Apply to movement calculations
var final_speed = move_speed * terrain_speed_modifier * status_speed_modifier * companion_slow_mult;
```

**Recommended:** Use direct speed modifier approach for better performance (avoid per-enemy status effect overhead)

### 2. Slipstream Passive Aura

**Location:** `/scripts/player_handle_dash_cooldown/player_handle_dash_cooldown.gml`

**Modification:** Add passive aura check after base reduction

```gml
function player_handle_dash_cooldown() {
    if (dash_cooldown > 0) {
        // Base cooldown reduction
        var _reduction = 1;

        // EXISTING: Check for Slipstream Boost trigger
        var companions = get_active_companions();
        for (var i = 0; i < array_length(companions); i++) {
            var companion = companions[i];

            if (variable_struct_exists(companion.triggers, "slipstream_boost")) {
                var trigger = companion.triggers.slipstream_boost;
                if (trigger.active && variable_instance_exists(companion, "slipstream_boost_timer") && companion.slipstream_boost_timer > 0) {
                    _reduction += trigger.dash_cd_boost; // Add 35% boost
                }
            }

            // NEW: Check for passive slipstream aura
            if (variable_struct_exists(companion.auras, "slipstream") && companion.auras.slipstream.active) {
                var aura = companion.auras.slipstream;
                var multiplier = get_affinity_aura_multiplier(companion.affinity);
                var scaled_reduction = aura.dash_cd_reduction * multiplier;
                _reduction += scaled_reduction; // Add 20% passive boost (scaled)
            }
        }

        dash_cooldown = max(0, dash_cooldown - _reduction);
    }
}
```

**Scaling Example:**
- Affinity 3.0: 20% × 0.6 = 12% passive reduction
- Affinity 5.0: 20% × 1.0 = 20% passive reduction
- Affinity 10.0: 20% × 3.0 = 60% passive reduction

**Stack Behavior:** Passive aura and active trigger stack additively (both can be active simultaneously)

### 3. Maelstrom Deflection Bonus

**Location:** `/objects/obj_enemy_arrow/Step_0.gml`

**Modification:** Add deflection bonus check in wind deflection section (lines 1-38)

```gml
// Check for Hola's wind deflection aura (passive trajectory alteration)
if (instance_exists(obj_player)) {
    var companions = get_active_companions();
    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Check for Hola with affinity 5+
        if (companion.companion_id == "hola" && companion.affinity >= 5.0) {
            if (variable_struct_exists(companion.auras, "wind_deflection") && companion.auras.wind_deflection.active) {
                var aura = companion.auras.wind_deflection;
                var dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);

                // Only deflect if within radius
                if (dist_to_player <= aura.radius) {
                    var base_deflect_chance = aura.deflect_chance; // 25% base

                    // NEW: Add Maelstrom deflection bonus
                    var bonus_deflection = 0;
                    if (variable_struct_exists(companion.triggers, "maelstrom") &&
                        companion.triggers.maelstrom.active &&
                        variable_instance_exists(companion, "maelstrom_deflect_timer") &&
                        companion.maelstrom_deflect_timer > 0) {

                        bonus_deflection = companion.triggers.maelstrom.deflect_bonus; // +25%
                    }

                    var total_deflect_chance = base_deflect_chance + bonus_deflection;

                    // Scale by affinity
                    var affinity_scale = (companion.affinity - 5.0) / 5.0;
                    total_deflect_chance *= (1.0 + affinity_scale);

                    // Roll for deflection
                    if (random(1) < total_deflect_chance) {
                        // Calculate deflection strength...
                        // [existing deflection logic continues]
                    }
                }
            }
        }
    }
}
```

**Deflection Chance Examples:**
- Base (affinity 5.0): 25% chance
- With Maelstrom (affinity 5.0): 50% chance (25% + 25% bonus)
- With Maelstrom (affinity 10.0): 100% chance (capped)

### 4. Affinity Scaling Integration

All three features use existing `get_affinity_aura_multiplier(affinity)` function:

**Formula:** `0.6 + (2.4 * sqrt((affinity - 3.0) / 7.0))`

**Scaling Curve:**
- Affinity 3.0: 0.6x (60%)
- Affinity 5.0: 1.0x (100%)
- Affinity 7.0: 1.66x (166%)
- Affinity 10.0: 3.0x (300%)

### 5. Debug Integration

**Location:** `/objects/obj_player/Step_0.gml` (O key debug output, lines 260-279)

**Add to Hola section:**

```gml
if (keyboard_check_pressed(ord("O"))) {
    // [existing trait debug output]

    // Show Hola-specific aura status if recruited
    var companions = get_active_companions();
    for (var i = 0; i < array_length(companions); i++) {
        var comp = companions[i];
        if (comp.companion_id == "hola") {
            show_debug_message("=== HOLA AURA STATUS ===");
            show_debug_message("Affinity: " + string(comp.affinity));
            var mult = get_affinity_aura_multiplier(comp.affinity);
            show_debug_message("Aura Multiplier: " + string(mult) + "x");

            if (variable_struct_exists(comp.auras, "slowing") && comp.auras.slowing.active) {
                var base_slow = comp.auras.slowing.slow_percent;
                show_debug_message("Slowing Aura: " + string(base_slow * 100) + "% -> " + string(base_slow * mult * 100) + "%");
            }

            if (variable_struct_exists(comp.auras, "slipstream") && comp.auras.slipstream.active) {
                var base_cd = comp.auras.slipstream.dash_cd_reduction;
                show_debug_message("Slipstream Passive: " + string(base_cd * 100) + "% -> " + string(base_cd * mult * 100) + "%");
            }

            if (variable_struct_exists(comp.triggers, "maelstrom") && comp.triggers.maelstrom.active) {
                show_debug_message("Maelstrom Active: deflect_timer=" + string(comp.maelstrom_deflect_timer));
            }
        }
    }
}
```

## Performance Considerations

**Slowing Aura Optimization:**
- Use direct speed multiplier instead of status effects to avoid per-enemy overhead
- Check distance only once per enemy per frame
- Early exit if Hola not recruited or aura inactive

**Dash Cooldown Check:**
- Minimal overhead (single loop through companions)
- Only runs when `dash_cooldown > 0`

**Deflection Bonus:**
- Integrates into existing deflection check (no additional collision checks)
- Timer already managed in companion update loop

## Testing Checklist

1. **Slowing Aura:**
   - [ ] Recruit Hola, verify enemies within 120px move slower
   - [ ] Test at affinity 3.0 (30% slow), 5.0 (50% slow), 10.0 (150% slow capped)
   - [ ] Verify enemies outside radius move at normal speed
   - [ ] Confirm aura deactivates when Hola dismissed

2. **Slipstream Passive:**
   - [ ] Measure dash cooldown recovery rate without Hola
   - [ ] Recruit Hola, verify 20% faster recovery at affinity 5.0
   - [ ] Test stacking with Slipstream Boost trigger (55% total)
   - [ ] Verify scaling at affinity 3.0 (12%) and 10.0 (60%)

3. **Maelstrom Deflection:**
   - [ ] Trigger Maelstrom (4+ enemies, affinity 10)
   - [ ] Observe increased projectile deflection for 4 seconds
   - [ ] Verify timer countdown and deactivation
   - [ ] Test with multiple projectiles simultaneously

4. **Debug Output:**
   - [ ] Press O key with Hola recruited
   - [ ] Verify all aura stats displayed with correct scaling
   - [ ] Confirm multiplier calculation matches formula
