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
- **Documentation**: `/docs/` - System documentation (party system, containers, traits, etc.)

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

## Combat System Architecture

### Damage Calculation Pipeline (Player Attacks)
1. **Base Damage** → Get from equipped weapon stats (with versatile/dual-wield modifiers)
2. **Status Effect Modifiers** → Apply damage buffs/debuffs via `get_status_effect_modifier("damage")`
3. **Companion Bonuses** → Add attack bonuses from companion auras via `get_companion_attack_bonus()`
4. **Critical Hit Roll** → Roll against `crit_chance`, multiply by `crit_multiplier` if successful
5. **Dash Attack Bonus** → Apply 1.5x multiplier if `is_dash_attacking` is true

### Damage Reduction Pipeline (When Hit)
1. **Damage Type Modifier** → Apply trait-based resistance/vulnerability via `get_damage_modifier_for_type()`
2. **Equipment DR** → Subtract general + category-specific DR (melee or ranged)
3. **Companion DR** → Add DR bonuses from companion auras
4. **Defense Trait Modifier** → Multiply total DR by defense modifier from traits (bolstered/sundered)
5. **Chip Damage** → If final damage ≤ 0, apply 1 chip damage minimum

### Attack Categories
- **AttackCategory.melee** - Sword swings, dagger strikes, unarmed attacks
- **AttackCategory.ranged** - Arrows, thrown weapons, projectiles
- Affects which DR calculation to use (`get_equipment_melee_dr()` vs `get_equipment_ranged_dr()`)

### Combat Visual Feedback
- **Freeze Frame** - 2-4 frame pause on hit (`freeze_frame(duration)`)
- **Screen Shake** - Intensity based on weapon (daggers=2, swords=4, two-handed=8)
- **Enemy Flash** - White flash (normal hit) or red flash (crit) via `enemy_flash(color, duration)`
- **Hit Sparkles** - Spray particles away from impact using `spawn_hit_effect(x, y, direction)`
- **Slow-Mo** - 0.5s bullet-time on companion triggers via `activate_slowmo(0.5)`
- **Damage Numbers** - Color-coded floating text showing damage amount and type

**Key Files:**
- `/scripts/scr_combat_system/scr_combat_system.gml` - Core damage calculation and combat helpers
- `/objects/obj_attack/Create_0.gml` - Melee attack instance creation
- `/objects/obj_arrow/Create_0.gml` - Ranged attack projectile
- `/objects/obj_enemy_parent/Collision_obj_attack.gml` - Damage application to enemies

## Trait System V2.0 (Stacking Mechanics)

### Core Concept
Traits are modifiers that stack up to 5 times and can cancel each other out. Each entity has:
- **permanent_traits** - From tags, quests, permanent equipment
- **temporary_traits** - From equipment, companions, timed buffs

### Tag System
Tags are thematic descriptors that grant trait bundles. Apply with `apply_tag_traits()`:
- **fireborne** → `["fire_immunity", "ice_vulnerability"]`
- **venomous** → `["poison_immunity", "deals_poison_damage"]`
- **arboreal** → `["fire_vulnerability", "poison_resistance"]`
- **aquatic** → `["lightning_vulnerability", "fire_resistance"]`
- **glacial** → `["ice_immunity", "fire_vulnerability"]`
- **swampridden** → `["poison_immunity", "disease_resistance"]`
- **sandcrawler** → `["fire_resistance", "heat_adapted"]`

### Trait Stacking Rules
- **Stack Cancellation** - Opposite traits cancel stack-by-stack (e.g., 3 fire_resistance + 2 fire_vulnerability = 1 fire_resistance)
- **Immunity Override** - Immunity traits (0.0 multiplier) can be cancelled by vulnerability stacks
- **Defense Traits** - `defense_resistance` (bolstered) vs `defense_vulnerability` (sundered) affect all DR
  - Bolstered: `1.33^stacks` multiplier to DR
  - Sundered: `0.75^stacks` multiplier to DR
- **Damage Type Traits** - Resistance (`0.75^stacks`), Vulnerability (`1.5^stacks`), Immunity (0.0)

