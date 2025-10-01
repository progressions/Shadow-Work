# Spec Tasks

## Tasks

- [ ] 1. Implement Core Serialization Functions
  - [ ] 1.1 Create `serialize_player()` function to capture player position, HP, XP, level, state, dash_cooldown, is_two_handing, traits, tags, and status_effects
  - [ ] 1.2 Create `serialize_companions()` function to capture all companion data including affinity, quest_flags, triggers, auras, and recruitment status
  - [ ] 1.3 Create `serialize_inventory()` function to capture inventory array and equipped items struct
  - [ ] 1.4 Create `serialize_enemies()` function to capture enemy object type, position, HP, traits, tags, status effects, and AI state
  - [ ] 1.5 Create `deserialize_player()` function to restore all player data including status effects and traits
  - [ ] 1.6 Create `deserialize_companions()` function to restore or recreate companion instances with full state
  - [ ] 1.7 Create `deserialize_inventory()` function to restore inventory and re-equip items
  - [ ] 1.8 Create `deserialize_enemies()` function to spawn enemies with correct object type and restore all properties

- [ ] 2. Implement Quest System
  - [ ] 2.1 Create global.quest_flags ds_map in obj_game_controller Create event for boolean quest flags
  - [ ] 2.2 Create global.quest_counters ds_map in obj_game_controller Create event for numeric quest counters
  - [ ] 2.3 Create helper functions: `set_quest_flag(key, value)`, `get_quest_flag(key)`, `increment_quest_counter(key, amount)`
  - [ ] 2.4 Create `serialize_quest_data()` function to convert ds_maps to JSON-compatible structs
  - [ ] 2.5 Create `deserialize_quest_data()` function to restore ds_maps from structs
  - [ ] 2.6 Add quest flag/counter tracking to existing game events (enemy defeats, item pickups, dialogue completion)

- [ ] 3. Implement Room State Persistence System
  - [ ] 3.1 Create global.room_states struct and global.visited_rooms ds_list in obj_game_controller
  - [ ] 3.2 Create `serialize_room_state(room_index)` function to capture enemies, chests, breakables, items, and puzzle states
  - [ ] 3.3 Create `deserialize_room_state(room_index)` function to restore room state from saved data
  - [ ] 3.4 Add Room End event to obj_player or obj_game_controller to call serialize_room_state() before leaving
  - [ ] 3.5 Add Room Start logic to check for saved room state and call deserialize_room_state() if exists
  - [ ] 3.6 Implement chest tracking system (global array or ds_list of opened chest IDs)
  - [ ] 3.7 Implement breakable tracking system (global array of broken breakable IDs)
  - [ ] 3.8 Implement item pickup tracking system (global array of picked-up item spawn IDs)

- [ ] 4. Implement Save/Load Core Functions
  - [ ] 4.1 Create `save_game(slot)` function that builds root save struct, calls all serialize functions, converts to JSON, and writes to file
  - [ ] 4.2 Create `load_game(slot)` function that reads file, parses JSON, validates save_version, and calls all deserialize functions
  - [ ] 4.3 Add room transition logic to load_game() - if current_room != saved room, transition to saved room before restoring state
  - [ ] 4.4 Implement Chatterbox variable serialization using ChatterboxVariablesExport() in save
  - [ ] 4.5 Implement Chatterbox variable deserialization using ChatterboxVariablesImport() in load
  - [ ] 4.6 Add error handling for missing files, corrupted JSON, and version mismatches
  - [ ] 4.7 Add save_version field (set to 1) to root save struct for future compatibility

- [ ] 5. Implement Auto-Save System and Testing
  - [ ] 5.1 Create `auto_save()` function that calls save_game() with "autosave" as filename
  - [ ] 5.2 Add auto_save() call to Room End event with cooldown to prevent multiple saves per frame
  - [ ] 5.3 Test: Save and load in different rooms - verify player position and room transition work correctly
  - [ ] 5.4 Test: Save with companions recruited - verify affinity, quest_flags, and trigger states persist
  - [ ] 5.5 Test: Save with enemies at low HP and active status effects - verify enemies restore with correct HP, traits, and burning/slowed effects
  - [ ] 5.6 Test: Leave room, kill enemies in second room, return to first room - verify first room enemies still alive
  - [ ] 5.7 Test: Open chest, save, load - verify chest stays opened
  - [ ] 5.8 Test: Auto-save triggers on room transition and autosave.json file can be loaded successfully
