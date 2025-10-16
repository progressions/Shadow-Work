// Pause path movement when game is paused
if (global.game_paused) {
    // Save the path speed on first pause frame
    if (path_speed != 0) {
        saved_path_speed = path_speed;
        path_speed = 0;
    }
    exit;
}

// Restore path speed when unpaused
if (variable_instance_exists(self, "saved_path_speed") && saved_path_speed != 0) {
    path_speed = saved_path_speed;
    saved_path_speed = 0;
}

// Update stun/stagger timers
update_stun_stagger_timers(self);

// --- Flash Effect System ---
// Handle flash countdown and apply image_blend
// Note: Stun/stagger effects override flashes with persistent colors
if (is_stunned) {
    // Maintain stun color (yellow)
    image_blend = c_yellow;
} else if (is_staggered) {
    // Maintain stagger color (purple)
    image_blend = make_color_rgb(160, 32, 240);
} else if (flash_timer > 0) {
    // Apply temporary flash effect
    flash_timer--;
    image_blend = flash_color;
} else {
    // Reset to base color when no effects active
    if (!variable_instance_exists(self, "base_image_blend")) {
        base_image_blend = c_white;
    }
    image_blend = base_image_blend;
}

// Tick trait-driven status effects (runs even when dead)
tick_status_effects();

// Apply terrain effects (traits and speed modifier)
apply_terrain_effects();

// ============================================
// AUXILIARY THROW STATE MACHINE
// ============================================
// Handle auxiliary being thrown by chain boss
if (variable_instance_exists(self, "throw_state")) {
    // Skip AI if auxiliary is spinning
    if (variable_instance_exists(self, "spin_state") && spin_state == "spinning") {
        // Position is controlled by boss during spin attack
        return;
    }

    if (throw_state == "being_thrown") {
        // Move auxiliary along throw velocity
        x += throw_velocity_x;
        y += throw_velocity_y;

        // Check if reached chain max length (abort throw and return)
        if (variable_instance_exists(self, "chain_boss") && instance_exists(chain_boss)) {
            var _dist_to_boss = point_distance(x, y, chain_boss.x, chain_boss.y);
            if (_dist_to_boss >= chain_boss.chain_max_length) {
                // Reached max chain length, start returning
                throw_state = "returning";

                // Stop flying sound
                if (audio_exists(chain_boss.throw_sound_flying)) {
                    stop_looped_sfx(chain_boss.throw_sound_flying);
                }

                show_debug_message("Auxiliary reached chain limit, returning to boss");
            }
        }

        // Skip normal AI when being thrown
        return;
    } else if (throw_state == "returning") {
        // Move back toward boss
        if (variable_instance_exists(self, "chain_boss") && instance_exists(chain_boss)) {
            var _angle_to_boss = point_direction(x, y, chain_boss.x, chain_boss.y);
            var _return_speed = chain_boss.throw_return_speed;

            x += lengthdir_x(_return_speed, _angle_to_boss);
            y += lengthdir_y(_return_speed, _angle_to_boss);

            // Check if reached boss
            var _dist_to_boss = point_distance(x, y, chain_boss.x, chain_boss.y);
            if (_dist_to_boss < 32) {
                // Reached boss, reset to idle
                throw_state = "idle";
                collision_damage_enabled = original_collision_damage_enabled;

                // Boss can throw again
                chain_boss.throw_state = "none";
                chain_boss.throw_target_auxiliary = noone;
                chain_boss.throw_cooldown_timer = chain_boss.throw_cooldown;

                show_debug_message("Auxiliary returned to boss, throw cooldown started");
            }
        }

        // Skip normal AI when returning
        return;
    }
}

// Track state transitions for approach variation reset
if (!variable_instance_exists(self, "previous_state")) {
    previous_state = state;
}

var _entering_combat = ((state == EnemyState.targeting || state == EnemyState.ranged_attacking) &&
                        (previous_state != EnemyState.targeting && previous_state != EnemyState.ranged_attacking));

if (_entering_combat) {
    approach_chosen = false;
    approach_mode = "direct";
    flank_offset_angle = 0;
}

// Handle knockback movement when recently hit
if (knockback_timer > 0) {
    if (path_exists(path)) {
        path_end();
    }
    path_speed = 0;

    var _colliders = [tilemap, obj_enemy_parent, obj_rising_pillar, obj_player, obj_companion_parent];
    move_and_collide(kb_x, kb_y, _colliders);

    kb_x *= knockback_damping;
    kb_y *= knockback_damping;

    if (abs(kb_x) < 0.05) kb_x = 0;
    if (abs(kb_y) < 0.05) kb_y = 0;

    knockback_timer--;
    target_x = x;
    target_y = y;

    if (knockback_timer <= 0) {
        kb_x = 0;
        kb_y = 0;
    }

    return;
}

