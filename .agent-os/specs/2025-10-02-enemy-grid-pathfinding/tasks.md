# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-02-enemy-grid-pathfinding/spec.md

> Created: 2025-10-02
> Status: Ready for Implementation

## Tasks

- [x] 1. Setup Pathfinding Infrastructure
  - [x] 1.1 Create obj_pathfinding_controller object with Create, Step, Draw, and Clean Up events
  - [x] 1.2 Implement mp_grid_create() in Create event with 16x16 cell size based on room dimensions
  - [x] 1.3 Add obstacle marking using mp_grid_add_instances() for Tiles_Col, obj_enemy_parent, obj_rising_pillar, obj_companion_parent
  - [x] 1.4 Implement debug visualization in Draw event using mp_grid_draw() with global.debug_pathfinding flag
  - [x] 1.5 Add mp_grid_destroy() in Clean Up event to prevent memory leaks
  - [x] 1.6 Add global.debug_pathfinding = true flag to obj_game_controller Create event
  - [x] 1.7 Place obj_pathfinding_controller in room_greenwood_forest_1 and room_greenwood_forest_2

- [x] 2. Create Enemy State System Updates
  - [x] 2.1 Add EnemyState.targeting enum value to /scripts/scr_enums/scr_enums.gml
  - [x] 2.2 Add pathfinding variables to obj_enemy_parent Create event (path, ideal_range, path_update_timer, etc.)
  - [x] 2.3 Create obj_enemy_parent Clean Up event to delete path with path_delete()
  - [x] 2.4 Modify obj_enemy_parent Alarm_0 to handle targeting state and path recalculation timing
  - [x] 2.5 Test state transitions and verify path cleanup on enemy destruction

- [x] 3. Implement Pathfinding Helper Functions
  - [x] 3.1 Create /scripts/scr_enemy_pathfinding/scr_enemy_pathfinding.gml script file
  - [x] 3.2 Implement enemy_calculate_target_position() for melee and ranged target calculation
  - [x] 3.3 Implement circle strafe logic in enemy_calculate_target_position() for ranged enemies
  - [x] 3.4 Implement enemy_update_path() with mp_grid_path() and path_start()
  - [x] 3.5 Implement enemy_get_terrain_speed_modifier() to check traits and terrain
  - [x] 3.6 Test helper functions with different enemy types and ranges

- [x] 4. Create Enemy Targeting State Script
  - [x] 4.1 Create /scripts/enemy_state_targeting/enemy_state_targeting.gml script file
  - [x] 4.2 Implement aggro distance checking and state transitions (targeting ↔ idle)
  - [x] 4.3 Implement attack range checking and transitions (targeting → attacking/ranged_attacking)
  - [x] 4.4 Implement path recalculation trigger when alarm[0] <= 0 (every 120 frames)
  - [x] 4.5 Add fallback random wandering when no valid path exists
  - [x] 4.6 Integrate on_aggro sound effect when entering targeting state
  - [x] 4.7 Test targeting behavior with melee and ranged enemies

- [x] 5. Integrate Targeting State into Enemy Parent
  - [x] 5.1 Add enemy_state_targeting() call in obj_enemy_parent Step event for EnemyState.targeting
  - [x] 5.2 Add idle → targeting transition check in Step event when player within aggro_distance
  - [x] 5.3 Add play_enemy_sfx("on_aggro") when transitioning to targeting state
  - [x] 5.4 Ensure path_end() is called when exiting targeting state (to attacking or idle)
  - [x] 5.5 Test state machine transitions between idle, targeting, attacking, and ranged_attacking

- [x] 6. Implement Debug Visualization
  - [x] 6.1 Add path drawing in obj_enemy_parent Draw event using draw_path()
  - [x] 6.2 Check global.debug_pathfinding flag before drawing
  - [x] 6.3 Use yellow color with 0.5 alpha for path visualization
  - [x] 6.4 Test visualization in both rooms with multiple enemies

- [x] 7. Configure Ranged Enemy Ideal Range
  - [x] 7.1 Set ideal_range for obj_greenwood_bandit based on ranged_attack_range
  - [x] 7.2 Test ranged enemy kiting behavior (maintaining distance)
  - [x] 7.3 Test circle strafe behavior when in optimal range
  - [x] 7.4 Verify ranged enemies back away when player gets too close

- [x] 8. Implement Terrain Speed Modifiers
  - [x] 8.1 Verify get_terrain_at_position() function exists and works correctly
  - [x] 8.2 Fix enemy_get_terrain_speed_modifier() to check tags array instead of permanent_traits
  - [x] 8.3 Verify speed modifier applies to path_start() speed parameter
  - [x] 8.4 Fix apply_tag_traits() to support both parameterless (iterate tags array) and parameterized (apply specific tag) usage

  **Note:** No aquatic enemies exist yet to test water speed bonus. No lava terrain exists to test fireborne lava speed bonus. System is implemented correctly and will work when these assets are added.

- [ ] 9. Final Integration Testing
  - [ ] 9.1 Test with up to 15 enemies in a room to verify performance
  - [ ] 9.2 Verify enemies navigate around all obstacle types (walls, pillars, other enemies, companions)
  - [ ] 9.3 Test path recalculation every 2 seconds (120 frames) works correctly
  - [ ] 9.4 Verify melee enemies close distance and attack when in range
  - [ ] 9.5 Verify ranged enemies maintain optimal distance and circle strafe
  - [ ] 9.6 Test fallback wandering behavior when no path exists
  - [ ] 9.7 Verify debug visualization toggles correctly with global.debug_pathfinding flag
  - [ ] 9.8 Test in both room_greenwood_forest_1 and room_greenwood_forest_2
  - [ ] 9.9 Verify no pathfinding occurs in room_initial
  - [ ] 9.10 Test status effect integration (slowed enemies move slower on paths)
