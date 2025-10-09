# Spec Requirements Document

> Spec: Complete Hola Companion Abilities Implementation
> Created: 2025-10-08
> Status: Planning

## Overview

Implement the missing passive auras and trigger effects for Hola the wind sorceress companion to match her design documentation. Currently, only 4 of 7 features are fully functional - this spec will complete the slowing aura, slipstream passive aura, and maelstrom deflection bonus to establish Hola's identity as the battlefield control specialist.

## User Stories

### Battlefield Control Through Wind Magic

As a player who recruited Hola, I want her to create a constant slowing field around me that affects all nearby enemies, so that I can control enemy positioning and feel her wind magic actively shaping combat encounters.

When Hola is in my party, all enemies within 120 pixels of my character should move 50% slower, creating a visible strategic advantage that makes her battlefield control theme tangible and rewarding.

### Passive Dash Cooldown Reduction

As a player with high mobility gameplay, I want Hola's passive slipstream aura to reduce my dash cooldown at all times, so that I can dash more frequently and experience her wind magic empowering my movement.

With Hola recruited, my dash cooldown should recover 20% faster passively (stacking with her active Slipstream Boost trigger), making her valuable for aggressive, mobile playstyles.

### Ultimate Deflection Power

As a player who activated Hola's Maelstrom ultimate, I want the deflection bonus to actually increase my projectile deflection chance for 4 seconds, so that the ability delivers on its promise of enhanced wind ward protection during critical moments.

After Maelstrom triggers (requiring 4+ nearby enemies and affinity 10), enemy projectiles should have +25% additional deflection chance on top of the base Wind Deflection aura for 4 seconds, creating a powerful defensive window.

## Spec Scope

1. **Centralized Aura Getter Functions** - Create specialized getter functions (`get_companion_enemy_slow()`, `get_companion_dash_cd_reduction()`, `get_companion_deflection_bonus()`) in `scr_companion_system.gml` that automatically apply affinity scaling to any aura property, following the existing pattern used by `get_companion_melee_dr_bonus()` and `get_companion_ranged_dr_bonus()`
2. **Slowing Aura Implementation** - Use new `get_companion_enemy_slow()` function in enemy movement calculations to apply 50% speed reduction to enemies within 120px radius (no manual scaling needed)
3. **Slipstream Passive Aura** - Use new `get_companion_dash_cd_reduction()` function in `player_handle_dash_cooldown.gml` for 20% passive cooldown reduction (no manual scaling needed)
4. **Maelstrom Deflection Bonus** - Use new `get_companion_deflection_bonus()` function in `obj_enemy_arrow/Step_0.gml` for +25% deflection during trigger window (no manual scaling needed)
5. **Testing & Debug Commands** - Add debug output for all Hola auras and verify centralized system works correctly at different affinity levels

## Out of Scope

- Creating new companion abilities beyond the three missing features
- Modifying Hola's existing working features (Wind Ward, Wind Deflection, Gust, Slipstream Boost)
- Adding visual effects or particles for the auras (use existing systems only)
- Changing Hola's trigger unlock thresholds or cooldown values
- Implementing abilities for other companions

## Expected Deliverable

1. Enemies within 120px of player move 50% slower when Hola is recruited (visible in gameplay)
2. Dash cooldown recovers 20% faster passively with Hola in party (testable with dash timing)
3. Maelstrom ultimate provides +25% deflection for 4 seconds after activation (observable with projectile deflection)
4. All three features scale with affinity from 0.6x at affinity 3.0 to 3.0x at affinity 10.0
5. Debug key (O) shows slowing aura status and all aura multipliers for Hola

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-08-hola-companion-abilities/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-08-hola-companion-abilities/sub-specs/technical-spec.md
- Aura System Architecture: @.agent-os/specs/2025-10-08-hola-companion-abilities/sub-specs/aura-system-architecture.md
