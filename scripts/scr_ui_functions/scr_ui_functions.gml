// ============================================
// UI FUNCTIONS - Drawing helpers and UI utilities
// ============================================

/// @function ui_close_all_menus()
/// @description Close all UI menus, restore audio, and unpause the game
function ui_close_all_menus() {
    // Close all menu layers
    if (layer_exists("PauseLayer")) {
        layer_set_visible("PauseLayer", false);
    }
    if (layer_exists("SettingsLayer")) {
        layer_set_visible("SettingsLayer", false);
    }
    if (layer_exists("SaveLoadLayer")) {
        layer_set_visible("SaveLoadLayer", false);
    }

    // Restore world sounds
    audio_group_set_gain(audiogroup_sfx_world, 1, 0);

    // Unpause the game
    global.game_paused = false;

    // Return to gameplay state
    global.state = GameState.gameplay;

    // Set input debounce to prevent menu-closing button from triggering gameplay actions
    global.input_debounce_frames = 2;
}

// Spawn floating text above an entity
function spawn_floating_text(_x, _y, _text, _color = c_white, _parent_instance = noone) {
    var _floating_text = instance_create_layer(_x, _y, "Instances", obj_floating_text);
    _floating_text.text = _text;
    _floating_text.text_color = _color;

    // Set parent instance to follow
    if (_parent_instance != noone && instance_exists(_parent_instance)) {
        _floating_text.parent_instance = _parent_instance;
        _floating_text.offset_x = _x - _parent_instance.x;
        _floating_text.offset_y = _y - _parent_instance.y;
    }

    return _floating_text;
}

// Spawn damage number with color based on damage type
function spawn_damage_number(_x, _y, _damage_amount, _damage_type = DamageType.physical, _parent_instance = noone) {
    var _color = damage_type_to_color(_damage_type);
    var _text = "-" + string(_damage_amount);
    return spawn_floating_text(_x, _y, _text, _color, _parent_instance);
}

// Spawn immunity indicator text
function spawn_immune_text(_x, _y, _parent_instance = noone) {
    var _floating_text = instance_create_layer(_x, _y, "Instances", obj_floating_text);
    _floating_text.text = "IMMUNE!";
    _floating_text.text_color = c_gray;
    _floating_text.text_scale = 0.12; // Slightly larger than normal damage numbers

    // Set parent instance to follow
    if (_parent_instance != noone && instance_exists(_parent_instance)) {
        _floating_text.parent_instance = _parent_instance;
        _floating_text.offset_x = _x - _parent_instance.x;
        _floating_text.offset_y = _y - _parent_instance.y;
    }

    return _floating_text;
}

// Spawn XP reward text
function spawn_xp_text(_x, _y, _xp_amount, _parent_instance = noone) {
    var _floating_text = instance_create_layer(_x, _y, "Instances", obj_floating_text);
    _floating_text.text = "+" + string(_xp_amount) + " XP";
    _floating_text.text_color = c_yellow;
    _floating_text.text_scale = 0.1; // Scribble scale for readable text size

    // Set parent instance to follow
    if (_parent_instance != noone && instance_exists(_parent_instance)) {
        _floating_text.parent_instance = _parent_instance;
        _floating_text.offset_x = _x - _parent_instance.x;
        _floating_text.offset_y = _y - _parent_instance.y;
    }

    return _floating_text;
}

/// @function ui_show_top_message
/// @description Display a temporary message at the top of the screen
/// @param {string} _text Text to display
/// @param {real} _color Optional colour (default white)
/// @param {real} _display_frames Optional duration in frames before fade-out (default 180)
/// @param {real} _y Optional GUI Y position (default 28)
/// @param {real} _scale Optional Scribble scale (default 0.45)
function ui_show_top_message(_text, _color = c_white, _display_frames = 180, _y = 28, _scale = 0.45) {
    global.ui_top_message = {
        text: string(_text),
        color: _color,
        timer: max(0, _display_frames),
        fade_speed: 0.08,
        alpha: 0,
        y: _y,
        scale: _scale
    };
}

