# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GameMaker Studio 2 project for a top-down action RPG called "Shadow Work". The game features grid-based puzzles, real-time combat, and an inventory/equipment system with weapons, armor, and items.

## GameMaker Project Structure

- **Main project file**: `Shadow Work.yyp` - GameMaker Studio 2 project configuration
- **Objects**: `/objects/` - Game objects with event scripts (Create, Step, Draw, Collision, etc.)
- **Scripts**: `/scripts/` - Reusable GML functions and enums
- **Sprites**: `/sprites/` - Game graphics and animations
- **Sounds**: `/sounds/` - Audio files for music and sound effects
- **Rooms**: `/rooms/` - Game levels/scenes
- **Tilesets**: `/tilesets/` - Tile-based level building assets

## Key Game Systems

### Player System
- **Main object**: `obj_player` - Handles player movement, combat, inventory management
- **States**: Managed via `PlayerState` enum (idle, walking, dashing, attacking, on_grid)
- **Equipment slots**: right_hand, left_hand, head, torso, legs
- **Combat**: Attack spawns `obj_attack` instance with weapon damage/range

### Item & Inventory System
- **Database**: `global.item_database` in `scripts/scripts.gml` defines all items
- **Item types**: Weapons (one-handed, two-handed, versatile), Armor, Consumables, Tools, Ammo
- **Inventory functions**: `inventory_add_item()`, `equip_item()`, `unequip_item()`

### Enemy System
- **Parent**: `obj_enemy_parent` - Base object for all enemies
- **Enemy types**: `obj_orc`, `obj_burglar`, `obj_greenwood_bandit`, `obj_ronald`
- **Animation**: Uses 31-frame sprite sheets with animation state management

### Enemy Party System
- **Documentation**: See `docs/ENEMY_PARTY_SYSTEM.md`
- **Controller**: `obj_enemy_party_controller` - Manages coordinated enemy groups with formations
- **Key features**: Auto-spawning members, formation-based positioning, dynamic state changes, patrol/protect behaviors

### Openable Container System
- **Documentation**: See `docs/OPENABLE_CONTAINERS.md`
- **Parent object**: `obj_openable` - Inheritable base for chests, barrels, crates
- **Key features**: 4-frame animations, flexible loot modes (specific/random weighted), persistence, interaction prompts

### Grid Puzzle System
- **Controller**: `obj_grid_controller` - Manages pillar puzzle mechanics
- **Components**: `obj_button`, `obj_rising_pillar`, `obj_reset_pad`

### Quest System
- **Database**: `global.quest_database` in `scripts/scr_quest_system/scr_quest_system.gml` defines all quests
- **Quest types**: Multiple objective types (recruit_companion, kill, collect, deliver, location, spawn_kill)
- **Quest functions**: `quest_accept()`, `quest_update_progress()`, `quest_complete()`, `quest_is_active()`, `quest_is_complete()`, `quest_can_accept()`
- **Integration**: Quests are offered through Yarn dialogue files using Chatterbox functions
- **Tracking**: Active quests stored in `obj_player.active_quests` struct, completion flags stored as global variables

## GML Code Conventions

### Code Style
- **Ruby-like conventions**: The codebase follows Ruby-style naming conventions
- **Functions**: snake_case (e.g., `get_total_damage()`, `inventory_add_item()`, `is_two_handing()`)
- **Variables**: snake_case (e.g., `move_speed`, `hp_total`, `dash_timer`)
- **Local variables**: prefixed with underscore (e.g., `_item_def`, `_base_damage`, `_slot_name`)
- **Enums**: PascalCase (e.g., `PlayerState`, `ItemType`, `WeaponHandedness`)
- **Enum values**: snake_case (e.g., `PlayerState.attacking`, `ItemType.weapon`, `EquipSlot.right_hand`)
- **Struct properties**: snake_case (e.g., `equipped.right_hand`, `anim_data.idle_down`)
- **Global variables**: snake_case with `global.` prefix (e.g., `global.item_database`)

### Object Event Scripts
- Located in: `/objects/[object_name]/[Event].gml`
- Common events: Create_0, Step_0, Draw_0, Collision_[object]

