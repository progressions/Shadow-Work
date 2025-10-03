// Inherit the parent event
event_inherited();

// Orc-specific stats (stronger, slower)
attack_damage = 12;
attack_speed = 0.6;
attack_range = 25;
hp = 18;
hp_total = hp;
move_speed = 0.8;

// Orc traits - fire-born warrior, immune to fire but weak to ice
array_push(tags, "fireborne");
apply_tag_traits();

enemy_sounds.on_aggro = snd_orc_aggro;
enemy_sounds.on_death = snd_orc_death;
enemy_sounds.on_attack = snd_orc_attack;
enemy_sounds.on_hit = snd_orc_hit;

// Orc loot table - higher drop chance for tougher enemy
drop_chance = 0.5; // 50% chance to drop loot
loot_table = [
    {item_key: "rusty_dagger", weight: 2},
    {item_key: "medium_health_potion", weight: 3},
    {item_key: "leather_armor", weight: 1},
    {item_key: "arrows", weight: 4}
];