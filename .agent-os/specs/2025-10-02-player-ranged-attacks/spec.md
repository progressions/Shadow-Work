# Spec Requirements Document

> Spec: Player Ranged Attacks
> Created: 2025-10-02
> Status: Planning

## Overview

Implement a ranged attack system for the player that allows firing arrows when equipped with bow weapons. This feature adds tactical combat variety by enabling ranged combat alongside the existing melee system, with proper ammo consumption and projectile physics.

## User Stories

### Ranged Combat

As a player, I want to fire arrows when I have a bow equipped, so that I can attack enemies from a distance and use different combat tactics.

When the player presses the J button with a bow weapon equipped (wooden_bow, longbow, crossbow, or heavy_crossbow), the system checks if arrows are available in the inventory. If arrows are available, the player plays the attack animation, consumes one arrow, and spawns an obj_arrow projectile traveling in the direction the player is facing. The arrow travels in a straight line (up/down/left/right only) until it hits an enemy (obj_enemy_parent or descendants), a collision tile (Tiles_Col layer), or goes offscreen. When hitting an enemy, it deals damage based on the equipped bow's damage stat, plays hit sound effects, and destroys itself. The player can move freely once the arrow is fired.

## Spec Scope

1. **Ranged weapon detection** - Check if equipped weapon has `requires_ammo: "arrows"` property to identify ranged weapons
2. **Arrow consumption system** - Use existing `has_ammo("arrows")` and `consume_ammo("arrows", 1)` functions before firing
3. **Arrow projectile object** - Create obj_arrow that travels at speed 6 in cardinal directions (up/down/left/right)
4. **Arrow collision detection** - Detect collisions with Tiles_Col layer and obj_enemy_parent descendants, destroying arrow on impact
5. **Damage application** - Apply bow weapon damage to enemies on arrow hit using existing damage system
6. **Sound effects system** - Implement sound playback for: arrow firing, arrow hitting enemy, enemy hit reaction, arrow hitting walls
7. **Attack state management** - Allow player movement after arrow fires (non-blocking ranged attack)

## Out of Scope

- Ranged attacks for enemies (future feature)
- Diagonal arrow trajectories
- Arrow penetration through enemies
- Special arrow types or elemental arrows
- Bow-specific attack animations (will use melee animations temporarily)
- Critical hits or accuracy systems for ranged weapons
- Arrow drop-off or gravity physics

## Expected Deliverable

1. Player can equip a bow weapon and press J to fire arrows when arrows are in inventory
2. Arrows travel in straight cardinal directions and deal weapon damage to enemies on collision
3. Arrows consume ammo, collide with walls/enemies appropriately, and trigger sound effects at the correct moments

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-02-player-ranged-attacks/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-02-player-ranged-attacks/sub-specs/technical-spec.md
