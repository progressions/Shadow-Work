# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-02-player-ranged-attacks/spec.md

> Created: 2025-10-02
> Version: 1.0.0

## Technical Requirements

### 1. Ranged Weapon Detection

**Location**: `scripts/player_attacking/player_attacking.gml` - function `player_handle_attack_input()`

- Check if `equipped.right_hand` exists and has `definition.stats.requires_ammo` property
- Ranged weapons are identified by `stats.requires_ammo == "arrows"`
- Existing ranged weapons in database (scr_item_database.gml):
  - `wooden_bow` (frame 7): damage 2, range 120, two-handed
  - `longbow` (frame 8): damage 5, range 150, two-handed
  - `crossbow` (frame 9): damage 3, range 140, one-handed
  - `heavy_crossbow` (frame 10): damage 6, range 160, two-handed, armor penetration 0.3

### 2. Arrow Consumption Check

**Location**: `scripts/player_attacking/player_attacking.gml` - function `player_handle_attack_input()`

- Before spawning arrow, call `has_ammo("arrows")` to verify arrows in inventory
- If no arrows available, do not spawn projectile (optionally play "empty" sound)
- After spawning arrow, call `consume_ammo("arrows", 1)` to decrement arrow count
- Arrow item is defined in database as `global.item_database.arrows` (frame 24, stack_size 99)
- Existing functions in `scripts/scr_inventory_system/scr_inventory_system.gml`:
  - `has_ammo(_ammo_type)` at line 496
  - `consume_ammo(_ammo_type, _amount = 1)` at line 507

### 3. obj_arrow Projectile Object

**New Object**: Create `objects/obj_arrow/`

**Create Event** (`obj_arrow/Create_0.gml`):
- `creator = noone` - store reference to player who fired
- `damage = 0` - set by player based on equipped bow weapon damage
- `speed = 6` - built-in GameMaker speed property
- `direction = 0` - set based on player's `facing_dir` (0=right, 90=up, 180=left, 270=down)
- `image_angle = direction` - rotate sprite to match travel direction
- `sprite_index = spr_arrow` - arrow sprite (needs to be created)
- Set depth to draw arrow above ground but below UI

**Direction Mapping**:
```gml
switch (creator.facing_dir) {
    case "right": direction = 0; break;
    case "up": direction = 90; break;
    case "left": direction = 180; break;
    case "down": direction = 270; break;
}
```

**Step Event** (`obj_arrow/Step_0.gml`):
- Check for collision with `Tiles_Col` tilemap layer using `tilemap_get_at_pixel()`
  - If collision detected, play wall hit sound and destroy arrow
- Check for collision with `obj_enemy_parent` using `instance_place(x, y, obj_enemy_parent)`
  - If enemy hit, apply damage to enemy, play hit sounds, destroy arrow
- Check if arrow position is outside room bounds
  - If `x < 0 || x > room_width || y < 0 || y > room_height`, destroy arrow

**Collision with Tiles_Col**:
```gml
var _tilemap_col = layer_tilemap_get_id("Tiles_Col");
if (_tilemap_col != -1) {
    var _tile_value = tilemap_get_at_pixel(_tilemap_col, x, y);
    if (_tile_value != 0) {
        // Play arrow hit wall sound
        instance_destroy();
    }
}
```

**Collision with Enemy**:
```gml
var _hit_enemy = instance_place(x, y, obj_enemy_parent);
if (_hit_enemy != noone) {
    // Apply damage to enemy
    _hit_enemy.hp -= damage;

    // Play arrow hit enemy sound
    // Play enemy hit reaction sound (check _hit_enemy for custom sound, else default)

    instance_destroy();
}
```

### 4. Modify player_handle_attack_input()

**Location**: `scripts/player_attacking/player_attacking.gml`

**Current behavior** (line 28-59):
- Check `keyboard_check_pressed(ord("J"))` and `can_attack`
- Set `state = PlayerState.attacking`
- Create `obj_attack` for melee swing
- Calculate cooldown based on `attack_speed`

**New behavior**:
- After detecting J key press, check if equipped weapon is ranged
- **If ranged weapon**:
  - Check if arrows available with `has_ammo("arrows")`
  - If arrows available:
    - Play attack animation (set `state = PlayerState.attacking`)
    - Create `obj_arrow` instead of `obj_attack`
    - Set arrow properties: `creator`, `damage`, `direction`
    - Consume ammo with `consume_ammo("arrows", 1)`
    - Play bow firing sound
    - Calculate cooldown based on bow attack_speed
  - If no arrows: optionally play empty/click sound
- **If melee weapon**: existing behavior (spawn obj_attack)

