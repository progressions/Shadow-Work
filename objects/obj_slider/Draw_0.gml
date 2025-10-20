// Draw the slider bar (automatically respects all instance properties)
draw_self();

// Calculate handle position along the bar
var _bar_width = sprite_width;
var _bar_left = bbox_left;
var _handle_x = _bar_left + (value * _bar_width);

// Draw the handle at the calculated position
draw_sprite_ext(handle_sprite, 0, _handle_x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
