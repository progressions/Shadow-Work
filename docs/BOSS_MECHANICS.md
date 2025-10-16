# Boss Mechanics - Technical Documentation

This document provides comprehensive technical documentation for the advanced boss systems in Shadow Work, including the Chain Boss system and the Hazard Spawning system used primarily by boss encounters.

---

## Table of Contents

1. [Chain Boss System](#chain-boss-system)
2. [Hazard Spawning System](#hazard-spawning-system)

---

## Chain Boss System

### Overview

The Chain Boss system creates multi-entity boss encounters where the boss is physically chained to 2-5 auxiliary minions. Auxiliaries cannot move beyond the chain length, provide damage reduction to the boss, and participate in coordinated special attacks (throw and spin).

### Object Hierarchy

**Base:** `obj_chain_boss_parent` → `obj_enemy_parent`
**Implementation:** `obj_chain_boss` (Fire variant)

**Location:** `/objects/obj_chain_boss_parent/`

### Core Chain Mechanics

#### Auxiliary Spawning

**Location:** `/objects/obj_chain_boss_parent/Create_0.gml` (lines 99-136)

**Configuration:**
```gml
auxiliary_object = obj_fire_imp;       // Object type for auxiliaries
auxiliary_count = 4;                   // Number of auxiliaries (2-5)
chain_max_length = 96;                 // Maximum chain distance (pixels)
auxiliary_dr_bonus = 2;                // DR per living auxiliary
```

**Spawn Pattern:**
Auxiliaries spawn in circular formation around boss at 50% of max chain length:

```gml
for (var i = 0; i < auxiliary_count; i++) {
    var angle = (360 / auxiliary_count) * i;
    var spawn_distance = chain_max_length * 0.5;
    var spawn_x = x + lengthdir_x(spawn_distance, angle);
    var spawn_y = y + lengthdir_y(spawn_distance, angle);

    var aux = instance_create_layer(spawn_x, spawn_y, layer, auxiliary_object);
    aux.chain_boss = id;                 // Reference to boss
    aux.chain_max_length = chain_max_length;

    array_push(auxiliaries, aux);
}
```

#### Chain Constraint Physics

**Location:** Applied in auxiliary movement calculations

**Hard Boundary Enforcement:**
```gml
// After all movement calculations, clamp position to chain radius
var dist_to_boss = point_distance(x, y, chain_boss.x, chain_boss.y);

if (dist_to_boss > chain_max_length) {
    var angle_to_boss = point_direction(chain_boss.x, chain_boss.y, x, y);
    x = chain_boss.x + lengthdir_x(chain_max_length, angle_to_boss);
    y = chain_boss.y + lengthdir_y(chain_max_length, angle_to_boss);
}
```

**Properties:**
- Constraint applied AFTER pathfinding and movement
- No rubber-banding or momentum carryover
- Pathfinding stops when boundary reached
- Prevents auxiliaries from being pulled away

#### Visual Chain Rendering

**Location:** `/objects/obj_chain_boss_parent/Draw_0.gml`

**Chain Drawing System:**
```gml
for (var i = 0; i < array_length(auxiliaries); i++) {
    var aux = auxiliaries[i];
    if (instance_exists(aux) && aux.state != EnemyState.dead) {
        draw_chain(x, y, aux.x, aux.y);
    }
}
```

**Chain Properties:**
- **Sprite:** `spr_chain` (4×8 pixel chain link)
- **Rendering:** Drawn BEFORE boss sprite (boss appears on top)
- **Sag Effect:** Parabolic curve based on tension

**Tension-Based Rendering:**
```gml
var distance = point_distance(x1, y1, x2, y2);
var tension = distance / chain_max_length;

if (tension < 0.7) {
    // Visible sag (up to 20 pixels)
    var sag_amount = 20 * (1 - tension / 0.7);
} else {
    // Taut/straight chain
    var sag_amount = 0;
}
```

### Auxiliary-Based Damage Reduction

**Location:** `/scripts/player_attack_helpers/player_attack_helpers.gml` (lines 122-130)

**Implementation:**
```gml
// In damage calculation pipeline
if (target.object_index == obj_chain_boss_parent ||
    object_is_ancestor(target.object_index, obj_chain_boss_parent)) {

    var living_auxiliaries = 0;
    for (var i = 0; i < array_length(target.auxiliaries); i++) {
        var aux = target.auxiliaries[i];
        if (instance_exists(aux) && aux.state != EnemyState.dead) {
            living_auxiliaries++;
        }
    }

    var bonus_dr = living_auxiliaries * target.auxiliary_dr_bonus;
    total_dr += bonus_dr;
}
```

**Example:**
- Boss has 4 living auxiliaries
- `auxiliary_dr_bonus = 2`
- Bonus DR = 4 × 2 = **+8 DR**

**Dynamic Scaling:**
- DR decreases as auxiliaries die
- Incentivizes player to target auxiliaries first
- Creates strategic gameplay decisions

### Death Tracking System

**Location:** `/objects/obj_enemy_parent/Destroy_0.gml`

**Notification on Auxiliary Death:**
```gml
// Check if this enemy is chained to a boss
if (chain_boss != noone && instance_exists(chain_boss)) {
    chain_boss.auxiliaries_alive--;

    // Remove from boss's auxiliary array
    for (var i = 0; i < array_length(chain_boss.auxiliaries); i++) {
        if (chain_boss.auxiliaries[i] == id) {
            array_delete(chain_boss.auxiliaries, i, 1);
            break;
        }
    }

    show_debug_message("Chain boss auxiliary died. Remaining: " +
        string(chain_boss.auxiliaries_alive));
}
```

### Boss Phases

#### Enrage Phase

**Trigger:** All auxiliaries defeated (`auxiliaries_alive == 0`)
**Location:** `/objects/obj_chain_boss_parent/Step_0.gml` (lines 8-39)

**Activation Check:**
```gml
if (auxiliaries_alive == 0 && !enraged) {
    enraged = true;

    // Apply enrage bonuses
    attack_speed *= 1.5;         // +50% attack speed
    move_speed *= 1.3;           // +30% move speed
    attack_damage *= 1.2;        // +20% melee damage
    ranged_damage *= 1.2;        // +20% ranged damage

    // Visual feedback
    image_blend = c_red;

    // Audio feedback
    if (enemy_sounds.on_enrage != undefined) {
        play_enemy_sfx("on_enrage");
    }

    show_debug_message("CHAIN BOSS ENRAGED!");
}
```

**Enrage Multipliers:**
- **Attack Speed:** ×1.5
- **Move Speed:** ×1.3
- **Damage:** ×1.2 (both melee and ranged)

**Visual:** Boss turns red (`image_blend = c_red`)

### Advanced Attack #1: Throw Attack

**Configuration:**
```gml
enable_throw_attack = true;
throw_cooldown = 300;              // 5 seconds (300 frames)
throw_windup_time = 30;            // 0.5 seconds
throw_range_min = 64;
throw_range_max = 256;
throw_projectile_speed = 4;
throw_return_speed = 3;
throw_damage = 4;                  // Fire variant
throw_damage_type = DamageType.fire;
```

#### Throw Execution Flow

**Location:** `/objects/obj_chain_boss_parent/Step_0.gml` (lines 42-125)

**Phase 1: Target Selection**
```gml
// Find available auxiliary (not stunned, not dead, idle state)
for (var i = 0; i < array_length(auxiliaries); i++) {
    var aux = auxiliaries[i];
    if (instance_exists(aux) &&
        aux.state == EnemyState.idle &&
        !aux.is_stunned &&
        aux.state != EnemyState.dead) {

        selected_auxiliary = aux;
        break;
    }
}
```

**Phase 2: Windup**
```gml
throw_state = "winding_up";
throw_windup_timer = throw_windup_time;  // 30 frames
selected_auxiliary.state = "being_thrown";

// Audio
play_sfx(snd_throw_start, 1.0);
```

**Phase 3: Launch**
```gml
throw_state = "throwing";

// Calculate throw direction toward player
var target_angle = point_direction(x, y, obj_player.x, obj_player.y);

selected_auxiliary.throw_direction = target_angle;
selected_auxiliary.throw_speed = throw_projectile_speed;  // 4 px/frame
```

**Phase 4: Flight**

**Location:** `/objects/obj_enemy_parent/Step_0.gml` (lines 51-100)

```gml
// In auxiliary Step event
if (state == "being_thrown") {
    // Move toward target
    x += lengthdir_x(throw_speed, throw_direction);
    y += lengthdir_y(throw_speed, throw_direction);

    // Check if at max chain length
    var dist_to_boss = point_distance(x, y, chain_boss.x, chain_boss.y);
    if (dist_to_boss >= chain_max_length) {
        state = "returning";
    }
}
```

**Collision Damage:**
- Auxiliary deals collision damage while flying
- Location: `/objects/obj_enemy_parent/Collision_obj_player.gml` (lines 5-28)
- Uses boss's throw damage value

**Phase 5: Return**
```gml
if (state == "returning") {
    var angle_to_boss = point_direction(x, y, chain_boss.x, chain_boss.y);
    x += lengthdir_x(throw_return_speed, angle_to_boss);  // 3 px/frame
    y += lengthdir_y(throw_return_speed, angle_to_boss);

    var dist_to_boss = point_distance(x, y, chain_boss.x, chain_boss.y);
    if (dist_to_boss < 32) {
        state = EnemyState.idle;
        chain_boss.throw_state = "none";
        chain_boss.throw_cooldown_timer = chain_boss.throw_cooldown;  // 300
    }
}
```

#### Throw State Machine

**Boss States:**
- `"none"` - Not throwing
- `"winding_up"` - Windup animation playing
- `"throwing"` - Auxiliary in flight
- `"none"` - Complete (after auxiliary returns)

**Auxiliary States:**
- `EnemyState.idle` - Available for throw
- `"being_thrown"` - Flying toward target
- `"returning"` - Flying back to boss
- `EnemyState.idle` - Returned

#### Throw Sound Effects

**snd_throw_start:**
- Plays at windup start
- Volume 1.0

**snd_throwing:**
- Looping sound during flight
- Stops on hit or return

**snd_throw_hit:**
- Plays when auxiliary hits player

### Advanced Attack #2: Spin Attack

**Configuration:**
```gml
enable_spin_attack = true;
spin_cooldown = 480;               // 8 seconds
spin_windup_time = 45;             // 0.75 seconds
spin_duration = 180;               // 3 seconds
spin_rotation_speed = 8;           // Degrees per frame
spin_range = 200;                  // Player detection range
spin_damage = 5;                   // Fire variant
spin_damage_type = DamageType.fire;
```

**Requirements:**
- Minimum 2 living auxiliaries
- Player within `spin_range`
- Cooldown expired

#### Spin Execution Flow

**Location:** `/objects/obj_chain_boss_parent/Step_0.gml` (lines 127-255)

**Phase 1: Range and Requirement Check**
```gml
if (spin_cooldown_timer <= 0 &&
    auxiliaries_alive >= 2 &&
    point_distance(x, y, obj_player.x, obj_player.y) < spin_range &&
    spin_state == "none") {

    spin_state = "winding_up";
    spin_windup_timer = spin_windup_time;  // 45 frames
    play_sfx(snd_spin_start, 1.0);
}
```

**Phase 2: Windup**
```gml
if (spin_state == "winding_up") {
    spin_windup_timer--;

    if (spin_windup_timer <= 0) {
        spin_state = "spinning";
        spin_timer = spin_duration;  // 180 frames

        // Set all living auxiliaries to spinning state
        for (var i = 0; i < array_length(auxiliaries); i++) {
            var aux = auxiliaries[i];
            if (instance_exists(aux) && aux.state != EnemyState.dead) {
                aux.state = "spinning";
            }
        }

        play_sfx(snd_spinning, 1.0, false, true);  // Looping
    }
}
```

**Phase 3: Spinning**

**Orbital Positioning Calculation (lines 192-226):**
```gml
if (spin_state == "spinning") {
    spin_timer--;

    // Update spin angle
    spin_angle += spin_rotation_speed;  // 8 degrees/frame

    // Position auxiliaries in orbit
    var living_aux_count = auxiliaries_alive;
    var angle_step = 360 / living_aux_count;
    var aux_index = 0;

    for (var i = 0; i < array_length(auxiliaries); i++) {
        var aux = auxiliaries[i];
        if (instance_exists(aux) && aux.state == "spinning") {
            var aux_angle = spin_angle + (angle_step * aux_index);

            // Position at max chain length
            aux.x = x + lengthdir_x(chain_max_length, aux_angle);
            aux.y = y + lengthdir_y(chain_max_length, aux_angle);

            aux_index++;
        }
    }

    // Check for spin completion
    if (spin_timer <= 0) {
        spin_state = "none";
        spin_cooldown_timer = spin_cooldown;  // 480 frames

        // Return auxiliaries to idle
        for (var i = 0; i < array_length(auxiliaries); i++) {
            var aux = auxiliaries[i];
            if (instance_exists(aux) && aux.state == "spinning") {
                aux.state = EnemyState.idle;
            }
        }

        audio_stop_sound(snd_spinning);
        play_sfx(snd_spin_end, 1.0);
    }
}
```

**Collision Damage:**
- Each spinning auxiliary deals collision damage
- Respects collision cooldown timers
- Uses boss's spin damage value

**Positioning:**
- Auxiliaries evenly spaced around boss
- All at max chain length (96 pixels)
- Rotate 8 degrees per frame (full rotation in 45 frames)

#### Spin State Machine

**Boss States:**
- `"none"` - Not spinning
- `"winding_up"` - Windup animation (45 frames)
- `"spinning"` - Active spin (180 frames)
- `"none"` - Complete

**Auxiliary States:**
- `EnemyState.idle` - Normal behavior
- `"spinning"` - Orbiting boss
- `EnemyState.idle` - Returned

#### Spin Sound Effects

**snd_spin_start:**
- Plays at windup start

**snd_spinning:**
- Looping sound during spin
- Auto-stopped at spin end

**snd_spin_end:**
- Plays when spin completes

### Fire Boss Variant

**Object:** `obj_chain_boss`
**Location:** `/objects/obj_chain_boss/Create_0.gml`

**Stats:**
```gml
event_inherited();  // Inherit from parent

hp = 100;
hp_total = 100;
attack_damage = 8;
move_speed = 1.2;

// Fire theme
array_push(tags, "fireborne");
apply_tag_traits();  // Fire immunity, ice vulnerability
```

**Auxiliary Configuration:**
```gml
auxiliary_object = obj_fire_imp;
auxiliary_count = 4;
chain_max_length = 96;
auxiliary_dr_bonus = 2;  // +8 DR total with 4 auxiliaries
```

**Attack Configuration:**
```gml
// Throw attack
enable_throw_attack = true;
throw_damage = 4;
throw_damage_type = DamageType.fire;

// Spin attack
enable_spin_attack = true;
spin_damage = 5;
spin_damage_type = DamageType.fire;
```

#### Fire Imp Auxiliaries

**Object:** `obj_fire_imp`
**Stats:**
```gml
hp = 8;
attack_damage = 1;
collision_damage = 2;           // Collision with player
move_speed = 0.75;
attack_range = 32;

// Fire theme
array_push(tags, "fireborne");
apply_tag_traits();
```

**Status Effects:**
```gml
attack_status_effects = [
    {trait: "burning", chance: 0.5}  // 50% to apply burning
];
```

**Loot Table:**
```gml
loot_drops = [
    {item_key: "torch", weight: 2},
    {item_key: "small_health_potion", weight: 2}
];
drop_chance = 0.4;  // 40% to drop loot
```

### Room Placement

**Room:** `room_greenwood_forest_4`
**Position:** (544, 304)
**Instance Name:** `inst_414759E4`

### Key Files Reference

| File | Purpose | Key Lines |
|------|---------|-----------|
| `/objects/obj_chain_boss_parent/Create_0.gml` | Core initialization | 99-136 |
| `/objects/obj_chain_boss_parent/Step_0.gml` | Enrage, throw, spin logic | Full file |
| `/objects/obj_chain_boss_parent/Draw_0.gml` | Chain rendering | Full file |
| `/objects/obj_chain_boss/Create_0.gml` | Fire variant config | Full file |
| `/objects/obj_fire_imp/Create_0.gml` | Auxiliary stats | Full file |
| `/objects/obj_enemy_parent/Step_0.gml` | Auxiliary throw/spin states | 51-100 |
| `/objects/obj_enemy_parent/Destroy_0.gml` | Death notification | Full file |
| `/objects/obj_enemy_parent/Collision_obj_player.gml` | Throw collision damage | 5-28 |
| `/scripts/player_attack_helpers/player_attack_helpers.gml` | Auxiliary DR bonus | 122-130 |

---

## Hazard Spawning System

### Overview

The Hazard Spawning system provides a projectile-based delivery mechanism for persistent area-of-effect hazards. Primarily used by boss enemies, it features visual telegraphing, range-based damage scaling, optional explosions, and layered damage opportunities.

### System Components

1. **obj_hazard_parent** - Base persistent hazard (fire, poison, etc.)
2. **obj_hazard_projectile** - Delivery projectile
3. **obj_hazard_target_indicator** - Visual telegraph
4. **obj_explosion** - Optional explosion effect
5. **EnemyState.hazard_spawning** - Enemy state machine

### Hazard Types

#### Fire Hazard (obj_fire)

**Location:** `/objects/obj_fire/Create_0.gml`

**Configuration:**
```gml
event_inherited();  // From obj_hazard_parent

damage_mode = "continuous";      // Tick-based damage
damage_amount = 0;               // Configurable
damage_type = DamageType.fire;
damage_interval = 0.5;           // Seconds between ticks
damage_immunity_duration = 0.5;  // Seconds of immunity

effect_mode = "status";
effect_name = "burning";
effect_application = "on_enter";

// Immunity traits
immunity_traits = ["fire_immunity", "ground_hazard_immunity"];

// Visual
sprite_index = spr_fire;
image_speed = 0.3;               // 4-frame animation
depth = 100;                     // Behind entities
```

#### Poison Hazard (obj_poison)

**Location:** `/objects/obj_poison/Create_0.gml`

**Configuration:**
```gml
event_inherited();

damage_mode = "none";            // Status-only
effect_mode = "status";
effect_name = "poisoned";
effect_application = "on_enter";

immunity_traits = ["poison_immunity", "ground_hazard_immunity"];

sprite_index = spr_poison_pool;
image_speed = 0.2;
depth = 100;
```

### Hazard Parent System

**Object:** `obj_hazard_parent`
**Parent:** `obj_persistent_parent` (for save/load)

**Location:** `/objects/obj_hazard_parent/`

#### Configuration Options

**Damage Modes:**
- `"none"` - No direct damage (effect-only hazards)
- `"continuous"` - Tick-based damage every `damage_interval` seconds
- `"on_enter"` - One-time damage when entity enters

**Effect Modes:**
- `"none"` - No effects
- `"trait"` - Applies timed trait (fire_resistance, etc.)
- `"status"` - Applies status effect (burning, poisoned, slowed)

**Effect Application:**
- `"on_enter"` - Applied once when entering
- `"continuous"` - Applied every tick (with cooldown)

#### Entity Tracking

**Data Structures:**
```gml
entities_inside = ds_list_create();           // Entities currently in hazard
damage_immunity_map = ds_map_create();        // Per-entity damage timers
effect_immunity_map = ds_map_create();        // Per-entity effect timers
```

**Automatic Cleanup:**
- Entities removed from lists when they exit collision
- Dead entities removed from tracking
- Maps cleaned up when entities destroyed

#### Damage Pipeline (Continuous Mode)

**Location:** `/objects/obj_hazard_parent/Step_0.gml`

```gml
// Check if damage interval elapsed
if (damage_interval_timer >= damage_interval) {
    damage_interval_timer = 0;

    // For each entity in hazard
    for (var i = 0; i < ds_list_size(entities_inside); i++) {
        var entity = ds_list_find_value(entities_inside, i);

        if (!instance_exists(entity)) continue;

        // Check damage immunity
        var immunity_timer = damage_immunity_map[? entity];
        if (immunity_timer != undefined && immunity_timer > 0) continue;

        // Calculate damage with modifiers
        var trait_modifier = entity.get_damage_modifier_for_type(damage_type);
        var equipment_dr = entity.get_equipment_general_dr();
        var companion_dr = entity.get_companion_dr_bonus();
        var total_dr = equipment_dr + companion_dr;

        // Apply defense trait modifiers (bolstered/sundered)
        var defense_modifier = entity.get_defense_trait_modifier();
        total_dr *= defense_modifier;

        // Final damage calculation
        var final_damage = max(1, (damage_amount * trait_modifier) - total_dr);

        // Apply damage
        entity.hp -= final_damage;

        // Visual feedback
        entity.image_blend = c_red;
        spawn_damage_number(entity.x, entity.y - 16, final_damage, damage_type);

        // Set immunity timer
        damage_immunity_map[? entity] = damage_immunity_duration;

        // Check for death
        if (entity.hp <= 0 && entity.object_index == obj_player) {
            // Handle player death
        }
    }
}

// Countdown immunity timers
var keys = ds_map_keys_to_array(damage_immunity_map);
for (var i = 0; i < array_length(keys); i++) {
    var timer = damage_immunity_map[? keys[i]];
    if (timer > 0) {
        damage_immunity_map[? keys[i]] = timer - (1 / game_get_speed(gamespeed_fps));
    }
}
```

#### Collision Detection

**Location:** `/objects/obj_hazard_parent/Collision_obj_player.gml`

```gml
// Add player to tracking if not already present
if (ds_list_find_index(entities_inside, other.id) == -1) {
    ds_list_add(entities_inside, other.id);

    // Apply on-enter effects
    if (effect_application == "on_enter") {
        if (effect_mode == "status") {
            other.apply_status_effect(effect_name);
        } else if (effect_mode == "trait") {
            other.apply_timed_trait(effect_name, effect_duration);
        }
    }

    // Apply on-enter damage
    if (damage_mode == "on_enter") {
        // Apply damage with full pipeline
    }
}
```

**Exit Detection:**
Checked each frame - if entity no longer colliding, remove from list.

#### Serialization Support

**Location:** `/objects/obj_hazard_parent/Create_0.gml`

```gml
function serialize() {
    return {
        x: x,
        y: y,
        damage_mode: damage_mode,
        damage_amount: damage_amount,
        damage_type: damage_type,
        damage_interval: damage_interval,
        effect_mode: effect_mode,
        effect_name: effect_name,
        lifetime: lifetime,
        sprite_index: sprite_index
        // Note: Does NOT serialize temporary state (entities, timers)
    };
}

function deserialize(_data) {
    x = _data.x;
    y = _data.y;
    damage_mode = _data.damage_mode;
    // ... restore all properties
}
```

### Hazard Projectile System

**Object:** `obj_hazard_projectile`
**Location:** `/objects/obj_hazard_projectile/`

#### Configuration Variables

```gml
// Movement
move_speed = 3;                  // Pixels per frame
direction = 0;                   // Angle in degrees
travel_distance = 128;           // Max distance before landing

// Damage
damage_amount = 2;
damage_type = DamageType.physical;
attack_category = AttackCategory.ranged;
status_effects_on_hit = [];      // Array of status effects

// Hazard spawning
hazard_object = obj_fire;
hazard_lifetime = -1;            // Seconds (-1 = permanent)
hazard_spawned = false;

// Explosion (optional)
explosion_enabled = false;
explosion_object = obj_explosion;
explosion_damage = 3;
explosion_damage_type = DamageType.fire;

// Tracking
spawn_x = x;
spawn_y = y;
distance_travelled = 0;

// Range profile
range_profile_id = RangeProfile.hazard_projectile;
current_damage_multiplier = 1.0;
```

#### Movement and Collision

**Location:** `/objects/obj_hazard_projectile/Step_0.gml`

**Step Logic:**
```gml
// 1. Update depth for rendering
depth = -y;

// 2. Move in direction
x += lengthdir_x(move_speed, direction);
y += lengthdir_y(move_speed, direction);

// 3. Calculate distance traveled
distance_travelled = point_distance(spawn_x, spawn_y, x, y);

// 4. Update range multiplier
current_damage_multiplier = projectile_calculate_damage_multiplier(
    range_profile_id,
    distance_travelled
);

// 5. Check if reached travel distance
if (distance_travelled >= travel_distance) {
    spawn_hazard();
    instance_destroy();
    exit;
}

// 6. Wall collision check
var _tilemap_col = layer_tilemap_get_id("Tiles_Col");
if (_tilemap_col != -1) {
    var _tile_value = tilemap_get_at_pixel(_tilemap_col, x, y);
    if (_tile_value != 0) {
        play_sfx(snd_bump, 0.8);
        spawn_hazard();
        instance_destroy();
        exit;
    }
}

// 7. Out of bounds check
if (x < 0 || x > room_width || y < 0 || y > room_height) {
    instance_destroy();
    exit;
}

// 8. Auto-cull beyond max range
var max_distance = get_range_profile_max_distance(range_profile_id);
var overshoot = get_range_profile_overshoot_buffer(range_profile_id);
if (distance_travelled > max_distance + overshoot) {
    instance_destroy();
    exit;
}
```

#### Player Collision

**Location:** `/objects/obj_hazard_projectile/Collision_obj_player.gml`

```gml
// Calculate damage with trait modifier
var trait_modifier = other.get_damage_modifier_for_type(damage_type);
var base_damage = damage_amount * current_damage_multiplier;
var modified_damage = base_damage * trait_modifier;

// Apply equipment and companion DR
var equipment_dr = other.get_equipment_ranged_dr();
var companion_dr = other.get_companion_dr_bonus();
var total_dr = equipment_dr + companion_dr;

// Apply defense trait modifier
var defense_modifier = other.get_defense_trait_modifier();
total_dr *= defense_modifier;

// Final damage (minimum 1 chip damage)
var final_damage = max(1, modified_damage - total_dr);

// Apply damage
other.hp -= final_damage;

// Knockback
var kb_strength = 2;
other.kb_x = sign(other.x - x) * kb_strength;
other.kb_y = sign(other.y - y) * kb_strength;

// Visual feedback
other.image_blend = c_red;
spawn_damage_number(other.x, other.y - 16, final_damage, damage_type);

// Apply status effects
for (var i = 0; i < array_length(status_effects_on_hit); i++) {
    var effect = status_effects_on_hit[i];
    other.apply_status_effect(effect.trait);
}

// Spawn hazard at collision point
spawn_hazard();

// Destroy projectile
instance_destroy();
```

#### Hazard Spawning Function

```gml
function spawn_hazard() {
    if (hazard_spawned) return;  // Prevent duplicates
    hazard_spawned = true;

    if (hazard_object != noone) {
        var hazard = instance_create_layer(x, y, layer, hazard_object);

        // Configure hazard
        hazard.damage_amount = damage_amount * current_damage_multiplier;
        hazard.creator = creator;

        // Set lifetime
        if (hazard_lifetime > 0) {
            hazard.lifetime = hazard_lifetime;
            hazard.alarm[0] = hazard_lifetime * game_get_speed(gamespeed_fps);
        }
    }

    // Spawn explosion if enabled
    if (explosion_enabled && explosion_object != noone) {
        var explosion = instance_create_layer(x, y, layer, explosion_object);
        explosion.damage_amount = explosion_damage * current_damage_multiplier;
        explosion.damage_type = explosion_damage_type;
        explosion.creator = creator;
    }
}
```

### Range Profile System

**Location:** `/scripts/scr_projectile_range_profiles/scr_projectile_range_profiles.gml`

#### Hazard Projectile Profile

```gml
case RangeProfile.hazard_projectile:
    return {
        point_blank_distance: 48,
        point_blank_multiplier: 0.6,
        optimal_start: 60,
        optimal_end: 140,
        max_distance: 200,
        long_range_multiplier: 0.5,
        overshoot_buffer: 32
    };
```

**Damage Curve:**
- **0-48px:** Ramps from 0.6x → 1.0x (linear interpolation)
- **60-140px:** Full damage (1.0x multiplier)
- **140-200px:** Falls from 1.0x → 0.5x (linear falloff)
- **200-232px:** Grace period before auto-cull

**Calculation Function:**
```gml
function projectile_calculate_damage_multiplier(_profile_id, _distance) {
    var profile = get_range_profile(_profile_id);

    // Point blank zone
    if (_distance < profile.point_blank_distance) {
        var t = _distance / profile.point_blank_distance;
        return lerp(profile.point_blank_multiplier, 1.0, t);
    }

    // Optimal zone
    if (_distance >= profile.optimal_start &&
        _distance <= profile.optimal_end) {
        return 1.0;
    }

    // Long range falloff
    if (_distance > profile.optimal_end) {
        var falloff_distance = profile.max_distance - profile.optimal_end;
        var distance_into_falloff = _distance - profile.optimal_end;
        var t = min(1.0, distance_into_falloff / falloff_distance);
        return lerp(1.0, profile.long_range_multiplier, t);
    }

    return 1.0;
}
```

### Explosion System

**Object:** `obj_explosion`
**Location:** `/objects/obj_explosion/`

#### Configuration

```gml
// Damage
damage_amount = 3;
damage_type = DamageType.fire;
creator = noone;
has_damaged = false;         // One-hit flag

// Visual
sprite_index = spr_explosion;
image_speed = 0.5;           // 4-frame animation
depth = -y - 1;              // Above projectile

// Audio
play_sfx(snd_explosion, 1.0);
```

#### Behavior

**Step Event:**
```gml
// Check if animation complete
if (image_index >= image_number - 1) {
    instance_destroy();
}
```

**Player Collision:**
```gml
if (!has_damaged) {
    has_damaged = true;

    // Calculate damage (same pipeline as projectile)
    var trait_modifier = other.get_damage_modifier_for_type(damage_type);
    var equipment_dr = other.get_equipment_ranged_dr();
    var companion_dr = other.get_companion_dr_bonus();
    var total_dr = (equipment_dr + companion_dr) *
                    other.get_defense_trait_modifier();

    var final_damage = max(1, (damage_amount * trait_modifier) - total_dr);

    // Apply damage
    other.hp -= final_damage;

    // Knockback (stronger than projectile)
    var kb_strength = 3;
    var angle = point_direction(x, y, other.x, other.y);
    other.kb_x = lengthdir_x(kb_strength, angle);
    other.kb_y = lengthdir_y(kb_strength, angle);

    // Visual feedback
    other.image_blend = c_red;
    spawn_damage_number(other.x, other.y - 16, final_damage, damage_type);
}
```

### Visual Telegraph System

**Object:** `obj_hazard_target_indicator`
**Location:** `/objects/obj_hazard_target_indicator/`

**Configuration:**
```gml
sprite_index = spr_target;
image_speed = 0.2;           // 4-frame looping animation
image_alpha = 1.0;
depth = -9999;               // Above everything
```

**Purpose:**
- Shows where hazard will land
- Created during windup phase
- Positioned at player's location at windup start
- Does NOT track player during windup (intentional)
- Destroyed when projectile spawns

**Gameplay Value:**
- Gives player reaction time (~0.5-0.8 seconds)
- Allows skilled players to dodge
- Maintains fairness in boss encounters

### Enemy Integration

#### Configuration Variables

**Location:** `/objects/obj_enemy_parent/Create_0.gml` (lines 110-139)

```gml
// Master toggle
enable_hazard_spawning = false;
allow_multi_attack = false;      // Boss multi-attack system

// Timing
hazard_spawn_cooldown = 180;              // 3 seconds (180 frames)
hazard_spawn_cooldown_timer = 0;
hazard_spawn_windup_time = 30;            // 0.5 seconds (30 frames)
hazard_spawn_windup_timer = 30;

// Projectile
hazard_projectile_object = obj_hazard_projectile;
hazard_projectile_distance = 128;         // Travel distance
hazard_projectile_speed = 3;              // Pixels per frame
hazard_projectile_damage = 2;
hazard_projectile_damage_type = DamageType.fire;
hazard_projectile_direction_offset = 0;   // Angle offset

// Hazard
hazard_spawn_object = obj_fire;
hazard_status_effects = [];
hazard_lifetime = -1;                     // -1 = permanent

// Explosion
hazard_explosion_enabled = false;
hazard_explosion_object = obj_explosion;
hazard_explosion_damage = 3;
hazard_explosion_damage_type = DamageType.fire;
```

#### State Machine

**State:** `EnemyState.hazard_spawning`
**Location:** `/scripts/scr_enemy_state_hazard_spawning/scr_enemy_state_hazard_spawning.gml`

**Phase 1: Windup**
```gml
// Stop movement
target_x = x;
target_y = y;
path_end();

// First frame of windup
if (hazard_spawn_windup_timer == hazard_spawn_windup_time) {
    // Play sounds
    play_enemy_sfx("on_hazard_vocalize");  // Monster roar
    play_enemy_sfx("on_hazard_windup");    // Casting sound

    // Create target indicator at player position
    hazard_target_indicator = instance_create_layer(
        obj_player.x,
        obj_player.y,
        layer,
        obj_hazard_target_indicator
    );

    // Store target position (doesn't update during windup)
    hazard_target_x = obj_player.x;
    hazard_target_y = obj_player.y;
}

// Countdown
hazard_spawn_windup_timer--;
```

**Phase 2: Spawn Projectile**
```gml
// When timer reaches 0
if (hazard_spawn_windup_timer == 0) {
    spawn_hazard_projectile();

    // Cleanup
    hazard_spawn_windup_timer = -1;
    if (instance_exists(hazard_target_indicator)) {
        instance_destroy(hazard_target_indicator);
    }

    // Start cooldown
    hazard_spawn_cooldown_timer = hazard_spawn_cooldown;

    // Brief delay before state transition
    alarm[5] = 10;
}
```

**Phase 3: Return to Targeting**
```gml
// In Alarm[5]
if (event_number == 5) {
    hazard_spawn_windup_timer = hazard_spawn_windup_time;
    state = EnemyState.targeting;
}
```

#### Projectile Spawning Function

**Location:** Lines 70-117 in `scr_enemy_state_hazard_spawning.gml`

```gml
function spawn_hazard_projectile() {
    // Use stored target position (from windup start)
    var target_x = hazard_target_x;
    var target_y = hazard_target_y;

    // Calculate angle to target
    var angle = point_direction(x, y, target_x, target_y);
    angle += hazard_projectile_direction_offset;

    // Spawn position (16 pixels in front of enemy)
    var spawn_x = x + lengthdir_x(16, angle);
    var spawn_y = y + lengthdir_y(16, angle);

    // Calculate distance to target
    var distance_to_target = point_distance(x, y, target_x, target_y);

    // Create projectile
    var projectile = instance_create_layer(
        spawn_x,
        spawn_y,
        layer,
        hazard_projectile_object
    );

    // Configure projectile
    projectile.creator = id;
    projectile.direction = angle;
    projectile.image_angle = angle;
    projectile.move_speed = hazard_projectile_speed;
    projectile.travel_distance = distance_to_target;
    projectile.damage_amount = hazard_projectile_damage;
    projectile.damage_type = hazard_projectile_damage_type;
    projectile.hazard_object = hazard_spawn_object;
    projectile.hazard_lifetime = hazard_lifetime;

    // Explosion configuration
    if (hazard_explosion_enabled) {
        projectile.explosion_enabled = true;
        projectile.explosion_object = hazard_explosion_object;
        projectile.explosion_damage = hazard_explosion_damage;
        projectile.explosion_damage_type = hazard_explosion_damage_type;
    }

    // Status effects
    if (array_length(hazard_status_effects) > 0) {
        projectile.status_effects_on_hit = hazard_status_effects;
    }
}
```

### Movement Profile Integration

**Location:** `/scripts/movement_profile_hazard_spawner_update/movement_profile_hazard_spawner_update.gml`

**Behavior Pattern:**
```gml
// Beyond ideal_range: Move slowly toward player
if (dist_to_player > ideal_range) {
    move_speed_modifier = 0.6;  // 60% speed
    move_toward_player();
}

// Within ideal_range: Stop and prepare hazard
if (dist_to_player <= ideal_range) {
    target_x = x;
    target_y = y;

    // Check if can spawn hazard
    if (enable_hazard_spawning &&
        hazard_spawn_cooldown_timer <= 0 &&
        state == EnemyState.targeting &&
        enemy_has_line_of_sight()) {

        state = EnemyState.hazard_spawning;
        hazard_spawn_windup_timer = hazard_spawn_windup_time;
    }
}
```

**Never Retreats:** Unlike ranged enemies, hazard spawners maintain their position

### Fire Boss Integration

**Object:** `obj_fire_boss`
**Location:** `/objects/obj_fire_boss/Create_0.gml`

#### Multi-Attack System

```gml
// Enable multiple attack types
enable_dual_mode = true;               // Melee + ranged
enable_hazard_spawning = true;         // Hazard attacks
allow_multi_attack = true;             // Boss-specific system
```

**Attack Cooldowns:**
| Attack Type | Cooldown | Priority |
|-------------|----------|----------|
| Melee       | ~90 frames (1.5s) | 30 (default) |
| Ranged      | ~180 frames (3s) | 30 (default) |
| Hazard      | 480 frames (8s) | **40** (higher) |

**Priority System:**
- Higher priority = more likely to be chosen
- Hazard attacks prioritized when available
- Creates varied boss combat patterns

#### Hazard Configuration

```gml
hazard_spawn_cooldown = 480;           // 8 seconds
hazard_priority = 40;                  // Weight 40 (vs 30 default)
hazard_spawn_windup_time = 50;         // 0.83 seconds
hazard_projectile_speed = 4;           // Fast projectile
hazard_projectile_damage = 3;          // High damage
hazard_projectile_damage_type = DamageType.fire;
hazard_spawn_object = obj_fire;
hazard_lifetime = 5;                   // 5 seconds (not permanent)

// Status effects
hazard_status_effects = [
    {trait: "burning"}                 // Apply burning on hit
];

// Explosion disabled for fire boss
hazard_explosion_enabled = false;
```

#### Sound Configuration

```gml
enemy_sounds.on_hazard_vocalize = snd_fire_boss_roar;  // Monster roar
enemy_sounds.on_hazard_windup = snd_fire_boss_cast;    // Casting sound
```

#### Positioning

```gml
ideal_range = 120;                     // Medium distance
retreat_when_close = false;            // Aggressive positioning
```

### Layered Damage System

**Three Damage Opportunities:**

1. **Projectile Collision**
   - Damage on direct hit with player
   - Uses ranged DR calculation
   - Range multiplier applied

2. **Explosion (Optional)**
   - AOE damage at landing point
   - Uses ranged DR calculation
   - Stronger knockback (3 pixels vs 2)

3. **Persistent Hazard**
   - Continuous tick damage
   - Uses general DR + trait modifiers
   - Can affect multiple entities
   - Duration based on `hazard_lifetime`

**Maximum Damage Scenario:**
Player hit by all three in sequence:
- Projectile hit: 3 damage (with range multiplier)
- Explosion: 3 damage
- Hazard ticks: 0 damage × 10 ticks (over 5 seconds)
- **Total:** ~6 damage from single hazard spawn

### Key Files Reference

| File | Purpose | Key Lines |
|------|---------|-----------|
| `/objects/obj_hazard_parent/` | Base hazard system | Full folder |
| `/objects/obj_hazard_projectile/` | Projectile delivery | Full folder |
| `/objects/obj_hazard_target_indicator/` | Visual telegraph | Full folder |
| `/objects/obj_explosion/` | Explosion effect | Full folder |
| `/objects/obj_fire/Create_0.gml` | Fire hazard config | Full file |
| `/objects/obj_poison/Create_0.gml` | Poison hazard config | Full file |
| `/objects/obj_fire_boss/Create_0.gml` | Boss integration | Full file |
| `/scripts/scr_enemy_state_hazard_spawning/scr_enemy_state_hazard_spawning.gml` | State machine | Full file |
| `/scripts/movement_profile_hazard_spawner_update/movement_profile_hazard_spawner_update.gml` | Movement AI | Full file |
| `/scripts/scr_projectile_range_profiles/scr_projectile_range_profiles.gml` | Range profiles | Full file |
| `/scripts/scr_hazard_tests/scr_hazard_tests.gml` | Test suite | Full file |

---

*Last Updated: 2025-10-16*
