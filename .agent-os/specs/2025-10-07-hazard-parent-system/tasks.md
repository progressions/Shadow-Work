# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-07-hazard-parent-system/spec.md

> Created: 2025-10-07
> Status: IMPLEMENTATION COMPLETE

## Tasks

### 1. Create Base Hazard Object with Persistence

- [x] 1.1. Write tests for hazard creation with default instance variables and data structures
- [x] 1.2. Create `obj_hazard_parent` inheriting from `obj_persistent_parent`
- [x] 1.3. Implement Create event with instance variable initialization (damage_mode, damage_amount, damage_type, damage_interval, damage_immunity_duration, trait_to_apply, trait_duration, trait_mode, trait_reapply_cooldown, sfx variables)
- [x] 1.4. Initialize data structures (entities_inside ds_list, damage_immunity_map ds_map, trait_cooldown_map ds_map)
- [x] 1.5. Implement Destroy event to clean up data structures properly
- [x] 1.6. Write tests for save/load serialization (serialize and deserialize methods)
- [x] 1.7. Implement `serialize()` method returning hazard configuration data
- [x] 1.8. Implement `deserialize(data)` method restoring hazard state from saved data
- [x] 1.9. Verify all tests pass for base object creation and persistence

### 2. Implement Collision Detection and Entity Tracking

- [x] 2.1. Write tests for player collision detection (entering, staying inside, exiting hazard)
- [x] 2.2. Write tests for enemy collision detection with `obj_enemy_parent`
- [x] 2.3. Implement Collision event with `obj_player` to add player to entities_inside list
- [x] 2.4. Implement Collision event with `obj_enemy_parent` to add enemy to entities_inside list
- [x] 2.5. Play enter SFX on first collision using `play_sfx()` function
- [x] 2.6. Implement Collision End (Other) event to remove entities from entities_inside list
- [x] 2.7. Play exit SFX when entity leaves hazard zone
- [x] 2.8. Verify collision tracking tests pass with proper enter/exit behavior

### 3. Implement Damage System Integration

- [x] 3.1. Write tests for on-enter damage mode (single damage application with immunity period)
- [x] 3.2. Write tests for continuous damage mode (repeated damage at intervals)
- [x] 3.3. Write tests for damage immunity period preventing instant death
- [x] 3.4. Write tests for trait-based damage modification (fire_immunity blocks fire damage, resistance reduces damage)
- [x] 3.5. Implement on-enter damage logic in collision events (apply damage if no immunity, set immunity timer)
- [x] 3.6. Implement continuous damage logic in Step event (iterate entities_inside, check timers, apply damage at intervals)
- [x] 3.7. Implement damage immunity timer tracking (decrement timers in Step event using damage_immunity_map)
- [x] 3.8. Integrate with existing damage pipeline (use trait modifiers, spawn damage numbers with correct type, play damage SFX)
- [x] 3.9. Verify all damage system tests pass with correct timing and immunity behavior

### 4. Implement Trait Application System

- [x] 4.1. Write tests for on-enter trait application (trait applied on first collision)
- [x] 4.2. Write tests for trait reapply cooldown (prevents spam on re-entry)
- [x] 4.3. Write tests for trait immunity blocking application (fire_immunity blocks burning trait)
- [x] 4.4. Write tests for trait duration and stacking with existing system
- [x] 4.5. Implement on-enter trait application in collision events using `apply_timed_trait(trait_to_apply, trait_duration)`
- [x] 4.6. Implement trait reapply cooldown tracking (use trait_cooldown_map, decrement in Step event)
- [x] 4.7. Add cooldown check before trait application to prevent spam
- [x] 4.8. Verify trait application tests pass with proper timing and integration with trait system

### 5. Implement Audio/Visual Feedback and Final Polish

- [x] 5.1. Write tests for looping SFX start/stop on hazard creation/destruction
- [x] 5.2. Write tests for damage number spawning with correct damage type colors
- [x] 5.3. Implement looping SFX initialization in Create event (start sfx_loop if configured)
- [x] 5.4. Stop looping SFX in Destroy event to prevent audio leaks
- [x] 5.5. Integrate damage number spawning using existing `spawn_damage_number()` function with damage_type parameter
- [x] 5.6. Set sprite animation properties (image_speed) for visual feedback
- [x] 5.7. Test example hazard configurations (fire hazard, poison cloud, ice patch) in test room
- [x] 5.8. Verify all integration tests pass with correct audio cues, visual feedback, and multi-hazard scenarios
