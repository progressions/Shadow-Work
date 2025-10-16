# Ranged Attack System - Technical Documentation

## Overview

This document provides a comprehensive technical breakdown of the ranged attack system for both player and enemy, including weapon detection, projectile spawning, collision detection, range profiles, wind deflection, and damage calculation.

---

## System Architecture

The ranged attack system consists of several interconnected components:

1. **Attack Input Handler** - Detects input and determines attack type
2. **Windup System** - Animation and ammo consumption phase
3. **Ammo Management** - Validates and consumes ammunition
4. **Projectile Spawner** - Creates and configures arrow instances
5. **Range Profile System** - Distance-based damage scaling
6. **Collision System** - Detects hits and applies damage
7. **Wind Deflection** - Companion aura projectile bending
8. **Enemy Ranged Attacks** - AI-driven ranged combat

---

## 1. Attack Input Detection

**Primary Function:** `player_handle_attack_input()`
**Location:** `/scripts/player_attacking/player_attacking.gml:18-131`
**Called From:** `obj_player/Step_0.gml:85`

This function runs every frame and handles all player attack logic.

### Attack Initiation

```gml
if (keyboard_check_pressed(ord("J")) && can_attack) {
    // Attack logic begins
}
```

**Cooldown Management:**
- `attack_cooldown` decrements each frame (lines 19-25)
- When `attack_cooldown` reaches 0, `can_attack` is set to `true`
- After each attack, cooldown is reset based on weapon's `attack_speed` stat

---

## 2. Ranged Weapon Detection

**Location:** `/scripts/player_attacking/player_attacking.gml:32-46`

### Detection Logic

The system determines if an attack is ranged by checking for the `requires_ammo` property:

```gml
// Check if equipped weapon is ranged
if (equipped.right_hand != undefined &&
    equipped.right_hand.definition.type == ItemType.weapon) {

    if (equipped.right_hand.definition.stats[$ "requires_ammo"] != undefined) {
        _is_ranged = true;
        show_debug_message("Detected ranged weapon! Ammo type: " +
            equipped.right_hand.definition.stats.requires_ammo);
    }
}
```

### Item Database Example

Ranged weapons in `global.item_database` must include:

```gml
longbow: {
    item_id: "longbow",
    type: ItemType.weapon,
    stats: {
        damage: 6,
        attack_speed: 1.2,
        requires_ammo: "arrows",  // This flag makes it ranged
        // ... other stats
    }
}
```

**Key Point:** The presence of `requires_ammo` in the weapon's stats struct is the **sole determinant** of whether a weapon fires projectiles.

---

## 3. Ammo System

### Checking Ammo Availability

**Function:** `has_ammo(_ammo_type)`
**Location:** `/scripts/scr_inventory_system/scr_inventory_system.gml:496-504`

```gml
function has_ammo(_ammo_type) {
    for (var i = 0; i < array_length(inventory); i++) {
        var _item = inventory[i];
        if (_item.definition.item_id == _ammo_type && _item.count > 0) {
            return true;
        }
    }
    return false;
}
```

**Called At:** `player_attacking.gml:49`

```gml
var _has_arrows = has_ammo("arrows");
```

### Consuming Ammo

**Function:** `consume_ammo(_ammo_type, _amount)`
**Location:** `/scripts/scr_inventory_system/scr_inventory_system.gml:507-518`

```gml
function consume_ammo(_ammo_type, _amount = 1) {
    for (var i = 0; i < array_length(inventory); i++) {
        var _item = inventory[i];
        if (_item.definition.item_id == _ammo_type) {
            if (_item.count >= _amount) {
                inventory_remove_item(i, _amount);
                return true;
            }
        }
    }
    return false;
}
```

**Called At:** `player_attacking.gml:92`

This removes exactly 1 arrow from the player's inventory after successful spawn.

---

## 4. Projectile Spawning

**Location:** `/scripts/player_attacking/player_attacking.gml:47-99`

### Spawn Position Calculation

Arrow spawn position is offset based on the player's `facing_dir`:

```gml
var _arrow_x = x;
var _arrow_y = y;

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
```

### Instance Creation

```gml
var _arrow = instance_create_layer(_arrow_x, _arrow_y, "Instances", obj_arrow);
_arrow.creator = self;
_arrow.damage = get_total_damage();
```

**Critical Properties:**
- `creator`: Reference to the player instance (used for XP attribution)
- `damage`: Calculated once at spawn using `get_total_damage()`

### Direction Assignment

```gml
switch (facing_dir) {
    case "right": _arrow.direction = 0; break;
    case "up": _arrow.direction = 90; break;
    case "left": _arrow.direction = 180; break;
    case "down": _arrow.direction = 270; break;
}
_arrow.image_angle = _arrow.direction;
```

