# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-15-chain-boss-system/spec.md

> Created: 2025-10-15
> Version: 1.0.0

## Technical Requirements

### Object Structure

**obj_chain_boss_parent** (inherits from obj_enemy_parent)
- Configuration variables:
  - `auxiliary_count` (2-5) - Number of auxiliary enemies to spawn
  - `auxiliary_object` - Object type for auxiliaries (e.g., obj_chain_minion)
  - `chain_max_length` (default: 96 pixels) - Maximum distance from boss center
  - `chain_sprite` - Sprite to use for chain links (vertical sprite stretched/rotated)
  - `enrage_attack_speed_multiplier` (default: 1.5) - Attack speed increase when enraged
  - `enrage_move_speed_multiplier` (default: 1.3) - Movement speed increase when enraged
  - `enrage_damage_multiplier` (default: 1.2) - Damage increase when enraged
- Arrays:
  - `auxiliaries[]` - References to spawned auxiliary instances
  - `chain_data[]` - Structs containing chain state per auxiliary
- State management:
  - `is_enraged` (boolean) - Tracks if boss entered enrage phase
  - `auxiliaries_alive` (integer) - Counter decremented when auxiliaries die

**Auxiliary Enemy Setup**
- Each auxiliary needs reference to controlling boss: `chain_boss = noone`
- Auxiliaries use existing enemy AI (obj_enemy_parent inheritance) for player chasing
- Movement constrained by chain length in Step event

### Chain Rendering System

**Approach: Sprite-Based Dynamic Stretching**

Use a vertical chain link sprite (e.g., 2px wide × 8px tall single link) that gets:
1. **Stretched** - `image_yscale` adjusted based on distance between boss and auxiliary
2. **Rotated** - `image_angle` set to angle between boss and auxiliary
3. **Positioned** - Drawn from boss center toward auxiliary

**Tension Calculation:**
```gml
// In boss Draw event (for each auxiliary)
var _dist = point_distance(x, y, aux.x, aux.y);
var _angle = point_direction(x, y, aux.x, aux.y);
var _tension_ratio = _dist / chain_max_length;  // 0.0 to 1.0

// Sag calculation (catenary-like curve)
var _sag_amount = 0;
if (_tension_ratio < 0.7) {
    // When slack, chains sag
    _sag_amount = (1 - _tension_ratio) * 12;  // Max 12 pixels sag
}

// Draw chain with midpoint offset for sag
var _mid_x = (x + aux.x) / 2;
var _mid_y = (y + aux.y) / 2;
var _sag_angle = _angle + 90;  // Perpendicular to chain
_mid_x += lengthdir_x(_sag_amount, _sag_angle);
_mid_y += lengthdir_y(_sag_amount, _sag_angle);

// Draw as two segments: boss → midpoint → auxiliary
draw_chain_segment(x, y, _mid_x, _mid_y, chain_sprite);
draw_chain_segment(_mid_x, _mid_y, aux.x, aux.y, chain_sprite);
```

**Helper Function:**
```gml
function draw_chain_segment(x1, y1, x2, y2, sprite) {
    var _dist = point_distance(x1, y1, x2, y2);
    var _angle = point_direction(x1, y1, x2, y2);
    var _scale = _dist / sprite_get_height(sprite);

    draw_sprite_ext(
        sprite, 0,
        x1, y1,
        1, _scale,  // Stretch vertically
        _angle,
        c_white, 1
    );
}
```

### Distance Constraint System

**Implementation Location:** Auxiliary Step event (after movement calculation)

```gml
// In auxiliary Step event (after normal enemy movement)
if (instance_exists(chain_boss)) {
    var _dist = point_distance(x, y, chain_boss.x, chain_boss.y);

    if (_dist > chain_boss.chain_max_length) {
        // Clamp to max chain length
        var _angle = point_direction(chain_boss.x, chain_boss.y, x, y);
        x = chain_boss.x + lengthdir_x(chain_boss.chain_max_length, _angle);
        y = chain_boss.y + lengthdir_y(chain_boss.chain_max_length, _angle);

        // Optional: Stop pathfinding when hitting chain limit
        if (path_exists(path)) {
            path_end();
        }
    }
}
```

### Auxiliary Spawn System

**Implementation Location:** obj_chain_boss_parent Create event

