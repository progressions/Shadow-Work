// Interaction Manager - Singleton that manages all interactive object selection
// Ensures only one object responds to player input at a time

// Make sure we're the only instance (singleton pattern)
if (instance_number(obj_interaction_manager) > 1) {
    instance_destroy();
    exit;
}

// Initialize global variable for currently selected interactive object
global.active_interactive = noone;

// Maximum distance to search for interactive objects
max_query_radius = 64;

depth = -9999;  // Run before other objects