### Key Functions
- `get_total_trait_stacks(trait_key)` - Returns combined permanent + temporary stacks (capped at 5)
- `get_damage_modifier_for_type(damage_type)` - Calculates final multiplier with cancellation logic
- `apply_tag_traits()` - Applies all traits from tags array as permanent traits
- `apply_timed_trait(trait_key, duration_seconds)` - Temporary trait with auto-removal alarm

**Key Files:**
- `/scripts/trait_system/trait_system.gml` - All trait system functions
- `/objects/obj_game_controller/Create_0.gml` - Tag and trait database initialization
- `/docs/TRAIT_SYSTEM.md` - Complete trait system documentation

## Damage Type System

### DamageType Enum
```gml
enum DamageType {
    physical, magical, fire, ice, lightning,
    poison, disease, holy, unholy
}
```

### Integration Points
1. **Weapons** - Each weapon has `damage_type` in stats (defaults to physical)
2. **Status Effects** - Burning applies fire damage, certain effects trigger type-specific damage
3. **Traits** - Damage type resistance/vulnerability/immunity traits modify incoming damage
4. **Visual Feedback** - Damage numbers color-coded by type via `damage_type_to_color()`

**Key Files:**
- `/scripts/scr_damage_type_helpers/scr_damage_type_helpers.gml` - Conversion and color functions
- `/scripts/scr_enums/scr_enums.gml` - DamageType enum definition

## Status Effects System

### Status Effect Types
- **burning** - DoT: 1 damage every 0.5s for 3s (fire damage type)
- **wet** - -10% speed for 5s (increases ice damage taken)
- **empowered** - +50% damage for 10s
- **weakened** - -30% damage for 10s
- **swift** - +30% speed for 8s
- **slowed** - -40% speed for 5s

### Opposing Effects System
- **Neutralization** - Opposing effects neutralize each other (e.g., burning + wet = both neutralized)
- **Duration Refresh** - Reapplying same effect refreshes duration
- **Trait Immunity** - Traits can block status effects (e.g., `fire_immunity` blocks burning)

### Wielder Effects
Equipment can apply permanent status effects while equipped:
```gml
wielder_effects: [
    {effect: StatusEffectType.empowered}
]
```

**Key Files:**
- `/scripts/scr_status_effects/scr_status_effects.gml` - All status effect functions
- `/docs/status-effects-system.md` - Complete status effects documentation

## Enemy AI Architecture

### State Machine (EnemyState Enum)
```gml
enum EnemyState {
    idle,             // Standing still
    targeting,        // Pursuing player with pathfinding
    attacking,        // Executing melee attack
    ranged_attacking, // Firing projectile, can move while shooting
    dead,             // Death state with animation
    wander            // Random movement within radius
}
```

### Pathfinding System
- **mp_grid Pathfinding** - Uses GameMaker's built-in pathfinding with obstacle detection
- **Path Update Throttling** - Recalculates every 120 frames (2 seconds) or when player moves 64+ pixels
- **Ideal Range** - Enemies maintain optimal distance (melee: attack_range, ranged: 75-80% of attack_range)
- **LOS Checks** - Ranged enemies require clear line of sight via `enemy_has_line_of_sight()`
- **Unstuck System** - Alarm[4] detects stuck enemies and forces random direction movement

### Dual-Mode Combat System
Enemies with `enable_dual_mode = true` can switch between melee and ranged based on context:

**Attack Mode Decision Logic:**
1. **Distance Check** - If beyond ideal_range → ranged, if below melee_range_threshold → melee
2. **Formation Role Override** - "rear"/"support" forces ranged, "front"/"vanguard" forces melee
3. **Cooldown Gate** - Can't use mode if on cooldown, fallback to other mode if available
4. **Retreat Behavior** - Ranged-preferring enemies retreat if player breaches ideal_range

