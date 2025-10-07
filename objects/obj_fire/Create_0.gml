/// obj_fire : Create Event
/// Fire hazard configuration - continuous burning damage

// Inherit parent initialization
event_inherited();

// ==============================
// FIRE HAZARD CONFIGURATION
// ==============================

// Damage configuration
damage_mode = "continuous";         // Damage while standing on fire
damage_amount = 0;                  // 2 damage per tick
damage_type = DamageType.fire;      // Fire damage type
damage_interval = 0.5;              // Damage every 0.5 seconds
damage_immunity_duration = 0.5;     // 0.5s immunity between ticks

// Effect configuration
effect_type = "status";                      // Apply status effect
effect_to_apply = "burning";  // Burning trait effect
effect_mode = "on_enter";                    // Apply when entering fire

// Visual/Animation
sprite_index = spr_fire;            // 4-frame fire animation
image_speed = 0.3;                  // Animation speed

// Audio configuration (optional - uncomment and set sounds)
// sfx_loop = snd_fire_loop;        // Looping fire crackling sound
// sfx_enter = snd_fire_enter;      // Sound when entering fire
// sfx_damage = snd_fire_damage;    // Sound when taking fire damage
// sfx_exit = snd_fire_exit;        // Sound when leaving fire

// Depth
depth = 100; // Behind entities