```gml
// After event_inherited()
auxiliaries = [];
chain_data = [];
auxiliaries_alive = auxiliary_count;
is_enraged = false;

// Spawn auxiliaries in circle formation around boss
var _angle_step = 360 / auxiliary_count;
var _spawn_radius = chain_max_length * 0.5;  // Spawn at half chain length

for (var i = 0; i < auxiliary_count; i++) {
    var _angle = i * _angle_step;
    var _spawn_x = x + lengthdir_x(_spawn_radius, _angle);
    var _spawn_y = y + lengthdir_y(_spawn_radius, _angle);

    var _aux = instance_create_depth(_spawn_x, _spawn_y, depth, auxiliary_object);
    _aux.chain_boss = self;

    array_push(auxiliaries, _aux);
    array_push(chain_data, {
        auxiliary: _aux,
        tension: 0.5  // Initial tension state
    });
}
```

### Enrage Phase System

**Trigger Detection:** Check in boss Step event

```gml
// Check if all auxiliaries are dead
if (!is_enraged && auxiliaries_alive <= 0) {
    is_enraged = true;

    // Apply enrage multipliers
    attack_speed *= enrage_attack_speed_multiplier;
    move_speed *= enrage_move_speed_multiplier;
    attack_damage *= enrage_damage_multiplier;

    // Optional: Visual feedback
    image_blend = c_red;

    // Optional: Play enrage sound
    play_enemy_sfx("on_enrage");
}
```

**Auxiliary Death Handling:** In auxiliary Destroy event

```gml
// Notify boss of death
if (instance_exists(chain_boss)) {
    chain_boss.auxiliaries_alive--;

    // Remove from boss's auxiliary array
    for (var i = 0; i < array_length(chain_boss.auxiliaries); i++) {
        if (chain_boss.auxiliaries[i] == self) {
            array_delete(chain_boss.auxiliaries, i, 1);
            array_delete(chain_boss.chain_data, i, 1);
            break;
        }
    }
}
```

### Performance Considerations

1. **Chain Drawing:** Draw chains in boss Draw event (not auxiliary Draw) to centralize and avoid duplicates
2. **Constraint Checking:** Only check chain constraint after auxiliary movement (not every frame unnecessarily)
3. **Array Management:** Use array_delete instead of recreating arrays when auxiliaries die
4. **Sprite Optimization:** Use simple chain sprite (2×8 pixels) to minimize draw calls

### Integration with Existing Systems

- **Enemy Parent Inheritance:** Chain boss uses all existing enemy systems (pathfinding, combat, traits, animations)
- **Auxiliary AI:** Auxiliaries are standard enemies with added chain constraint
- **Sound System:** Enrage trigger can use existing `play_enemy_sfx()` infrastructure
- **Animation:** Boss can use standard enemy animations, enrage visual via `image_blend`

## Approach

### Implementation Phases

**Phase 1: Core Chain System**
1. Create obj_chain_boss_parent with configuration variables
2. Implement auxiliary spawn system in Create event
3. Add chain constraint logic to auxiliary Step event
4. Create chain sprite asset (2×8 pixel vertical chain link)

**Phase 2: Chain Rendering**
1. Implement draw_chain_segment() helper function
2. Add Draw event to obj_chain_boss_parent
3. Implement tension calculation and sag simulation
4. Test visual appearance at various distances

**Phase 3: Enrage System**
1. Add enrage detection in boss Step event
2. Implement auxiliary death notification in Destroy event
3. Apply stat multipliers on enrage trigger
4. Add visual/audio feedback for enrage

**Phase 4: Testing & Polish**
1. Create test boss instance (e.g., obj_chained_orc_boss)
2. Test with different auxiliary counts (2, 3, 4, 5)
3. Verify chain constraints work correctly
4. Test enrage phase triggers properly

### Alternative Approaches Considered

**Vertex Buffer Chain Rendering**
- More flexible for complex chain physics
- Overkill for simple distance-based sag
- Higher implementation complexity
- **Rejected:** Sprite stretching sufficient for visual requirements

**Individual Chain Link Objects**
- Create separate objects for each chain segment
- Would allow per-link collision detection
- Excessive object creation overhead
- **Rejected:** Not needed for visual-only chains

**Fixed Formation Without Chains**
- Simpler implementation (no constraint system)
- Less interesting boss mechanic
- No visual feedback for auxiliary positioning
- **Rejected:** Chains are core to boss identity

## External Dependencies

No new external dependencies required. This feature uses existing GameMaker built-in functions:
- `draw_sprite_ext()` for chain rendering
- `point_distance()` / `point_direction()` for chain calculations
- `lengthdir_x()` / `lengthdir_y()` for position calculations
- Standard GML array functions for auxiliary management
- Existing obj_enemy_parent inheritance for all AI/combat systems
