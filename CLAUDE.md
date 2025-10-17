# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GameMaker Studio 2 project for a top-down action RPG called "Shadow Work". The game features grid-based puzzles, real-time combat with dual-mode enemies, a trait-based damage system, companion mechanics, and an inventory/equipment system.

## GameMaker Project Structure

- **Main project file**: `Shadow Work.yyp` - GameMaker Studio 2 project configuration
- **Objects**: `/objects/` - Game objects with event scripts (Create, Step, Draw, Collision, etc.)
- **Scripts**: `/scripts/` - Reusable GML functions and enums
- **Sprites**: `/sprites/` - Game graphics and animations
- **Sounds**: `/sounds/` - Audio files with variant randomization support
- **Rooms**: `/rooms/` - Game levels/scenes
- **Tilesets**: `/tilesets/` - Tile-based level building assets
- **Documentation**: `/docs/` - System documentation (see below for complete list)

## Development Commands

Since this is a GameMaker Studio 2 project, there are no traditional build/test commands. Development is done through the GameMaker IDE:

- **Run game**: Press F5 in GameMaker Studio 2 IDE
- **Debug mode**: Press F6 in GameMaker Studio 2 IDE
- **Clean build**: Build → Clean in GameMaker Studio 2 IDE
- **Export**: File → Export → Select platform in GameMaker Studio 2 IDE

## GML Code Conventions

### Code Style (Ruby-like conventions)
- **Functions**: snake_case (e.g., `get_total_damage()`, `inventory_add_item()`, `is_two_handing()`)
- **Variables**: snake_case (e.g., `move_speed`, `hp_total`, `dash_timer`)
- **Local variables**: prefixed with underscore (e.g., `_item_def`, `_base_damage`, `_slot_name`)
- **Enums**: PascalCase (e.g., `PlayerState`, `ItemType`, `WeaponHandedness`)
- **Enum values**: snake_case (e.g., `PlayerState.attacking`, `ItemType.weapon`, `EquipSlot.right_hand`)
- **Struct properties**: snake_case (e.g., `equipped.right_hand`, `anim_data.idle_down`)
- **Global variables**: snake_case with `global.` prefix (e.g., `global.item_database`)

### Object Event Scripts
- Located in: `/objects/[object_name]/[Event].gml`
- Common events: Create_0, Step_0, Draw_0, Collision_[object], Alarm_[number]

## Core Architecture

### Parent Object Hierarchy
- **obj_persistent_parent** - Base for save/load serialization (`serialize()`, `deserialize()`)
- **obj_enemy_parent** - Base for all enemies (state machine, combat, pathfinding, traits)
- **obj_companion_parent** - Base for all companions (following, triggers, auras, affinity)
- **obj_interactable_parent** - Base for interactive objects (prompts, collision detection)
- **obj_openable** - Base for chests/containers (animation, loot drops, persistence)

### Global State Management
Key global variables that coordinate systems:
- `global.game_paused` - Pause state check (affects Step events)
- `global.idle_bob_timer` - Synchronized idle animations across all enemies
- `global.item_database` - All item definitions (weapons, armor, consumables)
- `global.quest_database` - All quest definitions with objectives
- `global.tag_database` - Tag → trait bundle mappings (fireborne, arboreal, etc.)
- `global.trait_database` - Trait definitions with stacking mechanics
- `global.formation_database` - Enemy party formations
- `global.sound_variant_lookup` - Sound variant counts for randomization

### Event-Driven Patterns
- **Alarm Events** - Timed actions (attack cooldowns, pathfinding updates, state resets)
- **Collision Events** - Damage application (`Collision_obj_attack`, `Collision_obj_enemy_arrow`)
- **Step Events** - State machines, animation updates, AI logic
- **Draw Events** - Custom rendering (HP bars, effects, UI overlays)

## Core Gameplay Systems

### Combat System

The combat system features layered damage calculation and reduction pipelines with trait-based modifiers.

