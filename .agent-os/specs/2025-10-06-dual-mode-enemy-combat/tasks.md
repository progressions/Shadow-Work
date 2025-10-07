# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-06-dual-mode-enemy-combat/spec.md

> Created: 2025-10-06
> Status: IMPLEMENTATION COMPLETE

## Tasks

### 1. Core Dual-Mode Properties and Configuration

- [x] 1.1 Add dual-mode configuration properties to obj_enemy_parent/Create_0.gml
  - [x] 1.1.1 Add `enable_dual_mode` flag (default: false) after existing combat properties
  - [x] 1.1.2 Add `preferred_attack_mode` string (options: "none", "melee", "ranged")
  - [x] 1.1.3 Add `melee_range_threshold` with default value of `attack_range * 0.5`
  - [x] 1.1.4 Add `retreat_when_close` flag (default: false)
  - [x] 1.1.5 Add `attack_mode_cache` and `cache_timer` variables for performance optimization

- [x] 1.2 Add formation role assignment support to obj_enemy_parent
  - [x] 1.2.1 Add optional `formation_role` variable (values: "rear", "front", "support", or undefined)
  - [x] 1.2.2 Verify variable can be set by party controller without causing errors

- [x] 1.3 Document property behaviors and configuration options
  - [x] 1.3.1 Add inline comments explaining each dual-mode property
  - [x] 1.3.2 Document interaction between `preferred_attack_mode` and `retreat_when_close`

### 2. Attack Mode Decision Logic Implementation