**Pseudocode**:
```gml
if (keyboard_check_pressed(ord("J")) && can_attack) {
    var _is_ranged = false;

    if (equipped.right_hand != undefined &&
        equipped.right_hand.definition.type == ItemType.weapon) {

        if (equipped.right_hand.definition.stats[$ "requires_ammo"] != undefined) {
            _is_ranged = true;
        }
    }

    if (_is_ranged) {
        // Ranged attack logic
        if (has_ammo("arrows")) {
            state = PlayerState.attacking;

            var _arrow = instance_create_layer(x, y, "Instances", obj_arrow);
            _arrow.creator = self;
            _arrow.damage = get_total_damage();

            // Set direction based on facing_dir
            switch (facing_dir) {
                case "right": _arrow.direction = 0; break;
                case "up": _arrow.direction = 90; break;
                case "left": _arrow.direction = 180; break;
                case "down": _arrow.direction = 270; break;
            }
            _arrow.image_angle = _arrow.direction;

            consume_ammo("arrows", 1);

            // Play bow firing sound
            play_sfx(snd_bow_fire, 1, false);

            // Calculate cooldown
            var _attack_speed = equipped.right_hand.definition.stats.attack_speed;
            attack_cooldown = max(15, round(60 / _attack_speed));
            can_attack = false;
        }
    } else {
        // Existing melee attack logic (lines 29-59)
    }
}
```

### 5. Sound Effects Integration

**New sound assets needed** (create placeholders, user will replace):
- `snd_bow_fire` - Played when arrow is spawned
- `snd_arrow_hit_enemy` - Played when arrow collides with enemy
- `snd_arrow_hit_wall` - Played when arrow collides with Tiles_Col or goes offscreen

**Existing sound system**:
- Use `play_sfx(_sound, _volume, _loop)` function from scr_sfx_functions.gml
- Enemy hit reactions: enemies may have custom hit sounds defined, with fallback to default
- Reference existing melee sound: `snd_attack_sword` (line 49 of player_attacking.gml)

**Sound timing**:
1. **Arrow fire**: In `player_handle_attack_input()` when arrow spawns
2. **Arrow hit enemy**: In `obj_arrow` Step event when collision with enemy detected
3. **Enemy hit reaction**: In `obj_arrow` Step event after damage applied (check enemy for custom sound)
4. **Arrow hit wall**: In `obj_arrow` Step event when Tiles_Col collision detected

### 6. Attack State Management

**Current behavior**:
- Player enters `PlayerState.attacking` when J pressed (line 29)
- Player remains in attacking state until animation completes
- See `player_state_attacking()` function (line 7-16)

**New behavior for ranged attacks**:
- Player enters `PlayerState.attacking` when firing bow
- Attack animation plays (currently reuses melee animation)
- Player can exit attacking state and move freely after arrow spawns (non-blocking)
- Arrow projectile continues traveling independently

**Implementation note**: The existing `player_state_attacking()` function handles animation completion. For ranged attacks, the animation will play but the player is not locked into the state - movement input should be allowed while animation completes.

### 7. Sprite Assets

**New sprite required**:
- `spr_arrow` - Arrow projectile sprite
  - Recommended size: 16x4 pixels (or similar thin projectile)
  - Oriented horizontally by default (pointing right at 0 degrees)
  - Origin point: center-left (so rotation pivots from tail)

**Future sprite** (out of scope for this spec):
- Bow-specific attack animations for player
- Update `anim_data` struct in obj_player/Create_0.gml (lines 101-125) when bow animations added

### 8. Integration Points

**Files to modify**:
1. `scripts/player_attacking/player_attacking.gml` - Add ranged weapon detection and arrow spawning
2. Create new object: `objects/obj_arrow/` with Create and Step events

**Files to reference** (no changes needed):
- `scripts/scr_inventory_system/scr_inventory_system.gml` - Use existing ammo functions
- `scripts/scr_item_database/scr_item_database.gml` - Reference ranged weapon definitions
- `scripts/scr_combat_system/scr_combat_system.gml` - May contain damage calculation helpers

**Dependencies**:
- Existing `get_total_damage()` function (referenced in obj_attack/Create_0.gml line 5)
- Existing `play_sfx()` function from scr_sfx_functions.gml
- Existing `has_ammo()` and `consume_ammo()` functions
- Existing tilemap collision detection pattern

### 9. Testing Considerations

**Manual testing checklist**:
1. Equip bow weapon, verify J fires arrow when arrows in inventory
2. Verify arrow consumes 1 arrow from inventory per shot
3. Verify arrow travels in correct direction based on player facing
4. Verify arrow collides with walls (Tiles_Col) and destroys
5. Verify arrow damages and destroys on enemy collision
6. Verify arrow destroys when leaving room bounds
7. Verify player can move during/after arrow firing
8. Verify bow firing with 0 arrows does not spawn arrow
9. Verify attack cooldown applies correctly for different bow attack speeds
10. Verify sound effects play at correct moments

**Edge cases**:
- Firing arrow while standing next to wall (should immediately hit wall)
- Firing arrow at very close range enemy (should hit immediately)
- Switching from bow to melee weapon mid-cooldown
- Arrow traveling across room transitions (if applicable)
