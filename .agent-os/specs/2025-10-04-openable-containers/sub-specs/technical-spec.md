# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-04-openable-containers/spec.md

> Created: 2025-10-04
> Version: 1.0.0

## Technical Requirements

### Object Architecture

**obj_openable (Parent Object)**
- Inherits from: `obj_persistent_parent` (for save/load integration)
- Variables:
  - `is_opened = false` (boolean) - tracks if container has been opened
  - `interaction_radius = 32` (real) - distance for player interaction prompt
  - `loot_mode = "specific"` (string) - "specific" or "random_weighted"
  - `loot_items = []` (array) - array of item_key strings for specific mode
  - `loot_table = []` (array) - array of {item_key, weight} structs for weighted mode
  - `loot_count = 1` (real) - exact number of items to spawn (random_weighted mode)
  - `loot_count_min = 1` (real) - minimum items for variable quantity
  - `loot_count_max = 1` (real) - maximum items for variable quantity
  - `use_variable_quantity = false` (boolean) - whether to use min/max range
  - `openable_id = ""` (string) - unique persistent ID for save system

**Child Objects** (user has already created obj_chest)
- Existing: `obj_chest` inherits from `obj_openable`
- Future: `obj_barrel`, `obj_crate` can be created by duplicating obj_chest

### Animation System

**Sprite Requirements**
- All container sprites must have exactly 4 frames (0-3)
- Frame 0: Closed state (default)
- Frames 1-2: Opening transition
- Frame 3: Fully opened state (final)
- Set `image_speed = 0` in Create event to control animation manually
- Set `image_index = 0` initially

**Animation Control**
- Step Event: Manual frame advance using `image_index++`
- Animation trigger: When player presses SPACE within interaction_radius
- Animation completion: When `image_index >= 3`, freeze at frame 3
- Only play animation once (check `is_opened` flag)

### Player Interaction

**Collision Detection (Step Event)**
```gml
// Check if player is within interaction range
if (instance_exists(obj_player)) {
    var _dist = point_distance(x, y, obj_player.x, obj_player.y);
    var _in_range = (_dist <= interaction_radius);

    // Check for SPACE key press when in range and not opened
    if (_in_range && !is_opened && keyboard_check_pressed(vk_space)) {
        open_container();
    }
}
```

**Interaction Prompt (Draw Event)**
```gml
// Draw "[Space] Open" text above container when player in range
if (!is_opened && instance_exists(obj_player)) {
    var _dist = point_distance(x, y, obj_player.x, obj_player.y);
    if (_dist <= interaction_radius) {
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_text(x, y - 32, "[Space] Open");
        draw_set_halign(fa_left);
    }
}
```

### Loot Spawning System

**Integration with Existing Loot System**
- Reuse `find_loot_spawn_position(origin_x, origin_y)` from scr_enemy_loot_system
- Reuse `select_weighted_loot_item(loot_table)` for weighted selection
- Reuse `spawn_item(x, y, item_key, count)` for item creation

**Loot Mode: Specific Items**
```gml
// Spawn exact items from loot_items array
function spawn_specific_loot() {
    for (var i = 0; i < array_length(loot_items); i++) {
        var _item_key = loot_items[i];
        var _pos = find_loot_spawn_position(x, y);
        spawn_item(_pos.x, _pos.y, _item_key, 1);
    }
    play_sfx(snd_loot_drop);
}
```

**Loot Mode: Random Weighted**
```gml
// Spawn random items from weighted loot_table
function spawn_random_loot() {
    var _count = use_variable_quantity ?
        irandom_range(loot_count_min, loot_count_max) :
        loot_count;

    for (var i = 0; i < _count; i++) {
        var _item_key = select_weighted_loot_item(loot_table);
        var _pos = find_loot_spawn_position(x, y);
        spawn_item(_pos.x, _pos.y, _item_key, 1);
    }
    play_sfx(snd_loot_drop);
}
```

