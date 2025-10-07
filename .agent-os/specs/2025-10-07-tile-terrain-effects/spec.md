# Spec Requirements Document

> Spec: Tile-Based Terrain Effects System
> Created: 2025-10-07

## Overview

Implement a configurable tile-based terrain effects system that allows tiles to apply temporary traits (like burning from lava) and modify movement speed. This system replaces the hardcoded path speed bonus with a unified, data-driven approach that makes it easy to add new terrain types with custom effects.

## User Stories

### Designer Adding New Hazardous Terrain

As a game designer, I want to add new hazardous terrain types (lava, poison pools, ice patches) to rooms, so that I can create environmental challenges and strategic positioning gameplay without writing code.

**Workflow:**
1. Designer adds lava tiles to `Tiles_Lava` layer in a room
2. Designer configures terrain in `global.terrain_effects_map` to apply `burning` trait and -20% speed
3. Enemies automatically avoid lava tiles in their pathfinding
4. Players and enemies take burning damage when standing on lava
5. Entities with `fire_immunity` trait ignore the burning damage (but still get the status)

### Player Navigating Environmental Hazards

As a player, I want terrain to affect my movement and apply status effects, so that I need to think strategically about positioning and use terrain to my advantage in combat.

**Workflow:**
1. Player walks onto lava tile → receives 1 stack of burning (refreshes duration while standing)
2. Player moves off lava → burning persists for full duration (3 seconds)
3. Player walks onto path tile → moves 25% faster
4. Player with fire immunity can stand on lava without taking damage (strategic advantage)

### Enemy AI Avoiding Hazards

As an enemy AI, I want to avoid hazardous terrain in my pathfinding, so that I don't walk into lava unless I'm immune to fire damage.

**Workflow:**
1. Enemy calculates path to player → pathfinding grid marks lava/poison tiles as obstacles
2. Enemy routes around hazardous terrain when possible
3. If enemy has `fire_immunity`, lava tiles are not marked as obstacles
4. If cornered with no alternative, enemy can still physically move onto hazard tiles

## Spec Scope

1. **Terrain Effects Database** - Centralized configuration mapping terrain types to traits, speed modifiers, and hazard flags
2. **Trait Application System** - Apply terrain traits once on entry with duration refresh (no stacking per frame)
3. **Speed Modifier System** - Direct speed modification per terrain type (separate from trait system)
4. **Enemy Pathfinding Integration** - Mark hazardous terrains as obstacles in `mp_grid` unless entity has immunity
5. **Trait Immunity Respect** - Terrain-applied traits respect existing trait immunities (e.g., `fire_immunity` blocks burning damage)

## Out of Scope

- Visual terrain effects (particles, shaders) - will be added in a separate spec
- Sound effects for terrain interactions - will be added separately
- Companion terrain interactions - companions don't interact with terrain
- Terrain-based damage reduction or armor bonuses
- Multi-tile terrain area detection (each tile checked independently)

## Expected Deliverable

1. Players and enemies receive appropriate traits and speed modifiers when standing on configured terrain tiles
2. Enemies avoid hazardous terrain in pathfinding unless immune to the associated trait
3. New terrain types can be added by editing `global.terrain_effects_map` without code changes
4. Trait immunities prevent damage from terrain-applied traits (e.g., fire_immunity prevents burning damage from lava)
