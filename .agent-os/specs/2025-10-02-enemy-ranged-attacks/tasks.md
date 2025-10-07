# Spec Tasks

> Status: IMPLEMENTATION COMPLETE

## Tasks

- [x] 1. Add Enemy Ranged Attack State and Properties
  - [x] 1.1 Add `ranged_attacking` value to `EnemyState` enum in `/scripts/scr_enums/scr_enums.gml`
  - [x] 1.2 Add ranged attack properties to `obj_enemy_parent/Create_0.gml`: `is_ranged_attacker`, `ranged_damage`, `ranged_attack_cooldown`, `ranged_attack_speed`, `can_ranged_attack`
  - [x] 1.3 Verify `facing_dir` property exists in `obj_enemy_parent` or add it if missing
  - [x] 1.4 Test that new properties initialize correctly without breaking existing enemies

- [x] 2. Implement Enemy Ranged Attack Function
  - [x] 2.1 Create `enemy_handle_ranged_attack()` function in `/scripts/player_attacking/player_attacking.gml` or new `/scripts/enemy_attacking/enemy_attacking.gml`
  - [x] 2.2 Implement cooldown management for ranged attacks (decrement counter, set `can_ranged_attack` flag)
  - [x] 2.3 Implement arrow spawn position calculation based on `facing_dir`
  - [x] 2.4 Spawn `obj_enemy_arrow` with correct `creator`, `damage`, `direction`, and `image_angle`
  - [x] 2.5 Set `EnemyState.ranged_attacking` state and calculate cooldown from `ranged_attack_speed`
  - [x] 2.6 Add sound effect with `play_enemy_sfx("on_attack")`
  - [x] 2.7 Test function with debug enemy to verify arrow spawning and direction

- [x] 3. Configure Enemy Arrow Object
  - [x] 3.1 Verify `obj_enemy_arrow/Create_0.gml` has correct properties: `creator`, `damage`, `speed`, `direction`, `image_angle`, `sprite_index`, `depth`
  - [x] 3.2 Implement or verify `obj_enemy_arrow/Step_0.gml` collision detection with `Tiles_Col` layer (destroy on wall hit)
  - [x] 3.3 Implement collision with `obj_player` (apply damage, knockback, visual feedback, spawn damage number)
  - [x] 3.4 Implement bounds check (destroy if outside room)
  - [x] 3.5 Test arrow collision with walls, player, and room boundaries

- [x] 4. Configure Greenwood Bandit as Ranged Attacker
  - [x] 4.1 Add ranged attack configuration to `obj_greenwood_bandit/Create_0.gml`: set `is_ranged_attacker = true`, `ranged_damage = 3`, `ranged_attack_speed = 0.7`
  - [x] 4.2 Add placeholder integration to call `enemy_handle_ranged_attack()` from enemy Step event or AI logic
  - [x] 4.3 Implement state return logic: `EnemyState.ranged_attacking` → `EnemyState.idle` after attack
  - [x] 4.4 Configure attack sound: set `enemy_sounds.on_attack` to bow sound if desired
  - [x] 4.5 Test Greenwood Bandit firing arrows at player in-game

- [x] 5. Integration Testing and Verification
  - [x] 5.1 Verify Greenwood Bandit spawns and fires arrows at player
  - [x] 5.2 Verify arrows deal correct damage (3 for Greenwood Bandit)
  - [x] 5.3 Verify separate cooldowns work (melee vs ranged have different timings)
  - [x] 5.4 Verify arrows destroy on wall collision
  - [x] 5.5 Verify arrows destroy on player collision and apply damage/knockback
  - [x] 5.6 Verify enemy enters `EnemyState.ranged_attacking` when firing and returns to idle
  - [x] 5.7 Verify sound effects play on arrow fire
  - [x] 5.8 Test system reusability: configure another enemy as ranged attacker and verify it works
