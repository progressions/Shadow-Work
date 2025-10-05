# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-04-dash-attack-combo/spec.md

> Created: 2025-10-04
> Status: Ready for Implementation

## Tasks

- [ ] 1. Implement dash attack window tracking system
  - [ ] 1.1 Add tracking variables to obj_player (dash_attack_window, last_dash_direction, is_dash_attacking)
  - [ ] 1.2 Add constants for tuning (DASH_ATTACK_WINDOW_DURATION, DASH_ATTACK_DAMAGE_MULTIPLIER, DASH_ATTACK_DEFENSE_PENALTY)
  - [ ] 1.3 Implement window timer logic in obj_player Step event
  - [ ] 1.4 Capture dash direction when dash state ends
  - [ ] 1.5 Reset window on direction change or expiration
  - [ ] 1.6 Test window timing and directional tracking (manual gameplay testing)

- [ ] 2. Implement dash attack trigger and detection
  - [ ] 2.1 Add dash attack check to attack input handling
  - [ ] 2.2 Compare facing direction with last_dash_direction
  - [ ] 2.3 Set is_dash_attacking flag when conditions met
  - [ ] 2.4 Test that dash attack only triggers in same direction as dash

- [ ] 3. Implement damage boost for dash attacks
  - [ ] 3.1 Modify get_total_damage() or damage calculation to check is_dash_attacking flag
  - [ ] 3.2 Apply 1.5x damage multiplier when is_dash_attacking is true
  - [ ] 3.3 Test damage increase on enemies (verify +50% damage output)

- [ ] 4. Implement defense penalty during dash attacks
  - [ ] 4.1 Locate player damage reception logic (collision with obj_enemy_parent or attacks)
  - [ ] 4.2 Apply 0.75x damage reduction multiplier when is_dash_attacking is true
  - [ ] 4.3 Test increased vulnerability (intentionally take damage during dash attack)

- [ ] 5. Add audio feedback and finalize
  - [ ] 5.1 Add sound effect asset for dash attack (snd_dash_attack)
  - [ ] 5.2 Play sound when is_dash_attacking flag is set
  - [ ] 5.3 Test complete dash attack combo flow (dash → attack → damage boost → sound)
  - [ ] 5.4 Verify all mechanics work together correctly
