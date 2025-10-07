// Draw VN interface overlay (Draw GUI event)
// Only draws when VN mode is active


if (!global.vn_active) exit;

// Enable texture filtering for smooth text/sprite rendering
gpu_set_tex_filter(true);

var _gui_width = display_get_gui_width();
var _gui_height = display_get_gui_height();

// Draw semi-transparent background overlay
draw_set_alpha(0.6);
draw_set_color(c_black);
draw_rectangle(0, 0, _gui_width, _gui_height, false);
draw_set_alpha(1);

// Draw dialogue box background
draw_set_color(c_dkgray);
draw_rectangle(dialogue_box_x, dialogue_box_y, dialogue_box_x + dialogue_box_width, dialogue_box_y + dialogue_box_height, false);

// Draw dialogue box border
draw_set_color(c_ltgray);
draw_rectangle(dialogue_box_x, dialogue_box_y, dialogue_box_x + dialogue_box_width, dialogue_box_y + dialogue_box_height, true);

// Draw tall portrait on left side (fit inside box with border visible)
// Check for companion portrait first, then intro portrait
var _portrait_sprite = noone;

if (global.vn_companion != undefined && global.vn_companion != noone && instance_exists(global.vn_companion) && global.vn_companion.vn_sprite != undefined) {
	_portrait_sprite = global.vn_companion.vn_sprite;
} else if (variable_global_exists("vn_intro_portrait_sprite") && global.vn_intro_portrait_sprite != noone) {
	_portrait_sprite = global.vn_intro_portrait_sprite;
}

if (_portrait_sprite != noone && sprite_exists(_portrait_sprite)) {
	var _sprite_width = sprite_get_width(_portrait_sprite);
	var _sprite_height = sprite_get_height(_portrait_sprite);

	// Calculate scale to fit portrait inside box (use min to keep it within bounds)
	var _available_width = portrait_width - 4;  // Leave space for border
	var _available_height = portrait_height - 4;
	var _scale = min(_available_width / _sprite_width, _available_height / _sprite_height);

	// Draw portrait centered in left panel
	var _draw_x = portrait_x + (portrait_width / 2);
	var _draw_y = portrait_y + (portrait_height / 2);
	draw_sprite_ext(_portrait_sprite, 0, _draw_x, _draw_y, _scale, _scale, 0, c_white, 1);

	// Draw portrait border
	draw_set_color(c_white);
	draw_rectangle(portrait_x, portrait_y, portrait_x + portrait_width, portrait_y + portrait_height, true);
}

// Draw name tag above dialogue box
if (current_speaker != "") {
	//draw_set_font(fnt_arial);
	draw_set_font(fnt_determination_normal) // fnt_pixelify_sans);

	var _name_width = string_width(current_speaker) + 60;

	draw_set_color(c_dkgray);
	draw_rectangle(name_tag_x, name_tag_y, name_tag_x + _name_width, name_tag_y + name_tag_height, false);

	draw_set_color(c_white);
	draw_rectangle(name_tag_x, name_tag_y, name_tag_x + _name_width, name_tag_y + name_tag_height, true);

	draw_set_color(c_white);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text(name_tag_x + _name_width / 2, name_tag_y + name_tag_height / 2, current_speaker);
}

// Draw dialogue text
//draw_set_font(fnt_arial);
draw_set_font(fnt_determination_normal);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text_ext(text_x, text_y, current_text, 20, text_width);

// Draw choices if available (stacked above dialogue box on right side)
if (global.vn_chatterbox != undefined) {
	var _option_count = ChatterboxGetOptionCount(global.vn_chatterbox);

	if (_option_count > 0) {
		var _choice_y = choice_start_y;

		// Draw choices in reverse order so first option appears at top
		for (var i = _option_count - 1; i >= 0; i--) {
			var _option_text = ChatterboxGetOption(global.vn_chatterbox, i);

			// Calculate choice position (stack upward)
			_choice_y -= (choice_height + choice_padding);

			// Highlight selected choice
			if (i == selected_choice) {
				draw_set_color(c_ltgray);
			} else {
				draw_set_color(c_dkgray);
			}

			draw_rectangle(choice_x, _choice_y, choice_x + choice_width, _choice_y + choice_height, false);

			// Draw choice border
			draw_set_color(c_white);
			draw_rectangle(choice_x, _choice_y, choice_x + choice_width, _choice_y + choice_height, true);

			// Draw choice text (black if highlighted, white if not)
			if (i == selected_choice) {
				draw_set_color(c_black);
			} else {
				draw_set_color(c_white);
			}
			draw_set_halign(fa_left);
			draw_set_valign(fa_middle);
			draw_set_font(fnt_determination_normal);
			draw_text(choice_x + 20, _choice_y + choice_height / 2, _option_text);
		}
	} else {
		// Show "continue" indicator
		if (ChatterboxIsWaiting(global.vn_chatterbox)) {
			draw_set_color(c_white);
			draw_set_halign(fa_right);
			draw_set_valign(fa_bottom);
			draw_set_font(fnt_determination_normal);
			draw_text(dialogue_box_x + dialogue_box_width - 20, dialogue_box_y + dialogue_box_height - 10, "[[ENTER/E]");
		}
	}
}

// Reset draw settings
draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
gpu_set_tex_filter(false);
