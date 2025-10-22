/// @description Party Controller Initialization

// Call parent create event (obj_persistent_parent)
event_inherited();

// Party member tracking
party_members = [];
party_leader = noone;
initial_party_size = 0;
decision_update_index = 0;  // Tracks which party member updates next (for staggered updates)
can_spawn_enemies = true;     // Set to false after spawning enemies (spawn once only)

// Formation properties
formation_template = "";
formation_data = {};

// Protection properties (for protecting state)
protect_x = 0;
protect_y = 0;
protect_radius = 200;

// Patrol properties (for patrolling state)
patrol_path = -1;           // GameMaker path resource (e.g., path_guard_route)
patrol_speed = 1.0;         // Speed along the path
patrol_loop = true;         // Loop the path or reverse at ends
patrol_position = 0;        // Current position along path (0 to 1)
patrol_aggro_radius = 200;  // How far from path enemies will chase player
patrol_return_radius = 300; // How far player must be before returning to patrol
patrol_home_x = 0;          // Original patrol starting position
patrol_home_y = 0;
patrol_original_state = PartyState.patrolling; // Remember original patrol/protect state

// Party state
party_state = PartyState.aggressive;

// State transition thresholds
desperate_threshold = 0.2;      // Enter desperate state when <= 20% party survives
cautious_threshold = 0.5;       // Enter cautious state when <= 50% party survives
emboldened_player_hp_threshold = 0.3;  // Enter emboldened when player HP <= 30%

// Decision weights (base values)
weight_attack = 1.0;
weight_formation = 0.8;
weight_flee = 0.3;
weight_patrol = 3.0;  // Base weight for continuing patrol/protect behavior

// Weight modifiers (multipliers applied based on conditions)
weight_modifiers = {
    low_party_survival: 3.0,    // Multiplier when party survival < 30%
    low_player_hp: 2.0,         // Multiplier when player HP < 30%
    low_self_hp: 2.5,           // Multiplier when enemy HP < 20%
    isolated: 1.5,              // Multiplier when far from formation
    player_in_aggro_range: 5.0  // Multiplier to attack weight when player in aggro radius
};

/// @function init_party(_spawn_data_array, _formation_template_key)
/// @description Initialize party by spawning enemies from spawn data
/// @param {array} _spawn_data_array - Array of spawn structs with {x, y, type} properties
/// @param {string} _formation_template_key - Key to formation in global.formation_database
function init_party(_spawn_data_array, _formation_template_key) {
    // Skip if already initialized or loading from save
    if (!can_spawn_enemies || (variable_global_exists("loading_from_save") && global.loading_from_save)) {
        show_debug_message("init_party: Skipping spawn (can_spawn_enemies=" + string(can_spawn_enemies) + ", loading=" + string(variable_global_exists("loading_from_save") && global.loading_from_save) + ")");
        return;
    }

    show_debug_message("init_party: Spawning " + string(array_length(_spawn_data_array)) + " enemies");

    formation_template = _formation_template_key;
    party_members = [];

    // Create enemies from spawn data
    for (var i = 0; i < array_length(_spawn_data_array); i++) {
        var _spawn_data = _spawn_data_array[i];

        // Create enemy instance
        var _enemy = instance_create_layer(_spawn_data.x, _spawn_data.y, layer, _spawn_data.type);

        // Add to party
        array_push(party_members, _enemy);

        // Set party controller reference
        if (instance_exists(_enemy)) {
            _enemy.party_controller = id;
        }
    }

    initial_party_size = array_length(party_members);

    // Assign formation roles and positions
    assign_formation_roles();

    // Mark as spawned (never spawn again)
    can_spawn_enemies = false;

    show_debug_message("init_party: Successfully spawned and initialized " + string(initial_party_size) + " party members");
}

