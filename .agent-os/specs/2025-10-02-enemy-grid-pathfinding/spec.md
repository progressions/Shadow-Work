# Spec Requirements Document

> Spec: Enemy Grid Pathfinding System
> Created: 2025-10-02
> Status: Planning

## Overview

Implement a grid-based pathfinding system for enemies using GameMaker's mp_grid functions, enabling intelligent navigation around obstacles, terrain-aware movement preferences, and sophisticated AI behaviors including ranged enemy kiting and circle strafing.

## User Stories

### Intelligent Enemy Navigation

As a player, I want enemies to navigate around walls and obstacles intelligently, so that combat feels more challenging and realistic rather than enemies getting stuck on terrain.

Enemies will use pathfinding grids to calculate optimal routes to the player, avoiding collision objects like walls (Tiles_Col layer), other enemies (obj_enemy_parent), pillars (obj_rising_pillar), and companions (obj_companion_parent). The system will update paths periodically (every 2 seconds) to respond to player movement while maintaining performance with up to 15 enemies per room.

### Ranged Enemy Tactical Positioning

As a player, I want ranged enemies to maintain optimal attack distance and use tactical movement, so that different enemy types require different combat strategies.

Ranged enemies (like the Greenwood Bandit) will use pathfinding to stay at their ideal attack range (attack_range ± 20 pixels) and circle strafe around the player when possible, creating dynamic ranged combat encounters that require player positioning and awareness.

### Terrain-Aware Enemy Movement

As a player, I want to see enemies interact with terrain types based on their traits, so that enemy behaviors feel consistent with their lore and characteristics.

Enemies with specific traits (fireborne, aquatic, etc.) will move faster on their preferred terrain types, creating natural terrain preferences without requiring complex weighted pathfinding algorithms. For example, aquatic enemies will favor water tiles by moving faster across them.

## Spec Scope

1. **Pathfinding Controller** - Create obj_pathfinding_controller that manages mp_grid setup per room (16x16 cell size) with obstacle marking for walls, enemies, pillars, and companions
2. **New Enemy State** - Add EnemyState.targeting state with dedicated enemy_state_targeting.gml script for pathfinding behavior, path following, and state transitions
3. **Path Calculation & Updates** - Implement path recalculation every 120 frames (2 seconds) using Alarm[0], with path storage and cleanup in enemy parent
4. **Ranged Enemy Kiting** - Add ideal_range property and circle strafe logic for ranged enemies to maintain attack_range ± 20px distance from player
5. **Terrain Speed Modifiers** - Implement terrain-based movement speed system for enemies using trait database to determine preferred terrains
6. **Debug Visualization** - Add global.debug_pathfinding flag to toggle grid and path visualization during development

## Out of Scope

- Custom A* pathfinding implementation (using GameMaker's built-in mp_grid system instead)
- Weighted pathfinding costs per terrain type (using movement speed as effective preference instead)
- Pathfinding for enemies on grid puzzle system (grid puzzles remain player-only)
- Formation-based enemy movement or group coordination
- Pathfinding in room_initial (controller only active in gameplay rooms)

## Expected Deliverable

1. Enemies successfully navigate around obstacles using pathfinding, avoiding walls, other enemies, pillars, and companions
2. Ranged enemies maintain optimal attack distance and demonstrate circle strafing behavior when engaging the player
3. Debug visualization shows pathfinding grids and enemy paths when global.debug_pathfinding is enabled
4. Enemies with terrain-based traits (aquatic, fireborne, etc.) move faster on their preferred terrain types

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-02-enemy-grid-pathfinding/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-02-enemy-grid-pathfinding/sub-specs/technical-spec.md
