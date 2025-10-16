// ============================================
// ENEMY STATE: HAZARD SPAWNING
// Windup animation, spawn projectile, return to targeting
// ============================================

function enemy_state_hazard_spawning() {
    // Stop movement during windup and spawn
    target_x = x;
    target_y = y;

    if (path_exists(path)) {
        path_end();
    }

    // Phase 1: Windup
    if (hazard_spawn_windup_timer > 0) {
        hazard_spawn_windup_timer--;

        // Play windup sound at start of windup (only once)
        if (hazard_spawn_windup_timer == hazard_spawn_windup_time - 1) {
            play_enemy_sfx("on_hazard_windup");
        }

        // Stay in windup phase
        return;
    }

    // Phase 2: Spawn projectile (happens once when windup completes)
    if (hazard_spawn_windup_timer == 0) {
        spawn_hazard_projectile();

        // Set windup timer to -1 to indicate spawn has occurred
        hazard_spawn_windup_timer = -1;

        // Start cooldown
        hazard_spawn_cooldown_timer = hazard_spawn_cooldown;

        // Return to targeting after brief delay (10 frames)
        alarm[5] = 10;  // Use alarm[5] for state transition
        return;
    }

    // Phase 3: Waiting for alarm to trigger state transition
    // Alarm[5] will set state back to targeting
}

/// @function spawn_hazard_projectile
/// @description Spawns a hazard projectile targeting the player's current location
function spawn_hazard_projectile() {
    // Calculate angle toward player's current position
    var _projectile_dir = point_direction(x, y, obj_player.x, obj_player.y);

    // Add configured offset if needed
    _projectile_dir += hazard_projectile_direction_offset;

    // Calculate spawn position slightly in front of enemy (toward player)
    var _spawn_offset = 16;
    var _spawn_x = x + lengthdir_x(_spawn_offset, _projectile_dir);
    var _spawn_y = y + lengthdir_y(_spawn_offset, _projectile_dir);

    // Create the projectile (use depth instead of layer to avoid layer issues)
    var _projectile = instance_create_depth(_spawn_x, _spawn_y, depth, hazard_projectile_object);

    if (instance_exists(_projectile)) {
        // Configure projectile properties
        _projectile.creator = self;
        _projectile.direction = _projectile_dir;
        _projectile.image_angle = _projectile_dir;
        _projectile.move_speed = hazard_projectile_speed;
        _projectile.travel_distance = hazard_projectile_distance;
        _projectile.damage_amount = hazard_projectile_damage;
        _projectile.damage_type = hazard_projectile_damage_type;
        _projectile.hazard_object = hazard_spawn_object;
        _projectile.hazard_lifetime = hazard_lifetime;

        // Pass explosion configuration
        _projectile.explosion_enabled = hazard_explosion_enabled;
        _projectile.explosion_object = hazard_explosion_object;
        _projectile.explosion_damage = hazard_explosion_damage;
        _projectile.explosion_damage_type = hazard_explosion_damage_type;

        // Pass status effects if configured
        if (variable_instance_exists(self, "hazard_status_effects")) {
            _projectile.status_effects_on_hit = hazard_status_effects;
        }
    }
}