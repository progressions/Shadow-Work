# Player Mechanics - Technical Documentation

This document provides comprehensive technical documentation for the core player mechanics in Shadow Work, including dashing, dash attacks, and shield blocking systems.

---

## Table of Contents

1. [Dashing System](#dashing-system)
2. [Dash Attack System](#dash-attack-system)
3. [Shield Blocking System](#shield-blocking-system)

---

## Dashing System

### Overview

Dashing is a quick burst of movement triggered by double-tapping movement keys, providing mobility and combat utility. The dash can be canceled by stagger effects and integrates with companion systems for enhanced gameplay.

### Input Detection

**Trigger:** Double-tap W/A/S/D within 300ms window

**Implementation:** `/scripts/player_handle_dash_input/player_handle_dash_input.gml`

```gml
double_tap_time = 300;  // Milliseconds
last_key_time_w = -999;
last_key_time_a = -999;
last_key_time_s = -999;
last_key_time_d = -999;
```

**Detection Logic:**
- Tracks last key press time for each movement key
- Compares current time to last press time
- If delta < 300ms and cooldown expired → trigger dash

**Focus Combat Integration:**
- If focus mode active, double-tap triggers different actions:
  - Ranged weapon: Execute ranged volley if retreating
  - Melee weapon: Trigger melee combo
  - Sets retreat direction instead of immediate dash

### Core Mechanics

**Location:** `/scripts/player_state_dashing/player_state_dashing.gml`

#### Timing Parameters

```gml
dash_duration = 8;           // Frames (~0.13 seconds at 60fps)
dash_timer = 0;              // Countdown during dash
dash_cooldown_time = 75;     // Frames (~1.25 seconds)
dash_cooldown = 0;           // Current cooldown counter
```

#### Movement Properties

```gml
dash_speed = 6;              // Base speed in pixels/frame
momentum_factor = 0.6;       // Speed carryover after dash ends
```

**Final Dash Speed Calculation:**
```gml
final_dash_speed = dash_speed * terrain_speed_modifier * speed_modifier
```

- `terrain_speed_modifier`: From terrain system (ice, mud, etc.)
- `speed_modifier`: From status effects via `get_status_effect_modifier("speed")`

#### Direction System

```gml
last_dash_direction = "";        // Tracks direction of last dash
dash_override_direction = "";    // For retreat/focus dashes
```

**Direction Priority:**
1. Use `dash_override_direction` if set (for retreat dashes)
2. Otherwise use `facing_dir` (player's current facing)

**Direction Application:**
```gml
switch(_dash_dir) {
    case "up":    dash_y = -final_dash_speed; break;
    case "down":  dash_y =  final_dash_speed; break;
    case "left":  dash_x = -final_dash_speed; break;
    case "right": dash_x =  final_dash_speed; break;
}
```

#### Momentum System

When dash completes, 60% of dash speed carries over as velocity:

```gml
// At end of dash (lines 28-45 in player_state_dashing.gml)
vel_x = dash_x * momentum_factor;
vel_y = dash_y * momentum_factor;
```

This creates smooth transition from dash to normal movement.

### Animation

**Location:** `/objects/obj_player/Create_0.gml` (lines 170-174)

**Frame Layout:**
- dash_down: frames 26-29 (4 frames)
- dash_right: frames 30-33 (4 frames)
- dash_left: frames 34-37 (4 frames)
- dash_up: frames 38-41 (4 frames)

**Animation Control:**
- Manual frame control: `image_speed = 0`
- `move_dir = "dash"` triggers animation in `player_handle_animation()`
- Animation plays during 8-frame dash duration

### Interruptions and Limitations

**Cannot Dash When:**
1. Already dashing (`state == PlayerState.dashing`)
2. On cooldown (`dash_cooldown > 0`)
3. Staggered (`is_staggered == true`)

**Dash Cancellation:**
- Stagger immediately cancels dash
- Checked at start of dash state (lines 3-10 in `player_state_dashing.gml`)
- Returns to idle state on cancel

**Collision Handling:**
- Uses `move_and_collide()` for wall collision
- Respects collision list for consistent behavior
- No tunneling through walls

### Cooldown System

**Location:** `/scripts/player_handle_dash_cooldown/player_handle_dash_cooldown.gml`

**Base Cooldown Reduction:**
```gml
base_reduction = 1;  // 1 frame per frame normally
```

**Companion Bonuses:**
```gml
companion_reduction = get_companion_dash_cd_reduction();
total_reduction = base_reduction + companion_reduction;
dash_cooldown = max(0, dash_cooldown - total_reduction);
```

**Hola's Slipstream Aura:**
- Provides 10-30% cooldown reduction
- Scales with companion affinity (3.0 to 10.0)
- Applied every frame while cooldown > 0

### Companion Integration

**Dash Event Notification:**

**Function:** `companion_on_player_dash(player_instance)`
**Called:** When dash starts (in `start_dash()` function)

**Companion Reactions:**
- Canopy's Dash Mend: Healing on dash
- Other companion dash-reactive triggers
- Dash cooldown reduction auras

### Implementation Functions

**Location:** `/objects/obj_player/Create_0.gml` (lines 243-260)

#### start_dash(_direction, _preserve_facing)

Initializes dash state and variables.

**Parameters:**
- `_direction`: Direction string ("up", "down", "left", "right")
- `_preserve_facing`: If true, uses `dash_override_direction` for retreat dashes

**Actions:**
1. Sets `state = PlayerState.dashing`
2. Sets `dash_timer = dash_duration`
3. Sets `last_dash_direction = _direction`
4. Calls `player_dash_begin()` for combat tracking
5. Plays `snd_dash` sound effect
6. Notifies companions via `companion_on_player_dash(id)`

### Sound Effects

**Dash Start:** `snd_dash` (volume 1.0)
- Plays when `start_dash()` is called
- Single sound per dash

### Key Files Reference

| File | Purpose | Key Lines |
|------|---------|-----------|
| `/scripts/player_handle_dash_input/player_handle_dash_input.gml` | Double-tap detection | Full file |
| `/scripts/player_state_dashing/player_state_dashing.gml` | Dash movement logic | Full file |
| `/scripts/player_handle_dash_cooldown/player_handle_dash_cooldown.gml` | Cooldown reduction | Full file |
| `/objects/obj_player/Create_0.gml` | `start_dash()` function | 243-260 |
| `/scripts/player_state_idle/player_state_idle.gml` | Dash input from idle | 21 |
| `/scripts/player_state_walking/player_state_walking.gml` | Dash input while walking | 23 |

---

## Dash Attack System

### Overview

The dash attack system provides two distinct damage mechanics:
1. **Collision Damage:** Damage enemies by dashing through them
2. **Post-Dash Attack Window:** Bonus damage when attacking immediately after dash

Both use a 1.5x damage multiplier and integrate with the full combat system (crits, traits, equipment, status effects).

### Type 1: Collision Damage (During Dash)

**Location:** `/scripts/player_dash_attack/player_dash_attack.gml`

#### Initialization

**Function:** `player_dash_begin()`
**Called:** When dash starts

**Actions:**
1. Create/clear `dash_hit_enemies` DS list
2. Reset `dash_hit_count = 0`
3. Reset `dash_impact_sound_played = false`
4. Roll target cap via `player_get_dash_target_cap()`
5. Check for companion multi-target bonuses (Yorna's aura)

#### Collision Detection

**Function:** `player_dash_handle_collisions(_prev_x, _prev_y)`
**Called:** Every frame during dash state

**Detection Method:**
1. Check bounding box intersection at current position
2. If not intersecting, use `collision_line` between previous and current position
3. Prevents tunneling through enemies at high speeds

**Filter Checks:**
1. Enemy not already hit this dash (`!ds_list_find_index(dash_hit_enemies, enemy_id)`)
2. Enemy not dead (`state != EnemyState.dead`)
3. Enemy not in hit immunity (`alarm[1] < 0`)
4. Haven't reached target cap (`dash_hit_count < dash_target_cap`)

#### Damage Application

**Location:** Lines 65-157 in `player_dash_attack.gml`

**Process:**
1. Set `is_dash_attacking = true` temporarily
2. Call `get_total_damage()` to calculate damage (includes 1.5x multiplier)
3. Determine if last attack was crit (for feedback)
4. Create attack info struct with all combat properties
5. Call `player_attack_apply_damage(enemy, attack_info)`
6. Add enemy to `dash_hit_enemies` list
7. Increment `dash_hit_count`
8. Reset `is_dash_attacking = false`

**Attack Info Structure:**
```gml
{
    damage: calculated_damage,
    damage_type: weapon_damage_type,
    attack_category: AttackCategory.melee,
    is_crit: last_attack_was_crit,
    knockback_force: weapon_knockback,
    shake_intensity: weapon_shake (2-8 based on handedness),
    apply_status_effects: true,
    allow_interrupt: true,
    armor_pierce: execution_window_pierce,
    flash_on_hit: true
}
```

#### Target Cap System

**Function:** `player_get_dash_target_cap()`

**Base Targets by Level:**
| Player Level | Base Targets |
|--------------|--------------|
| 1-4          | 1            |
| 5-9          | 2            |
| 10-14        | 3            |
| 15+          | 4            |

**Companion Bonuses:**
- Yorna's Warriors Presence aura can increase cap
- Proc chance-based (doesn't always trigger)
- Never reduces base cap, only increases
- Sets `dash_multi_bonus_active = true` on proc

#### Sound Effects

**First Hit Sound:** `snd_dash_attack`
- Plays only once per dash when first enemy is hit
- `dash_impact_sound_played` flag prevents spam
- Volume 1.0, no loop

#### Visual Feedback

**Screen Shake:**
- Intensity based on weapon handedness:
  - Daggers: 2 pixels
  - One-handed: 4 pixels
  - Versatile (two-handed): 6 pixels
  - Two-handed: 8 pixels

**Hit Effects:**
- Enemy flash (white for normal, red for crit)
- Hit sparkles spray from impact point
- Damage numbers (color-coded by damage type)
- Freeze frames (2-4 frames based on weapon)

### Type 2: Post-Dash Attack Window

**Location:** `/scripts/player_attacking/player_attacking.gml` (lines 69-88)

#### Window Activation

When dash completes:
```gml
dash_attack_window = dash_attack_window_duration;  // 0.4 seconds
```

**Location:** `/scripts/player_state_dashing/player_state_dashing.gml` (lines 38-41)

#### Window Properties

```gml
dash_attack_window_duration = 0.4;           // Seconds
dash_attack_damage_multiplier = 1.5;         // +50% damage
dash_attack_defense_penalty = 0.75;          // -25% DR penalty
```

#### Attack Trigger Conditions

**All must be true:**
1. `dash_attack_window > 0` (window still active)
2. `facing_dir == last_dash_direction` (attacking in dash direction)
3. Player attacks within window

**When triggered:**
1. Set `is_dash_attacking = true`
2. Apply 1.5x damage multiplier in `get_total_damage()`
3. Apply defense penalty trait (1 second duration):
   ```gml
   apply_timed_trait("defense_vulnerability", 1.0);
   ```
4. Play `snd_dash_attack` sound

#### Window Countdown

**Location:** `/objects/obj_player/Step_0.gml` (lines 133-152)

**Per Frame:**
```gml
dash_attack_window -= 1 / game_get_speed(gamespeed_fps);
```

**Cancellation:**
Window cancelled immediately if player changes direction:
```gml
if (facing_dir != last_dash_direction) {
    dash_attack_window = 0;
}
```

### Damage Calculation Integration

**Location:** `/scripts/scr_combat_system/scr_combat_system.gml` (lines 36-40)

```gml
// In get_total_damage() function
if (is_dash_attacking) {
    _base_damage *= dash_attack_damage_multiplier;
    show_debug_message("Dash attack damage boost applied! Base: " +
        string(_base_damage / dash_attack_damage_multiplier) +
        " -> Boosted: " + string(_base_damage));
}
```

**Order in Damage Pipeline:**
1. Base weapon damage (with versatile/dual-wield modifiers)
2. Status effect modifiers (empowered/weakened)
3. Companion bonuses (auras)
4. **Dash attack multiplier (1.5x)** ← Applied here
5. Execution window multiplier
6. Critical hit roll (1.75x if successful)

### Cleanup

**Function:** `player_dash_end()`
**Called:** When dash completes or is cancelled

**Actions:**
1. Destroy `dash_hit_enemies` DS list
2. Reset `dash_hit_count = 0`
3. Reset `dash_hit_count = 0`
4. Reset `dash_impact_sound_played = false`
5. Reset `dash_multi_bonus_active = false`

### Key Variables Reference

```gml
// Dash attack flags
is_dash_attacking = false;                   // Active damage multiplier flag
dash_attack_window = 0;                      // Post-dash window timer
dash_attack_window_duration = 0.4;           // Window duration (seconds)
dash_attack_damage_multiplier = 1.5;         // Damage bonus (+50%)
dash_attack_defense_penalty = 0.75;          // DR penalty (-25%)

// Collision tracking
dash_hit_enemies = -1;                       // DS list of hit enemies
dash_hit_count = 0;                          // Enemies hit this dash
dash_target_cap = 1;                         // Max targets (level-scaled)

// Sound and visual
dash_impact_sound_played = false;            // First hit sound flag
last_attack_was_crit = false;                // For visual feedback

// Companion bonuses
dash_multi_bonus_active = false;             // Yorna aura proc flag
dash_multi_bonus_cap = 0;                    // Bonus target cap
```

### Key Files Reference

| File | Purpose | Key Lines |
|------|---------|-----------|
| `/scripts/player_dash_attack/player_dash_attack.gml` | Collision damage system | Full file |
| `/scripts/player_attacking/player_attacking.gml` | Post-dash window logic | 69-88, 153 |
| `/scripts/scr_combat_system/scr_combat_system.gml` | Damage multiplier | 36-40 |
| `/objects/obj_player/Step_0.gml` | Window countdown | 133-152 |
| `/scripts/player_state_dashing/player_state_dashing.gml` | Window activation | 38-41 |
| `/docs/dash_attack.md` | Additional documentation | Full file |

---

## Shield Blocking System

### Implementation Status

**Current State:** Partially implemented

**Completed:**
- ✅ State management (entry/exit)
- ✅ Shield animations
- ✅ Omnidirectional strafing movement
- ✅ Perfect block window tracking
- ✅ Cooldown system
- ✅ Visual polish (shield positioning)

**Not Implemented:**
- ❌ Damage reduction on block
- ❌ Projectile collision detection
- ❌ Perfect block projectile destruction
- ❌ Directional blocking (front arc checks)
- ❌ Shield-specific properties
- ❌ Integration with hazard/arrow collision events

### Input and Entry

**Trigger:** Hold **O** key

**Entry Conditions:**
1. Shield equipped in left hand slot
2. Block cooldown expired (`block_cooldown <= 0`)
3. Player in idle or walking state

**Location:**
- `/scripts/player_state_idle/player_state_idle.gml` (lines 6-16)
- `/scripts/player_state_walking/player_state_walking.gml` (lines 10-20)

**Entry Code:**
```gml
if (keyboard_check_pressed(ord("O"))) {
    if (equipped[$ "left_hand"] != undefined && block_cooldown <= 0) {
        state = PlayerState.shielding;
        shield_facing_dir = facing_dir;      // Lock facing direction
        shield_raise_complete = false;
        play_sfx(snd_shield_raise, 0.8);
    }
}
```

**Exit Condition:**
```gml
if (keyboard_check_released(ord("O"))) {
    state = PlayerState.idle;
    block_cooldown = block_cooldown_max;    // Apply cooldown
}
```

### State Management

**State Enum:** `PlayerState.shielding`
**Location:** `/scripts/scr_enums/scr_enums.gml` (line 10)

**Key Variables:**

```gml
block_cooldown = 0;                      // Frames until can block again
block_cooldown_max = 60;                 // Normal cooldown (1 second)
block_cooldown_perfect_max = 30;         // Perfect block cooldown (0.5s)
perfect_block_window = 0;                // Frames of perfect block
perfect_block_window_duration = 18;      // Perfect window (~0.3 seconds)
shield_raise_complete = false;           // Animation finished flag
shield_facing_dir = "down";              // Locked direction
shield_anim_frame = 0;                   // Current animation frame
```

**Location:** `/objects/obj_player/Create_0.gml` (lines 214-222)

### Movement System

**Location:** `/scripts/player_state_shielding/player_state_shielding.gml`

#### Facing Lock

Direction locked on entry to `shield_facing_dir`:
```gml
facing_dir = shield_facing_dir;  // Locked every frame
```

#### Omnidirectional Strafing

**WASD Input Processing (lines 25-105):**
- W/A/S/D keys control movement velocity
- Movement independent of facing direction
- Same acceleration/friction as walking state
- Applies terrain and status effect modifiers

**Movement Properties:**
```gml
// Uses same velocity system as walking
vel_x += input_x * accel;
vel_y += input_y * accel;

// Apply friction
vel_x *= friction_multiplier;
vel_y *= friction_multiplier;

// Apply terrain and status modifiers
final_vel_x = vel_x * terrain_speed_modifier * speed_modifier;
final_vel_y = vel_y * terrain_speed_modifier * speed_modifier;
```

**Collision Handling:**
- Uses `move_and_collide()` with collision list
- Wall sliding works normally
- Respects same collision rules as other states

### Animation System

**Location:** `/scripts/player_handle_animation/player_handle_animation.gml` (lines 89-113)

#### Frame Layout

**Frames 61-73** in player sprite (3 frames per direction):
- shielding_down: 61-63
- shielding_right: 64-66
- shielding_left: 67-69
- shielding_up: 70-72
- Frame 73: Not used (padding)

#### Animation Behavior

```gml
case PlayerState.shielding:
    anim_frame += 0.2;  // Faster than idle (quick shield raise)

    if (anim_frame >= current_anim_length) {
        shield_raise_complete = true;
        anim_frame = current_anim_length - 0.01;  // Hold final frame
    }
```

**Properties:**
- Animation plays once, then holds on final frame
- Faster animation speed (0.2) than idle (0.15)
- Sets `shield_raise_complete = true` when finished
- Manual frame control (`image_speed = 0`)

### Perfect Block Window

**Activation:**
When shield animation completes (`shield_raise_complete == true`):
```gml
perfect_block_window = perfect_block_window_duration;  // 18 frames
```

**Visual Feedback:**
```gml
if (perfect_block_window > 0) {
    // Yellow flash to indicate perfect block window active
    // Location: player_handle_animation.gml lines 109-112
}
```

**Countdown:**
```gml
// Each frame while window active
if (perfect_block_window > 0) {
    perfect_block_window--;
}
```

**Duration:** 18 frames = ~0.3 seconds at 60fps

### Visual Polish

**Location:** `/objects/obj_player/Draw_0.gml`

#### Shield Position Offset

```gml
// Shield moves 6 pixels forward when actively shielding (line 8)
if (state == PlayerState.shielding) {
    shield_offset = 6;
}
```

#### Equipment Bobbing

Equipment bobbing disabled during shielding:
```gml
// Lines 99, 131
if (state != PlayerState.shielding) {
    // Apply bobbing
}
```

#### Rendering Order

Shield drawn in different layers based on facing direction for proper depth sorting.

### Cooldown System

**Normal Block:**
```gml
block_cooldown_max = 60;  // 1 second at 60fps
```

**Perfect Block:**
```gml
block_cooldown_perfect_max = 30;  // 0.5 seconds at 60fps
```

**Applied:** When O key released (shield lowered)

**Countdown:**
```gml
// In obj_player/Step_0.gml (lines 17-20)
if (block_cooldown > 0) {
    block_cooldown--;
}
```

### Planned Implementation (Not Yet Complete)

#### Damage Blocking

**Planned Mechanics:**
1. Check if player in shielding state during collision
2. Check if projectile/attack from front arc (based on `shield_facing_dir`)
3. If perfect block window active → destroy projectile, no damage
4. If normal block → reduce damage by shield's DR value
5. If blocked → apply shorter cooldown (perfect block cooldown)

**Required Integration Points:**
- `obj_enemy_arrow/Collision_obj_player.gml`
- `obj_hazard_projectile/Collision_obj_player.gml`
- `obj_enemy_parent/Collision_obj_player.gml` (melee attacks)
- Add shield-specific properties to item database

#### Directional Blocking

**Planned:**
- Calculate angle from attacker to player
- Check if within shield's blocking arc (typically 90-120 degrees)
- Only block attacks from front hemisphere

**Formula:**
```gml
var attack_angle = point_direction(x, y, attacker.x, attacker.y);
var shield_angle = direction_to_angle(shield_facing_dir);
var angle_diff = abs(angle_difference(attack_angle, shield_angle));

if (angle_diff <= block_arc / 2) {
    // Attack is within blocking arc
}
```

#### Shield Properties

**Planned Item Database Properties:**
```gml
shield: {
    item_id: "wooden_shield",
    type: ItemType.shield,
    stats: {
        block_dr: 5,              // DR when blocking
        perfect_block_dr: 999,     // Perfect block (full)
        block_arc: 90,             // Degrees of coverage
        block_cooldown: 60,        // Normal cooldown
        perfect_cooldown: 30       // Perfect cooldown
    }
}
```

### Implementation Tasks Remaining

See `.agent-os/specs/2025-10-16-shield-block-system/` for detailed implementation plan.

**Phase 2: Block Detection and Damage Reduction**
- Task 2.1: Add shield arc checking
- Task 2.2: Integrate with projectile collision
- Task 2.3: Apply DR from shield stats
- Task 2.4: Handle chip damage rules

**Phase 3: Perfect Block Mechanics**
- Task 3.1: Projectile destruction on perfect block
- Task 3.2: Visual/audio feedback enhancement
- Task 3.3: Apply perfect block cooldown

**Phase 4-6: Shield Properties, Stagger, Polish**
- Task 4: Per-shield stat configuration
- Task 5: Stagger mechanics on blocked hits
- Task 6: Integration testing and polish

### Key Files Reference

| File | Purpose | Key Lines |
|------|---------|-----------|
| `/scripts/player_state_shielding/player_state_shielding.gml` | Shielding state logic | Full file |
| `/scripts/player_handle_animation/player_handle_animation.gml` | Shield animations | 89-113 |
| `/objects/obj_player/Create_0.gml` | Variable initialization | 214-222 |
| `/objects/obj_player/Draw_0.gml` | Visual polish | 8, 99, 131 |
| `/scripts/player_state_idle/player_state_idle.gml` | Entry from idle | 6-16 |
| `/scripts/player_state_walking/player_state_walking.gml` | Entry from walking | 10-20 |

---

*Last Updated: 2025-10-16*
