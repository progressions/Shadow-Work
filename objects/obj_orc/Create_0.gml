// Inherit the parent event
event_inherited();

// Orc-specific stats (stronger, slower)
attack_damage = 3;
attack_speed = 0.6;
attack_range = 25;
hp = 18;
hp_total = hp;
move_speed = 0.8;

// Orc traits - fire-born warrior, resistant to fire
traits = ["fireborne"];

enemy_sounds.on_aggro = snd_orc_aggro;
enemy_sounds.on_death = snd_orc_death;
enemy_sounds.on_attack = snd_orc_attack;
enemy_sounds.on_hit = snd_orc_hit;