/// @description Debug display for AI memory & morale system

// Only draw debug info if party has members
if (array_length(party_members) == 0) exit;

// Calculate recent deaths from memory
var _recent_deaths = 0;
var _death_check_window = 15000; // 15 seconds
for (var i = 0; i < array_length(my_memories); i++) {
    var _mem = my_memories[i];
    if (_mem.type == "EnemyDeath" && (current_time - _mem.timestamp) < _death_check_window) {
        _recent_deaths++;
    }
}

// Get party info
var _alive_count = 0;
for (var i = 0; i < array_length(party_members); i++) {
    if (instance_exists(party_members[i]) && party_members[i].hp > 0) {
        _alive_count++;
    }
}

var _morale_threshold = array_length(party_members) * 0.5;
var _morale_broken = (_recent_deaths >= _morale_threshold);

// Convert party state to string
var _state_str = "Unknown";
switch (party_state) {
    case PartyState.aggressive: _state_str = "AGGRESSIVE"; break;
    case PartyState.cautious: _state_str = "CAUTIOUS"; break;
    case PartyState.desperate: _state_str = "DESPERATE"; break;
    case PartyState.emboldened: _state_str = "EMBOLDENED"; break;
    case PartyState.retreating: _state_str = "RETREATING"; break;
    case PartyState.patrolling: _state_str = "PATROLLING"; break;
    case PartyState.protecting: _state_str = "PROTECTING"; break;
}

// Draw debug overlay in top-right corner
var _x = display_get_gui_width() - 10;
var _y = 150;
var _line_height = 20;

draw_set_halign(fa_right);
draw_set_valign(fa_top);
draw_set_font(-1);

// Background
draw_set_alpha(0.7);
draw_set_color(c_black);
draw_rectangle(_x - 280, _y - 5, _x + 5, _y + (_line_height * 6) + 5, false);
draw_set_alpha(1.0);

// Title
draw_set_color(c_yellow);
draw_text(_x, _y, "PARTY MEMORY SYSTEM");
_y += _line_height;

// Party state (color-coded)
var _state_color = c_white;
if (party_state == PartyState.aggressive || party_state == PartyState.emboldened) {
    _state_color = c_red;
} else if (party_state == PartyState.cautious) {
    _state_color = c_orange;
} else if (party_state == PartyState.desperate) {
    _state_color = c_yellow;
}
draw_set_color(_state_color);
draw_text(_x, _y, "State: " + _state_str);
_y += _line_height;

// Party survival
draw_set_color(c_white);
draw_text(_x, _y, "Party: " + string(_alive_count) + " / " + string(initial_party_size) + " alive");
_y += _line_height;

// Recent deaths (memory-based)
var _death_color = _recent_deaths >= _morale_threshold ? c_red : c_white;
draw_set_color(_death_color);
draw_text(_x, _y, "Recent Deaths: " + string(_recent_deaths) + " (15s window)");
_y += _line_height;

// Morale status
if (_morale_broken) {
    draw_set_color(c_red);
    draw_text(_x, _y, "MORALE BROKEN!");
} else {
    draw_set_color(c_lime);
    draw_text(_x, _y, "Morale OK");
}
_y += _line_height;

// Total memories
draw_set_color(c_gray);
draw_text(_x, _y, "Total Memories: " + string(array_length(my_memories)));

// Reset text alignment
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