**Key Configuration Variables:**
```gml
enable_dual_mode = true;                    // Toggle context-based switching
preferred_attack_mode = "ranged";           // "none", "melee", or "ranged"
melee_range_threshold = attack_range * 0.5; // Distance below which melee is preferred
retreat_when_close = true;                  // Retreat when player gets too close
retreat_cooldown = 0;                       // Prevents pathfinding spam (60 frames)
formation_role = undefined;                 // Set by party controller: "rear", "front", "support"
```

### Flanking & Approach Variation
- **Flank Trigger Distance** - 120 pixels default (configurable via `flank_trigger_distance`)
- **Flank Chance** - 40% probability default (configurable via `flank_chance`)
- **Flank Calculation** - Approaches from behind player (opposite of facing_dir + random ±30° variance)
- **One-Time Selection** - Approach chosen once per aggro cycle, resets when losing aggro

**Key Files:**
- `/objects/obj_enemy_parent/Create_0.gml` - Enemy initialization and variables
- `/objects/obj_enemy_parent/Step_0.gml` - State machine dispatcher
- `/scripts/scr_enemy_state_targeting/scr_enemy_state_targeting.gml` - Pathfinding, targeting, dual-mode logic
- `/scripts/scr_enemy_state_ranged_attacking/scr_enemy_state_ranged_attacking.gml` - Ranged attack state

## Enemy Party System

### Party States (PartyState Enum)
```gml
enum PartyState {
    protecting,   // Guard location, limited pursuit
    aggressive,   // Chase and attack player
    cautious,     // Maintain formation, defensive
    desperate,    // Low health, high flee priority
    emboldened,   // Player weak, increased aggression
    retreating,   // Fleeing as a group
    patrolling    // Follow path until player detected
}
```

### Formation System
Formations defined in `global.formation_database`:
- **line_3** - Horizontal line formation (3 members)
- **wedge_5** - V-shaped attack formation (5 members)
- **circle_4** - Defensive circle (4 members)
- **protective_3** - Guard formation (3 members)

Each formation has position offsets from controller center:
```gml
{
    name: "wedge_5",
    offsets: [
        {x: 0, y: -32},    // Leader (front)
        {x: -24, y: 0},    // Left flank
        {x: 24, y: 0},     // Right flank
        {x: -48, y: 32},   // Left rear
        {x: 48, y: 32}     // Right rear
    ]
}
```

### Decision Weight System
Parties use weighted random selection for objectives:
- **weight_attack** (0-100) - Priority for attacking player
- **weight_formation** (0-100) - Priority for maintaining formation
- **weight_flee** (0-100) - Priority for fleeing combat

Dynamic adjustments based on party state:
- `desperate` state → flee_weight × 3, attack_weight × 0.5
- `cautious` state → formation_weight × 1.5, attack_weight × 0.7
- `emboldened` state → attack_weight × 1.5, formation_weight × 0.7

### Auto-Spawning Pattern
Party controllers spawn their own members:
```gml
var enemies = [
    instance_create_layer(x - 48, y, layer, obj_burglar),
    instance_create_layer(x, y, layer, obj_burglar),
    instance_create_layer(x + 48, y, layer, obj_burglar)
];
init_party(enemies, "line_3");
```

**Key Files:**
- `/objects/obj_enemy_party_controller/` - Base party controller with all logic
- `/docs/ENEMY_PARTY_SYSTEM.md` - Complete party system documentation

## Companion System

### Companion States
```gml
enum CompanionState {
    waiting,    // Not recruited, at spawn position
    following,  // Following player (default after recruitment)
    casting,    // Performing trigger animation
    evading     // Maintaining distance from combat
}
```

### Combat Evasion Behavior
When player enters combat (combat_timer < combat_cooldown), companions automatically switch to evading:
- **Distance Range** - Maintains 64-128 pixels from player
- **Enemy Avoidance** - Detects enemies within 200 pixels and moves away
- **Recalculation Throttle** - Updates position every 20 frames (~333ms)
- **Hysteresis Buffer** - 0.5 second delay before returning to following (prevents state flicker)

