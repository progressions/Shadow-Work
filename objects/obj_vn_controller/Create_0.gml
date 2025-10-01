// VN Overlay Controller - Persistent across rooms
// Only draws when global.vn_active == true

// UI configuration - Portrait on left, dialogue/choices on right
var _gui_width = display_get_gui_width();
var _gui_height = display_get_gui_height();

// Portrait configuration (left side, tall)
portrait_width = 400;
portrait_height = _gui_height - 40;
portrait_x = 20;
portrait_y = 20;

// Dialogue box (right side)
dialogue_box_x = portrait_x + portrait_width + 20;
dialogue_box_width = _gui_width - dialogue_box_x - 20;
dialogue_box_height = 200;
dialogue_box_y = _gui_height - dialogue_box_height - 20;

// Name tag above dialogue box
name_tag_height = 40;
name_tag_y = dialogue_box_y - name_tag_height - 10;
name_tag_x = dialogue_box_x;

// Text positioning
text_x = dialogue_box_x + 20;
text_y = dialogue_box_y + 20;
text_width = dialogue_box_width - 40;

// Choice configuration (fill space between top and name tag)
choice_height = 50;
choice_padding = 10;
choice_width = dialogue_box_width;
choice_x = dialogue_box_x;
choice_start_y = name_tag_y - 10; // Start just above name tag
selected_choice = 0;

// State
current_speaker = "";
current_text = "";
