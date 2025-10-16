# Spec Requirements Document

> Spec: Chain Boss System
> Created: 2025-10-15
> Status: Planning

## Overview

Implement a reusable boss enemy system where a central boss character (32x32px) is visually connected to 2-5 smaller auxiliary enemies (16x16px) via dynamic chain sprites that react to distance and tension. The auxiliaries chase the player within configurable chain length constraints, and when all auxiliaries are defeated, the boss enters an enraged phase with increased aggression.

## User Stories

### Boss Encounter with Chained Minions

As a player, I want to fight a boss that controls multiple smaller enemies via chains, so that I experience a dynamic multi-target combat encounter where positioning and target priority matter.

When the player encounters a chain boss, they see a large central enemy with 2-5 smaller enemies connected by visible chains. The smaller enemies move independently to attack the player but are constrained by chain length. As the auxiliaries move, the chains visibly sag when slack and stretch taut when at maximum distance. When the player defeats all auxiliaries, the boss enters an enraged state with faster attacks and more aggressive behavior.

### Strategic Target Selection

As a player, I want to decide whether to focus on the auxiliaries first or attack the boss directly, so that I can develop different strategies based on the situation.

The player can choose to eliminate auxiliaries one by one (reducing the boss's offensive pressure but potentially triggering enrage earlier) or focus fire on the boss while kiting the auxiliaries (faster kill but more incoming damage). The visual feedback from chain tension helps the player understand positioning and threat ranges.

## Spec Scope

1. **Chain Boss Parent Object** - Create `obj_chain_boss_parent` inheriting from `obj_enemy_parent` with configuration for number of auxiliaries, chain length, and enrage behavior.
2. **Auxiliary Spawn System** - Automatically spawn and configure 2-5 auxiliary enemies at boss creation with proper linking and chain initialization.
3. **Chain Physics & Constraint** - Implement distance-based movement constraints that prevent auxiliaries from exceeding configured chain length while allowing free movement within range.
4. **Dynamic Chain Rendering** - Draw sprite-based chains that visually react to distance with slack/sag when close and taut/straight when at maximum length.
5. **Enrage Phase Trigger** - Detect when all auxiliaries are defeated and transition boss to enraged state with configurable stat multipliers (attack speed, movement speed, damage).

## Out of Scope

- Chain collision with player (damage/slow effects)
- Destructible/targetable chains
- Boss chain manipulation attacks (reel in, whip, release) - reserved for future enhancement
- Chain physics affecting auxiliaries' velocity/momentum (simple distance clamp only)
- Multiple chain boss types with unique behaviors (foundation only)

## Expected Deliverable

1. A working chain boss enemy that can be placed in a room with configured number of auxiliaries that spawn automatically and remain constrained by visible chains.
2. Auxiliaries that chase the player within chain range, with chains visually reacting to tension (sagging when slack, taut when stretched).
3. Boss enters enraged phase when all auxiliaries are defeated, with visibly increased aggression (faster attacks, higher movement speed).

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-15-chain-boss-system/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-15-chain-boss-system/sub-specs/technical-spec.md
