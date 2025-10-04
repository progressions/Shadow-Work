# Enemy Party System

## Overview

The enemy party system provides coordinated group behavior for enemies in Shadow Work. Parties use formations, shared decision-making, and dynamic state changes based on combat conditions. Party controllers automatically spawn and manage their members, integrate with the save/load system, and work alongside individual enemy AI.

## Object Hierarchy

```
obj_persistent_parent (base persistence)
└── obj_enemy_party_controller (party management base class)
    ├── obj_gate_guard_party (defensive patrol example)
    └── obj_orc_raiding_party (aggressive example)
```

## Core Features

### Party States

Parties use the `PartyState` enum to manage behavior:

- **`protecting`**: Defend a specific location (protect_x, protect_y, protect_radius)
- **`aggressive`**: Actively pursue and attack the player
- **`cautious`**: Defensive formation, reduced attack priority
- **`desperate`**: Low health, high flee priority
- **`emboldened`**: Player low health, increased aggression
- **`retreating`**: Fleeing from combat
- **`patrolling`**: Following a path until player is detected

### Formation System

Formations are defined in `global.formation_database` (initialized in `obj_game_controller`):

```gml
global.formation_database = {
    line_3: {
        positions: [
            {x: -32, y: 0},
            {x: 0, y: 0},
            {x: 32, y: 0}
        ]
    },
    wedge_5: {
        positions: [
            {x: 0, y: -32},
            {x: -24, y: 0},
            {x: 24, y: 0},
            {x: -32, y: 32},
            {x: 32, y: 32}
        ]
    },
    circle_4: {
        positions: [
            {x: 0, y: -32},
            {x: 32, y: 0},
            {x: 0, y: 32},
            {x: -32, y: 0}
        ]
    },
    protective_3: {
        positions: [
            {x: 0, y: -24},
            {x: -24, y: 16},
            {x: 24, y: 16}
        ]
    }
};
```

### Auto-Spawning System

Party controller objects spawn their own enemy members in the Create event:

```gml
// Example from Create event
var enemies = [
    instance_create_layer(x - 48, y, layer, obj_burglar),
    instance_create_layer(x, y, layer, obj_burglar),
    instance_create_layer(x + 48, y, layer, obj_burglar)
];
init_party(enemies, formation_template);
```

This eliminates the need to manually place individual enemies in rooms.

### Decision System

Party controllers use weighted objectives that dynamically adjust based on conditions:

**Base weights** (configured per party):
- `weight_attack`: Priority for attacking player (0-100)
- `weight_formation`: Priority for maintaining formation (0-100)
- `weight_flee`: Priority for fleeing combat (0-100)

**Dynamic modifiers**:
- Party health percentage affects flee weight
- Player health percentage affects attack weight
- State changes trigger when thresholds are crossed

**State thresholds**:
- `desperate_threshold`: Party health % that triggers desperate state (default: 30%)
- `cautious_threshold`: Party health % that triggers cautious state (default: 50%)
- `emboldened_player_hp_threshold`: Player health % that triggers emboldened state (default: 25%)

## Implementation Details

### Core Variables (obj_enemy_party_controller/Create_0.gml)

```gml
// Party members
party_members = [];        // Array of enemy instances
formation_template = "";   // Key from global.formation_database

// State management
party_state = PartyState.aggressive;
previous_state = PartyState.aggressive;

// Decision weights
weight_attack = 70;
weight_formation = 50;
weight_flee = 20;

// State thresholds
desperate_threshold = 30;
cautious_threshold = 50;
emboldened_player_hp_threshold = 25;

// Patrol configuration (optional)
patrol_path = noone;           // Path resource
patrol_speed = 2;              // Movement speed along path
patrol_loop = true;            // Loop or stop at end
patrol_aggro_radius = 200;     // Detection range while patrolling
is_patrolling = false;

// Protect configuration (optional)
protect_x = x;
protect_y = y;
protect_radius = 100;

// Internal state
formation_center_x = x;
formation_center_y = y;
```

