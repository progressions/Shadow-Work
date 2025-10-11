# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-11-ranged-attack-windup/spec.md

> Created: 2025-10-11
> Version: 1.0.0

## Technical Requirements

### 1. New Properties on obj_enemy_parent

Add to Create_0.gml:
```gml
// Ranged attack windup configuration
ranged_windup_speed = 0.5;           // Animation speed multiplier during windup (0.1-1.0)
ranged_windup_complete = false;      // Tracks if first animation cycle finished
```

Add to enemy_sounds struct:
```gml
enemy_sounds = {
    on_melee_attack: undefined,
    on_ranged_attack: undefined,
    on_ranged_windup: undefined,     // NEW: Plays when ranged attack animation starts
    on_hit: undefined,
    on_death: undefined,
    on_aggro: undefined,
    on_footstep: undefined,
    on_status_effect: undefined
}
```

Set default windup sound in obj_enemy_parent Create_0.gml:
```gml
// Default sound fallbacks
if (enemy_sounds.on_ranged_windup == undefined) {
    enemy_sounds.on_ranged_windup = snd_bow_draw; // New default sound asset
}
```

### 2. Modify enemy_handle_ranged_attack.gml

**Current flow** (projectile spawns immediately):
```gml
// Line 81-91 in enemy_handle_ranged_attack.gml
state = EnemyState.ranged_attacking;
var _arrow = instance_create_layer(x, y, layer, obj_enemy_arrow);
// ... configure arrow ...
play_enemy_sfx("on_ranged_attack");
ranged_attack_cooldown = max(15, round(60 / ranged_attack_speed));
```

**New flow** (windup → projectile):
```gml
// Enter windup phase
state = EnemyState.ranged_attacking;
ranged_windup_complete = false;
anim_timer = 0; // Reset animation to start
play_enemy_sfx("on_ranged_windup"); // NEW: Windup sound
// DO NOT spawn projectile yet
ranged_attack_cooldown = max(15, round(60 / ranged_attack_speed));
```

### 3. Modify Animation Speed in obj_enemy_parent Step_0.gml

**Current ranged animation** (line 277-298):
```gml
case EnemyState.ranged_attacking:
    var _base_anim = "ranged_attack_" + dir_suffix;
    // ... animation lookup ...
    anim_timer += anim_speed * speed_mult; // Uses standard speed
```

**New ranged animation** (with windup speed):
```gml
case EnemyState.ranged_attacking:
    var _base_anim = "ranged_attack_" + dir_suffix;
    // ... animation lookup ...

    // Use slower windup speed until first cycle completes
    var _speed_mult = ranged_windup_complete ? speed_mult : (speed_mult * ranged_windup_speed);
    anim_timer += anim_speed * _speed_mult;

    var frame_offset = floor(anim_timer) mod frames_in_seq;
    image_index = start_frame + frame_offset;

    // Check if first animation cycle completed
    if (!ranged_windup_complete && floor(anim_timer) >= frames_in_seq) {
        ranged_windup_complete = true;
        spawn_ranged_projectile(); // NEW: Spawn projectile after windup
        play_enemy_sfx("on_ranged_attack"); // Play attack sound with spawn
    }
```

### 4. Create spawn_ranged_projectile() Function

Extract projectile spawning logic into reusable function in `/scripts/scr_enemy_ai/scr_enemy_ai.gml`:

```gml
/// @function spawn_ranged_projectile()
/// @description Spawns ranged projectile from enemy (called after windup completes)
function spawn_ranged_projectile() {
    var _arrow = instance_create_layer(x, y, layer, obj_enemy_arrow);
    _arrow.speed = ranged_projectile_speed;
    _arrow.direction = point_direction(x, y, obj_player.x, obj_player.y);
    _arrow.image_angle = _arrow.direction;
    _arrow.damage = ranged_damage;
    _arrow.damage_type = ranged_damage_type;
    _arrow.owner = id;
}
```