**Main Open Function**
```gml
function open_container() {
    if (is_opened) return;

    is_opened = true;
    play_sfx(snd_chest_open);
    // Animation will be handled in Step event
}
```

**Step Event Animation + Loot Spawn**
```gml
// Advance opening animation
if (is_opened && image_index < 3) {
    image_index += 0.2; // Animate over ~15 frames (60fps / 0.2 = ~1/4 second)

    // Spawn loot when animation completes
    if (image_index >= 3) {
        image_index = 3; // Freeze on final frame

        // Spawn loot based on mode
        if (loot_mode == "specific") {
            spawn_specific_loot();
        } else if (loot_mode == "random_weighted") {
            spawn_random_loot();
        }
    }
}
```

### Save/Load Integration

**Serialization (inherits from obj_persistent_parent)**
```gml
function serialize() {
    return {
        openable_id: object_get_name(object_index) + "_" + string(x) + "_" + string(y),
        is_opened: is_opened,
        x: x,
        y: y,
        object_type: object_get_name(object_index)
    };
}

function deserialize(_data) {
    is_opened = _data.is_opened;
    image_index = is_opened ? 3 : 0; // Set to opened sprite if already opened
}
```

**Room State Integration**
- Add openable containers to `serialize_room_state()` collection
- Track opened containers in `global.opened_containers` array (similar to picked_up_items)
- Prevent re-spawning loot from already-opened containers

### Audio Integration

**Sound Effects**
- `snd_chest_open` - plays when container begins opening animation (already exists)
- `snd_loot_drop` - plays when animation completes and items spawn (may need to be created)

**Sound Timing**
- **Opening Sound**: Play `snd_chest_open` immediately when `open_container()` is called (when player presses SPACE)
- **Loot Drop Sound**: Play `snd_loot_drop` when animation reaches frame 3 and items spawn

**Implementation**
- Use existing `play_sfx(sound_resource)` function from scr_sfx_functions
- Opening sound plays before animation starts
- Loot drop sound plays after animation completes (in Step event when spawning items)

### Configuration Examples

**Example 1: Quest Reward Chest (Specific Items)**
```gml
// In obj_chest child's Create event
loot_mode = "specific";
loot_items = ["master_sword", "health_potion", "gold_coin"];
```

**Example 2: Random Loot Chest (Fixed Quantity)**
```gml
loot_mode = "random_weighted";
loot_count = 2;
loot_table = [
    {item_key: "gold_coin", weight: 50},
    {item_key: "health_potion", weight: 30},
    {item_key: "rare_gem", weight: 5}
];
```

**Example 3: Variable Loot Barrel (1-3 Items)**
```gml
loot_mode = "random_weighted";
use_variable_quantity = true;
loot_count_min = 1;
loot_count_max = 3;
loot_table = [
    {item_key: "apple", weight: 40},
    {item_key: "bread", weight: 30},
    {item_key: "cheese", weight: 20}
];
```

## Approach

### Implementation Order

1. **Phase 1: Core Container Object**
   - Implement obj_openable Create event with all variables
   - Add Step event for interaction detection and animation
   - Add Draw event for interaction prompt
   - Implement open_container() function

2. **Phase 2: Loot Spawning**
   - Implement spawn_specific_loot() function
   - Implement spawn_random_loot() function
   - Integrate with existing scr_enemy_loot_system functions
   - Add loot spawn timing in animation completion

3. **Phase 3: Save/Load Integration**
   - Implement serialize() and deserialize() methods
   - Add container tracking to global save state
   - Update serialize_room_state() to include containers
   - Test container state persistence across room transitions

4. **Phase 4: Child Objects**
   - Configure obj_chest as first implementation
   - Create obj_barrel and obj_crate by duplication
   - Set up appropriate sprites for each type

5. **Phase 5: Audio Polish**
   - Verify snd_chest_open exists and is properly integrated
   - Create snd_loot_drop if needed
   - Test audio timing with animation

### Code Organization

