// ============================================
// ENEMY STATE: DEAD
// Plays death animation, spawns corpse, and cleans up path
// ============================================

function enemy_state_dead() {
    if (!variable_instance_exists(self, "death_anim_complete")) {
        death_anim_complete = false;
        death_anim_timer = 0;
    }

    if (!death_anim_complete) {
        var _dying_anim = global.enemy_anim_data.dying;
        death_anim_timer += anim_speed;
        var _frame_offset = floor(death_anim_timer) % _dying_anim.length;
        image_index = _dying_anim.start + _frame_offset;

        if (death_anim_timer >= _dying_anim.length) {
            death_anim_complete = true;
            image_index = _dying_anim.start + _dying_anim.length - 1;

            if (path_exists(path)) {
                path_end();
                path_delete(path);
            }

            var _corpse = instance_create_layer(x, y, "Instances", obj_enemy_corpse);
            _corpse.sprite_index = sprite_index;
            _corpse.image_index = image_index;

            instance_destroy();
        }
    } else {
        image_index = global.enemy_anim_data.dying.start + (global.enemy_anim_data.dying.length - 1);
    }
}
