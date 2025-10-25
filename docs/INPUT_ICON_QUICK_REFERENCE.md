# Input Icon System - Quick Reference

## Your Sprites

- **spr_keyboard** - 79 frames (keyboard keys)
- **spr_playstation** - 4 frames (Cross, Circle, Square, Triangle)
- **spr_playstation_extra** - 8 frames (L1, R1, L2, R2, Share/Create, Options, L3, R3)

## Quick Setup Steps

### 1. Find Frame Numbers

**For PlayStation sprites:**
- Open `spr_playstation` and `spr_playstation_extra` in GameMaker IDE
- Note which button is in which frame (0, 1, 2, 3, etc.)

**For Keyboard sprite:**
- Open `spr_keyboard` in GameMaker IDE
- Click through frames 0-78 and note which key is in which frame

### 2. Configure Icons

**PlayStation:**
Edit `/scripts/__InputIconConfigPlayStation/__InputIconConfigPlayStation.gml`
- Uncomment the sprite-based configuration sections
- Adjust frame numbers to match your sprite layout
- Comment out or remove the string-based definitions

**Keyboard:**
Edit `/scripts/__InputIconConfigKeyboard/__InputIconConfigKeyboard.gml`
- Uncomment the sprite-based configuration template
- Fill in all 79 frame numbers
- Comment out or remove the string-based definitions

### 3. Use in Your Game

```gml
// Get icon data for a verb
var _icon = InputIconGet(INPUT_VERB.attack);

// Draw it
if (is_struct(_icon)) {
    draw_sprite(_icon.sprite, _icon.frame, x, y);
} else if (is_string(_icon)) {
    draw_text(x, y, _icon); // Fallback for unmapped buttons
}
```

## Helper Function

- `input_icon_sprite(sprite, frame)` - Creates sprite-based icon data

## Example Configuration

```gml
// PlayStation face buttons
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face1, input_icon_sprite(spr_playstation, 0)); //Cross
InputIconDefineGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face2, input_icon_sprite(spr_playstation, 1)); //Circle

// Keyboard keys
InputIconDefineKeyboard("W", input_icon_sprite(spr_keyboard, 22));
InputIconDefineKeyboard(vk_space, input_icon_sprite(spr_keyboard, 45));
```

## Important Notes

- **Icon data is flexible** - can be sprites, strings, or any custom data
- **Configure once** - applies globally to all `InputIconGet()` calls
- **Works with verbs** - icons automatically match player's current input device
- **String fallback** - unmapped buttons return strings by default

## Files Reference

- `/scripts/input_icon_sprite/` - Helper function
- `/scripts/__InputIconConfigKeyboard/` - Keyboard configuration
- `/scripts/__InputIconConfigPlayStation/` - PlayStation configuration
- `/docs/INPUT_ICON_SPRITE_SETUP.md` - Detailed setup guide
