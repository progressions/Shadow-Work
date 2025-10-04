# Spec Requirements Document

> Spec: VN Intro on First Sight
> Created: 2025-10-04

## Overview

Implement a system that automatically triggers a VN (visual novel) dialogue interface when a character or object first becomes visible within the camera view. This system will work with companions, enemies, bosses, and arbitrary trigger objects placed in rooms, featuring automatic camera panning to spotlight the character and persistent flags to prevent re-triggering.

## User Stories

### Character Introduction

As a player, I want to see a dramatic VN introduction when I first encounter important characters (companions, bosses, enemies), so that I get narrative context and emotional engagement with these characters.

When the player moves through the world and a flagged character enters the camera viewport, the game smoothly pans the camera to center on that character, pauses gameplay, and opens the VN interface with the character's introduction dialogue. After the player completes the dialogue, the camera pans back to the player and gameplay resumes. This introduction only happens once per character instance.

### Environmental Storytelling

As a player, I want to receive narrative moments when reaching important locations, so that the world feels alive and story events unfold naturally.

A level designer places an invisible "VN trigger" object at a specific location on the map (e.g., overlooking a distant castle). When the player walks into camera view of this object, the VN interface opens with environmental narration like "You see a massive castle looming in the distance, its dark towers piercing the sky." This provides cinematic storytelling without interrupting exploration flow.

### Boss Encounter Introduction

As a player, I want memorable introductions to boss characters, so that encounters feel epic and meaningful.

When a persistent boss enemy first appears on screen, the camera dramatically pans to center them, the VN interface opens with their introduction (name, portrait, threatening dialogue), and after the player dismisses it, combat begins. The boss's persistence ensures this intro only plays once even if the player dies and returns.

## Spec Scope

1. **Camera Visibility Detection** - System detects when objects with VN intro flags enter view camera 0 bounds using GameMaker camera functions
2. **Camera Panning System** - Smooth camera pan from player to spotted character, with return pan to player when VN closes
3. **Flexible VN Trigger Configuration** - Per-instance variables for yarn file, start node, character name (optional), and seen flag identifier
4. **Generic VN Helper Functions** - New VN dialogue functions that work without companion-specific dependencies (theme songs, recruitment variables)
5. **Persistence System** - Global flag tracking which intro IDs have been seen, preventing re-triggers across game sessions

## Out of Scope

- Multiple simultaneous intro triggers (only one at a time)
- Custom camera pan speeds per instance (use system default)
- VN intro queue system for multiple characters visible at once
- Audio/music changes specific to non-companion VN intros (companions already handle this)

## Expected Deliverable

1. Player walks into view range of a flagged companion/enemy/object, camera smoothly pans to center it, VN opens with configured dialogue, and after completion camera returns to player with gameplay resumed
2. Seen flags persist correctly - previously seen intros do not re-trigger even after save/load or room transitions
3. Instance creation code can easily configure any object to trigger a VN intro by setting simple variables (yarn_file, node, character_name, intro_id)
