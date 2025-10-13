// Use base arrow setup (speed, sprite, depth)
event_inherited();

// Attack category is already set by parent (obj_arrow) to AttackCategory.ranged

// Override visual frame for enemy projectiles (still using shared sheet)
image_index = 28;

// Enemy arrow collision communication variables
__proj_damage_type = DamageType.physical;
__proj_final_damage = 0;
__proj_res_multiplier = 1.0;
__proj_status_effects = [];
__proj_is_crit = false;
