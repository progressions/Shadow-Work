/// @description Draw interaction prompt with outline

// Store current draw settings
var _prev_halign = draw_get_halign();
var _prev_valign = draw_get_valign();
var _prev_color = draw_get_color();
var _prev_font = draw_get_font();

// New verb mode - draw icon + action text
if (use_verb && verb != -1) {
    var _icon = InputIconGet(verb);
    var _draw_y = y - 6;

    // Calculate total width for centering
    var _icon_width = 16;
    var _spacing = 4;
    var _text_width = string_width(action_text) * text_scale;

    if (is_struct(_icon) && sprite_exists(_icon.sprite)) {
        _icon_width = sprite_get_width(_icon.sprite);
    } else if (is_string(_icon)) {
        _icon_width = string_width(_icon) * text_scale;
    }

    var _total_width = _icon_width + _spacing + _text_width;
    var _start_x = x - (_total_width / 2);

    // Draw icon (sprite or text)
    if (is_struct(_icon) && sprite_exists(_icon.sprite)) {
        // Draw sprite icon
        draw_sprite(_icon.sprite, _icon.frame, _start_x + (_icon_width / 2), _draw_y);
    } else if (is_string(_icon)) {
        // Draw text icon with brackets
        var _icon_text = "[[" + _icon + "]";
        scribble(_icon_text)
            .starting_format("fnt_ui", text_color)
            .scale(text_scale)
            .align(fa_left, fa_bottom)
            .sdf_outline(c_black, 1)
            .sdf_shadow(c_black, 0.3, -2, 2, 0.1)
            .draw(_start_x, _draw_y);
    }

    // Draw action text
    scribble(action_text)
        .starting_format("fnt_ui", text_color)
        .scale(text_scale)
        .align(fa_left, fa_bottom)
        .sdf_outline(c_black, 1)
        .sdf_shadow(c_black, 0.3, -2, 2, 0.1)
        .draw(_start_x + _icon_width + _spacing, _draw_y);
}
// Legacy text mode - draw pre-formatted text
else {
    scribble(text)
        .starting_format("fnt_ui", text_color)
        .scale(text_scale)
        .align(fa_center, fa_bottom)
        .sdf_outline(c_black, 1)
        .sdf_shadow(c_black, 0.3, -2, 2, 0.1)
        .draw(x, y - 6);
}

// Restore previous draw settings
draw_set_font(_prev_font);
draw_set_halign(_prev_halign);
draw_set_valign(_prev_valign);
draw_set_color(_prev_color);
