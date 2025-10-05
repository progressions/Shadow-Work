# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-04-companion-evading-behavior/spec.md

> Created: 2025-10-04
> Status: Ready for Implementation

## Tasks

- [x] 1. Implement Player Combat Timer System
  - [x] 1.1 Add combat_timer and combat_cooldown variables to obj_player Create event
  - [x] 1.2 Create is_in_combat() function in obj_player
  - [x] 1.3 Add combat_timer increment logic to obj_player Step event
  - [x] 1.4 Reset combat_timer in obj_player collision events when taking damage
  - [x] 1.5 Reset combat_timer in obj_attack collision event when hitting enemies
  - [x] 1.6 Test combat timer resets correctly on damage dealt/received

- [x] 2. Add Companion State System
  - [x] 2.1 Create CompanionState enum (following, evading) in companion script or parent
  - [x] 2.2 Add companion_state variable to obj_grimnir, obj_runa, obj_thrain Create events
  - [x] 2.3 Add evade distance variables (evade_distance_min, evade_distance_max, evade_detection_radius)
  - [x] 2.4 Implement state transition logic in companion Step events
  - [x] 2.5 Test companions transition to evading state during combat
  - [x] 2.6 Test companions return to following state after cooldown

- [x] 3. Implement Evasion Pathfinding Logic
  - [x] 3.1 Create evade_from_combat() function for companions
  - [x] 3.2 Implement avoidance vector calculation from player position
  - [x] 3.3 Add enemy detection and avoidance within evade_detection_radius
  - [x] 3.4 Calculate target evasion position at appropriate distance range
  - [x] 3.5 Integrate with existing pathfinding system (mp_grid or custom)
  - [x] 3.6 Add pathfinding throttling (recalculate every 15-30 frames)
  - [x] 3.7 Handle edge cases (tight corridors, no valid path)
  - [x] 3.8 Test companions maintain 64-128 pixel distance during evasion

- [x] 4. Polish State Transitions and Visual Feedback
  - [x] 4.1 Add position caching to prevent constant recalculation
  - [x] 4.2 Implement smooth pathfinding back to follow position on state exit
  - [x] 4.3 Add hysteresis buffer to prevent rapid state switching
  - [x] 4.4 (Optional) Add visual feedback sprite/animation for evading state
  - [x] 4.5 Test behavior in open rooms and tight corridors
  - [x] 4.6 Test performance with 3 companions evading simultaneously
  - [x] 4.7 Verify no companions getting stuck or behaving erratically
  - [x] 4.8 Final integration testing and bug fixes
