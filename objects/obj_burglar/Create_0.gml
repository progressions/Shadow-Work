// Inherit the parent event
event_inherited();

// Burglar-specific stats (fast, low damage)
attack_damage = 2;
attack_speed = 1.5;
attack_range = 18;
hp = 5;
move_speed = 0.8;

// Burglar traits - forest dweller, vulnerable to fire, resistant to poison
array_push(tags, "arboreal");
apply_tag_traits();

// Approach variation - burglars are sneaky and flank frequently
flank_chance = 0.7;
flank_trigger_distance = 100;  // Shorter range for aggressive close-quarters flanking

enemy_sounds.on_attack = snd_burglar_attack;
enemy_sounds.on_hit = snd_burglar_hit;
enemy_sounds.on_death = snd_burglar_death;

// Burglar loot table - thief-appropriate items (fast, weak enemy = lower drop rate)
drop_chance = 0.25; // 25% chance to drop loot
loot_table = [
    {item_key: "rusty_dagger", weight: 3},
    {item_key: "arrows", weight: 2},
    {item_key: "small_health_potion", weight: 2},
    {item_key: "water", weight: 1}
];