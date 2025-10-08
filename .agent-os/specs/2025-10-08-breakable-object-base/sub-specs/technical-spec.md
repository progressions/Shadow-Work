# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-08-breakable-object-base/spec.md

> Created: 2025-10-08  
> Version: 1.0.0

## Technical Requirements

### Object Architecture

**obj_breakable (Parent Object)**  
Inherits from `obj_persistent_parent`.

- `max_hp = 1` – default durability for props; child objects may override.
- `hp = max_hp` – current durability.
- `state = BreakableState.idle` – enum stored in script (values: `idle`, `breaking`, `broken`).
- `idle_anim_speed = 0.15` – frames-per-step for looping the unbroken sway (frames 0–3).
- `break_anim_speed = 0.35` – frames-per-step for the one-shot break (frames 4–7).
- `idle_anim_timer = 0` – accumulates fractional frames for idle loop.
- `break_anim_timer = 0` – accumulates fractional frames while breaking.
- `idle_frame_range = {start: 0, end: 3}` – override-ready struct for variants with different frame windows.
- `break_frame_range = {start: 4, end: 7}` – start/end inclusive for the shatter sequence.
- `particle_config = {asset: spr_fx_leaf, count: 12, speed_min: 2, speed_max: 4, spread: 360, life: 20}` – overridable particle burst definition.
- `break_sfx = snd_breakable_grass` – sound asset played when break begins (children override).
- `record_persistence = true` – flag used to skip serialization when designers want temporary props.
- `is_destroyed = false` – toggled once breaking finishes; used in serialization.
- `attack_hit_token = -1` – stores `other.attack_instance_id` to prevent multi-hit from same swing.

**obj_breakable_grass (Child Object)**  
Parent set to `obj_breakable`.

- Assign `sprite_index = spr_breakable_grass`.
- Override `max_hp = 1`, `particle_config` with leafy palette, `break_sfx = snd_grass_rustle`.
- Optionally randomize idle phase offset in Create event for visual variety (`idle_anim_timer = random(idle_frame_range.end - idle_frame_range.start + 1)`).

### State Machine

1. **Idle** – Loops the `idle_frame_range`. Collision events accept melee damage. Particles inactive.
2. **Breaking** – Once `hp <= 0`, call `begin_break()`:  
   - Set `state = BreakableState.breaking`.  
   - Reset `break_anim_timer = 0`.  
   - Force `image_index = break_frame_range.start`.  
   - Disable further collision damage (`collision_mask_enabled = false`).  
   - Spawn particle burst and play `break_sfx`.  
3. **Broken** – After the break animation reaches `break_frame_range.end`, mark `is_destroyed = true`, serialize state, then call `instance_destroy()`; serialization ensures destroyed props don’t respawn.

### Damage Handling

Implement `Collision_obj_attack.gml` for `obj_breakable`.

```gml
/// obj_breakable :: Collision w/ obj_attack
if (state != BreakableState.idle) exit;

if (other.attack_category != AttackCategory.melee) exit; // ignore arrows & ranged

if (!ds_exists(other.hit_breakables, ds_type_list)) {
    other.hit_breakables = ds_list_create();
}

if (ds_list_find_index(other.hit_breakables, id) != -1) exit;
ds_list_add(other.hit_breakables, id);

hp -= max(1, other.damage); // breakables ignore DR; simple subtraction

if (hp <= 0) {
    begin_break(other);
}
```

Add `hit_breakables` list management to `obj_attack`:

- Create event: `hit_breakables = ds_list_create();`
- CleanUp event: destroy the list (`ds_list_destroy(hit_breakables)`).

### Animation Control

Set `image_speed = 0` in Create.

**Idle Loop (Step Event):**

```gml
if (state == BreakableState.idle) {
    idle_anim_timer += idle_anim_speed;
    var _frame_count = idle_frame_range.end - idle_frame_range.start + 1;
    var _offset = floor(idle_anim_timer) mod _frame_count;
    image_index = idle_frame_range.start + _offset;
}
```

**Breaking Sequence:**

```gml
else if (state == BreakableState.breaking) {
    break_anim_timer += break_anim_speed;
    var _progress = floor(break_anim_timer);
    var _frame = break_frame_range.start + _progress;
    image_index = clamp(_frame, break_frame_range.start, break_frame_range.end);

    if (_frame >= break_frame_range.end) {
        finish_break();
    }
}
```

### Particle Burst

Create helper script `scripts/environment_breakables/scr_spawn_breakable_particles.gml`:

```gml
function scr_spawn_breakable_particles(origin_x, origin_y, config) {
    var _count = config.count ?? 8;
    for (var i = 0; i < _count; i++) {
        var _dir = irandom_range(0, config.spread ?? 360);
        var _spd = random_range(config.speed_min ?? 1, config.speed_max ?? 4);
        var _life = irandom_range(config.life_min ?? 12, config.life ?? 20);
        var _fx = instance_create_layer(origin_x, origin_y, "FX", obj_fx_particle);
        with (_fx) {
            sprite_index = config.asset ?? spr_fx_leaf;
            image_index = irandom(sprite_get_number(sprite_index) - 1);
            direction = _dir;
            speed = _spd;
            image_angle = direction;
            life = _life;
            image_alpha = 1;
        }
    }
}
```

