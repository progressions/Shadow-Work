# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-01-multi-slot-save-system/spec.md

## Technical Requirements

### File Storage & Format

- **Format**: JSON using `json_encode()` and `json_parse()`
- **Location**: GameMaker save directory via `game_save_id`
- **File naming**:
  - Manual saves: `save_slot_1.json` through `save_slot_5.json`
  - Auto-save: `autosave.json`
- **Save schema version**: Include `save_version` integer in JSON root for future migration support

### Save Data Structure

#### Root Save Object
```gml
{
    save_version: 1,
    timestamp: current_time,
    current_room: room,

    player: { /* player data */ },
    companions: [ /* array of companion data */ ],
    inventory: { /* inventory and equipment */ },
    enemies: [ /* current room enemies */ ],
    npcs: [ /* NPC dialogue states */ ],

    quest_flags: { /* quest boolean flags */ },
    quest_counters: { /* quest numeric counters */ },

    room_states: { /* room index -> room state */ },

    world_state: {
        opened_chests: [ /* chest object IDs */ ],
        broken_breakables: [ /* breakable object IDs */ ],
        picked_up_items: [ /* item spawn IDs */ ]
    }
}
```

#### Player Serialization
```gml
{
    x: obj_player.x,
    y: obj_player.y,
    hp: obj_player.hp,
    hp_total: obj_player.hp_total,
    xp: obj_player.xp,
    level: obj_player.level,
    facing_dir: obj_player.last_dir_index, // 0=down, 1=right, 2=left, 3=up
    state: obj_player.state, // PlayerState enum value
    dash_cooldown: obj_player.dash_cooldown,
    is_two_handing: obj_player.is_two_handing,

    // Traits with stacks
    traits: [
        { trait_name: "fire_resistance", stacks: 2 },
        { trait_name: "ice_vulnerability", stacks: 1 }
    ],

    // Tags
    tags: obj_player.tags, // Array of tag names

    // Status effects with remaining time
    status_effects: [
        {
            type: effect.type, // StatusEffectType enum
            remaining_duration: effect.remaining_duration,
            tick_timer: effect.tick_timer,
            is_permanent: effect.is_permanent,
            neutralized: effect.neutralized
        }
    ]
}
```

#### Companion Serialization (per companion)
```gml
{
    companion_id: companion.companion_id,
    x: companion.x,
    y: companion.y,
    is_recruited: companion.is_recruited,
    state: companion.state,
    affinity: companion.affinity,
    quest_flags: companion.quest_flags, // Full struct
    dialogue_history: companion.dialogue_history,
    relationship_stage: companion.relationship_stage,

    // Triggers (save unlocked, cooldown, active states)
    triggers: {
        shield: { unlocked: bool, cooldown: int, active: bool },
        dash_mend: { unlocked: bool, cooldown: int, active: bool },
        aegis: { unlocked: bool, cooldown: int, active: bool },
        guardian_veil: { unlocked: bool, cooldown: int, active: bool }
    },

    // Auras (save active states)
    auras: {
        protective: { active: bool },
        regeneration: { active: bool }
    }
}
```

#### Enemy Serialization (per enemy)
```gml
{
    object_type: object_get_name(object_index), // String name for recreation
    x: enemy.x,
    y: enemy.y,
    hp: enemy.hp,
    hp_max: enemy.hp_max,
    state: enemy.state,
    last_dir_index: enemy.last_dir_index,

    // Traits with stacks
    traits: [
        { trait_name: "fire_immunity", stacks: 1 },
        { trait_name: "ice_vulnerability", stacks: 2 }
    ],

    // Tags
    tags: enemy.tags, // Array of tag names

    // Status effects with remaining time
    status_effects: [
        {
            type: effect.type, // StatusEffectType enum
            remaining_duration: effect.remaining_duration,
            tick_timer: effect.tick_timer,
            is_permanent: effect.is_permanent,
            neutralized: effect.neutralized
        }
    ]
}
```

#### Inventory Serialization
```gml
{
    inventory: [
        // Array of item keys from global.item_database
        "wooden_sword",
        "health_potion",
        "bronze_key"
    ],

    equipped: {
        right_hand: "fine_sword", // Item key or null
        left_hand: "wooden_shield",
        head: "leather_cap",
        torso: "leather_armor",
        legs: null
    }
}
```

#### Room State Serialization (per room)
```gml
room_states[room_index] = {
    enemies: [ /* enemy array as above */ ],
    opened_chests: [ /* chest object IDs */ ],
    broken_breakables: [ /* breakable IDs */ ],
    picked_up_items: [ /* item spawn IDs */ ],
    puzzle_state: { /* custom per-puzzle data */ }
}
```

#### Quest System Structure
```gml
// Global quest tracking (create in obj_game_controller)
global.quest_flags = ds_map_create(); // Boolean flags
global.quest_counters = ds_map_create(); // Numeric counters

// Examples:
ds_map_add(global.quest_flags, "met_yorna", true);
ds_map_add(global.quest_flags, "greenwood_cleared", false);
ds_map_add(global.quest_counters, "bandits_defeated", 3);
ds_map_add(global.quest_counters, "keys_collected", 1);
```

