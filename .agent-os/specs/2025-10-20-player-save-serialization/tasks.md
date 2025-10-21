# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-20-player-save-serialization/spec.md

> Created: 2025-10-20
> Status: Ready for Implementation

## Tasks

- [ ] 1. Implement player serialization functions
  - [ ] 1.1 Create serialize_player() function to save position, stats, traits, and torch state
  - [ ] 1.2 Create deserialize_player() function to restore player state from saved data
  - [ ] 1.3 Test player serialization/deserialization in isolation
  - [ ] 1.4 Verify all player stats restore correctly (HP, XP, level, damage, crit stats)

- [ ] 2. Implement inventory serialization functions
  - [ ] 2.1 Create serialize_inventory() function to save item_id, count, and durability for each item
  - [ ] 2.2 Create deserialize_inventory() function to restore inventory by looking up items in global.item_database
  - [ ] 2.3 Test inventory serialization with empty inventory, partial inventory, and full inventory
  - [ ] 2.4 Verify item counts and durability values restore correctly

- [ ] 3. Implement equipment serialization functions
  - [ ] 3.1 Create serialize_equipment() function to save equipped items and loadout configuration
  - [ ] 3.2 Create deserialize_equipment() function to restore equipment from inventory references
  - [ ] 3.3 Test equipment serialization with various loadout states (melee active, ranged active)
  - [ ] 3.4 Verify equipped items appear in correct slots and active loadout is restored

- [ ] 4. Implement quest serialization functions
  - [ ] 4.1 Create serialize_quests() function to save active quests, completion flags, and counters
  - [ ] 4.2 Create deserialize_quests() function to restore quest progress and global quest flags
  - [ ] 4.3 Test quest serialization with no quests, active quests, and completed quests
  - [ ] 4.4 Verify quest objective progress and completion flags restore correctly

- [ ] 5. Implement companion serialization functions
  - [ ] 5.1 Create serialize_companions() function to save recruited companions with affinity and dialogue history
  - [ ] 5.2 Create deserialize_companions() function to restore or spawn companions at saved positions
  - [ ] 5.3 Test companion serialization with no companions, single companion, and multiple companions
  - [ ] 5.4 Verify companion affinity, position, quest flags, and dialogue history restore correctly

- [ ] 6. Implement torch carrier system serialization
  - [ ] 6.1 Create serialize_torch_state() function to save global torch carrier and player torch state
  - [ ] 6.2 Create deserialize_torch_state() function to restore torch carrier and torch time remaining
  - [ ] 6.3 Test torch serialization with torch on player, torch on companion, and no torch active
  - [ ] 6.4 Verify torch carrier ID and torch time remaining restore correctly

- [ ] 7. Implement main save_game() function
  - [ ] 7.1 Create save_game(_slot_number) function that validates slot number (1-5)
  - [ ] 7.2 Build complete save_data struct by calling all serialize functions
  - [ ] 7.3 Convert save_data to JSON string using json_stringify()
  - [ ] 7.4 Write JSON to save_slot_N.json file in GameMaker save directory
  - [ ] 7.5 Add debug logging for save operations
  - [ ] 7.6 Test saving to each slot (1-5) and verify JSON files are created

- [ ] 8. Implement main load_game() function
  - [ ] 8.1 Create load_game(_slot_number) function that validates slot number and file existence
  - [ ] 8.2 Read JSON from save_slot_N.json file
  - [ ] 8.3 Parse JSON to struct using json_parse()
  - [ ] 8.4 Call all deserialize functions with appropriate data sections
  - [ ] 8.5 Handle room transitions if player saved in different room
  - [ ] 8.6 Add debug logging for load operations
  - [ ] 8.7 Test loading from each slot and verify all state is restored

- [ ] 9. Integration testing and edge case handling
  - [ ] 9.1 Test full save/load cycle: save game → quit → restart → load → verify all state matches
  - [ ] 9.2 Test save/load with different room locations and verify room transitions work
  - [ ] 9.3 Test save/load with various inventory configurations (empty, partial, full)
  - [ ] 9.4 Test save/load with different companion configurations (none, one, multiple in different rooms)
  - [ ] 9.5 Test loading non-existent save slot and verify error handling
  - [ ] 9.6 Test loading invalid slot numbers and verify validation
  - [ ] 9.7 Test save/load with torch on different carriers (player, companion, none)
  - [ ] 9.8 Verify save/load menu buttons trigger actual save/load operations (no longer no-ops)