### Affinity System & Aura Scaling
Companion auras scale with affinity (3.0 to 10.0):
- **Multiplier Formula** - `0.6 + (2.4 * sqrt((affinity - 3.0) / 7.0))`
- **Result Range** - 0.6x at affinity 3.0, 3.0x at affinity 10.0
- **Diminishing Returns** - Square root provides stronger early gains

### Trigger System
Companions have active abilities (triggers) with affinity-based unlocks:
- **Base Trigger** - Unlocked at affinity 0+ (always available)
- **Mid Trigger** - Unlocks at affinity 5+
- **Advanced Trigger** - Unlocks at affinity 8+
- **Ultimate Trigger** - Unlocks at affinity 10

**Trigger Activation Flow:**
1. Check trigger unlock status and cooldown
2. Check player HP threshold for trigger condition
3. Set `state = CompanionState.casting`
4. Play casting animation (3 frames × 200ms = 600ms)
5. Apply effect (DR bonus, heal, damage buff, slow-mo, etc.)
6. Start cooldown timer
7. Return to previous state (following or evading)

### Companion Animation (18-frame layout)
- Frames 0-1: idle_down (also idle_right)
- Frames 2-3: idle_left
- Frames 4-5: idle_up
- Frames 6-8: casting_down
- Frames 9-11: casting_right
- Frames 12-14: casting_left
- Frames 15-17: casting_up

**Key Files:**
- `/objects/obj_companion_parent/Create_0.gml` - Companion initialization
- `/objects/obj_companion_parent/Step_0.gml` - Following, evading, and trigger logic
- `/scripts/scr_companion_system/scr_companion_system.gml` - Helper functions for bonuses

## Sound System

### Sound Variant Randomization
The sound system supports automatic variant selection for variety:
- **Variant Naming** - Base sound + numbered variants (e.g., `snd_sword_hit`, `snd_sword_hit_1`, `snd_sword_hit_2`)
- **Cache Lookup** - `global.sound_variant_lookup[sound_name]` stores variant count
- **Random Selection** - `play_sfx()` automatically picks random variant if available
- **Debug Mode** - `global.debug_sound_variants` flag for logging variant selection

### Enemy Sound Configuration
Enemies have separate sound events for melee vs ranged attacks:
```gml
enemy_sounds = {
    on_melee_attack: undefined,   // Defaults to snd_enemy_attack_generic
    on_ranged_attack: undefined,  // Defaults to snd_bow_attack
    on_hit: undefined,            // Defaults to snd_enemy_hit_generic
    on_death: undefined,          // Defaults to snd_enemy_death
    on_aggro: undefined,          // No default (optional)
    on_footstep: undefined,       // No default (optional)
    on_status_effect: undefined   // Defaults to snd_status_effect_generic
}
```

Override in child enemy Create events:
```gml
enemy_sounds.on_melee_attack = snd_orc_attack;
enemy_sounds.on_ranged_attack = snd_bow_attack;
```

### Sound Functions
- `play_sfx(sound, volume, priority, loop, fade_in, fade_out)` - Main sound function with variant support
- `play_enemy_sfx(event_name)` - Plays enemy sound with custom/fallback logic
- `stop_looped_sfx(sound)` - Stops looping sound via controller

**Key Files:**
- `/scripts/scr_sfx_functions/scr_sfx_functions.gml` - Sound playback functions
- `/objects/obj_sfx_controller/Create_0.gml` - Sound controller initialization

## Animation Systems

### Player Animation (Custom Frame-Based)
Player uses `anim_data` struct with manual frame control for 58-frame sprite:
- **Animation Types** - Idle (2 frames), Walk (4-5 frames), Dash (4 frames), Attack (4 frames)
- **Frame Advancement** - `anim_frame += anim_speed_walk` or `anim_speed_idle`
- **Manual Control** - `image_speed = 0`, set `image_index` directly based on state

### Enemy Animation (State-Based)
Enemy animation uses global frame tracker and state lookups:

**Standard Enemy Layout (35 frames for melee-only):**
- Frames 0-1: idle_down, 2-3: idle_right, 4-5: idle_left, 6-7: idle_up
- Frames 8-10: walk_down, 11-13: walk_right, 14-16: walk_left, 17-19: walk_up
- Frames 20-22: attack_down, 23-25: attack_right, 26-28: attack_left, 29-31: attack_up
- Frames 32-34: dying