GameMaker's `direction` property (in degrees) automatically moves the arrow:
- 0° = East
- 90° = North
- 180° = West
- 270° = South

### Post-Spawn Actions

1. **Consume ammo:** `consume_ammo("arrows", 1);`
2. **Play sound:** `play_sfx(snd_bow_attack, 1, false);`
3. **Set cooldown:** `attack_cooldown = max(15, round(60 / _attack_speed));`
4. **Set state:** `state = PlayerState.attacking;`

---

## 5. Arrow Object Configuration

**Object:** `obj_arrow`
**Create Event:** `/objects/obj_arrow/Create_0.gml`

### Initial Properties

```gml
// Set by spawning code
creator = noone;      // Player instance reference
damage = 0;           // Total damage value

// Movement
speed = 6;            // Pixels per frame
direction = 0;        // Set by player facing_dir
image_angle = direction;

// Visual
sprite_index = spr_items;
image_index = 28;     // Arrow frame from item database
image_speed = 0;

// Rendering
depth = -y;           // Draw order (higher Y = behind)
```

**Key Design Point:** Damage is assigned once at creation and never recalculated. The arrow "snapshots" the player's damage at the moment of firing.

---

## 6. Collision Detection & Damage Application

**Step Event:** `/objects/obj_arrow/Step_0.gml:1-59`

The arrow performs three collision checks each frame:

### A. Wall Collision (lines 2-11)

```gml
var _tilemap_col = layer_tilemap_get_id("Tiles_Col");
if (_tilemap_col != -1) {
    var _tile_value = tilemap_get_at_pixel(_tilemap_col, x, y);
    if (_tile_value != 0) {
        play_sfx(snd_bump, 1, false);
        instance_destroy();
        exit;
    }
}
```

Arrows are destroyed instantly when hitting solid tiles.

### B. Enemy Collision (lines 14-52)

```gml
var _hit_enemy = instance_place(x, y, obj_enemy_parent);
if (_hit_enemy != noone) {
    with (_hit_enemy) {
        // Only damage living enemies not in hit immunity
        if (state != EnemyState.dead && alarm[1] < 0) {
            // Apply damage
            hp -= other.damage;
            image_blend = c_red;

            // Play hit sound
            play_enemy_sfx("on_hit");

            // Spawn floating damage number
            spawn_damage_number(x, y - 16, other.damage, DamageType.physical, self);

            // Check for death
            if (hp <= 0) {
                // Award XP to the arrow's creator (player)
                var attacker = other.creator;
                if (attacker != noone && attacker.object_index == obj_player) {
                    var xp_reward = 5;
                    with (attacker) {
                        gain_xp(xp_reward);
                    }
                }

                state = EnemyState.dead;
                play_enemy_sfx("on_death");
                increment_quest_counter("enemies_defeated", 1);
            }

            // Apply knockback
            kb_x = sign(x - other.x);
            kb_y = sign(y - other.y);
            alarm[1] = 20;  // 20 frames of hit immunity
        }
    }

    instance_destroy();
    exit;
}
```

**Collision Function:** `instance_place(x, y, obj_enemy_parent)` checks for any instance of enemy parent or child objects.

**Hit Immunity:** `alarm[1] < 0` ensures enemies can't be hit multiple times in rapid succession.

**XP Attribution:** The `creator` property links damage back to the player for experience rewards.

**Knockback Direction:** Calculated as `sign(enemy.x - arrow.x)` for both X and Y axes.

### C. Bounds Check (lines 54-58)

```gml
if (x < 0 || x > room_width || y < 0 || y > room_height) {
    instance_destroy();
    exit;
}
```

Prevents arrows from existing outside the room boundaries.

---

## 7. Damage Calculation

**Function:** `get_total_damage()`
**Location:** `/scripts/scr_combat_system/scr_combat_system.gml:5-25`

This function is called **once** when the arrow spawns, and the result is stored in the arrow's `damage` variable.

```gml
function get_total_damage() {
    var _base_damage = 1; // Base unarmed damage

    // Right hand weapon
    if (equipped.right_hand != undefined &&
        equipped.right_hand.definition.type == ItemType.weapon) {

        var _weapon_stats = equipped.right_hand.definition.stats;

        // Check if using versatile weapon two-handed
        if (is_two_handing() &&
            equipped.right_hand.definition.handedness == WeaponHandedness.versatile) {
            _base_damage = _weapon_stats[$ "two_handed_damage"] ?? _weapon_stats.damage;
        } else {
            _base_damage = _weapon_stats.damage;
        }
    }

    // Add left hand weapon damage if dual-wielding
    if (is_dual_wielding()) {
        var _left_damage = equipped.left_hand.definition.stats.damage;
        _base_damage += _left_damage * 0.5; // Off-hand does 50% damage
    }

    // ... additional modifiers (armor, status effects, etc.)

    return _base_damage;
}
```

