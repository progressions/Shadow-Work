# Quest System Documentation

## Overview

The quest system is a comprehensive framework for creating multi-objective quests with various reward types, automatic progress tracking, and Yarn dialogue integration. Quests can be given by NPCs (primarily companions) and track player progress across 6 different objective types.

## Core Components

### Quest Database
- **Location**: `scripts/scr_quest_system/scr_quest_system.gml`
- **Global Variable**: `global.quest_database`
- **Initialization**: `init_quest_database()` called in `obj_game_controller` Create event

### Player Quest Tracking
- **Location**: `obj_player.active_quests`
- **Type**: Struct mapping quest_id to quest data
- **Persistence**: Quest completion flags stored as global variables

## Quest Definition Structure

```gml
global.quest_database.quest_id = {
    quest_id: "unique_quest_identifier",
    quest_name: "Display Name of Quest",
    quest_giver: "obj_npc_name",
    objectives: [
        {
            type: "objective_type",
            target: "target_identifier",
            count: 1,
            current: 0,
            description: "Player-facing description"
            // Additional fields depending on objective type
        }
    ],
    rewards: {
        affinity_rewards: [
            { companion_id: "companion_name", amount: 2.0 }
        ],
        item_rewards: ["item_key1", "item_key2"],
        gold_reward: 0
    },
    prerequisites: ["other_quest_id"],  // Empty array if none
    completion_flag: "global_flag_name",
    requires_turnin: false,             // Whether quest needs manual turn-in
    turnin_npc: undefined,              // NPC object name if requires_turnin
    chain_next: undefined               // Next quest in chain (optional)
};
```

## Objective Types

### 1. recruit_companion
**Purpose**: Complete when a specific companion joins the party

**Structure**:
```gml
{
    type: "recruit_companion",
    target: "yorna",  // companion_id
    count: 1,
    current: 0,
    description: "Find and recruit Yorna"
}
```

**Tracking**: Automatic via `recruit_companion()` function
- When companion is recruited, calls `quest_check_companion_recruitment(companion_id)`
- Matches `target` against recruited companion's `companion_id`

**Example**: Hola's "Find Yorna" quest

---

### 2. kill
**Purpose**: Kill a specified number of enemies (by object type or trait)

**Structure**:
```gml
{
    type: "kill",
    target: "obj_greenwood_bandit",  // Object name OR trait tag
    count: 5,
    current: 0,
    use_trait: false,  // true to match by trait instead of object
    description: "Kill 5 Greenwood Bandits"
}
```

**Tracking**: Automatic via `enemy_state_dead()`
- When enemy dies, calls `quest_check_enemy_kill(object_index, tags, is_quest_enemy, quest_enemy_id)`
- If `use_trait` is false: matches `target` against enemy's object name
- If `use_trait` is true: matches `target` against enemy's trait tags array

**Examples**:
```gml
// Kill by object type
{type: "kill", target: "obj_orc", count: 3, use_trait: false}

// Kill by trait
{type: "kill", target: "fireborne", count: 5, use_trait: true}
```

---

### 3. collect
**Purpose**: Collect quest items from enemies or world

**Structure**:
```gml
{
    type: "collect",
    target: "wolf_pelt",  // item_id of quest item
    count: 3,
    current: 0,
    description: "Collect 3 Wolf Pelts"
}
```

**Quest Item Setup**:
```gml
// In global.item_database
wolf_pelt: new create_item_definition(
    30, "wolf_pelt", "Wolf Pelt", ItemType.quest_item, EquipSlot.none,
    {quest_id: "example_quest", stack_size: 5}
)
```

**Tracking**: Automatic via `inventory_add_item()`
- When quest item is picked up, calls `quest_check_item_collection(item_id, quest_id)`
- Matches `target` against item's `item_id`
- Quest items cannot be dropped or removed from inventory
- Quest items auto-removed on quest completion (unless reward)

---

### 4. deliver
**Purpose**: Deliver quest items to a specific NPC or location

**Structure**:
```gml
{
    type: "deliver",
    target: "mysterious_letter",  // item_id to deliver
    count: 1,
    current: 0,
    delivery_target: "obj_hola",  // NPC object name
    description: "Deliver the letter to Hola"
}
```

**Tracking**: Manual trigger required
- Call `quest_check_delivery(npc_object_name)` when player interacts with NPC
- Checks if player has required quest item in inventory
- Automatically updates progress if item is present

**Example Integration**:
```gml
// In NPC's interaction event or dialogue
if (quest_check_delivery(object_get_name(object_index))) {
    // Quest objective completed
}
```

---

### 5. location
**Purpose**: Reach a specific location in the game world

**Structure**:
```gml
{
    type: "location",
    target: "location_name",  // Descriptive name (not used in code)
    count: 1,
    current: 0,
    description: "Reach the Ancient Temple"
}
```

**Quest Marker Setup**:
1. Create an object in GameMaker (e.g., `obj_quest_marker_temple`)
2. Add variable: `quest_id = "your_quest_id"`
3. Add Collision event with `obj_player`:
```gml
if (quest_check_location_reached(quest_id)) {
    instance_destroy(); // Remove marker after reaching
}
```
4. Place marker object in room at target location

