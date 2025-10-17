# Companion System - Technical Documentation

This document provides comprehensive technical documentation for the companion gameplay systems in Shadow Work, including states, evasion, affinity scaling, triggers, and animation.

---

## Table of Contents

1. [Companion States](#companion-states)
2. [Combat Evasion Behavior](#combat-evasion-behavior)
3. [Affinity System & Aura Scaling](#affinity-system--aura-scaling)
4. [Trigger System](#trigger-system)
5. [Companion Animation](#companion-animation)

---

## Companion States

Companions use a state machine to control their behavior relative to the player.

**Location:** `/objects/obj_companion_parent/Step_0.gml`

### CompanionState Enum

```gml
enum CompanionState {
    waiting,    // Not recruited, at spawn position
    following,  // Following player (default after recruitment)
    casting,    // Performing trigger animation
    evading     // Maintaining distance from combat
}
```

**Location:** `/scripts/scr_enums/scr_enums.gml`

### State Descriptions

#### waiting

**Purpose:** Companion has not been recruited yet

**Behavior:**
- Stand at spawn position
- Play idle animation
- Wait for player interaction to recruit
- Transition to `following` when recruited

**Recruitment:**
```gml
// In companion dialogue or interaction
function recruit_companion(companion_id) {
    var companion = instance_find(obj_companion_parent, companion_id);
    if (companion != noone) {
        companion.state = CompanionState.following;
        companion.is_recruited = true;

        // Add to player's companion list
        array_push(obj_player.companions, companion);

        // Track for quest objectives
        quest_check_objective_progress("recruit_companion", companion.object_index);
    }
}
```

**Location:** `/scripts/scr_companion_system/scr_companion_system.gml`

#### following

**Purpose:** Companion follows player during exploration

**Behavior:**
- Follow player with offset
- Maintain follow distance (32-48 pixels)
- Avoid overlapping with player
- Match player's movement speed
- Automatically switch to `evading` when combat starts

**Following Logic:**
```gml
// In CompanionState.following
var follow_distance = 40;
var dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);

if (dist_to_player > follow_distance) {
    // Move toward player
    var angle_to_player = point_direction(x, y, obj_player.x, obj_player.y);
    x += lengthdir_x(move_speed, angle_to_player);
    y += lengthdir_y(move_speed, angle_to_player);
}

// Check if player entered combat
if (obj_player.combat_timer < obj_player.combat_cooldown) {
    state = CompanionState.evading;
    evade_recheck_timer = 0;
}
```

**Location:** `/objects/obj_companion_parent/Step_0.gml` (lines 45-89)

#### casting

**Purpose:** Companion is performing trigger ability

**Behavior:**
- Play casting animation (3 frames × 200ms = 600ms)
- Cannot move during cast
- Apply trigger effect when animation completes
- Return to previous state (following or evading)

**Casting Flow:**
```gml
case CompanionState.casting:
    // Increment animation frame
    cast_anim_frame += 0.005;

    // Check if animation complete
    if (cast_anim_frame >= 3) {
        cast_anim_frame = 0;
        state = previous_state;  // Return to following or evading

        // Trigger effect already applied when state entered
    }
    break;
```

**Location:** `/objects/obj_companion_parent/Step_0.gml` (lines 135-152)

#### evading

**Purpose:** Companion maintains safe distance during combat

**Behavior:**
- Stay 64-128 pixels away from player
- Avoid enemies within 200 pixel radius
- Recalculate position every 20 frames
- Check every 0.5 seconds if combat ended
- Return to `following` 0.5 seconds after combat ends (hysteresis)

**Location:** `/objects/obj_companion_parent/Step_0.gml` (lines 91-133)

---

## Combat Evasion Behavior

When player enters combat, companions automatically evade to avoid being hit.

**Location:** `/objects/obj_companion_parent/Step_0.gml` (lines 91-133)

### Activation

```gml
// Triggered when player enters combat
if (obj_player.combat_timer < obj_player.combat_cooldown) {
    state = CompanionState.evading;
    evade_recheck_timer = 0;
}
```

**Player Combat Detection:**
- `combat_timer` starts counting when player attacks or is hit
- `combat_cooldown` is typically 180 frames (3 seconds)
- While `combat_timer < combat_cooldown`, player is "in combat"

### Distance Maintenance

```gml
// Maintain 64-128 pixel distance from player
var evade_min_distance = 64;
var evade_max_distance = 128;
var dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);

if (dist_to_player < evade_min_distance) {
    // Too close, move away
    move_away_from_player();
} else if (dist_to_player > evade_max_distance) {
    // Too far, move closer
    move_toward_player();
}
```

### Enemy Avoidance

```gml
// Find nearby enemies
var nearby_enemies = [];
with (obj_enemy_parent) {
    if (point_distance(x, y, other.x, other.y) < 200) {
        array_push(nearby_enemies, id);
    }
}

// Calculate avoidance vector
var avoid_x = 0;
var avoid_y = 0;

for (var i = 0; i < array_length(nearby_enemies); i++) {
    var enemy = nearby_enemies[i];
    var angle_away = point_direction(enemy.x, enemy.y, x, y);
    var enemy_dist = point_distance(x, y, enemy.x, enemy.y);
    var influence = 1.0 - (enemy_dist / 200);  // Stronger when closer

    avoid_x += lengthdir_x(influence * move_speed * 2, angle_away);
    avoid_y += lengthdir_y(influence * move_speed * 2, angle_away);
}

// Apply avoidance
x += avoid_x;
y += avoid_y;
```

### Recalculation Throttle

```gml
evade_recheck_timer++;

if (evade_recheck_timer >= 20) {  // Every 20 frames (~333ms)
    evade_recheck_timer = 0;

    // Recalculate ideal evade position
    calculate_evade_position();
}
```

**Purpose:** Prevents excessive calculations and erratic movement

### Return to Following (Hysteresis)

```gml
// Check every 0.5 seconds if combat ended
if (evade_recheck_timer == 0) {
    if (obj_player.combat_timer >= obj_player.combat_cooldown) {
        // Combat ended, but wait 0.5 seconds before returning
        if (evade_return_delay <= 0) {
            state = CompanionState.following;
            evade_return_delay = 30;  // Reset delay
        } else {
            evade_return_delay--;
        }
    } else {
        // Still in combat, reset delay
        evade_return_delay = 30;
    }
}
```

**Hysteresis Buffer:**
- 0.5 second delay before returning to following
- Prevents rapid state flickering at end of combat
- Creates smooth transition feel

---

## Affinity System & Aura Scaling

Companion auras and bonuses scale with affinity level.

**Location:** `/scripts/scr_companion_system/scr_companion_system.gml`

### Affinity Range

```gml
// Affinity scale: 3.0 to 10.0
min_affinity = 3.0;  // Recruited baseline
max_affinity = 10.0;  // Maximum affection
```

**Affinity Milestones:**
- **0-2.9**: Cannot recruit
- **3.0**: Recruitment threshold
- **5.0**: Mid trigger unlocked, rival acceptance threshold
- **8.0**: Advanced trigger unlocked, romantic quest unlocked
- **10.0**: Ultimate trigger unlocked, secret endings available

### Scaling Multiplier Formula

```gml
function get_affinity_multiplier(affinity) {
    // Ensure affinity is in valid range
    affinity = clamp(affinity, 3.0, 10.0);

    // Normalized affinity (0.0 to 1.0)
    var normalized = (affinity - 3.0) / 7.0;

    // Square root for diminishing returns
    var sqrt_normalized = sqrt(normalized);

    // Final multiplier: 0.6x at affinity 3.0, 3.0x at affinity 10.0
    return 0.6 + (2.4 * sqrt_normalized);
}
```

**Multiplier by Affinity:**

| Affinity | Normalized | Sqrt | Multiplier |
|----------|------------|------|------------|
| 3.0      | 0.0        | 0.0  | 0.6x       |
| 4.0      | 0.14       | 0.38 | 1.51x      |
| 5.0      | 0.29       | 0.54 | 1.89x      |
| 6.0      | 0.43       | 0.66 | 2.18x      |
| 7.0      | 0.57       | 0.76 | 2.42x      |
| 8.0      | 0.71       | 0.85 | 2.64x      |
| 9.0      | 0.86       | 0.93 | 2.83x      |
| 10.0     | 1.0        | 1.0  | 3.0x       |

**Design:** Square root provides stronger early gains, encouraging affinity investment.

### Aura Scaling Examples

```gml
// Canopy's Guardian Shield
base_dr_bonus = 2;
max_dr_bonus = 10;
var multiplier = get_affinity_multiplier(canopy_affinity);
var scaled_dr = base_dr_bonus + ((max_dr_bonus - base_dr_bonus) * ((multiplier - 0.6) / 2.4));
// Affinity 3.0: +2 DR
// Affinity 10.0: +10 DR

// Yorna's Warriors Presence
base_attack_bonus = 1;
max_attack_bonus = 5;
var multiplier = get_affinity_multiplier(yorna_affinity);
var scaled_attack = base_attack_bonus + ((max_attack_bonus - base_attack_bonus) * ((multiplier - 0.6) / 2.4));
// Affinity 3.0: +1 damage
// Affinity 10.0: +5 damage

// Hola's Slipstream
base_cooldown_reduction = 0.1;  // 10%
max_cooldown_reduction = 0.3;   // 30%
var multiplier = get_affinity_multiplier(hola_affinity);
var scaled_reduction = base_cooldown_reduction + ((max_cooldown_reduction - base_cooldown_reduction) * ((multiplier - 0.6) / 2.4));
// Affinity 3.0: -10% dash cooldown
// Affinity 10.0: -30% dash cooldown
```

---

## Trigger System

Companions have active abilities (triggers) that activate under specific conditions.

**Location:** `/objects/obj_companion_parent/Step_0.gml` (lines 154-280)

### Trigger Types

Companions have up to 4 triggers based on affinity:

```gml
// Trigger unlock thresholds
base_trigger_affinity = 0.0;       // Always available (if implemented)
mid_trigger_affinity = 5.0;        // Unlocks at affinity 5+
advanced_trigger_affinity = 8.0;   // Unlocks at affinity 8+
ultimate_trigger_affinity = 10.0;  // Unlocks at affinity 10
```

### Trigger Activation Conditions

```gml
// Check if trigger is unlocked
if (affinity < trigger.required_affinity) return false;

// Check cooldown
if (trigger_cooldown > 0) return false;

// Check player HP threshold
var player_hp_percent = obj_player.hp / obj_player.hp_total;
if (player_hp_percent > trigger.hp_threshold) return false;

// Additional conditions (distance, state, etc.)
if (!trigger.condition_check()) return false;

// All conditions met, activate trigger
activate_trigger(trigger_id);
```

### Trigger Activation Flow

```gml
function activate_trigger(trigger_id) {
    // 1. Save previous state
    previous_state = state;

    // 2. Enter casting state
    state = CompanionState.casting;
    cast_anim_frame = 0;

    // 3. Apply trigger effect immediately
    apply_trigger_effect(trigger_id);

    // 4. Play sound
    play_sfx(trigger_sound, 1.0);

    // 5. Start cooldown
    trigger_cooldown = trigger_cooldown_max;
}
```

### Example Triggers

#### Canopy's Guardian Shield

**Type:** Defensive DR boost

**Configuration:**
```gml
trigger = {
    required_affinity: 0.0,  // Base trigger
    hp_threshold: 0.5,       // Activates when player below 50% HP
    cooldown: 300,           // 5 seconds
    effect_type: "dr_boost",
    base_dr: 5,
    scaled_dr: 15,           // At max affinity
    duration: 3.0            // 3 seconds
};
```

**Effect:**
```gml
// Add temporary DR to player
var multiplier = get_affinity_multiplier(affinity);
var scaled_dr = lerp(trigger.base_dr, trigger.scaled_dr, (multiplier - 0.6) / 2.4);

obj_player.apply_timed_trait("companion_dr_boost", trigger.duration, scaled_dr);
```

#### Canopy's Dash Mend

**Type:** Reactive heal on player dash

**Configuration:**
```gml
trigger = {
    required_affinity: 5.0,  // Mid trigger
    cooldown: 120,           // 2 seconds
    effect_type: "heal",
    base_heal: 2,
    scaled_heal: 6,          // At max affinity
    proc_chance: 0.3         // 30% chance
};
```

**Effect:**
```gml
// Called from companion_on_player_dash()
if (random(1.0) < trigger.proc_chance) {
    var multiplier = get_affinity_multiplier(affinity);
    var scaled_heal = lerp(trigger.base_heal, trigger.scaled_heal, (multiplier - 0.6) / 2.4);

    obj_player.hp = min(obj_player.hp_total, obj_player.hp + scaled_heal);
    spawn_heal_effect(obj_player.x, obj_player.y, scaled_heal);

    trigger_cooldown = trigger.cooldown;
}
```

#### Yorna's Battle Fury

**Type:** Damage buff when low HP

**Configuration:**
```gml
trigger = {
    required_affinity: 8.0,  // Advanced trigger
    hp_threshold: 0.25,      // Activates when player below 25% HP
    cooldown: 480,           // 8 seconds
    effect_type: "damage_buff",
    damage_multiplier: 1.5,  // +50% damage
    duration: 5.0            // 5 seconds
};
```

**Effect:**
```gml
// Apply empowered status
obj_player.apply_status_effect("empowered");

// Visual effect
activate_slowmo(0.5);  // 0.5 second bullet-time
spawn_aura_effect(obj_player.x, obj_player.y, c_red);
```

### Trigger Cooldown

```gml
// In companion Step event
if (trigger_cooldown > 0) {
    trigger_cooldown--;
}

// Can also be reduced by frame time for second-based cooldown
if (trigger_cooldown > 0) {
    trigger_cooldown -= 1 / game_get_speed(gamespeed_fps);
}
```

---

## Companion Animation

Companions use an 18-frame sprite layout with manual animation control.

**Location:** `/objects/obj_companion_parent/Step_0.gml` (animation handling)

### 18-Frame Layout

```gml
// Idle animations (2 frames each direction)
idle_down:  frames 0-1  (also used for idle_right)
idle_left:  frames 2-3
idle_up:    frames 4-5

// Casting animations (3 frames each direction)
casting_down:  frames 6-8
casting_right: frames 9-11
casting_left:  frames 12-14
casting_up:    frames 15-17
```

### Animation Direction Mapping

```gml
function get_companion_anim_frame(anim_type, direction, frame_offset) {
    var base_frame = 0;

    if (anim_type == "idle") {
        switch(direction) {
            case "down":
            case "right":
                base_frame = 0;
                break;
            case "left":
                base_frame = 2;
                break;
            case "up":
                base_frame = 4;
                break;
        }
        return base_frame + floor(frame_offset) % 2;  // 2 frames per direction
    }
    else if (anim_type == "casting") {
        switch(direction) {
            case "down":
                base_frame = 6;
                break;
            case "right":
                base_frame = 9;
                break;
            case "left":
                base_frame = 12;
                break;
            case "up":
                base_frame = 15;
                break;
        }
        return base_frame + floor(frame_offset) % 3;  // 3 frames per direction
    }

    return 0;
}
```

### Animation Control

```gml
// Manual frame control
image_speed = 0;

// Update animation based on state
switch(state) {
    case CompanionState.following:
    case CompanionState.evading:
    case CompanionState.waiting:
        // Idle animation
        idle_anim_frame += 0.15;  // Animation speed
        image_index = get_companion_anim_frame("idle", facing_dir, idle_anim_frame);
        break;

    case CompanionState.casting:
        // Casting animation
        cast_anim_frame += 0.2;  // Faster animation
        image_index = get_companion_anim_frame("casting", facing_dir, cast_anim_frame);
        break;
}
```

### Facing Direction

```gml
// Update facing direction based on movement
if (abs(vel_x) > abs(vel_y)) {
    facing_dir = (vel_x > 0) ? "right" : "left";
} else if (abs(vel_y) > 0.1) {
    facing_dir = (vel_y > 0) ? "down" : "up";
}

// During following, can also face toward player
var angle_to_player = point_direction(x, y, obj_player.x, obj_player.y);
if (angle_to_player >= 45 && angle_to_player < 135) {
    facing_dir = "down";
} else if (angle_to_player >= 135 && angle_to_player < 225) {
    facing_dir = "left";
} else if (angle_to_player >= 225 && angle_to_player < 315) {
    facing_dir = "up";
} else {
    facing_dir = "right";
}
```

---

## Key Files Reference

| File | Purpose | Key Lines |
|------|---------|-----------|
| `/objects/obj_companion_parent/Create_0.gml` | Companion initialization | Full file |
| `/objects/obj_companion_parent/Step_0.gml` | State machine and triggers | Full file |
| `/scripts/scr_companion_system/scr_companion_system.gml` | Helper functions for bonuses | Full file |
| `/docs/COMPANION_GUIDE.md` | High-level companion design | Full file |
| `/docs/AFFINITY_SYSTEM_DESIGN.md` | Affinity mechanics design | Full file |
| `/docs/Companion_Affinity_Triggers.md` | Trigger design documentation | Full file |

---

*Last Updated: 2025-10-17*