**Important:** Ranged weapons cannot be dual-wielded or used two-handed, so the calculation is simpler for bows/crossbows.

---

## 8. Attack Cooldown System

**Location:** `/scripts/player_attacking/player_attacking.gml:98`

```gml
attack_cooldown = max(15, round(60 / _attack_speed));
```

**Calculation:**
- Base formula: `60 / attack_speed`
- Minimum: 15 frames (~0.25 seconds at 60 FPS)
- Example: Longbow with `attack_speed: 1.2` → `60 / 1.2 = 50 frames` cooldown

**Cooldown Decrement:** Handled in `player_handle_attack_input()` lines 19-25, runs every frame.

---

## Complete Attack Flow Sequence

1. **Frame N:** Player presses "J" key
2. **Check:** `can_attack == true` and `attack_cooldown == 0`
3. **Weapon Check:** Is `equipped.right_hand.definition.stats.requires_ammo` defined?
4. **Ammo Check:** Does inventory contain arrows with `count > 0`?
5. **State Change:** `state = PlayerState.attacking` (triggers attack animation)
6. **Position:** Calculate spawn offset based on `facing_dir`
7. **Spawn:** `instance_create_layer()` creates `obj_arrow`
8. **Configure:** Set `creator`, `damage`, `direction`, `image_angle`
9. **Consume:** Remove 1 arrow from inventory
10. **Sound:** Play `snd_bow_attack`
11. **Cooldown:** Set `attack_cooldown` based on weapon speed
12. **Frame N+1 onward:** Arrow moves at `speed = 6` in its `direction`
13. **Each Frame:** Arrow checks for wall/enemy/bounds collisions
14. **On Hit:** Apply `damage` to enemy, spawn damage number, award XP, destroy arrow
15. **Cooldown Ends:** Player can attack again when `attack_cooldown` reaches 0

---

## Debug Features

**Debug Key:** Press `9` to add 10 arrows to inventory
**Location:** `obj_player/Step_0.gml:171-174`

```gml
if (keyboard_check_pressed(ord("9"))) {
    inventory_add_item(global.item_database.arrows, 10);
    show_debug_message("Added 10 arrows to inventory");
}
```

---

## Key Files Reference

| File | Purpose | Key Lines |
|------|---------|-----------|
| `/scripts/player_attacking/player_attacking.gml` | Main attack logic | 18-131 |
| `/objects/obj_arrow/Create_0.gml` | Arrow initialization | 1-17 |
| `/objects/obj_arrow/Step_0.gml` | Collision detection | 1-59 |
| `/scripts/scr_inventory_system/scr_inventory_system.gml` | Ammo management | 496-518 |
| `/scripts/scr_combat_system/scr_combat_system.gml` | Damage calculation | 5-25 |
| `/objects/obj_player/Step_0.gml` | Input handling | 85 |

---

## Design Patterns & Best Practices

### 1. Creator Pattern
The arrow stores a reference to its creator (`self`), enabling proper XP attribution even after the arrow has traveled across the map.

### 2. Snapshot Damage
Damage is calculated once at spawn time. This prevents exploits where players could switch weapons mid-flight to increase damage.

### 3. State-Based Hit Immunity
Enemies use `alarm[1]` for hit immunity, preventing multiple projectiles from hitting the same enemy in a single frame.

### 4. Early Exit Pattern
All collision checks use `exit;` after `instance_destroy()` to prevent further code execution on destroyed instances.

### 5. Collision Order
Checks are ordered by frequency: walls (most common) → enemies → bounds. This optimizes performance.

---

## Extending the System

### Adding New Projectile Types

1. **Create new projectile object** (e.g., `obj_crossbow_bolt`)
2. **Modify spawn logic** in `player_attacking.gml` to check weapon type:
   ```gml
   var _projectile_obj = obj_arrow; // default
   if (equipped.right_hand.definition.item_id == "crossbow") {
       _projectile_obj = obj_crossbow_bolt;
   }
   var _projectile = instance_create_layer(_x, _y, "Instances", _projectile_obj);
   ```
3. **Configure projectile properties** (speed, sprite, damage modifiers)

### Adding New Ammo Types

1. **Add ammo to item database** with unique `item_id`
2. **Set weapon's `requires_ammo`** to match the new `item_id`
3. **Ammo system automatically handles** validation and consumption

---

## Known Limitations

