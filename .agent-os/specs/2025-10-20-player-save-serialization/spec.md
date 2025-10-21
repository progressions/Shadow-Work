# Spec Requirements Document

> Spec: Player Save Serialization (Incremental Save System Phase 1)
> Created: 2025-10-20
> Status: Planning

## Overview

Implement player state serialization as the first phase of rebuilding the save/load system. This phase focuses on saving and restoring the player's position, stats, inventory, equipment, quest progress, and recruited companions to JSON files. This establishes the foundation for a complete save system to be built incrementally.

## User Stories

### Player Saving Game Progress

As a player, I want to save my current game state to a save slot, so that I can quit the game and resume my progress later with my character, items, and quest progress intact.

The player can press a save button in the save/load menu, select a slot (1-5), and save their current position, health, inventory, equipment, quest progress, and recruited companions. The save creates a JSON file that can be loaded later to restore this exact state.

### Player Loading Saved Game

As a player, I want to load a previously saved game from a save slot, so that I can continue playing from where I left off with all my progress restored.

The player can press a load button in the save/load menu, select a previously saved slot, and have their character restored to the exact state when the save was created, including position, health, inventory, equipped items, active quests, and recruited companions.

## Spec Scope

1. **Player State Serialization** - Save player position, stats (HP, XP, level), facing direction, elevation, and base combat stats to JSON
2. **Inventory Serialization** - Save all inventory items with their item_id, count, and durability, along with equipped items per slot
3. **Equipment & Loadout Serialization** - Save active loadout (melee/ranged) and items equipped in each loadout's hands
4. **Quest Progress Serialization** - Save all active quests with objective progress, quest completion flags, and quest counters/flags
5. **Companion Serialization** - Save recruited companions with their affinity, position, dialogue history, quest flags, and torch state
6. **Save File Management** - Implement save_game(slot) to write JSON to save_slot_N.json files in GameMaker's save directory
7. **Load File Management** - Implement load_game(slot) to read JSON and restore player, inventory, quests, and companions
8. **Torch State Serialization** - Save player and companion torch states (active, time remaining, carrier)

## Out of Scope

- Room state persistence (enemies, chests, breakables) - Phase 2
- World state tracking (visited rooms, opened containers) - Phase 2
- Auto-save functionality - Phase 3
- Save file metadata (timestamp, room name, playtime) - Phase 3
- Multiple save profiles or cloud saves - Future enhancement
- Save file corruption recovery - Future enhancement

## Expected Deliverable

1. Player can save to any of 5 slots and the save file contains complete player, inventory, quest, and companion data in JSON format
2. Player can load from any saved slot and be restored to the exact position, stats, inventory, equipment, quests, and companions from when the save was created
3. Save/load menu buttons trigger actual save/load operations (no longer no-ops)

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-20-player-save-serialization/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-20-player-save-serialization/sub-specs/technical-spec.md