/// @function ui_draw_top_text
/// @description Draw centered Scribble text at the top of the GUI layer
/// @param {string} _text Text to render
/// @param {real} _y GUI-space Y position
/// @param {real} _alpha Alpha multiplier (0-1)
/// @param {real} _color Optional colour (default white)
/// @param {real} _scale Optional Scribble scale (default 0.45)
function ui_draw_top_text(_text, _y, _alpha, _color = c_white, _scale = 0.45) {
    var _message = string(_text);
    if (_message == "") return;

    var _draw_alpha = clamp(_alpha, 0, 1);
    if (_draw_alpha <= 0) return;

    var _gui_width = display_get_gui_width();

    draw_set_alpha(_draw_alpha);
    scribble(_message)
        .starting_format("fnt_quest", _color)
        .align(fa_center, fa_top)
        .scale(_scale)
        .draw(_gui_width * 0.5, _y);
    draw_set_alpha(1);
}

/// @function ui_draw_top_text_with_verb
/// @description Draw centered text with input verb icon at the top of the GUI layer
/// @param {string} _text Text to render with {VERB} placeholder for icon
/// @param {Enum.INPUT_VERB} _verb Input verb to display icon for
/// @param {real} _y GUI-space Y position
/// @param {real} _alpha Alpha multiplier (0-1)
/// @param {real} _color Optional colour (default white)
/// @param {real} _scale Optional Scribble scale (default 0.45)
function ui_draw_top_text_with_verb(_text, _verb, _y, _alpha, _color = c_white, _scale = 0.45) {
    var _message = string(_text);
    if (_message == "") return;

    var _draw_alpha = clamp(_alpha, 0, 1);
    if (_draw_alpha <= 0) return;

    var _gui_width = display_get_gui_width();
    var _icon = InputIconGet(_verb);
    var _icon_scale = 2.0; // Scale for sprite icons (larger for top-of-screen visibility)

    // Split text at {VERB} placeholder
    var _verb_pos = string_pos("{VERB}", _message);
    var _text_before = "";
    var _text_after = "";

    if (_verb_pos > 0) {
        _text_before = string_copy(_message, 1, _verb_pos - 1);
        _text_after = string_delete(_message, 1, _verb_pos + 5); // 5 = length of "{VERB}"
    } else {
        // No {VERB} found, fallback to icon at start
        _text_after = _message;
    }

    // Calculate widths for centering using Scribble's measurement
    var _icon_width = 16;
    var _spacing_before = (_text_before != "") ? 0 : 0; // Space between text and icon
    var _spacing_after = (_text_after != "") ? 16 : 0; // Space between icon and text

    // Measure text widths using Scribble
    var _before_width = 0;
    var _after_width = 0;

    if (_text_before != "") {
        var _temp_before = scribble(_text_before).starting_format("fnt_quest", _color).scale(_scale);
        _before_width = _temp_before.get_width();
    }

    if (_text_after != "") {
        var _temp_after = scribble(_text_after).starting_format("fnt_quest", _color).scale(_scale);
        _after_width = _temp_after.get_width();
    }

    if (is_struct(_icon) && sprite_exists(_icon.sprite)) {
        _icon_width = sprite_get_width(_icon.sprite) * _icon_scale;
    } else if (is_string(_icon)) {
        // For text fallback, measure the actual text
        var _temp_icon = scribble("Press [[" + _icon + "]").starting_format("fnt_quest", _color).scale(_scale);
        _icon_width = _temp_icon.get_width();
    }

    var _total_width = _before_width + _spacing_before + _icon_width + _spacing_after + _after_width;
    var _start_x = (_gui_width * 0.5) - (_total_width * 0.5);

    draw_set_alpha(_draw_alpha);

    // Draw text before icon
    if (_text_before != "") {
        scribble(_text_before)
            .starting_format("fnt_quest", _color)
            .align(fa_left, fa_top)
            .scale(_scale)
            .draw(_start_x, _y);
    }

    var _icon_x = _start_x + _before_width + _spacing_before;

    // Draw icon (sprite or text fallback)
    if (is_struct(_icon) && sprite_exists(_icon.sprite)) {
        // Draw sprite icon centered vertically with text (offset 22px lower)
        draw_sprite_ext(_icon.sprite, _icon.frame, _icon_x + (_icon_width * 0.5), _y + 32, _icon_scale, _icon_scale, 0, c_white, _draw_alpha);
    } else if (is_string(_icon)) {
        // Draw text fallback with "Press [key]"
        scribble("Press [[" + _icon + "]")
            .starting_format("fnt_quest", _color)
            .align(fa_left, fa_top)
            .scale(_scale)
            .draw(_icon_x, _y);
    }

    // Draw text after icon
    if (_text_after != "") {
        scribble(_text_after)
            .starting_format("fnt_quest", _color)
            .align(fa_left, fa_top)
            .scale(_scale)
            .draw(_icon_x + _icon_width + _spacing_after, _y);
    }

    draw_set_alpha(1);
}

