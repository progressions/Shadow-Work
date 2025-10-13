# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-12-enemy-hazard-spawning/spec.md

## Technical Requirements

### 1. Enemy State Machine Extension

**Add new state to EnemyState enum** (`/scripts/scr_enums/scr_enums.gml`):
```gml
enum EnemyState {
    idle,
    targeting,
    attacking,
    ranged_attacking,
    hazard_spawning,  // NEW STATE
    dead,
    wander
}
```

**Create state script** (`/scripts/scr_enemy_state_hazard_spawning/scr_enemy_state_hazard_spawning.gml`):
- Handle windup phase with timer and animation
- Play windup sound effect at start of windup
- Spawn projectile at end of windup
- Track cooldown timer
- Return to idle/targeting after spawn completes

### 2. Hazard Projectile Object

**Create new object** `obj_hazard_projectile` (inheriting from generic projectile parent if exists):

**Configuration Variables:**
- `travel_distance` - Distance in pixels before landing (default: 128)
- `hazard_object` - Object type to spawn at landing (e.g., `obj_hazard_fire`)
- `move_speed` - Projectile travel speed (default: 3)
- `damage_amount` - Damage dealt on player collision (default: 2)
- `damage_type` - DamageType enum value (default: `DamageType.physical`)
- `direction` - Movement direction in degrees
- `starting_x`, `starting_y` - Track spawn position for distance calculation

**Create Event:**
- Initialize variables
- Set sprite and image_speed
- Calculate target landing position based on direction and travel_distance

**Step Event:**
- Move in direction at move_speed
- Calculate distance traveled from starting position
- If distance >= travel_distance:
  - Spawn configured hazard object at current position
  - Destroy self