### Animation Handling
- Player uses custom frame-based animation with `anim_data` struct
- Enemies use `animate_6frame_bob()` function for simple movement animation

## Development Commands

Since this is a GameMaker Studio 2 project, there are no traditional build/test commands. Development is done through the GameMaker IDE:

- **Run game**: Press F5 in GameMaker Studio 2 IDE
- **Debug mode**: Press F6 in GameMaker Studio 2 IDE
- **Clean build**: Build → Clean in GameMaker Studio 2 IDE
- **Export**: File → Export → Select platform in GameMaker Studio 2 IDE

## Architecture Notes

### Game Loop Flow
1. `obj_game_controller` manages global game state and room transitions
2. `obj_player` handles input and updates player state each frame
3. Collision detection uses tilemap (`layer_tilemap_get_id("Tiles_Col")`) and object collisions
4. Combat damage is calculated from equipped items using stat modifiers

### Save/Load System Consideration
The item system uses string keys (`equipped_sprite_key`) for save/load compatibility. When implementing save/load, serialize the `equipped` and `inventory` structs.

### Performance Considerations
- Use `image_speed = 0` for manual sprite animation control
- Enemy AI uses simple state machines with alarm-based timing
- Collision checks use GameMaker's built-in collision system with parent objects

## Common Tasks

### Adding New Items
1. Add item definition to `global.item_database` in `scripts/scripts.gml`
2. Create world sprite frame in `spr_items` sprite sheet
3. Add equipped sprite variant if needed (e.g., `spr_wielded_[item_name]`)

### Creating New Enemies
1. Create new object inheriting from `obj_enemy_parent`
2. Override Create event to set stats (hp, damage, move_speed)
3. Add sprite with appropriate animation frames

### Implementing New Player Abilities
1. Add new state to `PlayerState` enum if needed
2. Update player Step event state machine
3. Add input handling in appropriate state check

### Creating New Quests
1. Add quest definition to `init_quest_database()` in `scripts/scr_quest_system/scr_quest_system.gml`
2. Define quest properties: quest_id, quest_name, quest_giver, objectives, rewards, prerequisites, completion_flag
3. Add quest dialogue to companion's Yarn file using quest functions:
   - Use `<<if quest_can_accept("quest_id")>>` to show quest option
   - Use `<<quest_accept("quest_id")>>` to accept the quest
   - Use `<<if quest_is_active("quest_id")>>` to check if quest is in progress
   - Use `<<if quest_is_complete("quest_id")>>` to check if quest is done
4. Objective types automatically track progress:
   - `recruit_companion`: Tracks when companions join (auto-tracked in `recruit_companion()`)
   - `kill`: Tracks enemy kills (auto-tracked in `enemy_state_dead()`)
   - `collect`: Tracks quest item pickup (auto-tracked in `inventory_add_item()`)
   - `deliver`: Call `quest_check_delivery(object_name)` when player talks to NPC
   - `location`: Create `obj_quest_marker` instance and call `quest_check_location_reached(quest_id)` in collision
   - `spawn_kill`: Use `spawn_quest_enemy(obj, x, y, room, quest_id)` to spawn, auto-tracked when killed

### Quest Marker Objects (for location objectives)
To create a quest marker for location objectives:
1. Create object inheriting from a parent or standalone
2. Add variable `quest_id` (string) - set to the quest this marker is for
3. Add Collision event with `obj_player`:
   ```gml
   if (quest_check_location_reached(quest_id)) {
       instance_destroy(); // Remove marker after reaching it
   }
   ```
4. Place marker in room where player should go

### Creating Enemy Parties
See `docs/ENEMY_PARTY_SYSTEM.md` for detailed instructions. Quick overview:
1. Create object inheriting from `obj_enemy_party_controller`
2. Configure party state, formation, weights, and thresholds
3. Auto-spawn members with `init_party(enemies_array, formation_key)`
4. Optional: Configure patrol path or protect point

### Creating Openable Containers
See `docs/OPENABLE_CONTAINERS.md` for detailed instructions. Quick overview:
1. Create object inheriting from `obj_openable`
2. Create 4-frame sprite (closed → opening → open)
3. Configure loot mode (`"specific"` or `"random_weighted"`)
4. Container persists automatically via save/load system