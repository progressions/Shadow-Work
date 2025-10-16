/// Explosion Create Event
// Explosion spawned at projectile landing - animates and damages player in radius

// Damage configuration (set by spawner)
damage_amount = 3;                  // Damage dealt to player
damage_type = DamageType.fire;      // Type of damage
creator = noone;                    // Who created this explosion

// Animation configuration
image_speed = 0.5;                  // Animation speed (4 frames total)
image_index = 0;                    // Start at first frame

// Depth
depth = -y - 1;                     // Draw above projectile/hazard

// Track if damage has been applied (only damage once)
has_damaged = false;
