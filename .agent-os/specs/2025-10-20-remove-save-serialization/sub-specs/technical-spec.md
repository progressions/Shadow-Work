# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-20-remove-save-serialization/spec.md

> Created: 2025-10-20
> Version: 1.0.0

## Technical Requirements

### Phase 1: Remove Core Save System Script

**File to Delete:**
- `/scripts/scr_save_system/scr_save_system.gml` - Entire script file (1148 lines)

**Replacement Functions:**
Create a new minimal save system script with only:
```gml
// Empty no-op save function
function save_game(_slot_number) {
    // Intentionally empty - to be reimplemented
}

// Empty no-op load function
function load_game(_slot_number) {
    // Intentionally empty - to be reimplemented
}
```

### Phase 2: Remove Persistence Base Methods

**File to Modify:**
- `/objects/obj_persistent_parent/Create_0.gml`

**Changes:**
- Remove `serialize()` method implementation
- Remove `deserialize()` method implementation
- Keep the object as a parent (other objects inherit from it)

### Phase 3: Remove Child Object Serialization

**Files to Modify (remove serialize/deserialize methods):**
- `/objects/obj_enemy_parent/Create_0.gml`
- `/objects/obj_openable/Create_0.gml`
- `/objects/obj_spawner_parent/Create_0.gml`
- `/objects/obj_hazard_parent/Create_0.gml`
- `/objects/obj_item_parent/Create_0.gml`
- `/objects/obj_enemy_corpse/Create_0.gml` (if exists)
- `/objects/obj_interactable_parent/Create_0.gml` (if exists)
- `/objects/obj_enemy_party_controller/Create_0.gml` - Remove `serialize_party_data()` and `deserialize_party_data()`

### Phase 4: Disconnect Game Controller Hooks

**Files to Modify:**
- `/objects/obj_game_controller/Other_4.gml` (Room Start event)
  - Remove calls to `check_for_pending_save_restore()`
  - Remove calls to `restore_room_state_if_visited()`

- `/objects/obj_game_controller/Other_5.gml` (Room End event)
  - Remove calls to `save_current_room_state()`
  - Remove auto-save logic

- `/objects/obj_game_controller/Create_0.gml` (if applicable)
  - Remove initialization of save-related global variables:
    - `global.room_states`
    - `global.visited_rooms`
    - `global.opened_chests`
    - `global.broken_breakables`
    - `global.picked_up_items`
    - `global.pending_save_data`
    - `global.is_loading`

### Phase 5: Preserve UI Components

**Files to Keep (DO NOT MODIFY):**
- `/objects/obj_save_load_menu/` - Keep entire object and all events
- The menu will call save_game() and load_game() but they will be no-ops

### Phase 6: Update obj_save_load_menu Integration

**File to Modify:**
- `/objects/obj_save_load_menu/Create_0.gml` or relevant event

**Changes:**
- Ensure it calls `save_game(slot)` and `load_game(slot)`
- Add temporary user feedback that save system is being rebuilt (optional)

## Approach

The approach is to surgically remove all serialization infrastructure while preserving the UI layer. This creates a clean slate for rebuilding the save system without legacy code interference.

Key principles:
1. Delete at the lowest level first (serialization methods in parent objects)
2. Work upward to system-level hooks (game controller)
3. Preserve user-facing components (menus) as functional shells
4. Replace with minimal no-op implementations to prevent missing function errors

This approach ensures:
- No orphaned serialization code remains
- UI components remain testable
- Game continues to run normally (just without save functionality)
- Clean foundation for new save architecture

## Testing Requirements

1. **Menu Access Test**: Verify save/load menu can be opened without errors
2. **No-Op Test**: Verify clicking save/load buttons triggers no errors but performs no action
3. **Game Flow Test**: Verify game can start, play, and exit without crashes
4. **Clean Console**: Verify no serialization-related errors in debug output

## Implementation Order

1. Create new minimal scr_save_system script with empty functions
2. Remove serialize/deserialize from obj_persistent_parent
3. Remove serialize/deserialize from all child objects
4. Disconnect game controller hooks (Room Start/End events)
5. Remove global variable initializations
6. Test game launch and menu access
7. Verify no errors or warnings in output

## Success Criteria

- Game launches without errors
- Save/load menu opens without errors
- Save/load buttons can be clicked without crashes (but do nothing)
- No references to serialize/deserialize methods remain in code
- Room transitions work normally without save state restoration

## External Dependencies

None - This is purely internal refactoring of existing GameMaker code.
