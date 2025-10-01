# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-09-30-companion-system/spec.md

> Created: 2025-09-30
> Version: 1.0.0

## Technical Requirements

### 1. Companion Object Architecture

#### obj_companion_parent (Base Object)

**Purpose**: Parent object for all companions providing shared infrastructure

**Instance Variables** (stored on each companion instance):
```gml
// Identity
companion_id = "";              // Unique identifier (e.g., "canopy")
companion_name = "";            // Display name (e.g., "Canopy")

// State
is_recruited = false;           // Recruitment status
is_active = false;              // Currently in player's party
is_following = false;           // Currently following player

// Stats
affinity = 1.0;                 // Relationship level (1.0-10.0)
quest_flags = {};               // Struct for quest progression tracking

// Animation
sprite_idle = -1;               // Idle animation sprite
sprite_walk = -1;               // Walking animation sprite
current_anim_state = "idle";    // Current animation state
facing_direction = "down";      // Direction facing (up, down, left, right)
image_speed = 0;                // Manual animation control

// Following AI
follow_distance_min = 24;       // Minimum follow distance in pixels
follow_distance_max = 32;       // Maximum follow distance in pixels
move_speed = 2;                 // Movement speed
target_x = 0;                   // Target position X
target_y = 0;                   // Target position Y

// Auras
auras = [];                     // Array of aura definition structs

// Triggers
triggers = [];                  // Array of trigger definition structs
trigger_cooldowns = {};         // Cooldown tracking for triggers

// Persistence
persistent = true;              // Persist across room changes
```

**Core Events**:
- `Create_0`: Initialize base variables
- `Step_0`: Execute following AI, evaluate triggers, update animation
- `Draw_0`: Render companion sprite with current animation frame
- `Room_Start`: Re-establish connection to player if active
- `Room_End`: Clean up aura effects

**Core Functions** (defined in companion parent):
```gml
/// @function companion_recruit()
/// @description Marks companion as recruited and joins party

/// @function companion_activate()
/// @description Adds companion to active party and begins following

/// @function companion_deactivate()
/// @description Removes companion from active party

/// @function companion_apply_auras()
/// @description Applies all auras to player

/// @function companion_remove_auras()
/// @description Removes all auras from player

/// @function companion_evaluate_triggers()
/// @description Checks trigger conditions and activates if met

/// @function companion_update_following()
/// @description Updates following AI behavior

/// @function companion_update_animation()
/// @description Updates sprite and animation frame
```

#### obj_canopy (Canopy Companion)

**Purpose**: First companion implementation inheriting from `obj_companion_parent`

**Create Event Additions**:
```gml
// Inherit parent create
event_inherited();

// Set identity
companion_id = "canopy";
companion_name = "Canopy";

// Set sprites
sprite_idle = spr_canopy;  // Uses existing sprite
sprite_walk = spr_canopy;

// Define auras
auras = [
    {
        type: "protective",
        stat: "defense_rating",
        value: 1,
        description: "Grants +1 DR to player"
    },
    {
        type: "regeneration",
        stat: "hp_regen",
        value: 0.1,  // 0.1 HP per step (6 HP per second at 60 FPS)
        description: "Slowly regenerates player HP"
    }
];

// Define triggers
triggers = [
    {
        id: "shield",
        condition: function() {
            return obj_player.hp_current < (obj_player.hp_total * 0.3);
        },
        effect: function() {
            // Apply temporary damage reduction buff to player
            if (!variable_instance_exists(obj_player, "shield_active")) {
                obj_player.shield_active = true;
                obj_player.shield_dr_bonus = 3;  // +3 DR while shield active
                obj_player.shield_duration = 180; // 3 seconds at 60 FPS

                // Visual/audio feedback
                // show_debug_message("Canopy's Shield activated!");
            }
        },
        cooldown: 600,  // 10 seconds at 60 FPS
        description: "Activates protective shield when player HP < 30%"
    }
];

// Initialize cooldowns
trigger_cooldowns = {
    shield: 0
};
```

### 2. Following AI System

#### Distance-Based Following

**Algorithm**:
1. Calculate distance to player each step
2. If distance > `follow_distance_max`: Move toward player
3. If distance < `follow_distance_min`: Stop moving
4. If within range: Idle animation

