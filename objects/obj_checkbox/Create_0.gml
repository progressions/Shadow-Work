// Call parent Create event to initialize button properties
event_inherited();

// Checkbox-specific state
enabled = false;
is_selected = false; // Whether this checkbox is currently selected in navigation

// Initialize from global audio config for audio control checkboxes
if (variable_global_exists("audio_config")) {
	if (button_id == 4) {
		// Music checkbox
		enabled = global.audio_config.music_enabled;
	} else if (button_id == 5) {
		// SFX checkbox
		enabled = global.audio_config.sfx_enabled;
	}
}

// Toggle the checkbox state
toggle = function() {
	enabled = !enabled;
	update_checkbox_visuals();
}

// Update visual appearance based on enabled AND selection state
// Frame 0: Unchecked, not selected
// Frame 1: Checked, not selected
// Frame 2: Unchecked, selected (highlighted)
// Frame 3: Checked, selected (highlighted)
update_checkbox_visuals = function() {
	var _base_frame = is_selected ? 2 : 0;
	var _enabled_offset = enabled ? 1 : 0;
	image_index = _base_frame + _enabled_offset;
}

// Custom visual update for UI controller to call
// This overrides the default button highlight behavior
custom_visual_update = function(_is_selected) {
	is_selected = _is_selected;
	update_checkbox_visuals();
}

// Initialize visuals
update_checkbox_visuals();