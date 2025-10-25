var _count = ChatterboxGetOptionCount(chatterbox);

if (ChatterboxIsWaiting(chatterbox) && InputPressed(INPUT_VERB.INTERACT)) {
	ChatterboxContinue(chatterbox);
	chatterbox_update();
} else if (_count) {
	var key = InputPressed(INPUT_VERB.DOWN) - InputPressed(INPUT_VERB.UP);
	repeat (1 + (ChatterboxGetOptionConditionBool(chatterbox, wrap(option_index + key, 0, _count - 1)) == false)) {
		option_index = wrap(option_index + key, 0, _count - 1);
	}

	if (InputPressed(INPUT_VERB.INTERACT)) {
		ChatterboxSelect(chatterbox, option_index);
		option_index = 0;

		chatterbox_update();
	}
}

if (ChatterboxIsStopped(chatterbox)) {
	instance_destroy();
}