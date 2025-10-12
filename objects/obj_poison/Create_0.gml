/// obj_poison : Create Event
/// Poison hazard configuration - continuous poison damage

// Inherit parent initialization
event_inherited();

// ==============================
// POISON HAZARD CONFIGURATION
// ==============================

// Poison hazard applies a DoT identical to burning but themed as poison
damage_mode = "none";              // No direct damage ticks
damage_amount = 0;
damage_type = DamageType.poison;
damage_interval = 1;
damage_immunity_duration = 1;

effect_type = "status";
effect_to_apply = "poisoned";
effect_duration = -1;                // Use trait default duration
effect_mode = "on_enter";

// Immunity - entities with these traits are immune to poison
immunity_traits = ["poison_immunity", "ground_hazard_immunity"];

// Visual/Animation
sprite_index = spr_poison_pool;     // Poison pool animation
image_speed = 0.2;                  // Animation speed (slower than fire)

// Audio configuration (optional - uncomment and set sounds)
// sfx_loop = snd_poison_loop;        // Looping bubbling/hissing sound
// sfx_enter = snd_poison_enter;      // Sound when entering poison
// sfx_damage = snd_poison_damage;    // Sound when taking poison damage
// sfx_exit = snd_poison_exit;        // Sound when leaving poison

// Depth
depth = 100; // Behind entities
