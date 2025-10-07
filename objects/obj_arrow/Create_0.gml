// Arrow projectile properties
creator = noone;
damage = 0;

// Attack category for damage reduction calculations
attack_category = AttackCategory.ranged;

// Default projectile properties
damage_type = DamageType.physical;
status_effects_on_hit = [];

// Movement (set by spawning code)
speed = 3;
direction = 0;
image_angle = direction;

// Sprite (placeholder - will use spr_arrow when available)
sprite_index = spr_items;
image_index = 28; // arrow frame from item database
image_speed = 0;

// Set depth to draw above ground but below UI
depth = -y;
