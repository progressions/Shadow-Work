draw_self();

var _healthbar_width = 234;
var _current_hp = obj_player.hp;
var _max_hp = obj_player.hp_total;

// Check if player took damage
if (_current_hp < previous_hp) {
    // Player took damage - reset the animation
    displayed_previous_hp = previous_hp;
    damage_delay_timer = damage_delay_duration;
}

// Update the damage delay timer
if (damage_delay_timer > 0) {
    damage_delay_timer--;
} else {
    // Animate the grey bar sliding down
    if (displayed_previous_hp > _current_hp) {
        displayed_previous_hp = max(_current_hp, displayed_previous_hp - (_max_hp * animation_speed));
    }
}

// Update previous_hp for next frame
previous_hp = _current_hp;

// Calculate widths
var _current_percentage = _current_hp / _max_hp;
var _current_width = _healthbar_width * _current_percentage;

var _previous_percentage = displayed_previous_hp / _max_hp;
var _previous_width = _healthbar_width * _previous_percentage;

show_debug_message("health percentage " + string(_current_percentage));

// Determine health bar color frame
var _healthbar_frame = 0;
if (_current_percentage < 0.33) { _healthbar_frame = 2; }
else if (_current_percentage < 0.66) { _healthbar_frame = 1; }

// Draw black background
draw_sprite_stretched(spr_ui_healthbar_filler, 3, x+5, y+5, _healthbar_width, 14);

// Draw grey "previous health" bar (frame 4)
draw_sprite_stretched(spr_ui_healthbar_filler, 4, x+5, y+5, _previous_width, 14);

// Draw current health bar on top
draw_sprite_stretched(spr_ui_healthbar_filler, _healthbar_frame, x+5, y+5, _current_width, 14);

// Draw border
draw_sprite(spr_ui_healthbar, 0, x+6, y+6);