### Core Functions

#### `init_party(enemies_array, formation_key)`

Initializes the party with enemy members and formation:

```gml
function init_party(_enemies, _formation_key) {
    party_members = _enemies;
    formation_template = _formation_key;

    // Link enemies to this controller
    for (var i = 0; i < array_length(party_members); i++) {
        var _enemy = party_members[i];
        if (instance_exists(_enemy)) {
            _enemy.party_controller = id;
            _enemy.party_index = i;
        }
    }

    update_formation_positions();
}
```

#### `update_formation_positions()`

Calculates target positions for each party member based on formation template:

```gml
function update_formation_positions() {
    if (formation_template == "" || !variable_struct_exists(global.formation_database, formation_template)) {
        return;
    }

    var _formation = global.formation_database[$ formation_template];
    var _positions = _formation.positions;

    for (var i = 0; i < array_length(party_members); i++) {
        var _enemy = party_members[i];
        if (!instance_exists(_enemy)) continue;

        var _offset = _positions[i % array_length(_positions)];
        _enemy.formation_x = formation_center_x + _offset.x;
        _enemy.formation_y = formation_center_y + _offset.y;
    }
}
```

#### `calculate_party_health_percentage()`

Returns average health percentage of all living party members:

```gml
function calculate_party_health_percentage() {
    var _total_hp = 0;
    var _total_max_hp = 0;
    var _living_count = 0;

    for (var i = 0; i < array_length(party_members); i++) {
        var _enemy = party_members[i];
        if (instance_exists(_enemy) && _enemy.state != EnemyState.dead) {
            _total_hp += _enemy.hp;
            _total_max_hp += _enemy.hp_total;
            _living_count++;
        }
    }

    return (_living_count > 0) ? (_total_hp / _total_max_hp) * 100 : 0;
}
```

#### `update_party_state()`

Evaluates conditions and transitions party state:

```gml
function update_party_state() {
    var _party_health_pct = calculate_party_health_percentage();
    var _player_health_pct = (instance_exists(obj_player)) ? (obj_player.hp / obj_player.hp_total) * 100 : 100;

    // State transitions based on thresholds
    if (_party_health_pct <= desperate_threshold) {
        party_state = PartyState.desperate;
    } else if (_party_health_pct <= cautious_threshold) {
        party_state = PartyState.cautious;
    } else if (_player_health_pct <= emboldened_player_hp_threshold) {
        party_state = PartyState.emboldened;
    } else if (is_patrolling) {
        party_state = PartyState.patrolling;
    } else {
        party_state = PartyState.aggressive;
    }
}
```

#### `make_party_decision()`

Uses weighted random selection to choose party objective:

```gml
function make_party_decision() {
    // Adjust weights based on state
    var _attack_weight = weight_attack;
    var _formation_weight = weight_formation;
    var _flee_weight = weight_flee;

    switch (party_state) {
        case PartyState.desperate:
            _flee_weight *= 3;
            _attack_weight *= 0.5;
            break;
        case PartyState.cautious:
            _formation_weight *= 1.5;
            _attack_weight *= 0.7;
            break;
        case PartyState.emboldened:
            _attack_weight *= 1.5;
            _formation_weight *= 0.7;
            break;
    }

    // Weighted random selection
    var _total = _attack_weight + _formation_weight + _flee_weight;
    var _roll = random(_total);

    if (_roll < _attack_weight) {
        return "attack";
    } else if (_roll < _attack_weight + _formation_weight) {
        return "formation";
    } else {
        return "flee";
    }
}
```

### Integration with Individual Enemy AI

Enemy instances have these party-related variables added in `obj_enemy_parent`:

```gml
// Party integration
party_controller = noone;    // Instance of obj_enemy_party_controller
party_index = -1;            // Position in party_members array
formation_x = x;             // Target x for formation
formation_y = y;             // Target y for formation
```

