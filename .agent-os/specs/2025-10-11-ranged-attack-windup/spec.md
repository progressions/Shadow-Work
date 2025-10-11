# Spec Requirements Document

> Spec: Enemy Ranged Attack Windup System
> Created: 2025-10-11
> Status: Planning

## Overview

Implement a configurable windup/telegraph system for enemy ranged attacks that slows down the attack animation and adds sound feedback before projectile launch. This will give players visual and audio cues to react to incoming ranged attacks, improving combat readability and difficulty balance.

## User Stories

### Visual Telegraph for Ranged Attacks

As a player, I want to see enemies clearly wind up their ranged attacks, so that I can anticipate and dodge incoming projectiles.

When an enemy begins a ranged attack, they play their ranged attack animation at a configurable slower speed (e.g., half-speed by default). A windup sound plays when the animation starts, giving audio feedback. Once the full animation cycle completes, the projectile spawns and the attack sound plays. This creates a clear visual and audio telegraph that rewards player awareness and reaction time.

### Designer Control Over Attack Timing

As a game designer, I want to configure ranged attack windup speeds per enemy type, so that I can balance difficulty and create varied enemy behaviors.

Different enemies can have different `ranged_windup_speed` values (default 0.5 = half-speed, but configurable 0.1-1.0 range). Fast enemies might use 0.7 speed for quick attacks, while slow heavy enemies use 0.3 for long telegraphs. Each enemy type can also have custom windup sounds (e.g., bow creak vs crossbow crank) configured via `enemy_sounds.on_ranged_windup`.

## Spec Scope

1. **Configurable Windup Speed** - Add `ranged_windup_speed` property to `obj_enemy_parent` (default 0.5, range 0.1-1.0)
2. **Animation Timing Control** - Modify ranged attack animation system to use `ranged_windup_speed` multiplier during windup phase
3. **Windup Sound Event** - Add `on_ranged_windup` to `enemy_sounds` struct with configurable per-enemy sounds and parent default
4. **Delayed Projectile Spawn** - Move projectile creation from state entry to end of first animation cycle
5. **Attack Sound Timing** - Ensure `on_ranged_attack` sound plays when projectile spawns (not at animation start)

## Out of Scope

- Player bow/ranged weapon windup (enemies only)
- Melee attack windup/telegraph system
- Visual effects during windup (particles, glows, etc.)
- Animation interruption/cancellation mechanics
- Charged/held ranged attacks (multi-stage charging)

## Expected Deliverable

1. Enemy ranged attacks play at configurable slower speed with windup sound before projectile launches
2. Different enemy types can have different windup speeds and sounds (e.g., `obj_burglar` with 0.4 speed and custom bow creak sound)
3. All existing ranged enemies continue to function with new default windup behavior without requiring individual updates

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-11-ranged-attack-windup/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-11-ranged-attack-windup/sub-specs/technical-spec.md
