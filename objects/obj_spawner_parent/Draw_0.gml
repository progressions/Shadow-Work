// ============================================
// SPAWNER PARENT - Draw Event
// Handle visibility and optional debug display
// ============================================

// Only draw if visible
if (is_visible && sprite_index != -1) {
    draw_self();
}

// Optional: Draw debug information (uncomment for testing)
/*
if (is_visible) {
    draw_set_color(c_white);
    draw_set_alpha(0.8);
    var debug_text = "Spawned: " + string(spawned_count);
    if (spawn_mode == SpawnerMode.finite) {
        debug_text += "/" + string(max_total_spawns);
    }
    debug_text += "\nActive: " + string(array_length(active_spawned_enemies)) + "/" + string(max_concurrent_enemies);
    debug_text += "\nTimer: " + string(spawn_timer);
    debug_text += "\nStatus: " + (is_active ? "Active" : "Inactive");
    draw_text(x, y - 32, debug_text);
    draw_set_alpha(1);
}

// Draw proximity radius if enabled
if (proximity_enabled && is_visible) {
    draw_set_color(c_yellow);
    draw_set_alpha(0.2);
    draw_circle(x, y, proximity_radius, false);
    draw_set_alpha(1);
}
*/
