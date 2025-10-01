# Save System Testing Guide

This guide provides test cases for the multi-slot save system implementation.

## Quick Testing Commands

Add these debug commands to your game for easy testing (e.g., in obj_player Step event):

```gml
// Debug save/load commands
if (keyboard_check_pressed(vk_f5)) {
    save_game(1);
    show_debug_message("Manual save to slot 1");
}

if (keyboard_check_pressed(vk_f9)) {
    load_game(1);
    show_debug_message("Manual load from slot 1");
}

if (keyboard_check_pressed(vk_f6)) {
    save_game(2);
    show_debug_message("Manual save to slot 2");
}

if (keyboard_check_pressed(vk_f10)) {
    load_game(2);
    show_debug_message("Manual load from slot 2");
}

if (keyboard_check_pressed(vk_f8)) {
    load_game("autosave");
    show_debug_message("Load from autosave");
}
```

## Test Case 1: Basic Save and Load

**Objective**: Verify save and load in the same room

### Steps:
1. Start a new game
2. Move the player to a specific position
3. Press F5 to save to slot 1
4. Move the player to a different position
5. Press F9 to load from slot 1

### Expected Result:
- Player should return to the saved position
- Player HP, XP, and level should match saved values
- Debug console shows "GAME STATE RESTORED SUCCESSFULLY"

## Test Case 2: Save and Load in Different Rooms

**Objective**: Verify room transition during load

### Steps:
1. Start in room A
2. Move to specific position
3. Press F5 to save to slot 1
4. Go to room B
5. Press F9 to load from slot 1

### Expected Result:
- Game transitions back to room A
- Player appears at saved position
- Debug console shows "Room transition needed" message
- Debug console shows "Pending save data detected - restoring now"

## Test Case 3: Save with Companions

**Objective**: Verify companion data persistence

### Steps:
1. Recruit Canopy (or another companion)
2. Increase affinity to a specific value (e.g., 5.5)
3. Press F5 to save
4. Close and reopen the game, or change affinity value
5. Press F9 to load

### Expected Result:
- Companion is still recruited
- Companion affinity matches saved value
- Companion position is restored
- Companion triggers and auras are in correct state

## Test Case 4: Save with Enemies and Status Effects

**Objective**: Verify enemy state persistence

### Steps:
1. Find a room with enemies
2. Damage an enemy to 50% HP (but don't kill it)
3. Apply a status effect (e.g., burning) to an enemy
4. Press F5 to save
5. Kill the damaged enemy
6. Press F9 to load

### Expected Result:
- Enemy is alive again with 50% HP
- Status effect is still active with correct remaining duration
- Enemy traits and tags are preserved

## Test Case 5: Room Persistence

**Objective**: Verify rooms remember their state

### Steps:
1. Enter room A with enemies
2. Kill half the enemies
3. Leave room A (go to room B)
4. Return to room A

### Expected Result:
- Dead enemies stay dead
- Living enemies are in their saved positions with saved HP
- Debug console shows "Restored previously visited room"

## Test Case 6: Item Pickup Tracking

**Objective**: Verify picked up items don't respawn

### Steps:
1. Enter a room with ground items
2. Pick up an item
3. Leave the room
4. Return to the room

### Expected Result:
- Picked up item does not respawn
- Other items that weren't picked up are still there

## Test Case 7: Quest Flag Persistence

**Objective**: Verify quest flags and counters save/load

### Steps:
1. Kill 5 enemies (increments enemies_defeated counter)
2. Pick up 3 items (increments items_collected counter)
3. Press F5 to save
4. Kill 5 more enemies
5. Press F9 to load

### Expected Result:
- enemies_defeated counter is 5 (not 10)
- items_collected counter is 3
- Debug console shows "Quest data restored" with correct counts

## Test Case 8: Auto-Save Functionality

**Objective**: Verify auto-save triggers on room transition

### Steps:
1. Start in room A
2. Make some changes (move player, kill enemies, etc.)
3. Transition to room B
4. Close the game WITHOUT manually saving
5. Reopen the game
6. Press F8 to load autosave

### Expected Result:
- autosave.json file exists in save directory
- Game state is restored to just before the room transition
- All changes made in room A are preserved

## Test Case 9: Multiple Save Slots

**Objective**: Verify multiple save slots work independently

### Steps:
1. In room A, press F5 (save to slot 1)
2. Go to room B
3. Press F6 (save to slot 2)
4. Press F9 (load slot 1)
5. Verify you're in room A
6. Press F10 (load slot 2)
7. Verify you're in room B

### Expected Result:
- Slot 1 loads room A
- Slot 2 loads room B
- Each slot maintains its own independent state

## Test Case 10: Inventory and Equipment

**Objective**: Verify inventory and equipped items persist

### Steps:
1. Pick up items to fill inventory
2. Equip specific items in each slot
3. Press F5 to save
4. Drop items and unequip everything
5. Press F9 to load

### Expected Result:
- Inventory contains all saved items
- Equipment slots have correct items equipped
- Wielder effects (status effects from equipped items) are reapplied

## Save File Locations

Save files are stored in GameMaker's default save directory:
- **Windows**: `%localappdata%\<game_name>\`
- **macOS**: `~/Library/Application Support/<game_name>/`
- **Linux**: `~/.config/<game_name>/`

File names:
- `save_slot_1.json` through `save_slot_5.json`
- `autosave.json`

## Debugging Tips

1. **Check debug console**: All save/load operations log detailed information
2. **Inspect save files**: Open JSON files in a text editor to verify data
3. **Look for errors**: Watch for "ERROR:" messages in debug console
4. **Version mismatch**: Save version is checked on load (currently version 1)

## Known Limitations (TODO for Future)

- Chests and breakables require implementation (see CHEST_AND_BREAKABLE_TRACKING.md)
- Puzzle states not yet tracked (add when puzzle system expands)
- No save file encryption or obfuscation
- No save file compression