#### NPC Dialogue Serialization
Use Chatterbox's built-in variable system:
```gml
// Save Chatterbox variables
var chatterbox_vars = ChatterboxVariablesExport();
// Store chatterbox_vars in save file

// On load:
ChatterboxVariablesImport(loaded_chatterbox_vars);
```

### Core Functions

#### save_game(slot)
1. Create root save struct
2. Call serialize_player()
3. Call serialize_companions()
4. Call serialize_inventory()
5. Call serialize_enemies() for current room
6. Call serialize_room_states() for all visited rooms
7. Serialize global.quest_flags and global.quest_counters
8. Serialize Chatterbox variables
9. Convert struct to JSON using json_encode()
10. Write to file using file_text_open_write() and file_text_write_string()
11. Close file with file_text_close()

#### load_game(slot)
1. Check if save file exists using file_exists()
2. Open file with file_text_open_read()
3. Read JSON string with file_text_read_string()
4. Close file with file_text_close()
5. Parse JSON using json_parse()
6. Check save_version for compatibility
7. If current_room != loaded room, transition to loaded room
8. Call deserialize_player()
9. Call deserialize_companions()
10. Call deserialize_inventory()
11. Call deserialize_room_states()
12. Restore global.quest_flags and global.quest_counters
13. Restore Chatterbox variables
14. Call deserialize_enemies() to spawn enemies in current room

#### auto_save()
- Same as save_game() but writes to "autosave.json"
- Called in obj_player Room End event
- Add cooldown to prevent saving multiple times per frame

#### serialize_room_state(room_index)
1. Create struct for room state
2. Loop through all enemies in room, serialize each
3. Store opened chest IDs (track via global array or ds_list)
4. Store broken breakable IDs
5. Store picked-up item IDs
6. Store puzzle-specific state (obj_grid_controller state, button states)
7. Return struct

#### deserialize_room_state(room_index)
1. Check if room state exists in global.room_states
2. If exists, load state struct
3. Destroy all default spawned enemies in room
4. Spawn enemies from saved state using instance_create_depth()
5. Set enemy properties (hp, position, traits, status effects)
6. Mark chests as opened
7. Destroy breakables that were broken
8. Remove items that were picked up
9. Restore puzzle states

### Room State Persistence System

#### Global Room State Storage
```gml
// In obj_game_controller Create event
global.room_states = {}; // Struct keyed by room index
global.visited_rooms = ds_list_create(); // Track which rooms have been visited
```

#### On Room End (obj_player or obj_game_controller)
```gml
// Save current room state before leaving
if (!ds_list_find_index(global.visited_rooms, room)) {
    ds_list_add(global.visited_rooms, room);
}

global.room_states[$ string(room)] = serialize_room_state(room);
```

#### On Room Start
```gml
// Check if room has saved state
if (variable_struct_exists(global.room_states, string(room))) {
    deserialize_room_state(room);
} else {
    // First visit, use default spawns
}
```

### Enemy Recreation System

Since enemies are objects, they must be recreated using object indices. Store object name as string and convert back:

```gml
// On serialize:
var obj_name = object_get_name(enemy.object_index);

// On deserialize:
var obj_index = asset_get_index(obj_name);
var enemy = instance_create_depth(x, y, depth, obj_index);
```

### Status Effect Restoration

When restoring status effects to player and enemies:
1. Call entity's `init_status_effects()` to create empty array
2. For each saved effect, call `apply_status_effect(type, duration_override)`
3. Manually set tick_timer and neutralized state

### Trait Restoration

When restoring traits to player and enemies:
1. Call entity's trait initialization (if they have inherited traits from tags)
2. For each saved trait with stacks, call `add_trait(trait_name)` the appropriate number of times

### Tag Restoration

When restoring tags to player and enemies:
1. Initialize tags array if needed
2. For each saved tag, add to entity's tags array
3. Tags automatically grant their associated traits via the tag system

### Error Handling

- Validate save file exists before loading
- Check save_version compatibility
- Handle corrupted JSON with try/catch (use json_parse with error handling)
- Default to new game state if load fails
- Log errors to debug console with show_debug_message()

### Performance Considerations

- Save files may be 50-100 KB for full game state
- JSON parsing is fast enough for save/load (< 100ms)
- Avoid saving every frame; use room transitions and manual triggers
- Room state storage in memory is acceptable (< 1 MB for typical game)

### Testing Requirements

1. Save and load in different rooms - verify player position and room transition
2. Save with multiple companions recruited - verify affinity and quest flags persist
3. Save with enemies at low HP with status effects - verify enemies restore with correct HP, traits, and active burning/slowed effects
4. Leave room, kill enemies in second room, return to first room - verify first room enemies are still alive
5. Open chest, leave room, save, load - verify chest stays opened
6. Test auto-save on room transition - verify auto-save file is created and can be loaded
7. Save with active quest flags and counters - verify they persist across load
8. Save with NPC dialogue progress - verify Chatterbox variables restore correctly

## External Dependencies

None - all functionality uses built-in GameMaker functions and existing game systems.
