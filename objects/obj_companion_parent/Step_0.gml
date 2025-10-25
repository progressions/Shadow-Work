// Companion Parent Step Event
// Handles following AI, animation, and trigger cooldowns

if (global.game_paused) exit;


// Update trigger cooldowns (check if they exist first - companions have different triggers)
if (variable_struct_exists(triggers, "shield") && triggers.shield.cooldown > 0) triggers.shield.cooldown--;
if (variable_struct_exists(triggers, "dash_mend") && triggers.dash_mend.cooldown > 0) triggers.dash_mend.cooldown--;
if (variable_struct_exists(triggers, "aegis") && triggers.aegis.cooldown > 0) triggers.aegis.cooldown--;
if (variable_struct_exists(triggers, "guardian_veil") && triggers.guardian_veil.cooldown > 0) triggers.guardian_veil.cooldown--;
if (variable_struct_exists(triggers, "gust") && triggers.gust.cooldown > 0) triggers.gust.cooldown--;
if (variable_struct_exists(triggers, "slipstream_boost") && triggers.slipstream_boost.cooldown > 0) triggers.slipstream_boost.cooldown--;
if (variable_struct_exists(triggers, "maelstrom") && triggers.maelstrom.cooldown > 0) triggers.maelstrom.cooldown--;
// Yorna's triggers
if (variable_struct_exists(triggers, "on_hit_strike") && triggers.on_hit_strike.cooldown > 0) triggers.on_hit_strike.cooldown--;
if (variable_struct_exists(triggers, "expose_weakness") && triggers.expose_weakness.cooldown > 0) triggers.expose_weakness.cooldown--;
if (variable_struct_exists(triggers, "execution_window") && triggers.execution_window.cooldown > 0) triggers.execution_window.cooldown--;

// Unlock triggers based on affinity (check if they exist first)
if (variable_struct_exists(triggers, "dash_mend")) triggers.dash_mend.unlocked = (affinity >= 5.0);
if (variable_struct_exists(triggers, "aegis")) triggers.aegis.unlocked = (affinity >= 8.0);
if (variable_struct_exists(triggers, "guardian_veil")) triggers.guardian_veil.unlocked = (affinity >= 10.0);
if (variable_struct_exists(triggers, "slipstream_boost")) triggers.slipstream_boost.unlocked = (affinity >= 8.0);
if (variable_struct_exists(triggers, "maelstrom")) triggers.maelstrom.unlocked = (affinity >= 10.0);
// Yorna's triggers (on_hit_strike is unlocked by default)
if (variable_struct_exists(triggers, "expose_weakness")) triggers.expose_weakness.unlocked = (affinity >= 8.0);
if (variable_struct_exists(triggers, "execution_window")) triggers.execution_window.unlocked = (affinity >= 10.0);

// Handle casting state
if (state == CompanionState.casting) {
    // Stop all movement during casting
    move_dir_x = 0;
    move_dir_y = 0;

    // Advance animation timer
    casting_timer++;

    // Advance frame every casting_animation_speed frames
    if (casting_timer >= casting_animation_speed) {
        casting_frame_index++;
        casting_timer = 0;

        // Check if animation complete (3 frames total: 0, 1, 2)
        if (casting_frame_index >= 3) {
            // Return to previous state
            state = previous_state;
            casting_frame_index = 0;

            // Reset instant trigger active flags (triggers without durations)
            // These are effects that fire immediately during casting and don't persist
            if (variable_struct_exists(triggers, "gust") && triggers.gust.active) {
                triggers.gust.active = false;
            }
            if (variable_struct_exists(triggers, "maelstrom") && triggers.maelstrom.active) {
                triggers.maelstrom.active = false;
            }
            if (variable_struct_exists(triggers, "dash_mend") && triggers.dash_mend.active) {
                triggers.dash_mend.active = false;
            }
        }
    }

    // Exit early - don't process following logic while casting
    exit;
}

// Combat evasion state transition (only when recruited)
if (is_recruited && instance_exists(follow_target)) {
    // Check player combat timer with hysteresis
    var player_combat_timer = 999;
    var player_combat_cooldown = 3;

    with (follow_target) {
        if (variable_instance_exists(self, "combat_timer")) {
            player_combat_timer = combat_timer;
            player_combat_cooldown = combat_cooldown;
        }
    }

    // Hysteresis buffer to prevent rapid state switching
    var evade_enter_threshold = player_combat_cooldown; // 3 seconds
    var evade_exit_threshold = player_combat_cooldown + 0.5; // 3.5 seconds (buffer)

    // Transition with hysteresis
    if (player_combat_timer < evade_enter_threshold && state == CompanionState.following) {
        state = CompanionState.evading;
        evade_recalc_timer = 0; // Reset timer to recalculate immediately
    } else if (player_combat_timer > evade_exit_threshold && state == CompanionState.evading) {
        state = CompanionState.following;
    }
}

