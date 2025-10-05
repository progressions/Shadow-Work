# Spec Requirements Document

> Spec: Companion Evading Behavior
> Created: 2025-10-04
> Status: Planning

## Overview

Implement a combat evasion state for companions that causes them to move away from the player and enemies during active combat, reducing visual clutter and improving tactical positioning. Companions automatically transition between following and evading states based on a combat timer that tracks when the player last took damage or dealt damage.

## User Stories

### Combat Clarity

As a player engaged in combat, I want my companions to stay out of the way during fights, so that I can clearly see enemies and my character without companions crowding the battle area.

When combat begins (player takes damage or hits an enemy), all companions enter an evading state where they pathfind to maintain distance from both the player and nearby enemies. They position themselves within visual range but far enough away to not interfere with combat movement or visibility. After a cooldown period without combat activity, companions smoothly return to their normal following behavior.

### Tactical Positioning

As a player managing multiple companions, I want them to automatically spread out during combat, so that they don't block doorways or movement paths and the battlefield feels less cluttered.

Companions in evading state seek positions away from the player's current location and any active enemies, creating natural spacing. In confined spaces like corridors, they move to corners or the farthest available positions. This prevents companion pathfinding from interfering with player movement during critical combat moments.

### Intuitive State Transitions

As a player, I want companion behavior to feel responsive but not jumpy, so that state changes feel intentional and don't create confusion about whether the AI is broken.

The combat timer prevents rapid state switching by requiring a cooldown period (e.g., 3-5 seconds) of no combat activity before companions return to following. This creates smooth, deliberate transitions that feel like intelligent behavior rather than erratic AI.

## Spec Scope

1. **Combat Detection System** - Implement combat timer on player that resets when player takes damage or obj_attack collides with an enemy
2. **Companion Evading State** - Add new state to companion objects that triggers when player's combat timer is active
3. **Evasion Pathfinding** - Companions pathfind to maintain 64-128 pixel distance from player and avoid all obj_enemy_parent instances
4. **State Transition Logic** - Smooth transition from evading back to following when combat timer expires and enemies are cleared
5. **Visual Feedback** - Optional: Different sprite or animation during evading state to indicate intentional behavior

## Out of Scope

- Companion-specific bravery/cowardice traits (all companions use same evading behavior)
- Combat companions that fight alongside player (this affects all companions equally)
- Manual player control of companion positions
- Advanced formation or tactical positioning commands
- Companion AI improvements beyond evading behavior

## Expected Deliverable

1. During combat, companions automatically move away from player and enemies, maintaining visible but non-interfering positions
2. Companions return to normal following behavior after 3-5 seconds of no combat activity
3. Behavior works smoothly in both open areas and confined spaces without companions getting stuck or behaving erratically

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-04-companion-evading-behavior/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-04-companion-evading-behavior/sub-specs/technical-spec.md
