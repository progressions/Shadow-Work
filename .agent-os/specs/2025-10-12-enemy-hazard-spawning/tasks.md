# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-12-enemy-hazard-spawning/spec.md

> Created: 2025-10-13
> Status: Ready for Implementation

## Tasks

- [ ] 1. Create Hazard Projectile System
  - [ ] 1.1 Create obj_hazard_projectile object with Create, Step, and Collision events
  - [ ] 1.2 Implement travel distance tracking and landing logic
  - [ ] 1.3 Add hazard spawn on landing with configurable object type
  - [ ] 1.4 Implement player collision damage without projectile destruction
  - [ ] 1.5 Add wall/obstacle collision with early hazard spawn
  - [ ] 1.6 Test projectile travel distance accuracy and hazard spawning

- [ ] 2. Extend Enemy State Machine
  - [ ] 2.1 Add EnemyState.hazard_spawning to scr_enums.gml
  - [ ] 2.2 Create scr_enemy_state_hazard_spawning.gml state handler
  - [ ] 2.3 Implement windup timer, animation, and sound playback
  - [ ] 2.4 Add projectile spawning at end of windup
  - [ ] 2.5 Implement cooldown tracking and state transitions
  - [ ] 2.6 Add state dispatcher case in obj_enemy_parent Step event
  - [ ] 2.7 Test hazard spawning state with windup and cooldown

- [ ] 3. Add Enemy Configuration System
  - [ ] 3.1 Add hazard spawning configuration variables to obj_enemy_parent Create event
  - [ ] 3.2 Add hazard windup sound to enemy_sounds struct
  - [ ] 3.3 Implement animation fallback logic (ranged → melee → idle)
  - [ ] 3.4 Update scr_animation_helpers.gml with hazard_spawning animation data
  - [ ] 3.5 Test configuration with multiple hazard types and distances

- [ ] 4. Implement Hazard Spawner Movement Profile
  - [ ] 4.1 Create movement_profile_hazard_spawner_update.gml script
  - [ ] 4.2 Implement slow approach with speed multiplier
  - [ ] 4.3 Add stop-at-ideal-range logic without retreat
  - [ ] 4.4 Integrate hazard spawn trigger conditions (range, cooldown, LOS)
  - [ ] 4.5 Test movement profile behavior and positioning

- [ ] 5. Implement Multi-Attack Boss System
  - [ ] 5.1 Add allow_multi_attack and hazard_priority variables to obj_enemy_parent
  - [ ] 5.2 Implement attack mode decision logic with weighted selection
  - [ ] 5.3 Add independent cooldown tracking for melee, ranged, and hazard attacks
  - [ ] 5.4 Test boss multi-attack patterns with all three attack types
  - [ ] 5.5 Verify cooldown independence and attack prioritization

- [ ] 6. Create Example Enemy Implementations
  - [ ] 6.1 Create obj_fire_cultist as dedicated hazard spawner
  - [ ] 6.2 Configure fire cultist with appropriate stats and hazard settings
  - [ ] 6.3 Create obj_boss_fire_lord with multi-attack capability
  - [ ] 6.4 Test both enemy types in combat scenarios
  - [ ] 6.5 Verify all configuration options work correctly
