var _count = ChatterboxGetOptionCount(chatterbox);

if (ChatterboxIsWaiting(chatterbox) && keyboard_check_pressed(vk_space)) {
	ChatterboxContinue(chatterbox);
	chatterbox_update();
} else if (_count) {
	var key = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
	repeat (1 + (ChatterboxGetOptionConditionBool(chatterbox, wrap(option_index + key, 0, _count - 1)) == false)) {
		option_index = wrap(option_index + key, 0, _count - 1);
	}
	
	if (keyboard_check_pressed(vk_space)) {
		ChatterboxSelect(chatterbox, option_index);
		option_index = 0;
		
		chatterbox_update();
	}
}

if (ChatterboxIsStopped(chatterbox)) {
	instance_destroy();
}