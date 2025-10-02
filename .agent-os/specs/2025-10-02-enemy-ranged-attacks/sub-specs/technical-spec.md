# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-02-enemy-ranged-attacks/spec.md

## Technical Requirements

### 1. Enum Extension

**File:** `/scripts/scr_enums/scr_enums.gml`

Add new state to `EnemyState` enum:

```gml
enum EnemyState {
    idle,
    attacking,
    ranged_attacking,  // NEW
    dead,
}
```

**Rationale:** Separate state for ranged attacks allows distinct behavior and future AI logic to differentiate between ranged and melee states.

---

### 2. Enemy Parent Properties

**File:** `/objects/obj_enemy_parent/Create_0.gml`

Add the following properties after the existing attack system stats (around line 36):

```gml
// Ranged attack system
is_ranged_attacker = false;  // Set to true for enemies that use ranged attacks
ranged_damage = 2;           // Default arrow damage (override in child enemies)
ranged_attack_cooldown = 0;  // Separate cooldown for ranged attacks
ranged_attack_speed = 0.8;   // Attacks per second for ranged (default slower than melee)
can_ranged_attack = true;    // Cooldown flag for ranged attacks
```

**Property Descriptions:**

- `is_ranged_attacker`: Boolean flag to enable ranged attack behavior
- `ranged_damage`: Damage value passed to spawned arrows (overridable per enemy)
- `ranged_attack_cooldown`: Frame counter for ranged attack cooldown (separate from melee `attack_cooldown`)
- `ranged_attack_speed`: Attacks per second (used to calculate cooldown, similar to player system)
- `can_ranged_attack`: Boolean flag indicating if ranged attack is off cooldown

**Ruby-style naming convention:** All properties use `snake_case` per CLAUDE.md guidelines.

---

### 3. Ranged Attack Function

**File:** `/scripts/player_attacking/player_attacking.gml` or new file `/scripts/enemy_attacking/enemy_attacking.gml`

Create new function `enemy_handle_ranged_attack()` to handle enemy projectile spawning:

```gml
function enemy_handle_ranged_attack() {
    // Only execute if this enemy is a ranged attacker
    if (!is_ranged_attacker) return false;

    // Check cooldown
    if (ranged_attack_cooldown > 0) {
        ranged_attack_cooldown--;
        can_ranged_attack = false;
    } else {
        can_ranged_attack = true;
    }

    // Spawn arrow if cooldown ready
    if (can_ranged_attack) {
        // Calculate spawn position based on facing_dir
        var _arrow_x = x;
        var _arrow_y = y;

        // Offset based on facing direction (similar to player system)
        switch (facing_dir) {
            case "right":
                _arrow_x += 16;
                _arrow_y += 8;
                break;
            case "up":
                _arrow_x += 16;
                _arrow_y -= 16;
                break;
            case "left":
                _arrow_x -= 16;
                _arrow_y -= 20;
                break;
            case "down":
                _arrow_x -= 16;
                _arrow_y += 8;
                break;
        }

        // Spawn arrow
        var _arrow = instance_create_layer(_arrow_x, _arrow_y, "Instances", obj_enemy_arrow);
        _arrow.creator = self;
        _arrow.damage = ranged_damage;  // Use enemy's ranged damage

        // Set direction based on facing_dir
        switch (facing_dir) {
            case "right": _arrow.direction = 0; break;
            case "up": _arrow.direction = 90; break;
            case "left": _arrow.direction = 180; break;
            case "down": _arrow.direction = 270; break;
        }
        _arrow.image_angle = _arrow.direction;

        // Set state and cooldown
        state = EnemyState.ranged_attacking;
        ranged_attack_cooldown = max(15, round(60 / ranged_attack_speed));
        can_ranged_attack = false;

        // Play sound effect (use existing enemy attack sound or create new)
        play_enemy_sfx("on_attack");

        return true;
    }

    return false;
}
```