// Safe one-time inits (shared across states)
if (!variable_instance_exists(self, "last_dir_index"))   last_dir_index   = 0;
if (!variable_instance_exists(self, "anim_timer"))       anim_timer       = 0;
if (!variable_instance_exists(self, "anim_speed"))       anim_speed       = 0.18;
if (!variable_instance_exists(self, "move_speed"))       move_speed       = 1;
if (!variable_instance_exists(self, "prev_start_index")) prev_start_index = -1;

// Dedicated dead state handler mirrors player state machine flow
if (state == EnemyState.dead) {
    enemy_state_dead();
    return;
}

if ((state == EnemyState.targeting || state == EnemyState.ranged_attacking) && aggro_release_distance >= 0) {
    var _player_exists = instance_exists(obj_player);
    if (!_player_exists || point_distance(x, y, obj_player.x, obj_player.y) > aggro_release_distance) {
        if (path_exists(path)) {
            path_end();
        }
        path_speed = 0;
        state = EnemyState.wander;
        target_x = x;
        target_y = y;
        alarm[0] = 0;

        // Reset approach variation when losing aggro
        approach_chosen = false;
        approach_mode = "direct";
        flank_offset_angle = 0;
    }
}

// Party controller weighted decision system
if (instance_exists(party_controller)) {
    party_controller.calculate_decision_weights(id);
}

// Approach variation system - select flanking angle when entering close range
if ((state == EnemyState.targeting || state == EnemyState.ranged_attacking) && instance_exists(obj_player)) {
    var dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);

    // Trigger approach selection when entering close range (once per aggro)
    if (!approach_chosen && dist_to_player <= flank_trigger_distance) {
        approach_chosen = true;

        // Random chance to select flanking approach
        if (random(1) < flank_chance) {
            approach_mode = "flanking";

            // Convert player's facing_dir to angle
            var player_facing_angle = 0;
            switch(obj_player.facing_dir) {
                case "down":  player_facing_angle = 90;  break;
                case "right": player_facing_angle = 0;   break;
                case "left":  player_facing_angle = 180; break;
                case "up":    player_facing_angle = 270; break;
            }

            // Calculate angle to approach from behind (opposite of player's facing)
            var behind_angle = player_facing_angle + 180;

            // Calculate current direction from enemy to player
            var current_dir = point_direction(x, y, obj_player.x, obj_player.y);

            // Calculate offset needed to approach from behind
            // Add random variation (±30°) to avoid perfect predictability
            var target_approach_angle = behind_angle + random_range(-30, 30);
            flank_offset_angle = angle_difference(target_approach_angle, current_dir);
        } else {
            approach_mode = "direct";
            flank_offset_angle = 0;
        }
    }
}

// Stun/Stagger restrictions
// If staggered, stop all movement
if (is_staggered) {
    if (path_exists(path)) {
        path_end();
    }
    path_speed = 0;
}

// If fully immobilized (stunned + staggered), skip state processing
if (is_stunned && is_staggered) {
    // Just do animation update, no state logic
    enemy_state_idle();
} else {
    // Dispatch to state-specific handlers
    switch (state) {
        case EnemyState.targeting:
            // If staggered, can't move to target
            if (!is_staggered) {
                enemy_state_targeting();
            } else {
                enemy_state_idle();
            }
            break;

        case EnemyState.attacking:
            // If stunned, can't attack
            if (!is_stunned) {
                enemy_state_attacking();
            } else {
                enemy_state_idle();
            }
            break;

        case EnemyState.ranged_attacking:
            // If stunned, can't attack (but ranged can move while attacking if not staggered)
            if (!is_stunned) {
                enemy_state_ranged_attacking();
            } else {
                enemy_state_idle();
            }
            break;

        case EnemyState.hazard_spawning:
            // If stunned, can't perform hazard spawn
            if (!is_stunned) {
                enemy_state_hazard_spawning();
            } else {
                enemy_state_idle();
            }
            break;

        case EnemyState.wander:
            // If staggered, can't wander
            if (!is_staggered) {
                enemy_state_wander();
            } else {
                enemy_state_idle();
            }
            break;

        case EnemyState.idle:
            enemy_state_idle();
            break;

        default:
            state = EnemyState.targeting;
            if (!is_staggered) {
                enemy_state_targeting();
            } else {
                enemy_state_idle();
            }
            break;
    }
}

// Movement delta after state logic (supports path-based motion)
var _dx = x - xprevious;
var _dy = y - yprevious;
var _is_moving = (abs(_dx) > 0.1) || (abs(_dy) > 0.1);

if (!_is_moving) {
    if (path_exists(path)) {
        _dx = current_path_target_x - x;
        _dy = current_path_target_y - y;
        _is_moving = (abs(_dx) > 0.1) || (abs(_dy) > 0.1);
    }

    if (!_is_moving) {
        _dx = target_x - x;
        _dy = target_y - y;
        _is_moving = (abs(_dx) > 0.1) || (abs(_dy) > 0.1);
    }
}

// Determine facing (0=down,1=right,2=left,3=up)
var dir_index;
if (_is_moving) {
    if (abs(_dy) > abs(_dx)) dir_index = (_dy < 0) ? 3 : 0;
    else                     dir_index = (_dx < 0) ? 2 : 1;
    last_dir_index = dir_index;
} else {
    dir_index = last_dir_index;
}

