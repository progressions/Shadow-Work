// Inherit the parent event
event_inherited();

// Burglar-specific stats (fast, low damage)
attack_damage = 2;
attack_speed = 1.4;
attack_range = 24;
hp = 7;
move_speed = 0.8;

if (!variable_instance_exists(self, "tags")) tags = [];
array_push(tags, "undead");
apply_tag_traits();

// Approach variation - burglars are sneaky and flank frequently
flank_chance = 0.3;
flank_trigger_distance = 100;  // Shorter range for aggressive close-quarters flanking

enemy_sounds.on_melee_attack = snd_burglar_attack;
enemy_sounds.on_hit = snd_burglar_hit;
enemy_sounds.on_death = snd_burglar_death;


drop_chance = 0.25; // 25% chance to drop loot
loot_table = [
    {item_key: "arrows", weight: 2},
    {item_key: "small_health_potion", weight: 2},
];