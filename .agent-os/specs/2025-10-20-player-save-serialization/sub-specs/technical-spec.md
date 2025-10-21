# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-20-player-save-serialization/spec.md

> Created: 2025-10-20
> Version: 1.0.0

## Technical Requirements

### Phase 1: Player Serialization Functions

**File to Modify:** `/scripts/scr_save_system/scr_save_system.gml`

Create the following helper functions for player serialization:

#### serialize_player()
Returns a struct containing all player state:
```gml
{
    // Position & World
    x: player.x,
    y: player.y,
    room: room_get_name(room),
    facing_dir: player.facing_dir,
    current_elevation: player.current_elevation,

    // Stats
    hp: player.hp,
    hp_total: player.hp_total,
    level: player.level,
    xp: player.xp,
    xp_to_next: player.xp_to_next,
    damage: player.damage,
    crit_chance: player.crit_chance,
    crit_multiplier: player.crit_multiplier,

    // Traits (permanent only)
    tags: player.tags,
    permanent_traits: player.permanent_traits,

    // Torch state
    torch_active: player.torch_active,
    torch_time_remaining: player.torch_time_remaining
}
```

#### deserialize_player(data)
Restores player state from saved struct:
- Sets position, stats, facing direction
- Restores tags and permanent traits
- Restores torch state

### Phase 2: Inventory Serialization Functions

#### serialize_inventory()
Returns array of inventory items:
```gml
[
    {
        item_id: "rusty_sword",
        count: 1,
        durability: 85
    },
    {
        item_id: "small_health_potion",
        count: 5,
        durability: 100
    }
]
```

#### deserialize_inventory(data)
Restores inventory from saved array:
- Clears current inventory
- Recreates each item by looking up item_id in global.item_database
- Restores count and durability

### Phase 3: Equipment Serialization Functions

#### serialize_equipment()
Returns struct of equipped items and loadouts:
```gml
{
    equipped: {
        right_hand: "rusty_sword" or undefined,
        left_hand: "wooden_shield" or undefined,
        head: undefined,
        torso: "leather_armor" or undefined,
        legs: undefined
    },
    loadouts: {
        active: "melee",
        melee: {
            right_hand: "rusty_sword",
            left_hand: "wooden_shield"
        },
        ranged: {
            right_hand: "short_bow",
            left_hand: undefined
        }
    }
}
```

#### deserialize_equipment(data, inventory_array)
Restores equipment from saved struct:
- Finds items in restored inventory by item_id
- Equips items to correct slots
- Restores loadout configuration
- Sets active loadout

### Phase 4: Quest Serialization Functions

#### serialize_quests()
Returns struct containing all quest data:
```gml
{
    active_quests: {
        "hola_find_yorna": {
            quest_id: "hola_find_yorna",
            objectives: [
                {
                    type: "recruit_companion",
                    target: "yorna",
                    count: 1,
                    current: 0
                }
            ]
        }
    },
    completion_flags: {
        quest_hola_find_yorna_complete: false,
        quest_protect_canopy_complete: true
    },
    quest_counters: global.quest_counters,
    quest_flags: global.quest_flags
}
```

#### deserialize_quests(data)
Restores quest state from saved struct:
- Restores active_quests on obj_player
- Sets all quest completion flags (global variables)
- Restores quest_counters and quest_flags

### Phase 5: Companion Serialization Functions

#### serialize_companions()
Returns array of recruited companion data:
```gml
[
    {
        companion_id: "hola",
        is_recruited: true,
        affinity: 7.5,
        x: 320,
        y: 240,
        room: "rm_forest",
        quest_flags: {
            met_player: true,
            first_conversation: true,
            romantic_quest_unlocked: false
        },
        dialogue_history: ["hola_greeting_1", "hola_quest_1"],
        relationship_stage: 2,
        carrying_torch: false,
        torch_time_remaining: 0
    }
]
```

#### deserialize_companions(data)
Restores companion state from saved array:
- For each saved companion, finds or creates companion instance
- Restores affinity, position, quest flags, dialogue history
- Restores torch state if carrying
- Sets is_recruited = true and state = CompanionState.following

### Phase 6: Torch Carrier System

#### serialize_torch_state()
Returns struct of global torch carrier:
```gml
{
    carrier_id: global.torch_carrier_id,
    player_torch_active: obj_player.torch_active,
    player_torch_time: obj_player.torch_time_remaining
}
```

#### deserialize_torch_state(data)
Restores torch carrier from saved data:
- Sets global.torch_carrier_id
- Restores player torch state
- Companions restore their torch state from companion data

### Phase 7: Main save_game() Function

**Implementation:**
```gml
function save_game(_slot_number) {
    // Validate slot number
    if (_slot_number < 1 || _slot_number > 5) {
        show_debug_message("ERROR: Invalid save slot " + string(_slot_number));
        return false;
    }

    // Build save data struct
    var save_data = {
        version: 1,
        timestamp: date_current_datetime(),
        player: serialize_player(),
        inventory: serialize_inventory(),
        equipment: serialize_equipment(),
        quests: serialize_quests(),
        companions: serialize_companions(),
        torch_state: serialize_torch_state()
    };

    // Convert to JSON
    var json_string = json_stringify(save_data);

    // Write to file
    var filename = "save_slot_" + string(_slot_number) + ".json";
    var file = file_text_open_write(filename);
    file_text_write_string(file, json_string);
    file_text_close(file);

    show_debug_message("Game saved to slot " + string(_slot_number));
    return true;
}
```

### Phase 8: Main load_game() Function

