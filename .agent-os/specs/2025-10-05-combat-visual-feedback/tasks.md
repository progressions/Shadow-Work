# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-05-combat-visual-feedback/spec.md

> Created: 2025-10-05
> Status: IMPLEMENTATION COMPLETE

## Tasks

- [x] 1. Implement Freeze Frame System
  - [x] 1.1 Add freeze frame variables to obj_game_controller (freeze_timer, freeze_active)
  - [x] 1.2 Create freeze_frame(duration) function in obj_game_controller
  - [x] 1.3 Integrate freeze calls in obj_attack collision with enemies
  - [x] 1.4 Add longer freeze on enemy death (in enemy_state_dead)
  - [x] 1.5 Test freeze frames with different weapons and verify 60 FPS maintained

- [x] 2. Implement Enemy Flash Effects
  - [x] 2.1 Add flash variables to obj_enemy_parent (flash_timer, flash_color)
  - [x] 2.2 Create enemy_flash(color, duration) function
  - [x] 2.3 Add white flash on hit in obj_enemy_parent collision
  - [x] 2.4 Integrate flash with image_blend in obj_enemy_parent Step event
  - [x] 2.5 Test flash effects with various enemy types

- [x] 3. Implement Basic Crit System
  - [x] 3.1 Add crit_chance variable to obj_player Create event (default 0.1 for 10%)
  - [x] 3.2 Add crit_multiplier to obj_player (default 1.75)
  - [x] 3.3 Add crit calculation to get_total_damage() function
  - [x] 3.4 Add is_crit flag to obj_attack for passing crit status
  - [x] 3.5 Integrate red flash on crit hits (use enemy_flash with c_red)
  - [x] 3.6 Add longer freeze frame on crits (4 frames vs 2 frames)
  - [x] 3.7 Test crit system and verify proper flash/freeze integration

- [x] 4. Implement Screen Shake System
  - [x] 4.1 Add shake variables to obj_game_controller (shake_intensity, shake_timer, shake_decay)
  - [x] 4.2 Create screen_shake(intensity) function in obj_game_controller
  - [x] 4.3 Add camera offset logic in obj_game_controller Step event
  - [x] 4.4 Define weapon-based shake intensities (dagger=2, sword=4, two_handed=8)
  - [x] 4.5 Integrate shake calls in obj_attack based on weapon type
  - [x] 4.6 Test shake with all weapon types and verify smooth camera recovery

- [x] 5. Implement Sprite-Based Hit Effects
  - [x] 5.1 Create spr_hit_spark sprite (simple 8x8 white/yellow spark, 2-3 frames)
  - [x] 5.2 Create obj_hit_effect object with alpha fade logic
  - [x] 5.3 Add directional spawn logic (spray away from attack direction)
  - [x] 5.4 Integrate hit effect spawning in obj_attack collision
  - [x] 5.5 Test hit effects at various angles and verify cleanup

- [x] 6. Implement Slow-Motion on Trigger Activation
  - [x] 6.1 Add slowmo variables to obj_game_controller (slowmo_active, slowmo_timer, slowmo_recovery)
  - [x] 6.2 Create activate_slowmo(duration) function using game_set_speed()
  - [x] 6.3 Add slowmo recovery logic with lerp in obj_game_controller Step event
  - [x] 6.4 Integrate slowmo calls when companion triggers activate
  - [x] 6.5 Test slowmo with multiple companion triggers and verify smooth transitions
  - [x] 6.6 Verify all systems work together (freeze + shake + flash + slowmo + effects)

Follow the recommended implementation order: 1 → 2 → 3 → 4 → 5 → 6, as each builds on the previous systems.

Testing notes: Since this is GameMaker, manual testing is done by running the game (F5) and observing effects in combat. Create a test scenario in an existing room with enemies to verify all features.
