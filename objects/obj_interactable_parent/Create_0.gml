// Interactable Parent - Base object for all interactive objects
// Provides standard interface for interaction manager system

// Call parent create event (obj_persistent_parent)
event_inherited();

// Interaction properties
interaction_radius = 32;           // Distance within which player can interact
interaction_priority = 50;         // Priority for selection (higher = more important)
interaction_verb = INPUT_VERB.INTERACT;  // Input verb for adaptive icon display
interaction_action = "Interact";   // Action text for display
interaction_prompt = noone;        // Reference to active prompt instance

// Legacy support (deprecated - use interaction_verb instead)
interaction_key = "Space";         // Deprecated: Use interaction_verb for gamepad/keyboard adaptive display

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
