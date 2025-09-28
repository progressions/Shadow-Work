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

### Grid Puzzle System
- **Controller**: `obj_grid_controller` - Manages pillar puzzle mechanics
- **Components**: `obj_button`, `obj_rising_pillar`, `obj_reset_pad`

## GML Code Conventions

### Object Event Scripts
- Located in: `/objects/[object_name]/[Event].gml`
- Common events: Create_0, Step_0, Draw_0, Collision_[object]

### Animation Handling
- Player uses custom frame-based animation with `anim_data` struct
- Enemies use `animate_6frame_bob()` function for simple movement animation

### Variable Naming
- Snake_case for variables: `move_speed`, `hp_total`
- PascalCase for enums: `PlayerState`, `ItemType`
- Struct properties use snake_case: `equipped.right_hand`

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