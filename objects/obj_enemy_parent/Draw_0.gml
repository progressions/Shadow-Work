
// Draw shadow first
draw_sprite_ext(spr_shadow, image_index, x, y + 2, 1, 0.5, 0, c_black, 0.3);

draw_self();

// Health bar above enemy
if (hp < hp_total && state != EnemyState.dead) { // Only show when damaged and alive
    var bar_x1 = x - 8;
    var bar_y1 = bbox_top - 8;
    var bar_x2 = x + 8;
    var bar_y2 = bbox_top - 4;

    draw_healthbar(bar_x1, bar_y1, bar_x2, bar_y2, (hp / hp_total) * 100, c_black, c_red, c_lime, 0, true, true);
}

// Status effect icons above enemy
if (array_length(status_effects) > 0 && state != EnemyState.dead) {
    var icon_size = 6;
    var icon_spacing = 8;
    var start_x = x - (array_length(status_effects) * icon_spacing) / 2;
    var icon_y = bbox_top - 18;

    for (var i = 0; i < array_length(status_effects); i++) {
        var effect = status_effects[i];
        var icon_x = start_x + (i * icon_spacing);

        // Draw colored circle for each effect type
        var icon_color = c_white;
        switch(effect.type) {
            case StatusEffectType.burning:
                icon_color = c_red;
                break;
            case StatusEffectType.wet:
                icon_color = c_blue;
                break;
            case StatusEffectType.empowered:
                icon_color = c_yellow;
                break;
            case StatusEffectType.weakened:
                icon_color = c_gray;
                break;
            case StatusEffectType.swift:
                icon_color = c_green;
                break;
            case StatusEffectType.slowed:
                icon_color = c_purple;
                break;
        }

        draw_set_color(icon_color);
        draw_circle(icon_x, icon_y, icon_size / 2, false);

        // Draw duration as a small bar under the icon
        var duration_percent = effect.remaining_duration / effect.data.duration;
        var bar_width = icon_size;
        var bar_height = 1;
        var bar_x1 = icon_x - bar_width / 2;
        var bar_x2 = icon_x + bar_width / 2;
        var bar_y1 = icon_y + icon_size / 2 + 1;
        var bar_y2 = bar_y1 + bar_height;

        draw_set_color(c_black);
        draw_rectangle(bar_x1, bar_y1, bar_x2, bar_y2, false);
        draw_set_color(icon_color);
        draw_rectangle(bar_x1, bar_y1, bar_x1 + (bar_width * duration_percent), bar_y2, false);
    }

    // Reset draw color
    draw_set_color(c_white);
}