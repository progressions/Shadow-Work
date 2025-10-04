# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-03-enemy-party-controller/spec.md

## Technical Requirements

### Party Controller Object (`obj_enemy_party_controller`)

**Properties:**
- `party_members` (array) - References to enemy instances in the party
- `party_leader` (instance or noone) - Reference to designated leader enemy
- `party_state` (enum: `PartyState`) - Current state (protecting, aggressive, cautious, desperate, emboldened, retreating)
- `initial_party_size` (int) - Original member count for percentage calculations
- `formation_template` (string) - Key to formation in global database
- `formation_data` (struct) - Current formation with role assignments and offsets
- `protect_x`, `protect_y` (real) - Protection point coordinates (for protecting state)
- `protect_radius` (real) - Maximum distance from protection point

**Decision Weight Configuration:**
- `weight_attack` (real) - Base weight for attacking player objective
- `weight_formation` (real) - Base weight for returning to formation objective
- `weight_flee` (real) - Base weight for fleeing objective
- `weight_modifiers` (struct) - Multipliers based on conditions (low_party_hp, low_player_hp, isolated, etc.)

**State Transition Thresholds:**
- `desperate_threshold` (real 0-1) - Party survival % to trigger desperate state (default 0.2)
- `cautious_threshold` (real 0-1) - Party survival % to trigger cautious state (default 0.5)
- `emboldened_player_hp_threshold` (real 0-1) - Player HP % to trigger emboldened state (default 0.3)

**Methods:**
- `init_party(enemy_array, formation_template_key)` - Initialize party with enemies and formation
- `assign_formation_roles()` - Assign roles to members based on formation template and enemy capabilities
- `update_party_state()` - Evaluate conditions and transition states
- `calculate_decision_weights(enemy_instance)` - Calculate weighted objectives for individual enemy
- `get_formation_position(enemy_instance)` - Get target formation coordinates for enemy
- `on_member_death(enemy_instance)` - Handle member removal and formation adjustment
- `on_leader_death()` - Virtual function, override per party type for custom behavior
- `serialize_party_data()` - Return struct for save system
- `deserialize_party_data(data)` - Restore party from saved data

### Formation System

**Global Formation Database** (`global.formation_database`)

Structure:
```gml
global.formation_database = {
    "line_3": {
        max_members: 3,
        roles: ["frontline", "frontline", "frontline"],
        offsets: [
            {x: 0, y: 0},      // Leader/center
            {x: -48, y: 0},    // Left
            {x: 48, y: 0}      // Right
        ]
    },
    "wedge_5": {
        max_members: 5,
        roles: ["frontline", "frontline", "frontline", "backline", "backline"],
        offsets: [
            {x: 0, y: 0},      // Point
            {x: -32, y: 32},   // Left front
            {x: 32, y: 32},    // Right front
            {x: -48, y: 64},   // Left back
            {x: 48, y: 64}     // Right back
        ]
    },
    "circle_4": {
        max_members: 4,
        roles: ["defender", "defender", "defender", "defender"],
        offsets: [
            {x: 0, y: -48},    // North
            {x: 48, y: 0},     // East
            {x: 0, y: 48},     // South
            {x: -48, y: 0}     // West
        ]
    },
    "protective_3": {
        max_members: 3,
        roles: ["frontline", "backline", "backline"],
        offsets: [
            {x: 0, y: 0},      // Tank front
            {x: -32, y: 48},   // Ranged left
            {x: 32, y: 48}     // Ranged right
        ]
    }
}
```

**Procedural Adjustments:**
- When party size < formation max_members, remove trailing positions
- When party size > formation max_members, duplicate offset pattern or fallback to "scattered" formation
- Rotate offsets based on party facing direction (toward player or protection point)

### Weighted Decision System

**Enemy Individual Behavior** (integrated into `obj_enemy_parent`)

Each enemy in a party evaluates three objectives each step:

1. **Attack Player** - Move toward player using grid pathfinding, attack when in range
2. **Return to Formation** - Move toward assigned formation position using grid pathfinding
3. **Flee** - Move away from player toward map edge or safe zone

**Weight Calculation Algorithm:**
```gml
// Base weights from party controller
var _w_attack = party_controller.weight_attack;
var _w_formation = party_controller.weight_formation;
var _w_flee = party_controller.weight_flee;

// Apply modifiers based on conditions
var _party_survival = party_controller.get_party_survival_percentage();
var _player_hp_pct = obj_player.hp / obj_player.hp_max;
var _my_hp_pct = hp / hp_max;
var _distance_from_formation = point_distance(x, y, formation_target_x, formation_target_y);

// Low party HP increases flee weight
if (_party_survival < 0.3) {
    _w_flee *= party_controller.weight_modifiers.low_party_survival;
}

// Low player HP increases attack weight
if (_player_hp_pct < 0.3) {
    _w_attack *= party_controller.weight_modifiers.low_player_hp;
}

// Low personal HP increases flee weight
if (_my_hp_pct < 0.2) {
    _w_flee *= party_controller.weight_modifiers.low_self_hp;
}

// Far from formation increases formation weight
if (_distance_from_formation > 100) {
    _w_formation *= party_controller.weight_modifiers.isolated;
}

// Choose highest weighted objective
var _max_weight = max(_w_attack, _w_formation, _w_flee);
if (_max_weight == _w_attack) {
    current_objective = "attack";
    objective_target_x = obj_player.x;
    objective_target_y = obj_player.y;
} else if (_max_weight == _w_formation) {
    current_objective = "formation";
    objective_target_x = formation_target_x;
    objective_target_y = formation_target_y;
} else {
    current_objective = "flee";
    objective_target_x = flee_target_x;
    objective_target_y = flee_target_y;
}
```

