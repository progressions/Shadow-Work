// Inherit the parent event
event_inherited();

// Burglar-specific stats (fast, low damage)
attack_damage = 1;
attack_speed = 1.2;
attack_range = 18;
hp = 3;
move_speed = 1.3;

// Burglar traits - forest dweller, vulnerable to fire
traits = ["arboreal"];

enemy_sounds.on_attack = snd_burglar_attack;
enemy_sounds.on_hit = snd_burglar_hit;
enemy_sounds.on_death = snd_burglar_death;