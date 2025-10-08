switch (state) {
	case BreakableState.idle: {
		var _frame_count = max(1, idle_frame_range.end_index - idle_frame_range.start_index + 1);
		idle_anim_timer += idle_anim_speed;
		var _offset = floor(idle_anim_timer) mod _frame_count;
		image_index = idle_frame_range.start_index + _offset;
		break;
	}

	case BreakableState.breaking: {
		var _frame_count = max(1, break_frame_range.end_index - break_frame_range.start_index + 1);
		break_anim_timer += break_anim_speed;
		var _progress = floor(break_anim_timer);
		var _frame = break_frame_range.start_index + _progress;
		if (_frame >= break_frame_range.start_index + _frame_count - 1) {
			image_index = break_frame_range.start_index + _frame_count - 1;
			finish_break();
		} else {
			image_index = clamp(_frame, break_frame_range.start_index, break_frame_range.end_index);
		}
		break;
	}

	default: {
		// Already broken; do nothing
	}
}
