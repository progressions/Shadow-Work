// Inherit the parent event
event_inherited();

// Burglar-specific stats (fast, low damage)
attack_damage = 3;
attack_speed = 1.25;
attack_range = 18;
hp = 10;
move_speed = 0.7;

// Burglar traits - forest dweller, vulnerable to fire, resistant to poison
array_push(tags, "aquatic");
apply_tag_traits();

// Approach variation - burglars are sneaky and flank frequently
flank_chance = 0.9;
flank_trigger_distance = 100;  // Shorter range for aggressive close-quarters flanking

enemy_sounds.on_melee_attack = snd_water_bouncer_attack;
enemy_sounds.on_hit = snd_water_bouncer_hit;
enemy_sounds.on_death = snd_water_bouncer_death;

// Burglar loot table - thief-appropriate items (fast, weak enemy = lower drop rate)
drop_chance = 0.25; // 25% chance to drop loot
loot_table = [
    {item_key: "rusty_dagger", weight: 3},
    {item_key: "arrows", weight: 2},
    {item_key: "small_health_potion", weight: 2},
    
];