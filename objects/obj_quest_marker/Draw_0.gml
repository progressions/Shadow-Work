/// Quest Marker Draw Event
/// Draw animated marker and off-screen arrow indicator

var _cam = view_camera[0];
var _cam_x = camera_get_view_x(_cam);
var _cam_y = camera_get_view_y(_cam);
var _cam_w = camera_get_view_width(_cam);
var _cam_h = camera_get_view_height(_cam);

var _marker_x = x;
var _marker_y = y;

// Check if marker is on screen
var _on_screen = point_in_rectangle(_marker_x, _marker_y,
    _cam_x, _cam_y,
    _cam_x + _cam_w, _cam_y + _cam_h);

if (_on_screen) {
    // Draw animated marker at location
    draw_sprite(marker_sprite, image_index, _marker_x, _marker_y);
} else if (show_offscreen_arrow) {
    // Draw off-screen arrow indicator pointing toward marker
    var _screen_center_x = _cam_x + _cam_w / 2;
    var _screen_center_y = _cam_y + _cam_h / 2;

    // Calculate direction from screen center to marker
    var _dir_x = _marker_x - _screen_center_x;
    var _dir_y = _marker_y - _screen_center_y;
    var _dist = sqrt(_dir_x * _dir_x + _dir_y * _dir_y);

    if (_dist > 0) {
        // Normalize direction
        var _norm_x = _dir_x / _dist;
        var _norm_y = _dir_y / _dist;

        // Position arrow at screen edge, pointing toward marker
        var _arrow_x = _screen_center_x + _norm_x * (_cam_w / 2 - 5);
        var _arrow_y = _screen_center_y + _norm_y * (_cam_h / 2 - 5);

        // Draw arrow sprite pointing toward marker
        var _angle = point_direction(_screen_center_x, _screen_center_y, _marker_x, _marker_y);

        // Sprite naturally points up, add 90° to align with GameMaker's rotation
        // Add 180° to flip direction (was pointing opposite)
        var _rotation = _angle - 90;

        // Draw arrow sprite with rotation, color, and alpha
        draw_sprite_ext(
            spr_quest_pointer,          // Arrow sprite
            0,                          // Frame (use first frame)
            _arrow_x,                   // X position
            _arrow_y,                   // Y position
            1,                          // X scale
            1,                          // Y scale
            _rotation,                  // Rotation angle
            offscreen_arrow_color,      // Color blend
            offscreen_arrow_alpha       // Alpha transparency
        );
    }
}