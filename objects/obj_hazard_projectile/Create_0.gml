// Hazard projectile configuration
// Set by spawning enemy before projectile is created

// Required: Who created this projectile (for damage attribution)
creator = noone;

// Movement configuration
move_speed = 3;              // Pixels per frame
direction = 0;               // Direction in degrees
image_angle = direction;     // Rotate sprite to match direction

// Travel distance configuration
travel_distance = 128;       // Max distance in pixels before landing
starting_x = x;              // Track spawn position
starting_y = y;
distance_traveled = 0;       // Current distance traveled

// Damage configuration
damage_amount = 2;           // Damage dealt to player on collision
damage_type = DamageType.physical;  // Type of damage (fire, poison, etc.)
attack_category = AttackCategory.ranged;  // For DR calculations

// Hazard spawn configuration
hazard_object = obj_fire;         // Object to spawn at landing point
hazard_spawned = false;           // Track if we've spawned the hazard
hazard_lifetime = -1;             // Hazard duration in seconds (-1 = permanent)

// Explosion configuration (optional blast on landing)
explosion_enabled = false;        // Whether to spawn explosion
explosion_object = obj_explosion; // Explosion object to spawn
explosion_damage = 3;             // Explosion damage amount
explosion_damage_type = DamageType.fire; // Explosion damage type

// Visual configuration
sprite_index = spr_fireball;    // Placeholder sprite
image_index = 0;            // Fireball/projectile frame from items
image_speed = 0;             // No animation
depth = -y;                  // Draw above ground

// Status effects (optional)
status_effects_on_hit = [];  // Status effects to apply on player hit

// ==============================
// RANGE PROFILE CONFIGURATION
// ==============================

// Initialize range profile system
projectile_range_profiles_init();
range_profile_id = RangeProfile.hazard_projectile;
range_profile_id_cached = range_profile_id;
range_profile = projectile_get_range_profile(range_profile_id);
if (range_profile == undefined) {
    range_profile = projectile_create_default_profile();
}
current_damage_multiplier = 1.0;
previous_damage_multiplier = current_damage_multiplier;
max_travel_distance = range_profile.max_distance + range_profile.overshoot_buffer;
