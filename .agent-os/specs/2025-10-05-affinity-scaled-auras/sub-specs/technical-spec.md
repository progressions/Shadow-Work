# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-05-affinity-scaled-auras/spec.md

## Technical Requirements

### Scaling Formula

Implement a diminishing returns scaling formula that provides:
- **At affinity 3.0**: ~0.6x multiplier (60% of current baseline)
- **At affinity 10.0**: 3.0x multiplier (300% of current baseline)
- **Curve shape**: Stronger gains early, diminishing returns at high affinity

**Recommended formula:**
```gml
function get_affinity_aura_multiplier(affinity) {
    // Normalized affinity from 0-1 based on range 3.0-10.0
    var normalized = clamp((affinity - 3.0) / 7.0, 0, 1);

    // Diminishing returns curve: 0.6 + (2.4 * sqrt(normalized))
    // sqrt provides diminishing returns
    var multiplier = 0.6 + (2.4 * sqrt(normalized));

    return multiplier;
}
```

**Multiplier curve examples:**
- Affinity 3.0: 0.6x (60%)
- Affinity 4.0: ~0.97x
- Affinity 5.0: ~1.26x
- Affinity 6.0: ~1.51x
- Affinity 7.0: ~1.72x
- Affinity 8.0: ~1.92x
- Affinity 9.0: ~2.10x
- Affinity 10.0: 3.0x (300%)

### Default Affinity Update

Change companion default affinity in `obj_companion_parent/Create_0.gml`:
```gml
affinity = 3.0;  // Changed from 1.0
```

### Aura Scaling Implementation

**Files to modify:**

1. **`scripts/scr_companion_system/scr_companion_system.gml`**
   - Add `get_affinity_aura_multiplier()` helper function
   - Modify `apply_companion_regeneration_auras()` to scale `hp_per_tick` by multiplier
   - Modify `get_companion_melee_dr_bonus()` to scale DR values by multiplier
   - Modify `get_companion_ranged_dr_bonus()` to scale DR values by multiplier

2. **`objects/obj_canopy/Create_0.gml`** (and all other companion Create events)
   - Aura values remain as "base" values
   - Actual effectiveness calculated at runtime using multiplier

**Implementation pattern:**
```gml
// Example: Applying regeneration with affinity scaling
var base_regen = companion.auras.regeneration.hp_per_tick;
var multiplier = get_affinity_aura_multiplier(companion.affinity);
var scaled_regen = base_regen * multiplier;

player_instance.hp = min(
    player_instance.hp + scaled_regen,
    player_instance.hp_total
);
```

### DR Caps and Balance

**Existing DR caps:**
- Player melee DR: Typically capped at reasonable levels (verify in combat system)
- Enemy DR: Capped at 3 (from enemy auras system)

**Scaling considerations:**
- At affinity 10, Canopy's protective aura (1 DR base) becomes 3 DR
- Multiple companions at max affinity could stack significantly
- Consider global DR caps in player combat calculations if needed

**Recommendation:** Monitor balance during testing and adjust caps if companion stacking becomes overpowered.

### Debug Commands

Add debug key to `obj_player/Step_0.gml` to test scaling:

```gml
// Debug key: H - Show affinity aura multipliers for all companions
if (keyboard_check_pressed(ord("H"))) {
    show_debug_message("=== AFFINITY AURA SCALING ===");
    with (obj_companion_parent) {
        if (is_recruited) {
            var multiplier = get_affinity_aura_multiplier(affinity);
            show_debug_message(companion_name + " (Affinity " + string(affinity) + "):");
            show_debug_message("  Multiplier: " + string(multiplier) + "x");

            // Show scaled aura values
            if (variable_struct_exists(auras, "regeneration") && auras.regeneration.active) {
                var base_regen = auras.regeneration.hp_per_tick;
                show_debug_message("  Regen: " + string(base_regen) + " -> " + string(base_regen * multiplier) + " HP/tick");
            }
            if (variable_struct_exists(auras, "protective") && auras.protective.active) {
                var base_dr = auras.protective.dr_bonus;
                show_debug_message("  DR: " + string(base_dr) + " -> " + string(base_dr * multiplier));
            }
        }
    }
    show_debug_message("============================");
}
```

### Companion Auras to Scale

Based on existing companion system:

**Canopy (obj_canopy):**
- `protective` aura: DR bonus scales
- `regeneration` aura: HP per tick scales

**Hola (obj_hola):**
- `wind_ward` aura: Ranged DR scales

**Other companions:** Apply same multiplier pattern to all passive auras when implemented.

### Testing Requirements

1. Verify regeneration healing at affinity 3.0 provides ~0.3 HP/tick (0.5 base * 0.6)
2. Verify regeneration healing at affinity 10.0 provides ~1.5 HP/tick (0.5 base * 3.0)
3. Verify protective DR at affinity 3.0 provides ~0.6 DR (1 base * 0.6)
4. Verify protective DR at affinity 10.0 provides ~3.0 DR (1 base * 3.0)
5. Test with existing K debug key (boosts affinity +1) combined with H debug key (shows multipliers)
6. Verify companions start at affinity 3.0 when recruited
7. Check that save/load preserves affinity and scaling works correctly on load

## External Dependencies

None - uses existing GML functions and companion system architecture.
