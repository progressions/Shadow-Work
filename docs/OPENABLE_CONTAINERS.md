# Openable Container System

## Overview

The openable container system provides an inheritable framework for creating interactive chests, barrels, crates, and other lootable objects in Shadow Work. Containers feature a 4-frame opening animation, flexible loot configuration, and full save/load persistence.

## Object Hierarchy

```
obj_persistent_parent (base persistence)
└── obj_openable (container base class)
    ├── obj_chest (treasure chests)
    ├── obj_barrel (barrels - food/consumables)
    └── obj_crate (crates - tools/materials)
```

## Core Features

### Animation System

Containers use a 4-frame sprite with manual animation control:
- **Frame 0**: Closed state (idle)
- **Frames 1-2**: Opening transition
- **Frame 3**: Fully open (final state)

Animation plays once when opened at 0.2 frame increment speed (~15 frames at 60fps).

### Player Interaction

- **Interaction radius**: 32 pixels
- **Input**: SPACE key
- **Visual feedback**: `obj_interaction_prompt` displays "[Space] Open" text above container
  - Uses `fnt_arial` font at 0.35 scale
  - White text with black outline (4-way)
  - Always renders on top (depth -9999)
  - Follows parent container position

### Loot Configuration

Containers support three loot modes:

#### 1. Specific Items Mode
Spawns exact items every time:
```gml
loot_mode = "specific";
loot_items = ["health_potion", "short_sword", "leather_helmet"];
```

#### 2. Random Weighted Mode (Fixed Count)
Spawns fixed number of random items from weighted table:
```gml
loot_mode = "random_weighted";
loot_count = 2;  // Always spawn 2 items
loot_table = [
    {item_key: "health_potion", weight: 50},  // 50% chance
    {item_key: "rusty_dagger", weight: 30},   // 30% chance
    {item_key: "short_sword", weight: 15},    // 15% chance
    {item_key: "master_sword", weight: 5}     // 5% chance
];
```

#### 3. Variable Quantity Mode
Spawns random number of items (min-max range):
```gml
loot_mode = "random_weighted";
use_variable_quantity = true;
loot_count_min = 1;  // At least 1 item
loot_count_max = 3;  // Up to 3 items
loot_table = [
    {item_key: "health_potion", weight: 40},
    {item_key: "rusty_dagger", weight: 30},
    {item_key: "leather_helmet", weight: 20},
    {item_key: "axe", weight: 10}
];
```

### Sound Effects

- **`snd_chest_open`**: Plays immediately when container begins opening
- **`snd_loot_drop`**: Plays when animation completes and items spawn

## Implementation Details

### Core Variables (obj_openable/Create_0.gml)

```gml
// State
is_opened = false;
loot_spawned = false;

// Interaction
interaction_radius = 32;
interaction_prompt = noone;  // Instance of obj_interaction_prompt

// Animation
image_speed = 0;   // Manual control
image_index = 0;   // Start closed

// Loot configuration
loot_mode = "specific";  // or "random_weighted"
loot_items = [];
loot_table = [];
loot_count = 1;
loot_count_min = 1;
loot_count_max = 1;
use_variable_quantity = false;

// Persistence
openable_id = object_get_name(object_index) + "_" + string(x) + "_" + string(y);
```

### Core Functions

#### `open_container()`
Triggers opening animation and plays sound:
```gml
function open_container() {
    if (is_opened) return;
    is_opened = true;
    play_sfx(snd_chest_open);
}
```

#### `spawn_loot()`
Routes to appropriate spawn function based on `loot_mode`:
- Calls `spawn_specific_loot()` for specific mode
- Calls `spawn_random_loot()` for random_weighted mode
- Uses `loot_spawned` flag to prevent duplicates

#### `spawn_specific_loot()`
Spawns all items from `loot_items` array:
- Validates each item exists in `global.item_database`
- Uses `find_loot_spawn_position(x, y)` to find valid ground
- Calls `spawn_item(pos.x, pos.y, item_key, 1)` for each

#### `spawn_random_loot()`
Spawns random items from weighted table:
- Determines count (fixed or variable via `loot_count_min/max`)
- Uses `select_weighted_loot_item(loot_table)` for each item
- Validates and spawns like specific mode