// Evading behavior (maintaining distance from combat)
if (state == CompanionState.evading && instance_exists(follow_target)) {
    evade_from_combat();
    // Don't process following logic below
    var _skip_following = true;
} else {
    var _skip_following = false;
}

// Following behavior (only when in following state, not casting or evading)
if (is_recruited && state == CompanionState.following) {
    if (instance_exists(follow_target)) {
        var dist_to_player = point_distance(x, y, follow_target.x, follow_target.y);

        // Check if too far from player
        if (dist_to_player > teleport_distance_threshold) {
            time_far_from_player++;

            // Teleport if been far for too long
            if (time_far_from_player >= teleport_time_threshold) {
                // Find safe position near player (behind them based on their facing)
                var teleport_offset = 32;
                var player_facing = follow_target.facing_dir;

                // Default behind player (opposite of facing direction)
                var teleport_x = follow_target.x;
                var teleport_y = follow_target.y;

                switch (player_facing) {
                    case "down":  teleport_y -= teleport_offset; break;
                    case "up":    teleport_y += teleport_offset; break;
                    case "left":  teleport_x += teleport_offset; break;
                    case "right": teleport_x -= teleport_offset; break;
                }

                // Teleport
                x = teleport_x;
                y = teleport_y;
                time_far_from_player = 0;

                show_debug_message(companion_name + " teleported to player");
            }
        } else {
            // Close enough, reset timer
            time_far_from_player = 0;
        }

        // Only move if beyond follow distance
        if (dist_to_player > follow_distance) {
            // Pathfinding update throttling
            path_recalc_timer++;

            // Recalculate path periodically or when player moves significantly
            var player_moved_far = point_distance(last_target_x, last_target_y, follow_target.x, follow_target.y) > 32;

            if (path_recalc_timer >= path_recalc_interval || player_moved_far) {
                path_recalc_timer = 0;
                last_target_x = follow_target.x;
                last_target_y = follow_target.y;

                // Update pathfinding (avoids hazards)
                companion_update_path();
            }

            // Follow the path if we have one
            if (path_get_number(companion_path) > 0 && current_waypoint < path_get_number(companion_path)) {
                var target_x = path_get_point_x(companion_path, current_waypoint);
                var target_y = path_get_point_y(companion_path, current_waypoint);

                var dist_to_waypoint = point_distance(x, y, target_x, target_y);

                // Move toward current waypoint
                if (dist_to_waypoint > 4) {
                    var move_dir = point_direction(x, y, target_x, target_y);
                    var move_x = lengthdir_x(follow_speed, move_dir);
                    var move_y = lengthdir_y(follow_speed, move_dir);

                    move_dir_x = move_x;
                    move_dir_y = move_y;

                    move_and_collide(move_x, move_y, [tilemap, obj_rising_pillar, obj_companion_parent]);
                } else {
                    // Reached waypoint, move to next
                    current_waypoint++;
                }
            } else {
                // No path or reached end - try direct movement as fallback
                var dir_to_player = point_direction(x, y, follow_target.x, follow_target.y);
                var move_x = lengthdir_x(follow_speed, dir_to_player);
                var move_y = lengthdir_y(follow_speed, dir_to_player);

                move_dir_x = move_x;
                move_dir_y = move_y;

                move_and_collide(move_x, move_y, [tilemap, obj_rising_pillar, obj_companion_parent]);
            }
        } else {
            // Within follow range, stay idle
            move_dir_x = 0;
            move_dir_y = 0;
        }
    }
} else if (!is_recruited) {
    // Not recruited, stand idle
    move_dir_x = 0;
    move_dir_y = 0;
    state = CompanionState.waiting;
}

// Determine facing direction based on movement
var _is_moving = (abs(move_dir_x) > 0.1) || (abs(move_dir_y) > 0.1);

if (_is_moving) {
    if (abs(move_dir_y) > abs(move_dir_x)) {
        last_dir_index = (move_dir_y < 0) ? 3 : 0; // up : down
    } else {
        last_dir_index = (move_dir_x < 0) ? 2 : 1; // left : right
    }
}

// Animation will be handled in Draw event

// Torch state update
companion_update_torch_state();

// Set interaction_action to Recruit (only shown when not recruited)
interaction_action = "Recruit";

// Handle interaction prompt display - only show if this is the active interactive
if (global.active_interactive == id) {
    show_interaction_prompt_verb(interaction_radius, 0, bbox_top - y - 12, interaction_verb, interaction_action);

    // Handle INTERACT button press - verify player is still in range and can interact
    if (InputPressed(INPUT_VERB.INTERACT) && instance_exists(obj_player)) {
        var _dist = point_distance(x, y, obj_player.x, obj_player.y);
        if (_dist <= interaction_radius && can_interact()) {
            on_interact();
        }
    }
}
// Clean up prompt if we're no longer the active interactive
else if (instance_exists(interaction_prompt)) {
    instance_destroy(interaction_prompt);
    interaction_prompt = noone;
}

// Y-sorted depth for proper rendering order
depth = -bbox_bottom;
