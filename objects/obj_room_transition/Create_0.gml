// Room Transition Object
// Set these variables in Instance Creation Code for each transition

target_room = undefined;  // Which room to go to
target_x = -1;           // Where player spawns in new room (-1 = keep current x)
target_y = -1;           // Where player spawns in new room (-1 = keep current y)

triggered = false;       // Prevent multiple collision triggers

// Visual indicator (optional - you can disable sprite in room editor)
image_alpha = 0.3;  // Semi-transparent so you can see it while editing
