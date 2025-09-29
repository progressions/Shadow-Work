# Spec Requirements Document

> Spec: Trait System
> Created: 2025-09-29

## Overview

Implement a modular trait system for characters that allows data-driven gameplay effects based on character origins and attributes. Traits are lowercase string identifiers (e.g., "fireborne", "arboreal") that characters can possess, with each trait providing specific gameplay effects defined in a centralized configuration.

## User Stories

### Enemy with Environmental Traits

As a game designer, I want to assign traits to enemies through simple array configuration, so that I can quickly define enemy strengths and weaknesses without modifying code.

When creating an enemy, I set `traits = ["arboreal", "aquatic"]` in the enemy's Create event. The enemy automatically receives all trait effects (fire vulnerability, lightning vulnerability, water movement bonuses) from the trait database. These effects apply during combat and environmental interactions without additional code.

### Fire Damage Against Trait-Based Enemies

As a player, I want enemies with different traits to react differently to damage types, so that combat feels strategic and varied.

When attacking an arboreal enemy with a burning torch, the enemy takes 150% fire damage due to their fire vulnerability trait. When attacking a fireborne enemy with the same torch, they take 0 damage (immune). The damage modifiers apply automatically based on the weapon's damage type and the target's traits.

### Movement Speed in Different Terrains

As a player, I want trait-based enemies to move differently across terrain types, so that enemy behavior feels authentic to their nature.

An aquatic enemy moves 50% faster through water tiles but 200% slower on land. A sandcrawler moves 50% faster on desert tiles. These movement modifiers apply automatically based on the terrain type under the character and their traits.

## Spec Scope

1. **Trait Database** - Centralized `global.trait_database` with trait definitions including damage modifiers, environmental effects, and immunity flags
2. **Character Trait Storage** - Add `traits = []` array to `obj_player` and `obj_enemy_parent` for storing active trait keys
3. **Trait Helper Functions** - Create `has_trait()`, `add_trait()`, `remove_trait()`, `get_trait_effect()`, and trait modifier calculation functions
4. **Damage System Integration** - Modify existing damage calculations in collision events to apply trait-based damage modifiers (fire, ice, poison, lightning, etc.)
5. **Debug Commands** - Add keyboard shortcuts to add/remove traits during testing

## Out of Scope

- Player trait assignment (player starts with no traits)
- Trait UI/visual indicators
- Trait interactions (e.g., damage_vs_arboreal bonuses)
- Equipment granting traits
- Status effects granting traits
- Environmental movement speed modifiers (terrain-based speed changes)

## Expected Deliverable

1. Enemies can be assigned traits via array in Create event (e.g., `traits = ["fireborne"]`) and automatically receive all trait effects
2. Fire damage dealt to an arboreal enemy results in 150% damage; fire damage dealt to a fireborne enemy results in 0 damage (immunity)
3. Debug keyboard commands (e.g., press T to add/remove test traits) allow runtime trait testing