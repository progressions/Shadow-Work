# Spec Requirements Document

> Spec: Enemy Movement Profiles
> Created: 2025-10-11
> Status: Planning

## Overview

Implement a generalized movement profile system that allows enemies to use specialized movement behaviors beyond basic pathfinding. The initial implementation will focus on a "kiting swoop attacker" profile for bat enemies that maintains distance from the player, performs long-distance dash attacks, and returns to a home position.

## User Stories

### Bat Enemy with Erratic Flying Movement

As a player, I want to encounter bat enemies that fly erratically and keep their distance, so that combat feels dynamic and requires different strategies than melee-only enemies.

When a bat enemy spawns, it should maintain a safe distance from the player (75-150 pixels) using pathfinding. The bat should move in an erratic pattern (small random adjustments to its target position) while kiting. When conditions are met (player is within swoop range, cooldown expired), the bat performs a fast dash attack toward the player, then swoops back to its original anchor position.

### Generalizable Movement System

As a developer, I want movement profiles to be reusable and configurable, so that different enemies can use the same movement patterns with different parameters.

Movement profiles should be defined in a global database similar to the trait system. Each profile should have configurable parameters (distances, speeds, cooldowns) and hook into the enemy state machine without breaking existing pathfinding or AI systems.

## Spec Scope

1. **Movement Profile Database** - Global struct defining reusable movement profiles with parameters
2. **Kiting Behavior** - Maintain distance from target using pathfinding with erratic adjustments
3. **Swoop Attack** - Fast linear dash attack toward player with return-to-anchor behavior
4. **Enemy Integration** - Apply movement profiles to enemies via simple assignment in Create event
5. **State Machine Integration** - Hook movement profiles into existing enemy state machine (targeting, attacking states)

## Out of Scope

- Movement profiles for companions or NPCs (enemy-only for now)
- Complex formation flying or group coordination
- Terrain-specific movement behaviors (water/air navigation)
- Dynamic profile switching during combat
- AI decision-making for when to use profiles (use simple distance/cooldown triggers)

## Expected Deliverable

1. Bat enemies visibly maintain distance from player while moving erratically
2. Bats perform swooping dash attacks when player is in range, then return to anchor
3. Other enemies can use the kiting profile by assigning it in their Create event
4. Movement profiles respect stun/stagger CC effects and pathfinding obstacles

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-11-enemy-movement-profiles/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-11-enemy-movement-profiles/sub-specs/technical-spec.md
