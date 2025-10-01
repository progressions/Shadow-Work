# Spec Requirements Document

> Spec: Multi-Slot Save System with Room State Persistence
> Created: 2025-10-01

## Overview

Implement a comprehensive save/load system that supports 5 save slots, serializing player stats, inventory, equipment, companion data (affinity and quest flags), enemy states (position, health, traits, tags, status effects), NPC dialogue progress, and complete room state persistence. The system includes auto-save functionality to prevent progress loss and uses JSON format for human-readable, debuggable save files stored in GameMaker's save directory.

## User Stories

### Manual Save and Load

As a player, I want to save my game progress to one of 5 save slots, so that I can maintain multiple playthroughs or experiment with different choices without losing my main save.

The player can access a save menu (not yet implemented in this spec, but the backend will support it) and choose to save to slot 1-5. The system captures the complete game state including player position, HP, XP, level, inventory, equipped items, all companion data (position, affinity, quest flags, trigger/aura states), all enemy states in the current room (position, HP, traits, tags, status effects with remaining durations), NPC dialogue progress, quest flags, and world state changes (opened chests, broken breakables, picked-up items). When the player loads a save, they return to the exact state when they saved.

### Auto-Save Protection

As a player, I want the game to automatically save my progress periodically, so that I don't lose significant progress if I forget to manually save or if the game crashes.

The system automatically saves the complete game state every time the player transitions between rooms, ensuring that progress is preserved even if the player forgets to manually save. Auto-saves are stored separately from manual saves and can be accessed as a recovery option.

### Room State Persistence

As a player, I want rooms to remember their state when I leave and return, so that enemies I defeated stay defeated, items I picked up stay picked up, and puzzles I solved stay solved.

When the player leaves a room, the system captures a snapshot of that room's state (enemy positions/health/traits/status effects, item pickups, chest states, breakable objects, puzzle states). This data is stored in a global room data collection. When the player returns to a previously visited room, the system restores the saved state instead of resetting to default, creating a persistent world.

## Spec Scope

1. **Save Slot Management** - Implement 5 distinct save slots with JSON serialization, storing complete game state to GameMaker's save directory using `game_save_id` for file paths.

2. **Player Data Serialization** - Serialize player position (x, y), current room, HP, max HP, XP, level, facing direction, movement state, dash cooldown, and current PlayerState.

3. **Inventory & Equipment Serialization** - Serialize complete inventory array and equipped items struct (right_hand, left_hand, head, torso, legs), including item IDs, quantities, and two-handing status.

4. **Companion Data Serialization** - Serialize all companion data including companion_id, position, affinity level, quest_flags struct, relationship_stage, dialogue_history array, trigger states (unlocked, cooldown, active, duration), aura states, and recruitment status.

5. **Enemy State Serialization** - Serialize all enemies in current room with position, HP, enemy type (object_index as string), facing direction, tags array, traits array with stack counts, active status_effects array with remaining durations and tick timers, and AI state.

6. **NPC Dialogue Progress** - Serialize dialogue progress for all NPCs including which dialogue nodes have been seen, relationship values, and completed dialogue branches using Chatterbox variable states.

7. **Quest Flag System** - Create and serialize a global quest flag system using a ds_map or struct to track boolean flags (quest started, quest completed, dialogue seen, event triggered) and numeric counters (items collected, enemies defeated).

8. **Room State Persistence** - Implement a global room state collection (ds_map or struct keyed by room index) that stores room-specific data: enemy states, picked-up item IDs, opened chest IDs, broken breakable IDs, puzzle states (button presses, pillar positions), and item ground spawns with positions.

9. **Auto-Save System** - Implement automatic saving on room transitions, with a separate auto-save file that doesn't overwrite manual save slots, triggered by the Room End event.

10. **Save/Load Core Functions** - Create `save_game(slot)`, `load_game(slot)`, `auto_save()`, `serialize_player()`, `serialize_companions()`, `serialize_enemies()`, `serialize_room_state()`, `deserialize_and_restore()` functions.

## Out of Scope

- Save slot UI/menu interface (backend only in this spec)
- Cloud save functionality
- Save file encryption or obfuscation
- Save file compression
- Cross-platform save compatibility
- Save file migration tools for future schema changes
- Undo/redo save functionality
- Save file metadata (playtime, screenshot, timestamp) - basic timestamp only

## Expected Deliverable

1. **Functional save/load system** - Player can save to any of 5 slots and load from any slot, restoring the exact game state including position, stats, inventory, companions, enemies, and room states.

2. **Working auto-save** - Game automatically saves on room transitions without player input, creating a safety net for progress preservation.

3. **Room state persistence** - Rooms maintain their state across visits: defeated enemies stay defeated, collected items stay collected, opened chests stay opened, and solved puzzles stay solved.

4. **JSON save files** - Save files are stored in human-readable JSON format in GameMaker's save directory, making them easy to debug and inspect during development.

5. **Complete serialization** - All critical game state is captured including player stats, inventory, equipment, companion affinity/quest flags/triggers/auras, enemy position/health/traits/status effects, NPC dialogue progress, quest flags, and world state changes.