**Function Behavior:**
- Returns `false` if enemy is not a ranged attacker or on cooldown
- Returns `true` if arrow was successfully spawned
- Manages separate cooldown from melee attacks
- Spawns `obj_enemy_arrow` with enemy's `ranged_damage` value
- Sets `EnemyState.ranged_attacking` state
- Uses enemy's `facing_dir` to determine arrow direction

**Design Pattern:** Follows the same pattern as `player_handle_attack_input()` from the player ranged attack system documented in `RANGED_ATTACK_SYSTEM_TECHNICAL.md`.

---

### 4. Enemy Arrow Object

**Object:** `obj_enemy_arrow` (already created by user)

**Expected Configuration:**

The existing `obj_enemy_arrow` object should have similar properties to `obj_arrow`:

**Create Event:**
```gml
creator = noone;      // Set to enemy instance
damage = 0;           // Set by enemy's ranged_damage
speed = 6;            // Movement speed
direction = 0;        // Set by spawning code
image_angle = direction;
sprite_index = spr_items;  // Or enemy-specific arrow sprite
image_index = 28;     // Arrow frame
depth = -y;
```

**Step Event:**
- Check collision with `Tiles_Col` layer (destroy on wall hit)
- Check collision with `obj_player` (apply damage, destroy arrow)
- Check bounds (destroy if outside room)

**Collision Logic with Player:**
```gml
var _hit_player = instance_place(x, y, obj_player);
if (_hit_player != noone) {
    with (_hit_player) {
        // Apply damage
        hp -= other.damage;

        // Knockback
        kb_x = sign(x - other.x) * 2;
        kb_y = sign(y - other.y) * 2;

        // Visual feedback
        image_blend = c_red;
        alarm[1] = 10;  // Flash duration

        // Spawn damage number
        spawn_damage_number(x, y - 16, other.damage, DamageType.physical, self);
    }

    instance_destroy();
    exit;
}
```

**Note:** This assumes `obj_enemy_arrow` follows the same collision pattern as `obj_arrow` but targets `obj_player` instead of `obj_enemy_parent`.

---

### 5. Greenwood Bandit Configuration

**File:** `/objects/obj_greenwood_bandit/Create_0.gml`

Add ranged attack configuration after existing stats:

```gml
// Inherit the parent event
event_inherited();

// Greenwood Bandit-specific stats (balanced)
attack_damage = 2;
attack_speed = 0.9;
attack_range = 22;
hp = 4;
move_speed = 1.0;

// Ranged attack configuration
is_ranged_attacker = true;
ranged_damage = 3;           // Higher than melee damage
ranged_attack_speed = 0.7;   // Slower than melee (longer cooldown)
```

**Balance Rationale:**
- `ranged_damage = 3`: Higher than melee to reward ranged positioning
- `ranged_attack_speed = 0.7`: Slower rate of fire (~86 frame cooldown) balances higher damage
- Greenwood Bandit maintains existing melee stats for future hybrid behavior

---

### 6. Integration Points

#### A. Enemy Step Event (Implementation-Dependent)

The `enemy_handle_ranged_attack()` function should be called from the enemy's Step event or AI logic. Exact integration point depends on existing enemy behavior structure.

**Placeholder Integration (to be refined in AI pass):**

```gml
// In obj_enemy_parent Step event or AI function
if (is_ranged_attacker && can_ranged_attack) {
    // Check if player is in range and line of sight
    var _player = instance_nearest(x, y, obj_player);
    if (_player != noone && point_distance(x, y, _player.x, _player.y) < attack_range) {
        enemy_handle_ranged_attack();
    }
}
```

**Note:** This is a minimal integration. Full AI behavior (targeting, distance management, state transitions) will be handled in a separate specification.

#### B. State Handling

The `EnemyState.ranged_attacking` state should return to `EnemyState.idle` after a brief animation delay (similar to player attack state). This can be managed with an alarm or frame counter.

```gml
// Example: In enemy Step event
if (state == EnemyState.ranged_attacking) {
    // Wait for attack animation/cooldown
    if (ranged_attack_cooldown == 0) {
        state = EnemyState.idle;
    }
}
```

---

### 7. Sound Effects

Enemies should play attack sound when firing arrows:

