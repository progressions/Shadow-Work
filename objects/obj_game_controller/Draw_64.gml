// Draw GUI Event - Draw "Loading..." text during save load

if (global.is_loading) {
    // Set text properties
    draw_set_font(fnt_arial);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_black);

    // Draw "Loading..." text in center of screen
    draw_text(display_get_gui_width() / 2, display_get_gui_height() / 2, "Loading...");

    // Reset text alignment
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
