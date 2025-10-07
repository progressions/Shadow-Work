# Spec Requirements Document

> Spec: Projectile Range Falloff
> Created: 2025-10-07

## Overview

Introduce distance-based damage falloff curves for arrow-like projectiles so longbows reward long shots while crossbows stay deadly up close, giving each ranged weapon a distinct identity.

## User Stories

### Longbow Ranger: Rewarded Long Shots

As a longbow-focused player, I want my arrows to deal full damage when they land at long range so that landing distant hits feels meaningfully stronger than point-blank shots.

**Workflow:**
1. Equip a longbow and engage enemies several tiles away.
2. Fire arrows; damage numbers show reduced output at point-blank, climbing to 1.0x once arrows travel through the longbow's optimal window.
3. Shots beyond the optimal window lose power, signaling the need to reposition.

### Crossbow Skirmisher: Close-Range Edge

As a crossbow user, I want the weapon to hit hardest at short-to-mid range so that I can kite nearby foes without outperforming longbows at range.

**Workflow:**
1. Equip a crossbow and fight enemies within one to two screen lengths.
2. Observe 1.0x damage inside the crossbow's short optimal band and reduced damage once bolts travel past that band.
3. Adjust spacing to stay within the high-damage window.

### Combat Designer: Tune Range Profiles

As a combat designer, I want to define ideal-range bands per projectile so that I can balance new bows or spells by adjusting data instead of touching core code.

**Workflow:**
1. Set profile parameters (point-blank penalty, optimal window, falloff cap) in the item database or projectile definition.
2. Playtest in debug mode to view distance, multiplier, and resulting damage.
3. Adjust profile values until the weapon meets its intended feel.

## Spec Scope

1. **Range Profile Definitions** - Add configurable range-damage profile structs that specify point-blank penalty, optimal band, and long-range falloff for projectile weapons.
2. **Projectile Distance Tracking** - Have projectile objects capture spawn coordinates, accumulate distance traveled, and expose the active damage multiplier.
3. **Damage Pipeline Integration** - Apply the distance multiplier before resistance/DR calculations for both player and enemy projectiles while preserving existing crit, status, and trait interactions.
4. **Data Updates & Defaults** - Assign tailored profiles to wooden bows, longbows, crossbows, heavy crossbows, and enemy arrows, with safe defaults for any projectile lacking explicit data.
5. **Debug Feedback Hooks** - Gate optional debugging output that surfaces current distance and multiplier when `global.debug_mode` is enabled (no UI changes in normal play).

## Out of Scope

- Introducing new projectile trajectories, gravity, or spread mechanics.
- Rebalancing enemy health, armor, or drop tables beyond range damage tuning.
- Creating new UI widgets or HUD elements beyond debug-only readouts.
- Implementing ammo types or elemental arrows (handled by other specs).

## Expected Deliverable

1. Projectile damage automatically scales by distance using per-weapon range profiles for players and enemies.
2. Longbows peak at distant hits while crossbows and heavy crossbows peak closer to the shooter, matching design intent.
3. Designers can tweak range behavior through data-only updates without editing projectile logic.
