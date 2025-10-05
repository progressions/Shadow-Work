# Affinity-Scaled Auras - Testing Guide

## Overview

This guide provides step-by-step instructions for testing the affinity-based aura scaling system.

## Code Changes Summary

### Files Modified

1. **`scripts/scr_companion_system/scr_companion_system.gml`**
   - Added `get_affinity_aura_multiplier()` function (lines 5-18)
   - Modified `get_companion_melee_dr_bonus()` to scale DR by affinity (lines 33-81)
   - Modified `get_companion_ranged_dr_bonus()` to scale DR by affinity (lines 87-135)
   - Modified `apply_companion_regeneration_auras()` to scale regen by affinity (lines 137-162)

2. **`objects/obj_companion_parent/Create_0.gml`**
   - Changed default `affinity = 1.0` to `affinity = 3.0` (line 43)

3. **`objects/obj_player/Step_0.gml`**
   - Added debug key **H** to show affinity aura multipliers (lines 332-357)
   - Existing debug key **K** boosts Canopy affinity +1 (lines 317-330)

## Expected Scaling Behavior

### Formula
- **Affinity 3.0**: 0.6x multiplier (60% of base value)
- **Affinity 10.0**: 3.0x multiplier (300% of base value)
- **Curve**: Diminishing returns using sqrt function

### Canopy's Auras (Base Values)

| Aura Type | Base Value | Affinity 3.0 | Affinity 5.0 | Affinity 7.0 | Affinity 10.0 |
|-----------|------------|--------------|--------------|--------------|---------------|
| Regeneration | 0.5 HP/tick | 0.3 HP/tick | 0.63 HP/tick | 0.86 HP/tick | 1.5 HP/tick |
| Protective DR | 1 DR | 0.6 DR | 1.26 DR | 1.72 DR | 3.0 DR |

### Hola's Wind Ward (Base Value: 3 Ranged DR)

| Affinity | Scaled Ranged DR |
|----------|------------------|
| 3.0 | 1.8 DR |
| 5.0 | 3.78 DR |
| 7.0 | 5.16 DR |
| 10.0 | 9.0 DR |

## In-Game Testing Instructions

### Test 1: Basic Functionality

1. **Start the game** and recruit Canopy
2. **Press H** to show aura multipliers
3. **Verify output:**
   ```
   Canopy (Affinity 3.0):
     Multiplier: 0.6x
     Regen: 0.5 -> 0.3 HP/tick
     Protective DR: 1 -> 0.6
   ```

### Test 2: Affinity Scaling

1. **Recruit Canopy** (starts at affinity 3.0)
2. **Press K** seven times to reach affinity 10.0
3. **Press H** after each K press to observe scaling
4. **Verify progression:**
   - Multiplier increases from 0.6x → 3.0x
   - Regeneration scales from 0.3 → 1.5 HP/tick
   - Protective DR scales from 0.6 → 3.0

### Test 3: Regeneration Healing

1. **Recruit Canopy** at affinity 3.0
2. **Take damage** to reduce HP
3. **Wait 1 second** (60 frames at 60fps)
4. **Verify:** HP increases by ~0.3
5. **Press K** to boost affinity to 10.0
6. **Take damage** again
7. **Wait 1 second**
8. **Verify:** HP increases by ~1.5

### Test 4: DR Stacking (Balance Test)

1. **Recruit multiple companions** (if Hola is available)
2. **Press K** to boost all to max affinity
3. **Press H** to see total DR contribution
4. **Engage in combat** and verify DR feels balanced
5. **Check:** Multiple max-affinity companions shouldn't make player invincible

### Test 5: Save/Load Persistence

1. **Recruit Canopy** and boost affinity to 7.0
2. **Press F5** to save
3. **Press H** to note current multiplier (should be ~1.72x)
4. **Press F9** to load
5. **Press H** again
6. **Verify:** Affinity preserved at 7.0, multiplier still ~1.72x

### Test 6: Combat Feel Progression

Test at different affinity levels to verify progression feels rewarding:

1. **Affinity 3.0** (new companion):
   - Should feel noticeably weaker than old system
   - Player should feel motivated to increase affinity

2. **Affinity 5.0-6.0** (mid-level bond):
   - Should feel roughly equivalent to old fixed values
   - Noticeable improvement from affinity 3.0

3. **Affinity 8.0-10.0** (max bond):
   - Should feel significantly more powerful
   - Reward for relationship investment should be clear

## Debug Commands Reference

- **K**: Boost Canopy affinity by +1 (max 10.0)
- **H**: Display all companion affinity multipliers and scaled aura values

## Expected Debug Output (H Key)

```
=== AFFINITY AURA SCALING ===
Canopy (Affinity 3.0):
  Multiplier: 0.6x
  Regen: 0.5 -> 0.3 HP/tick
  Protective DR: 1 -> 0.6
============================
```

After pressing K to reach affinity 10.0:

```
=== AFFINITY AURA SCALING ===
Canopy (Affinity 10.0):
  Multiplier: 3.0x
  Regen: 0.5 -> 1.5 HP/tick
  Protective DR: 1 -> 3.0
============================
```

## Balance Notes

Monitor during testing:

1. **Early game feel** - Is affinity 3.0 too weak for new companions?
2. **Mid-game progression** - Does affinity growth feel rewarding?
3. **End-game power** - Are max-affinity companions overpowered?
4. **Multiple companions** - Does DR stacking need caps?

## Known Issues / Edge Cases

- **None identified** - System uses existing save/load infrastructure
- Triggers (Shield, Guardian Veil, etc.) remain unscaled by design
- Trigger unlocks still based on affinity thresholds (5+, 8+, 10)

## Balance Adjustment Recommendations

If testing reveals balance issues:

1. **Too weak at affinity 3.0:**
   - Adjust formula minimum from 0.6 to 0.7 or 0.8
   - Change `var multiplier = 0.6 + (2.4 * sqrt(normalized));`
   - To `var multiplier = 0.7 + (2.3 * sqrt(normalized));`

2. **Too powerful at affinity 10.0:**
   - Adjust formula maximum from 3.0 to 2.5 or 2.0
   - Reduce the multiplier coefficient

3. **DR stacking too strong:**
   - Add global DR cap in combat system
   - Consider diminishing returns for multiple companions

Document any changes in `spec.md` notes section.