// Update facing_dir string for ranged attacks (matches dir_index)
var _dir_names = ["down", "right", "left", "up"];
facing_dir = _dir_names[dir_index];

// Animation handling
image_speed = 0;

var _using_walk_anim = ((state == EnemyState.targeting || state == EnemyState.wander) && _is_moving);
var anim_info;

if (_using_walk_anim) {
    var _walk_keys = ["walk_down", "walk_right", "walk_left", "walk_up"];
    var _idle_keys = ["idle_down", "idle_right", "idle_left", "idle_up"];
    anim_info = enemy_anim_get(_walk_keys[dir_index], _idle_keys[dir_index]);
} else {
    anim_info = get_enemy_anim(state, dir_index);
}

var start_index = anim_info.start;
var frames_in_seq = anim_info.length;

// Reset timers when the sequence (block/dir) changes
if (prev_start_index != start_index) {
    if (state == EnemyState.attacking || state == EnemyState.ranged_attacking) {
        anim_timer = 0;
    }
    prev_start_index = start_index;
}

// Choose frame
var frame_offset;
var _use_idle_timer = (state == EnemyState.idle) || _using_walk_anim || !_is_moving;

if (_use_idle_timer) {
    frame_offset = global.idle_bob_timer % frames_in_seq;
} else {
    var speed_mult = 1.25; // faster feel for attacks

    // Apply ranged windup speed modifier during windup phase
    if (state == EnemyState.ranged_attacking && !ranged_windup_complete) {
        speed_mult = speed_mult * ranged_windup_speed; // Slow down animation during windup
    }

    anim_timer += anim_speed * speed_mult;
    frame_offset = floor(anim_timer) mod frames_in_seq;

    // Handle ranged attack windup completion
    if (state == EnemyState.ranged_attacking && !ranged_windup_complete && anim_timer >= frames_in_seq) {
        // Windup animation cycle complete - spawn projectile and exit ranged_attacking state
        ranged_windup_complete = true;
        spawn_ranged_projectile();
        state = EnemyState.targeting; // Return to targeting immediately after firing
        ranged_windup_complete = false; // Reset flag for next attack

        if (variable_global_exists("debug_mode") && global.debug_damage_reduction) {
            show_debug_message("WINDUP COMPLETE - Projectile spawned after " + string(frames_in_seq) + " frames, returning to targeting");
        }
    }

    // Debug: Show windup progress
    if (state == EnemyState.ranged_attacking && !ranged_windup_complete && variable_global_exists("debug_mode") && global.debug_damage_reduction) {
        if (anim_timer mod 30 == 0) { // Log every 30 frames
            show_debug_message("Windup progress: anim_timer=" + string(anim_timer) + "/" + string(frames_in_seq) + ", speed_mult=" + string(speed_mult));
        }
    }

    if (state == EnemyState.attacking && anim_timer >= frames_in_seq) {
        // Keep looping attack animation until alarm[2] finishes and resets state
        anim_timer = 0;
    }
}

// Final image index
var idx = start_index + frame_offset;
var max_index = sprite_get_number(sprite_index) - 1;
if (idx > max_index) idx = max_index;
if (idx < 0)         idx = 0;

image_index = idx;

// Attack cooldowns
if (attack_cooldown > 0) {
    attack_cooldown--;
    can_attack = false;
} else {
    can_attack = true;
}

if (ranged_attack_cooldown > 0) {
    ranged_attack_cooldown--;
    can_ranged_attack = false;
} else {
    can_ranged_attack = true;
}

if (state == EnemyState.ranged_attacking && ranged_attack_cooldown <= 0) {
    state = EnemyState.targeting;
    ranged_windup_complete = false; // Reset windup flag for next attack
}

// Hazard spawning cooldown
if (hazard_spawn_cooldown_timer > 0) {
    hazard_spawn_cooldown_timer--;
}

// Retreat cooldown (for dual-mode enemies)
if (retreat_cooldown > 0) {
    retreat_cooldown--;
}

// Collision damage cooldown
if (collision_damage_timer > 0) {
    collision_damage_timer--;
}

// ============================================
// CHAIN CONSTRAINT SYSTEM
// Applied after all movement to keep auxiliaries tethered to chain boss
// ============================================
if (variable_instance_exists(self, "chain_boss") && instance_exists(chain_boss)) {
    var _dist = point_distance(x, y, chain_boss.x, chain_boss.y);

    // If auxiliary exceeded chain length, clamp to boundary
    if (_dist > chain_boss.chain_max_length) {
        var _angle = point_direction(chain_boss.x, chain_boss.y, x, y);
        x = chain_boss.x + lengthdir_x(chain_boss.chain_max_length, _angle);
        y = chain_boss.y + lengthdir_y(chain_boss.chain_max_length, _angle);

        // Stop pathfinding when hitting chain limit
        if (path_exists(path)) {
            path_end();
        }
    }
}

// Update previous state for next frame's transition detection
previous_state = state;
