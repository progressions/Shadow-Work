# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-03-enemy-spawner-system/spec.md

## Technical Requirements

### Object Architecture

- **`obj_spawner_parent`** - Base spawner object with configurable instance variables:
  - `spawn_table` - Array of structs: `[{ enemy_object: obj_orc, weight: 70 }, { enemy_object: obj_burglar, weight: 30 }]`
  - `spawn_period` - Number (in frames or seconds) between spawn attempts
  - `spawn_mode` - Enum: `SpawnerMode.finite` or `SpawnerMode.continuous`
  - `spawn_limit` - Integer: total enemies to spawn (for finite mode); -1 for unlimited
  - `enemy_cap` - Integer: maximum concurrent alive enemies from this spawner
  - `proximity_enabled` - Boolean: whether to check player distance
  - `proximity_radius` - Number: activation radius in pixels
  - `is_visible` - Boolean: whether spawner sprite is drawn
  - `is_damageable` - Boolean: whether spawner can take damage
  - `hp_total` - Number: spawner health (if damageable)
  - `hp_current` - Number: current spawner health
  - `spawn_sound` - Sound asset: optional audio effect on spawn (can be `noone`)
  - `spawned_count` - Integer: total enemies spawned (runtime state)
  - `active_enemies` - Array: references to currently alive spawned enemies (runtime state)
  - `is_active` - Boolean: whether spawner is currently active (runtime state)
  - `spawn_timer` - Number: countdown timer for next spawn (runtime state)
  - `is_destroyed` - Boolean: whether spawner has been destroyed (runtime state)

### Weighted Spawn System

- Reuse existing weighted selection pattern from loot tables
- Implement `select_weighted_enemy()` function:
  - Calculate total weight from `spawn_table`
  - Generate random number within total weight range
  - Iterate through spawn table to select enemy based on weighted ranges
  - Return selected enemy object type

### Spawner Lifecycle Events

- **Create Event**:
  - Initialize all instance variables with defaults or inherited values
  - Set `spawn_timer = spawn_period`
  - Set `is_active = true` if not proximity-enabled, else `false`
  - Initialize `active_enemies = []` and `spawned_count = 0`

- **Step Event**:
  - Check if `is_destroyed` → exit early if true
  - If `proximity_enabled`, check distance to `obj_player`:
    - If within `proximity_radius` and `is_active == false` → activate spawner
    - If outside `proximity_radius` and `is_active == true` → deactivate spawner (set `is_active = false`)
  - If `is_active`:
    - Clean `active_enemies` array (remove dead/destroyed enemy references)
    - Decrement `spawn_timer`
    - If `spawn_timer <= 0`:
      - Check spawn conditions:
        - Finite mode: `spawned_count < spawn_limit`
        - Continuous mode: always true
        - Enemy cap: `array_length(active_enemies) < enemy_cap`
      - If all conditions met:
        - Call `select_weighted_enemy()` to get enemy type
        - Spawn enemy at spawner position (or with offset)
        - Add enemy reference to `active_enemies`
        - Increment `spawned_count`
        - Play `spawn_sound` if set
        - Reset `spawn_timer = spawn_period`
      - If finite mode and `spawned_count >= spawn_limit` → set `is_active = false`

- **Draw Event** (if `is_visible`):
  - Draw spawner sprite at current position
  - Optional: draw debug info (spawn count, active enemies) in development mode

- **Collision/Damage Event** (if `is_damageable`):
  - Reduce `hp_current` by damage amount
  - If `hp_current <= 0`:
    - Set `is_destroyed = true`
    - Set `is_active = false`
    - Play destruction effect/sound (optional)
    - Do NOT destroy `active_enemies` (they remain in world)
    - Optionally: set `visible = false` or destroy instance

### Enemy Reference Management

- Track spawned enemies in `active_enemies` array
- Each Step event, iterate through `active_enemies` and remove invalid references:
  ```gml
  var _cleaned = [];
  for (var i = 0; i < array_length(active_enemies); i++) {
      if (instance_exists(active_enemies[i])) {
          array_push(_cleaned, active_enemies[i]);
      }
  }
  active_enemies = _cleaned;
  ```

### Save/Load Integration

- Extend existing save system to serialize spawner state
- Save data structure per spawner instance:
  ```gml
  {
      spawner_id: unique_id,           // Room-persistent ID
      object_index: obj_spawner_child,  // Object type for recreation
      x: x_position,
      y: y_position,
      spawned_count: spawned_count,
      is_destroyed: is_destroyed,
      is_active: is_active,
      hp_current: hp_current,
      // Store all configurable properties for restoration
      spawn_table: spawn_table,
      spawn_period: spawn_period,
      // ... other config vars
  }
  ```

- On load:
  - Recreate spawner instances at saved positions with saved object types
  - Restore all state variables (`spawned_count`, `is_destroyed`, `is_active`, `hp_current`)
  - Restore configuration variables
  - Do NOT restore `active_enemies` array (enemies are saved/loaded independently through existing enemy save system)
  - Destroyed spawners (`is_destroyed == true`) should be recreated but remain inactive

### Spawner Child Objects

- Create example child objects that inherit from `obj_spawner_parent`:
  - `obj_spawner_mook_finite` - Spawns 5 mooks then stops
  - `obj_spawner_mixed_continuous` - Continuously spawns weighted mix of enemies
  - `obj_spawner_featured_proximity` - Proximity-activated featured enemy spawner

- Child objects override parent variables in Create event:
  ```gml
  event_inherited(); // Call parent Create

  // Override specific properties
  spawn_table = [
      { enemy_object: obj_orc, weight: 60 },
      { enemy_object: obj_burglar, weight: 40 }
  ];
  spawn_period = 180; // 3 seconds at 60 FPS
  spawn_mode = SpawnerMode.finite;
  spawn_limit = 5;
  enemy_cap = 2;
  proximity_enabled = true;
  proximity_radius = 200;
  is_visible = false;
  is_damageable = false;
  ```

### Enums

- Add `SpawnerMode` enum to `scripts/scr_enums/scr_enums.gml`:
  ```gml
  enum SpawnerMode {
      finite,      // Spawn up to spawn_limit then stop
      continuous   // Spawn indefinitely until destroyed/deactivated
  }
  ```

### Helper Functions

- Create `scripts/scr_spawner_helpers/scr_spawner_helpers.gml`:
  - `select_weighted_enemy(spawn_table)` - Returns enemy object based on weights
  - `spawner_can_spawn(spawner)` - Checks all spawn conditions (mode, limit, cap)
  - `spawner_cleanup_enemies(spawner)` - Removes dead references from active_enemies array

### Audio

- Use existing sound system
- Spawner instance variable `spawn_sound` can reference sound assets like `snd_spawn_enemy`
- Play via `audio_play_sound(spawn_sound, 1, false)` when enemy spawns

### Performance Considerations

- Limit number of active spawners in a room (recommend max 10-15)
- Use proximity activation to reduce unnecessary spawn checks
- Clean `active_enemies` array every step to prevent memory leaks
- Consider adding a global spawner manager if performance issues arise (out of scope for MVP)

### Testing Requirements

- Test finite spawner stops after exact spawn_limit enemies
- Test continuous spawner respects enemy_cap
- Test proximity activation/deactivation at radius boundaries
- Test damageable spawner destruction stops spawning
- Test spawned enemies behave identically to manually-placed enemies
- Test save/load preserves spawner state correctly
- Test weighted spawn tables produce expected distribution over multiple spawns
- Test spawner state after player leaves/returns to room
