
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