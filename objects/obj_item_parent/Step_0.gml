
// ============================================
// OBJ_ITEM_PARENT - Step Event
// ============================================
// Items use the exact same global timer
if (global.game_paused) exit;

// Handle bobbing animation
if (floor(global.idle_bob_timer) % 2 == 0) {
    y = base_y + 2;
} else {
    y = base_y;
}

// Handle interaction prompt display - only show if this is the active interactive
if (global.active_interactive == id) {
    show_interaction_prompt(interaction_radius, 0, -24, interaction_key, interaction_action);

    // Handle SPACE key press - verify player is still in range and can interact
    if (keyboard_check_pressed(vk_space) && instance_exists(obj_player)) {
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
