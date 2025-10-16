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

// Auxiliary-Based Damage Reduction
auxiliary_dr_bonus = 2;                   // DR bonus per living auxiliary (default 2 DR per aux)

// ============================================
// THROW ATTACK CONFIGURATION
// ============================================

// Throw Attack Behavior
enable_throw_attack = false;              // Enable throw attack ability (set to true in child)
throw_cooldown = 300;                     // Frames between throws (5 seconds default)
throw_windup_time = 30;                   // Frames for windup animation (0.5 seconds)
throw_speed = 4;                          // Pixels per frame for thrown auxiliary
throw_damage = 3;                         // Damage dealt on hit
throw_damage_type = DamageType.physical;  // Damage type for throw impact
throw_range_min = 64;                     // Minimum distance to player to trigger throw
throw_range_max = 256;                    // Maximum distance to player to trigger throw
throw_return_speed = 3;                   // Speed auxiliary returns to boss

// Throw Attack Sounds (configurable per boss)
throw_sound_start = snd_throw_start;      // Sound when throw begins
throw_sound_flying = snd_throwing;        // Sound during flight (looping)
throw_sound_hit = snd_throw_hit;          // Sound when projectile hits player

// ============================================
// SPIN ATTACK CONFIGURATION
// ============================================

// Spin Attack Behavior
enable_spin_attack = false;               // Enable spin attack ability (set to true in child)
spin_cooldown = 480;                      // Frames between spins (8 seconds default)
spin_windup_time = 45;                    // Frames for windup animation (0.75 seconds)
spin_duration = 180;                      // Frames for full spin (3 seconds)
spin_rotation_speed = 6;                  // Degrees per frame (360 degrees = 60 frames = 1 second)
spin_damage = 4;                          // Damage dealt per auxiliary hit
spin_damage_type = DamageType.physical;   // Damage type for spin attack
spin_range_max = 200;                     // Maximum distance to player to trigger spin

// Spin Attack Sounds (configurable per boss)
spin_sound_start = snd_spin_start;        // Sound when spin begins
spin_sound_spinning = snd_spinning;       // Sound during spin (looping)
spin_sound_end = snd_spin_end;            // Sound when spin ends

// ============================================
// STATE TRACKING
// ============================================

// Auxiliary tracking arrays
auxiliaries = [];                         // Array of auxiliary instance references
chain_data = [];                          // Array of chain state structs

// Enrage state
auxiliaries_alive = auxiliary_count;      // Counter for living auxiliaries
is_enraged = false;                       // Whether boss has entered enrage phase

// Throw attack state
throw_state = "none";                     // "none", "selecting", "winding_up", "throwing"
throw_target_auxiliary = noone;           // Which auxiliary is being thrown
throw_windup_timer = 0;                   // Countdown timer for windup
throw_cooldown_timer = 0;                 // Cooldown timer between throws

// Spin attack state
spin_state = "none";                      // "none", "winding_up", "spinning"
spin_windup_timer = 0;                    // Countdown timer for windup
spin_duration_timer = 0;                  // Duration timer for active spin
spin_cooldown_timer = 0;                  // Cooldown timer between spins
spin_current_angle = 0;                   // Current rotation angle for spin

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

    // Initialize throw state on auxiliary
    _aux.throw_state = "idle";                    // "idle", "being_thrown", "returning"
    _aux.throw_velocity_x = 0;                    // Throw velocity X
    _aux.throw_velocity_y = 0;                    // Throw velocity Y
    _aux.original_collision_damage_enabled = _aux.collision_damage_enabled; // Save original state

    // Initialize spin state on auxiliary
    _aux.spin_state = "idle";                     // "idle", "spinning"
    _aux.spin_orbit_angle = _angle;               // Starting angle for orbital position

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
