# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-11-ranged-attack-windup/spec.md

> Created: 2025-10-11
> Status: Ready for Implementation

## Tasks

### 1. Add Ranged Windup Configuration to obj_enemy_parent

**Testing Approach:** Manual verification in GameMaker IDE - inspect obj_enemy_parent Create event to verify new properties exist and have correct default values.

- [ ] 1.1 Define manual testing plan for windup property initialization
- [ ] 1.2 Add `ranged_windup_speed` property to obj_enemy_parent/Create_0.gml (default: 0.5)
- [ ] 1.3 Add `ranged_windup_complete` property to obj_enemy_parent/Create_0.gml (default: false)
- [ ] 1.4 Add `on_ranged_windup` field to enemy_sounds struct in Create_0.gml
- [ ] 1.5 Set default fallback for enemy_sounds.on_ranged_windup to snd_bow_draw
- [ ] 1.6 Verify in GameMaker IDE that properties initialize correctly when spawning test enemy

### 2. Create Sound Assets and Windup Audio System

**Testing Approach:** Manual verification in-game - spawn ranged enemy, trigger attack, verify windup sound plays before projectile spawns.

- [ ] 2.1 Define manual testing plan for windup sound timing
- [ ] 2.2 Create or import snd_bow_draw sound asset (0.3-0.5 second duration)
- [ ] 2.3 Optional: Create sound variants (snd_bow_draw_1, snd_bow_draw_2) for variety
- [ ] 2.4 Update global.sound_variant_lookup in obj_sfx_controller if variants created
- [ ] 2.5 Test in-game: Verify snd_bow_draw plays when ranged attack begins
- [ ] 2.6 Test in-game: Verify sound plays before projectile spawns
- [ ] 2.7 Test in-game: Verify sound variant randomization works if multiple variants exist

### 3. Implement spawn_ranged_projectile() Function

**Testing Approach:** Manual verification in-game - test projectile spawning after windup completes with correct direction, speed, and damage values.

- [ ] 3.1 Define manual testing plan for projectile spawn behavior
- [ ] 3.2 Create spawn_ranged_projectile() function in /scripts/scr_enemy_ai/scr_enemy_ai.gml
- [ ] 3.3 Extract projectile creation logic (obj_enemy_arrow instantiation)
- [ ] 3.4 Set projectile properties: speed, direction, image_angle, damage, damage_type, owner
- [ ] 3.5 Ensure function uses enemy instance variables (ranged_damage, ranged_projectile_speed, etc.)
- [ ] 3.6 Test in-game: Verify projectile spawns at enemy position
- [ ] 3.7 Test in-game: Verify projectile travels toward player with correct speed and direction
- [ ] 3.8 Test in-game: Verify projectile applies correct damage and damage type on hit

### 4. Modify Ranged Attack State Entry Logic

**Testing Approach:** Manual verification in-game - ensure entering ranged_attacking state no longer spawns projectile immediately.

- [ ] 4.1 Define manual testing plan for windup phase state entry
- [ ] 4.2 Open /scripts/scr_enemy_state_targeting/scr_enemy_state_targeting.gml
- [ ] 4.3 Locate enemy_handle_ranged_attack() function (lines 81-91)
- [ ] 4.4 Remove projectile spawn code from state entry
- [ ] 4.5 Add ranged_windup_complete = false reset when entering state
- [ ] 4.6 Add anim_timer = 0 reset to restart animation cycle
- [ ] 4.7 Replace play_enemy_sfx("on_ranged_attack") with play_enemy_sfx("on_ranged_windup")
- [ ] 4.8 Keep ranged_attack_cooldown assignment unchanged
- [ ] 4.9 Test in-game: Verify no projectile spawns when enemy enters ranged_attacking state
- [ ] 4.10 Test in-game: Verify windup sound plays on state entry

### 5. Implement Windup Animation Speed System

**Testing Approach:** Manual verification in-game - observe ranged attack animation plays slower during windup phase, then speeds up after projectile spawns.

