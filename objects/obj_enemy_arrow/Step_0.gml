// Check for collision with Tiles_Col layer
var _tilemap_col = layer_tilemap_get_id("Tiles_Col");
if (_tilemap_col != -1) {
    var _tile_value = tilemap_get_at_pixel(_tilemap_col, x, y);
    if (_tile_value != 0) {
        // Hit a wall - play sound and destroy
        play_sfx(snd_bump, 1, false);
        instance_destroy();
        exit;
    }
}

// Check for collision with player
var _hit_player = instance_place(x, y, obj_player);
if (_hit_player != noone) {
    with (_hit_player) {
        if (state != PlayerState.dead) {
            // Apply damage
            hp -= other.damage;

            // Visual feedback
            image_blend = c_red;
            alarm[0] = 10; // Flash duration (alarm[0] for player, not alarm[1])

            // Play hit sound
            play_sfx(snd_player_hit, 1, false);

            // Spawn damage number
            spawn_damage_number(x, y - 16, other.damage, DamageType.physical, self);

            // Apply knockback
            kb_x = sign(x - other.x) * 2;
            kb_y = sign(y - other.y) * 2;

            // Check if player died
            if (hp <= 0) {
                state = PlayerState.dead;
                play_sfx(snd_player_death, 1, false);
                show_debug_message("Player died from arrow");
            }
        }
    }

    instance_destroy();
    exit;
}

// Check if arrow is out of bounds
if (x < 0 || x > room_width || y < 0 || y > room_height) {
    instance_destroy();
    exit;
}
