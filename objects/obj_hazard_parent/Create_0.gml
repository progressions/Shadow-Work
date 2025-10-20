/// obj_hazard_parent : Create Event
/// Base object for environmental hazards that apply damage/traits

// Inherit from persistent parent
event_inherited();

// ==============================
// DAMAGE CONFIGURATION
// ==============================

/// Damage mode: "none", "continuous", "on_enter"
damage_mode = "none";

/// Damage amount per application
damage_amount = 0;

/// Damage type (uses DamageType enum)
damage_type = DamageType.physical;

/// Seconds between damage ticks (continuous mode only)
damage_interval = 1.0;

/// Seconds of damage immunity after taking damage
damage_immunity_duration = 0.5;

// ==============================
// EFFECT CONFIGURATION
// ==============================

/// Effect type: "trait" or "status"
effect_type = "none";  // "none", "trait", "status"

/// Effect to apply
// For traits: string key like "fire_resistance"
// For status effects: provide trait key like "burning"
effect_to_apply = undefined;

/// Duration in seconds for timed traits (ignored for status effects which have their own duration)
effect_duration = 3.0;

/// Effect mode: "none", "on_enter"
effect_mode = "on_enter";

/// Immunity traits - entities with these traits are immune to this hazard's effects
// Array of trait keys (e.g., ["poison_immunity", "ground_hazard_immunity"])
immunity_traits = [];

// ==============================
// AUDIO CONFIGURATION
// ==============================

/// Looping background sound (e.g., snd_fire_loop)
sfx_loop = undefined;

/// Sound when entity enters hazard
sfx_enter = undefined;

/// Sound when entity exits hazard
sfx_exit = undefined;

/// Sound when damage is applied
sfx_damage = undefined;

// ==============================
// ANIMATION
// ==============================

// Sprite and animation speed can be set in room editor
// Default to no sprite
if (sprite_index == -1) {
    sprite_index = -1; // No default sprite
}

image_speed = 0.2; // Default animation speed
stored_image_speed = image_speed; // Store for pause/unpause
was_paused = false; // Track pause state

// ==============================
// ENTITY TRACKING DATA STRUCTURES
// ==============================

/// List of entity IDs currently inside hazard
entities_inside = ds_list_create();

/// Map of entity ID -> damage immunity timer (seconds remaining)
damage_immunity_map = ds_map_create();

/// Map of entity ID -> effect immunity timer (seconds remaining)
effect_immunity_map = ds_map_create();

/// Seconds of effect immunity after applying effect (prevents spam)
effect_immunity_duration = 3.0;

// ==============================
// INTERNAL TIMERS
// ==============================

/// Internal timer for continuous damage (counts up to damage_interval)
continuous_damage_timer = 0;

// ==============================
// AUDIO INITIALIZATION
// ==============================

/// Start looping SFX if configured
if (sfx_loop != undefined) {
    play_sfx(sfx_loop, 1, false, true); // Play looping
}

// ==============================
// DEPTH SORTING
// ==============================

// Hazards should typically be below entities
depth = 100; // Higher depth = further back

// Serialize/deserialize methods removed during save system rebuild