**Files to Modify:**
- `/objects/obj_openable/Create_0.gml` - Initialize all variables
- `/objects/obj_openable/Step_0.gml` - Interaction detection and animation
- `/objects/obj_openable/Draw_0.gml` - Interaction prompt rendering
- `/objects/obj_chest/Create_0.gml` - Example loot configuration
- `/scripts/scr_save_system/scr_save_system.gml` - Add container state tracking

**Files to Reference (DO NOT MODIFY):**
- `/scripts/scr_enemy_loot_system/*.gml` - Existing loot functions to reuse
- `/scripts/scr_sfx_functions/*.gml` - Existing audio playback functions

### Design Patterns

**Ruby-Style Conventions:**
- All function names use snake_case: `open_container()`, `spawn_specific_loot()`
- All variable names use snake_case: `is_opened`, `loot_items`, `interaction_radius`
- Local variables prefixed with underscore: `_dist`, `_item_key`, `_pos`

**GameMaker Patterns:**
- Manual sprite animation control using `image_speed = 0` and `image_index`
- Distance checks using `point_distance()` for interaction range
- Draw events for UI elements (interaction prompt)
- Parent/child object hierarchy for shared behavior

**Integration Points:**
- Quest system: Items spawned from containers auto-tracked for "collect" objectives
- Inventory system: Items use existing `spawn_item()` which creates obj_item instances
- Save system: Containers inherit from obj_persistent_parent for state persistence

## External Dependencies

### Existing Systems Required

**Loot System Functions (scr_enemy_loot_system):**
- `find_loot_spawn_position(origin_x, origin_y)` - Returns {x, y} struct for item placement
- `select_weighted_loot_item(loot_table)` - Returns item_key string based on weights
- `spawn_item(x, y, item_key, count)` - Creates obj_item instance at position

**Audio System (scr_sfx_functions):**
- `play_sfx(sound_resource)` - Plays sound effect with proper audio group

**Save System (scr_save_system):**
- `serialize_room_state()` - Needs update to include openable containers
- `deserialize_room_state(_data)` - Needs update to restore container states
- `obj_persistent_parent` - Parent object providing serialization interface

**Item Database (global.item_database):**
- All item_key strings in loot_items or loot_table must exist in database
- Item definitions used when spawning items

### Sound Assets

**Required:**
- `snd_chest_open` - Already exists in project

**Optional (may need creation):**
- `snd_loot_drop` - Sound effect for items spawning from container
- `snd_barrel_break` - Alternative open sound for destructible containers
- `snd_crate_open` - Alternative open sound for wooden crates

### Sprite Assets

**Required Structure:**
- All container sprites must be exactly 4 frames
- Frame timing: 0 (closed) → 1 (opening) → 2 (opening) → 3 (opened)
- Sprite origin should be centered for proper positioning

**Existing:**
- `spr_chest` - Already created by user

**Future Additions:**
- `spr_barrel` - Barrel container sprite
- `spr_crate` - Wooden crate sprite
- `spr_locked_chest` - Variant requiring keys (future enhancement)

### Quest System Integration

**No modifications required to quest system:**
- Container-spawned items automatically tracked via existing `inventory_add_item()` function
- Quest "collect" objectives work automatically when items are picked up
- No special quest_update_progress() calls needed

### Potential Issues

1. **Loot Spawn Position Conflicts:**
   - Multiple items may spawn in same location if container is near walls
   - Solution: Existing `find_loot_spawn_position()` should handle collision checks

2. **Save/Load Timing:**
   - Player could save while container is mid-animation
   - Solution: Store `is_opened` flag, not animation frame; deserialize sets final frame

3. **Multiple Containers in Range:**
   - Player could be in range of multiple containers simultaneously
   - Solution: Interaction prompt may overlap; consider z-ordering or distance priority in future

4. **Item Database Validation:**
   - Invalid item_key in loot_items/loot_table will cause runtime errors
   - Solution: Add debug validation in Create event to warn about missing items