**Implementation**:
```gml
/// @function companion_update_following()
/// In obj_companion_parent Step event

if (!is_following || !instance_exists(obj_player)) {
    return;
}

// Calculate distance to player
var _dist = point_distance(x, y, obj_player.x, obj_player.y);

// Update target position
target_x = obj_player.x;
target_y = obj_player.y;

// Movement logic
if (_dist > follow_distance_max) {
    // Calculate direction to player
    var _dir = point_direction(x, y, target_x, target_y);

    // Calculate movement vector
    var _move_x = lengthdir_x(move_speed, _dir);
    var _move_y = lengthdir_y(move_speed, _dir);

    // Move with collision detection
    move_and_collide(_move_x, _move_y, "Tiles_Col");

    // Update animation state
    current_anim_state = "walking";

    // Update facing direction
    if (abs(_move_x) > abs(_move_y)) {
        facing_direction = (_move_x > 0) ? "right" : "left";
    } else {
        facing_direction = (_move_y > 0) ? "down" : "up";
    }
} else if (_dist < follow_distance_min) {
    // Too close, stop moving
    current_anim_state = "idle";
} else {
    // Within acceptable range
    current_anim_state = "idle";
}
```

#### Collision Handling

**Tilemap Collision**:
- Use `layer_tilemap_get_id("Tiles_Col")` for collision layer
- Use `move_and_collide()` helper function (similar to player/enemy movement)
- Check collision before moving, adjust path if blocked

**Entity Collision**:
- Avoid collision with `obj_enemy_parent` instances
- Use `place_meeting()` to detect potential collisions
- Adjust path slightly if blocked by enemy

### 3. Aura System

#### Aura Definition Structure

```gml
{
    type: "aura_type_name",        // Unique identifier
    stat: "stat_name",             // Player stat to modify
    value: numeric_value,          // Modifier value
    description: "text"            // Human-readable description
}
```

#### Aura Application

**Protective Aura (+1 DR)**:
```gml
// Applied in companion_apply_auras()
obj_player.defense_rating_bonus += 1;  // Add to existing DR bonus tracking
```

**Regeneration Aura**:
```gml
// Applied each step when active
if (obj_player.hp_current < obj_player.hp_total) {
    obj_player.hp_current += 0.1;  // Passive regeneration
    obj_player.hp_current = min(obj_player.hp_current, obj_player.hp_total);
}
```

#### Aura Management

**Activation**:
- Called in `companion_activate()` function
- Iterates through `auras` array
- Applies each aura effect to player

**Deactivation**:
- Called in `companion_deactivate()` and `Room_End` event
- Removes all aura effects from player
- Prevents stat modifiers from persisting incorrectly

### 4. Trigger System

#### Trigger Definition Structure

```gml
{
    id: "trigger_id",                  // Unique identifier
    condition: function() {},          // Function returning bool
    effect: function() {},             // Function to execute when triggered
    cooldown: frames,                  // Cooldown in frames (60 = 1 second)
    description: "text"                // Human-readable description
}
```

#### Trigger Evaluation

**Execution Flow**:
1. Each step, iterate through `triggers` array
2. Check if trigger is on cooldown (skip if cooldown > 0)
3. Evaluate `condition()` function
4. If condition returns true, execute `effect()` function
5. Set cooldown to trigger's `cooldown` value
6. Decrement all active cooldowns each step

**Implementation**:
```gml
/// @function companion_evaluate_triggers()
/// In obj_companion_parent Step event

if (!is_active) {
    return;
}

// Decrement cooldowns
var _trigger_ids = variable_struct_get_names(trigger_cooldowns);
for (var i = 0; i < array_length(_trigger_ids); i++) {
    var _id = _trigger_ids[i];
    if (trigger_cooldowns[$ _id] > 0) {
        trigger_cooldowns[$ _id]--;
    }
}

// Evaluate triggers
for (var i = 0; i < array_length(triggers); i++) {
    var _trigger = triggers[i];

    // Skip if on cooldown
    if (trigger_cooldowns[$ _trigger.id] > 0) {
        continue;
    }

    // Check condition
    if (_trigger.condition()) {
        // Execute effect
        _trigger.effect();

        // Set cooldown
        trigger_cooldowns[$ _trigger.id] = _trigger.cooldown;
    }
}
```

#### Shield Trigger Implementation

**Condition**: Player HP < 30% of max HP
**Effect**: Apply temporary +3 DR buff for 3 seconds
**Cooldown**: 10 seconds

