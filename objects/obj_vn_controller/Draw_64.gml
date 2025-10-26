// Draw VN interface overlay (Draw GUI event)
// Only draws when VN mode is active


if (!global.vn_active) exit;

// Enable texture filtering for smooth text/sprite rendering
gpu_set_tex_filter(true);

var _gui_width = display_get_gui_width();
var _gui_height = display_get_gui_height();

// Recalculate UI positions based on current GUI dimensions
// Portrait configuration (left side, tall)
var _portrait_width = 400;
var _portrait_height = _gui_height - 40;
var _portrait_x = 20;
var _portrait_y = 20;

// Dialogue box (right side)
var _dialogue_box_x = _portrait_x + _portrait_width + 20;
var _dialogue_box_width = _gui_width - _dialogue_box_x - 20;
var _dialogue_box_height = 200;
var _dialogue_box_y = _gui_height - _dialogue_box_height - 20;

// Name tag above dialogue box
var _name_tag_height = 40;
var _name_tag_y = _dialogue_box_y - _name_tag_height - 10;
var _name_tag_x = _dialogue_box_x;

// Text positioning
var _text_x = _dialogue_box_x + 20;
var _text_y = _dialogue_box_y + 20;
var _text_width = _dialogue_box_width - 40;

// Choice configuration (fill space between top and name tag)
var _choice_height = 50;
var _choice_padding = 10;
var _choice_top_padding = 15; // Padding at top of choices container
var _choice_highlight_margin = 8; // Left/right margin for highlight rectangle
var _choice_width = _dialogue_box_width;
var _choice_x = _dialogue_box_x;
var _choice_start_y = _name_tag_y - 10; // Start just above name tag

// Draw semi-transparent background overlay
draw_set_alpha(0.6);
draw_set_color(c_black);
draw_rectangle(0, 0, _gui_width, _gui_height, false);
draw_set_alpha(1);

// Draw dialogue box with 9-slice sprite
draw_sprite_stretched(spr_ui_box, 0, _dialogue_box_x, _dialogue_box_y, _dialogue_box_width, _dialogue_box_height);

// Draw portrait on left side - bottom aligned with dialogue box
// Priority: video > companion portrait > intro portrait
var _portrait_sprite = noone;
var _has_video = (vn_video != -1);

// Calculate bottom alignment position (match dialogue box bottom)
var _bottom_y = _dialogue_box_y + _dialogue_box_height;
var _available_width = _portrait_width;

// Check for video first
if (_has_video) {
	var _video_data = video_draw();
	var _video_status = _video_data[0];

	if (_video_status == 0) {
		// Video is playing successfully
		var _video_surface = _video_data[1];

		if (surface_exists(_video_surface)) {
			var _surf_width = surface_get_width(_video_surface);
			var _surf_height = surface_get_height(_video_surface);

			// Calculate scale to fit video width (let height be determined by aspect ratio)
			var _scale = _available_width / _surf_width;

			// Calculate scaled dimensions
			var _scaled_width = _surf_width * _scale;
			var _scaled_height = _surf_height * _scale;

			// Position: centered horizontally, bottom-aligned
			var _draw_x = _portrait_x;
			var _draw_y = _bottom_y - _scaled_height;

			// Draw video surface
			draw_surface_ext(_video_surface, _draw_x, _draw_y, _scale, _scale, 0, c_white, 1);

			// Draw portrait border around the actual video dimensions
			draw_set_color(c_white);
			draw_rectangle(_draw_x, _draw_y, _draw_x + _scaled_width, _draw_y + _scaled_height, true);
		}
	}
}
// If no video, check for sprite portrait
else {
	if (global.vn_companion != undefined && global.vn_companion != noone && instance_exists(global.vn_companion) && global.vn_companion.vn_sprite != undefined) {
		_portrait_sprite = global.vn_companion.vn_sprite;
	} else if (variable_global_exists("vn_intro_portrait_sprite") && global.vn_intro_portrait_sprite != noone) {
		_portrait_sprite = global.vn_intro_portrait_sprite;
	}

	if (_portrait_sprite != noone && sprite_exists(_portrait_sprite)) {
		var _sprite_width = sprite_get_width(_portrait_sprite);
		var _sprite_height = sprite_get_height(_portrait_sprite);

		// Calculate scale to fit width (let height be determined by aspect ratio)
		var _scale = _available_width / _sprite_width;

		// Calculate scaled dimensions
		var _scaled_width = _sprite_width * _scale;
		var _scaled_height = _sprite_height * _scale;

		// Position: left edge aligned, bottom-aligned
		var _draw_x = _portrait_x;
		var _draw_y = _bottom_y - _scaled_height;

		// Draw portrait sprite
		draw_sprite_ext(_portrait_sprite, 0, _draw_x, _draw_y, _scale, _scale, 0, c_white, 1);

		// Draw portrait border around actual sprite dimensions
		draw_set_color(c_white);
		draw_rectangle(_draw_x, _draw_y, _draw_x + _scaled_width, _draw_y + _scaled_height, true);
	}
}