**Quick Reference:**
- **Damage Pipeline**: Base Damage → Status Modifiers → Companion Bonuses → Dash Multiplier → Critical Hit
- **Reduction Pipeline**: Trait Modifier → Equipment DR → Companion DR → Defense Traits → Chip Damage
- **Attack Categories**: melee (swords, daggers) vs ranged (arrows, projectiles)

**See:** `/docs/COMBAT_SYSTEM.md` for complete damage calculation documentation

**Key Files:**
- `/scripts/scr_combat_system/scr_combat_system.gml` - Core damage calculation
- `/objects/obj_attack/Create_0.gml` - Melee attack instances
- `/objects/obj_arrow/Create_0.gml` - Ranged attack projectiles
- `/objects/obj_enemy_parent/Collision_obj_attack.gml` - Damage application

### Damage Type System

Nine damage types with trait-based resistance/vulnerability/immunity system.

**Damage Types**: physical, magical, fire, ice, lightning, poison, disease, holy, unholy

**See:** `/docs/DAMAGE_TYPE_SYSTEM.md` for complete damage type documentation

**Key Files:**
- `/scripts/scr_enums/scr_enums.gml` - DamageType enum
- `/scripts/scr_damage_type_helpers/scr_damage_type_helpers.gml` - Conversion and color functions

### Player Mechanics

**Dashing**: Double-tap movement for 8-frame burst (6 px/frame) with 60% momentum carryover
**Dash Attack**: Collision damage during dash + 0.4s attack window after (1.5x damage, -25% DR trade-off)
**Shield Blocking**: Partially implemented (animations complete, damage blocking not yet implemented)

**See:** `/docs/PLAYER_MECHANICS.md` for complete player mechanics documentation

**Key Files:**
- `/scripts/player_handle_dash_input/player_handle_dash_input.gml` - Double-tap detection
- `/scripts/player_state_dashing/player_state_dashing.gml` - Dash movement
- `/scripts/player_dash_attack/player_dash_attack.gml` - Dash attack system
- `/scripts/player_state_shielding/player_state_shielding.gml` - Shield blocking

### Ranged Combat

**Player**: Bows require ammo, range profiles for damage falloff, speed 2 px/frame
**Enemy**: Unlimited ammo, can move while shooting, speed 4 px/frame, can crit player
**Special**: Hola companion wind deflection aura bends enemy arrows away from player

**See:** `/docs/RANGED_ATTACK_SYSTEM_TECHNICAL.md` for complete ranged combat documentation

**Key Files:**
- `/scripts/player_attacking/player_attacking.gml` - Player ranged attack windup
- `/objects/obj_arrow/` - Player arrow projectile
- `/objects/obj_enemy_arrow/` - Enemy arrow projectile
- `/scripts/scr_projectile_range_profiles/scr_projectile_range_profiles.gml` - Range profiles

### Boss Mechanics

**Chain Boss**: Boss physically chained to 2-5 auxiliaries. Auxiliaries grant DR, boss enrages when all die. Special attacks: Throw Attack (launches auxiliary), Spin Attack (orbital collision damage).

**Hazard Spawning**: Projectile delivery system for persistent AOE hazards. Visual telegraph, range-based damage, optional explosion, layered damage opportunities.

**See:** `/docs/BOSS_MECHANICS.md` for complete boss mechanics documentation

**Key Files:**
- `/objects/obj_chain_boss_parent/` - Base chain boss system
- `/objects/obj_hazard_parent/` - Base hazard system
- `/objects/obj_hazard_projectile/` - Hazard delivery
- `/scripts/scr_enemy_state_hazard_spawning/scr_enemy_state_hazard_spawning.gml` - Hazard state

### Trait System

Traits stack up to 5 times and can cancel each other. Opposite traits cancel stack-by-stack (3 fire_resistance + 2 fire_vulnerability = 1 fire_resistance).

**Trait Categories**:
- Damage type (resistance/vulnerability/immunity)
- Defense (bolstered/sundered affecting all DR)
- Status immunity

**See:** `/docs/TRAIT_SYSTEM.md` for complete trait system documentation

**Key Files:**
- `/scripts/trait_system/trait_system.gml` - All trait functions
- `/objects/obj_game_controller/Create_0.gml` - Trait and tag databases