/// @function assign_formation_roles()
/// @description Assign roles and formation positions to party members
function assign_formation_roles() {
    if (!is_struct(global.formation_database) || !variable_struct_exists(global.formation_database, formation_template)) {
        show_debug_message("Warning: Formation template '" + formation_template + "' not found in database");
        return;
    }

    var _template = global.formation_database[$ formation_template];
    var _party_size = array_length(party_members);

    // Initialize formation data
    formation_data = {
        template_name: formation_template,
        assignments: []
    };

    // Assign roles and offsets to each party member
    for (var i = 0; i < _party_size; i++) {
        var _enemy = party_members[i];
        if (!instance_exists(_enemy)) continue;

        // Handle procedural adjustments if party size doesn't match template
        var _role_index = i;
        var _offset_index = i;

        // If party size exceeds template, wrap around (duplicate pattern)
        if (i >= _template.max_members) {
            _role_index = i mod _template.max_members;
            _offset_index = i mod _template.max_members;
        }

        // Create assignment struct
        var _assignment = {
            enemy: _enemy,
            role: _template.roles[_role_index],
            offset: _template.offsets[_offset_index],
            is_leader: (i == 0) // First enemy is leader by default
        };

        array_push(formation_data.assignments, _assignment);

        // Assign formation role for dual-mode combat based on Y-offset
        var _y_offset = _template.offsets[_offset_index].y;
        if (_y_offset < -16) {
            _enemy.formation_role = "rear";      // Negative Y = rear formation (ranged preference)
        } else if (_y_offset > 16) {
            _enemy.formation_role = "front";     // Positive Y = front formation (melee preference)
        } else {
            _enemy.formation_role = "support";   // Near zero = support (flexible)
        }

        // Set leader reference
        if (i == 0) {
            party_leader = _enemy;
        }
    }
}

/// @function get_formation_position(_enemy)
/// @description Calculate target formation coordinates for an enemy
/// @param {Id.Instance} _enemy - The enemy to get formation position for
/// @return {struct} Struct with x and y coordinates, or undefined if enemy not in party
function get_formation_position(_enemy) {
    if (!is_struct(formation_data) || !variable_struct_exists(formation_data, "assignments") || !is_array(formation_data.assignments)) {
        return undefined;
    }

    // Find enemy in formation assignments
    for (var i = 0; i < array_length(formation_data.assignments); i++) {
        var _assignment = formation_data.assignments[i];
        if (_assignment.enemy == _enemy) {
            // Calculate formation position relative to controller position
            // In protecting mode, use protect_x/y as anchor
            // In other modes, use controller position (which can follow player)
            var _anchor_x = (party_state == PartyState.protecting) ? protect_x : x;
            var _anchor_y = (party_state == PartyState.protecting) ? protect_y : y;

            return {
                x: _anchor_x + _assignment.offset.x,
                y: _anchor_y + _assignment.offset.y
            };
        }
    }

    return undefined;
}

/// @function get_party_survival_percentage()
/// @description Calculate what percentage of the party is still alive
/// @return {real} Percentage from 0.0 to 1.0
function get_party_survival_percentage() {
    if (initial_party_size == 0) return 0;

    var _alive_count = 0;
    for (var i = 0; i < array_length(party_members); i++) {
        var _enemy = party_members[i];
        if (instance_exists(_enemy) && _enemy.hp > 0) {
            _alive_count++;
        }
    }

    return _alive_count / initial_party_size;
}

/// @function evaluate_patrol_decision()
/// @description Determine if party should continue patrol or engage player
/// @return {string} "patrol" or "engage"
function evaluate_patrol_decision() {
    // Only relevant for patrol/protect states
    if (patrol_original_state != PartyState.patrolling && patrol_original_state != PartyState.protecting) {
        return "engage";
    }

    if (!instance_exists(obj_player)) {
        return "patrol";
    }

    // Ensure weight_modifiers exists (important during initialization)
    if (!variable_instance_exists(id, "weight_modifiers")) {
        weight_modifiers = {
            low_party_survival: 3.0,
            low_player_hp: 2.0,
            low_self_hp: 2.5,
            isolated: 1.5,
            player_in_aggro_range: 5.0
        };
    }

    // Calculate distance to player
    var _dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);

    // Base weights
    var _w_patrol = weight_patrol;
    var _w_engage = weight_attack;

    // Modify engage weight based on player proximity
    if (_dist_to_player <= patrol_aggro_radius) {
        _w_engage *= weight_modifiers.player_in_aggro_range;
    }

    // Modify engage weight based on player HP
    var _player_hp_pct = obj_player.hp / obj_player.hp_total;
    if (_player_hp_pct < 0.3) {
        _w_engage *= weight_modifiers.low_player_hp;
    }

    // Modify patrol weight based on distance from home
    if (party_state != patrol_original_state) {
        // Already engaged - reduce patrol weight
        _w_patrol *= 0.5;

        // If player is far away, increase patrol weight (return home)
        if (_dist_to_player >= patrol_return_radius) {
            _w_patrol *= 3.0;
        }
    }

    // Choose highest weighted objective
    var _decision = (_w_engage > _w_patrol) ? "engage" : "patrol";

    return _decision;
}

