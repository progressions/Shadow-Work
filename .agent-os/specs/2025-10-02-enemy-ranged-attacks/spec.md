# Spec Requirements Document

> Spec: Enemy Ranged Attacks System
> Created: 2025-10-02

## Overview

Implement a reusable ranged attack system for enemies, starting with the Greenwood Bandit, that allows enemies to fire projectiles at the player using the existing `obj_enemy_arrow` object. This system will be designed for extensibility, enabling easy configuration of any enemy as a ranged attacker and supporting future development of hybrid ranged/melee enemy behaviors.

## User Stories

### Ranged Enemy Combat

As a player, I want to encounter enemies that can attack me from a distance, so that I face more diverse combat scenarios and must adapt my tactics beyond melee range.

The player enters an area and encounters a Greenwood Bandit enemy. Instead of running directly at the player to engage in melee combat, the bandit stops at a distance and fires arrows. Each arrow travels across the screen, dealing damage if it hits the player. The ranged attack creates strategic depth, forcing the player to dodge projectiles, close the distance, or use their own ranged weapons to counter-attack.

### Enemy Configuration Simplicity

As a developer, I want to easily configure any enemy as a ranged attacker, so that I can quickly create diverse enemy types without rewriting attack logic.

By setting a simple flag or property (e.g., `is_ranged_attacker = true`) and defining ranged-specific stats (`ranged_damage`, `ranged_attack_cooldown`), any enemy inheriting from `obj_enemy_parent` can immediately use the ranged attack system. The Greenwood Bandit serves as the reference implementation, but the system is designed to work for any enemy with minimal configuration.

### Future Hybrid Combat Design

As a developer, I want the ranged attack system to support future hybrid ranged/melee behaviors, so that I can create enemies that intelligently switch between attack methods based on distance or other conditions.

The system architecture includes separate cooldown timers (`attack_cooldown` for melee, `ranged_attack_cooldown` for ranged) and a dedicated `EnemyState.ranged_attacking` state. This design allows future development of logic to switch between ranged and melee attacks, such as enemies using bows at range and switching to swords when the player closes distance.

## Spec Scope

1. **New Enemy State** - Add `EnemyState.ranged_attacking` to support dedicated ranged attack behavior
2. **Enemy Parent Properties** - Add configurable properties to `obj_enemy_parent`: `is_ranged_attacker`, `ranged_damage`, `ranged_attack_cooldown`
3. **Ranged Attack Function** - Implement `enemy_handle_ranged_attack()` function that spawns `obj_enemy_arrow` projectiles
4. **Projectile Spawning** - Configure arrow spawn position, direction, damage, and movement based on enemy facing direction
5. **Greenwood Bandit Configuration** - Set Greenwood Bandit as a ranged attacker with appropriate damage and cooldown values

## Out of Scope

- AI behavior changes (pathfinding, distance management, targeting) - will be addressed in a separate pass
- Enemy movement during ranged attacks - enemies stop to shoot in this implementation
- Ranged/melee switching logic - system is designed to support this but implementation comes later
- Ammo management for enemies - enemies have infinite ammo
- Enemy arrow recovery or drop mechanics
- Unique projectile types per enemy (all use `obj_enemy_arrow` for now)
- Visual effects or animations beyond basic projectile movement

## Expected Deliverable

1. Greenwood Bandit enemy fires arrows at the player when in attack range, dealing configurable damage
2. System is reusable: any enemy can become a ranged attacker by setting `is_ranged_attacker = true` and defining ranged stats
3. Separate cooldown timers for ranged and melee attacks allow future hybrid combat implementations
