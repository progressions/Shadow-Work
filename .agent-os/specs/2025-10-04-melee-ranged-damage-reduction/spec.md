# Spec Requirements Document

> Spec: Melee and Ranged Damage Reduction System
> Created: 2025-10-04

## Overview

Implement a comprehensive damage reduction system that differentiates between melee and ranged attacks, allowing equipment, traits, status effects, and companion auras to provide general, melee-specific, or ranged-specific damage reduction. This system will enable more strategic gameplay where shields excel at blocking projectiles, and companions like Hola can specialize in ranged damage mitigation.

## User Stories

### Strategic Equipment Choices

As a player, I want shields to provide better protection against ranged attacks than melee attacks, so that I can make tactical equipment decisions based on the enemy types I'm facing.

When equipped with a shield, the player gains moderate melee damage reduction (defense stat) but substantial ranged damage reduction, making shields particularly valuable against archer enemies and ranged attackers. This creates meaningful choice: do I equip a shield for ranged protection, or dual-wield/two-hand for more offense?

### Companion-Based Damage Mitigation

As a player, I want Hola's wind-based aura to reduce incoming ranged damage when she's in my party, so that I feel the tactical benefit of recruiting and keeping specific companions active.

When Hola is recruited and following the player, her wind_ward aura provides a flat ranged damage reduction bonus that stacks with equipment-based ranged DR. This is visible in combat through reduced damage numbers when hit by arrows or projectiles, reinforcing the companion's thematic wind control abilities.

### Clear Damage Categorization

As a player, I want to understand whether incoming damage is melee or ranged (in addition to damage type like fire/physical), so that I can better strategize my defense and equipment loadout.

All attacks in the game are categorized as either melee (obj_attack, obj_enemy_attack) or ranged (obj_arrow, obj_enemy_arrow), with this categorization determining which damage reduction values apply during damage calculation. Debug displays and eventual UI will show both the attack category (melee/ranged) and damage type (physical/fire/ice/etc).

## Spec Scope

1. **Damage Reduction Stats System** - Add support for general `damage_reduction`, `melee_damage_reduction`, and `ranged_damage_reduction` on equipment, traits, status effects, and companion auras
2. **Attack Categorization** - Tag all attack objects (obj_attack, obj_arrow, obj_enemy_attack, obj_enemy_arrow) with attack category (melee or ranged)
3. **Damage Calculation Refactor** - Update all damage calculation code to check attack category and apply the appropriate DR values
4. **Shield Item Updates** - Modify shield definitions to remove `block_chance` and add separate `melee_damage_reduction` and `ranged_damage_reduction` stats
5. **Hola Aura Integration** - Update Hola's wind_ward aura to provide `ranged_damage_reduction` instead of generic `projectile_dr`

## Out of Scope

- Block chance mechanics (removed entirely)
- Critical hit system modifications
- Armor penetration mechanics
- Enemy-specific damage reduction (enemies receiving reduced damage)
- UI visualization of DR stats (debug display only for now)

## Expected Deliverable

1. Player can equip a shield and observe reduced damage from ranged attacks (higher reduction) versus melee attacks (lower reduction) in debug output
2. Hola companion, when recruited, provides ranged damage reduction that visibly reduces projectile damage in combat
3. All attack objects properly tagged with attack category, and damage calculations correctly apply melee vs ranged DR based on attack type
