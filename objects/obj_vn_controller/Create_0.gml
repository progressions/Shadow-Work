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
current_raw_content = "";
current_line_metadata = undefined;
dialogue_typist_speed = 1.4;
dialogue_typist_smoothness = 0.6;

dialogue_typist = scribble_typist();
dialogue_typist
	.in(dialogue_typist_speed, dialogue_typist_smoothness)
	.character_delay_clear()
	.character_delay_add(".", 140)
	.character_delay_add("!", 160)
	.character_delay_add("?", 160)
	.character_delay_add(",", 90)
	.character_delay_add("!!", 200)
	.character_delay_add("??", 200)
	.character_delay_add("!?", 200)
	.character_delay_add("?!", 200);

dialogue_text_uid = 0;
dialogue_text_cache_key = "vn_line:0";

dialogue_typist_sound_names = [
	"snd_vn_typing_1",
	"snd_vn_typing_2",
	"snd_vn_typing_3",
	"snd_vn_typing_4"
];
dialogue_typist_sound_bank = [];
dialogue_typist_sound_active = false;
dialogue_typist_gain = -1;
dialogue_typist_base_volume = 0.05;
dialogue_typist_pitch_min = 0.95;
dialogue_typist_pitch_max = 1.05;
dialogue_typist_sound_exceptions = " .,!?";
dialogue_typist_sound_interrupt = true;
dialogue_typist_sound_last_index = -1;

var _sound_name_count = array_length(dialogue_typist_sound_names);
if (_sound_name_count > 0) {
	for (var _i = 0; _i < _sound_name_count; ++_i) {
		var _asset_name = dialogue_typist_sound_names[_i];
		if (!is_string(_asset_name)) continue;

		var _sound_id = asset_get_index(_asset_name);
		if ((_sound_id != -1) && audio_exists(_sound_id)) {
			array_push(dialogue_typist_sound_bank, _sound_id);
		}
	}
}

dialogue_typist.execution_scope(id);
dialogue_typist.function_per_char(method(self, function(_scope, _char_index, _typist) {
	if (!dialogue_typist_sound_active) exit;
	if (dialogue_typist_gain <= 0) exit;

	var _count = array_length(dialogue_typist_sound_bank);
	if (_count <= 0) exit;

	var _sound_idx = irandom(_count - 1);
	if ((_count > 1) && (_sound_idx == dialogue_typist_sound_last_index)) {
		_sound_idx = (_sound_idx + 1) mod _count;
	}
	dialogue_typist_sound_last_index = _sound_idx;

	var _sound_asset = dialogue_typist_sound_bank[_sound_idx];
	play_sfx(_sound_asset, dialogue_typist_gain);
}));
