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
// For status effects: StatusEffectType enum like StatusEffectType.burning
effect_to_apply = undefined;

/// Duration in seconds for timed traits (ignored for status effects which have their own duration)
effect_duration = 3.0;

/// Effect mode: "none", "on_enter"
effect_mode = "on_enter";

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

// ==============================
// ENTITY TRACKING DATA STRUCTURES
// ==============================

/// List of entity IDs currently inside hazard
entities_inside = ds_list_create();

/// Map of entity ID -> damage immunity timer (seconds remaining)
damage_immunity_map = ds_map_create();

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

// ==============================
// SERIALIZATION METHODS
// ==============================

/// @function serialize()
/// @description Save hazard configuration for persistence
function serialize() {
    var base_data = {
        object_type: object_get_name(object_index),
        x: x,
        y: y,
        persistent_id: persistent_id,
        damage_mode: damage_mode,
        damage_amount: damage_amount,
        damage_type: damage_type,
        damage_interval: damage_interval,
        damage_immunity_duration: damage_immunity_duration,
        effect_type: effect_type,
        effect_to_apply: effect_to_apply,
        effect_duration: effect_duration,
        effect_mode: effect_mode,
        sprite_index: sprite_index != -1 ? sprite_get_name(sprite_index) : "",
        image_speed: image_speed,
        depth: depth
    };

    // Don't serialize sfx or temporary state (entities_inside, timers)
    return base_data;
}

/// @function deserialize(data)
/// @description Restore hazard from saved data
function deserialize(data) {
    x = data.x;
    y = data.y;
    damage_mode = data.damage_mode;
    damage_amount = data.damage_amount;
    damage_type = data.damage_type;
    damage_interval = data.damage_interval;
    damage_immunity_duration = data.damage_immunity_duration;
    effect_type = data.effect_type;
    effect_to_apply = data.effect_to_apply;
    effect_duration = data.effect_duration;
    effect_mode = data.effect_mode;

    if (data.sprite_index != "") {
        sprite_index = asset_get_index(data.sprite_index);
    }

    image_speed = data.image_speed;
    depth = data.depth;

    // Restart looping SFX if configured
    if (sfx_loop != undefined) {
        play_sfx(sfx_loop, 1, false, true);
    }
}