**Implementation:**
```gml
function load_game(_slot_number) {
    // Validate slot number
    if (_slot_number < 1 || _slot_number > 5) {
        show_debug_message("ERROR: Invalid load slot " + string(_slot_number));
        return false;
    }

    var filename = "save_slot_" + string(_slot_number) + ".json";

    // Check if file exists
    if (!file_exists(filename)) {
        show_debug_message("ERROR: Save file not found for slot " + string(_slot_number));
        return false;
    }

    // Read JSON from file
    var file = file_text_open_read(filename);
    var json_string = "";
    while (!file_text_eof(file)) {
        json_string += file_text_read_string(file);
        file_text_readln(file);
    }
    file_text_close(file);

    // Parse JSON
    var save_data = json_parse(json_string);

    // Validate version
    if (save_data.version != 1) {
        show_debug_message("ERROR: Incompatible save version");
        return false;
    }

    // Restore game state
    deserialize_player(save_data.player);
    deserialize_inventory(save_data.inventory);
    deserialize_equipment(save_data.equipment, obj_player.inventory);
    deserialize_quests(save_data.quests);
    deserialize_companions(save_data.companions);
    deserialize_torch_state(save_data.torch_state);

    // Transition to saved room if different
    if (room != asset_get_index(save_data.player.room)) {
        room_goto(asset_get_index(save_data.player.room));
    }

    show_debug_message("Game loaded from slot " + string(_slot_number));
    return true;
}
```

## Approach

### Modular Serialization Architecture

The system uses a modular approach with separate serialize/deserialize function pairs for each major game system:

1. **Player State** - Core stats, position, traits
2. **Inventory** - All carried items with counts and durability
3. **Equipment** - Equipped items and loadout configurations
4. **Quests** - Active quests, completion flags, counters
5. **Companions** - Recruited companions with affinity and state
6. **Torch System** - Global torch carrier tracking

This modular design allows:
- Independent testing of each component
- Easy debugging of specific subsystems
- Future expansion without affecting existing code
- Clear separation of concerns

### JSON-Based Persistence

GameMaker's native `json_stringify()` and `json_parse()` functions provide:
- Human-readable save files for debugging
- Automatic handling of nested structures
- Version tracking for future compatibility
- Standard format for potential cloud save integration

### Item Reference System

Items are saved by `item_id` string rather than direct struct references to:
- Maintain compatibility across game updates
- Allow item definition changes without breaking saves
- Support validation during load (missing items can be handled gracefully)
- Keep save file size minimal

### Companion Instance Management

Companions are saved with full state including:
- World position and room location
- Affinity level and relationship stage
- Quest flags and dialogue history
- Torch carrying state

During load, companions are either:
1. Found in the current room and updated with saved state
2. Created at their saved position/room if not present

### Quest State Preservation

Quest system serialization captures:
- Active quest objectives with progress counters
- Global completion flags (e.g., `global.quest_protect_canopy_complete`)
- Generic quest counters for dynamic tracking
- Quest-specific flags for branching dialogue

## Implementation Order

1. Create serialize_player() and deserialize_player()
2. Create serialize_inventory() and deserialize_inventory()
3. Create serialize_equipment() and deserialize_equipment()
4. Create serialize_quests() and deserialize_quests()
5. Create serialize_companions() and deserialize_companions()
6. Create serialize_torch_state() and deserialize_torch_state()
7. Implement save_game() using all serialize functions
8. Implement load_game() using all deserialize functions
9. Test save/load with each component incrementally

## Testing Strategy

**Unit Testing (per component):**
- Save player state → Load player state → Verify all stats match
- Save inventory → Load inventory → Verify all items present with correct counts
- Save equipment → Load equipment → Verify correct items equipped in correct slots
- Save quests → Load quests → Verify quest progress and flags restored
- Save companions → Load companions → Verify affinity and quest flags restored

**Integration Testing:**
- Full save → Full load → Verify complete game state restored
- Save in different rooms → Load → Verify room transition works
- Save with various inventory states (empty, full, partially equipped)
- Save with different companion combinations (none, one, multiple)
- Save with active quests in different states

**Edge Cases:**
- Loading non-existent slot (should show error)
- Loading with invalid slot number (should show error)
- Saving/loading with companions in different rooms
- Saving/loading with torch active on different carriers

## External Dependencies

### GameMaker Built-in Functions
- `json_stringify()` - Convert struct to JSON string
- `json_parse()` - Parse JSON string to struct
- `file_text_open_write()` - Open file for writing
- `file_text_open_read()` - Open file for reading
- `file_text_write_string()` - Write string to file
- `file_text_read_string()` - Read string from file
- `file_text_close()` - Close file handle
- `file_exists()` - Check if save file exists
- `room_get_name()` - Get current room name
- `asset_get_index()` - Convert room name to room ID
- `room_goto()` - Transition to saved room

### Existing Game Systems
- `global.item_database` - Item definitions lookup
- `global.quest_database` - Quest definitions
- `global.torch_carrier_id` - Global torch carrier tracking
- `obj_player` - Player instance with all state variables
- Companion objects (obj_hola, obj_yorna, etc.) - Companion instances
- Quest system functions from `/scripts/scr_quest_system/scr_quest_system.gml`
- Inventory functions from `/scripts/scr_inventory/scr_inventory.gml`

### File System
- GameMaker's sandboxed save directory
- 5 save slots: `save_slot_1.json` through `save_slot_5.json`

## Success Criteria

- save_game(1-5) creates valid JSON files in GameMaker save directory
- load_game(1-5) successfully restores all player, inventory, quest, and companion data
- Player position, stats, and facing direction match exactly after load
- All inventory items restored with correct counts and durability
- All equipped items in correct slots after load
- Active quests restored with correct objective progress
- Recruited companions appear at correct positions with correct affinity
- Torch state restored to correct carrier (player or companion)
