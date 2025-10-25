// Feather disable all

/////////////////////
//                 //
//  PlayStation 5  //
//                 //
/////////////////////

// ====================================================================================
// SPRITE-BASED ICONS - Uncomment and adjust frame numbers to use your custom sprites
// ====================================================================================
// Check the frame order in your sprites first:
//   - spr_playstation: 4 frames (face buttons)
//   - spr_playstation_extra: 8 frames (shoulders/triggers/start/L3/R3)
//
// Then replace the string-based definitions below with these sprite-based ones:
//
// Face buttons (spr_playstation)
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face1, input_icon_sprite(spr_playstation, 2)); //Cross
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face2, input_icon_sprite(spr_playstation, 1)); //Circle
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face3, input_icon_sprite(spr_playstation, 3)); //Square
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face4, input_icon_sprite(spr_playstation, 0)); //Triangle
//
// Shoulder buttons (spr_playstation_extra)
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_shoulderl,  input_icon_sprite(spr_playstation_extra, 2)); //L1
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_shoulderr,  input_icon_sprite(spr_playstation_extra, 3)); //R1
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_shoulderlb, input_icon_sprite(spr_playstation_extra, 0)); //L2
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_shoulderrb, input_icon_sprite(spr_playstation_extra, 1)); //R2

// Start button (spr_playstation_extra)
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_start, input_icon_sprite(spr_playstation_extra, 4)); //Options (right button - pause menu)
//
// // Stick clicks (spr_playstation_extra - adjust frame numbers to match your sprite)
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_stickl, input_icon_sprite(spr_playstation_extra, 6)); //L3
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_stickr, input_icon_sprite(spr_playstation_extra, 7)); //R3
// ====================================================================================

// STRING-BASED ICONS (default) - Commented out since using sprite-based icons above
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face1, "cross"   ); //Cross
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face2, "circle"  ); //Circle
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face3, "square"  ); //Square
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face4, "triangle"); //Triangle

// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_shoulderl,  "L1"); //L1
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_shoulderr,  "R1"); //R1
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_shoulderlb, "L2"); //L2
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_shoulderrb, "R2"); //R2
//
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_select, "create"); //Select (left button - no sprite, using string fallback)
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_start,  "options"); //Start

InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_padl, "dpad left" ); //D-pad left
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_padr, "dpad right"); //D-pad right
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_padu, "dpad up"   ); //D-pad up
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_padd, "dpad down" ); //D-pad down

InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, -gp_axislh, "thumbstick l left" );
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5,  gp_axislh, "thumbstick l right");
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, -gp_axislv, "thumbstick l up"   );
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5,  gp_axislv, "thumbstick l down" );
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5,  gp_stickl, "L3"                );

InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, -gp_axisrh, "thumbstick r left" );
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5,  gp_axisrh, "thumbstick r right");
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, -gp_axisrv, "thumbstick r up"   );
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5,  gp_axisrv, "thumbstick r down" );
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5,  gp_stickr, "R3"                );

InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_touchpadbutton, input_icon_sprite(spr_playstation_touchpad, 0)); // Touchpad sprite

//Not available on the PlayStation 5 console itself but available on other platforms
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_extra1, "mic");

//DualSense Edge
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_paddler, "RB");
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_paddlel, "LB");



/////////////////////
//                 //
//  PlayStation 4  //
//                 //
/////////////////////

// ====================================================================================
// SPRITE-BASED ICONS - Uncomment and adjust frame numbers to use your custom sprites
// ====================================================================================
// Use the same sprites and frame numbers as PS5 above
//
// Face buttons (spr_playstation)
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_face1, input_icon_sprite(spr_playstation, 2)); //Cross
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_face2, input_icon_sprite(spr_playstation, 1)); //Circle
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_face3, input_icon_sprite(spr_playstation, 3)); //Square
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_face4, input_icon_sprite(spr_playstation, 0)); //Triangle
//
// Shoulder buttons (spr_playstation_extra)
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_shoulderl,  input_icon_sprite(spr_playstation_extra, 2)); //L1
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_shoulderr,  input_icon_sprite(spr_playstation_extra, 3)); //R1
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_shoulderlb, input_icon_sprite(spr_playstation_extra, 0)); //L2
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_shoulderrb, input_icon_sprite(spr_playstation_extra, 1)); //R2

// Start button (spr_playstation_extra)
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_start, input_icon_sprite(spr_playstation_extra, 4)); //Options (right button - pause menu)
//
// // Stick clicks (spr_playstation_extra)
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_stickl, input_icon_sprite(spr_playstation_extra, 6)); //L3
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_stickr, input_icon_sprite(spr_playstation_extra, 7)); //R3
// ====================================================================================

// STRING-BASED ICONS (default) - Commented out since using sprite-based icons above
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_face1, "cross"   ); //Cross
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_face2, "circle"  ); //Circle
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_face3, "square"  ); //Square
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_face4, "triangle"); //Triangle

// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_shoulderl,  "L1"); //L1
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_shoulderr,  "R1"); //R1
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_shoulderlb, "L2"); //L2
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_shoulderrb, "R2"); //R2
//
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_select, "share"); //Select (left button - no sprite, using string fallback)
// InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_start,  "options"); //Start

InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_padl, "dpad left" ); //D-pad left
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_padr, "dpad right"); //D-pad right
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_padu, "dpad up"   ); //D-pad up
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_padd, "dpad down" ); //D-pad down

InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, -gp_axislh, "thumbstick l left" );
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4,  gp_axislh, "thumbstick l right");
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, -gp_axislv, "thumbstick l up"   );
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4,  gp_axislv, "thumbstick l down" );
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4,  gp_stickl, "L3"                );

InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, -gp_axisrh, "thumbstick r left" );
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4,  gp_axisrh, "thumbstick r right");
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, -gp_axisrv, "thumbstick r up"   );
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4,  gp_axisrv, "thumbstick r down" );
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4,  gp_stickr, "R3"                );

InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_touchpadbutton, input_icon_sprite(spr_playstation_touchpad, 0)); // Touchpad sprite