# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-03-enemy-spawner-system/spec.md

> Created: 2025-10-03
> Status: ✅ **IMPLEMENTATION COMPLETE**
> Completed: 2025-10-03

## Tasks

- [X] 1. Create core spawner object and helper scripts
  - [X] 1.1 Create `obj_spawner_parent` object with base sprite (can be invisible placeholder)
  - [X] 1.2 Implement spawner configuration variables in Create event (spawn_table array, spawn_interval, max_concurrent_enemies, max_total_spawns, proximity_radius, is_damageable, is_visible, spawn_sound)
  - [X] 1.3 Add spawner state tracking variables (spawned_count, active_spawned_enemies array, is_active, is_destroyed, spawn_timer)
  - [X] 1.4 Create `scr_spawner_helpers.gml` script file for spawner utility functions
  - [X] 1.5 Implement `spawner_select_enemy()` function using weighted selection logic similar to loot table system
  - [X] 1.6 Add Draw event to handle visibility logic (draw sprite only if is_visible is true)
  - [X] 1.7 Implement basic collision/damage handling in Collision event if is_damageable is true
  - [X] 1.8 Test spawner object can be placed in test room and initializes correctly

- [X] 2. Implement weighted spawn system and spawn logic
  - [X] 2.1 Design spawn_table data structure as array of structs with enemy_object and weight properties (e.g., [{enemy: obj_orc, weight: 70}, {enemy: obj_burglar, weight: 30}])
  - [X] 2.2 Implement `spawner_spawn_enemy()` function that selects enemy from weighted table and creates instance
  - [X] 2.3 Add spawned enemy tracking - store instance ID in active_spawned_enemies array
  - [X] 2.4 Implement spawn position logic (spawn at spawner x/y with optional random offset to avoid stacking)
  - [X] 2.5 Add spawn interval timer logic in Step event (decrement spawn_timer, trigger spawn when reaches 0)
  - [X] 2.6 Implement max_total_spawns check - deactivate spawner when spawned_count reaches limit (finite mode)
  - [X] 2.7 Add optional spawn sound effect playback when enemy is created
  - [X] 2.8 Test spawner correctly creates weighted enemy selection over multiple spawn cycles

- [X] 3. Implement proximity activation and enemy cap management
  - [X] 3.1 Add `spawner_check_proximity()` function to calculate distance between spawner and player
  - [X] 3.2 Implement proximity activation logic in Step event - set is_active based on player distance vs proximity_radius
  - [X] 3.3 Add spawner activation/deactivation behavior - reset spawn_timer when activating, pause when deactivating
  - [X] 3.4 Implement `spawner_cleanup_dead_enemies()` function to remove destroyed enemy IDs from active_spawned_enemies array
  - [X] 3.5 Add max_concurrent_enemies cap check - only spawn if array_length(active_spawned_enemies) < max_concurrent_enemies
  - [X] 3.6 Call cleanup function in Step event before spawn logic to maintain accurate enemy count
  - [X] 3.7 Add spawner state validation - do not spawn if is_destroyed is true
  - [X] 3.8 Test proximity activation works correctly and enemy cap prevents over-spawning

- [X] 4. Implement damageable spawner mechanics and spawner destruction
  - [X] 4.1 Add hp_total and hp_current variables to spawner configuration
  - [X] 4.2 Implement `spawner_take_damage(damage_amount)` function to reduce hp_current
  - [X] 4.3 Add Collision event with obj_attack to handle player attack damage if is_damageable is true
  - [X] 4.4 Implement spawner destruction logic - set is_destroyed to true and is_active to false when hp_current reaches 0
  - [X] 4.5 Add optional spawner death effect - play sound or create visual feedback (simple particle or object)
  - [X] 4.6 Ensure destroyed spawners stop all spawning behavior and become inactive permanently
  - [X] 4.7 Consider adding spawner to damageable object parent if needed for existing damage systems
  - [X] 4.8 Test damageable spawners can be destroyed by player attacks and stop spawning correctly

- [X] 5. Integrate spawner state into save/load system
  - [X] 5.1 Review existing save/load system implementation to understand serialization pattern
  - [X] 5.2 Add spawner state serialization function `spawner_get_save_data()` returning struct with spawned_count, is_active, is_destroyed, hp_current
  - [X] 5.3 Implement spawner state restoration function `spawner_load_save_data(save_struct)` to apply saved values
  - [X] 5.4 Hook spawner save/load into global save system - likely requires registering spawners with room persistence
  - [X] 5.5 Ensure spawned enemies integrate with existing enemy save/load system (should work automatically if using standard enemy objects)
  - [X] 5.6 Add spawner unique ID or instance tracking for save system matching (use instance id or room-based key)
  - [X] 5.7 Test save/load preserves spawner destroyed state correctly
  - [X] 5.8 Test save/load maintains spawn counts and active spawners resume spawning after load

- [X] 6. Create example child spawner objects and documentation
  - [X] 6.1 Create `obj_spawner_orc_camp` as example finite spawner (spawns 5 orcs then stops)
  - [X] 6.2 Create `obj_spawner_bandit_ambush` as proximity-triggered visible spawner with mixed enemy types
  - [X] 6.3 Create `obj_spawner_endless_arena` as continuous invisible invulnerable spawner for arena mode
  - [X] 6.4 Create `obj_spawner_damageable_nest` as visible damageable spawner with health and destruction mechanics
  - [X] 6.5 Place example spawners in test room demonstrating different configurations
  - [X] 6.6 Add code comments documenting spawner configuration variables and usage patterns
  - [X] 6.7 Test all example spawner types work correctly with different behavioral modes
  - [X] 6.8 Verify complete spawner system functionality across all features (spawning, caps, proximity, damage, save/load)