Call this function from:
- `enemy_handle_ranged_attack.gml` (removed - no longer spawns immediately)
- `obj_enemy_parent/Step_0.gml` ranged_attacking case (NEW - spawns after windup)

### 5. State Reset Behavior

When `ranged_attack_cooldown <= 0` and returning to targeting state, reset windup flag:
```gml
if (ranged_attack_cooldown <= 0) {
    state = EnemyState.targeting;
    ranged_windup_complete = false; // Reset for next attack
}
```

### 6. Sound Asset Requirements

Create new sound asset (or use existing placeholder):
- **snd_bow_draw** - Default windup sound (bow creak, crossbow wind, etc.)
- Should be ~0.3-0.5 seconds duration
- Can have variants: `snd_bow_draw_1`, `snd_bow_draw_2`, etc. (auto-handled by play_sfx system)

### 7. Per-Enemy Configuration Examples

Child enemies can override in Create_0.gml:
```gml
event_inherited();

// Fast archer - quick windup
ranged_windup_speed = 0.7;
enemy_sounds.on_ranged_windup = snd_bow_draw_fast;

// Heavy crossbowman - slow windup
ranged_windup_speed = 0.3;
enemy_sounds.on_ranged_windup = snd_crossbow_crank;
```

## Approach

This implementation uses a two-phase state machine for ranged attacks:

1. **Windup Phase** - State enters ranged_attacking, animation plays at reduced speed (`ranged_windup_speed` multiplier), windup sound plays, no projectile spawned yet
2. **Release Phase** - After first animation cycle completes (`anim_timer >= frames_in_seq`), projectile spawns, attack sound plays, animation continues at normal speed

The `ranged_windup_complete` flag tracks which phase we're in and resets when exiting the ranged_attacking state. This approach allows for smooth animation transitions while providing clear telegraphing.

## Integration Points

### Dual-Mode Enemy Compatibility
- System works automatically for dual-mode enemies (obj_enemy_parent handles both)
- No special dual-mode logic needed - windup applies whenever `state == EnemyState.ranged_attacking`

### Enemy Party Formation Compatibility
- Ranged enemies in rear/support roles benefit from longer telegraph
- Party controller doesn't need updates - enemies handle their own windup timing

### Animation System Compatibility
- Uses existing `anim_timer` and animation frame calculation
- Works with both standard 47-frame dual-mode layout and custom overrides via `enemy_anim_overrides`

### Sound System Compatibility
- Uses existing `play_enemy_sfx()` infrastructure
- Supports sound variants automatically (e.g., `snd_bow_draw`, `snd_bow_draw_1`, `snd_bow_draw_2`)

## Edge Cases & Testing

1. **Interrupt Handling** - If enemy takes damage during windup, should windup continue?
   - Current spec: Windup continues (damage doesn't interrupt animation state)
   - Future enhancement: Add interrupt mechanics if needed

2. **Very Fast Windup (0.9-1.0 speed)** - Ensure projectile still spawns correctly
   - Test with `ranged_windup_speed = 1.0` (no slowdown) to verify logic works

3. **Very Slow Windup (0.1-0.2 speed)** - Ensure animation doesn't look frozen
   - Test visibility of frame transitions at extreme slow speeds

4. **State Transitions** - If enemy loses LOS during windup, what happens?
   - Current behavior: `enemy_handle_combat_exit()` handles state changes
   - Should reset `ranged_windup_complete` when exiting ranged_attacking state

5. **Dual-Mode Switching** - Can enemy switch to melee during windup?
   - Current spec: Yes, state change resets windup flag
   - Ensure no orphaned attack sounds or projectiles

## Performance Considerations

- Minimal performance impact (one boolean check per frame during ranged attacks)
- No additional collision checks or pathfinding overhead
- Sound system already optimized for frequent calls

## External Dependencies

- **Sound Asset** - Requires `snd_bow_draw` (or equivalent) to be created/imported
- **Existing Systems** - Relies on current enemy animation system, sound system, and state machine
- **No New Objects** - No new GameMaker objects required, all modifications to existing parent