1. **No Gravity:** Arrows fly in straight lines without arc physics
2. **Fixed Speed:** All arrows move at `speed = 6` regardless of weapon
3. **No Penetration:** Arrows are destroyed on first hit
4. **Single Target:** Cannot damage multiple enemies in a line
5. **No Ricochet:** Arrows don't bounce off walls

These limitations are by design for the current MVP implementation.

---

## Future Enhancements (Not Implemented)

- **Arrow Recovery:** Chance to retrieve arrows from dead enemies
- **Elemental Arrows:** Fire/ice/poison arrow types
- **Charging System:** Hold attack button to increase damage/range
- **Trajectory Arcs:** Parabolic flight paths with gravity
- **Critical Hits:** Random damage multipliers based on accuracy stat

---

## Related Systems

- **Inventory System:** Manages arrow count and stackable items
- **Combat System:** Calculates total damage from equipment
- **Animation System:** Triggers attack animations during `PlayerState.attacking`
- **Status Effects:** Could modify arrow damage/speed in future versions
- **Trait System:** Could grant ranged damage bonuses or ammo efficiency

---

## 9. Windup System

### Overview

The ranged attack system uses a two-phase approach: windup phase (ammo consumption and animation) followed by projectile spawn on animation completion.

**Location:** `/scripts/player_attacking/player_attacking.gml` (lines 268-300)

### Windup Phase

```gml
// Check if weapon requires ammo
if (equipped.right_hand.definition.stats[$ "requires_ammo"] != undefined) {
    var ammo_type = equipped.right_hand.definition.stats.requires_ammo;

    // Check ammo availability
    if (has_ammo(ammo_type)) {
        // Enter attacking state
        state = PlayerState.attacking;
        ranged_windup_active = true;

        // CONSUME AMMO IMMEDIATELY (prevents waste if interrupted)
        consume_ammo(ammo_type, 1);

        // Store windup direction for spawn
        ranged_windup_direction = facing_dir;
        ranged_windup_complete = false;

        // Play windup sound
        play_sfx(snd_ranged_windup, 0.8);
    }
}
```

**Key Design:** Ammo consumed at windup start (not spawn) prevents exploits/waste

### Arrow Spawn Phase

**Function:** `player_spawn_ranged_projectile_after_windup()`
**Location:** Lines 193-266 in `player_attacking.gml`
**Called:** When ranged attack animation completes

```gml
// Get range profile from weapon or default
var range_profile_id = RangeProfile.generic_arrow;
if (equipped.right_hand.definition.stats[$ "range_profile"] != undefined) {
    range_profile_id = equipped.right_hand.definition.stats.range_profile;
}

// Calculate spawn position with direction-based offsets
var _arrow_x = x;
var _arrow_y = y;

switch (ranged_windup_direction) {
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

// Create arrow
var _arrow = instance_create_layer(_arrow_x, _arrow_y, "Instances", obj_arrow);

// Configure arrow
_arrow.creator = self;
_arrow.damage = get_total_damage();
_arrow.range_profile_id = range_profile_id;
_arrow.spawn_x = _arrow_x;
_arrow.spawn_y = _arrow_y;

// Set direction
var dir_angle = direction_string_to_angle(ranged_windup_direction);
_arrow.direction = dir_angle;
_arrow.image_angle = dir_angle;

// Set speed (default 2 px/frame)
_arrow.speed = 2;

// Play launch sound
play_sfx(snd_bow_attack, 1.0);
```

**Windup Variables:**
```gml
ranged_windup_active = false;
ranged_windup_complete = false;
ranged_windup_direction = "";
```

---

## 10. Range Profile System

### Overview

Range profiles control distance-based damage falloff with three zones: point blank (reduced damage), optimal range (full damage), and long range (falloff).

**Location:** `/scripts/scr_projectile_range_profiles/scr_projectile_range_profiles.gml`

### Profile Structure

```gml
{
    point_blank_distance: 48,      // Distance where point blank ends
    point_blank_multiplier: 0.6,   // Damage multiplier at spawn point
    optimal_start: 60,             // Optimal zone start
    optimal_end: 140,              // Optimal zone end
    max_distance: 200,             // Maximum travel distance
    long_range_multiplier: 0.5,    // Damage at max distance
    overshoot_buffer: 32           // Grace period before auto-cull
}
```

### Available Profiles

**Generic Arrow:**
- Point blank: 32px @ 0.7x
- Optimal: 96-144px @ 1.0x
- Max: 224px @ 0.55x

**Wooden Bow:**
- Point blank: 32px @ 0.6x
- Optimal: 96-160px @ 1.0x
- Max: 240px @ 0.5x