**Tracking**: Triggered by collision with quest marker
- `quest_check_location_reached(quest_id)` checks for active location objectives
- Returns true if objective was updated
- Marker should destroy itself or become invisible after completion

---

### 6. spawn_kill
**Purpose**: Kill quest-specific enemies spawned for this quest

**Structure**:
```gml
{
    type: "spawn_kill",
    target: "obj_bandit_boss",  // Enemy object type
    count: 1,
    current: 0,
    spawn_locations: [
        {x: 500, y: 300, room: rm_forest}
    ],
    description: "Defeat the Bandit Boss"
}
```

**Enemy Spawning**:
```gml
// When quest is accepted or at specific trigger
var enemy = spawn_quest_enemy(
    obj_bandit_boss,  // enemy object
    500,              // x position
    300,              // y position
    rm_forest,        // room to spawn in
    "quest_id"        // quest identifier
);
```

**Tracking**: Automatic via `enemy_state_dead()`
- Spawned enemies are marked with `quest_enemy = true` and `quest_enemy_id = quest_id`
- When killed, `quest_check_enemy_kill()` detects spawn_kill objectives
- Only counts enemies spawned specifically for this quest

---

## Core Functions

### Quest Management

#### `quest_accept(quest_id)`
Accepts a quest and adds it to player's active quests
- Validates prerequisites are met
- Deep copies quest data to `obj_player.active_quests`
- Initializes all objective progress counters to 0
- Returns true if successful

#### `quest_update_progress(quest_id, objective_index, amount)`
Updates progress for a specific objective
- Increments objective's `current` counter
- Checks if all objectives are complete
- Auto-completes quest if `requires_turnin` is false
- Returns true if successful

#### `quest_complete(quest_id)`
Completes a quest and grants rewards
- Grants affinity rewards to companions
- Adds item rewards to inventory
- Removes quest items from inventory (unless rewards)
- Sets global completion flag
- Unlocks chain quest if defined
- Removes quest from active_quests

#### `quest_check_objectives(quest_id)`
Checks if all objectives for a quest are met
- Returns true if all objective `current >= count`

### Quest State Queries

#### `quest_is_active(quest_id)`
Returns true if quest is in player's active_quests

#### `quest_is_complete(quest_id)`
Returns true if quest's completion flag is set

#### `quest_can_accept(quest_id)`
Returns true if quest can be accepted:
- All prerequisites are complete
- Quest is not already active
- Quest is not already complete

### Objective Tracking

#### `quest_check_companion_recruitment(companion_id)`
Called automatically when companion is recruited
- Checks all active quests for recruit_companion objectives
- Updates matching objectives

#### `quest_check_enemy_kill(enemy_object, enemy_tags, is_quest_enemy, quest_enemy_id)`
Called automatically when enemy dies
- Checks all active quests for kill and spawn_kill objectives
- Matches by object type or trait tags
- Handles quest-specific enemies

#### `quest_check_item_collection(item_id, quest_id)`
Called automatically when quest item is picked up
- Checks quest for collect objectives matching item_id
- Updates progress

#### `quest_check_location_reached(marker_quest_id)`
Called when player collides with quest marker
- Checks quest for location objectives
- Updates progress
- Returns true if objective was updated

#### `quest_check_delivery(npc_object_name)`
Called when player interacts with delivery target
- Checks all active quests for deliver objectives to this NPC
- Validates player has required items in inventory
- Updates progress if items present

#### `spawn_quest_enemy(enemy_object, spawn_x, spawn_y, spawn_room, quest_id)`
Spawns a quest-specific enemy
- Creates enemy instance at specified location
- Marks with `quest_enemy = true` and `quest_enemy_id = quest_id`
- Returns enemy instance

## Yarn Dialogue Integration

### Registered Functions
These functions are registered with Chatterbox in `obj_game_controller`:
- `quest_accept(quest_id)` - Accept a quest
- `quest_is_active(quest_id)` - Check if quest is active
- `quest_is_complete(quest_id)` - Check if quest is complete
- `quest_can_accept(quest_id)` - Check if quest can be accepted

### Dialogue Example

```yarn
title: Hola_Talk
---
<<if quest_is_complete("hola_find_yorna") and not $hola_thanked_for_yorna>>
    Hola: Thank you so much for finding Yorna!
    <<set $hola_thanked_for_yorna = true>>
<<elseif quest_is_active("hola_find_yorna")>>
    Hola: Have you found Yorna yet?
<<else>>
    Hola: Hello! How can I help?
<<endif>>

    <<if quest_can_accept("hola_find_yorna")>>
        -> Can I help you with something? [QUEST]
            Hola: Yes! My friend Yorna is missing. Can you find her?
            -> Of course, I'll find her
                <<quest_accept("hola_find_yorna")>>
                Hola: Thank you so much!
            -> Not right now
                Hola: Oh... okay.
    <<endif>>
===
```

## Quest Items

### Defining Quest Items

