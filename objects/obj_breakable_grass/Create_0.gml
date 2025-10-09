// Inherit base breakable setup
event_inherited();

sprite_index = spr_breakable_grass;

// Play the dedicated grass break sound
break_sfx = snd_breakable_grass;
break_sfx_volume = 0.8;

break_particle_sprite = spr_leaves;
break_particle_count = 10;
