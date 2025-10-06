# Spec Requirements Document

> Spec: Combat Visual Feedback System
> Created: 2025-10-05
> Status: Planning

## Overview

Implement visual and timing feedback systems to make combat feel punchy and impactful in Shadow Work. This spec covers freeze frames, screen shake, hit effects, slow-motion triggers, and a basic critical hit system. The goal is to provide clear, satisfying visual feedback during combat encounters without introducing complex particle systems or impacting the 60 FPS performance target.

## User Stories

1. **As a player**, I want to feel a brief pause when I land a hit on an enemy, so that my attacks feel more impactful
2. **As a player**, I want the screen to shake when I use heavy weapons, so that different weapon types feel distinct
3. **As a player**, I want to see visual sparks/flashes when I hit enemies, so that I have clear feedback that my attack connected
4. **As a player**, I want enemies to flash when I hit them (white for normal hits, red for crits), so that I can see damage being dealt
5. **As a player**, I want time to slow briefly when I activate a companion's trigger ability, so that the moment feels special and cinematic
6. **As a player**, I want to occasionally land critical hits, so that combat has exciting moments of higher damage

## Spec Scope

This spec covers the following systems:

1. **Freeze Frame System**
   - 2-4 frame pause on successful hits
   - Extended freeze on enemy kills (4-6 frames)
   - Extra freeze on critical hits (5-8 frames)
   - Implemented via `image_speed` manipulation for controlled timing

2. **Weapon-Based Screen Shake**
   - Screen shake intensity varies by weapon type
   - Heavy weapons (two-handed swords, axes) = strong shake
   - Medium weapons (one-handed swords, spears) = moderate shake
   - Light weapons (daggers, fists) = minimal shake
   - Shake duration: 4-8 frames depending on intensity

3. **Sprite-Based Hit Effects**
   - Directional hit spark sprites on successful attacks
   - Spawn at collision point between weapon and enemy
   - Alpha fade-out over 8-12 frames
   - No particle system required - uses simple object spawning

4. **Enemy Flash Effects**
   - White flash on normal hits (blend color manipulation)
   - Red flash on critical hits
   - Flash duration: 2-4 frames
   - Returns to normal sprite after flash

5. **Slow-Motion on Companion Trigger Activation**
   - 0.5 second slow-motion effect when companion trigger ability activates
   - Time scale reduced to 0.3-0.5 of normal speed
   - Smooth ramp-up back to normal speed
   - Does not affect UI or audio

6. **Basic Critical Hit System**
   - Random RNG-based crit chance (base 10%)
   - Crits deal 1.5x-2.0x damage multiplier
   - Combines with enemy flash (red) and extended freeze frame
   - No stat-based modifiers in this scope

## Out of Scope

The following features are explicitly **not** included in this spec:

- Complex particle systems with emitters and effects
- Advanced critical hit modifiers based on stats, equipment, or positioning
- UI indicators for critical hits, combo counters, or damage numbers
- Sound effects for impacts (may be added in future audio spec)
- Camera zoom effects during freeze frames
- Post-processing effects (motion blur, chromatic aberration)
- Difficulty-based adjustments to crit rates
- Companion-specific visual effects beyond trigger slow-mo

## Expected Deliverable

A combat system with improved visual feedback that:

- Provides clear, punchy feedback on every hit through freeze frames
- Differentiates weapon types through screen shake intensity
- Gives players visual confirmation of hits through sprite-based effects
- Creates exciting moments through critical hits and slow-motion effects
- Maintains 60 FPS performance target on target hardware
- Integrates seamlessly with existing combat systems (obj_attack, obj_enemy_parent, obj_player)
- Uses only GameMaker built-in functionality (no external extensions)

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-05-combat-visual-feedback/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-05-combat-visual-feedback/sub-specs/technical-spec.md
