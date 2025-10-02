function enemy_handle_ranged_attack() {
    // Only execute if this enemy is a ranged attacker
    if (!is_ranged_attacker) return false;

    // Update ranged attack cooldown
    if (ranged_attack_cooldown > 0) {
        ranged_attack_cooldown--;
        can_ranged_attack = false;
    } else {
        can_ranged_attack = true;
    }

    // Spawn arrow if cooldown ready and not already in ranged_attacking state
    if (can_ranged_attack && state != EnemyState.ranged_attacking) {
        // Calculate spawn position based on facing_dir
        var _arrow_x = x;
        var _arrow_y = y;

        // Offset based on facing direction (similar to player system)
        switch (facing_dir) {
            case "right":
                _arrow_x += 16;
                _arrow_y += 8;
                break;
            case "up":
                _arrow_x += 16;
                _arrow_y -= 16;
                break;
            case "left":
                _arrow_x -= 16;
                _arrow_y -= 20;
                break;
            case "down":
                _arrow_x -= 16;
                _arrow_y += 8;
                break;
        }

        // Spawn arrow
        var _arrow = instance_create_layer(_arrow_x, _arrow_y, "Instances", obj_enemy_arrow);
        _arrow.creator = self;
        _arrow.damage = ranged_damage;  // Use enemy's ranged damage

        // Set direction based on facing_dir
        switch (facing_dir) {
            case "right": _arrow.direction = 0; break;
            case "up": _arrow.direction = 90; break;
            case "left": _arrow.direction = 180; break;
            case "down": _arrow.direction = 270; break;
        }
        _arrow.image_angle = _arrow.direction;

        // Set state and cooldown
        state = EnemyState.ranged_attacking;
        ranged_attack_cooldown = max(15, round(60 / ranged_attack_speed));
        can_ranged_attack = false;

        // Play sound effect
        play_enemy_sfx("on_attack");

        show_debug_message("Enemy fired arrow! Damage: " + string(ranged_damage) + ", Direction: " + facing_dir);

        return true;
    }

    return false;
}