function ui_draw_bar(_x, _y, _w, _h, _value, _value_max, _fill_color, _back_color, _border_color) {
    var _max_value = max(1, _value_max);
    var _pct = clamp(_value / _max_value, 0, 1);

    draw_set_color(_back_color);
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);

    draw_set_color(_fill_color);
    draw_rectangle(_x + 1, _y + 1, _x + 1 + (_w - 2) * _pct, _y + _h - 1, false);

    draw_set_color(_border_color);
    draw_rectangle(_x, _y, _x + _w, _y + _h, true);
}

function ui_draw_health_bar(_player, _x, _y, _w, _h, _animation_data = undefined) {
    // If no animation data provided, fall back to simple bar
    if (_animation_data == undefined) {
        ui_draw_bar(_x, _y, _w, _h, _player.hp, _player.hp_total, c_red, make_color_rgb(24, 16, 16), c_black);
        return;
    }

    var _current_hp = _player.hp;
    var _max_hp = _player.hp_total;

    // Initialize animation data if needed
    if (!variable_struct_exists(_animation_data, "previous_hp")) {
        _animation_data.previous_hp = _current_hp;
        _animation_data.displayed_previous_hp = _current_hp;
        _animation_data.damage_delay_timer = 0;
        _animation_data.damage_delay_duration = 30; // 0.5 seconds at 60fps
        _animation_data.animation_speed = 0.01; // How fast the grey bar slides down
    }

    // Check if player took damage
    if (_current_hp < _animation_data.previous_hp) {
        // Player took damage - reset the animation
        _animation_data.displayed_previous_hp = _animation_data.previous_hp;
        _animation_data.damage_delay_timer = _animation_data.damage_delay_duration;
    }

    // Update the damage delay timer
    if (_animation_data.damage_delay_timer > 0) {
        _animation_data.damage_delay_timer--;
    } else {
        // Animate the grey bar sliding down
        if (_animation_data.displayed_previous_hp > _current_hp) {
            _animation_data.displayed_previous_hp = max(_current_hp, _animation_data.displayed_previous_hp - (_max_hp * _animation_data.animation_speed));
        }
    }

    // Update previous_hp for next frame
    _animation_data.previous_hp = _current_hp;

    // Calculate widths
    var _current_percentage = _current_hp / _max_hp;
    var _current_width = _w * _current_percentage;

    var _previous_percentage = _animation_data.displayed_previous_hp / _max_hp;
    var _previous_width = _w * _previous_percentage;

    // Determine health bar color frame
    var _healthbar_frame = 0;
    if (_current_percentage < 0.33) { _healthbar_frame = 2; }
    else if (_current_percentage < 0.66) { _healthbar_frame = 1; }

    // Draw black background
    draw_sprite_stretched(spr_ui_healthbar_filler, 3, _x, _y, _w, _h);

    // Draw grey "previous health" bar (frame 4)
    draw_sprite_stretched(spr_ui_healthbar_filler, 4, _x, _y, _previous_width, _h);

    // Draw current health bar on top
    draw_sprite_stretched(spr_ui_healthbar_filler, _healthbar_frame, _x, _y, _current_width, _h);

    // Draw border
    draw_sprite(spr_ui_healthbar, 0, _x + 1, _y + 1);
}

function ui_draw_xp_bar(_player, _x, _y, _w, _h, _label_x = undefined, _label_y = undefined) {
    ui_draw_bar(_x, _y, _w, _h, _player.xp, _player.xp_to_next, c_aqua, make_color_rgb(12, 20, 32), c_black);

    draw_set_color(c_white);
    var _text_x = is_undefined(_label_x) ? _x + _w + 6 : _label_x;
    var _text_y = is_undefined(_label_y) ? _y - 2 : _label_y;
    draw_text(_text_x, _text_y, "Lv " + string(_player.level));
}

function ui_get_status_effect_color(_effect_type) {
    var _trait_key = status_effect_resolve_trait(_effect_type);
    var _trait_data = status_effect_get_trait_data(_trait_key);
    if (_trait_data != undefined && variable_struct_exists(_trait_data, "ui_color")) {
        return _trait_data.ui_color;
    }
    return c_white;
}

