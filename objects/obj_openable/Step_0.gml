/// @description Handle player interaction and animation

// Check if player is within interaction range
if (instance_exists(obj_player)) {
    var _dist = point_distance(x, y, obj_player.x, obj_player.y);
    var _in_range = (_dist <= interaction_radius);

    // Show/hide interaction prompt
    if (!is_opened) {
        if (_in_range && !instance_exists(interaction_prompt)) {
            // Create prompt
            interaction_prompt = instance_create_layer(x, y - 8, "Instances", obj_interaction_prompt);
            interaction_prompt.text = "[Space] Open";
            interaction_prompt.parent_instance = id;
            interaction_prompt.depth = -9999; // Draw on top
        } else if (!_in_range && instance_exists(interaction_prompt)) {
            // Destroy prompt
            instance_destroy(interaction_prompt);
            interaction_prompt = noone;
        }
    }

    // Check for SPACE key press when in range and not opened
    if (_in_range && !is_opened && keyboard_check_pressed(vk_space)) {
        open_container();
        // Destroy prompt when opened
        if (instance_exists(interaction_prompt)) {
            instance_destroy(interaction_prompt);
            interaction_prompt = noone;
        }
    }
}

// Advance opening animation
if (is_opened && image_index < 3) {
    image_index += 0.2; // Animate over ~15 frames at 60fps

    // Spawn loot when animation completes
    if (image_index >= 3) {
        image_index = 3; // Freeze on final frame
        spawn_loot();
    }
}