### Status Effects System

**Effects**: burning, wet, empowered, weakened, swift, slowed
**Mechanics**: Opposing effects neutralize, duration refresh on reapply, trait immunity blocking

**See:** `/docs/status-effects-system.md` for complete status effects documentation

**Key Files:**
- `/scripts/scr_status_effects/scr_status_effects.gml` - All status effect functions

### Enemy AI

**State Machine**: idle → targeting → attacking/ranged_attacking → dead
**Pathfinding**: mp_grid with obstacle detection, throttled updates (2s or 64px player movement)
**Dual-Mode**: Context-based switching between melee and ranged based on distance, formation, cooldowns
**Flanking**: 40% chance to approach from behind player (opposite of facing_dir + ±30° variance)

**See:** `/docs/ENEMY_AI_ARCHITECTURE.md` for complete AI documentation
**See:** `/docs/ENEMY_AI_PATHFINDING_AND_RANGED_BEHAVIOR.md` for advanced AI behaviors

**Key Files:**
- `/objects/obj_enemy_parent/Step_0.gml` - State machine dispatcher
- `/scripts/scr_enemy_state_targeting/scr_enemy_state_targeting.gml` - Pathfinding and targeting
- `/scripts/scr_enemy_state_attacking/scr_enemy_state_attacking.gml` - Melee attacks
- `/scripts/scr_enemy_state_ranged_attacking/scr_enemy_state_ranged_attacking.gml` - Ranged attacks

### Enemy Party System

**States**: protecting, aggressive, cautious, desperate, emboldened, retreating, patrolling
**Formations**: line_3, wedge_5, circle_4, protective_3 (defined in `global.formation_database`)
**Decision Weights**: Parties use weighted random selection for attack/formation/flee priorities

**See:** `/docs/ENEMY_PARTY_SYSTEM.md` for complete party system documentation

**Key Files:**
- `/objects/obj_enemy_party_controller/` - Base party controller

### Companion System

**States**: waiting (not recruited) → following → evading (during combat) → casting (triggers)
**Evasion**: Maintains 64-128px from player, avoids enemies within 200px radius
**Affinity Scaling**: 3.0-10.0 scale with square root multiplier (0.6x to 3.0x bonus)
**Triggers**: 4 tiers (base, mid @5+, advanced @8+, ultimate @10) with cooldowns

**See:** `/docs/COMPANION_SYSTEM_TECHNICAL.md` for technical implementation
**See:** `/docs/COMPANION_GUIDE.md` for high-level companion design

**Key Files:**
- `/objects/obj_companion_parent/Create_0.gml` - Companion initialization
- `/objects/obj_companion_parent/Step_0.gml` - States and triggers
- `/scripts/scr_companion_system/scr_companion_system.gml` - Helper functions

### Sound System

**Variant Randomization**: Automatic random selection from numbered variants (e.g., `snd_sword_hit_1`, `snd_sword_hit_2`)
**Enemy Sounds**: Separate sounds for melee vs ranged attacks with fallback defaults
**Functions**: `play_sfx()` with variant support, `play_enemy_sfx()` with custom/fallback logic

**See:** `/docs/SOUND_SYSTEM.md` for complete sound system documentation

**Key Files:**
- `/scripts/scr_sfx_functions/scr_sfx_functions.gml` - Sound playback functions
- `/objects/obj_sfx_controller/Create_0.gml` - Sound controller

### Animation Systems

**Player**: Custom frame-based with `anim_data` struct, manual control (`image_speed = 0`), 58+ frames
**Enemy**: State-based with global idle bob timer, 35-frame layout (melee-only) or 47-frame (dual-mode)
**Override System**: Enemies can override default animations with `enemy_anim_overrides` struct

**See:** `/docs/ANIMATION_SYSTEM.md` for complete animation documentation

**Key Files:**
- `/scripts/scr_animation_helpers/scr_animation_helpers.gml` - Enemy animation data
- `/scripts/player_handle_animation/player_handle_animation.gml` - Player animation
- `/objects/obj_player/Create_0.gml` - Player anim_data struct

