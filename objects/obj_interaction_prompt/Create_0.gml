/// @description Initialize interaction prompt

// Legacy text mode (for backwards compatibility)
text = "[[Space]]";
text_color = c_white;
text_scale = 0.075;

// New verb mode (Input system integration)
use_verb = false;          // When true, use verb + action_text instead of text
verb = -1;                 // INPUT_VERB enum value
action_text = "";          // Action text (e.g., "Open", "Talk")

// Common properties
parent_instance = noone;
offset_y = -18;
font = fnt_pixelify_sans;