Call this helper inside `begin_break()` using the parent’s `particle_config`. Ensure `obj_fx_particle` supports configurable lifetime; if not, extend its Create/Step to read new properties (`direction`, `speed`, `life`).

### Persistence Integration

Override `serialize()` and `deserialize(data)` in `obj_breakable`:

```gml
function serialize() {
    var _data = inherited();
    _data.is_destroyed = is_destroyed;
    return _data;
}

function deserialize(_data) {
    inherited(_data);
    if (_data.is_destroyed) {
        is_destroyed = true;
        instance_destroy();
    }
}
```

When break completes, set `is_destroyed = true` before `instance_destroy()`. Room serialization will now remember broken props.

### Audio

Play `break_sfx` in `begin_break()`. If `break_sfx` is undefined, skip playback to avoid errors. Provide default `snd_breakable_generic` asset; `obj_breakable_grass` overrides with `snd_grass_rustle`.

## Implementation Plan

1. **Asset Prep**
   - Import/verify `spr_breakable_grass` (frames 0–7). Tag frame ranges (`unbroken` 0–3, `breaking` 4–7) inside GameMaker.
   - Add `snd_breakable_generic` and `snd_grass_rustle` if not already present.

2. **Parent Logic**
   - Implement Create, Step, Collision(`obj_attack`), and optional Destroy/CleanUp events for `obj_breakable`.
   - Add `BreakableState` enum to `scripts/environment_breakables/state_constants.gml`.
   - Create helper scripts `scr_spawn_breakable_particles`, `scr_breakable_begin_break`, `scr_breakable_finish_break` if splitting logic.

3. **Attack Adjustments**
   - Add `hit_breakables` list to `obj_attack` Create/CleanUp.
   - Expose `attack_instance_id` in `obj_attack` (incrementing ID) if needed for robust duplicate prevention.

4. **Child Configuration**
   - Update `obj_breakable_grass` to inherit parent, assign sprite, override particle config, and optionally randomize idle offset.
   - Place test instances in a sandbox room.

5. **Persistence Validation**
   - Break grass, leave room, return, confirm destroyed instances are gone.
   - Verify saving/loading replicates state.

6. **VFX Polish**
   - Tune particle speed/count per sprite.
   - Ensure FX layer depth keeps debris above terrain but below HUD.

## Code Organization

**New Files**
- `scripts/environment_breakables/state_constants.gml`
- `scripts/environment_breakables/scr_spawn_breakable_particles.gml`
- Optional helpers (`scr_breakable_begin_break.gml`, `scr_breakable_finish_break.gml`)

**Modified Files**
- `objects/obj_breakable/Create_0.gml`
- `objects/obj_breakable/Step_0.gml`
- `objects/obj_breakable/Collision_obj_attack.gml`
- `objects/obj_breakable/CleanUp_0.gml` (destroy temporary data structures if any)
- `objects/obj_breakable_grass/Create_0.gml`
- `objects/obj_attack/Create_0.gml` (add `hit_breakables` list)
- `objects/obj_attack/CleanUp_0.gml` (destroy `hit_breakables`)
- `rooms/<playtest_room>.yy` (place test instances)

**Assets**
- `sprites/spr_breakable_grass/spr_breakable_grass.yy` (ensure proper sequence)
- `sounds/snd_breakable_generic.yy`, `sounds/snd_grass_rustle.yy` (if new)

## External Dependencies

- Uses existing melee attack infrastructure (`obj_attack`, `AttackCategory` enum).
- Relies on `obj_persistent_parent` serialization pipeline.
- Particle system depends on `obj_fx_particle`; extend if missing properties (direction/speed/life).

## Risks & Mitigations

1. **Repeated Hits During Same Swing** – Without tracking, multi-frame collisions would overkill HP. Mitigate with `hit_breakables` list and state checks.
2. **Missing Particle Object** – If `obj_fx_particle` lacks configurable lifetime, debris might persist. Extend particle object to read runtime parameters.
3. **Sprite Tag Drift** – Designers must keep frame tags aligned (0–3 idle, 4–7 breaking). Document in object comment and design notes.
4. **Persistence Conflicts** – Destroying instances immediately after `serialize()` may double-save. Ensure `serialize()` runs before destruction or mark `is_destroyed` prior to calling `instance_destroy()`.

## Acceptance Checklist

- [ ] Breakable props animate idle sway and shatter on melee hits only.
- [ ] Particle burst and sound trigger exactly once per destruction.
- [ ] Destroyed props remain gone after room transitions and save/load.
- [ ] Child variants can override HP, particles, and sounds without modifying parent scripts.
- [ ] No memory leaks from DS lists (`hit_breakables`) or particle instances.
