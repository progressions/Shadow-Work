# Spec Requirements Document

> Spec: Companion Casting Animation System
> Created: 2025-10-04

## Overview

Implement a casting animation state for companions that plays directional casting animations when their triggers activate. This enhances visual feedback for companion abilities by showing companions performing magical gestures that correspond to their trigger effects.

## User Stories

### Companion Trigger Visual Feedback

As a player, I want to see my companion perform a casting animation when their triggers activate, so that I have clear visual feedback that their ability is being used.

When a companion's trigger activates (shield, guardian veil, gust, etc.), the companion should stop moving, face their current direction, and play a 3-frame casting animation before returning to their following behavior. The animation should be directional (down, right, left, up) to match the companion's facing direction at the moment of activation.

### Companion State Management

As a developer, I want companions to have a proper state machine with waiting, following, and casting states, so that companion behavior is clear and maintainable.

Companions should use a `CompanionState` enum with three states: `waiting` (when not recruited, standing idle), `following` (when recruited and following the player), and `casting` (when actively performing a trigger animation). The state should automatically transition from casting back to the appropriate idle/following state when the animation completes.

## Spec Scope

1. **CompanionState Enum Update** - Modify the existing `CompanionState` enum to use `waiting`, `following`, and `casting` values instead of current values
2. **Casting Animation Data** - Add casting animation frame data to companion `anim_data` struct for all four directions (down, right, left, up)
3. **Trigger Activation Integration** - Modify trigger activation logic to set companion state to `casting` and initialize animation playback
4. **Animation Playback System** - Implement frame-based animation playback in companion Draw event that plays casting animation once and returns to previous state
5. **State Transition Logic** - Update companion Step event to handle state transitions between waiting, following, and casting with proper movement restrictions during casting

## Out of Scope

- Casting animations for companions other than Canopy (they don't have the sprite frames yet)
- Sound effects specifically for casting animations (will use existing trigger sounds)
- Camera effects or screen shake during casting
- Particle effects or VFX overlays during casting
- Player control/interruption of companion casting

## Expected Deliverable

1. Companion enters `casting` state when any trigger activates, plays the appropriate directional casting animation, and returns to `following` state upon completion
2. The `CompanionState` enum uses `waiting`, `following`, and `casting` values with proper state management throughout companion logic
3. Canopy displays the correct 3-frame casting animation (frames 6-8 for down, 9-11 for right, 12-14 for left, 15-17 for up) based on facing direction when triggers activate
