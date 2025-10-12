// Inherit the parent event
event_inherited();

// Bat-specific stats (fast flyer, low hp, hit-and-run tactics)
attack_damage = 3;
attack_speed = 1.0;
attack_range = 20;
hp = 4;
hp_total = hp;
move_speed = 1.2;  // Fast flying movement

// Flying trait - grants immunity to ground-based hazards (lava, poison pools, etc.)
array_push(tags, "flying");
apply_tag_traits();

// Assign kiting swooper movement profile
movement_profile = global.movement_profile_database.kiting_swooper;
movement_profile_state = "kiting";  // Start in kiting state

// Initialize movement profile variables
movement_profile_anchor_x = x;  // Remember spawn position
movement_profile_anchor_y = y;
movement_profile_erratic_timer = 0;  // Will pick position immediately
movement_profile_swoop_cooldown = movement_profile.parameters.swoop_cooldown;

// Add variation to kite distance to prevent clustering
// This spreads bats out at different distances (±20 pixels from ideal)
var _distance_variation = irandom_range(-20, 20);
movement_profile_custom_params = {
    kite_min_distance: movement_profile.parameters.kite_min_distance + _distance_variation,
    kite_max_distance: movement_profile.parameters.kite_max_distance + _distance_variation,
    kite_ideal_distance: movement_profile.parameters.kite_ideal_distance + _distance_variation
};

// Bat sounds (using generic sounds for now)
// enemy_sounds.on_melee_attack = snd_bat_attack;
// enemy_sounds.on_hit = snd_bat_hit;
// enemy_sounds.on_death = snd_bat_death;

// Bat loot table - light items (fast weak flyer = low drop rate)
drop_chance = 0.2; // 20% chance to drop loot
loot_table = [
    {item_key: "arrows", weight: 2},
    {item_key: "small_health_potion", weight: 1}
];