/// @description Handle player interaction and animation

// Show interaction prompt only if this is the active interactive object
if (!is_opened && global.active_interactive == id) {
    show_interaction_prompt(interaction_radius, 0, -24, interaction_key, interaction_action);

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

// Advance opening animation
if (is_opened && image_index < 3) {
    image_index += 0.2; // Animate over ~15 frames at 60fps

    // Spawn loot when animation completes
    if (image_index >= 3) {
        image_index = 3; // Freeze on final frame
        spawn_loot();
    }
}