#### `serialize()` / `deserialize()`
Save/load persistence:
```gml
function serialize() {
    return {
        openable_id: openable_id,
        is_opened: is_opened,
        loot_spawned: loot_spawned,
        x: x, y: y,
        object_type: object_get_name(object_index)
    };
}

function deserialize(_data) {
    is_opened = _data.is_opened;
    loot_spawned = _data.loot_spawned ?? false;
    image_index = is_opened ? 3 : 0;  // Set correct frame
}
```

### Integration with Existing Systems

#### Enemy Loot System
Reuses loot functions from `scr_enemy_loot_system`:
- `find_loot_spawn_position(x, y)` - Finds valid spawn point 16px away
- `select_weighted_loot_item(loot_table)` - Weighted random selection
- `spawn_item(x, y, item_key, count)` - Creates obj_item_pickup instance

#### Save/Load System
- Inherits from `obj_persistent_parent`
- Automatically included in `serialize_room_state()`
- State persists across room transitions and game sessions
- `loot_spawned` flag prevents duplicate loot on reload

#### Interaction Prompt System
- `obj_interaction_prompt` is a reusable UI element
- Also used by `obj_companion_parent` for recruitment
- Spawned/destroyed dynamically in Step event
- Configurable text, color, scale, and font

### Debug Features

Validation checks in Create event:
```gml
// Warns about invalid item_keys in loot_items
if (loot_mode == "specific") {
    for (var i = 0; i < array_length(loot_items); i++) {
        if (!variable_struct_exists(global.item_database, loot_items[i])) {
            show_debug_message("WARNING: Invalid item_key: " + loot_items[i]);
        }
    }
}

// Warns about invalid item_keys in loot_table
if (loot_mode == "random_weighted") {
    for (var i = 0; i < array_length(loot_table); i++) {
        if (!variable_struct_exists(global.item_database, loot_table[i].item_key)) {
            show_debug_message("WARNING: Invalid item_key: " + loot_table[i].item_key);
        }
    }
}
```

## Creating New Container Types

### Example: Creating obj_barrel

1. **Create object** inheriting from `obj_openable`

2. **Create sprite** `spr_barrel` with 4 frames

3. **Configure in Create_0.gml**:
```gml
event_inherited();

// Food/consumable themed loot
loot_mode = "random_weighted";
loot_count = 1;
loot_table = [
    {item_key: "health_potion", weight: 40},
    {item_key: "apple", weight: 30},
    {item_key: "bread", weight: 20},
    {item_key: "cheese", weight: 10}
];
```

4. **Place in room** - all behavior is automatic

### Per-Instance Configuration

Use Room Creation Code to customize individual containers:
```gml
// Make this specific chest drop rare loot
loot_mode = "specific";
loot_items = ["master_sword", "chain_armor"];
```

## Visual Elements

### Shadow Rendering
Containers draw a shadow sprite beneath them (obj_openable/Draw_0.gml):
```gml
// Shadow (same as player/enemies)
draw_sprite_ext(spr_shadow, image_index, x, y + 2, 1, 0.5, 0, c_black, 0.3);

// Container sprite
draw_self();
```

### Interaction Prompt
`obj_interaction_prompt` appearance:
- Font: `fnt_arial` at 0.35 scale
- Position: Follows parent with configurable `offset_y` (default -8)
- Color: White (`c_white`) with black outline
- Depth: -9999 (always on top)
- Auto-destroys when parent is destroyed or out of range

## State Flow

```
[Container Placed]
    ↓
[Player approaches] → Show interaction prompt
    ↓
[Player presses SPACE]
    ↓
[open_container()] → Set is_opened = true, play snd_chest_open
    ↓
[Step Event] → Increment image_index by 0.2 each frame
    ↓
[image_index >= 3]
    ↓
[spawn_loot()] → Spawn items, play snd_loot_drop
    ↓
[Container remains open] → State persists via save system
```

## Best Practices

1. **Always call `event_inherited()`** in child Create events
2. **Test loot tables** - debug validation catches invalid item_keys
3. **Use specific mode** for guaranteed story items
4. **Use weighted mode** for randomized treasure
5. **Configure per-instance** via Room Creation Code when needed
6. **Create 4-frame sprites** with clear opening animation
7. **Containers persist** - opened state saves automatically

## Future Expansion Ideas

- Locked containers requiring keys
- Trapped containers (damage or status effects)
- Container types with different interaction sounds
- Animated loot particles/sparkles
- Container durability (breakable vs openable)
- Multi-use containers (respawning loot)