**Longbow:**
- Point blank: 148px @ 0.5x (very long!)
- Optimal: 160-260px @ 1.0x
- Max: 340px @ 0.6x
- Buffer: 48px

**Crossbow:**
- Point blank: 24px @ 0.55x
- Optimal: 64-120px @ 1.0x
- Max: 200px @ 0.4x

**Heavy Crossbow:**
- Similar to crossbow
- 30% armor penetration (separate stat)

**Enemy Shortbow:**
- Point blank: 32px @ 0.65x
- Optimal: 80-140px @ 1.0x
- Max: 220px @ 0.55x

### Damage Calculation

**Location:** `/objects/obj_arrow/Step_0.gml` (lines 1-28)

```gml
// Update distance traveled
distance_travelled = point_distance(spawn_x, spawn_y, x, y);

// Get range profile
var profile = get_range_profile(range_profile_id);

// Calculate multiplier
if (distance_travelled < profile.point_blank_distance) {
    // Point blank zone: lerp from point_blank_multiplier to 1.0
    var t = distance_travelled / profile.point_blank_distance;
    current_damage_multiplier = lerp(
        profile.point_blank_multiplier,
        1.0,
        t
    );
}
else if (distance_travelled >= profile.optimal_start &&
         distance_travelled <= profile.optimal_end) {
    // Optimal zone: full damage
    current_damage_multiplier = 1.0;
}
else if (distance_travelled > profile.optimal_end) {
    // Long range falloff
    var falloff_distance = profile.max_distance - profile.optimal_end;
    var distance_into_falloff = distance_travelled - profile.optimal_end;
    var t = min(1.0, distance_into_falloff / falloff_distance);
    current_damage_multiplier = lerp(
        1.0,
        profile.long_range_multiplier,
        t
    );
}

// Auto-cull check
var max_travel = profile.max_distance + profile.overshoot_buffer;
if (distance_travelled > max_travel) {
    instance_destroy();
    exit;
}
```

**Damage Application:**
```gml
// In collision with enemy
var final_damage = damage * current_damage_multiplier;
```

---

## 11. Enemy Ranged Attack System

### Configuration

**Location:** `/objects/obj_enemy_parent/Create_0.gml` (lines 80-96)

```gml
// Flags
is_ranged_attacker = false;
can_ranged_attack = false;

// Stats
ranged_damage = 3;
ranged_damage_type = DamageType.physical;
ranged_attack_cooldown = 0;
ranged_attack_speed = 1.0;          // Attacks per second

// Projectile
ranged_projectile_object = obj_enemy_arrow;
ranged_projectile_speed = 4;        // Faster than player (2 px/frame)

// Attack struct
ranged_attack = {
    damage: ranged_damage,
    damage_type: ranged_damage_type,
    chance_to_stun: 0.03,           // Lower than melee (0.05)
    chance_to_stagger: 0.08,        // Lower than melee (0.12)
    stun_duration: 1.2,
    stagger_duration: 0.8,
    range: attack_range
};
```

### Enemy Attack Flow

**Function:** `enemy_handle_ranged_attack()`
**Location:** `/scripts/enemy_handle_ranged_attack/enemy_handle_ranged_attack.gml`

**Phase 1: Windup (lines 83-130)**
```gml
if (is_ranged_attacker && can_ranged_attack) {
    // Update cooldown
    ranged_attack_cooldown--;

    if (ranged_attack_cooldown <= 0) {
        // Aim at player
        var player_angle = point_direction(x, y, obj_player.x, obj_player.y);
        facing_dir = angle_to_direction_string(player_angle);

        // Enter ranged attacking state
        state = EnemyState.ranged_attacking;
        ranged_windup_complete = false;
        anim_timer = 0;

        // Calculate cooldown
        ranged_attack_cooldown = max(15, round(60 / ranged_attack_speed));

        // Failsafe alarm (prevents stuck state)
        alarm[3] = 90;

        // Play windup sound
        play_enemy_sfx("on_ranged_windup");
    }
}
```

**Phase 2: Projectile Spawn (lines 1-81)**

**Function:** `spawn_ranged_projectile()`

