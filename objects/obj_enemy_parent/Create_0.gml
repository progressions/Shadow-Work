
// Get the tilemap for collisions
tilemap = layer_tilemap_get_id("Tiles_Col");

// Initialize animation variables - IMPORTANT!
anim_timer = 0;  // Make sure this is here
image_speed = 0;
image_index = 0;

target_x = x;
target_y = y;

alarm[0] = 60;

// Store movement direction for animation
move_dir_x = 0;
move_dir_y = 0;

current_base_frame = 0;
frame_counter = 0;

state = PlayerState.idle;

kb_x = 0;
kb_y = 0;

// Attack system stats
attack_damage = 2; // Base enemy damage
attack_speed = 0.8; // Slower than default player
attack_range = 20; // Melee range
attack_cooldown = 0;
can_attack = true;