- [ ] 5.1 Define manual testing plan for animation speed transitions
- [ ] 5.2 Open /objects/obj_enemy_parent/Step_0.gml
- [ ] 5.3 Locate EnemyState.ranged_attacking case in animation switch (lines 277-298)
- [ ] 5.4 Replace speed_mult with conditional: ranged_windup_complete ? speed_mult : (speed_mult * ranged_windup_speed)
- [ ] 5.5 Add windup completion check: if (!ranged_windup_complete && floor(anim_timer) >= frames_in_seq)
- [ ] 5.6 Set ranged_windup_complete = true when first cycle completes
- [ ] 5.7 Call spawn_ranged_projectile() when windup completes
- [ ] 5.8 Call play_enemy_sfx("on_ranged_attack") when projectile spawns
- [ ] 5.9 Test in-game: Verify animation plays at reduced speed during windup (visible slow motion)
- [ ] 5.10 Test in-game: Verify projectile spawns after first animation cycle completes
- [ ] 5.11 Test in-game: Verify attack sound plays when projectile spawns (not at windup start)
- [ ] 5.12 Test in-game: Verify animation continues at normal speed after windup completes

### 6. Implement State Reset and Edge Case Handling

**Testing Approach:** Manual verification in-game - test state transitions, interrupts, and edge cases like losing line of sight during windup.

- [ ] 6.1 Define manual testing plan for state transitions and edge cases
- [ ] 6.2 Locate ranged_attack_cooldown <= 0 check in obj_enemy_parent/Step_0.gml
- [ ] 6.3 Add ranged_windup_complete = false reset when returning to targeting state
- [ ] 6.4 Test edge case: Enemy takes damage during windup (verify animation continues)
- [ ] 6.5 Test edge case: Enemy loses line of sight during windup (verify state transitions correctly)
- [ ] 6.6 Test edge case: Dual-mode enemy switches to melee during windup (verify clean state transition)
- [ ] 6.7 Test edge case: Very fast windup speed (0.9-1.0) to verify projectile still spawns
- [ ] 6.8 Test edge case: Very slow windup speed (0.1-0.2) to verify animation doesn't appear frozen
- [ ] 6.9 Test in-game: Verify ranged_windup_complete resets properly between attacks
- [ ] 6.10 Test in-game: Verify no orphaned projectiles or sounds from interrupted windups

### 7. Configure Per-Enemy Windup Variations

**Testing Approach:** Manual verification in-game - test multiple enemy types with different windup speeds and sounds to ensure variety.

- [ ] 7.1 Define manual testing plan for per-enemy configuration variations
- [ ] 7.2 Identify 2-3 existing ranged enemies for configuration examples
- [ ] 7.3 Configure fast archer example (ranged_windup_speed = 0.7, quick sound)
- [ ] 7.4 Configure slow crossbowman example (ranged_windup_speed = 0.3, heavy sound)
- [ ] 7.5 Optional: Create enemy-specific windup sounds (snd_bow_draw_fast, snd_crossbow_crank)
- [ ] 7.6 Test in-game: Verify fast archer has noticeably shorter windup than default
- [ ] 7.7 Test in-game: Verify slow crossbowman has noticeably longer windup than default
- [ ] 7.8 Test in-game: Verify custom windup sounds play for configured enemies

### 8. Integration Testing with Existing Systems

**Testing Approach:** Comprehensive manual verification in-game - test windup system with dual-mode enemies, enemy parties, and various combat scenarios.

- [ ] 8.1 Define comprehensive manual testing plan for system integration
- [ ] 8.2 Test dual-mode enemy: Verify windup works when switching from melee to ranged
- [ ] 8.3 Test dual-mode enemy: Verify clean transition when switching from ranged back to melee
- [ ] 8.4 Test enemy party: Verify rear/support ranged enemies use windup correctly
- [ ] 8.5 Test enemy party: Verify synchronized attacks look correct with windup delays
- [ ] 8.6 Test animation overrides: Verify custom enemy_anim_overrides work with windup system
- [ ] 8.7 Test sound variants: Verify multiple snd_bow_draw variants play randomly
- [ ] 8.8 Test player feedback: Verify windup provides clear telegraph for player to dodge/react
- [ ] 8.9 Verify performance: No frame drops or stuttering with multiple ranged enemies winding up
- [ ] 8.10 Final playtest: Run through combat scenarios to verify system feels responsive and balanced
