# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-07-yorna-triggers-completion/spec.md

> Created: 2025-10-07
> Status: Ready for Implementation

## Tasks

- [ ] 1. Implement companion notification system
  - [ ] 1.1 Create `companion_on_player_hit()` function in `scr_companion_system.gml`
  - [ ] 1.2 Add companion hit notification call in `obj_enemy_parent/Collision_obj_attack.gml` after damage calculation
  - [ ] 1.3 Extend `companion_on_player_dash()` to support crit/dash-triggered abilities
  - [ ] 1.4 Test notification system fires correctly for hits, dashes, and crits

- [ ] 2. Implement On-Hit Strike trigger
  - [ ] 2.1 Add On-Hit Strike logic to `companion_on_player_hit()` function
  - [ ] 2.2 Add cooldown management for `on_hit_strike` in `obj_companion_parent/Step_0.gml`
  - [ ] 2.3 Integrate bonus damage into enemy collision damage calculation
  - [ ] 2.4 Add visual feedback (floating text) and sound effects for trigger activation
  - [ ] 2.5 Test On-Hit Strike activates with proper cooldown (30 frames / 0.5s)

- [ ] 3. Implement Expose Weakness trigger
  - [ ] 3.1 Add Expose Weakness logic to extended `companion_on_player_dash()` function
  - [ ] 3.2 Add cooldown and unlock management for `expose_weakness` (affinity >= 8.0) in `obj_companion_parent/Step_0.gml`
  - [ ] 3.3 Create armor debuff system to reduce enemy DR by 2 for duration
  - [ ] 3.4 Add timer/alarm system for 180-frame (3s) duration with restoration
  - [ ] 3.5 Add visual feedback and sound effects for trigger activation
  - [ ] 3.6 Test Expose Weakness activates at affinity 8+ on dash/crit with 5s cooldown

- [ ] 4. Implement Execution Window trigger
  - [ ] 4.1 Add Execution Window logic to extended `companion_on_player_dash()` function
  - [ ] 4.2 Add cooldown and unlock management for `execution_window` (affinity >= 10.0) in `obj_companion_parent/Step_0.gml`
  - [ ] 4.3 Create damage multiplier system (2.0x) and armor pierce (3) application to player damage
  - [ ] 4.4 Add timer for 120-frame (2s) duration
  - [ ] 4.5 Add visual feedback and sound effects for trigger activation
  - [ ] 4.6 Test Execution Window activates at affinity 10 on dash/crit with 10s cooldown

- [ ] 5. Update universal affinity debug command
  - [ ] 5.1 Locate K key handler (likely in `obj_player/Step_0.gml` or debug script)
  - [ ] 5.2 Replace Canopy-specific affinity increase with loop over all active companions
  - [ ] 5.3 Add debug output showing all companions' new affinity levels
  - [ ] 5.4 Add floating text visual feedback for each companion
  - [ ] 5.5 Test K key increases affinity for all recruited companions simultaneously
