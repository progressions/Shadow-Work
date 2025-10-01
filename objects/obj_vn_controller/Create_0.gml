ChatterboxLoadFromFile("canopy.yarn");
ChatterboxAddFunction("bg", background_set_index);

chatterbox = ChatterboxCreate();
ChatterboxJump(chatterbox, "Start");
chatterbox_update();

option_index = 0;

size = [0.7, 0.75];					// character sprite scale
color = [c_ltgrey, c_white];		// character sprite blend


