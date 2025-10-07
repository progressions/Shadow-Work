// Arrow projectile properties
creator = noone;
damage = 0;

// Attack category for damage reduction calculations
attack_category = AttackCategory.ranged;

// Default projectile properties
damage_type = DamageType.physical;
status_effects_on_hit = [];

// Movement (set by spawning code)
speed = 3;
direction = 0;
image_angle = direction;

// Sprite (placeholder - will use spr_arrow when available)
sprite_index = spr_items;
image_index = 28; // arrow frame from item database
image_speed = 0;

// Set depth to draw above ground but below UI
depth = -y;

// Range profile tracking (updated by spawning code)
projectile_range_profiles_init();
range_profile_id = RangeProfile.generic_arrow;
range_profile_id_cached = range_profile_id;
range_profile = projectile_get_range_profile(range_profile_id);
if (range_profile == undefined) {
    range_profile = projectile_create_default_profile();
}
current_damage_multiplier = 1.0;
previous_damage_multiplier = current_damage_multiplier;
distance_travelled = 0;
max_travel_distance = range_profile.max_distance + range_profile.overshoot_buffer;
spawn_x = x;
spawn_y = y;
weapon_range_stat = 0;
