/// Chain Boss Parent - Draw Event
// Draw chains connecting boss to auxiliaries, then draw boss sprite

// ============================================
// CHAIN RENDERING
// ============================================

/// @function draw_chain_segment
/// @description Helper function to draw repeating chain links with smooth sagging curve
/// @param {real} x1 Start X position
/// @param {real} y1 Start Y position
/// @param {real} x2 End X position
/// @param {real} y2 End Y position
/// @param {asset} sprite Chain sprite to draw (4×8 single link)
/// @param {real} tension Tension ratio (0.0 = very slack, 1.0 = taut)
function draw_chain_segment(x1, y1, x2, y2, sprite, tension) {
    var _dist = point_distance(x1, y1, x2, y2);
    var _base_angle = point_direction(x1, y1, x2, y2);
    var _sprite_height = sprite_get_height(sprite);

    // Calculate how many chain links to draw
    var _num_links = ceil(_dist / _sprite_height);

    // Calculate maximum sag based on tension (less tension = more sag)
    // Taut chains (tension > 0.7) have minimal sag
    var _max_sag = 0;
    if (tension < 0.7) {
        _max_sag = (1 - tension) * 20;  // Up to 20 pixels of sag when very slack
    }

    // Draw each chain link along a curved path
    for (var i = 0; i < _num_links; i++) {
        var _t = (i * _sprite_height) / _dist;  // Position along line (0.0 to 1.0)

        // Calculate position along straight line
        var _link_x = lerp(x1, x2, _t);
        var _link_y = lerp(y1, y2, _t);

        // Calculate parabolic sag offset (peaks at midpoint)
        // Formula: 4 * t * (1 - t) gives 0 at ends, 1.0 at t=0.5
        var _sag_curve = 4 * _t * (1 - _t);
        var _sag_offset = _sag_curve * _max_sag;

        // Apply sag perpendicular to chain direction (downward)
        var _sag_angle = _base_angle + 90;  // Perpendicular
        _link_x += lengthdir_x(_sag_offset, _sag_angle);
        _link_y += lengthdir_y(_sag_offset, _sag_angle);

        // Calculate angle to next link for proper rotation
        var _next_t = ((i + 1) * _sprite_height) / _dist;
        if (_next_t > 1.0) _next_t = 1.0;

        var _next_x = lerp(x1, x2, _next_t);
        var _next_y = lerp(y1, y2, _next_t);
        var _next_sag_curve = 4 * _next_t * (1 - _next_t);
        var _next_sag_offset = _next_sag_curve * _max_sag;
        _next_x += lengthdir_x(_next_sag_offset, _sag_angle);
        _next_y += lengthdir_y(_next_sag_offset, _sag_angle);

        var _link_angle = point_direction(_link_x, _link_y, _next_x, _next_y);

        draw_sprite_ext(
            sprite, 0,
            _link_x, _link_y,
            1, 1,  // No scaling - draw at actual size
            _link_angle,
            c_white, 0.8  // Slightly transparent
        );
    }
}

// Calculate boss center position from bounding box
var _boss_center_x = (bbox_left + bbox_right) / 2;
var _boss_center_y = (bbox_top + bbox_bottom) / 2;

// Draw chains for each auxiliary
for (var i = 0; i < array_length(auxiliaries); i++) {
    var _aux = auxiliaries[i];

    // Skip if auxiliary doesn't exist
    if (!instance_exists(_aux)) continue;

    // Calculate auxiliary center position from bounding box
    var _aux_center_x = (_aux.bbox_left + _aux.bbox_right) / 2;
    var _aux_center_y = (_aux.bbox_top + _aux.bbox_bottom) / 2;

    // Calculate distance and tension from boss center to auxiliary center
    var _dist = point_distance(_boss_center_x, _boss_center_y, _aux_center_x, _aux_center_y);
    var _angle = point_direction(_boss_center_x, _boss_center_y, _aux_center_x, _aux_center_y);
    var _tension_ratio = _dist / chain_max_length;  // 0.0 to 1.0

    // Draw chain with smooth sagging curve from boss center to auxiliary center
    // Tension parameter controls sag: 0.0 = very slack, 1.0 = taut
    draw_chain_segment(_boss_center_x, _boss_center_y, _aux_center_x, _aux_center_y, chain_sprite, _tension_ratio);

    // Update chain data struct (for potential future use)
    chain_data[i].tension = _tension_ratio;
    chain_data[i].angle = _angle;
    chain_data[i].distance = _dist;
}

// ============================================
// DRAW BOSS SPRITE
// ============================================
// Draw boss normally after chains (so boss appears on top)
draw_self();

// ============================================
// CALL PARENT DRAW EVENT
// ============================================
// This handles health bar, status effects, and other parent rendering
event_inherited();