- Check collision with player:
  - Apply damage with damage_type
  - Continue traveling (don't destroy on player hit)

**Collision with walls/obstacles:**
- Spawn hazard object at collision point
- Destroy self

### 3. Enemy Configuration Variables

**Add to `obj_enemy_parent` Create event:**

```gml
// Hazard Spawning Configuration
enable_hazard_spawning = false;
hazard_spawn_cooldown = 180;        // Frames between spawns (3 seconds at 60fps)
hazard_spawn_cooldown_timer = 0;    // Current cooldown counter
hazard_spawn_windup_time = 30;      // Frames for windup animation (0.5 seconds)
hazard_spawn_windup_timer = 0;      // Current windup counter

// Projectile Configuration
hazard_projectile_object = obj_hazard_projectile;
hazard_projectile_distance = 128;   // Pixels projectile travels before landing
hazard_projectile_speed = 3;        // Movement speed
hazard_projectile_damage = 2;       // Damage on hit
hazard_projectile_damage_type = DamageType.fire;
hazard_projectile_direction_offset = 0;  // Degrees offset from facing_dir

// Hazard Configuration
hazard_spawn_object = obj_hazard_fire;  // Object created at landing point

// Multi-Attack Boss Support
allow_multi_attack = false;         // Enable melee + ranged + hazard
hazard_priority = 30;               // Weight for hazard attack in decision making
```

### 4. Movement Profile Implementation

**Create movement profile script** (`/scripts/movement_profile_hazard_spawner_update/movement_profile_hazard_spawner_update.gml`):

**Behavior:**
- Move slowly toward player (50-60% of normal move_speed)
- Stop at `ideal_range` distance from player
- Trigger hazard_spawning state when:
  - Within ideal_range
  - Cooldown timer expired
  - Clear line of sight to player
- Maintain distance but don't retreat (unlike ranged enemies)
- Use pathfinding for obstacle avoidance

**Configuration:**
```gml
ideal_range = 96;  // Stop 96 pixels from player
hazard_spawn_move_speed_multiplier = 0.6;  // 60% of base move_speed
```

### 5. Multi-Attack Boss System

**Add attack mode decision logic** to enemy Step event:

```gml
// For enemies with allow_multi_attack = true
if (allow_multi_attack) {
    // Check cooldowns and decide which attack to use
    var can_melee = (attack_cooldown <= 0) && (distance_to_player <= attack_range);
    var can_ranged = (ranged_cooldown <= 0) && (distance_to_player >= melee_range_threshold);
    var can_hazard = (hazard_spawn_cooldown_timer <= 0) && enable_hazard_spawning;

    // Weighted random selection if multiple attacks available
    if (can_hazard && random(100) < hazard_priority) {
        state = EnemyState.hazard_spawning;
    } else if (can_melee && distance_to_player <= attack_range) {
        state = EnemyState.attacking;
    } else if (can_ranged) {
        state = EnemyState.ranged_attacking;
    }
}
```

### 6. Animation System

**Animation fallback logic** (in hazard_spawning state):
- **Priority 1:** Use `ranged_attack_[direction]` animation if enemy has 47-frame sprite
- **Priority 2:** Use `attack_[direction]` animation if enemy only has 35-frame sprite
- **Fallback:** Use `idle_[direction]` animation if neither exists

**Implementation in state script:**
```gml
// Check if enemy has ranged attack animation
if (sprite_get_number(sprite_index) >= 47) {
    // Use ranged attack animation (frames 35-48)
    animation_to_play = "ranged_attack_" + direction_string;
} else if (sprite_get_number(sprite_index) >= 35) {
    // Use melee attack animation (frames 20-31)
    animation_to_play = "attack_" + direction_string;
} else {
    // Fallback to idle animation
    animation_to_play = "idle_" + direction_string;
}
```

### 7. Sound Integration

**Windup sound effect:**
- Play sound at start of hazard_spawn_windup_timer using `play_enemy_sfx("on_hazard_windup")`
- Add `on_hazard_windup` to enemy_sounds struct
- Default fallback: `snd_enemy_attack_generic` or `snd_ranged_attack`

**Configuration in enemy_sounds struct:**
```gml
enemy_sounds = {
    on_melee_attack: undefined,
    on_ranged_attack: undefined,
    on_hazard_windup: undefined,  // NEW
    on_hit: undefined,
    on_death: undefined,
    on_aggro: undefined,
    on_footstep: undefined,
    on_status_effect: undefined
}
```

### 8. Integration Points

**Files to modify:**
- `/scripts/scr_enums/scr_enums.gml` - Add `hazard_spawning` to EnemyState enum
- `/objects/obj_enemy_parent/Create_0.gml` - Add hazard spawning configuration variables
- `/objects/obj_enemy_parent/Step_0.gml` - Add state dispatcher case for `EnemyState.hazard_spawning`
- `/scripts/scr_animation_helpers/scr_animation_helpers.gml` - Add animation data for hazard_spawning state

**Files to create:**
- `/scripts/scr_enemy_state_hazard_spawning/scr_enemy_state_hazard_spawning.gml` - State handler
- `/scripts/movement_profile_hazard_spawner_update/movement_profile_hazard_spawner_update.gml` - Movement AI
- `/objects/obj_hazard_projectile/` - Projectile object with Create, Step, Collision events

**Example enemy implementation** (`obj_fire_cultist`):
```gml
event_inherited();

// Basic stats
hp = 8;
hp_total = hp;
move_speed = 1.2;

// Hazard spawning configuration
enable_hazard_spawning = true;
hazard_spawn_cooldown = 240;  // 4 seconds
hazard_spawn_windup_time = 45;  // 0.75 seconds windup
hazard_projectile_distance = 160;
hazard_projectile_damage = 3;
hazard_projectile_damage_type = DamageType.fire;
hazard_spawn_object = obj_hazard_fire;

// Movement profile
movement_profile = movement_profile_hazard_spawner_update;
ideal_range = 112;

// Sound
enemy_sounds.on_hazard_windup = snd_fire_cultist_cast;
```

**Example boss with multi-attack** (`obj_boss_fire_lord`):
```gml
event_inherited();

// Basic stats
hp = 100;
hp_total = hp;
move_speed = 1.5;
attack_damage = 5;
attack_range = 32;

// Enable all attack types
enable_dual_mode = true;
enable_hazard_spawning = true;
allow_multi_attack = true;

// Hazard spawning (longest cooldown)
hazard_spawn_cooldown = 480;  // 8 seconds
hazard_priority = 40;
hazard_projectile_distance = 200;
hazard_projectile_damage = 4;
hazard_projectile_damage_type = DamageType.fire;
hazard_spawn_object = obj_hazard_fire;

// Ranged attack (medium cooldown)
ranged_cooldown_max = 120;  // 2 seconds
ranged_damage = 3;

// Melee attack (short cooldown)
attack_cooldown_max = 60;  // 1 second
attack_damage = 5;
```

## Performance Considerations

- Limit maximum number of active hazard projectiles per enemy (max 3 concurrent)
- Hazard objects already have lifetime management, no additional cleanup needed
- Projectile distance calculation uses simple Pythagorean theorem, low overhead
- Cooldown timers use frame-based counters, no expensive time checks

## Testing Scenarios

1. **Single hazard-spawning enemy** - Verify windup, projectile travel, hazard spawn at correct distance
2. **Boss multi-attack** - Verify independent cooldowns for melee, ranged, and hazard attacks
3. **Projectile collision** - Verify damage on player hit and hazard spawn at wall collision
4. **Animation fallback** - Test enemies with 35-frame, 47-frame, and minimal sprites
5. **Movement profile** - Verify slow approach, stopping at ideal_range, and no retreat behavior
