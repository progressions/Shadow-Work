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
        // Update facing_dir to point at player (not movement direction)
        var _dx = obj_player.x - x;
        var _dy = obj_player.y - y;

        if (abs(_dx) > abs(_dy)) {
            facing_dir = (_dx > 0) ? "right" : "left";
        } else {
            facing_dir = (_dy > 0) ? "down" : "up";
        }

        // Calculate spawn position based on facing_dir
        var _projectile_x = x;
        var _projectile_y = y;

        // Offset based on facing direction (similar to player system)
        switch (facing_dir) {
            case "right":
                _projectile_x += 16;
                _projectile_y += 8;
                break;
            case "up":
                _projectile_x += 16;
                _projectile_y -= 16;
                break;
            case "left":
                _projectile_x -= 16;
                _projectile_y -= 20;
                break;
            case "down":
                _projectile_x -= 16;
                _projectile_y += 8;
                break;
        }

        // Spawn projectile (arrow by default)
        var _projectile_obj = is_undefined(ranged_projectile_object) ? obj_enemy_arrow : ranged_projectile_object;
        var _projectile = instance_create_layer(_projectile_x, _projectile_y, "Instances", _projectile_obj);
        _projectile.creator = self;
        _projectile.damage = ranged_damage;  // Use enemy's ranged damage

        // Configure projectile damage type
        var _proj_damage_type = DamageType.physical;
        if (variable_instance_exists(self, "ranged_damage_type")) {
            _proj_damage_type = ranged_damage_type;
        } else if (variable_instance_exists(self, "attack_damage_type")) {
            _proj_damage_type = attack_damage_type;
        }
        _projectile.damage_type = _proj_damage_type;

        // Carry status effects on hit if defined
        if (variable_instance_exists(self, "ranged_status_effects") && is_array(ranged_status_effects) && array_length(ranged_status_effects) > 0) {
            _projectile.status_effects_on_hit = ranged_status_effects;
        } else if (variable_instance_exists(self, "attack_status_effects") && is_array(attack_status_effects) && array_length(attack_status_effects) > 0) {
            _projectile.status_effects_on_hit = attack_status_effects;
        }

        // Set direction based on facing_dir
        switch (facing_dir) {
            case "right": _projectile.direction = 0; break;
            case "up": _projectile.direction = 90; break;
            case "left": _projectile.direction = 180; break;
            case "down": _projectile.direction = 270; break;
        }
        _projectile.image_angle = _projectile.direction;

        // Set state and cooldown
        state = EnemyState.ranged_attacking;
        ranged_attack_cooldown = max(15, round(60 / ranged_attack_speed));
        can_ranged_attack = false;

        // Set failsafe alarm to prevent getting stuck in ranged_attacking
        alarm[3] = 90; // Force exit after 1.5 seconds if still stuck

        // Keep path active - enemy can move while shooting

        // Play sound effect
        play_enemy_sfx("on_attack");

        if (variable_global_exists("debug_mode") && global.debug_mode) {
            show_debug_message("Enemy fired ranged attack (" + object_get_name(_projectile_obj) + ") Damage: " + string(ranged_damage) + ", Direction: " + facing_dir);
        }

        return true;
    }

    return false;
}
