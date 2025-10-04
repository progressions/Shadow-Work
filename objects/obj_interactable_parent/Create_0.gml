// Interactable Parent - Base object for all interactive objects
// Provides standard interface for interaction manager system

// Interaction properties
interaction_radius = 32;           // Distance within which player can interact
interaction_priority = 50;         // Priority for selection (higher = more important)
interaction_key = "Space";         // Key name for display
interaction_action = "Interact";   // Action text for display

// Base methods - override these in child objects

/// @function can_interact()
/// @description Returns whether this object can currently be interacted with
function can_interact() {
    return true;  // Override in child objects
}

/// @function on_interact()
/// @description Called when player interacts with this object
function on_interact() {
    // Override in child objects
    show_debug_message("Interacted with: " + object_get_name(object_index));
}
