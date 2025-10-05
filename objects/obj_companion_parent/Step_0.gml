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

// Unlock triggers based on affinity (check if they exist first)
if (variable_struct_exists(triggers, "dash_mend")) triggers.dash_mend.unlocked = (affinity >= 5.0);
if (variable_struct_exists(triggers, "aegis")) triggers.aegis.unlocked = (affinity >= 8.0);
if (variable_struct_exists(triggers, "guardian_veil")) triggers.guardian_veil.unlocked = (affinity >= 10.0);
if (variable_struct_exists(triggers, "slipstream_boost")) triggers.slipstream_boost.unlocked = (affinity >= 8.0);
if (variable_struct_exists(triggers, "maelstrom")) triggers.maelstrom.unlocked = (affinity >= 10.0);

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
        }
    }

    // Exit early - don't process following logic while casting
    exit;
}

// Following behavior (only when in following state, not casting)
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
            // Calculate direction to player
            var dir_to_player = point_direction(x, y, follow_target.x, follow_target.y);
            var move_x = lengthdir_x(follow_speed, dir_to_player);
            var move_y = lengthdir_y(follow_speed, dir_to_player);

            // Store movement direction for animation
            move_dir_x = move_x;
            move_dir_y = move_y;

            // Move with collision detection (including other companions)
            move_and_collide(move_x, move_y, [tilemap, obj_rising_pillar, obj_companion_parent]);
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
    show_interaction_prompt(interaction_radius, 0, bbox_top - y - 12, interaction_key, interaction_action);

    // Handle SPACE key press
    if (keyboard_check_pressed(vk_space)) {
        on_interact();
    }
}
// Clean up prompt if we're no longer the active interactive
else if (instance_exists(interaction_prompt)) {
    instance_destroy(interaction_prompt);
    interaction_prompt = noone;
}
