# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-04-dash-attack-combo/spec.md

> Created: 2025-10-04
> Status: IMPLEMENTATION COMPLETE

## Tasks

- [x] 1. Implement dash attack window tracking system
  - [x] 1.1 Add tracking variables to obj_player (dash_attack_window, last_dash_direction, is_dash_attacking)
  - [x] 1.2 Add constants for tuning (DASH_ATTACK_WINDOW_DURATION, DASH_ATTACK_DAMAGE_MULTIPLIER, DASH_ATTACK_DEFENSE_PENALTY)
  - [x] 1.3 Implement window timer logic in obj_player Step event
  - [x] 1.4 Capture dash direction when dash state ends
  - [x] 1.5 Reset window on direction change or expiration
  - [x] 1.6 Test window timing and directional tracking (manual gameplay testing)

- [x] 2. Implement dash attack trigger and detection
  - [x] 2.1 Add dash attack check to attack input handling
  - [x] 2.2 Compare facing direction with last_dash_direction
  - [x] 2.3 Set is_dash_attacking flag when conditions met
  - [x] 2.4 Test that dash attack only triggers in same direction as dash

- [x] 3. Implement damage boost for dash attacks
  - [x] 3.1 Modify get_total_damage() or damage calculation to check is_dash_attacking flag
  - [x] 3.2 Apply 1.5x damage multiplier when is_dash_attacking is true
  - [x] 3.3 Test damage increase on enemies (verify +50% damage output)

- [x] 4. Implement defense penalty during dash attacks
  - [x] 4.1 Locate player damage reception logic (collision with obj_enemy_parent or attacks)
  - [x] 4.2 Apply 0.75x damage reduction multiplier when is_dash_attacking is true
  - [x] 4.3 Test increased vulnerability (intentionally take damage during dash attack)

- [x] 5. Add audio feedback and finalize
  - [x] 5.1 Add sound effect asset for dash attack (snd_dash_attack)
  - [x] 5.2 Play sound when is_dash_attacking flag is set
  - [x] 5.3 Test complete dash attack combo flow (dash → attack → damage boost → sound)
  - [x] 5.4 Verify all mechanics work together correctly