```gml
// Re-aim at player before spawning
var target_angle = point_direction(x, y, obj_player.x, obj_player.y);
facing_dir = angle_to_direction_string(target_angle);

// Calculate spawn position (same offsets as player)
var _arrow_x = x;
var _arrow_y = y;

switch (facing_dir) {
    case "right": _arrow_x += 16; _arrow_y += 8; break;
    case "up": _arrow_x += 16; _arrow_y -= 16; break;
    case "left": _arrow_x -= 16; _arrow_y -= 20; break;
    case "down": _arrow_x -= 16; _arrow_y += 8; break;
}

// Create projectile
var projectile = instance_create_layer(
    _arrow_x,
    _arrow_y,
    layer,
    ranged_projectile_object
);

// Configure projectile
projectile.creator = id;
projectile.damage = ranged_damage;
projectile.damage_type = ranged_damage_type;

// Copy status effects
if (array_length(ranged_status_effects) > 0) {
    projectile.status_effects = ranged_status_effects;
} else if (array_length(attack_status_effects) > 0) {
    projectile.status_effects = attack_status_effects;
}

// Set direction and speed
projectile.direction = target_angle;
projectile.image_angle = target_angle;
projectile.speed = ranged_projectile_speed;  // 4 px/frame (default)

// Play attack sound
play_enemy_sfx("on_ranged_attack");
```

### Key Differences from Player

| Feature | Player | Enemy |
|---------|--------|-------|
| **Speed** | 2 px/frame | 4 px/frame |
| **Ammo** | Required | Unlimited |
| **Movement** | No (attacking state) | Yes (can kite) |
| **Crit System** | No crits on projectiles | Can crit player |
| **Range Profiles** | Full system | Basic (enemy_shortbow) |
| **Windup Sound** | snd_ranged_windup | on_ranged_windup (configurable) |

### Dual-Mode Integration

Enemies with `enable_dual_mode = true` can switch between melee and ranged:

**Decision Logic:**
- **Beyond ideal_range:** Use ranged attack
- **Below melee_range_threshold:** Use melee attack
- **Formation role override:** "rear"/"support" forces ranged
- **Cooldown gate:** Can't use mode if on cooldown

**Key Variables:**
```gml
enable_dual_mode = true;
preferred_attack_mode = "ranged";  // "none", "melee", or "ranged"
melee_range_threshold = attack_range * 0.5;
retreat_when_close = true;
ideal_range = attack_range * 0.75;
```

---

## 12. Wind Deflection System

### Overview

Hola companion (affinity 5+) creates a wind aura that deflects enemy arrows away from the player. Deflection strength scales with proximity to player and Hola's affinity level.

**Location:** `/objects/obj_enemy_arrow/Step_0.gml` (lines 1-38)

### Deflection Calculation

```gml
// Check if Hola exists with affinity 5+
if (instance_exists(obj_hola) && obj_hola.affinity >= 5) {
    var dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);

    // Check if within aura radius
    var aura_radius = 150;  // Configurable
    if (dist_to_player < aura_radius) {
        // Calculate deflection strength
        var proximity_factor = 1 - (dist_to_player / aura_radius);

        // Affinity scaling: 0% at affinity 5, 100% at affinity 10
        var affinity_factor = (obj_hola.affinity - 5) / 5;

        // Combined multiplier
        var deflection_multiplier = proximity_factor * affinity_factor;

        // Max deflection: 15 degrees per frame
        var max_deflection = 15;
        var deflection_amount = max_deflection * deflection_multiplier;

        // Calculate angle away from player
        var angle_to_player = point_direction(x, y, obj_player.x, obj_player.y);
        var angle_away = angle_to_player + 180;

        // Blend current direction toward away direction
        direction = lerp_angle(direction, angle_away, deflection_amount / 180);
        image_angle = direction;
    }
}
```

### Deflection Properties

**Maximum Deflection:**
- 15 degrees per frame at close range with max affinity
- Can turn arrow 90 degrees in 6 frames
- Full 180 degree turnaround in 12 frames

**Scaling Factors:**
- **Proximity:** 100% at player position, 0% at aura edge
- **Affinity:** 0% at affinity 5, 100% at affinity 10

**Example Values:**
- Affinity 7.5, 50 pixels from player (75 pixel aura):
  - Proximity factor: 1 - (50/75) = 0.33
  - Affinity factor: (7.5-5)/5 = 0.5
  - Combined: 0.33 × 0.5 = 0.165
  - Deflection: 15° × 0.165 = **2.5° per frame**

---

## 13. Enemy Arrow Object

**Object:** `obj_enemy_arrow`
**Parent:** `obj_arrow` (inherits base behavior)

**Location:** `/objects/obj_enemy_arrow/`

### Create Event

```gml
event_inherited();  // Inherit from obj_arrow

// Override visual
image_index = 28;  // Same sprite as player arrow

// Communication variables for damage calculation
// (Used to pass data between collision and damage calculation)
```

### Step Event

**Order of Operations:**
1. Wind deflection (if Hola present)
2. Wall collision check (inherited)
3. Player collision check (overridden)
4. Out of bounds check (inherited)

### Player Collision

**Location:** `/objects/obj_enemy_arrow/Collision_obj_player.gml` (lines 52-183)

