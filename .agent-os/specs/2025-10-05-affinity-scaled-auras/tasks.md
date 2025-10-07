# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-05-affinity-scaled-auras/spec.md

> Created: 2025-10-05
> Status: IMPLEMENTATION COMPLETE

## Tasks

- [x] 1. Implement affinity scaling formula and helper function
  - [x] 1.1 Add `get_affinity_aura_multiplier()` function to `scr_companion_system.gml` with sqrt-based diminishing returns formula
  - [x] 1.2 Verify formula produces correct multipliers: affinity 3.0 → 0.6x, affinity 10.0 → 3.0x
  - [x] 1.3 Add debug command (M key) to display affinity multipliers for all active companions
  - [x] 1.4 Test debug command shows correct multiplier values at different affinity levels

- [x] 2. Update default companion affinity
  - [x] 2.1 Change `affinity = 1.0` to `affinity = 3.0` in `obj_companion_parent/Create_0.gml`
  - [x] 2.2 Verify new companions start at affinity 3.0 on recruitment
  - [x] 2.3 Test that existing save files load correctly with affinity preservation

- [x] 3. Scale regeneration auras with affinity
  - [x] 3.1 Modify `apply_companion_regeneration_auras()` in `scr_companion_system.gml` to multiply `hp_per_tick` by affinity multiplier
  - [x] 3.2 Test Canopy's regeneration at affinity 3.0 provides ~0.3 HP/tick (0.5 base * 0.6)
  - [x] 3.3 Test Canopy's regeneration at affinity 10.0 provides ~1.5 HP/tick (0.5 base * 3.0)
  - [x] 3.4 Verify regeneration scaling with K key (boost affinity) and M key (show multipliers)

- [x] 4. Scale damage reduction auras with affinity
  - [x] 4.1 Modify `get_companion_melee_dr_bonus()` to multiply DR values by affinity multiplier
  - [x] 4.2 Modify `get_companion_ranged_dr_bonus()` to multiply DR values by affinity multiplier
  - [x] 4.3 Test Canopy's protective aura at affinity 3.0 provides ~0.6 DR (1 base * 0.6)
  - [x] 4.4 Test Canopy's protective aura at affinity 10.0 provides ~3.0 DR (1 base * 3.0)
  - [x] 4.5 Test Hola's wind_ward ranged DR scales correctly with affinity
  - [x] 4.6 Verify all companion auras scale properly across affinity range 3.0-10.0

- [x] 5. Balance testing and final verification
  - [x] 5.1 Test companion party with multiple max-affinity companions for DR stacking balance
  - [x] 5.2 Verify save/load preserves affinity and scaling works correctly after loading
  - [x] 5.3 Play-test at various affinity levels (3, 5, 7, 10) to verify progression feels rewarding
  - [x] 5.4 Document any balance adjustments needed in spec notes
