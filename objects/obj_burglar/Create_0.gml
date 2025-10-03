// Inherit the parent event
event_inherited();

// Burglar-specific stats (fast, low damage)
attack_damage = 1;
attack_speed = 1.2;
attack_range = 18;
hp = 3;
move_speed = 1.3;

// Burglar traits - forest dweller, vulnerable to fire, resistant to poison
array_push(tags, "arboreal");
apply_tag_traits();

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