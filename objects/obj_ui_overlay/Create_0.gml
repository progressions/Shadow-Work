exit;
persistent = true;

ui_inset = 6;
ui_padding = 6;
ui_bar_width = 48;
ui_bar_height = 4;
ui_xp_height = 3;
ui_status_icon_size = 8;
ui_status_spacing = 1;
ui_panel_margin = 2;
ui_inner_padding = 4;

var _camera = view_camera[0];
if (!is_undefined(_camera) && _camera != -1) {
    ui_view_base_w = camera_get_view_width(_camera);
    ui_view_base_h = camera_get_view_height(_camera);
} else {
    ui_view_base_w = display_get_gui_width();
    ui_view_base_h = display_get_gui_height();
}

if (ui_view_base_w <= 0 || ui_view_base_h <= 0) {
    if (surface_exists(application_surface)) {
        ui_view_base_w = surface_get_width(application_surface);
        ui_view_base_h = surface_get_height(application_surface);
    } else {
        ui_view_base_w = 320;
        ui_view_base_h = 180;
    }
}

display_set_gui_size(ui_view_base_w, ui_view_base_h);

ui_panel_color = make_color_rgb(20, 20, 28);
ui_panel_border_color = make_color_rgb(60, 60, 84);
ui_border_color = make_color_rgb(6, 8, 16);