**Extended Layout (47 frames for dual-mode with ranged attacks):**
- Frames 0-34: Standard layout above
- Frames 35-37: ranged_attack_down (3 frames)
- Frames 38-41: ranged_attack_right (4 frames)
- Frames 42-45: ranged_attack_left (4 frames)
- Frames 46-48: ranged_attack_up (3 frames)

**Animation Override System:**
Enemies can override with `enemy_anim_overrides` struct:
```gml
enemy_anim_overrides = {
    ranged_attack_down: {start: 35, length: 3},
    ranged_attack_right: {start: 38, length: 4},
    ranged_attack_left: {start: 42, length: 4},
    ranged_attack_up: {start: 46, length: 3}
};
```

**Key Files:**
- `/scripts/scr_animation_helpers/scr_animation_helpers.gml` - Enemy animation data and lookup
- `/objects/obj_enemy_parent/Step_0.gml` - Animation frame calculation
- `/objects/obj_player/Create_0.gml` - Player anim_data struct

## Quest System

### Quest Database
All quests defined in `global.quest_database` via `init_quest_database()`:
```gml
{
    quest_id: "protect_canopy_village",
    quest_name: "Protect Canopy Village",
    quest_giver: "hola",
    description: "Defeat 5 bandits threatening the village",
    objectives: [
        {type: "kill", target: "obj_burglar", required: 5, current: 0}
    ],
    rewards: {xp: 100, items: ["rusty_dagger"]},
    prerequisites: [],
    completion_flag: "quest_protect_canopy_complete"
}
```

### Objective Types (Auto-Tracking)
- **recruit_companion** - Tracks when companions join (auto-tracked in `recruit_companion()`)
- **kill** - Tracks enemy kills (auto-tracked in `enemy_state_dead()`)
- **collect** - Tracks quest item pickup (auto-tracked in `inventory_add_item()`)
- **deliver** - Manual call to `quest_check_delivery(object_name)` when player talks to NPC
- **location** - Create `obj_quest_marker` and call `quest_check_location_reached(quest_id)` in collision
- **spawn_kill** - Use `spawn_quest_enemy(obj, x, y, room, quest_id)` to spawn, auto-tracked on death

### Yarn Dialogue Integration
Quests are offered through Yarn dialogue files using Chatterbox functions:
```yarn
<<if quest_can_accept("protect_canopy_village")>>
    -> Accept the quest
        <<quest_accept("protect_canopy_village")>>
        I'll help you!
<<endif>>

<<if quest_is_active("protect_canopy_village")>>
    -> Check quest progress
        <<quest_get_progress("protect_canopy_village")>>
<<endif>>
```

**Key Files:**
- `/scripts/scr_quest_system/scr_quest_system.gml` - All quest functions
- `/objects/obj_player/Create_0.gml` - Active quests storage

## Item & Inventory System

### Item Database
All items defined in `global.item_database` in `/scripts/scripts.gml`:
```gml
rusty_dagger: {
    item_id: "rusty_dagger",
    type: ItemType.weapon,
    handedness: WeaponHandedness.one_handed,
    stats: {
        attack_damage: 2,
        attack_speed: 1.2,
        attack_range: 20
    },
    world_sprite_frame: 0,
    equipped_sprite_key: "rusty_dagger"
}
```

### Equipment System
- **Equipment slots**: right_hand, left_hand, head, torso, legs
- **Loadout System** - Switch between melee and ranged loadouts
- **Two-Handing** - Versatile weapons can be two-handed for damage bonus
- **Wielder Effects** - Equipment can apply permanent status effects while equipped

**Key Functions:**
- `inventory_add_item(item_key, quantity)` - Add item to inventory
- `equip_item(item_key, slot)` - Equip item to slot
- `unequip_item(slot)` - Remove item from slot
- `get_total_damage()` - Calculate total player damage with all modifiers
- `get_attack_range()` - Calculate total attack range
- `is_two_handing()` - Check if player is two-handing versatile weapon

