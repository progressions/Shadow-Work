# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-05-combat-visual-feedback/spec.md

> Created: 2025-10-05
> Version: 1.0.0

## Technical Requirements

### 1. Freeze Frame System

**Implementation Approach:**
- Use `image_speed = 0` to pause all animated objects during freeze
- Track freeze duration with a countdown timer in `obj_game_controller`
- Resume animation by restoring `image_speed` values after freeze ends

**Key Variables (obj_game_controller):**
```gml
freeze_frames_remaining = 0;  // Counter for freeze duration
freeze_original_speeds = {};  // Struct to store original image_speed values
is_frozen = false;            // Boolean flag for freeze state
```

**Core Functions:**
```gml
// Start freeze frame effect
// duration: number of frames to freeze (2-8)
function apply_freeze_frame(duration) {
    if (!is_frozen) {
        is_frozen = true;
        freeze_frames_remaining = duration;

        // Store and pause all animated objects
        with (obj_player) {
            other.freeze_original_speeds[$ "player"] = image_speed;
            image_speed = 0;
        }
        with (obj_enemy_parent) {
            other.freeze_original_speeds[$ string(id)] = image_speed;
            image_speed = 0;
        }
    }
}

// Resume animation after freeze (called in Step event)
function update_freeze_frame() {
    if (is_frozen && freeze_frames_remaining > 0) {
        freeze_frames_remaining--;

        if (freeze_frames_remaining <= 0) {
            is_frozen = false;

            // Restore original speeds
            with (obj_player) {
                image_speed = other.freeze_original_speeds[$ "player"] ?? 1;
            }
            with (obj_enemy_parent) {
                image_speed = other.freeze_original_speeds[$ string(id)] ?? 1;
            }

            freeze_original_speeds = {}; // Clear storage
        }
    }
}
```

**Integration Points:**
- Call `apply_freeze_frame(2)` in `obj_attack` collision with enemies (normal hit)
- Call `apply_freeze_frame(5)` on enemy death
- Call `apply_freeze_frame(6)` on critical hit
- Call `update_freeze_frame()` in `obj_game_controller` Step event

---

### 2. Screen Shake System

**Implementation Approach:**
- Manipulate camera x/y offset to create shake effect
- Use decay pattern: strong initial shake that decreases over time
- Different intensity levels based on weapon type

**Key Variables (obj_game_controller):**
```gml
shake_intensity = 0;      // Current shake strength (pixels)
shake_duration = 0;       // Frames remaining for shake
shake_decay = 0.8;        // Multiplier for intensity reduction per frame
```

**Core Functions:**
```gml
// Trigger screen shake
// intensity: initial shake strength in pixels (2-12)
// duration: number of frames to shake (4-10)
function apply_screen_shake(intensity, duration) {
    shake_intensity = max(shake_intensity, intensity); // Don't reduce ongoing shake
    shake_duration = max(shake_duration, duration);
}

// Update shake and apply to camera (called in Step event)
function update_screen_shake() {
    if (shake_duration > 0) {
        shake_duration--;

        // Random offset based on intensity
        var shake_x = random_range(-shake_intensity, shake_intensity);
        var shake_y = random_range(-shake_intensity, shake_intensity);

        // Apply to camera
        camera_set_view_pos(view_camera[0],
            view_xview[0] + shake_x,
            view_yview[0] + shake_y);

        // Decay intensity
        shake_intensity *= shake_decay;

        if (shake_duration <= 0) {
            shake_intensity = 0;
        }
    }
}
```

**Weapon Shake Values:**
```gml
// In obj_attack Create event, set shake based on weapon type
var weapon_data = global.item_database[$ weapon_id];
var shake_intensity = 4;  // Default
var shake_duration = 6;   // Default

switch (weapon_data.handedness) {
    case WeaponHandedness.two_handed:
        shake_intensity = 10;
        shake_duration = 8;
        break;
    case WeaponHandedness.versatile:
        shake_intensity = 7;
        shake_duration = 7;
        break;
    case WeaponHandedness.one_handed:
        shake_intensity = 4;
        shake_duration = 6;
        break;
}

// Store for use in collision event
self.shake_intensity = shake_intensity;
self.shake_duration = shake_duration;
```

