/// Chain Boss Parent - Create Event
// Boss enemy with chained auxiliary minions
event_inherited();

// ============================================
// CHAIN BOSS CONFIGURATION
// ============================================

// Auxiliary Configuration
// Only set defaults if not already configured by child
if (!variable_instance_exists(self, "auxiliary_count")) {
    auxiliary_count = 4;                  // Number of auxiliary enemies (2-5)
}
if (!variable_instance_exists(self, "auxiliary_object")) {
    auxiliary_object = obj_enemy_parent;  // Object type for auxiliaries (override in child)
}
if (!variable_instance_exists(self, "chain_max_length")) {
    chain_max_length = 96;                // Maximum chain length in pixels
}
if (!variable_instance_exists(self, "chain_sprite")) {
    chain_sprite = spr_chain;             // Sprite for chain links (override in child)
}

// Enrage Phase Configuration
enrage_attack_speed_multiplier = 1.5;     // Attack speed increase when enraged (1.5x)
enrage_move_speed_multiplier = 1.3;       // Movement speed increase when enraged (1.3x)
enrage_damage_multiplier = 1.2;           // Damage increase when enraged (1.2x)

// ============================================
// STATE TRACKING
// ============================================

// Auxiliary tracking arrays
auxiliaries = [];                         // Array of auxiliary instance references
chain_data = [];                          // Array of chain state structs

// Enrage state
auxiliaries_alive = auxiliary_count;      // Counter for living auxiliaries
is_enraged = false;                       // Whether boss has entered enrage phase

// ============================================
// SPAWN AUXILIARIES IN CIRCULAR FORMATION
// ============================================

// Calculate spawn positions in circle around boss
var _angle_step = 360 / auxiliary_count;  // Degrees between each auxiliary
var _spawn_radius = chain_max_length * 0.5;  // Spawn at half chain length

// Spawn each auxiliary
for (var i = 0; i < auxiliary_count; i++) {
    var _angle = i * _angle_step;
    var _spawn_x = x + lengthdir_x(_spawn_radius, _angle);
    var _spawn_y = y + lengthdir_y(_spawn_radius, _angle);

    // Create auxiliary at calculated position
    var _aux = instance_create_depth(_spawn_x, _spawn_y, depth, auxiliary_object);

    // Set bidirectional reference: auxiliary → boss
    _aux.chain_boss = self;

    // Add auxiliary to boss's tracking arrays
    array_push(auxiliaries, _aux);

    // Initialize chain state data for this auxiliary
    array_push(chain_data, {
        auxiliary: _aux,           // Reference to auxiliary instance
        tension: 0.5,              // Current tension (0.0 = slack, 1.0 = taut)
        angle: _angle,             // Current angle from boss to auxiliary
        distance: _spawn_radius    // Current distance from boss
    });
}
