# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-07-tile-terrain-effects/spec.md

> Created: 2025-10-07
> Status: Ready for Implementation

## Tasks

- [ ] 1. Create terrain effects database and core system functions
  - [ ] 1.1 Add `global.terrain_effects_map` to `obj_game_controller/Create_0.gml` with lava, poison_pool, ice, path, water, and grass configurations
  - [ ] 1.2 Add `terrain_applied_traits`, `current_terrain`, and `terrain_speed_modifier` variables to `obj_player/Create_0.gml`
  - [ ] 1.3 Add `terrain_applied_traits`, `current_terrain`, and `terrain_speed_modifier` variables to `obj_enemy_parent/Create_0.gml`
  - [ ] 1.4 Create `apply_terrain_effects()` function in `trait_system.gml` using existing `apply_timed_trait()` for trait application
  - [ ] 1.5 Test terrain database initialization and verify all terrain configs are accessible

- [ ] 2. Integrate terrain effects into player movement
  - [ ] 2.1 Add `apply_terrain_effects()` call to `obj_player/Step_0.gml` before state machine
  - [ ] 2.2 Update `player_state_walking.gml` to use `terrain_speed_modifier` instead of hardcoded path check
  - [ ] 2.3 Update `player_state_dashing.gml` to use `terrain_speed_modifier` if terrain affects dashing
  - [ ] 2.4 Test player on lava tiles: verify burning trait applied once, persists after leaving
  - [ ] 2.5 Test player on path tiles: verify 25% speed increase (backward compatibility)
  - [ ] 2.6 Test player with fire_immunity on lava: verify burning applied but no damage dealt

- [ ] 3. Integrate terrain effects into enemy movement
  - [ ] 3.1 Add `apply_terrain_effects()` call to `obj_enemy_parent/Step_0.gml` before state machine
  - [ ] 3.2 Update `enemy_get_terrain_speed_modifier()` in `scr_enemy_pathfinding.gml` to return `terrain_speed_modifier` variable
  - [ ] 3.3 Remove hardcoded terrain checks from `enemy_get_terrain_speed_modifier()` (water/lava/sand tag checks)
  - [ ] 3.4 Test enemy on lava: verify burning trait applied and speed reduction works
  - [ ] 3.5 Test enemy with aquatic tag on water: verify wet trait applied and speed modifier works

- [ ] 4. Implement enemy pathfinding hazard avoidance
  - [ ] 4.1 Create `mark_hazardous_terrain_in_grid()` function in `scr_enemy_pathfinding.gml`
  - [ ] 4.2 Add call to `mark_hazardous_terrain_in_grid()` in `enemy_update_path()` after grid creation
  - [ ] 4.3 Test enemy pathfinding around lava tiles: verify enemies avoid lava when calculating paths
  - [ ] 4.4 Test enemy with fire_immunity: verify lava tiles NOT marked as obstacles for immune enemies
  - [ ] 4.5 Test cornered enemy: verify enemy can still physically move onto hazard tiles if no path exists

- [ ] 5. Create test room and verify all terrain types
  - [ ] 5.1 Create test room with sections for each terrain type (lava, poison, ice, path, water, grass)
  - [ ] 5.2 Add Tiles_Lava layer with lava tiles
  - [ ] 5.3 Update `global.terrain_tile_map` to include Tiles_Lava layer mapping
  - [ ] 5.4 Test all terrain types with player: verify traits and speed modifiers apply correctly
  - [ ] 5.5 Test all terrain types with enemies: verify pathfinding avoids hazards and traits apply correctly
  - [ ] 5.6 Verify trait durations persist after leaving terrain and expire naturally
