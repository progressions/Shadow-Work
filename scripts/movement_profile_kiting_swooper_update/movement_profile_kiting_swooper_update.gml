/// @function movement_profile_kiting_swooper_update(enemy)
/// @description Update function for kiting swooper movement profile
/// @param {Id.Instance} enemy - The enemy instance using this profile
function movement_profile_kiting_swooper_update(_enemy) {
    if (!instance_exists(_enemy)) return;
    if (_enemy.movement_profile == undefined) return;

    var _profile = _enemy.movement_profile;
    var _params = _profile.parameters;

    // Get player reference
    if (!instance_exists(obj_player)) return;
    var _player = obj_player;

    // Handle crowd control effects
    // Stunned: Can't attack or take actions (skip all logic, preserve state)
    if (_enemy.is_stunned) {
        return;
    }

    // Staggered: Can't move (skip movement logic, preserve state, but allow cooldown counting)
    if (_enemy.is_staggered) {
        // Continue cooldown timers even when staggered
        if (_enemy.movement_profile_swoop_cooldown > 0) {
            _enemy.movement_profile_swoop_cooldown--;
        }
        if (_enemy.movement_profile_erratic_timer > 0) {
            _enemy.movement_profile_erratic_timer--;
        }
        return;
    }

    // Handle kiting state
    if (_enemy.movement_profile_state == "kiting") {
        // Calculate distance to player
        var _dist_to_player = point_distance(_enemy.x, _enemy.y, _player.x, _player.y);

        // Determine base target position based on distance
        var _base_target_x = _enemy.x;
        var _base_target_y = _enemy.y;

        if (_dist_to_player < _params.kite_min_distance) {
            // Too close - move away from player
            var _away_angle = point_direction(_player.x, _player.y, _enemy.x, _enemy.y);
            _base_target_x = _player.x + lengthdir_x(_params.kite_ideal_distance, _away_angle);
            _base_target_y = _player.y + lengthdir_y(_params.kite_ideal_distance, _away_angle);
        } else if (_dist_to_player > _params.kite_max_distance) {
            // Too far - move toward player
            var _toward_angle = point_direction(_enemy.x, _enemy.y, _player.x, _player.y);
            _base_target_x = _player.x + lengthdir_x(_params.kite_ideal_distance, _toward_angle);
            _base_target_y = _player.y + lengthdir_y(_params.kite_ideal_distance, _toward_angle);
        } else {
            // At good distance - maintain with erratic movement
            // Use player position as base, offset by ideal distance in current direction
            var _current_angle = point_direction(_player.x, _player.y, _enemy.x, _enemy.y);
            _base_target_x = _player.x + lengthdir_x(_params.kite_ideal_distance, _current_angle);
            _base_target_y = _player.y + lengthdir_y(_params.kite_ideal_distance, _current_angle);
        }

        // Update erratic offset timer
        _enemy.movement_profile_erratic_timer--;

        if (_enemy.movement_profile_erratic_timer <= 0) {
            // Time to update erratic offset
            _enemy.movement_profile_erratic_timer = _params.erratic_update_interval;

            // Add random offset to target position for erratic movement
            var _random_angle = random(360);
            var _random_dist = random(_params.erratic_offset);

            _enemy.movement_profile_target_x = _base_target_x + lengthdir_x(_random_dist, _random_angle);
            _enemy.movement_profile_target_y = _base_target_y + lengthdir_y(_random_dist, _random_angle);
        }

        // Use pathfinding to move toward erratic target
        // Check if we need to update path (target moved significantly or no path)
        var _path_needs_update = false;

        if (!path_exists(_enemy.path) || _enemy.path_speed == 0) {
            _path_needs_update = true;
        } else {
            var _dist_to_path_target = point_distance(
                _enemy.movement_profile_target_x,
                _enemy.movement_profile_target_y,
                _enemy.current_path_target_x,
                _enemy.current_path_target_y
            );
            if (_dist_to_path_target > 32) {
                _path_needs_update = true;
            }
        }

        if (_path_needs_update) {
            // Use existing enemy pathfinding system
            with (_enemy) {
                var _path_found = enemy_update_path(
                    movement_profile_target_x,
                    movement_profile_target_y
                );

                if (_path_found) {
                    current_path_target_x = movement_profile_target_x;
                    current_path_target_y = movement_profile_target_y;
                }
            }
        }

        // Update facing direction based on movement
        var _dx = _enemy.x - _enemy.xprevious;
        var _dy = _enemy.y - _enemy.yprevious;

        if (abs(_dx) > abs(_dy)) {
            _enemy.facing_dir = (_dx > 0) ? "right" : "left";
        } else if (abs(_dy) > 0.1) {
            _enemy.facing_dir = (_dy > 0) ? "down" : "up";
        }

        // Check swoop attack conditions
        _enemy.movement_profile_swoop_cooldown--;

        if (_enemy.movement_profile_swoop_cooldown <= 0 && _dist_to_player <= _params.swoop_range) {
            // Ready to swoop!
            _enemy.movement_profile_state = "swooping";
            _enemy.state = EnemyState.attacking;

            if (path_exists(_enemy.path)) {
                path_end(_enemy.path);
            }

            show_debug_message("Enemy " + object_get_name(_enemy.object_index) + " initiating swoop attack!");
        }
    }
    // Handle swooping state (dash attack toward player)
    else if (_enemy.movement_profile_state == "swooping") {
        // Calculate direction to player (locked at swoop start)
        if (!variable_instance_exists(_enemy, "swoop_target_x")) {
            // Store target position when swoop begins
            _enemy.swoop_target_x = _player.x;
            _enemy.swoop_target_y = _player.y;
            _enemy.swoop_start_x = _enemy.x;
            _enemy.swoop_start_y = _enemy.y;

            // Calculate swoop direction
            _enemy.swoop_direction = point_direction(_enemy.x, _enemy.y, _player.x, _player.y);

            // Update facing direction for animation
            var _angle = _enemy.swoop_direction;
            if (_angle >= 315 || _angle < 45) {
                _enemy.facing_dir = "right";
            } else if (_angle >= 45 && _angle < 135) {
                _enemy.facing_dir = "down";
            } else if (_angle >= 135 && _angle < 225) {
                _enemy.facing_dir = "left";
            } else {
                _enemy.facing_dir = "up";
            }

            // Create swoop attack hitbox
            var _attack = instance_create_layer(_enemy.x, _enemy.y, "Instances", obj_enemy_attack);
            _attack.creator = _enemy;
            _attack.damage = _enemy.attack_damage;
            _attack.damage_type = _enemy.attack_damage_type;
            _attack.direction = _enemy.swoop_direction;
            _attack.speed = _params.swoop_speed;
            _attack.image_angle = _enemy.swoop_direction;

            // Store attack instance reference
            _enemy.swoop_attack_instance = _attack;

            show_debug_message("Swoop attack created at angle " + string(_enemy.swoop_direction));
        }

        // Move in straight line toward target
        var _swoop_dx = lengthdir_x(_params.swoop_speed, _enemy.swoop_direction);
        var _swoop_dy = lengthdir_y(_params.swoop_speed, _enemy.swoop_direction);

        // Apply movement (using move_and_collide for collision detection)
        var _collisions = [];
        with (_enemy) {
            _collisions = move_and_collide(_swoop_dx, _swoop_dy, [tilemap, obj_enemy_parent, obj_rising_pillar, obj_player]);
        }

        // Check if we've reached target or hit something
        var _dist_to_target = point_distance(_enemy.x, _enemy.y, _enemy.swoop_target_x, _enemy.swoop_target_y);
        var _dist_traveled = point_distance(_enemy.x, _enemy.y, _enemy.swoop_start_x, _enemy.swoop_start_y);

        // Transition to returning state if:
        // 1. Reached target area (within 20 pixels)
        // 2. Traveled swoop_range distance
        // 3. Hit a wall
        if (_dist_to_target < 20 || _dist_traveled > _params.swoop_range || array_length(_collisions) > 0) {
            // Swoop complete - transition to returning
            _enemy.movement_profile_state = "returning";
            _enemy.state = EnemyState.targeting;

            // Clean up swoop variables
            _enemy.swoop_target_x = undefined;
            _enemy.swoop_target_y = undefined;
            _enemy.swoop_start_x = undefined;
            _enemy.swoop_start_y = undefined;
            _enemy.swoop_direction = undefined;

            // Destroy attack hitbox if still exists
            if (variable_instance_exists(_enemy, "swoop_attack_instance") &&
                instance_exists(_enemy.swoop_attack_instance)) {
                instance_destroy(_enemy.swoop_attack_instance);
            }
            _enemy.swoop_attack_instance = undefined;

            show_debug_message("Swoop complete, transitioning to returning state");
        }
    }
    // Handle returning state (navigate back to anchor position)
    else if (_enemy.movement_profile_state == "returning") {
        // Calculate distance to anchor position
        var _dist_to_anchor = point_distance(_enemy.x, _enemy.y, _enemy.movement_profile_anchor_x, _enemy.movement_profile_anchor_y);

        // Check if we've reached anchor position
        if (_dist_to_anchor <= _params.anchor_tolerance) {
            // Reached anchor - transition back to kiting
            _enemy.movement_profile_state = "kiting";

            // Reset swoop cooldown
            _enemy.movement_profile_swoop_cooldown = _params.swoop_cooldown;

            // Reset erratic timer to immediately pick new position
            _enemy.movement_profile_erratic_timer = 0;

            show_debug_message("Enemy " + object_get_name(_enemy.object_index) + " returned to anchor, resuming kiting");
        } else {
            // Not at anchor yet - navigate back using pathfinding
            // Check if we need to update path
            var _path_needs_update = false;

            if (!path_exists(_enemy.path) || _enemy.path_speed == 0) {
                _path_needs_update = true;
            } else {
                var _dist_to_path_target = point_distance(
                    _enemy.movement_profile_anchor_x,
                    _enemy.movement_profile_anchor_y,
                    _enemy.current_path_target_x,
                    _enemy.current_path_target_y
                );
                if (_dist_to_path_target > 32) {
                    _path_needs_update = true;
                }
            }

            if (_path_needs_update) {
                // Use existing enemy pathfinding system
                with (_enemy) {
                    var _path_found = enemy_update_path(
                        movement_profile_anchor_x,
                        movement_profile_anchor_y
                    );

                    if (_path_found) {
                        current_path_target_x = movement_profile_anchor_x;
                        current_path_target_y = movement_profile_anchor_y;
                    }
                }
            }

            // Update facing direction based on movement
            var _dx = _enemy.x - _enemy.xprevious;
            var _dy = _enemy.y - _enemy.yprevious;

            if (abs(_dx) > abs(_dy)) {
                _enemy.facing_dir = (_dx > 0) ? "right" : "left";
            } else if (abs(_dy) > 0.1) {
                _enemy.facing_dir = (_dy > 0) ? "down" : "up";
            }
        }
    }
}
