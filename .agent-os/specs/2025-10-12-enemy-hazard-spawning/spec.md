# Spec Requirements Document

> Spec: Enemy Hazard Spawning System
> Created: 2025-10-12

## Overview

Implement a hazard spawning attack system that allows enemies to launch projectiles that create persistent area-of-effect hazards (fire pools, poison clouds, acid puddles) at their landing points. This system will add tactical depth to combat by forcing players to manage battlefield positioning while avoiding dangerous zones created by specialized enemies or boss multi-phase attacks.

## User Stories

### Hazard-Spawning Enemy Encounter

As a player, I want to face enemies that create dangerous zones on the battlefield, so that combat requires strategic positioning and movement rather than just damage output.

When encountering a hazard-spawning enemy (like a Fire Cultist or Poison Shaman), the enemy moves slowly toward the player, stops at a tactical distance, plays a windup animation with audio cue, then launches a projectile (fireball, poison glob, acid sphere) that travels in a direction relative to their facing. The projectile travels a configured distance before "landing" and spawning a hazard object (fire pool, poison cloud, acid puddle) that persists and damages the player on contact. The player must dodge both the incoming projectile and avoid the resulting hazard zone, creating dynamic battlefield hazards that require constant awareness.

### Boss Multi-Attack Pattern

As a player, I want boss enemies to have varied attack patterns including area denial, so that boss fights feel mechanically rich and challenging.

During a boss encounter, the boss can perform standard melee swings and ranged arrow attacks on short cooldowns, but also has a hazard spawning attack on a longer cooldown (e.g., every 8-10 seconds). When the boss triggers the hazard spawn, they perform a special windup, launch a large fireball that travels across the arena, and create a fire pool at the landing point. This forces the player to manage multiple threat types: dodging immediate attacks, avoiding projectiles, and navigating around persistent hazard zones that limit safe movement space.

### Enemy Type Specialization

As a developer, I want to configure hazard spawning behavior per enemy type or instance, so that different enemies can have unique tactical behaviors without code duplication.

Each hazard-spawning enemy can be configured with: cooldown duration, projectile object type, hazard object type, projectile travel distance, damage amount, damage type (fire/poison/etc), hazard lifetime, and direction offset relative to facing. This allows creating specialized enemy variants (slow-moving fire cultists with long-range fireballs, aggressive poison shamans with short-range rapid clouds, stationary acid turrets with predictable patterns) by simply adjusting configuration values rather than writing new AI logic.

## Spec Scope

1. **New Enemy State** - Add `EnemyState.hazard_spawning` state to enemy state machine with windup, launch, and cooldown phases
2. **Hazard Projectile System** - Create projectile objects that travel a configured distance, deal damage on contact, then spawn hazard objects and self-destruct at landing point
3. **Configuration System** - Add configurable variables for cooldown, projectile/hazard types, travel distance, damage, damage type, lifetime, and direction offset
4. **Movement Profile** - Implement slow-movement hazard-spawning behavior profile with stop-and-shoot mechanics
5. **Multi-Attack Boss Support** - Enable boss enemies to combine melee, ranged, and hazard spawning attacks with independent cooldowns

## Out of Scope

- Creating new hazard object types (existing hazard objects like `obj_hazard_fire`, `obj_hazard_poison` will be used)
- Creating new projectile sprites or animations (will use existing sprites as placeholders)
- Advanced targeting AI for projectile aim (projectiles travel in direction relative to facing, not predictive aiming)
- Hazard object modifications or new hazard mechanics (hazards already have damage, lifetime, visual effects implemented)
- Player abilities to manipulate or destroy hazards

## Expected Deliverable

1. Hazard-spawning enemies successfully launch projectiles that travel configured distances and spawn hazard objects at landing points
2. Boss enemies can perform melee attacks, ranged attacks, and hazard spawning attacks with independent cooldowns
3. Hazard spawning behavior is fully configurable per enemy instance with variables for cooldown, objects, distance, damage, and direction