**Damage Pipeline:**
```gml
// 1. Get status effect modifier from enemy
var status_modifier = 1.0;
if (instance_exists(creator)) {
    status_modifier = creator.get_status_effect_modifier("damage");
}

// 2. Critical hit roll (uses enemy's stats)
var is_crit = false;
var crit_multiplier = 1.0;
if (instance_exists(creator) && random(1) < creator.crit_chance) {
    is_crit = true;
    crit_multiplier = creator.crit_multiplier;
}

// 3. Calculate base damage
var base_damage = damage * status_modifier * crit_multiplier;

// 4. Apply trait-based resistance
var trait_modifier = other.get_damage_modifier_for_type(damage_type);
var modified_damage = base_damage * trait_modifier;

// 5. Apply player ranged DR
var ranged_dr = other.get_ranged_damage_reduction();
var final_damage = modified_damage - ranged_dr;

// 6. Chip damage (minimum 1 unless immune)
if (final_damage <= 0 && trait_modifier > 0) {
    final_damage = 1;
} else if (trait_modifier == 0) {
    final_damage = 0;  // Full immunity
}

// 7. Apply damage
other.hp -= final_damage;

// 8. Visual feedback
if (is_crit) {
    other.image_blend = c_red;  // Red flash
    freeze_frame(3);
} else {
    other.image_blend = c_red;  // Normal red flash
    freeze_frame(2);
}

// 9. Knockback (stronger than player arrows)
other.kb_x = sign(other.x - x) * 2;  // Player: 1, Enemy: 2
other.kb_y = sign(other.y - y) * 2;

// 10. Status effects
for (var i = 0; i < array_length(status_effects); i++) {
    var effect = status_effects[i];
    if (random(1) < (effect.chance ?? 1.0)) {
        other.apply_status_effect(effect.trait);
    }
}

// 11. Stun/stagger from enemy ranged_attack stats
if (instance_exists(creator)) {
    process_attack_cc_effects(creator, other, creator.ranged_attack);
}

// 12. Check player death
if (other.hp <= 0) {
    // Handle player death
}

// 13. Play sound
play_sfx(snd_player_hit, 1.0);

// 14. Spawn damage number
spawn_damage_number(other.x, other.y - 16, final_damage, damage_type);

// Destroy arrow
instance_destroy();
```

**Key Differences from Player Arrow Collision:**
- Enemies can crit player with ranged attacks
- Uses ranged DR (not melee DR)
- Stronger knockback (2 vs 1)
- Different visual feedback timing

---

## 14. Complete Attack Flow Sequences

### Player Ranged Attack Flow

1. **Frame N:** Player presses "J" with bow equipped
2. **Weapon Check:** Is `requires_ammo` defined? Yes
3. **Ammo Check:** Does inventory have arrows? Yes
4. **Windup Start:**
   - Set `state = PlayerState.attacking`
   - Set `ranged_windup_active = true`
   - **Consume 1 arrow immediately**
   - Store `ranged_windup_direction`
   - Play `snd_ranged_windup`
5. **Animation:** Ranged attack animation plays
6. **Windup Complete:** Animation finishes
   - Call `player_spawn_ranged_projectile_after_windup()`
7. **Arrow Spawn:**
   - Calculate spawn position with offsets
   - Create `obj_arrow` instance
   - Set `damage = get_total_damage()`
   - Set range profile from weapon
   - Set direction and speed (2 px/frame)
   - Play `snd_bow_attack`
8. **Frame N+1 onward:**
   - Arrow moves in direction
   - Update `distance_travelled`
   - Calculate `current_damage_multiplier` from range profile
9. **Collision:**
   - **Enemy:** Apply `damage * multiplier`, subtract enemy ranged DR
   - **Wall:** Destroy arrow
   - **Bounds:** Destroy arrow
10. **Cooldown:** Based on weapon `attack_speed`

### Enemy Ranged Attack Flow

1. **Targeting State:** Enemy pursuing player
2. **Range Check:** Player within `attack_range` and has LOS
3. **Cooldown Check:** `ranged_attack_cooldown <= 0`
4. **Windup Start:**
   - Aim at player
   - Set `state = EnemyState.ranged_attacking`
   - Set failsafe alarm
   - Play `on_ranged_windup` sound
5. **Animation:** Ranged attack animation plays
   - **Enemy can continue moving** (unlike melee)
6. **Animation Complete:**
   - Call `spawn_ranged_projectile()`
7. **Projectile Spawn:**
   - Re-aim at player
   - Calculate spawn position
   - Create `obj_enemy_arrow`
   - Set damage, type, speed (4 px/frame)
   - Copy status effects
   - Play `on_ranged_attack` sound