### Grid Pathfinding Integration

Enemies in parties use existing `grid_pathfinding_find_path()` function to reach objective targets. No changes to pathfinding algorithm required.

**Integration Points:**
- When objective = "attack", pathfind to player position
- When objective = "formation", pathfind to formation position
- When objective = "flee", pathfind away from player toward map edge

### Party State Machine

**PartyState Enum:**
```gml
enum PartyState {
    protecting,   // Guard a location, limited pursuit radius
    aggressive,   // Chase and attack player
    cautious,     // Maintain formation, engage when approached
    desperate,    // Few members remaining, high flee weights
    emboldened,   // Player is weak, high attack weights
    retreating    // Flee as a group
}
```

**State Transition Logic** (evaluated in party controller Step event):
```gml
function update_party_state() {
    var _survival = get_party_survival_percentage();
    var _player_hp_pct = obj_player.hp / obj_player.hp_max;

    // Desperate - low survival
    if (_survival <= desperate_threshold) {
        party_state = PartyState.desperate;
        return;
    }

    // Emboldened - player is weak
    if (_player_hp_pct <= emboldened_player_hp_threshold) {
        party_state = PartyState.emboldened;
        return;
    }

    // Cautious - medium survival
    if (_survival <= cautious_threshold) {
        party_state = PartyState.cautious;
        return;
    }

    // Default to aggressive or protecting based on initial config
    // (protecting state is set explicitly and doesn't auto-transition)
}
```

### Save/Load Integration

**Serialization Format:**
```gml
{
    party_id: "unique_id_string",
    party_state: PartyState.aggressive,
    initial_party_size: 5,
    formation_template: "wedge_5",
    protect_x: 1024,
    protect_y: 768,
    protect_radius: 200,
    member_ids: ["enemy_1_uuid", "enemy_2_uuid", "enemy_3_uuid"],
    leader_id: "enemy_1_uuid",
    weight_attack: 1.0,
    weight_formation: 0.8,
    weight_flee: 0.3,
    weight_modifiers: {
        low_party_survival: 3.0,
        low_player_hp: 2.0,
        low_self_hp: 2.5,
        isolated: 1.5
    },
    desperate_threshold: 0.2,
    cautious_threshold: 0.5,
    emboldened_player_hp_threshold: 0.3
}
```

**Integration with existing save system:**
- Add party controller serialization to room save data
- Link enemies to party via UUID references
- Restore party controller first, then reconnect enemy references on load

### Audio Feedback

**State Transition Audio Cues:**
- `snd_party_aggressive` - Played when entering aggressive or emboldened state
- `snd_party_cautious` - Played when entering cautious state
- `snd_party_desperate` - Played when entering desperate state
- `snd_party_retreat` - Played when entering retreating state

**Implementation:**
```gml
function transition_to_state(new_state) {
    if (party_state == new_state) return;

    var _old_state = party_state;
    party_state = new_state;

    // Play audio cue
    switch (new_state) {
        case PartyState.aggressive:
        case PartyState.emboldened:
            audio_play_sound(snd_party_aggressive, 5, false);
            break;
        case PartyState.cautious:
            audio_play_sound(snd_party_cautious, 5, false);
            break;
        case PartyState.desperate:
            audio_play_sound(snd_party_desperate, 5, false);
            break;
        case PartyState.retreating:
            audio_play_sound(snd_party_retreat, 5, false);
            break;
    }
}
```

### Debug Visualization

**Debug Draw** (in party controller Draw event when `global.debug_mode == true`):
```gml
if (global.debug_mode) {
    // Draw formation positions
    for (var i = 0; i < array_length(party_members); i++) {
        var _enemy = party_members[i];
        if (instance_exists(_enemy)) {
            var _form_pos = get_formation_position(_enemy);
            draw_circle(_form_pos.x, _form_pos.y, 8, true);
            draw_line(_enemy.x, _enemy.y, _form_pos.x, _form_pos.y);
        }
    }

    // Draw party state text
    draw_set_color(c_yellow);
    draw_text(x, y - 32, "State: " + get_party_state_string());
    draw_text(x, y - 16, "Members: " + string(array_length(party_members)) + "/" + string(initial_party_size));

    // Draw protection radius if in protecting mode
    if (party_state == PartyState.protecting) {
        draw_circle(protect_x, protect_y, protect_radius, true);
    }
}
```

## External Dependencies

No new external dependencies required. This system integrates with existing GameMaker Studio 2 functionality and the current Shadow Work codebase:
- Existing grid pathfinding system
- Existing enemy state machines (`obj_enemy_parent`)
- Existing save/load system
- GameMaker built-in audio functions
