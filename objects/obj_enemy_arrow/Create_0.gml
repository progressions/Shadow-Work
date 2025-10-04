// Use base arrow setup (speed, sprite, depth)
event_inherited();

// Attack category is already set by parent (obj_arrow) to AttackCategory.ranged

// Override visual frame for enemy projectiles (still using shared sheet)
image_index = 28;
