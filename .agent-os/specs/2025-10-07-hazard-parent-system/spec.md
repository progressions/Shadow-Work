# Spec Requirements Document

> Spec: Hazard Parent System
> Created: 2025-10-07

## Overview

Implement a parent object (`obj_hazard_parent`) for environmental hazards that can apply damage and/or temporary traits to players and enemies when they collide with or stand on them. This system will enable level designers to create varied environmental dangers (fire, poison, ice, etc.) through configurable instances without requiring new object types for each hazard variant.

## User Stories

### Level Designer: Creating Environmental Hazards

As a level designer, I want to place environmental hazards (lava pools, poison clouds, ice patches) in rooms using a single parent object with configurable properties, so that I can create dangerous areas without needing custom code for each hazard type.

**Workflow:**
1. Place `obj_hazard_parent` (or child objects) in room editor
2. Configure instance variables: damage type, damage amount, damage mode (continuous/on-enter), trait to apply, trait duration, damage interval
3. Set visual sprite and optional looping sound effect
4. Test in game - hazard damages/affects entities based on configuration

### Player: Navigating Environmental Dangers

As a player, I want to see visual and audio cues when entering hazardous terrain and receive feedback when taking damage, so that I can make informed decisions about risk vs reward when traversing dangerous areas.

**Workflow:**
1. Approach visible hazard (fire, poison pool, etc.)
2. Hear audio cue when entering hazard zone
3. See damage numbers and visual feedback when taking damage
4. Observe status effect icon when trait is applied (burning, slowed, etc.)
5. Experience damage immunity period preventing instant death
6. Use traits/equipment to mitigate hazard effects (fire immunity blocks fire hazards)

### Enemy: Hazard Interaction

As an enemy AI, I want to interact with environmental hazards using the same trait and damage systems as the player, so that hazards create tactical opportunities (player can kite fire-vulnerable enemies into lava).

**Workflow:**
1. Enemy pathfinding encounters hazard
2. Enemy takes damage/applies trait based on hazard configuration
3. Enemy traits (fire_immunity, etc.) properly mitigate hazard effects
4. Enemy AI can optionally avoid hazards (future enhancement)

## Spec Scope

1. **obj_hazard_parent Base Object** - Create persistent parent object with serialization support for save/load, configurable instance variables for damage and traits
2. **Damage System Integration** - Support continuous damage (at intervals) or on-enter damage, with configurable damage type (physical, fire, ice, poison, etc.) and damage immunity period
3. **Trait Application System** - Apply temporary traits on collision (burning, wet, slowed, etc.) with configurable duration, re-application on re-entry, and integration with existing trait stacking system
4. **Visual & Audio Feedback** - Animated sprite support, configurable looping SFX, audio cues for enter/exit/damage events, spawn damage numbers on damage application
5. **Collision Detection** - Affect both players and enemies, respect trait-based immunities (fire_immunity blocks fire damage), integrate with companion auras and status effects

## Out of Scope

- Enemy AI pathfinding avoidance of hazards (future enhancement)
- Hazard preset database (designers configure instances directly)
- Hazard destruction/toggling mechanics (may be added later)
- Multi-trait application from single hazard (one trait or damage type per hazard)
- Particle effects system (can use existing spawn effects)

## Expected Deliverable

1. Players and enemies take appropriate damage when colliding with hazards, with damage numbers displayed and immunity period preventing instant death
2. Temporary traits are applied on hazard collision with proper duration and re-application on re-entry
3. Hazards properly integrate with existing trait system (immunities block effects, resistances reduce damage, opposing traits neutralize)
4. Hazard states persist across save/load cycles
5. Visual animations and audio cues play appropriately on enter/exit/damage events
