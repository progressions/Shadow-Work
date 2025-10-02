# Ranged Attack System - Technical Documentation

## Overview

This document provides a comprehensive technical breakdown of the player's ranged attack system, including how the game detects ranged weapons, spawns projectiles, handles collision detection, and applies damage to targets.

---

## System Architecture

The ranged attack system consists of several interconnected components:

1. **Attack Input Handler** - Detects player input and determines attack type
2. **Ammo Management** - Validates and consumes ammunition
3. **Projectile Spawner** - Creates and configures arrow instances
4. **Collision System** - Detects hits and applies damage
5. **Damage Calculator** - Computes final damage values

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

*Last Updated: 2025-10-02*
