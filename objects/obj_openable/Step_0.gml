/// @description Handle player interaction and animation

// Show interaction prompt when not opened
if (!is_opened) {
    show_interaction_prompt(interaction_radius, 0, -24, "Space", "Open");
}

// Check for SPACE key press when in range and not opened
if (instance_exists(obj_player) && !is_opened) {
    var _dist = point_distance(x, y, obj_player.x, obj_player.y);
    if (_dist <= interaction_radius && keyboard_check_pressed(vk_space)) {
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
