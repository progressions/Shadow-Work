/// @description Canopy Guard Party - Protecting Configuration

// Call parent create event
event_inherited();

// Patrolling state configuration (small circle around Canopy to keep them in place)
party_state = PartyState.patrolling;
patrol_original_state = PartyState.patrolling;
formation_template = "protective_3"; // Triangle formation around Canopy

// Canopy's position in room_level_1
protect_x = 650;
protect_y = 450;

// Patrol configuration - TIGHT circle around Canopy (engage when player is close)
patrol_path = path_canopy_guard_idle;  // Small circle around Canopy
patrol_speed = 0.1;        // Very slow "patrol" speed - barely moves
patrol_loop = true;        // Loop continuously
patrol_aggro_radius = 80;  // Engage when player within 80px of Canopy
patrol_return_radius = 120; // Return to patrol when player is 120px away

// Weight configuration - Stay on patrol until player gets very close
weight_attack = 1.0;       // Base attack weight
weight_formation = 2.0;    // High formation priority
weight_flee = 0.2;         // Low flee
weight_patrol = 5.0;       // Strong patrol priority (but not overwhelming)

// Guard behavior modifiers - Engage when player is in aggro radius
weight_modifiers.low_party_survival = 1.5;     // Some panic when reduced
weight_modifiers.low_player_hp = 1.5;          // Moderate aggression when player is weak
weight_modifiers.low_self_hp = 2.0;            // Return to formation when hurt
weight_modifiers.isolated = 3.0;               // Strongly drawn back to formation
weight_modifiers.player_in_aggro_range = 50.0; // BIG boost when player enters aggro radius

// Defensive thresholds
desperate_threshold = 0.2;   // Stay defensive even when low
cautious_threshold = 0.5;    // Become cautious at half strength
emboldened_player_hp_threshold = 0.25;  // Moderate emboldening

// Auto-spawn 3 greenwood bandits around Canopy
var enemies = [
    instance_create_layer(protect_x - 48, protect_y, layer, obj_greenwood_bandit),      // Left
    instance_create_layer(protect_x + 48, protect_y, layer, obj_greenwood_bandit),      // Right
    instance_create_layer(protect_x, protect_y - 48, layer, obj_greenwood_bandit)       // Front
];

// Party system will handle keeping them on patrol via patrol_aggro_radius
// No special configuration needed - they're just normal enemies in a patrolling party

// Initialize the party
init_party(enemies, formation_template);

show_debug_message("=== CANOPY THREAT PARTY CREATED ===");
show_debug_message("Position: (" + string(x) + ", " + string(y) + ")");
show_debug_message("Patrol path exists: " + string(path_exists(patrol_path)));
show_debug_message("Party members: " + string(array_length(party_members)));
show_debug_message("patrol_original_state: " + string(patrol_original_state));
show_debug_message("patrol_aggro_radius: " + string(patrol_aggro_radius));
