# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-07-hazard-parent-system/spec.md

## Technical Requirements

### Object Structure

**obj_hazard_parent**
- Inherit from `obj_persistent_parent` for save/load support
- Implement `serialize()` and `deserialize()` methods
- Use `depth = -y` or similar for proper layering with player/enemies

### Instance Variables (Configurable in Room Editor)

**Damage Configuration:**
```gml
damage_mode = "none";              // "none", "continuous", "on_enter"
damage_amount = 0;                 // Damage per application
damage_type = DamageType.physical; // Using existing DamageType enum
damage_interval = 1.0;             // Seconds between damage ticks (continuous mode)
damage_immunity_duration = 0.5;    // Seconds of immunity after taking damage
```

**Trait Configuration:**
```gml
trait_to_apply = "";               // Trait key (e.g., "burning", "wet", "slowed")
trait_duration = 3.0;              // Duration in seconds for applied trait
trait_mode = "on_enter";           // "none", "on_enter"
// Note: Trait system handles duration, stacking, and refreshing automatically
```

**Audio Configuration:**
```gml
sfx_loop = undefined;              // Looping background sound (e.g., snd_fire_loop)
sfx_enter = undefined;             // Sound when entity enters hazard
sfx_exit = undefined;              // Sound when entity exits hazard
sfx_damage = undefined;            // Sound when damage is applied
```

**Animation:**
```gml
sprite_index = spr_hazard_fire;    // Configurable hazard sprite
image_speed = 0.2;                 // Animation speed
```

### Collision Tracking

**Per-Entity State Tracking:**
```gml
// Track which entities are currently in the hazard
entities_inside = ds_list_create();

// Track damage immunity timers per entity (prevents instant death from continuous damage)
damage_immunity_map = ds_map_create();

// Note: Trait duration/stacking is handled by the existing trait system
```

### Event Implementation

**Create Event:**
- Initialize all instance variables with defaults
- Create data structures (ds_list, ds_maps)
- Start looping SFX if configured

**Step Event:**
- Update damage immunity timers (decrement all entries in damage_immunity_map)
- If damage_mode == "continuous":
  - For each entity in entities_inside:
    - Check if damage immunity expired
    - Apply damage using existing damage calculation pipeline
    - Set damage immunity timer
    - Play damage SFX
    - Spawn damage number

**Collision with obj_player:**
- Add player to entities_inside list (if not already present)
- Play enter SFX on first entry
- If damage_mode == "on_enter" and no damage immunity:
  - Apply damage
  - Set damage immunity timer
- If trait_mode == "on_enter":
  - Apply trait using `apply_timed_trait(trait_to_apply, trait_duration)`
  - Trait system automatically handles duration, stacking, and refreshing

**Collision with obj_enemy_parent:**
- Same logic as player collision
- Use enemy's trait and damage systems

**Collision End (Other) Event:**
- Remove entity from entities_inside list
- Play exit SFX
- Optional: Remove entity from tracking maps (or let timers expire naturally)

**Destroy Event:**
- Clean up data structures (entities_inside, damage_immunity_map)
- Stop looping SFX

**Draw Event (optional):**
- Draw sprite with animations
- Optional: Draw debug visualization showing hazard bounds

### Integration Points

**Damage Calculation:**
- Use existing `get_damage_modifier_for_type(damage_type)` from trait system
- Apply through player/enemy damage pipeline (respects DR, companion bonuses, etc.)
- Spawn damage numbers using `spawn_damage_number(x, y, damage, damage_type, target)`

**Trait Application:**
- Use existing `apply_timed_trait(trait_key, duration)` function
- Leverages existing trait stacking and cancellation system
- Immunities automatically block trait application (e.g., fire_immunity blocks burning)

**Audio System:**
- Use `play_sfx()` for one-shot sounds (enter/exit/damage)
- Use looping SFX controller for background hazard sounds
- Integrate with existing sound variant system

**Visual Feedback:**
- Spawn damage numbers on damage application
- Use existing `spawn_floating_text()` for trait application feedback (optional)
- Support animated sprites with standard GameMaker image_speed

### Serialization

**serialize() method:**
```gml
return {
    x: x,
    y: y,
    damage_mode: damage_mode,
    damage_amount: damage_amount,
    damage_type: damage_type,
    damage_interval: damage_interval,
    trait_to_apply: trait_to_apply,
    trait_duration: trait_duration,
    sprite_index: sprite_get_name(sprite_index),
    image_speed: image_speed
    // Don't serialize temporary state (entities_inside, timers)
};
```

**deserialize() method:**
```gml
function deserialize(data) {
    x = data.x;
    y = data.y;
    damage_mode = data.damage_mode;
    damage_amount = data.damage_amount;
    damage_type = data.damage_type;
    damage_interval = data.damage_interval;
    trait_to_apply = data.trait_to_apply;
    trait_duration = data.trait_duration;
    sprite_index = asset_get_index(data.sprite_index);
    image_speed = data.image_speed;
}
```

### Example Hazard Configurations

**Fire Hazard (Lava Pool):**
```gml
damage_mode = "continuous";
damage_amount = 2;
damage_type = DamageType.fire;
damage_interval = 0.5;
damage_immunity_duration = 0.5;
trait_to_apply = "burning";
trait_duration = 3.0;
trait_mode = "on_enter";  // Trait system handles duration/stacking
sprite_index = spr_hazard_lava;
sfx_loop = snd_fire_loop;
sfx_enter = snd_fire_enter;
sfx_damage = snd_fire_damage;
```

**Poison Cloud:**
```gml
damage_mode = "continuous";
damage_amount = 1;
damage_type = DamageType.poison;
damage_interval = 1.0;
trait_to_apply = "poison_vulnerability";
trait_duration = 5.0;
trait_mode = "on_enter";  // Trait system handles duration/stacking
sprite_index = spr_hazard_poison_cloud;
sfx_loop = snd_poison_hiss;
```

**Ice Patch:**
```gml
damage_mode = "none";
trait_to_apply = "slowed";
trait_duration = 2.0;
trait_mode = "on_enter";  // Trait system handles duration/stacking
sprite_index = spr_hazard_ice;
sfx_enter = snd_ice_slide;
```

### Performance Considerations

- Use `ds_list` and `ds_map` for efficient entity tracking
- Clean up data structures properly in Destroy event
- Limit collision checks to active entities only
- Damage immunity prevents excessive damage calculations
- Trait system handles all trait duration/stacking logic (no redundant tracking needed)

### Testing Checklist

1. Player takes damage in continuous mode at correct intervals
2. Damage immunity period prevents instant death
3. Player takes damage once on-enter mode
4. Traits apply on collision with correct duration (handled by trait system)
5. Traits respect immunities (fire_immunity blocks burning)
6. Trait system handles re-application on re-entry (stacking/refreshing as appropriate)
7. Enemies take damage and apply traits same as player
8. Audio cues play on enter/exit/damage
9. Damage numbers spawn with correct type color
10. Hazard state persists across save/load
11. Multiple hazards don't interfere with each other
12. Companion auras reduce hazard damage appropriately
