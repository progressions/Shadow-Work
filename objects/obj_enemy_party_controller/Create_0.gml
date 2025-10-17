/// @description Party Controller Initialization

// Party member tracking
party_members = [];
party_leader = noone;
initial_party_size = 0;
decision_update_index = 0;  // Tracks which party member updates next (for staggered updates)

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

/// @function init_party(enemy_array, formation_template_key)
/// @description Initialize party with enemies and formation template
/// @param {array} enemy_array - Array of enemy instances to add to party
/// @param {string} formation_template_key - Key to formation in global.formation_database
function init_party(_enemy_array, _formation_template_key) {
    party_members = _enemy_array;
    initial_party_size = array_length(_enemy_array);
    formation_template = _formation_template_key;

    // Set party controller reference on each enemy
    for (var i = 0; i < array_length(party_members); i++) {
        var _enemy = party_members[i];
        if (instance_exists(_enemy)) {
            _enemy.party_controller = id;
        }
    }

    // Assign formation roles and positions
    assign_formation_roles();
}

/// @function assign_formation_roles()
/// @description Assign roles and formation positions to party members
function assign_formation_roles() {
    if (!variable_struct_exists(global.formation_database, formation_template)) {
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

/// @function get_formation_position(enemy_instance)
/// @description Calculate target formation coordinates for an enemy
/// @param {Id.Instance} enemy_instance - The enemy to get formation position for
/// @return {struct} Struct with x and y coordinates, or undefined if enemy not in party
function get_formation_position(_enemy) {
    if (!variable_struct_exists(formation_data, "assignments")) {
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

    // Debug output - TEMPORARILY ENABLED FOR CANOPY THREAT DEBUG
    if (object_index == obj_canopy_threat) {
        show_debug_message("Party Decision: " + _decision +
                         " (engage=" + string(_w_engage) +
                         ", patrol=" + string(_w_patrol) +
                         ", dist=" + string(_dist_to_player) +
                         ", aggro_radius=" + string(patrol_aggro_radius) + ")");
    }

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

/// @function transition_to_state(new_state)
/// @description Handle state transition with audio feedback
/// @param {real} new_state - The state to transition to
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

/// @function calculate_decision_weights(enemy_instance)
/// @description Calculate weighted objectives for individual enemy
/// @param {Id.Instance} enemy_instance - The enemy to calculate weights for
function calculate_decision_weights(_enemy) {
    if (!instance_exists(_enemy)) return;
    if (!instance_exists(obj_player)) return;

    // Get formation position
    var _form_pos = get_formation_position(_enemy);
    if (_form_pos != undefined) {
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

/// @function on_member_death(enemy_instance)
/// @description Handle party member removal and formation adjustment
/// @param {Id.Instance} enemy_instance - The enemy that died
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

/// @function serialize_party_data()
/// @description Return struct for save system
/// @return {struct} Save data for this party controller
function serialize_party_data() {
    // Collect member IDs (using persistent_id from enemy serialize)
    var _member_ids = [];
    for (var i = 0; i < array_length(party_members); i++) {
        var _enemy = party_members[i];
        if (instance_exists(_enemy)) {
            var _id = object_get_name(_enemy.object_index) + "_" + string(_enemy.x) + "_" + string(_enemy.y);
            array_push(_member_ids, _id);
        }
    }

    // Get leader ID
    var _leader_id = "";
    if (instance_exists(party_leader)) {
        _leader_id = object_get_name(party_leader.object_index) + "_" + string(party_leader.x) + "_" + string(party_leader.y);
    }

    return {
        party_id: "party_" + string(id),
        party_state: party_state,
        initial_party_size: initial_party_size,
        formation_template: formation_template,
        protect_x: protect_x,
        protect_y: protect_y,
        protect_radius: protect_radius,
        member_ids: _member_ids,
        leader_id: _leader_id,
        weight_attack: weight_attack,
        weight_formation: weight_formation,
        weight_flee: weight_flee,
        weight_modifiers: {
            low_party_survival: weight_modifiers.low_party_survival,
            low_player_hp: weight_modifiers.low_player_hp,
            low_self_hp: weight_modifiers.low_self_hp,
            isolated: weight_modifiers.isolated
        },
        desperate_threshold: desperate_threshold,
        cautious_threshold: cautious_threshold,
        emboldened_player_hp_threshold: emboldened_player_hp_threshold,
        controller_x: x,
        controller_y: y
    };
}

/// @function deserialize_party_data(data, enemy_lookup)
/// @description Restore party from saved data
/// @param {struct} data - Saved party data
/// @param {struct} enemy_lookup - Map of persistent_id to enemy instances
function deserialize_party_data(_data, _enemy_lookup) {
    party_state = _data.party_state;
    initial_party_size = _data.initial_party_size;
    formation_template = _data.formation_template;
    protect_x = _data.protect_x;
    protect_y = _data.protect_y;
    protect_radius = _data.protect_radius;
    weight_attack = _data.weight_attack;
    weight_formation = _data.weight_formation;
    weight_flee = _data.weight_flee;

    weight_modifiers = {
        low_party_survival: _data.weight_modifiers.low_party_survival,
        low_player_hp: _data.weight_modifiers.low_player_hp,
        low_self_hp: _data.weight_modifiers.low_self_hp,
        isolated: _data.weight_modifiers.isolated
    };

    desperate_threshold = _data.desperate_threshold;
    cautious_threshold = _data.cautious_threshold;
    emboldened_player_hp_threshold = _data.emboldened_player_hp_threshold;

    x = _data.controller_x;
    y = _data.controller_y;

    // Reconnect party members using enemy lookup
    party_members = [];
    for (var i = 0; i < array_length(_data.member_ids); i++) {
        var _member_id = _data.member_ids[i];
        if (variable_struct_exists(_enemy_lookup, _member_id)) {
            var _enemy = _enemy_lookup[$ _member_id];
            if (instance_exists(_enemy)) {
                array_push(party_members, _enemy);
                _enemy.party_controller = id;
            }
        }
    }

    // Reconnect leader
    party_leader = noone;
    if (_data.leader_id != "" && variable_struct_exists(_enemy_lookup, _data.leader_id)) {
        var _leader = _enemy_lookup[$ _data.leader_id];
        if (instance_exists(_leader)) {
            party_leader = _leader;
        }
    }

    // Reassign formation roles
    if (array_length(party_members) > 0) {
        assign_formation_roles();
    }
}
