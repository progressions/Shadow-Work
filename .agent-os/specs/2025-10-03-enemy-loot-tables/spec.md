# Spec Requirements Document

> Spec: Enemy Loot Tables and Item Drops
> Created: 2025-10-03

## Overview

Implement a weighted loot table system that allows enemies to drop items when killed, with configurable drop rates and item probabilities. This feature will add reward variety to combat encounters and provide players with equipment and consumables through gameplay rather than only world pickups.

## User Stories

### Combat Rewards

As a player, I want to receive loot drops from defeated enemies, so that I feel rewarded for successful combat encounters and can acquire equipment and supplies through gameplay.

When the player defeats an enemy, there is a configurable chance (per enemy type) that the enemy will drop an item. The item is selected from the enemy's loot table using weighted random selection, where items can have different drop probabilities. The dropped item spawns near the enemy's death location with slight positional randomization to avoid overlap and ensure it lands on walkable terrain.

### Loot Variety

As a game designer, I want to configure different loot tables for different enemy types with weighted probabilities, so that I can create interesting combat rewards and balance item acquisition rates.

Each enemy type can define its own loot table as a list of item keys (matching global.item_database keys) with optional weights. If no weights are specified, all items in the table have equal probability. The system supports both simple equal-chance tables and complex weighted distributions, allowing fine control over what items drop and how frequently.

## Spec Scope

1. **Weighted Loot Table System** - Create a loot table structure that supports item keys with optional weights, defaulting to equal probability when weights are omitted.

2. **Drop Chance Configuration** - Add a configurable drop_chance property (0.0 to 1.0) to obj_enemy_parent that determines whether an enemy drops loot on death.

3. **Item Spawning Logic** - Implement death-time loot spawning that selects a random item from the loot table and spawns it near the enemy with 16px scatter in a random direction.

4. **Collision-Aware Placement** - Ensure dropped items don't spawn on blocked tiles by checking terrain collision and finding nearby walkable positions.

5. **Default Loot Table** - Provide a sensible default loot table in obj_enemy_parent that can be overridden in individual enemy Create events.

## Out of Scope

- Currency/gold drop system (no gold/resources in game currently)
- Multiple item drops per enemy (limit one item per drop)
- Visual effects for loot drops (will be added separately after testing)
- Loot rarity tiers or quality systems
- Player inventory capacity checks (assumed to be handled by existing inventory system)

## Expected Deliverable

1. Enemies have a configurable chance to drop items when killed, with the drop system working for all enemy types in the game.

2. Each enemy type can have a custom loot table with weighted probabilities, testable by killing multiple enemies and observing varied drop results.

3. Dropped items spawn near defeated enemies on walkable terrain without overlapping blocked tiles or existing objects.
