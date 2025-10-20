# Spec Requirements Document

> Spec: Remove Save Game Serialization Code
> Created: 2025-10-20

## Overview

Remove all save game serialization and deserialization code from the GameMaker project while preserving the save/load menu UI. The save_game() and load_game() functions will remain as empty no-op functions to maintain UI compatibility during the rebuild phase.

## User Stories

### Developer Removing Legacy Code

As a developer, I want to remove all the existing save system code, so that I can rebuild it from scratch with a new architecture without conflicting legacy code.

The developer needs to remove all serialization logic from parent objects, remove the save system script entirely, and disconnect save hooks from the game controller while keeping the UI menus functional but non-functional.

## Spec Scope

1. **Remove Save System Script** - Delete the entire scr_save_system script file containing all 27 save/load/serialization functions
2. **Clear Persistence Methods** - Remove serialize() and deserialize() methods from obj_persistent_parent and all child objects
3. **Disconnect Game Controller Hooks** - Remove save_current_room_state() and restore_room_state_if_visited() calls from room start/end events
4. **Empty Save/Load Functions** - Replace save_game() and load_game() functions with empty no-op implementations
5. **Clean Global Variables** - Remove initialization of save-related global variables (room_states, visited_rooms, quest_flags, etc.)

## Out of Scope

- Removing the save/load menu UI objects (obj_save_load_menu)
- Removing audio settings persistence code (will be preserved for new system)
- Creating the new save system architecture (separate spec)
- Modifying quest system or dialogue system integration

## Expected Deliverable

1. The game runs without errors after removal, with save/load menus accessible but non-functional
2. All serialize() and deserialize() methods removed from codebase
3. save_game() and load_game() functions exist but perform no operations
