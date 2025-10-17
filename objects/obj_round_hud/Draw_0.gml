draw_self();

// Get sprite dimensions at the start (used throughout draw event)
var _sprite_height = sprite_get_height(round_hud_hp_bar);
var _sprite_width = sprite_get_width(round_hud_hp_bar);

// Draw all HUD elements at the object's GUI position
draw_sprite(round_hud_xp_frame, 0, x+24, y+110);

// Draw XP bar filled from left to right based on player XP
if (instance_exists(obj_player)) {
    var _xp_sprite_height = sprite_get_height(round_hud_xp_bar);
    var _xp_sprite_width = sprite_get_width(round_hud_xp_bar);

    // Calculate fill percentage (0.0 to 1.0)
    var _xp_fill_percent = clamp(obj_player.xp / obj_player.xp_to_next, 0, 1);
    var _xp_fill_width = _xp_sprite_width * _xp_fill_percent;

    // Draw only the filled portion from left to right
    draw_sprite_part(round_hud_xp_bar, 0,
        0,                  // left (start at beginning)
        0,                  // top
        _xp_fill_width,     // width (only filled portion)
        _xp_sprite_height,  // height (full height)
        x + 24,             // x position
        y + 110              // y position
    );
}

draw_sprite(round_hud_hp_bar_bg, 0, x+24, y+20);

// Draw HP bar filled from bottom to top based on player HP
if (instance_exists(obj_player)) {

    // Calculate fill percentage (0.0 to 1.0)
    var _fill_percent = clamp(obj_player.hp / obj_player.hp_total, 0, 1);
    var _fill_height = _sprite_height * _fill_percent;

    // Draw only the filled portion from bottom up
    draw_sprite_part(round_hud_hp_bar, 0,
        0,                                      // left
        _sprite_height - _fill_height,         // top (start from bottom minus fill)
        _sprite_width,                          // width
        _fill_height,                           // height (only filled portion)
        x + 24,                                 // x position
        y + 20 + (_sprite_height - _fill_height)  // y position (aligned to bottom)
    );
}

draw_sprite(round_hud_level, 0, x+20, y+106);

// Draw player level
if (instance_exists(obj_player)) {
    // Draw text at normal size (create a larger font resource if you need bigger text)
    scribble(string(obj_player.level))
		.starting_format("fnt_ui", c_black)
		.scale(0.35)
		.draw(x + 32, y + _sprite_height - 12)

}

// Draw melee loadout weapon slot
draw_sprite(round_hud_melee_slot, 0, x + 20, y + 180);
if (instance_exists(obj_player) && obj_player.loadouts.melee.right_hand != undefined) {
    var _melee_frame = obj_player.loadouts.melee.right_hand.definition.world_sprite_frame;
    draw_sprite_stretched(spr_items, _melee_frame, x + 8, y + _sprite_height + 46, 64, 64);
}

// Draw ranged loadout weapon slot
// draw_sprite(round_hud_arrow_count, 0, x, y);
if (instance_exists(obj_player) && obj_player.loadouts.ranged.right_hand != undefined) {
    var _ranged_frame = obj_player.loadouts.ranged.right_hand.definition.world_sprite_frame;
    draw_sprite_stretched(spr_items, _ranged_frame, x + 8, y + _sprite_height + 90, 64, 64);
}

// Draw dash icon with cooldown visualization
// frame 0: dash is ready
// frame 1: cooldown just started (0-30%)
// frame 2: cooldown is 30% over (30-60%)
// frame 3: cooldown is 60% over (60-100%)
if (instance_exists(obj_player)) {
    var _dash_frame = 0;

    if (obj_player.dash_cooldown > 0) {
        // Calculate cooldown progress (0.0 to 1.0)
        var _progress = (obj_player.dash_cooldown_time - obj_player.dash_cooldown) / obj_player.dash_cooldown_time;

        // Map progress to frame (1, 2, or 3)
        if (_progress < 0.3) {
            _dash_frame = 1; // Just started (0-30%)
        } else if (_progress < 0.6) {
            _dash_frame = 2; // 30-60% complete
        } else {
            _dash_frame = 3; // 60-100% complete
        }
    }

    // Apply blue flash when dash is first triggered (first 10% of cooldown)
    var _dash_color = c_white;
    if (obj_player.dash_cooldown > 0) {
        var _cooldown_percent = obj_player.dash_cooldown / obj_player.dash_cooldown_time;
        if (_cooldown_percent > 0.9) {  // Flash during first 10% of cooldown
            _dash_color = c_aqua;  // Bright blue flash
        }
    }

    draw_sprite_ext(spr_dash_icon, _dash_frame, x + 8, y + _sprite_height + 150, 1, 1, 0, _dash_color, 1);
}

// Build status effect display string
if (instance_exists(obj_player)) {
    var _status_string = "";
    var _status_list = ["burning", "poisoned", "diseased", "cursed", "wet", "bleeding"];

    // Check trait-based status effects (only active timed traits with timer bars)
    if (variable_instance_exists(obj_player, "timed_traits")) {
        for (var i = 0; i < array_length(obj_player.timed_traits); i++) {
            var _entry = obj_player.timed_traits[i];
            var _trait_key = _entry.trait;

            // Only show status effects in our display list
            var _is_status_effect = false;
            for (var j = 0; j < array_length(_status_list); j++) {
                if (_status_list[j] == _trait_key) {
                    _is_status_effect = true;
                    break;
                }
            }

            if (_is_status_effect) {
                var _trait_data = status_effect_get_trait_data(_trait_key);
                if (_trait_data != undefined) {
                    var _name = _trait_data.name ?? string_upper(_trait_key);
                    var _stacks = _entry.stacks_applied;

                    // Add stack count if more than 1 stack
                    if (_stacks > 1) {
                        _name += " x" + string(_stacks);
                    }

                    var _color = _trait_data.ui_color ?? c_white;
                    var _color_value = clamp(round(_color), 0, 16777215);
                    var _color_tag = "[d#" + string(_color_value) + "]";

                    if (_status_string != "") _status_string += "\n";
                    _status_string += _color_tag + _name + "[/c]";
                }
            }
        }
    }

    // Check stunned/staggered variables
    if (obj_player.is_stunned) {
        if (_status_string != "") _status_string += "\n";
        _status_string += "[c_yellow]Stunned[/c_yellow]";
    }

    if (obj_player.is_staggered) {
        if (_status_string != "") _status_string += "\n";
        _status_string += "[#A020F0]Staggered[/c]";  // Purple
    }

    // Draw status effects if any are active
    if (_status_string != "") {
        scribble(_status_string)
            .starting_format("fnt_ui", c_white)
            .scale(0.25)
            .draw(x + 8, y + _sprite_height + 180);
    }
}

// Draw onboarding quest text using Scribble
// Debug: Check quest status
if (global.onboarding_quests.current_quest != undefined) {
	var _quest_text = onboarding_get_current_quest_text();
	var _text_x = display_get_gui_width() / 2;
	var _text_y = 60;  // Below health bars

	// Use Scribble for advanced text rendering with fnt_quest font and alpha
	// Format: [fnt_quest] for font, [c_white] for color
	var _scribble_text = "[fnt_quest][c_white]" + _quest_text;

	draw_set_alpha(onboarding_quest_alpha);
	scribble(_scribble_text)
		.starting_format("fnt_quest", c_white)
		.align(fa_center, fa_top)
		.scale(0.4)
		.draw(_text_x, _text_y);
	draw_set_alpha(1);
}
