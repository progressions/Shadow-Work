/// @function movement_profile_kiting_swooper_update(enemy)
/// @description Update function for kiting swooper movement profile
/// @param {Id.Instance} _enemy - The enemy instance using this profile
function movement_profile_kiting_swooper_update(_enemy) {
    if (!instance_exists(_enemy)) return;
    if (_enemy.movement_profile == undefined) return;

    var _profile = _enemy.movement_profile;
    var _params = _profile.parameters;

    // Use custom parameters if defined (allows per-enemy variation)
    if (variable_instance_exists(_enemy, "movement_profile_custom_params")) {
        var _custom = _enemy.movement_profile_custom_params;
        // Override distance parameters if custom values exist
        if (variable_struct_exists(_custom, "kite_min_distance")) {
            _params = {
                kite_min_distance: _custom.kite_min_distance,
                kite_max_distance: _custom.kite_max_distance,
                kite_ideal_distance: _custom.kite_ideal_distance,
                erratic_offset: _params.erratic_offset,
                erratic_update_interval: _params.erratic_update_interval,
                swoop_range: _params.swoop_range,
                swoop_speed: _params.swoop_speed,
                swoop_cooldown: _params.swoop_cooldown,
                return_speed: _params.return_speed,
                anchor_tolerance: _params.anchor_tolerance
            };
        }
    }

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

        // Check if enemy is flying (can move directly without pathfinding)
        var _is_flying = false;
        with (_enemy) {
            if (variable_instance_exists(self, "tags") && is_array(tags)) {
                for (var i = 0; i < array_length(tags); i++) {
                    if (tags[i] == "flying") {
                        _is_flying = true;
                        break;
                    }
                }
            }
        }

        if (_is_flying) {
            // Flying enemies move directly toward target without pathfinding
            var _dir = point_direction(_enemy.x, _enemy.y, _enemy.movement_profile_target_x, _enemy.movement_profile_target_y);
            var _dist_to_target = point_distance(_enemy.x, _enemy.y, _enemy.movement_profile_target_x, _enemy.movement_profile_target_y);

            // Apply speed modifiers
            var _speed_modifier = 1.0;
            with (_enemy) {
                _speed_modifier = get_status_effect_modifier("speed");
                var _terrain_speed = enemy_get_terrain_speed_modifier();
                var _companion_slow = get_companion_enemy_slow(x, y);
                _speed_modifier *= _terrain_speed * _companion_slow;
            }

            var _actual_speed = _enemy.move_speed * _speed_modifier;

            // Move directly (only avoid rising pillars and other solid objects)
            if (_dist_to_target > 2) {
                var _dx = lengthdir_x(_actual_speed, _dir);
                var _dy = lengthdir_y(_actual_speed, _dir);

                with (_enemy) {
                    move_and_collide(_dx, _dy, [obj_rising_pillar]);
                }
            }
        } else {
            // Ground enemies use pathfinding
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
            // Keep enemy in targeting state - movement profile handles everything

            // Stop following current path
            with (_enemy) {
                if (path_exists(path)) {
                    path_end();
                }
            }

            show_debug_message("Enemy " + object_get_name(_enemy.object_index) + " initiating swoop attack!");
        }
    }
    // Handle swooping state (dash attack toward player)
    else if (_enemy.movement_profile_state == "swooping") {
        // Initialize swoop if not already initialized (check multiple variables to ensure complete init)
        if (!variable_instance_exists(_enemy, "swoop_target_x") ||
            !variable_instance_exists(_enemy, "swoop_direction") ||
            _enemy.swoop_direction == undefined) {
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

            // Initialize swoop hit tracking (prevent multi-hits on same swoop)
            _enemy.swoop_has_hit = false;

            show_debug_message("Swoop attack initialized at angle " + string(_enemy.swoop_direction));
        }

        // Safety check - if swoop_direction is undefined, abort swoop
        if (!variable_instance_exists(_enemy, "swoop_direction") || _enemy.swoop_direction == undefined) {
            show_debug_message("ERROR: swoop_direction undefined, aborting swoop");
            _enemy.movement_profile_state = "returning";
            return;
        }

        // Move in straight line toward target
        var _swoop_dx = lengthdir_x(_params.swoop_speed, _enemy.swoop_direction);
        var _swoop_dy = lengthdir_y(_params.swoop_speed, _enemy.swoop_direction);

        // Apply movement (bats can pass through other enemies during swoop)
        var _collisions = [];
        with (_enemy) {
            _collisions = move_and_collide(_swoop_dx, _swoop_dy, [tilemap, obj_rising_pillar]);
        }

        // Check if player is in melee range and trigger attack
        if (!_enemy.swoop_has_hit && instance_exists(obj_player)) {
            var _dist_to_player = point_distance(_enemy.x, _enemy.y, obj_player.x, obj_player.y);
            if (_dist_to_player <= _enemy.attack_range && _enemy.can_attack) {
                // Temporarily set state to attacking and trigger melee attack
                with (_enemy) {
                    state = EnemyState.attacking;
                    attack_cooldown = round(90 / attack_speed);
                    can_attack = false;
                    alarm[2] = 15; // Standard melee attack delay
                }

                // Mark that this swoop has hit (prevent multi-hits)
                _enemy.swoop_has_hit = true;
                show_debug_message("Swoop triggered melee attack on player (distance: " + string(_dist_to_player) + ")");
            }
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
            // Enemy stays in targeting state throughout movement profile

            // Clean up swoop variables
            _enemy.swoop_target_x = undefined;
            _enemy.swoop_target_y = undefined;
            _enemy.swoop_start_x = undefined;
            _enemy.swoop_start_y = undefined;
            _enemy.swoop_direction = undefined;
            _enemy.swoop_has_hit = undefined;

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
            // Not at anchor yet - navigate back
            // Check if enemy is flying (can move directly without pathfinding)
            var _is_flying = false;
            with (_enemy) {
                if (variable_instance_exists(self, "tags") && is_array(tags)) {
                    for (var i = 0; i < array_length(tags); i++) {
                        if (tags[i] == "flying") {
                            _is_flying = true;
                            break;
                        }
                    }
                }
            }

            if (_is_flying) {
                // Flying enemies move directly toward anchor without pathfinding
                var _dir = point_direction(_enemy.x, _enemy.y, _enemy.movement_profile_anchor_x, _enemy.movement_profile_anchor_y);

                // Apply speed modifiers
                var _speed_modifier = 1.0;
                with (_enemy) {
                    _speed_modifier = get_status_effect_modifier("speed");
                    var _terrain_speed = enemy_get_terrain_speed_modifier();
                    var _companion_slow = get_companion_enemy_slow(x, y);
                    _speed_modifier *= _terrain_speed * _companion_slow;
                }

                var _actual_speed = _enemy.move_speed * _speed_modifier * _params.return_speed;

                // Move directly (only avoid rising pillars and other solid objects)
                var _dx = lengthdir_x(_actual_speed, _dir);
                var _dy = lengthdir_y(_actual_speed, _dir);

                with (_enemy) {
                    move_and_collide(_dx, _dy, [obj_rising_pillar]);
                }
            } else {
                // Ground enemies use pathfinding
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
