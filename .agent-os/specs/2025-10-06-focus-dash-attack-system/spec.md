# Spec Requirements Document

> Spec: Focus Dash Attack System
> Created: 2025-10-06

## Overview

Design a focus-based combat input system that lets players hold a modifier to aim attacks independently from movement, chaining directional melee or ranged strikes with automatic retreat dashes. The goal is to make ranged and melee combat feel responsive while supporting existing dash-triggered companion bonuses.

## User Stories

### Hold-to-Focus Aim

As a player who is kiting enemies, I want to hold a focus key and choose any of eight directions before attacking, so that I can strike or shoot behind me without rotating my movement facing. The flow includes entering focus, buffering a direction, seeing an aim indicator, and firing the stored attack vector on release.

### Focus Dash Retreat (Melee)

As a melee-focused player, I want to trigger a dash away immediately after a focus attack, so that I can land a hit then escape danger without manual reposition inputs. The flow covers queuing a retreat direction, performing the melee strike in the aimed direction, and auto-dashing in the buffered retreat vector once recovery completes.

### Focus Dash Volley (Ranged)

As a ranged player, I want to dash away first and auto-fire a projectile back toward my target, so that I can maintain spacing while answering pressure. The flow captures holding focus, buffering aim and retreat vectors, executing the retreat dash, and spawning the projectile toward the stored aim direction at dash completion.

## Spec Scope

1. **Focus Input State** - Define the hold-`J` focus state, its timers, stored vectors, and how it interacts with movement and dash detection.
2. **Directional Mapping & Indicators** - Map WASD combinations to eight-direction vectors during focus and outline minimal UI feedback for the stored aim/retreat directions.
3. **Melee Focus Attack Sequencing** - Specify melee behavior when focus is active, including attack timing, recovery, and automatic post-hit dash execution.
4. **Ranged Focus Attack Sequencing** - Detail ranged behavior under focus, ensuring dashes occur before projectile spawn and that offsets/aim work for the eight directions.
5. **Dash Reason & Companion Hooks** - Document dash metadata so existing and future dash-triggered systems (e.g., Canopy’s Dash Mend) respond appropriately to focus-initiated retreats.

## Out of Scope

- Creating new weapon assets, animations, or VFX beyond indicator necessities.
- Balance changes to damage, cooldowns, or companion abilities.
- Network or multiplayer considerations.

## Expected Deliverable

A design specification describing states, input handling, timers, state machine updates, UI cues, and integration touchpoints for the focus dash attack system, ready for implementation tickets and cross-team review.