**Player Integration**:
```gml
// In obj_player Step event, add shield duration tracking
if (variable_instance_exists(self, "shield_active") && shield_active) {
    shield_duration--;
    if (shield_duration <= 0) {
        shield_active = false;
        shield_dr_bonus = 0;
    }
}

// In obj_player get_total_defense() function
var _total_dr = defense_rating + defense_rating_bonus;
if (variable_instance_exists(self, "shield_active") && shield_active) {
    _total_dr += shield_dr_bonus;
}
```

### 5. Animation System

#### Sprite Sheet Structure

**Existing Asset**: `spr_canopy`
- Assumes similar structure to enemy sprites
- Manual frame control with `image_speed = 0`

#### Animation States

**Idle**: Single frame per direction
**Walking**: Animated frames for movement

**Implementation**:
```gml
/// @function companion_update_animation()
/// In obj_companion_parent Step event

sprite_index = (current_anim_state == "walking") ? sprite_walk : sprite_idle;

// Update image_index based on facing_direction
// This will depend on spr_canopy sprite sheet layout
// Assuming similar structure to player/enemy sprites
switch (facing_direction) {
    case "down":
        image_index = 0;  // Adjust based on actual sprite layout
        break;
    case "up":
        image_index = 8;  // Adjust based on actual sprite layout
        break;
    case "left":
        image_index = 16; // Adjust based on actual sprite layout
        break;
    case "right":
        image_index = 24; // Adjust based on actual sprite layout
        break;
}

// Animate if walking
if (current_anim_state == "walking") {
    // Simple animation cycle (adjust frame range based on sprite)
    image_index += 0.2;  // Animation speed
    // Wrap around based on sprite frames available
}
```

### 6. Player Integration

#### Step Event Modifications

**Add to obj_player Step_0**:
```gml
// Apply companion regeneration auras
apply_companion_regeneration_auras();
```

**New Player Function**:
```gml
/// @function apply_companion_regeneration_auras()
/// @description Applies HP regeneration from active companions

function apply_companion_regeneration_auras() {
    // Iterate through active companions
    with (obj_companion_parent) {
        if (is_active) {
            for (var i = 0; i < array_length(auras); i++) {
                var _aura = auras[i];
                if (_aura.type == "regeneration") {
                    if (obj_player.hp_current < obj_player.hp_total) {
                        obj_player.hp_current += _aura.value;
                        obj_player.hp_current = min(obj_player.hp_current, obj_player.hp_total);
                    }
                }
            }
        }
    }
}
```

#### Defense Rating Calculation

**Modify get_total_defense() in obj_player**:
```gml
/// @function get_total_defense()
/// @description Calculates total DR including companion auras

function get_total_defense() {
    var _total_dr = defense_rating;

    // Add armor DR bonus
    if (variable_instance_exists(self, "defense_rating_bonus")) {
        _total_dr += defense_rating_bonus;
    }

    // Add companion aura DR bonus
    _total_dr += get_companion_dr_bonus();

    // Add shield trigger DR bonus
    if (variable_instance_exists(self, "shield_active") && shield_active) {
        _total_dr += shield_dr_bonus;
    }

    return _total_dr;
}

/// @function get_companion_dr_bonus()
/// @description Calculates total DR bonus from active companions

function get_companion_dr_bonus() {
    var _bonus = 0;

    with (obj_companion_parent) {
        if (is_active) {
            for (var i = 0; i < array_length(auras); i++) {
                var _aura = auras[i];
                if (_aura.stat == "defense_rating") {
                    _bonus += _aura.value;
                }
            }
        }
    }

    return _bonus;
}
```

### 7. Persistence and Save/Load

#### Companion State Serialization

**Save Data Structure**:
```gml
global.save_data.companions = {
    canopy: {
        is_recruited: false,
        affinity: 1.0,
        quest_flags: {}
    }
    // Additional companions in future phases
};

global.save_data.active_companions = [];  // Array of companion IDs
```

**Save Function**:
```gml
/// @function save_companion_data()
/// @description Serializes all companion state to save data

function save_companion_data() {
    // Initialize companions struct if doesn't exist
    if (!variable_struct_exists(global.save_data, "companions")) {
        global.save_data.companions = {};
    }

    // Iterate through all companion instances
    with (obj_companion_parent) {
        global.save_data.companions[$ companion_id] = {
            is_recruited: is_recruited,
            affinity: affinity,
            quest_flags: quest_flags
        };
    }

    // Save active companions list
    global.save_data.active_companions = [];
    with (obj_companion_parent) {
        if (is_active) {
            array_push(global.save_data.active_companions, companion_id);
        }
    }
}
```

