/// @description Debug visualization

// Only draw debug visuals if debug mode is enabled
if (!variable_global_exists("debug_mode")) {
    global.debug_mode = false;
}

if (!global.debug_mode) {
    exit;
}

// Draw formation positions and connections
draw_set_color(c_yellow);
draw_set_alpha(0.7);

for (var i = 0; i < array_length(party_members); i++) {
    var _enemy = party_members[i];
    if (!instance_exists(_enemy)) continue;

    // Get formation position for this enemy
    var _form_pos = get_formation_position(_enemy);
    if (_form_pos != undefined) {
        // Draw circle at formation position
        draw_circle(_form_pos.x, _form_pos.y, 8, true);

        // Draw line from enemy to their formation target
        draw_line(_enemy.x, _enemy.y, _form_pos.x, _form_pos.y);

        // Draw small indicator if this is the leader
        if (_enemy == party_leader) {
            draw_set_color(c_red);
            draw_circle(_form_pos.x, _form_pos.y, 12, true);
            draw_set_color(c_yellow);
        }
    }
}

// Draw party state text
draw_set_color(c_white);
draw_set_alpha(1.0);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Get party state name
var _state_name = "";
switch (party_state) {
    case PartyState.protecting:
        _state_name = "PROTECTING";
        draw_set_color(c_blue);
        break;
    case PartyState.aggressive:
        _state_name = "AGGRESSIVE";
        draw_set_color(c_red);
        break;
    case PartyState.cautious:
        _state_name = "CAUTIOUS";
        draw_set_color(c_orange);
        break;
    case PartyState.desperate:
        _state_name = "DESPERATE";
        draw_set_color(c_purple);
        break;
    case PartyState.emboldened:
        _state_name = "EMBOLDENED";
        draw_set_color(c_lime);
        break;
    case PartyState.retreating:
        _state_name = "RETREATING";
        draw_set_color(c_aqua);
        break;
}

// Draw state text above controller position
draw_text(x, y - 48, "State: " + _state_name);

// Draw member count
draw_set_color(c_white);
var _alive_count = 0;
for (var i = 0; i < array_length(party_members); i++) {
    if (instance_exists(party_members[i]) && party_members[i].hp > 0) {
        _alive_count++;
    }
}
draw_text(x, y - 32, "Members: " + string(_alive_count) + "/" + string(initial_party_size));

// Draw formation name
draw_set_color(c_gray);
draw_text(x, y - 16, "Formation: " + formation_template);

// Draw protection radius if in protecting mode
if (party_state == PartyState.protecting) {
    draw_set_color(c_blue);
    draw_set_alpha(0.3);
    draw_circle(protect_x, protect_y, protect_radius, true);

    // Draw crosshair at protect point
    draw_set_alpha(0.7);
    draw_line(protect_x - 10, protect_y, protect_x + 10, protect_y);
    draw_line(protect_x, protect_y - 10, protect_x, protect_y + 10);
}

// Reset draw settings
draw_set_color(c_white);
draw_set_alpha(1.0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
