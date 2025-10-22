/// @description Defensive Gate Guard Party Configuration

// Call parent create event
event_inherited();

// Configure for patrol behavior (can also use protecting state)
party_state = PartyState.patrolling;  // or PartyState.protecting
patrol_original_state = PartyState.patrolling; // Remember the original state
formation_template = "line_3";

// Patrol configuration (for patrolling state)
// Assign the patrol path here (must create path in GameMaker first)
patrol_path = path_castle_patrol;          // Set to your path resource (e.g., path_gate_patrol)
patrol_speed = 0.5;           // Slow patrol speed
patrol_loop = true;           // Loop continuously
patrol_aggro_radius = 150;    // Chase player within 150px of path
patrol_return_radius = 250;   // Return to patrol when player is 250px away

// Protective position (for protecting state - alternative to patrolling)
protect_x = x;
protect_y = y;
protect_radius = 150;

// Defensive weight configuration - prioritize formation
weight_attack = 0.8;      // Moderate attack weight
weight_formation = 2.0;   // Very high formation priority
weight_flee = 0.1;        // Almost never flee
weight_patrol = 2.5;      // Moderate patrol priority (lower than default 3.0)

// Defensive modifiers
weight_modifiers.low_party_survival = 1.5;  // Less panic when reduced
weight_modifiers.low_player_hp = 1.5;       // Don't overcommit to attack
weight_modifiers.low_self_hp = 2.0;         // Return to formation when hurt
weight_modifiers.isolated = 3.0;            // Strongly drawn back to formation

// Defensive thresholds
desperate_threshold = 0.15;  // Hold the line even when almost dead
cautious_threshold = 0.4;    // Become cautious earlier
emboldened_player_hp_threshold = 0.2;  // Less easily emboldened

// Override leader death - guards hold position
function on_leader_death() {
    // Guards maintain discipline when leader falls
    weight_formation *= 1.5;  // Even more focused on formation
    show_debug_message("Gate Guard Party: Leader fallen! Hold the line!");
}

// Define spawn data for party members
var spawn_data = [
    { x: x - 48, y: y, type: obj_burglar },  // Left guard
    { x: x, y: y, type: obj_burglar },       // Center guard
    { x: x + 48, y: y, type: obj_burglar }   // Right guard
];

// Initialize the party (handles spawning and setup)
init_party(spawn_data, formation_template);
