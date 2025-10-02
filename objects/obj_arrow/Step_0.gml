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

// Check for collision with enemies
var _hit_enemy = instance_place(x, y, obj_enemy_parent);
if (_hit_enemy != noone) {
    with (_hit_enemy) {
        if (state != EnemyState.dead && alarm[1] < 0) {
            // Apply damage
            hp -= other.damage;
            image_blend = c_red;

            // Play enemy hit sound (same system as melee attacks)
            play_enemy_sfx("on_hit");

            // Spawn damage number
            spawn_damage_number(x, y - 16, other.damage, DamageType.physical, self);

            // Check if enemy died and award XP
            if (hp <= 0) {
                var attacker = other.creator;
                if (attacker != noone && attacker.object_index == obj_player) {
                    var xp_reward = 5;
                    with (attacker) {
                        gain_xp(xp_reward);
                    }
                }

                state = EnemyState.dead;
                play_enemy_sfx("on_death");
                increment_quest_counter("enemies_defeated", 1);
            }

            // Knockback
            kb_x = sign(x - other.x);
            kb_y = sign(y - other.y);
            alarm[1] = 20;
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