```gml
play_enemy_sfx("on_attack");
```

The existing `play_enemy_sfx()` function and `enemy_sounds` struct in `obj_enemy_parent` should handle this. If a specific bow sound is desired, add:

```gml
// In obj_greenwood_bandit Create event
enemy_sounds.on_attack = snd_bow_attack;  // Reuse player bow sound
```

---

### 8. Facing Direction Requirement

Enemies must have a `facing_dir` property (string: "right", "up", "left", "down") for arrow direction calculation. If this doesn't exist in `obj_enemy_parent`, it must be added and updated based on movement direction.

**Check:** Verify `facing_dir` exists in enemy parent or add tracking in movement logic.

---

### 9. Future Extension Points

The system is designed with these future enhancements in mind:

#### Ranged/Melee Switching
```gml
// Future logic example
if (distance_to_player < 32) {
    // Switch to melee
    if (can_attack) {
        enemy_handle_melee_attack();
    }
} else {
    // Use ranged
    if (can_ranged_attack) {
        enemy_handle_ranged_attack();
    }
}
```

#### Enemy-Specific Projectiles
```gml
// Future enhancement: projectile type property
projectile_object = obj_enemy_arrow;  // Can be overridden to obj_fire_arrow, etc.
```

#### Ammo Management (Optional Future)
```gml
// Future enhancement
arrow_count = 10;
max_arrows = 10;

// In ranged attack function
if (arrow_count > 0) {
    arrow_count--;
    // spawn arrow
}
```

---

## Performance Considerations

- **Projectile Pooling:** Not required for MVP, but if many ranged enemies spawn simultaneously, consider object pooling to reduce `instance_create_layer` overhead
- **Collision Checks:** Enemy arrows use same efficient collision detection as player arrows (tilemap checks + `instance_place`)
- **Cooldown Management:** Frame-based cooldown decrements are lightweight and already used in player system

---

## Testing Checklist

1. Greenwood Bandit spawns and fires arrows at player
2. Arrows deal correct damage (3 for Greenwood Bandit)
3. Separate cooldowns work (enemy can have different melee/ranged cooldowns)
4. Arrows destroy on wall collision
5. Arrows destroy on player collision and apply damage/knockback
6. Enemy enters `EnemyState.ranged_attacking` when firing
7. Enemy returns to idle state after attack
8. Sound effects play on arrow fire
9. System is reusable: setting `is_ranged_attacker = true` on another enemy works

---

## File Summary

**Files to Modify:**
1. `/scripts/scr_enums/scr_enums.gml` - Add `EnemyState.ranged_attacking`
2. `/objects/obj_enemy_parent/Create_0.gml` - Add ranged attack properties
3. `/scripts/player_attacking/player_attacking.gml` OR create new `/scripts/enemy_attacking/enemy_attacking.gml` - Add `enemy_handle_ranged_attack()` function
4. `/objects/obj_greenwood_bandit/Create_0.gml` - Configure as ranged attacker
5. `/objects/obj_enemy_arrow/Create_0.gml` - Verify properties (if not already correct)
6. `/objects/obj_enemy_arrow/Step_0.gml` - Implement collision detection (if not already correct)

**Files to Reference:**
- `/docs/RANGED_ATTACK_SYSTEM_TECHNICAL.md` - Player ranged attack implementation pattern
- `/objects/obj_arrow/Create_0.gml` - Arrow object pattern
- `/objects/obj_arrow/Step_0.gml` - Arrow collision pattern
- `/scripts/player_attacking/player_attacking.gml` - Attack function pattern

---

## Ruby-Style Naming Conventions

All code follows the Ruby-style conventions documented in CLAUDE.md:
- Functions: `snake_case` (e.g., `enemy_handle_ranged_attack()`)
- Variables: `snake_case` (e.g., `is_ranged_attacker`, `ranged_damage`)
- Local variables: prefixed with underscore (e.g., `_arrow`, `_arrow_x`)
- Enums: `PascalCase` (e.g., `EnemyState`)
- Enum values: `snake_case` (e.g., `EnemyState.ranged_attacking`)