**Integration Points:**
- Call `apply_screen_shake(shake_intensity, shake_duration)` in `obj_attack` collision with enemies
- Call `update_screen_shake()` in `obj_game_controller` Step event

---

### 3. Hit Effect Sprites

**Implementation Approach:**
- Create simple sprite objects that spawn at hit location
- Fade out using alpha over time
- Directional variants based on attack angle

**New Object: obj_hit_effect**
```gml
// Create event
alpha = 1.0;
lifetime = 10;  // Frames before destruction
fade_speed = 0.1;
depth = -1000;  // Draw above most objects

// Step event
alpha -= fade_speed;
lifetime--;

if (lifetime <= 0 || alpha <= 0) {
    instance_destroy();
}

// Draw event
draw_sprite_ext(sprite_index, image_index, x, y,
    image_xscale, image_yscale, image_angle,
    c_white, alpha);
```

**Sprite Assets Required:**
- `spr_hit_spark_horizontal` - 1-3 frames, small spark/flash
- `spr_hit_spark_vertical` - rotated variant
- `spr_hit_spark_diagonal` - diagonal variants

**Spawning Logic (in obj_attack collision):**
```gml
// Calculate hit direction
var hit_dir = point_direction(x, y, other.x, other.y);
var hit_sprite = spr_hit_spark_horizontal;

// Choose sprite based on angle
if (hit_dir > 45 && hit_dir < 135) {
    hit_sprite = spr_hit_spark_vertical;
} else if (hit_dir > 135 && hit_dir < 225) {
    hit_sprite = spr_hit_spark_horizontal;
}

// Spawn effect at collision point
var effect = instance_create_depth(
    other.x + lengthdir_x(16, hit_dir),
    other.y + lengthdir_y(16, hit_dir),
    -1000,
    obj_hit_effect
);
effect.sprite_index = hit_sprite;
effect.image_angle = hit_dir;
```

---

### 4. Enemy Flash Effects

**Implementation Approach:**
- Use `image_blend` to tint enemy sprite
- Reset after short duration (2-4 frames)
- Different colors for normal (white) vs crit (red) hits

**New Variables (obj_enemy_parent):**
```gml
flash_timer = 0;          // Frames remaining for flash
flash_color = c_white;    // Color to blend
original_blend = c_white; // Store original color
```

**Core Functions (obj_enemy_parent):**
```gml
// Apply flash effect
// color: c_white for normal, c_red for crit
// duration: frames to show flash (2-4)
function apply_damage_flash(color, duration) {
    flash_color = color;
    flash_timer = duration;
    image_blend = color;
}

// Update flash (in Step event)
function update_damage_flash() {
    if (flash_timer > 0) {
        flash_timer--;
        if (flash_timer <= 0) {
            image_blend = original_blend;
        }
    }
}
```

**Integration Points:**
- Call `apply_damage_flash(c_white, 3)` in enemy's hit/damage function (normal hit)
- Call `apply_damage_flash(c_red, 4)` on critical hit
- Call `update_damage_flash()` in `obj_enemy_parent` Step event

---

### 5. Slow-Motion System

**Implementation Approach:**
- Manipulate `game_set_speed()` to slow game time
- Gradual ramp back to normal speed
- Only affects game logic, not UI drawing

**Key Variables (obj_game_controller):**
```gml
time_scale = 1.0;              // Current time multiplier
target_time_scale = 1.0;       // Target to interpolate toward
time_scale_lerp_speed = 0.05;  // Interpolation speed
normal_game_speed = 60;        // Base FPS
```

**Core Functions:**
```gml
// Trigger slow-motion effect
// scale: 0.3-1.0 (0.3 = 30% speed, 1.0 = normal)
// ramp_speed: how quickly to return to normal (0.01-0.1)
function apply_slow_motion(scale, ramp_speed) {
    time_scale = scale;
    target_time_scale = 1.0;
    time_scale_lerp_speed = ramp_speed;

    // Apply immediately
    game_set_speed(normal_game_speed * time_scale, gamespeed_fps);
}

// Update time scale (in Step event)
function update_time_scale() {
    if (time_scale != target_time_scale) {
        time_scale = lerp(time_scale, target_time_scale, time_scale_lerp_speed);

        // Snap to target when close enough
        if (abs(time_scale - target_time_scale) < 0.01) {
            time_scale = target_time_scale;
        }

        game_set_speed(normal_game_speed * time_scale, gamespeed_fps);
    }
}
```