8. **Frame N+1 onward:**
   - Arrow moves toward target
   - **Wind deflection applied** (if Hola present)
9. **Collision:**
   - **Player:** Full damage pipeline with crit/trait/DR
   - **Wall:** Destroy arrow
   - **Bounds:** Destroy arrow
10. **Return to Targeting:** Enemy resumes pursuit

---

## 15. Weapon Database Examples

### Player Bows

```gml
wooden_bow: {
    item_id: "wooden_bow",
    type: ItemType.weapon,
    handedness: WeaponHandedness.two_handed,
    stats: {
        attack_damage: 2,
        attack_speed: 1.2,
        attack_range: 120,
        damage_type: DamageType.physical,
        requires_ammo: "arrows",
        range_profile: RangeProfile.wooden_bow
    },
    world_sprite_frame: 7,
    equipped_sprite_key: "wooden_bow",
    large_sprite: true  // Uses larger weapon sprite
}

longbow: {
    item_id: "longbow",
    type: ItemType.weapon,
    handedness: WeaponHandedness.two_handed,
    stats: {
        attack_damage: 5,
        attack_speed: 1.0,
        attack_range: 150,
        damage_type: DamageType.physical,
        requires_ammo: "arrows",
        range_profile: RangeProfile.longbow
    },
    world_sprite_frame: 8,
    equipped_sprite_key: "longbow",
    large_sprite: true
}

crossbow: {
    item_id: "crossbow",
    type: ItemType.weapon,
    handedness: WeaponHandedness.one_handed,  // Can use shield!
    stats: {
        attack_damage: 3,
        attack_speed: 0.6,
        attack_range: 140,
        damage_type: DamageType.physical,
        requires_ammo: "arrows",
        range_profile: RangeProfile.crossbow
    },
    world_sprite_frame: 9,
    equipped_sprite_key: "crossbow",
    large_sprite: true
}

heavy_crossbow: {
    item_id: "heavy_crossbow",
    type: ItemType.weapon,
    handedness: WeaponHandedness.two_handed,
    stats: {
        attack_damage: 6,
        attack_speed: 0.4,
        attack_range: 160,
        damage_type: DamageType.physical,
        requires_ammo: "arrows",
        range_profile: RangeProfile.heavy_crossbow,
        armor_pierce_percent: 0.3  // 30% armor penetration
    },
    world_sprite_frame: 10,
    equipped_sprite_key: "heavy_crossbow",
    large_sprite: true
}
```

### Arrows (Ammo)

```gml
arrows: {
    item_id: "arrows",
    name: "Arrows",
    type: ItemType.ammo,
    description: "Standard arrows for bows and crossbows",
    stackable: true,
    max_stack: 99,
    world_sprite_frame: 24
}
```

---

## 16. Sound Configuration

### Player Sounds

**Windup:**
- Sound: `snd_ranged_windup`
- Volume: 0.8
- Plays: When windup starts

**Launch:**
- Sound: `snd_bow_attack`
- Volume: 1.0
- Plays: When arrow spawns

### Enemy Sounds

**Configurable via `enemy_sounds` struct:**
```gml
enemy_sounds.on_ranged_windup = snd_enemy_ranged_windup;
enemy_sounds.on_ranged_attack = snd_bow_attack;
```

**Defaults:**
- Windup: `snd_enemy_ranged_windup` (if undefined)
- Attack: `snd_bow_attack` (if undefined)

**Hit Sounds:**
- Enemy hit by player arrow: Enemy's `on_hit` sound
- Player hit by enemy arrow: `snd_player_hit`

---

## 17. Debug Features

**Add Arrows to Inventory:**
- Key: Press `9`
- Amount: +10 arrows
- Location: `obj_player/Step_0.gml` (lines 171-174)

```gml
if (keyboard_check_pressed(ord("9"))) {
    inventory_add_item(global.item_database.arrows, 10);
    show_debug_message("Added 10 arrows to inventory");
}
```

**Debug Logging:**
- Windup start: "Detected ranged weapon! Ammo type: arrows"
- Range profile: Current multiplier logged each frame
- Collision: "Arrow hit enemy at distance: X"

---

## Related Systems

- **Inventory System:** Manages arrow count and stackable ammo
- **Combat System:** Calculates total damage from equipment
- **Animation System:** Triggers ranged attack animations
- **Status Effects:** Can be applied by arrows with `status_effects_on_hit`
- **Trait System:** Modifies incoming arrow damage via resistance/immunity
- **Companion System:** Hola provides wind deflection aura
- **Dual-Mode Enemy AI:** Switches between melee and ranged attacks
- **Range Profile System:** Controls distance-based damage scaling

---

*Last Updated: 2025-10-16*
