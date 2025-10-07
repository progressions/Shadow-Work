# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-07-yorna-triggers-completion/spec.md

> Created: 2025-10-07
> Status: IMPLEMENTATION COMPLETE

## Tasks

- [x] 1. Implement companion notification system
  - [x] 1.1 Create `companion_on_player_hit()` function in `scr_companion_system.gml`
  - [x] 1.2 Add companion hit notification call in `obj_enemy_parent/Collision_obj_attack.gml` after damage calculation
  - [x] 1.3 Extend `companion_on_player_dash()` to support crit/dash-triggered abilities
  - [x] 1.4 Test notification system fires correctly for hits, dashes, and crits

- [x] 2. Implement On-Hit Strike trigger
  - [x] 2.1 Add On-Hit Strike logic to `companion_on_player_hit()` function
  - [x] 2.2 Add cooldown management for `on_hit_strike` in `obj_companion_parent/Step_0.gml`
  - [x] 2.3 Integrate bonus damage into enemy collision damage calculation
  - [x] 2.4 Add visual feedback (floating text) and sound effects for trigger activation
  - [x] 2.5 Test On-Hit Strike activates with proper cooldown (30 frames / 0.5s)

- [x] 3. Implement Expose Weakness trigger
  - [x] 3.1 Add Expose Weakness logic to extended `companion_on_player_dash()` function
  - [x] 3.2 Add cooldown and unlock management for `expose_weakness` (affinity >= 8.0) in `obj_companion_parent/Step_0.gml`
  - [x] 3.3 Create armor debuff system to reduce enemy DR by 2 for duration
  - [x] 3.4 Add timer/alarm system for 180-frame (3s) duration with restoration
  - [x] 3.5 Add visual feedback and sound effects for trigger activation
  - [x] 3.6 Test Expose Weakness activates at affinity 8+ on dash/crit with 5s cooldown

- [x] 4. Implement Execution Window trigger
  - [x] 4.1 Add Execution Window logic to extended `companion_on_player_dash()` function
  - [x] 4.2 Add cooldown and unlock management for `execution_window` (affinity >= 10.0) in `obj_companion_parent/Step_0.gml`
  - [x] 4.3 Create damage multiplier system (2.0x) and armor pierce (3) application to player damage
  - [x] 4.4 Add timer for 120-frame (2s) duration
  - [x] 4.5 Add visual feedback and sound effects for trigger activation
  - [x] 4.6 Test Execution Window activates at affinity 10 on dash/crit with 10s cooldown

- [x] 5. Update universal affinity debug command
  - [x] 5.1 Locate K key handler (likely in `obj_player/Step_0.gml` or debug script)
  - [x] 5.2 Replace Canopy-specific affinity increase with loop over all active companions
  - [x] 5.3 Add debug output showing all companions' new affinity levels
  - [x] 5.4 Add floating text visual feedback for each companion
  - [x] 5.5 Test K key increases affinity for all recruited companions simultaneously