**Integration Points:**
- Call `apply_slow_motion(0.4, 0.05)` when companion trigger ability activates
- Call `update_time_scale()` in `obj_game_controller` Step event
- Effect lasts approximately 0.5 seconds (30 frames at 0.05 lerp speed)

---

### 6. Critical Hit System

**Implementation Approach:**
- Random RNG check on each attack
- Modified damage calculation
- Combined with visual effects (red flash, extended freeze)

**New Variables (obj_attack):**
```gml
is_critical_hit = false;
crit_chance = 0.10;        // 10% base crit chance
crit_multiplier = 1.75;    // 1.75x damage on crit
```

**Core Functions:**
```gml
// Check for critical hit (called in Create event)
function roll_for_crit() {
    is_critical_hit = (random(1) < crit_chance);
    return is_critical_hit;
}

// Calculate damage with crit modifier
function get_attack_damage() {
    var base_damage = damage;  // From weapon

    if (is_critical_hit) {
        return base_damage * crit_multiplier;
    }

    return base_damage;
}
```

**Integration Points (obj_attack collision with obj_enemy_parent):**
```gml
// In collision event with enemy
var final_damage = get_attack_damage();
other.hp_current -= final_damage;

if (is_critical_hit) {
    // Critical hit visuals
    other.apply_damage_flash(c_red, 4);
    obj_game_controller.apply_freeze_frame(6);
} else {
    // Normal hit visuals
    other.apply_damage_flash(c_white, 3);
    obj_game_controller.apply_freeze_frame(2);
}

// Apply screen shake regardless
obj_game_controller.apply_screen_shake(shake_intensity, shake_duration);

// Spawn hit effect
// (see Hit Effect Sprites section above)
```

---

## External Dependencies

**None required.** All features use GameMaker Studio 2 built-in functions:

- `image_speed` - Animation control for freeze frames
- `camera_set_view_pos()` - Camera manipulation for screen shake
- `instance_create_depth()` - Spawning hit effect objects
- `draw_sprite_ext()` - Alpha blending for hit effects
- `image_blend` - Color tinting for enemy flashes
- `game_set_speed()` - Time manipulation for slow-motion
- `random()` - RNG for critical hit rolls
- `lerp()` - Smooth interpolation for time scale recovery

---

## Performance Considerations

**Target: 60 FPS maintained**

1. **Freeze Frames**: Minimal performance impact (pausing animation is free)
2. **Screen Shake**: Single camera offset calculation per frame (~0.01ms)
3. **Hit Effects**: Maximum 5-10 instances active at once, simple alpha fade
4. **Enemy Flashes**: Zero performance cost (built-in blending)
5. **Slow-Motion**: Global time scale affects all objects equally, no per-instance overhead
6. **Crit Calculation**: Single RNG call per attack creation (~0.001ms)

**Optimization Notes:**
- Limit simultaneous hit effect instances to 10 (destroy oldest if exceeded)
- Use object pooling for hit effects if performance issues arise
- Screen shake uses view manipulation, not object movement
- Freeze frames don't pause game logic, only visual animation
- Time scale affects `game_set_speed()` globally, not per-instance

**Memory Footprint:**
- Hit effect sprites: ~50-100 KB total (3-4 simple sprites)
- Additional variables per enemy: 16 bytes (flash_timer, flash_color)
- Game controller additions: ~100 bytes (shake/freeze/time_scale state)
- Total estimated memory increase: <200 KB

---

## Implementation Order

Recommended implementation sequence:

1. **Freeze Frame System** - Foundation for timing-based feedback
2. **Enemy Flash Effects** - Visual confirmation of hits
3. **Critical Hit System** - Gameplay mechanic with visual tie-in
4. **Screen Shake System** - Weapon differentiation
5. **Hit Effect Sprites** - Additional visual polish
6. **Slow-Motion System** - Companion trigger enhancement

This order allows testing each system independently while building on previous work.