**Load Function**:
```gml
/// @function load_companion_data()
/// @description Restores companion state from save data

function load_companion_data() {
    if (!variable_struct_exists(global.save_data, "companions")) {
        return;
    }

    // Restore companion state
    with (obj_companion_parent) {
        if (variable_struct_exists(global.save_data.companions, companion_id)) {
            var _data = global.save_data.companions[$ companion_id];
            is_recruited = _data.is_recruited;
            affinity = _data.affinity;
            quest_flags = _data.quest_flags;

            // Activate if in active companions list
            var _active_list = global.save_data.active_companions;
            for (var i = 0; i < array_length(_active_list); i++) {
                if (_active_list[i] == companion_id) {
                    companion_activate();
                    break;
                }
            }
        }
    }
}
```

#### Room Transition Handling

**Room_Start Event**:
```gml
// In obj_companion_parent Room_Start event
if (is_active && instance_exists(obj_player)) {
    // Position companion near player
    x = obj_player.x + random_range(-48, 48);
    y = obj_player.y + random_range(-48, 48);

    // Resume following
    is_following = true;
}
```

**Room_End Event**:
```gml
// In obj_companion_parent Room_End event
// Clean up temporary effects
companion_remove_auras();
```

### 8. Recruitment System

#### Interaction Trigger

**Approach**: Use existing game interaction system (if available) or create simple proximity-based interaction

**Implementation Options**:

**Option A: Proximity + Key Press**:
```gml
// In obj_canopy Step event (before recruitment)
if (!is_recruited) {
    var _dist = point_distance(x, y, obj_player.x, obj_player.y);
    if (_dist < 32 && keyboard_check_pressed(ord("E"))) {
        companion_recruit();
        companion_activate();
    }
}
```

**Option B: Collision-based**:
- Create `obj_recruit_trigger` at Canopy's location
- Player collision with trigger initiates recruitment dialogue
- Acceptance recruits and activates companion

#### Recruitment Flow

1. Player approaches unrecruited Canopy
2. Interaction prompt appears (future: dialogue system)
3. Player accepts recruitment
4. `companion_recruit()` called, sets `is_recruited = true`
5. `companion_activate()` called, adds to party and begins following
6. Auras applied to player immediately
7. State saved to persistence system

### 9. Global Companion Management

#### Active Party Tracking

**Global Variable**:
```gml
// In scripts/scripts.gml or game initialization
global.active_companions = [];  // Array of companion instance IDs
global.max_party_size = 4;      // Future: allow multiple companions
```

**Management Functions**:
```gml
/// @function get_active_companion_count()
/// @description Returns number of companions in active party
function get_active_companion_count() {
    return array_length(global.active_companions);
}

/// @function add_companion_to_party(_companion_instance)
/// @description Adds companion to active party
function add_companion_to_party(_companion_instance) {
    if (get_active_companion_count() >= global.max_party_size) {
        return false;  // Party full
    }

    array_push(global.active_companions, _companion_instance);
    return true;
}

/// @function remove_companion_from_party(_companion_instance)
/// @description Removes companion from active party
function remove_companion_from_party(_companion_instance) {
    var _index = array_get_index(global.active_companions, _companion_instance);
    if (_index != -1) {
        array_delete(global.active_companions, _index, 1);
        return true;
    }
    return false;
}
```

### 10. Code Style and Conventions

**Naming Conventions** (Ruby-style):
- Functions: `snake_case` (e.g., `companion_recruit()`, `apply_companion_regeneration_auras()`)
- Variables: `snake_case` (e.g., `is_recruited`, `follow_distance_max`, `trigger_cooldowns`)
- Local variables: prefixed with `_` (e.g., `_dist`, `_aura`, `_trigger`)
- Enums: `PascalCase` (not needed for Phase 1)
- Struct properties: `snake_case` (e.g., `auras[i].type`, `quest_flags.some_flag`)

**Instance-Based Data Storage**:
- All companion-specific data stored on companion instance, not globals
- Exception: `global.active_companions` array for party tracking
- Benefits: Supports multiple companions, clean save/load, no name conflicts

**Code Organization**:
- Core companion functions in `obj_companion_parent` events
- Companion-specific data in child object Create events
- Player integration functions in `obj_player` or `scripts/scripts.gml`
- Save/load functions in existing save system

