# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-05-combat-visual-feedback/spec.md

> Created: 2025-10-05
> Status: Ready for Implementation

## Tasks

- [ ] 1. Implement Freeze Frame System
  - [ ] 1.1 Add freeze frame variables to obj_game_controller (freeze_timer, freeze_active)
  - [ ] 1.2 Create freeze_frame(duration) function in obj_game_controller
  - [ ] 1.3 Integrate freeze calls in obj_attack collision with enemies
  - [ ] 1.4 Add longer freeze on enemy death (in enemy_state_dead)
  - [ ] 1.5 Test freeze frames with different weapons and verify 60 FPS maintained

- [ ] 2. Implement Enemy Flash Effects
  - [ ] 2.1 Add flash variables to obj_enemy_parent (flash_timer, flash_color)
  - [ ] 2.2 Create enemy_flash(color, duration) function
  - [ ] 2.3 Add white flash on hit in obj_enemy_parent collision
  - [ ] 2.4 Integrate flash with image_blend in obj_enemy_parent Step event
  - [ ] 2.5 Test flash effects with various enemy types

- [ ] 3. Implement Basic Crit System
  - [ ] 3.1 Add crit_chance variable to obj_player Create event (default 0.1 for 10%)
  - [ ] 3.2 Add crit_multiplier to obj_player (default 1.75)
  - [ ] 3.3 Add crit calculation to get_total_damage() function
  - [ ] 3.4 Add is_crit flag to obj_attack for passing crit status
  - [ ] 3.5 Integrate red flash on crit hits (use enemy_flash with c_red)
  - [ ] 3.6 Add longer freeze frame on crits (4 frames vs 2 frames)
  - [ ] 3.7 Test crit system and verify proper flash/freeze integration

- [ ] 4. Implement Screen Shake System
  - [ ] 4.1 Add shake variables to obj_game_controller (shake_intensity, shake_timer, shake_decay)
  - [ ] 4.2 Create screen_shake(intensity) function in obj_game_controller
  - [ ] 4.3 Add camera offset logic in obj_game_controller Step event
  - [ ] 4.4 Define weapon-based shake intensities (dagger=2, sword=4, two_handed=8)
  - [ ] 4.5 Integrate shake calls in obj_attack based on weapon type
  - [ ] 4.6 Test shake with all weapon types and verify smooth camera recovery

- [ ] 5. Implement Sprite-Based Hit Effects
  - [ ] 5.1 Create spr_hit_spark sprite (simple 8x8 white/yellow spark, 2-3 frames)
  - [ ] 5.2 Create obj_hit_effect object with alpha fade logic
  - [ ] 5.3 Add directional spawn logic (spray away from attack direction)
  - [ ] 5.4 Integrate hit effect spawning in obj_attack collision
  - [ ] 5.5 Test hit effects at various angles and verify cleanup

- [ ] 6. Implement Slow-Motion on Trigger Activation
  - [ ] 6.1 Add slowmo variables to obj_game_controller (slowmo_active, slowmo_timer, slowmo_recovery)
  - [ ] 6.2 Create activate_slowmo(duration) function using game_set_speed()
  - [ ] 6.3 Add slowmo recovery logic with lerp in obj_game_controller Step event
  - [ ] 6.4 Integrate slowmo calls when companion triggers activate
  - [ ] 6.5 Test slowmo with multiple companion triggers and verify smooth transitions
  - [ ] 6.6 Verify all systems work together (freeze + shake + flash + slowmo + effects)

Follow the recommended implementation order: 1 → 2 → 3 → 4 → 5 → 6, as each builds on the previous systems.

Testing notes: Since this is GameMaker, manual testing is done by running the game (F5) and observing effects in combat. Create a test scenario in an existing room with enemies to verify all features.