### Quest System

**Objective Types**: recruit_companion, kill, collect, deliver, location, spawn_kill (all auto-tracking)
**Integration**: Yarn dialogue with Chatterbox functions (`quest_can_accept()`, `quest_accept()`, etc.)
**Rewards**: XP, items, affinity increases, gold

**See:** `/docs/QUEST_SYSTEM.md` for complete quest system documentation

**Key Files:**
- `/scripts/scr_quest_system/scr_quest_system.gml` - All quest functions
- `/objects/obj_game_controller/Create_0.gml` - Quest database initialization

### Dialogue Functions (Chatterbox/Yarn)

**Functions**: Inventory (`has_item`, `give_item`, `remove_item`, `inventory_count`), Affinity (`get_affinity`), Quest Progress (`objective_complete`, `quest_progress`)

**See:** `/docs/DIALOGUE_FUNCTIONS.md` for complete Chatterbox function reference and Yarn examples

### Item & Inventory System

**Item Types**: weapon, shield, armor (head/torso/legs), consumable, quest_item, material, key
**Equipment**: 5 slots (right_hand, left_hand, head, torso, legs)
**Loadouts**: Separate melee and ranged loadouts with auto-equip rules
**Systems**: Two-handing (+50% damage), dual-wielding (-25% each), wielder effects

**See:** `/docs/ITEM_INVENTORY_SYSTEM.md` for complete item system documentation

**Key Files:**
- `/scripts/scripts.gml` - Item database initialization
- `/scripts/scr_inventory/scr_inventory.gml` - Inventory functions
- `/scripts/scr_combat_system/scr_combat_system.gml` - Combat stat calculations

## Common Implementation Tasks

### Adding New Damage Types
1. Add to `DamageType` enum in `/scripts/scr_enums/scr_enums.gml`
2. Add color mapping in `damage_type_to_color()` (see `/docs/DAMAGE_TYPE_SYSTEM.md`)
3. Create immunity/resistance/vulnerability traits in `global.trait_database`
4. Add to relevant tags in `global.tag_database`

### Creating Dual-Mode Enemies
1. Inherit from `obj_enemy_parent`
2. Set `enable_dual_mode = true` and configure attack preferences
3. Configure both melee and ranged stats
4. Use 47-frame sprite with ranged animations
5. Set separate sounds for melee vs ranged attacks

See `/docs/ENEMY_AI_ARCHITECTURE.md` for complete dual-mode configuration.

### Creating New Enemies
1. Create object inheriting from `obj_enemy_parent`
2. Override Create event: call `event_inherited()` then set stats (hp, attack_damage, move_speed, etc.)
3. Apply tags for trait bundles: `array_push(tags, "fireborne"); apply_tag_traits();`
4. Configure flank behavior via `flank_chance` and `flank_trigger_distance`
5. Add sprite with 35-frame (melee-only) or 47-frame (dual-mode) layout

### Creating Enemy Parties
1. Create object inheriting from `obj_enemy_party_controller`
2. Configure party state, formation, and weights in Create event
3. Auto-spawn members with `init_party(enemies_array, formation_key)`
4. Optional: Configure patrol path or protect point

See `/docs/ENEMY_PARTY_SYSTEM.md` for detailed instructions.

### Creating Openable Containers
1. Create object inheriting from `obj_openable`
2. Create 4-frame sprite (closed → opening → open → open)
3. Configure loot mode and loot table in Create event
4. Container persists automatically via save/load system

See `/docs/OPENABLE_CONTAINERS.md` for detailed instructions.

### Adding New Items
1. Add item definition to `global.item_database` in `/scripts/scripts.gml`
2. Create world sprite frame in `spr_items` sprite sheet
3. Add equipped sprite variant if needed (e.g., `spr_wielded_[item_name]`)
4. For weapons: Set damage_type, attack_damage, attack_speed, attack_range
5. For armor: Set melee_dr, ranged_dr, general_dr

See `/docs/ITEM_INVENTORY_SYSTEM.md` for item structure details.

