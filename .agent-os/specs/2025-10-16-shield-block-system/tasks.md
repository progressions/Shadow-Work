# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-16-shield-block-system/spec.md

> Created: 2025-10-16
> Status: Ready for Implementation

## Tasks

- [ ] 1. Set up player state machine and animation foundation
  - [ ] 1.1 Add `PlayerState.shielding` enum value to existing PlayerState enum
  - [ ] 1.2 Create shield raise animation frames in player sprite for all 4 directions (down, right, left, up)
  - [ ] 1.3 Add shielding state handler to player Step event state machine dispatcher
  - [ ] 1.4 Implement shield state entry: lock facing_dir and show raise animation
  - [ ] 1.5 Implement shield state exit: play lower animation and start cooldown timer
  - [ ] 1.6 Add block cooldown tracking variables to player Create event
  - [ ] 1.7 Verify player can enter/exit shielding state with button press

- [ ] 2. Implement shield block detection and damage reduction
  - [ ] 2.1 Add collision detection between obj_player (shielding) and obj_enemy_arrow
  - [ ] 2.2 Add collision detection between obj_player (shielding) and obj_hazard_projectile
  - [ ] 2.3 Calculate chip damage for normal block (use existing DR system for ranged)
  - [ ] 2.4 Apply knockback to player during block (projectile physics continues)
  - [ ] 2.5 Prevent hazard spawn on normal block (modify projectile behavior when hitting shield)
  - [ ] 2.6 Add perfect block window tracking (frame counter during shield hold)
  - [ ] 2.7 Verify chip damage displays and projectiles are handled correctly

- [ ] 3. Implement perfect block mechanics and feedback
  - [ ] 3.1 Define perfect block window duration (0.3s, configurable)
  - [ ] 3.2 Detect collision during perfect block window
  - [ ] 3.3 Destroy projectile on perfect block (no hazard spawn, no damage)
  - [ ] 3.4 Add shield sprite flash effect when perfect block window opens
  - [ ] 3.5 Trigger `freeze_frame()` on successful perfect block for impact feedback
  - [ ] 3.6 Apply shorter cooldown duration for perfect blocks (0.5s normal vs 0.3s perfect)
  - [ ] 3.7 Test perfect block timing window and visual feedback

- [ ] 4. Configure shield properties per item and add equipment integration
  - [ ] 4.1 Add `shield_block_arc`, `shield_block_cooldown_normal`, `shield_block_cooldown_perfect` to item database schema
  - [ ] 4.2 Set default shield properties (90° arc, 1.0s normal, 0.5s perfect cooldown)
  - [ ] 4.3 Configure existing shields with appropriate properties based on size/tier
  - [ ] 4.4 Check shield equipped before allowing block state entry
  - [ ] 4.5 Apply shield-specific cooldown durations based on equipped shield
  - [ ] 4.6 Apply shield-specific block arc width to collision detection
  - [ ] 4.7 Verify shield properties are read correctly from equipped item

- [ ] 5. Implement stagger and large projectile mechanics
  - [ ] 5.1 Add `causes_stagger_on_block` flag to projectile objects
  - [ ] 5.2 Apply stagger status to player when large projectile hits during normal block
  - [ ] 5.3 Ensure perfect block destroys projectile before stagger can apply
  - [ ] 5.4 Test stagger mechanics with hazard projectiles and arrows
  - [ ] 5.5 Verify knockback still applies during block even with stagger

- [ ] 6. Polish and integration testing
  - [ ] 6.1 Add UI indicator for block cooldown status (optional)
  - [ ] 6.2 Test block state with movement (locked to facing direction like ranged focus)
  - [ ] 6.3 Test block state with ranged focus interaction (priority/precedence)
  - [ ] 6.4 Verify target indicator is destroyed on perfect block
  - [ ] 6.5 Test shield block against all projectile types (arrows, hazard projectiles)
  - [ ] 6.6 Balance cooldown durations and perfect block window timing based on playtesting
  - [ ] 6.7 Verify no unintended interactions with existing combat systems