**Key Files:**
- `/scripts/scripts.gml` - Item database initialization
- `/scripts/scr_inventory/scr_inventory.gml` - Inventory functions
- `/scripts/scr_combat_system/scr_combat_system.gml` - Combat stat calculations

## Common Implementation Tasks

### Adding New Damage Types
1. Add to `DamageType` enum in `/scripts/scr_enums/scr_enums.gml`
2. Add color mapping in `damage_type_to_color()` in `/scripts/scr_damage_type_helpers/scr_damage_type_helpers.gml`
3. Create immunity/resistance/vulnerability traits in `global.trait_database`
4. Add to relevant tags in `global.tag_database`

### Creating Dual-Mode Enemies
1. Inherit from `obj_enemy_parent`
2. Set dual-mode configuration in Create event:
```gml
enable_dual_mode = true;
preferred_attack_mode = "ranged";  // or "melee" or "none"
retreat_when_close = true;
melee_range_threshold = 32;
ideal_range = attack_range * 0.75;
```
3. Configure both melee and ranged stats (attack_damage, ranged_damage, etc.)
4. Use 47-frame sprite with ranged attack animations (frames 35-48)
5. Override `enemy_anim_overrides` if using custom layout
6. Set separate sounds for melee vs ranged:
```gml
enemy_sounds.on_melee_attack = snd_sword_swing;
enemy_sounds.on_ranged_attack = snd_bow_attack;
```

### Creating New Enemies
1. Create object inheriting from `obj_enemy_parent`
2. Override Create event to set stats:
```gml
event_inherited();

hp = 10;
hp_total = hp;
attack_damage = 3;
attack_speed = 0.8;
attack_range = 25;
move_speed = 1.0;
```
3. Apply tags for trait bundles: `array_push(tags, "fireborne"); apply_tag_traits();`
4. Configure flank behavior: `flank_chance = 0.6; flank_trigger_distance = 120;`
5. Add sprite with appropriate animation frames (35 or 47-frame layout)

### Creating Enemy Parties
See `/docs/ENEMY_PARTY_SYSTEM.md` for detailed instructions. Quick overview:
1. Create object inheriting from `obj_enemy_party_controller`
2. Configure party state, formation, and weights in Create event
3. Auto-spawn members with `init_party(enemies_array, formation_key)`
4. Optional: Configure patrol path or protect point

### Creating Openable Containers
See `/docs/OPENABLE_CONTAINERS.md` for detailed instructions. Quick overview:
1. Create object inheriting from `obj_openable`
2. Create 4-frame sprite (closed → opening → open → open)
3. Configure loot mode and loot table in Create event:
```gml
loot_mode = "random_weighted";
loot_table = [
    {item_key: "rusty_dagger", weight: 2},
    {item_key: "small_health_potion", weight: 3}
];
```
4. Container persists automatically via save/load system

### Adding New Items
1. Add item definition to `global.item_database` in `/scripts/scripts.gml`
2. Create world sprite frame in `spr_items` sprite sheet
3. Add equipped sprite variant if needed (e.g., `spr_wielded_[item_name]`)
4. For weapons: Set damage_type, attack_damage, attack_speed, attack_range
5. For armor: Set melee_dr, ranged_dr, general_dr

### Creating New Quests
1. Add quest definition to `init_quest_database()` in `/scripts/scr_quest_system/scr_quest_system.gml`
2. Define quest properties: quest_id, quest_name, quest_giver, objectives, rewards
3. Add quest dialogue to companion's Yarn file using quest functions
4. Objective types auto-track through gameplay (no manual progress calls needed for kill/collect)

### Creating Quest Marker Objects
For location objectives:
1. Create object (inheriting from parent or standalone)
2. Add variable `quest_id` (string) - set to the quest this marker is for
3. Add Collision event with `obj_player`:
```gml
if (quest_check_location_reached(quest_id)) {
    instance_destroy();
}
```
4. Place marker in room where player should go

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
