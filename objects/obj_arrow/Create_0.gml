// Arrow projectile properties
creator = noone;
damage = 0;

// Movement (set by spawning code)
speed = 6;
direction = 0;
image_angle = direction;

// Sprite (placeholder - will use spr_arrow when available)
sprite_index = spr_items;
image_index = 28; // arrow frame from item database
image_speed = 0;

// Set depth to draw above ground but below UI
depth = -y;
