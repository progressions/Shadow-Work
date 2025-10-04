# Spec Requirements Document

> Spec: Openable Containers System
> Created: 2025-10-04
> Status: Planning

## Overview

Implement an inheritable openable container system (chests, barrels, crates, etc.) that plays a 4-frame opening animation when the player presses SPACE nearby, then spawns configured loot items. Containers can be configured to drop specific items, random items from a weighted loot table, or a variable quantity of items.

## User Stories

### Treasure Chest Discovery

As a player, I want to open chests scattered throughout the game world, so that I can collect loot and rewards to enhance my character.

The player explores a dungeon and encounters a closed chest. When they approach within 32 pixels, a "[Space] Open" prompt appears above the chest. Pressing SPACE plays the opening sound effect and triggers a smooth 4-frame opening animation (frames 0→1→2→3). When the animation completes on frame 3, a loot drop sound plays and the chest spawns its configured loot nearby on valid ground, which could be specific items (quest rewards) or random items from a weighted loot table. The chest remains open permanently and cannot be interacted with again. If the player leaves and returns to the room, the chest stays in its opened state.

### Environmental Container Variety

As a level designer, I want to create different types of openable containers (chests, barrels, crates, pots), so that I can provide varied loot opportunities that fit different environments.

Each container type inherits from `obj_openable` and uses its own sprite with a 4-frame open animation. A wooden barrel in a tavern, an ornate chest in a castle treasury, and a simple crate in a warehouse all use the same opening mechanics but have distinct visual styles. Each can be configured with different loot configurations - specific quest items, weighted random loot, or a variable quantity of items from a table.

### Loot Configuration Flexibility

As a developer, I want to configure containers with flexible loot options (specific items, random weighted selection, or variable quantity), so that I can create different reward scenarios from guaranteed quest items to randomized treasure.

A container can be configured in three ways:
1. **Specific Items**: `loot_items = ["iron_sword", "health_potion"]` - always drops exactly these items
2. **Random Weighted Selection**: `loot_mode = "random_weighted"`, `loot_count = 2`, `loot_table = [{item_key: "gold_coin", weight: 50}, {item_key: "rare_gem", weight: 5}]` - spawns 2 random items using weighted selection
3. **Variable Quantity**: `loot_mode = "random_weighted"`, `loot_count_min = 1`, `loot_count_max = 3` - spawns 1-3 random items from the loot table

## Spec Scope

1. **Parent Container Object** - Create `obj_openable` with interaction detection, animation control, and loot spawning logic
2. **Animation System** - Implement 4-frame opening animation (0→1→2→3) that plays once and freezes on frame 3
3. **Loot Configuration** - Support three loot modes: specific items, weighted random selection, and variable quantity from loot table
4. **Multi-Item Spawning** - Spawn multiple items with collision-free positioning using existing `find_loot_spawn_position()` logic
5. **Persistent State** - Integrate with save/load system to track opened containers across game sessions
6. **Child Container Types** - Create example implementations: `obj_chest`, `obj_barrel`, `obj_crate`
7. **Audio Feedback** - Play `snd_chest_open` when container begins opening, and `snd_loot_drop` when animation completes and items spawn

## Out of Scope

- Locked containers requiring keys or puzzles
- Animated lid physics or particle effects beyond sprite animation
- Container inventory UI (items spawn on ground like enemy loot)
- Destructible containers (breaking barrels/crates)
- Trapped containers with damage or status effects

## Expected Deliverable

1. Player can approach any container type (chest, barrel, crate) and see a "[Space] Open" prompt when within 32 pixels
2. Pressing SPACE triggers the 4-frame opening animation with sound effects
3. Container spawns configured loot items on valid ground near the container
4. Containers configured with specific items always drop those exact items
5. Containers configured with loot tables spawn the correct quantity of random weighted items
6. Opened containers remain permanently open and are saved/loaded correctly across game sessions

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-04-openable-containers/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-04-openable-containers/sub-specs/technical-spec.md
