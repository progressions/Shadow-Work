
// Draw shadow first
draw_sprite_ext(spr_shadow, image_index, x, y + 2, 1, 0.5, 0, c_black, 0.3);

draw_self();

// Health bar above enemy
if (hp < hp_total && state != EnemyState.dead) { // Only show when damaged and alive
    var bar_x1 = x - 8;
    var bar_y1 = bbox_top - 8;
    var bar_x2 = x + 8;
    var bar_y2 = bbox_top - 6;

    draw_healthbar(bar_x1, bar_y1, bar_x2, bar_y2, (hp / hp_total) * 100, c_black, c_red, c_lime, 0, true, false);
}

// Status effect duration bars above enemy (no icons)
if (array_length(status_effects) > 0 && state != EnemyState.dead) {
    var bar_width = 16;
    var bar_height = 2;
    var bar_spacing = 1;

    // Count non-permanent effects for positioning
    var non_permanent_count = 0;
    for (var i = 0; i < array_length(status_effects); i++) {
        if (!status_effects[i].is_permanent) {
            non_permanent_count++;
        }
    }

    if (non_permanent_count > 0) {
        var total_height = (non_permanent_count * (bar_height + bar_spacing)) - bar_spacing;
        var start_y = bbox_top - 12 - total_height;
        var bar_index = 0;

        for (var i = 0; i < array_length(status_effects); i++) {
            var effect = status_effects[i];

            // Skip permanent effects
            if (effect.is_permanent) {
                continue;
            }

            var bar_y = start_y + (bar_index * (bar_height + bar_spacing));
            var bar_x1 = x - bar_width / 2;
            var bar_x2 = x + bar_width / 2;
            var bar_y1 = bar_y;
            var bar_y2 = bar_y + bar_height;

            // Determine color for each effect type
            var bar_color = c_white;
            switch(effect.type) {
                case StatusEffectType.burning:
                    bar_color = c_red;
                    break;
                case StatusEffectType.wet:
                    bar_color = c_blue;
                    break;
                case StatusEffectType.empowered:
                    bar_color = c_yellow;
                    break;
                case StatusEffectType.weakened:
                    bar_color = c_gray;
                    break;
                case StatusEffectType.swift:
                    bar_color = c_green;
                    break;
                case StatusEffectType.slowed:
                    bar_color = c_purple;
                    break;
            }

            // Draw duration bar
            var duration_percent = effect.remaining_duration / effect.data.duration;
            draw_set_color(c_black);
            draw_rectangle(bar_x1, bar_y1, bar_x2, bar_y2, false);
            draw_set_color(bar_color);
            draw_rectangle(bar_x1, bar_y1, bar_x1 + (bar_width * duration_percent), bar_y2, false);

            bar_index++;
        }

        // Reset draw settings
        draw_set_color(c_white);
        draw_set_alpha(1);
    }
}

// Ensure alpha is always reset at end of draw
draw_set_alpha(1);