/// @description Aggressive Orc Raiding Party Configuration

// Call parent create event
event_inherited();

// Configure for aggressive raiding behavior
party_state = PartyState.aggressive;
formation_template = "wedge_5";

// Aggressive weight configuration - prioritize attacking
weight_attack = 2.0;      // Very high attack weight
weight_formation = 0.5;   // Low formation priority
weight_flee = 0.2;        // Very low flee weight

// More aggressive modifiers
weight_modifiers.low_party_survival = 2.0;  // Less likely to flee even when weakened
weight_modifiers.low_player_hp = 3.0;       // Very aggressive when player is weak
weight_modifiers.low_self_hp = 1.5;         // Less likely to flee when hurt
weight_modifiers.isolated = 1.2;            // Don't care much about formation

// Aggressive thresholds
desperate_threshold = 0.1;  // Only desperate when almost all dead
cautious_threshold = 0.3;   // Stay aggressive longer
emboldened_player_hp_threshold = 0.4;  // Emboldened more easily

// Override leader death to make party more aggressive
function on_leader_death() {
    // Orcs become enraged when leader dies
    weight_attack *= 1.5;
    weight_flee *= 0.5;
    show_debug_message("Orc Raiding Party: Leader slain! Party enraged!");
}

// Auto-spawn party members in wedge formation
var enemies = [
    instance_create_layer(x, y - 48, layer, obj_orc),         // Front (leader)
    instance_create_layer(x - 32, y - 16, layer, obj_burglar),    // Left flank
    instance_create_layer(x + 32, y - 16, layer, obj_burglar),    // Right flank
    instance_create_layer(x - 48, y + 16, layer, obj_burglar),    // Left rear
    instance_create_layer(x + 48, y + 16, layer, obj_burglar)     // Right rear
];

// Initialize the party
init_party(enemies, formation_template);