/// @function update_party_state()
/// @description Evaluate conditions and transition party state
function update_party_state() {
    var _survival = get_party_survival_percentage();

    // Don't auto-transition if in original patrol/protect state
    if (party_state == patrol_original_state) {
        return;
    }

    // Get player HP percentage if player exists
    var _player_hp_pct = 1.0;
    if (instance_exists(obj_player)) {
        _player_hp_pct = obj_player.hp / obj_player.hp_total;
    }

    // Determine new state based on conditions
    var _new_state = party_state;

    // Desperate - low survival (highest priority)
    if (_survival <= desperate_threshold) {
        _new_state = PartyState.desperate;
    }
    // Emboldened - player is weak
    else if (_player_hp_pct <= emboldened_player_hp_threshold) {
        _new_state = PartyState.emboldened;
    }
    // Cautious - medium survival
    else if (_survival <= cautious_threshold) {
        _new_state = PartyState.cautious;
    }
    // Default to aggressive if conditions not met
    else {
        _new_state = PartyState.aggressive;
    }

    // Transition to new state if different
    if (_new_state != party_state) {
        transition_to_state(_new_state);
    }
}

/// @function transition_to_state(_new_state)
/// @description Handle state transition with audio feedback
/// @param {real} _new_state - The state to transition to
function transition_to_state(_new_state) {
    if (party_state == _new_state) return;

    var _old_state = party_state;
    party_state = _new_state;

    // Play audio cue based on new state
    switch (_new_state) {
        case PartyState.aggressive:
        case PartyState.emboldened:
            play_sfx(snd_party_aggressive);
            break;

        case PartyState.cautious:
            play_sfx(snd_party_cautious);
            break;

        case PartyState.desperate:
            play_sfx(snd_party_desperate);
            break;

        case PartyState.retreating:
            play_sfx(snd_party_retreating);
            break;

        case PartyState.patrolling:
            play_sfx(snd_party_patrolling);
            break;

        case PartyState.protecting:
            play_sfx(snd_party_protecting);
            break;
    }
}

/// @function calculate_decision_weights(_enemy)
/// @description Calculate weighted objectives for individual enemy
/// @param {Id.Instance} _enemy - The enemy to calculate weights for
function calculate_decision_weights(_enemy) {
    if (!instance_exists(_enemy)) return;
    if (!instance_exists(obj_player)) return;

    // Ensure weight_modifiers exists (important during initialization)
    if (!variable_instance_exists(id, "weight_modifiers")) {
        weight_modifiers = {
            low_party_survival: 3.0,
            low_player_hp: 2.0,
            low_self_hp: 2.5,
            isolated: 1.5,
            player_in_aggro_range: 5.0
        };
    }

    // Get formation position
    var _form_pos = get_formation_position(_enemy);
    if (is_struct(_form_pos) && _form_pos != undefined) {
        _enemy.formation_target_x = _form_pos.x;
        _enemy.formation_target_y = _form_pos.y;
    }

    // Calculate flee target (away from player toward map edge)
    var _flee_dir = point_direction(obj_player.x, obj_player.y, _enemy.x, _enemy.y);
    _enemy.flee_target_x = _enemy.x + lengthdir_x(200, _flee_dir);
    _enemy.flee_target_y = _enemy.y + lengthdir_y(200, _flee_dir);

    // Base weights from party controller
    var _w_attack = weight_attack;
    var _w_formation = weight_formation;
    var _w_flee = weight_flee;

    // --- STATE-BASED BEHAVIORAL MODIFIERS ---
    // Modify weights based on party state (morale, tactics, etc.)
    switch (party_state) {
        case PartyState.cautious:
            // Morale broken - become defensive
            _w_flee *= 2.5;        // Much more likely to flee or keep distance
            _w_attack *= 0.4;      // Much less aggressive
            _w_formation *= 1.8;   // Prioritize staying together
            break;

        case PartyState.desperate:
            // Nearly wiped out - survival mode
            _w_flee *= 4.0;        // Extremely high flee priority
            _w_attack *= 0.2;      // Barely attack
            _w_formation *= 0.5;   // Formation less important than survival
            break;

        case PartyState.emboldened:
            // Player is weak - press the advantage
            _w_attack *= 2.0;      // Very aggressive
            _w_flee *= 0.3;        // Rarely flee
            _w_formation *= 0.7;   // Formation less important than killing
            break;

        case PartyState.aggressive:
            // Normal aggressive behavior (no modifiers needed)
            break;

        case PartyState.retreating:
            // Ordered retreat
            _w_flee *= 5.0;        // Maximum flee priority
            _w_attack *= 0.1;      // Almost never attack
            _w_formation *= 1.5;   // Maintain formation while retreating
            break;
    }

    // Calculate condition percentages
    var _party_survival = get_party_survival_percentage();
    var _player_hp_pct = obj_player.hp / obj_player.hp_total;
    var _my_hp_pct = _enemy.hp / _enemy.hp_total;
    var _distance_from_formation = _form_pos != undefined ?
        point_distance(_enemy.x, _enemy.y, _form_pos.x, _form_pos.y) : 0;

    // Apply modifiers based on conditions

    // Low party survival increases flee weight
    if (_party_survival < 0.3) {
        _w_flee *= weight_modifiers.low_party_survival;
    }

    // Low player HP increases attack weight
    if (_player_hp_pct < 0.3) {
        _w_attack *= weight_modifiers.low_player_hp;
    }

    // Low personal HP increases flee weight
    if (_my_hp_pct < 0.2) {
        _w_flee *= weight_modifiers.low_self_hp;
    }

    // Far from formation increases formation weight
    if (_distance_from_formation > 100) {
        _w_formation *= weight_modifiers.isolated;
    }

    // Choose highest weighted objective
    var _max_weight = max(_w_attack, _w_formation, _w_flee);

    if (_max_weight == _w_flee) {
        _enemy.current_objective = "flee";
        _enemy.objective_target_x = _enemy.flee_target_x;
        _enemy.objective_target_y = _enemy.flee_target_y;
    } else if (_max_weight == _w_formation) {
        _enemy.current_objective = "formation";
        _enemy.objective_target_x = _enemy.formation_target_x;
        _enemy.objective_target_y = _enemy.formation_target_y;
    } else {
        _enemy.current_objective = "attack";
        _enemy.objective_target_x = obj_player.x;
        _enemy.objective_target_y = obj_player.y;
    }
}

