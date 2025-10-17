# Animation System - Technical Documentation

This document provides comprehensive technical documentation for the animation systems in Shadow Work, including player and enemy animation handling.

---

## Table of Contents

1. [Player Animation (Custom Frame-Based)](#player-animation-custom-frame-based)
2. [Enemy Animation (State-Based)](#enemy-animation-state-based)

---

## Player Animation (Custom Frame-Based)

The player uses a custom frame-based animation system with manual control for precise timing.

**Location:** `/objects/obj_player/Create_0.gml` and `/scripts/player_handle_animation/player_handle_animation.gml`

### Animation Data Structure

```gml
// In obj_player Create event
anim_data = {
    // Idle animations (2 frames each)
    idle_down: {start: 0, length: 2},
    idle_right: {start: 2, length: 2},
    idle_left: {start: 4, length: 2},
    idle_up: {start: 6, length: 2},

    // Walk animations (4-5 frames)
    walk_down: {start: 8, length: 5},
    walk_right: {start: 13, length: 5},
    walk_left: {start: 18, length: 5},
    walk_up: {start: 23, length: 3},

    // Dash animations (4 frames each)
    dash_down: {start: 26, length: 4},
    dash_right: {start: 30, length: 4},
    dash_left: {start: 34, length: 4},
    dash_up: {start: 38, length: 4},

    // Attack animations (4 frames each)
    attack_down: {start: 42, length: 4},
    attack_right: {start: 46, length: 4},
    attack_left: {start: 50, length: 4},
    attack_up: {start: 54, length: 4},

    // Ranged attack animations (4 frames each)
    ranged_down: {start: 58, length: 4},
    ranged_right: {start: 62, length: 4},
    ranged_left: {start: 66, length: 4},
    ranged_up: {start: 70, length: 4},

    // Shielding animations (3 frames each)
    shielding_down: {start: 61, length: 3},
    shielding_right: {start: 64, length: 3},
    shielding_left: {start: 67, length: 3},
    shielding_up: {start: 70, length: 3}
};

// Animation state
anim_frame = 0;             // Current animation frame offset
anim_speed_walk = 0.2;      // Walking animation speed
anim_speed_idle = 0.15;     // Idle animation speed
image_speed = 0;            // Disable automatic animation
```

**Total Frames:** 58+ frames in player sprite sheet

### Manual Frame Control

```gml
// Disable GameMaker's automatic animation
image_speed = 0;

// Manually set image_index each frame
image_index = current_anim_start + floor(anim_frame);
```

### Animation Update Logic

```gml
// In player_handle_animation() function
function player_handle_animation() {
    // Get current animation type and direction
    var anim_type = get_anim_type_from_state();  // "idle", "walk", "dash", "attack", etc.
    var anim_direction = facing_dir;              // "down", "up", "left", "right"

    // Build animation key
    var anim_key = anim_type + "_" + anim_direction;

    // Get animation data
    var current_anim = anim_data[$ anim_key];
    if (current_anim == undefined) {
        // Fallback to idle_down
        current_anim = anim_data.idle_down;
    }

    // Advance animation frame
    if (anim_type == "idle") {
        anim_frame += anim_speed_idle;
    } else if (anim_type == "walk") {
        anim_frame += anim_speed_walk;
    } else {
        // Attack, dash, etc. - use state-specific speed
        anim_frame += anim_speed_attack;
    }

    // Loop animation
    if (anim_frame >= current_anim.length) {
        anim_frame = 0;

        // State-specific behavior on animation complete
        if (anim_type == "attack" || anim_type == "ranged") {
            attack_animation_complete = true;
        }
    }

    // Set sprite frame
    image_index = current_anim.start + floor(anim_frame);
}
```

**Location:** `/scripts/player_handle_animation/player_handle_animation.gml`

### Animation State Determination

```gml
function get_anim_type_from_state() {
    switch(state) {
        case PlayerState.idle:
            return "idle";

        case PlayerState.walking:
            return "walk";

        case PlayerState.dashing:
            return "dash";

        case PlayerState.attacking:
            return is_ranged_weapon(equipped.right_hand) ? "ranged" : "attack";

        case PlayerState.shielding:
            return "shielding";

        default:
            return "idle";
    }
}
```

### Direction Determination

```gml
// Update facing direction based on input
if (input_x != 0 || input_y != 0) {
    if (abs(input_x) > abs(input_y)) {
        facing_dir = (input_x > 0) ? "right" : "left";
    } else {
        facing_dir = (input_y > 0) ? "down" : "up";
    }
}

// Direction persists when idle (player faces last direction)
```

### Animation Reset

```gml
// Reset animation when changing states
function change_state(new_state) {
    state = new_state;
    anim_frame = 0;  // Reset to first frame
}
```

### Special Case: Attack Animation

```gml
// Attack animations don't loop - play once and check for completion
case PlayerState.attacking:
    anim_frame += anim_speed_attack;

    if (anim_frame >= current_anim.length) {
        anim_frame = current_anim.length - 0.01;  // Hold on last frame
        attack_animation_complete = true;

        // Spawn attack hitbox when animation completes
        if (!attack_spawned) {
            spawn_attack_hitbox();
            attack_spawned = true;
        }
    }
    break;
```

---

## Enemy Animation (State-Based)

Enemies use a state-based animation system with global frame tracking.

**Location:** `/scripts/scr_animation_helpers/scr_animation_helpers.gml` and `/objects/obj_enemy_parent/Step_0.gml`

### Standard Enemy Sprite Layout

**35-frame layout (melee-only enemies):**

```gml
// Idle animations (2 frames each direction)
idle_down:  frames 0-1
idle_right: frames 2-3
idle_left:  frames 4-5
idle_up:    frames 6-7

// Walk animations (3 frames each direction)
walk_down:  frames 8-10
walk_right: frames 11-13
walk_left:  frames 14-16
walk_up:    frames 17-19

// Attack animations (3 frames each direction)
attack_down:  frames 20-22
attack_right: frames 23-25
attack_left:  frames 26-28
attack_up:    frames 29-31

// Death animation (3 frames)
dying: frames 32-34
```

### Extended Sprite Layout (Dual-Mode Enemies)

**47-frame layout (melee + ranged):**

```gml
// Frames 0-34: Standard layout above

// Ranged attack animations (3-4 frames each direction)
ranged_attack_down:  frames 35-37  (3 frames)
ranged_attack_right: frames 38-41  (4 frames)
ranged_attack_left:  frames 42-45  (4 frames)
ranged_attack_up:    frames 46-48  (3 frames)
```

### Animation Data Lookup

```gml
// In scr_animation_helpers.gml
function get_enemy_animation_data(state, direction) {
    var anim_key = state + "_" + direction;

    // Check for custom override first
    if (enemy_anim_overrides[$ anim_key] != undefined) {
        return enemy_anim_overrides[$ anim_key];
    }

    // Use standard layout
    switch(anim_key) {
        // Idle animations
        case "idle_down":  return {start: 0, length: 2};
        case "idle_right": return {start: 2, length: 2};
        case "idle_left":  return {start: 4, length: 2};
        case "idle_up":    return {start: 6, length: 2};

        // Walk animations
        case "walk_down":  return {start: 8, length: 3};
        case "walk_right": return {start: 11, length: 3};
        case "walk_left":  return {start: 14, length: 3};
        case "walk_up":    return {start: 17, length: 3};

        // Attack animations
        case "attack_down":  return {start: 20, length: 3};
        case "attack_right": return {start: 23, length: 3};
        case "attack_left":  return {start: 26, length: 3};
        case "attack_up":    return {start: 29, length: 3};

        // Ranged attack animations (extended layout)
        case "ranged_attack_down":  return {start: 35, length: 3};
        case "ranged_attack_right": return {start: 38, length: 4};
        case "ranged_attack_left":  return {start: 42, length: 4};
        case "ranged_attack_up":    return {start: 46, length: 3};

        // Death animation
        case "dying_down":
        case "dying_right":
        case "dying_left":
        case "dying_up":
            return {start: 32, length: 3};

        default:
            return {start: 0, length: 2};  // Fallback to idle_down
    }
}
```

### Animation Override System

Enemies can override default animations with custom layouts:

```gml
// In enemy Create event
enemy_anim_overrides = {
    ranged_attack_down: {start: 35, length: 3},
    ranged_attack_right: {start: 38, length: 4},
    ranged_attack_left: {start: 42, length: 4},
    ranged_attack_up: {start: 46, length: 3}
};

// Example: Boss with longer attack animations
enemy_anim_overrides = {
    attack_down: {start: 20, length: 5},   // 5 frames instead of 3
    attack_right: {start: 25, length: 5},
    attack_left: {start: 30, length: 5},
    attack_up: {start: 35, length: 5}
};
```

### Global Frame Tracker

Enemies use a global idle bob timer for synchronized animation:

```gml
// In obj_game_controller Step event
global.idle_bob_timer += 0.1;

if (global.idle_bob_timer >= 360) {
    global.idle_bob_timer = 0;
}

// All enemies reference this for idle animations
// Creates synchronized breathing/bobbing effect
```

### Enemy Animation Update

```gml
// In obj_enemy_parent Step event
function update_enemy_animation() {
    // Get animation type from state
    var anim_type = get_anim_type_from_enemy_state(state);

    // Get animation data
    var anim = get_enemy_animation_data(anim_type, facing_dir);

    // Calculate frame based on state
    var frame_offset = 0;

    if (state == EnemyState.idle || state == EnemyState.wander) {
        // Use global bob timer for idle
        frame_offset = floor(global.idle_bob_timer / 180) % anim.length;
    }
    else if (state == EnemyState.targeting) {
        // Walk animation based on movement
        if (path_speed > 0) {
            frame_offset = floor((current_time / 100) % anim.length);
        } else {
            // Idle if not moving
            frame_offset = floor(global.idle_bob_timer / 180) % anim.length;
        }
    }
    else if (state == EnemyState.attacking ||
             state == EnemyState.ranged_attacking) {
        // Attack animation advances per frame
        attack_anim_frame += 0.2;
        frame_offset = floor(attack_anim_frame) % anim.length;

        // Check if animation complete
        if (attack_anim_frame >= anim.length) {
            attack_animation_complete = true;
        }
    }
    else if (state == EnemyState.dead) {
        // Death animation plays once
        death_anim_frame += 0.15;
        frame_offset = min(floor(death_anim_frame), anim.length - 1);

        // Destroy when animation completes
        if (death_anim_frame >= anim.length) {
            instance_destroy();
        }
    }

    // Set sprite frame
    image_index = anim.start + frame_offset;
}
```

### Animation State Mapping

```gml
function get_anim_type_from_enemy_state(enemy_state) {
    switch(enemy_state) {
        case EnemyState.idle:
        case EnemyState.wander:
            return "idle";

        case EnemyState.targeting:
            return "walk";

        case EnemyState.attacking:
            return "attack";

        case EnemyState.ranged_attacking:
            return "ranged_attack";

        case EnemyState.dead:
            return "dying";

        default:
            return "idle";
    }
}
```

### Direction Update

```gml
// Update facing direction based on movement or target
if (state == EnemyState.targeting) {
    // Face toward player
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
}

// Direction persists in other states unless explicitly changed
```

### Example: Custom Enemy Animation

```gml
// obj_fire_boss Create event
event_inherited();

// Custom animation speeds
anim_speed_idle = 0.05;
anim_speed_walk = 0.15;
anim_speed_attack = 0.25;

// Custom animation overrides (longer attack animations)
enemy_anim_overrides = {
    attack_down: {start: 20, length: 6},
    attack_right: {start: 26, length: 6},
    attack_left: {start: 32, length: 6},
    attack_up: {start: 38, length: 6},

    ranged_attack_down: {start: 44, length: 5},
    ranged_attack_right: {start: 49, length: 5},
    ranged_attack_left: {start: 54, length: 5},
    ranged_attack_up: {start: 59, length: 5}
};

// Boss uses custom 64-frame sprite
```

---

## Animation Best Practices

### For Player Animations

1. **Use manual frame control** - `image_speed = 0` for precise timing
2. **Reset frame on state change** - Prevents animation artifacts
3. **Hold last frame** - For non-looping animations (attacks, etc.)
4. **Sync with gameplay** - Attack hitboxes spawn when animation reaches specific frame

### For Enemy Animations

1. **Use standard layouts** - 35 or 47 frame layouts for consistency
2. **Synchronized idle** - Use `global.idle_bob_timer` for unified feel
3. **Override when needed** - Use `enemy_anim_overrides` for special cases
4. **State-based animation** - Animation type determined by enemy state

### Animation Timing

**Player:**
- Idle: 0.15 speed (slower, calmer)
- Walk: 0.2 speed (matches movement)
- Attack: 0.25 speed (snappy, responsive)
- Dash: Fixed 8-frame duration

**Enemies:**
- Idle: 0.1 speed (subtle breathing)
- Walk: 0.15 speed (matches pathfinding)
- Attack: 0.2 speed (telegraphs attack)
- Death: 0.15 speed (dramatic pause)

---

## Key Files Reference

| File | Purpose | Key Lines |
|------|---------|-----------|
| `/objects/obj_player/Create_0.gml` | Player anim_data struct | Lines 170-225 |
| `/scripts/player_handle_animation/player_handle_animation.gml` | Player animation logic | Full file |
| `/scripts/scr_animation_helpers/scr_animation_helpers.gml` | Enemy animation data | Full file |
| `/objects/obj_enemy_parent/Step_0.gml` | Enemy animation update | Lines 200-250 |
| `/objects/obj_game_controller/Create_0.gml` | Global idle bob timer | Line 45 |

---

*Last Updated: 2025-10-17*
