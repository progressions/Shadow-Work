/// obj_curse : Create Event
/// Curse hazard configuration - applies unholy-damage DoT

// Inherit parent initialization
event_inherited();

// ==============================
// CURSE HAZARD CONFIGURATION
// ==============================

// Curse hazard applies a DoT similar to burning but themed as unholy damage
damage_mode = "none";              // No direct damage ticks
damage_amount = 0;
damage_type = DamageType.unholy;
damage_interval = 1;
damage_immunity_duration = 1;

effect_type = "status";
effect_to_apply = "cursed";
effect_duration = -1;                // Use trait default duration
effect_mode = "on_enter";

// Immunity - entities with these traits are immune to curse
immunity_traits = ["unholy_immunity", "ground_hazard_immunity"];

// Visual/Animation
image_speed = 0.2;                  // Animation speed (slower than fire)

// Audio configuration (optional - uncomment and set sounds)
// sfx_loop = snd_poison_loop;        // Looping bubbling/hissing sound
// sfx_enter = snd_poison_enter;      // Sound when entering poison
// sfx_damage = snd_poison_damage;    // Sound when taking poison damage
// sfx_exit = snd_poison_exit;        // Sound when leaving poison

// Depth
depth = 100; // Behind entities
