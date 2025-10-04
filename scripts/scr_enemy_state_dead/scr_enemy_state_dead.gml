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
        var _dying_anim = enemy_anim_get("dying");
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

            // Check quest objectives for enemy kills
            var _is_quest_enemy = variable_instance_exists(id, "quest_enemy") ? quest_enemy : false;
            var _quest_enemy_id = variable_instance_exists(id, "quest_enemy_id") ? quest_enemy_id : "";
            quest_check_enemy_kill(object_index, tags, _is_quest_enemy, _quest_enemy_id);

            // Notify party controller of death
            if (instance_exists(party_controller)) {
                party_controller.on_member_death(id);
            }

            instance_destroy();
        }
    } else {
        var _final_dying = enemy_anim_get("dying");
        image_index = _final_dying.start + (_final_dying.length - 1);
    }
}