function ui_draw_status_effects(_player, _x, _y, _icon_size, _spacing) {
    if (!instance_exists(_player)) return;

    var _get_traits = method(_player, get_active_timed_trait_data);
    if (_get_traits == undefined) return;

    var _effects = _get_traits();
    if (!is_array(_effects) || array_length(_effects) == 0) return;

    var _visible = [];

    for (var i = 0; i < array_length(_effects); i++) {
        var _effect = _effects[i];
        if (_effect.total <= 0) continue;
        if (_effect.effective_stacks <= 0) continue;

        var _trait_data = status_effect_get_trait_data(_effect.trait);
        if (_trait_data == undefined) continue;

        var _icon_sprite = -1;
        if (variable_struct_exists(_trait_data, "icon_sprite")) {
            _icon_sprite = _trait_data.icon_sprite;
        }

        array_push(_visible, {
            trait: _effect.trait,
            remaining: _effect.remaining,
            total: _effect.total,
            stacks: _effect.effective_stacks,
            color: _trait_data.ui_color ?? c_white,
            icon: _icon_sprite
        });
    }

    for (var j = 0; j < array_length(_visible); j++) {
        var _entry = _visible[j];
        var _icon_x = _x + (j * (_icon_size + _spacing));
        var _icon_y = _y;

        if (_entry.icon != -1 && sprite_exists(_entry.icon)) {
            draw_sprite_ext(_entry.icon, 0, _icon_x, _icon_y, 1, 1, 0, c_white, 1);
        } else {
            draw_set_color(_entry.color);
            draw_rectangle(_icon_x, _icon_y, _icon_x + _icon_size, _icon_y + _icon_size, false);
        }

        var _duration_pct = clamp(_entry.remaining / max(1, _entry.total), 0, 1);
        draw_set_color(c_black);
        draw_rectangle(_icon_x, _icon_y + _icon_size + 1, _icon_x + _icon_size, _icon_y + _icon_size + 3, false);
        draw_set_color(_entry.color);
        draw_rectangle(_icon_x, _icon_y + _icon_size + 1, _icon_x + (_icon_size * _duration_pct), _icon_y + _icon_size + 3, false);

        if (_entry.stacks > 1) {
            draw_set_color(_entry.color);
            draw_text(_icon_x + _icon_size + 2, _icon_y, "x" + string(_entry.stacks));
        }
    }

    draw_set_color(c_white);
}

/// @function show_interaction_prompt(radius, offset_x, offset_y, key, action)
/// @description Manage interaction prompt display based on player proximity
/// @param {real} _radius - Distance from object to show prompt
/// @param {real} _offset_x - X offset from object position
/// @param {real} _offset_y - Y offset from object position (usually negative, like -12)
/// @param {string} _key - Key name to display (e.g., "Space", "E", "F")
/// @param {string} _action - Action text to display (e.g., "Open", "Recruit", "Talk")
///
/// NOTE: This function should only be called when the calling object
/// is the active interactive (global.active_interactive == id)
function show_interaction_prompt(_radius, _offset_x, _offset_y, _key, _action) {
    // Check if player exists and is in range
    if (!instance_exists(obj_player)) {
        // No player, destroy prompt if it exists
        if (instance_exists(interaction_prompt)) {
            instance_destroy(interaction_prompt);
            interaction_prompt = noone;
        }
        return;
    }

    var _dist = point_distance(x, y, obj_player.x, obj_player.y);
    var _in_range = (_dist <= _radius);

    // Build prompt text: "[Key] Action"
    // In Scribble, [[ = literal [
    var _text = "[[" + _key + "] " + _action;

    // Create or update prompt if in range
    if (_in_range) {
        if (!instance_exists(interaction_prompt)) {
            // Create new prompt
            interaction_prompt = instance_create_layer(x + _offset_x, y + _offset_y, "Instances", obj_interaction_prompt);
            interaction_prompt.text = _text;
            interaction_prompt.parent_instance = id;
            interaction_prompt.offset_y = _offset_y;
            interaction_prompt.depth = -9999;
        } else {
            // Update existing prompt text (in case action changed, e.g., "Recruit" -> "Talk")
            interaction_prompt.text = _text;
        }
    }
    // Hide prompt if out of range
    else if (instance_exists(interaction_prompt)) {
        instance_destroy(interaction_prompt);
        interaction_prompt = noone;
    }
}
