// Debug: Draw pathfinding path
if (global.debug_pathfinding && path_exists(path)) {
    draw_set_color(c_yellow);
    draw_set_alpha(0.5);
    draw_path(path, 0, 0, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// Debug: Draw last seen player position (for ranged enemies)
if (global.debug_pathfinding && is_ranged_attacker && (last_seen_player_x != 0 || last_seen_player_y != 0)) {
    draw_set_color(c_red);
    draw_set_alpha(0.3);
    draw_rectangle(last_seen_player_x - 8, last_seen_player_y - 8, last_seen_player_x + 8, last_seen_player_y + 8, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// Debug: Draw current state above enemy
if (global.debug_pathfinding) {
    var _state_text = "";
    switch(state) {
        case EnemyState.idle: _state_text = "IDLE"; break;
        case EnemyState.wander: _state_text = "WANDER"; break;
        case EnemyState.targeting: _state_text = "TARGETING"; break;
        case EnemyState.attacking: _state_text = "ATTACKING"; break;
        case EnemyState.ranged_attacking: _state_text = "RANGED_ATK"; break;
        case EnemyState.dead: _state_text = "DEAD"; break;
        default: _state_text = "UNKNOWN"; break;
    }

    // Add alarm and path status
    var _has_path = path_exists(path) && path_index == path;
    var _path_active = (path_index != -1 && path_position >= 0 && path_position < 1);
    _state_text += "\nA0:" + string(alarm[0]) + " P:" + (_has_path ? "Y" : "N");
    _state_text += "\nPos:" + string(path_position) + " Spd:" + string(path_speed);

    draw_set_color(c_white);
    draw_text(x, bbox_top - 30, _state_text);
}

// Debug: Draw approach variation visualization
if (global.debug_enemy_approach && instance_exists(obj_player)) {
    // Draw trigger distance circle
    draw_set_color(c_yellow);
    draw_set_alpha(0.2);
    draw_circle(x, y, flank_trigger_distance, true);

    // Draw approach mode and angle
    var _approach_text = approach_mode == "flanking" ? "BEHIND" : "DIRECT";
    if (approach_chosen && flank_offset_angle != 0) {
        _approach_text += " (" + string(round(flank_offset_angle)) + "°)";
    }
    draw_set_color(approach_mode == "flanking" ? c_red : c_green);
    draw_set_alpha(1);
    draw_text(x, bbox_bottom + 4, _approach_text);

    // Draw approach direction line if flanking
    if (approach_mode == "flanking" && approach_chosen && flank_offset_angle != 0) {
        var base_dir = point_direction(x, y, obj_player.x, obj_player.y);
        var approach_dir = base_dir + flank_offset_angle;
        var line_length = 40;
        var line_end_x = x + lengthdir_x(line_length, approach_dir);
        var line_end_y = y + lengthdir_y(line_length, approach_dir);

        draw_set_color(c_red);
        draw_set_alpha(0.7);
        draw_line_width(x, y, line_end_x, line_end_y, 2);
        draw_circle(line_end_x, line_end_y, 4, false);

        // Draw player's facing direction indicator
        var player_facing_angle = 0;
        switch(obj_player.facing_dir) {
            case "down":  player_facing_angle = 90;  break;
            case "right": player_facing_angle = 0;   break;
            case "left":  player_facing_angle = 180; break;
            case "up":    player_facing_angle = 270; break;
        }
        var facing_line_length = 30;
        var facing_end_x = obj_player.x + lengthdir_x(facing_line_length, player_facing_angle);
        var facing_end_y = obj_player.y + lengthdir_y(facing_line_length, player_facing_angle);

        draw_set_color(c_blue);
        draw_set_alpha(0.8);
        draw_line_width(obj_player.x, obj_player.y, facing_end_x, facing_end_y, 3);
        draw_circle(facing_end_x, facing_end_y, 6, false);
    }

    // Reset draw settings
    draw_set_color(c_white);
    draw_set_alpha(1);
}

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
