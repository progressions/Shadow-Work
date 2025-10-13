/// obj_hazard_parent : Draw Event
/// Draw hazard sprite and optional debug visualization

// Draw the hazard sprite automatically
// This maintains normal sprite rendering (animated fire, poison clouds, etc.)
draw_self();

// ==============================
// DEBUG VISUALIZATION (OPTIONAL)
// ==============================

// Uncomment to show hazard collision bounds
/*
if (variable_global_exists("debug_mode") && global.debug_damage_reduction) {
    draw_set_color(c_red);
    draw_set_alpha(0.3);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
    draw_set_alpha(1.0);

    // Draw damage mode label
    draw_set_color(c_white);
    draw_text(x, bbox_top - 16, damage_mode + " (" + damage_type_to_string(damage_type) + ")");
}
*/