### Creating New Quests
1. Add quest definition to `init_quest_database()` in `/scripts/scr_quest_system/scr_quest_system.gml`
2. Define quest properties: quest_id, quest_name, quest_giver, objectives, rewards
3. Add quest dialogue to companion's Yarn file using quest functions
4. Objective types auto-track through gameplay (no manual progress calls needed)

See `/docs/QUEST_SYSTEM.md` for objective types and integration.

### Creating Quest Marker Objects
For location objectives:
1. Create object (inheriting from parent or standalone)
2. Add variable `quest_id` (string) - set to the quest this marker is for
3. Add Collision event with `obj_player`: `if (quest_check_location_reached(quest_id)) { instance_destroy(); }`
4. Place marker in room where player should go

## Documentation Reference

### Player Systems
- `/docs/PLAYER_MECHANICS.md` - Dashing, dash attack, shield blocking
- `/docs/COMBAT_SYSTEM.md` - Damage calculation and reduction pipelines
- `/docs/ITEM_INVENTORY_SYSTEM.md` - Items, equipment, loadouts

### Enemy Systems
- `/docs/ENEMY_AI_ARCHITECTURE.md` - State machine, pathfinding, dual-mode, flanking
- `/docs/ENEMY_AI_PATHFINDING_AND_RANGED_BEHAVIOR.md` - Advanced AI behaviors
- `/docs/ENEMY_PARTY_SYSTEM.md` - Party formations, states, decision weights
- `/docs/BOSS_MECHANICS.md` - Chain boss system, hazard spawning system

### Companion Systems
- `/docs/COMPANION_SYSTEM_TECHNICAL.md` - States, evasion, affinity, triggers, animation
- `/docs/COMPANION_GUIDE.md` - High-level companion design and relationships
- `/docs/AFFINITY_SYSTEM_DESIGN.md` - Affinity mechanics and scaling
- `/docs/Companion_Affinity_Triggers.md` - Trigger design documentation

### Core Systems
- `/docs/TRAIT_SYSTEM.md` - Trait stacking, tag system, trait functions
- `/docs/DAMAGE_TYPE_SYSTEM.md` - Damage types, integration, visual feedback
- `/docs/status-effects-system.md` - Status effects, opposing effects, wielder effects
- `/docs/QUEST_SYSTEM.md` - Quest database, objective types, Yarn integration
- `/docs/OPENABLE_CONTAINERS.md` - Container system, loot tables, persistence

### Technical Systems
- `/docs/SOUND_SYSTEM.md` - Sound variants, enemy sounds, playback functions
- `/docs/ANIMATION_SYSTEM.md` - Player and enemy animation systems
- `/docs/RANGED_ATTACK_SYSTEM_TECHNICAL.md` - Player and enemy ranged attacks
- `/docs/SAVE_SYSTEM.md` - Save/load architecture
- `/docs/COMBAT_FEEL_AND_IMPACT.md` - Visual feedback and game feel

### Design Documents
- `/docs/GAME_STORY_BIBLE.md` - Overall game story and lore
- `/docs/NARRATIVE_TONE_GUIDE.md` - Writing and narrative guidelines
- `/docs/ENEMIES.md` - Enemy design reference
- `/docs/LEVEL_THEMES_AND_MECHANICS.md` - Level design guidelines

## Performance Considerations

- Use `image_speed = 0` for manual sprite animation control
- Enemy AI uses state machines with alarm-based timing for expensive operations
- Pathfinding updates throttled to 120 frames (2 seconds) or player movement threshold
- Collision checks use GameMaker's built-in collision system with parent objects
- All entities use `move_and_collide()` with collision list for consistent behavior

## Save/Load System

The item system uses string keys (`equipped_sprite_key`) for save/load compatibility. When implementing save/load:
- Serialize `equipped` and `inventory` structs from obj_player
- Persistent objects inherit from `obj_persistent_parent` with `serialize()` and `deserialize()` methods
- Container states persist automatically via openable system
- Quest completion flags stored as global variables (e.g., `global.quest_protect_canopy_complete`)

See `/docs/SAVE_SYSTEM.md` for complete save/load documentation.
