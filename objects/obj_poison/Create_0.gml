/// obj_poison : Create Event
/// Poison hazard configuration - continuous poison damage

// Inherit parent initialization
event_inherited();

// ==============================
// POISON HAZARD CONFIGURATION
// ==============================

// Damage configuration
damage_mode = "continuous";         // Damage while standing in poison
damage_amount = 1;                  // 1 damage per tick
damage_type = DamageType.poison;    // Poison damage type
damage_interval = 0.67;             // Damage every ~0.67 seconds
damage_immunity_duration = 0.67;    // 0.67s immunity between ticks

// Effect configuration
effect_type = "status";                      // Apply status effect
effect_to_apply = StatusEffectType.poisoned; // Poisoned status effect
effect_mode = "on_enter";                    // Apply when entering poison

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
