# Input Icon Sprite Setup Guide

This guide explains how to set up sprite-based icons for the Input library's icon system.

## Overview

You have three sprites for input icons:
- **spr_keyboard** - 79 frames for keyboard keys
- **spr_playstation** - 4 frames for face buttons
- **spr_playstation_extra** - 8 frames for shoulders/triggers/start

## Helper Function

Use `input_icon_sprite(sprite, frame)` to create icon data:

```gml
// Example: Map Cross button to frame 0 of spr_playstation
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face1, input_icon_sprite(spr_playstation, 0));
```

## Configuration Files

Edit these files to map your sprites:
- `/scripts/__InputIconConfigKeyboard/__InputIconConfigKeyboard.gml` - Keyboard icons
- `/scripts/__InputIconConfigPlayStation/__InputIconConfigPlayStation.gml` - PlayStation icons

## PlayStation Button Mapping

### spr_playstation (4 frames)
Determine your frame order by opening the sprite in GameMaker. Typically:
- Frame 0: Cross (gp_face1)
- Frame 1: Circle (gp_face2)
- Frame 2: Square (gp_face3)
- Frame 3: Triangle (gp_face4)

### spr_playstation_extra (8 frames)
Determine your frame order by opening the sprite in GameMaker. Common layouts:
- Frame 0: L1 (gp_shoulderl)
- Frame 1: R1 (gp_shoulderr)
- Frame 2: L2 (gp_shoulderlb)
- Frame 3: R2 (gp_shoulderrb)
- Frame 4: Share/Create (gp_select)
- Frame 5: Options/Start (gp_start)
- Frame 6: L3 (gp_stickl)
- Frame 7: R3 (gp_stickr)

## Example PlayStation Configuration

```gml
// Face buttons (spr_playstation)
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face1, input_icon_sprite(spr_playstation, 0)); //Cross
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face2, input_icon_sprite(spr_playstation, 1)); //Circle
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face3, input_icon_sprite(spr_playstation, 2)); //Square
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face4, input_icon_sprite(spr_playstation, 3)); //Triangle

// Shoulder buttons (spr_playstation_extra)
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_shoulderl,  input_icon_sprite(spr_playstation_extra, 0)); //L1
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_shoulderr,  input_icon_sprite(spr_playstation_extra, 1)); //R1
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_shoulderlb, input_icon_sprite(spr_playstation_extra, 2)); //L2
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_shoulderrb, input_icon_sprite(spr_playstation_extra, 3)); //R2

// Start/Select (spr_playstation_extra)
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_select, input_icon_sprite(spr_playstation_extra, 4)); //Create
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_start,  input_icon_sprite(spr_playstation_extra, 5)); //Options

// Stick clicks (spr_playstation_extra)
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_stickl, input_icon_sprite(spr_playstation_extra, 6)); //L3
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_stickr, input_icon_sprite(spr_playstation_extra, 7)); //R3
```

## Keyboard Frame Mapping

For spr_keyboard (79 frames), you need to map each key to its frame index.

### Creating the Mapping

1. Open `spr_keyboard` in GameMaker IDE
2. Click through each frame (0-78) and note which key it represents
3. Optional: Create a mapping document or spreadsheet for reference
4. Update `__InputIconConfigKeyboard.gml` with the correct frame numbers

### Example Keyboard Configuration

```gml
// Letter keys (example - adjust frame numbers to match your sprite)
InputIconDefineKeyboard("W", input_icon_sprite(spr_keyboard, 22));
InputIconDefineKeyboard("A", input_icon_sprite(spr_keyboard, 0));
InputIconDefineKeyboard("S", input_icon_sprite(spr_keyboard, 18));
InputIconDefineKeyboard("D", input_icon_sprite(spr_keyboard, 3));

// Special keys (example - adjust frame numbers)
InputIconDefineKeyboard(vk_space, input_icon_sprite(spr_keyboard, 45));
InputIconDefineKeyboard(vk_enter, input_icon_sprite(spr_keyboard, 50));
InputIconDefineKeyboard(vk_shift, input_icon_sprite(spr_keyboard, 60));
```

## Drawing Icons in Your UI

When you retrieve an icon with `InputIconGet()`, you'll get back a struct with sprite and frame:

```gml
// Get the icon for a verb
var _icon = InputIconGet(INPUT_VERB.attack);

// Draw the icon
if (is_struct(_icon)) {
    draw_sprite(_icon.sprite, _icon.frame, x, y);
}
// Fallback for unmapped buttons (returns string)
else if (is_string(_icon)) {
    draw_text(x, y, _icon);
}
```

## Testing Your Setup

Create a test object that displays all mapped icons:

```gml
// In Draw event
var _test_verbs = [
    INPUT_VERB.attack,
    INPUT_VERB.interact,
    INPUT_VERB.menu,
    // ... add your verbs
];

var _x = 20;
var _y = 20;

for (var i = 0; i < array_length(_test_verbs); i++) {
    var _icon = InputIconGet(_test_verbs[i]);

    if (is_struct(_icon)) {
        draw_sprite(_icon.sprite, _icon.frame, _x, _y);
    } else {
        draw_text(_x, _y, string(_icon));
    }

    _y += 20;
}
```

## Next Steps

1. Open your sprites in GameMaker and note the frame order
2. Update `/scripts/__InputIconConfigPlayStation/__InputIconConfigPlayStation.gml`
3. Create a frame mapping document for spr_keyboard
4. Update `/scripts/__InputIconConfigKeyboard/__InputIconConfigKeyboard.gml`
5. Test with `InputIconGet()` in your game