/// @function on_member_death(_enemy)
/// @description Handle party member removal and formation adjustment
/// @param {Id.Instance} _enemy - The enemy that died
function on_member_death(_enemy) {
    if (!instance_exists(_enemy)) return;

    // Check if leader died
    var _was_leader = (party_leader == _enemy);

    // Remove enemy from party_members array
    for (var i = 0; i < array_length(party_members); i++) {
        if (party_members[i] == _enemy) {
            array_delete(party_members, i, 1);
            break;
        }
    }

    // If leader died, call virtual function and assign new leader
    if (_was_leader) {
        party_leader = noone;
        on_leader_death();

        // Assign new leader (first remaining member)
        if (array_length(party_members) > 0) {
            party_leader = party_members[0];
        }
    }

    // Reassign formation roles to remaining members
    if (array_length(party_members) > 0) {
        assign_formation_roles();
    }
}

/// @function on_leader_death()
/// @description Virtual function called when party leader dies - override in child controllers
function on_leader_death() {
    // Default behavior: do nothing
    // Child controllers can override this for custom behavior
    // Example: party becomes cautious, flees, or gets enraged
}

// Serialize/deserialize methods removed during save system rebuild
function serialize() {
    // Convert party_members instance array to persistent_id array
    var _member_ids = [];
    for (var i = 0; i < array_length(party_members); i++) {
        var _member = party_members[i];
        if (instance_exists(_member)) {
            array_push(_member_ids, _member.persistent_id);
        }
    }

    var _struct = {
        // Base persistent_parent fields
        object_type: object_get_name(object_index),
        persistent_id: persistent_id,
        x: x,
        y: y,
        room_name: room_get_name(room),
        sprite_index: sprite_get_name(sprite_index),
        image_index: image_index,
        image_xscale: image_xscale,
        image_yscale: image_yscale,

        // Party controller-specific fields
        party_member_ids: _member_ids,  // Array of persistent_ids
        party_state: party_state,
        formation_template: formation_template,
        initial_party_size: initial_party_size,
        can_spawn_enemies: false,  // Always false when serialized - never spawn on load

        // Protection properties
        protect_x: protect_x,
        protect_y: protect_y,
        protect_radius: protect_radius,

        // Patrol properties
        patrol_path_name: (patrol_path != -1) ? path_get_name(patrol_path) : "",
        patrol_speed: patrol_speed,
        patrol_loop: patrol_loop,
        patrol_position: patrol_position,
        patrol_aggro_radius: patrol_aggro_radius,
        patrol_return_radius: patrol_return_radius,
        patrol_home_x: patrol_home_x,
        patrol_home_y: patrol_home_y,
        patrol_original_state: patrol_original_state,

        // Decision weights
        weight_attack: weight_attack,
        weight_formation: weight_formation,
        weight_flee: weight_flee,
        weight_patrol: weight_patrol
    };

    return _struct;
}
