# Spec Tasks

## Tasks

- [ ] 1. Replace save system script with empty no-op functions
  - [ ] 1.1 Delete the existing `/scripts/scr_save_system/scr_save_system.gml` file
  - [ ] 1.2 Create new minimal `scr_save_system.gml` with empty `save_game()` and `load_game()` functions
  - [ ] 1.3 Verify game launches without errors after script replacement

- [ ] 2. Remove persistence base methods from obj_persistent_parent
  - [ ] 2.1 Open `/objects/obj_persistent_parent/Create_0.gml`
  - [ ] 2.2 Remove `serialize()` method implementation
  - [ ] 2.3 Remove `deserialize()` method implementation
  - [ ] 2.4 Keep the object intact as a parent (other objects inherit from it)
  - [ ] 2.5 Verify no errors when launching game

- [ ] 3. Remove serialization methods from child objects
  - [ ] 3.1 Remove serialize/deserialize from `/objects/obj_enemy_parent/Create_0.gml`
  - [ ] 3.2 Remove serialize/deserialize from `/objects/obj_openable/Create_0.gml`
  - [ ] 3.3 Remove serialize/deserialize from `/objects/obj_spawner_parent/Create_0.gml`
  - [ ] 3.4 Remove serialize/deserialize from `/objects/obj_hazard_parent/Create_0.gml`
  - [ ] 3.5 Remove serialize/deserialize from `/objects/obj_item_parent/Create_0.gml`
  - [ ] 3.6 Remove serialize_party_data/deserialize_party_data from `/objects/obj_enemy_party_controller/Create_0.gml`
  - [ ] 3.7 Check for and remove serialize/deserialize from `/objects/obj_enemy_corpse/Create_0.gml` (if exists)
  - [ ] 3.8 Check for and remove serialize/deserialize from `/objects/obj_interactable_parent/Create_0.gml` (if exists)

- [ ] 4. Disconnect game controller save hooks
  - [ ] 4.1 Open `/objects/obj_game_controller/Other_4.gml` (Room Start event)
  - [ ] 4.2 Remove calls to `check_for_pending_save_restore()`
  - [ ] 4.3 Remove calls to `restore_room_state_if_visited()`
  - [ ] 4.4 Open `/objects/obj_game_controller/Other_5.gml` (Room End event)
  - [ ] 4.5 Remove calls to `save_current_room_state()`
  - [ ] 4.6 Remove auto-save logic
  - [ ] 4.7 Test room transitions work without errors

- [ ] 5. Clean up save-related global variables
  - [ ] 5.1 Open `/objects/obj_game_controller/Create_0.gml`
  - [ ] 5.2 Remove initialization of `global.room_states`
  - [ ] 5.3 Remove initialization of `global.visited_rooms`
  - [ ] 5.4 Remove initialization of `global.opened_chests`
  - [ ] 5.5 Remove initialization of `global.broken_breakables`
  - [ ] 5.6 Remove initialization of `global.picked_up_items`
  - [ ] 5.7 Remove initialization of `global.pending_save_data`
  - [ ] 5.8 Remove initialization of `global.is_loading`

- [ ] 6. Verify save/load menu integration and final testing
  - [ ] 6.1 Launch game and verify no errors in console
  - [ ] 6.2 Open save/load menu and verify it displays without errors
  - [ ] 6.3 Click save button and verify no errors (should do nothing)
  - [ ] 6.4 Click load button and verify no errors (should do nothing)
  - [ ] 6.5 Test room transitions and verify game flow works normally
  - [ ] 6.6 Verify no serialization-related warnings or errors in debug output
  - [ ] 6.7 Perform full playthrough test to ensure game stability
  - [ ] 6.8 Verify all tasks complete and document any issues encountered