Enemies check for party commands in their Step event but maintain individual behavior when not in a party.

### Patrol Behavior

Configure patrol routes using GameMaker path resources:

```gml
// In party controller Create event
patrol_path = path_gate_patrol;
patrol_speed = 2;
patrol_loop = true;
patrol_aggro_radius = 200;
is_patrolling = true;
party_state = PartyState.patrolling;
```

Party transitions from patrolling to aggressive when player enters `patrol_aggro_radius`.

### Protect Behavior

Configure area defense:

```gml
// In party controller Create event
party_state = PartyState.protecting;
protect_x = x;
protect_y = y;
protect_radius = 150;
```

Party maintains formation near protect point and engages player within radius.

### Save/Load Integration

Party controllers inherit from `obj_persistent_parent`:

```gml
function serialize() {
    return {
        party_id: party_id,
        party_state: party_state,
        formation_center_x: formation_center_x,
        formation_center_y: formation_center_y,
        is_patrolling: is_patrolling,
        x: x, y: y,
        object_type: object_get_name(object_index)
    };
}

function deserialize(_data) {
    party_state = _data.party_state;
    formation_center_x = _data.formation_center_x;
    formation_center_y = _data.formation_center_y;
    is_patrolling = _data.is_patrolling;
}
```

Party members are tracked separately and reconnected on load.

## Creating New Party Controllers

### Example: Creating obj_gate_guard_party

1. **Create object** inheriting from `obj_enemy_party_controller`

2. **Configure in Create_0.gml**:

```gml
event_inherited();

// Defensive patrol setup
party_state = PartyState.patrolling;
formation_template = "line_3";

// Conservative weights
weight_attack = 40;
weight_formation = 70;
weight_flee = 30;

// Thresholds
desperate_threshold = 25;
cautious_threshold = 60;

// Patrol configuration
patrol_path = path_gate_route;
patrol_speed = 1.5;
patrol_loop = true;
patrol_aggro_radius = 180;
is_patrolling = true;

// Spawn party members
var enemies = [
    instance_create_layer(x - 48, y, layer, obj_guard),
    instance_create_layer(x, y, layer, obj_guard),
    instance_create_layer(x + 48, y, layer, obj_guard)
];
init_party(enemies, formation_template);
```

3. **Place in room** - party spawns automatically with members

### Example: Creating obj_orc_raiding_party

```gml
event_inherited();

// Aggressive configuration
party_state = PartyState.aggressive;
formation_template = "wedge_5";

// Aggressive weights
weight_attack = 80;
weight_formation = 40;
weight_flee = 10;

// Thresholds
desperate_threshold = 20;
cautious_threshold = 40;
emboldened_player_hp_threshold = 30;

// Spawn party members
var enemies = [
    instance_create_layer(x, y - 32, layer, obj_orc),
    instance_create_layer(x - 24, y, layer, obj_orc),
    instance_create_layer(x + 24, y, layer, obj_orc),
    instance_create_layer(x - 32, y + 32, layer, obj_orc_archer),
    instance_create_layer(x + 32, y + 32, layer, obj_orc_archer)
];
init_party(enemies, formation_template);
```

## Best Practices

1. **Always call `event_inherited()`** in child Create events
2. **Match formation size** to number of spawned enemies (or use modulo)
3. **Configure weights** to match party personality (aggressive, defensive, etc.)
4. **Use patrol paths** for guards and area defenders
5. **Use protect mode** for boss arenas or objective defense
6. **Test state transitions** by adjusting thresholds
7. **Party state persists** via save/load system

## Future Expansion Ideas

- Reinforcement spawning when party is desperate
- Leader designation (killing leader weakens party)
- Multi-party coordination (alliance system)
- Formation switching mid-combat
- Retreat to specific locations
- Call for help from nearby parties
- Morale system (flee if leader dies)