// Draw name tag above dialogue box
if (current_speaker != "") {
	//draw_set_font(fnt_arial);
	draw_set_font(fnt_vn) // fnt_pixelify_sans);

	var _name_width = string_width(current_speaker) + 60;

	// Draw name tag with 9-slice sprite
	draw_sprite_stretched(spr_ui_box, 0, _name_tag_x, _name_tag_y, _name_width, _name_tag_height);

	draw_set_color(c_white);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);

	// Draw name centered in name box
	var _name_center_x = _name_tag_x + _name_width / 2;
	var _name_center_y = _name_tag_y + _name_tag_height / 2;

	scribble(current_speaker)
		.starting_format("fnt_vn", c_white)
		.align(fa_center, fa_middle)
		.scale(0.5)
		.draw(_name_center_x, _name_center_y)
}

// Draw dialogue text with Scribble + typist animation
var _dialogue_element = scribble(current_text, dialogue_text_cache_key)
	.starting_format("fnt_vn", c_white)
	.wrap(_text_width)
	.align(fa_left, fa_top)
	.line_spacing("120%")
	.scale(0.5)
	.pre_update_typist(dialogue_typist)
	.draw(_text_x, _text_y, dialogue_typist);

// Reset draw state for subsequent elements
draw_set_color(c_white);
draw_set_font(fnt_vn);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Draw choices if available (stacked above dialogue box on right side)
if (global.vn_chatterbox != undefined) {
	var _option_count = ChatterboxGetOptionCount(global.vn_chatterbox);

	if (_option_count > 0) {
		// Calculate total height needed for all choices (including top padding)
		var _total_choices_height = (_option_count * _choice_height) + ((_option_count - 1) * _choice_padding) + _choice_top_padding;
		var _choices_container_y = _choice_start_y - _total_choices_height;

		// Draw single container box for all choices
		draw_sprite_stretched(spr_ui_box, 0, _choice_x, _choices_container_y, _choice_width, _total_choices_height);

		// Draw choices in reverse order so first option appears at top
		var _choice_y = _choice_start_y;
		for (var i = _option_count - 1; i >= 0; i--) {
			var _option_text = ChatterboxGetOption(global.vn_chatterbox, i);

			// Calculate choice position (stack upward, accounting for top padding on first item)
			_choice_y -= (_choice_height + _choice_padding);

			// Draw solid rectangle behind selected choice (with left/right margins)
			if (i == selected_choice) {
				draw_set_color(c_ltgray);
				draw_rectangle(
					_choice_x + _choice_highlight_margin,
					_choice_y,
					_choice_x + _choice_width - _choice_highlight_margin,
					_choice_y + _choice_height,
					false
				);
			}

			// Draw choice text (black if highlighted, white if not)
			var _text_color = (i == selected_choice) ? c_black : c_white;

			draw_set_halign(fa_left);
			draw_set_valign(fa_middle);
			draw_set_font(fnt_vn);

			scribble(_option_text)
				.starting_format("fnt_vn", _text_color)
				.align(fa_left, fa_middle)
				.scale(0.5)
				.draw(_choice_x + 20, _choice_y + _choice_height / 2);
		}
	} else {
		// Show "continue" indicator
		if (ChatterboxIsWaiting(global.vn_chatterbox) && (dialogue_typist == undefined || dialogue_typist.get_state() >= 1)) {
			draw_set_color(c_white);
			draw_set_halign(fa_right);
			draw_set_valign(fa_bottom);
			draw_set_font(fnt_vn);

			scribble("[[ENTER/E]]")
				.starting_format("fnt_vn", c_white)
				.align(fa_right, fa_bottom)
				.scale(0.5)
				.draw(_dialogue_box_x + _dialogue_box_width - 20, _dialogue_box_y + _dialogue_box_height - 10);
		}
	}
}

// Reset draw settings
draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
gpu_set_tex_filter(false);
