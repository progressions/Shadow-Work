exit;

var _gui_w = max(1, display_get_gui_width());
var _gui_h = max(1, display_get_gui_height());

draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Draw letterbox-style border to visually inset the gameplay area
if (ui_inset > 0) {
    draw_set_color(ui_border_color);
    draw_rectangle(0, 0, _gui_w, ui_inset, false); // top
    draw_rectangle(0, _gui_h - ui_inset, _gui_w, _gui_h, false); // bottom
    draw_rectangle(0, ui_inset, ui_inset, _gui_h - ui_inset, false); // left
    draw_rectangle(_gui_w - ui_inset, ui_inset, _gui_w, _gui_h - ui_inset, false); // right
}

var _player = instance_find(obj_player, 0);
if (_player == noone) {
    draw_set_color(c_white);
    exit;
}

var _status_count = 0;
if (variable_instance_exists(_player, "status_effects")) {
    _status_count = array_length(_player.status_effects);
}

var _status_row_w = (_status_count > 0) ? (_status_count * (ui_status_icon_size + ui_status_spacing) - ui_status_spacing) : 0;
var _content_padding = ui_inner_padding;
var _panel_content_w = max(ui_bar_width + 24, _status_row_w + (_content_padding * 2));
var _panel_w = clamp(_panel_content_w + (_content_padding * 2), 80, _gui_w - (ui_inset * 2) - ui_padding * 2);

var _panel_h = ui_bar_height + ui_xp_height + (_status_count > 0 ? ui_status_icon_size + 8 : 0) + (_content_padding * 2) + 12;

var _panel_x = ui_inset + ui_padding;
var _panel_y = ui_inset + ui_padding;

draw_set_color(ui_panel_color);
draw_roundrect(_panel_x - ui_panel_margin, _panel_y - ui_panel_margin, _panel_x - ui_panel_margin + _panel_w, _panel_y - ui_panel_margin + _panel_h, false);

draw_set_color(ui_panel_border_color);
draw_roundrect(_panel_x - ui_panel_margin, _panel_y - ui_panel_margin, _panel_x - ui_panel_margin + _panel_w, _panel_y - ui_panel_margin + _panel_h, true);

var _content_x = _panel_x + _content_padding;
var _content_y = _panel_y + _content_padding;

var _health_y = _content_y;
var _xp_y = _health_y + ui_bar_height + 4;
var _status_y = _xp_y + ui_xp_height + 6;

ui_draw_health_bar(_player, _content_x, _health_y, ui_bar_width, ui_bar_height);

var _level_label_x = _content_x + ui_bar_width + 6;
var _level_label_y = _xp_y - 2;
ui_draw_xp_bar(_player, _content_x, _xp_y, ui_bar_width, ui_xp_height, _level_label_x, _level_label_y);

if (_status_count > 0) {
    var _status_start_x = _content_x;
    if (_status_row_w < ui_bar_width) {
        _status_start_x = floor(_content_x + (ui_bar_width - _status_row_w) * 0.5);
    }
    ui_draw_status_effects(_player, _status_start_x, _status_y, ui_status_icon_size, ui_status_spacing);
}

draw_set_color(c_white);