Quest items are special items that:
- Cannot be dropped or removed from inventory
- Automatically track collect objectives when picked up
- Auto-removed from inventory when quest completes (unless reward)

```gml
// In global.item_database
mysterious_letter: new create_item_definition(
    28, "mysterious_letter", "Mysterious Letter",
    ItemType.quest_item, EquipSlot.none,
    {
        quest_id: "example_quest",  // Links to quest
        stack_size: 1
    }
)
```

### Quest Item Protection

The inventory system prevents quest item removal:
```gml
// In inventory_remove_item()
if (_item.definition.type == ItemType.quest_item) {
    show_debug_message("Cannot remove quest item");
    return false;
}
```

## Quest Rewards

### Affinity Rewards
```gml
affinity_rewards: [
    { companion_id: "hola", amount: 2.0 },
    { companion_id: "yorna", amount: 1.0 }
]
```
- Finds companions by `companion_id`
- Adds amount to their `affinity` value (capped at `affinity_max`)

### Item Rewards
```gml
item_rewards: ["iron_sword", "health_potion"]
```
- Adds items to player inventory using `inventory_add_item()`
- Can reward quest items if desired (they won't be auto-removed)

### Gold Rewards
```gml
gold_reward: 100
```
- Currently not implemented (awaiting currency system)
- Structure in place for future use

## Quest Chains

Quests can chain together using the `chain_next` property:

```gml
// First quest
global.quest_database.quest_part_1 = {
    // ... quest definition ...
    chain_next: "quest_part_2"
};

// Second quest
global.quest_database.quest_part_2 = {
    // ... quest definition ...
    prerequisites: ["quest_part_1"],  // Must complete part 1
    chain_next: "quest_part_3"
};
```

When `quest_part_1` completes, a debug message shows that `quest_part_2` is available.

## Debug Commands

### F11 Key - Test Quest System
```gml
// In obj_player Step event
if (keyboard_check_pressed(vk_f11)) {
    // Tests quest acceptance for debugging
    quest_accept("hola_find_yorna");
}
```

## Complete Example Quest

```gml
// Quest: Help Hola find three ancient artifacts
global.quest_database.hola_artifacts = {
    quest_id: "hola_artifacts",
    quest_name: "Ancient Artifacts",
    quest_giver: "obj_hola",
    objectives: [
        {
            type: "kill",
            target: "fireborne",
            count: 5,
            current: 0,
            use_trait: true,
            description: "Defeat 5 Fireborne enemies"
        },
        {
            type: "collect",
            target: "ancient_artifact",
            count: 3,
            current: 0,
            description: "Collect 3 Ancient Artifacts"
        },
        {
            type: "location",
            target: "ancient_temple",
            count: 1,
            current: 0,
            description: "Find the Ancient Temple"
        },
        {
            type: "deliver",
            target: "ancient_artifact",
            count: 3,
            current: 0,
            delivery_target: "obj_hola",
            description: "Return artifacts to Hola"
        }
    ],
    rewards: {
        affinity_rewards: [
            { companion_id: "hola", amount: 3.0 }
        ],
        item_rewards: ["master_sword"],
        gold_reward: 0
    },
    prerequisites: ["hola_find_yorna"],
    completion_flag: "quest_hola_artifacts_complete",
    requires_turnin: true,
    turnin_npc: "obj_hola",
    chain_next: undefined
};
```

## Implementation Checklist

When creating a new quest:

1. ☐ Define quest in `init_quest_database()`
2. ☐ Create quest items if needed (in `global.item_database`)
3. ☐ Add Yarn dialogue with quest offering
4. ☐ Create quest markers if using location objectives
5. ☐ Spawn quest enemies if using spawn_kill objectives
6. ☐ Add delivery check if using deliver objectives
7. ☐ Test quest acceptance
8. ☐ Test objective progression
9. ☐ Test quest completion and rewards
10. ☐ Test quest chains if applicable

## Technical Notes

### Quest Data Flow

1. **Initialization**: `init_quest_database()` creates `global.quest_database`
2. **Acceptance**: Player accepts via Yarn dialogue → `quest_accept()` → Quest copied to `obj_player.active_quests`
3. **Progress**: Actions trigger tracking functions → `quest_update_progress()` → Checks completion
4. **Completion**: All objectives met → `quest_complete()` → Rewards granted, flag set, quest removed

### Save System Integration

Quest completion flags are global variables (`global.quest_hola_find_yorna_complete`), making them automatically compatible with the save system's global variable serialization.

Active quests in `obj_player.active_quests` would need manual serialization if save/load during active quests is desired.

### Performance Considerations

- Quest checking functions use early returns when quest isn't active
- Enemy kill checking loops through active quests (minimize active quest count if performance critical)
- Quest item checking is O(n) through inventory
- All quest operations are frame-safe (no async operations)

## Future Enhancements

Potential additions to the quest system:

- Visual quest notifications (currently only debug messages)
- Sound effects for quest events
- Quest journal UI
- Quest abandonment
- Quest failure conditions
- Timed quests
- Repeatable daily/weekly quests
- Quest sharing in multiplayer
- Quest markers on minimap
- Quest tracking HUD element
