# Spec Requirements Document

> Spec: Enemy Spawner System
> Created: 2025-10-03

## Overview

Implement a configurable enemy spawner system that allows designers to place reusable spawner objects in rooms to dynamically generate enemies based on weighted probability tables, spawn limits, proximity triggers, and customizable behaviors. This system will reduce manual enemy placement, enable dynamic difficulty scaling, and provide flexible enemy population management across all game levels.

## User Stories

### Dynamic Enemy Population

As a level designer, I want to place spawner objects that automatically generate enemies according to configurable rules, so that I can create dynamic combat encounters without manually placing dozens of individual enemy instances.

The designer places a spawner object in a room, configures its spawn table (e.g., 70% mooks, 30% featured enemies), sets a proximity radius, spawn interval, and enemy cap. During gameplay, when the player enters the radius, the spawner begins producing enemies at the specified interval until the cap is reached or the spawner is destroyed.

### Varied Spawner Behaviors

As a game designer, I want spawners to support different behavioral modes (finite vs continuous spawning, proximity-based vs always-active, visible vs invisible, damageable vs invulnerable), so that I can create varied gameplay scenarios from ambush points to endless arenas.

A finite spawner might generate exactly 5 enemies then deactivate (useful for scripted encounters), while a continuous spawner keeps producing enemies until destroyed (useful for defense scenarios). Proximity spawners activate only when players approach (creating ambush moments), while always-active spawners populate remote areas. Visible damageable spawners become tactical targets, while invisible invulnerable spawners provide hidden enemy sources.

### Save/Load Persistence

As a player, I want spawner states to persist across save/load cycles, so that when I return to an area, destroyed spawners remain destroyed and active spawners maintain their spawn counts.

When a player saves the game after destroying two spawners and a third spawner has produced 3 out of 5 enemies, loading that save should restore: the two destroyed spawners as destroyed (no longer spawning), the third spawner with its internal count at 3/5, and all previously spawned enemies in their saved positions/states.

## Spec Scope

1. **Parent Spawner Object** - Create `obj_spawner_parent` with configurable properties for inheritance and instance-level overrides
2. **Weighted Spawn Tables** - Implement weighted probability system for enemy selection similar to existing loot table mechanics
3. **Spawn Behavior Modes** - Support finite spawning (X enemies then stop) and continuous spawning (until state change)
4. **Proximity Activation** - Enable spawners to activate/deactivate based on player distance with configurable radius
5. **Visibility and Damage** - Allow spawners to be visible/invisible and damageable/invulnerable via configuration
6. **Enemy Cap Management** - Enforce maximum concurrent alive enemies per spawner to prevent overwhelming the player
7. **Spawn Timing** - Configurable spawn period/interval between enemy generation
8. **Audio Feedback** - Optional sound effect playback when enemies are spawned
9. **Save/Load Integration** - Serialize spawner state (spawn count, active/destroyed status) into save system

## Out of Scope

- Animated spawner effects or particle systems for visible spawners
- Spawner visual indicators showing spawn state (idle/spawning/depleted)
- Global spawner controller object (rely on `obj_spawner_parent` for management)
- Spawner chaining or trigger dependencies between multiple spawners
- Enemy behavior modifications based on spawner origin
- Spawner health bars or damage feedback for damageable spawners

## Expected Deliverable

1. A functional `obj_spawner_parent` object that can be placed in rooms and configured via instance variables or child object overrides
2. Spawners correctly spawn enemies according to weighted tables, respect enemy caps, and respond to proximity triggers
3. Spawner states (destroyed, spawn counts, active/inactive) persist correctly across save/load cycles
4. Spawned enemies behave identically to manually-placed enemies and integrate seamlessly with existing save/load system
