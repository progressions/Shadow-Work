# Spec Requirements Document

> Spec: Trait System
> Created: 2025-09-29
> Updated: 2025-09-30 (VERSION 2.0 - Architectural Update)
> Status: Planning

**VERSION 2.0 NOTE**: This spec has been architecturally redesigned based on Age of Wonders trait stacking mechanics, introducing tag/trait separation and opposite trait cancellation systems.

## Overview

Implement a tag-based trait system inspired by Age of Wonders mechanics, where characters have **tags** (thematic descriptors like "fireborne", "venomous", "arboreal") that grant bundles of **traits** (granular mechanical effects like "fire_immunity", "fire_resistance", "fire_vulnerability"). Traits stack up to 5 times with multiplicative mechanics, and opposite traits cancel stack-by-stack (e.g., fire_resistance vs fire_vulnerability).

The system separates thematic identity (tags) from mechanical effects (traits), allowing:
- Characters to gain permanent tags from creation or quest rewards
- Equipment, companions, and buffs to grant temporary traits
- Complex resistance interactions through trait stacking
- Single source of truth for all damage modifiers

## User Stories

### Tag-Based Enemy Creation

As a game designer, I want to assign thematic tags to enemies that automatically grant trait bundles, so that enemy creation is intuitive and maintainable.

When creating an enemy, I set `tags = ["fireborne"]` in the Create event. The fireborne tag automatically grants permanent traits: fire_immunity (1 stack), ice_vulnerability (1 stack), fire_aura (1 stack). These traits apply during combat and can interact with temporary traits from equipment or buffs.

### Trait Stacking from Multiple Sources

As a player, I want resistances from different sources to stack multiplicatively, so that building specialized defenses feels rewarding.

My character has fire_resistance (1 stack) from the "heat_adapted" tag and gains fire_resistance (1 stack) from equipped "Flameguard Armor". Total: 2 stacks of fire_resistance. Each stack reduces fire damage by 25% multiplicatively: 0.75 × 0.75 = 0.5625x final damage (43.75% reduction). Attacking with a burning torch that deals 100 fire damage, I take only 56 damage.

### Opposite Trait Cancellation

As a player, I want negative traits to cancel positive traits stack-by-stack, creating strategic counterplay opportunities.

An enemy has fire_resistance (3 stacks) from the "salamander" tag. I cast a debuff spell that applies fire_vulnerability (2 stacks). The opposite traits cancel: 3 resistance - 2 vulnerability = net 1 stack of fire_resistance remaining. The enemy now takes 0.75x fire damage instead of 0.75³ = 0.421x damage.

### Equipment-Based Temporary Traits

As a player, I want equipment to grant traits while equipped and remove them when unequipped, so that equipment choices affect my resistances.

When I equip "Frostbane Gauntlets", I gain ice_resistance (1 stack) and cold_touch (1 stack) as temporary traits. While wearing them, ice attacks deal 0.75x damage to me. When I unequip the gauntlets, both temporary traits are removed and ice damage returns to normal.

### Immunity Trait Behavior

As a player, I want immunity traits to make me completely immune regardless of additional stacks, so that thematic invulnerabilities feel absolute.

My character has fire_immunity (1 stack) from the "fireborne" tag. Gaining additional fire_immunity stacks from equipment doesn't change the effect—1+ stacks = complete immunity. However, if I gain fire_vulnerability (2 stacks), it cancels fire_immunity (1 stack), leaving me with net fire_vulnerability (1 stack), taking 1.5x fire damage.

## Spec Scope

1. **Tag Database** - `global.tag_database` defining thematic tags and the permanent trait bundles they grant
2. **Trait Database** - `global.trait_database` defining individual traits with stack limits, effect values, and opposite trait relationships
3. **Character Trait Storage** - Characters have `permanent_traits` and `temporary_traits` structs (not arrays) storing trait stacks
4. **Trait Stacking System** - Add/remove traits with stack counting, max 5 stacks per trait
5. **Opposite Trait Cancellation** - Resistance/vulnerability pairs cancel stack-by-stack when calculating final modifiers
6. **Damage Type Expansion** - Extend damage types to include: physical, magical, fire, ice, lightning, poison, disease, holy, unholy
7. **Equipment Integration** - Modify `apply_wielder_effects()` and `remove_wielder_effects()` to grant/remove temporary traits instead of setting `damage_resistances` directly
8. **Damage System Integration** - Modify collision-based damage to calculate final modifiers from net trait stacks
9. **Debug Commands** - Runtime trait manipulation for testing stacking and cancellation

## Out of Scope

- Player tag assignment (player starts with no tags)
- Tag UI/visual indicators
- Companion aura traits (future feature)
- Spell buff trait system (future feature)
- Quest reward permanent trait granting (future feature)
- Environmental terrain movement modifiers
- Trait-based ability unlocks

## Expected Deliverable

1. Tag system where assigning `tags = ["fireborne"]` to an enemy automatically grants fire_immunity, ice_vulnerability, and fire_aura traits
2. Trait stacking where 2 stacks of fire_resistance result in 0.75² = 0.5625x fire damage taken
3. Opposite trait cancellation where fire_resistance (3) + fire_vulnerability (2) = net fire_resistance (1)
4. Equipment granting temporary traits via `apply_wielder_effects()` integration
5. Immunity traits providing complete immunity at 1+ stacks (unless cancelled by opposite vulnerability)
6. Fire damage against arboreal enemy (fire_vulnerability 1 stack) results in 1.5x damage
7. Fire damage against fireborne enemy (fire_immunity 1+ stacks) results in 0 damage
8. Debug commands to add/remove trait stacks and observe final damage calculations

## Spec Documentation

- Tasks: @.agent-os/specs/2025-09-29-trait-system/tasks.md
- Technical Specification: @.agent-os/specs/2025-09-29-trait-system/sub-specs/technical-spec.md