## Approach

### Implementation Phases

#### Phase 1A: Core Infrastructure (Days 1-2)
1. Create `obj_companion_parent` with base variables and events
2. Implement following AI with pathfinding
3. Create animation system skeleton
4. Test basic following behavior

#### Phase 1B: Canopy Implementation (Days 3-4)
1. Create `obj_canopy` inheriting from parent
2. Define Canopy's auras and triggers
3. Implement aura application system
4. Implement trigger evaluation system
5. Test auras and triggers

#### Phase 1C: Integration (Day 5)
1. Add player integration (regeneration, DR calculation)
2. Implement recruitment interaction
3. Add Room_Start/Room_End handling
4. Test room transitions

#### Phase 1D: Persistence (Day 6)
1. Implement save_companion_data()
2. Implement load_companion_data()
3. Integrate with existing save/load system
4. Test save/load cycle

#### Phase 1E: Polish and Testing (Day 7)
1. Refine animation timing
2. Add visual/audio feedback for triggers
3. Performance testing
4. Bug fixing and edge case handling

### Testing Strategy

**Unit Testing**:
- Following AI: Test distance calculations, pathfinding accuracy
- Aura System: Verify stat modifications apply/remove correctly
- Trigger System: Test condition evaluation, cooldown management
- Animation: Verify correct sprites/frames for each state

**Integration Testing**:
- Player damage reduction with Protective aura active
- HP regeneration over time with Regeneration aura
- Shield trigger activation at low HP
- Companion following through multiple rooms
- Save/load companion state preservation

**Edge Cases**:
- Player death while companion active (cleanup auras)
- Room transition while trigger active (handle cooldowns)
- Loading save with companion active (restore state)
- Multiple simultaneous auras (ensure stacking works)

## External Dependencies

### GameMaker Built-in Functions
- `point_distance()` - Distance calculations for following AI
- `point_direction()` - Direction calculations for pathfinding
- `lengthdir_x()`, `lengthdir_y()` - Vector calculations
- `layer_tilemap_get_id()` - Collision layer access
- `place_meeting()` - Collision detection
- `instance_exists()` - Instance validation
- `variable_instance_exists()` - Safe variable checking
- `variable_struct_exists()` - Struct property checking
- `array_length()`, `array_push()`, `array_delete()` - Array operations

### Existing Game Systems
- **Player Object** (`obj_player`): Integration for auras, triggers, stats
- **Save/Load System**: Companion state persistence
- **Collision System**: Tilemap collision detection
- **Item/Equipment System**: Future integration for affinity gains

### Existing Sprites
- `spr_canopy`: Canopy companion sprite sheet

### Helper Functions (May Need Creation)
- `move_and_collide()`: Collision-aware movement (similar to player/enemy movement)
- `array_get_index()`: Find index of element in array

## Performance Considerations

### Optimization Strategies

1. **Following AI**:
   - Calculate distance only when companion is active
   - Use squared distance for comparison (avoid sqrt) if possible
   - Limit pathfinding calculations to active companions only

2. **Trigger Evaluation**:
   - Skip cooldown checks for inactive companions
   - Early return if no triggers defined
   - Cache condition results when possible

3. **Aura Application**:
   - Apply auras once on activation, not every frame
   - Remove auras once on deactivation
   - Use direct variable modification instead of function calls in loops

4. **Animation**:
   - Manual sprite control to avoid unnecessary calculations
   - Update animation only when state changes

### Expected Performance Impact

- **CPU**: Minimal impact with 1-4 active companions
- **Memory**: ~2-3 KB per companion instance
- **Draw Calls**: +1 per active companion (negligible)

## Future Extensibility

### Designed for Expansion

1. **Additional Companions**: Parent object architecture supports easy creation of new companions
2. **Quest System**: `quest_flags` struct ready for quest integration
3. **Affinity System**: Affinity value tracked, ready for progression mechanics
4. **Advanced Triggers**: Trigger system supports complex conditions and effects
5. **Multiple Active Companions**: `global.active_companions` array supports party management
6. **Dialogue Integration**: Recruitment system can be extended with dialogue trees

### Planned Enhancements (Future Phases)

- Formation positioning for multiple companions
- Companion-specific equipment slots
- Affinity-based ability unlocks
- Combat AI for active attacking
- Companion progression/leveling system
