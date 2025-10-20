// Call parent Create event to initialize button properties
event_inherited();

// Slider-specific state
value = 0.5;           // Current value (0.0 to 1.0)
min_value = 0.0;
max_value = 1.0;
step_size = 0.05;      // 5% steps = 20 notches
is_selected = false;   // Whether this slider is currently selected in navigation

// Initialize from global audio config for audio control sliders
if (variable_global_exists("audio_config")) {
	if (button_id == 0) {
		// Master volume slider
		value = global.audio_config.master_volume;
	} else if (button_id == 2) {
		// Music volume slider
		value = global.audio_config.music_volume;
	} else if (button_id == 4) {
		// SFX volume slider
		value = global.audio_config.sfx_volume;
	}
}

// Sprites
bar_sprite = spr_slider_bar;
handle_sprite = spr_slider_handle;

// Adjust the slider value by one step
adjust_value = function(_direction) {
	// _direction: -1 for left (A), +1 for right (D)
	value += _direction * step_size;
	value = clamp(value, min_value, max_value);

	// Round to nearest step to avoid floating point errors
	value = round(value / step_size) * step_size;
	value = clamp(value, min_value, max_value);
}

// Update visual appearance based on selection state
update_slider_visuals = function() {
	// Bar sprite frame based on selection
	// Frame 0: normal, Frame 1: selected/highlighted
	image_index = is_selected ? 1 : 0;
}

// Custom visual update for UI controller to call
// This overrides the default button highlight behavior
custom_visual_update = function(_is_selected) {
	is_selected = _is_selected;
	update_slider_visuals();
}

// Initialize visuals
update_slider_visuals();