- [x] 2.1 Write test cases for dual-mode attack selection logic
  - [x] 2.1.1 Test: Enemy uses ranged when player is beyond ideal_range
  - [x] 2.1.2 Test: Enemy uses melee when player is within melee_range_threshold
  - [x] 2.1.3 Test: Enemy respects preferred_attack_mode in flexible zone (between thresholds)
  - [x] 2.1.4 Test: Enemy respects cooldown independence (can't spam by mode switching)
  - [x] 2.1.5 Test: Formation role overrides distance-based decision

- [x] 2.2 Implement distance-based attack mode decision in scr_enemy_state_targeting.gml
  - [x] 2.2.1 Calculate distance to player at start of targeting logic
  - [x] 2.2.2 Add dual-mode conditional block (check `enable_dual_mode` flag)
  - [x] 2.2.3 Implement distance-based decision logic (ranged if > ideal_range, melee if < melee_range_threshold)
  - [x] 2.2.4 Implement preference-based decision for flexible zone
  - [x] 2.2.5 Add formation role influence check (rear/support = ranged, front/vanguard = melee)

- [x] 2.3 Implement attack execution for chosen mode
  - [x] 2.3.1 Add cooldown gate to prevent mode abuse (check can_ranged_attack and can_attack)
  - [x] 2.3.2 Implement ranged attack execution with LOS check
  - [x] 2.3.3 Implement melee attack execution with state transition
  - [x] 2.3.4 Add fallback logic when chosen mode is on cooldown

- [x] 2.4 Preserve legacy single-mode logic as fallback
  - [x] 2.4.1 Wrap existing ranged-only logic in `else if (is_ranged_attacker)` block
  - [x] 2.4.2 Wrap existing melee-only logic in final `else` block
  - [x] 2.4.3 Verify legacy enemies with enable_dual_mode = false still function correctly

### 3. Retreat Mechanics and Party Formation Integration

- [x] 3.1 Implement retreat mechanics for ranged-preferring enemies
  - [x] 3.1.1 Add retreat trigger condition (retreat_when_close && preferred_attack_mode == "ranged" && distance < ideal_range)
  - [x] 3.1.2 Calculate retreat direction (away from player)
  - [x] 3.1.3 Set retreat target position (ideal_range + 32 pixels beyond player)
  - [x] 3.1.4 Force immediate pathfinding recalculation via alarm[0] = 0
  - [x] 3.1.5 Add minimum retreat cooldown (60 frames) to prevent spam

- [x] 3.2 Write test cases for retreat behavior
  - [x] 3.2.1 Test: Ranged-preferring enemy retreats when player closes to melee range
  - [x] 3.2.2 Test: Enemy stuck against wall uses melee instead of continuous retreat attempts
  - [x] 3.2.3 Test: Retreat cooldown prevents pathfinding spam

- [x] 3.3 Integrate formation role assignment in obj_enemy_party_controller
  - [x] 3.3.1 Locate formation position update logic in Step_0.gml (around line 40-50)
  - [x] 3.3.2 Add formation role assignment based on Y-offset in formation positions
  - [x] 3.3.3 Assign "rear" role for Y-offset < -16, "front" for Y-offset > 16, "support" otherwise
  - [x] 3.3.4 Verify role assignment updates when formation changes

- [x] 3.4 Write test cases for party formation integration
  - [x] 3.4.1 Test: Rear formation members use ranged attacks regardless of distance
  - [x] 3.4.2 Test: Front formation members use melee attacks when in range
  - [x] 3.4.3 Test: Support role members follow distance-based decision logic

### 4. Enemy Configuration and Animation Setup

- [x] 4.1 Configure obj_sandsnake for dual-mode (javelin warrior archetype)
  - [x] 4.1.1 Add enable_dual_mode = true to Create_0.gml
  - [x] 4.1.2 Set preferred_attack_mode = "ranged"
  - [x] 4.1.3 Set melee_range_threshold = 32 (very close before melee)
  - [x] 4.1.4 Set retreat_when_close = true
  - [x] 4.1.5 Configure enemy_anim_overrides for ranged attack animations (frames 35-46)

- [x] 4.2 Configure obj_orc for dual-mode (melee-preferring with throwing axes)
  - [x] 4.2.1 Add enable_dual_mode = true to Create_0.gml
  - [x] 4.2.2 Set preferred_attack_mode = "melee"
  - [x] 4.2.3 Add ranged_damage = 3 for throwing axes
  - [x] 4.2.4 Add ranged_attack_speed = 0.6 (slower than melee)
  - [x] 4.2.5 Set ranged_projectile_object = obj_throwing_axe (create new projectile object if needed)
  - [x] 4.2.6 Set melee_range_threshold = 48
  - [x] 4.2.7 Set retreat_when_close = false (orcs don't retreat)
  - [x] 4.2.8 Configure enemy_anim_overrides for ranged attack animations

- [x] 4.3 Configure obj_greenwood_bandit for dual-mode (archer with melee fallback)
  - [x] 4.3.1 Add enable_dual_mode = true to Create_0.gml
  - [x] 4.3.2 Set preferred_attack_mode = "ranged"
  - [x] 4.3.3 Add attack_damage = 1 for weak dagger swipe
  - [x] 4.3.4 Set melee_range_threshold = 24 (only melee when desperate)
  - [x] 4.3.5 Set retreat_when_close = true
  - [x] 4.3.6 Configure enemy_anim_overrides for ranged attack animations if not already set

- [x] 4.4 Verify animation system compatibility
  - [x] 4.4.1 Review existing scr_animation_helpers.gml for ranged animation fallback support
  - [x] 4.4.2 Test dual-mode enemy with complete animation set (frames 0-46)
  - [x] 4.4.3 Test dual-mode enemy without ranged animations (verify fallback to melee frames)
  - [x] 4.4.4 Verify animation transitions during mode switching look smooth

### 5. Testing, Edge Cases, and Validation

- [x] 5.1 Functional integration testing
  - [x] 5.1.1 Test: Sandsnake switches from javelin to melee when player approaches
  - [x] 5.1.2 Test: Orc prefers melee but throws axes at distant player
  - [x] 5.1.3 Test: Greenwood bandit maintains distance with arrows, uses dagger when cornered
  - [x] 5.1.4 Test: Enemy party with mixed dual-mode and single-mode enemies coordinates properly
  - [x] 5.1.5 Test: Formation roles correctly influence attack mode selection in party battles

- [x] 5.2 Cooldown independence validation
  - [x] 5.2.1 Test: Enemy cannot spam attacks by switching modes rapidly
  - [x] 5.2.2 Test: Ranged attack cooldown doesn't affect melee attack availability
  - [x] 5.2.3 Test: Melee attack cooldown doesn't affect ranged attack availability
  - [x] 5.2.4 Test: Enemy with both attacks on cooldown repositions or idles properly

- [x] 5.3 Edge case testing
  - [x] 5.3.1 Test: Enemy with enable_dual_mode but missing ranged sprite animations
  - [x] 5.3.2 Test: Enemy stuck against wall during retreat attempt (should defend with melee)
  - [x] 5.3.3 Test: LOS blocked for ranged attack but player in melee range (should use melee)
  - [x] 5.3.4 Test: Player rapidly entering and leaving ideal_range (verify mode switching stability)
  - [x] 5.3.5 Test: Dual-mode enemy in party without formation_role assigned

- [x] 5.4 Performance verification
  - [x] 5.4.1 Verify attack_mode_cache reduces per-frame decision overhead
  - [x] 5.4.2 Verify retreat pathfinding doesn't spam due to alarm[0] throttling
  - [x] 5.4.3 Test multiple dual-mode enemies active simultaneously (10+ enemies)
  - [x] 5.4.4 Profile frame time impact of dual-mode decision logic

- [x] 5.5 Final validation and documentation
  - [x] 5.5.1 Verify all test cases from 2.1, 3.2, and 3.4 pass
  - [x] 5.5.2 Test legacy single-mode enemies still function correctly (enable_dual_mode = false)
  - [x] 5.5.3 Document any limitations or known issues discovered during testing
  - [x] 5.5.4 Update enemy configuration examples with working parameters
  - [x] 5.5.5 Create brief usage guide for configuring new dual-mode enemies
