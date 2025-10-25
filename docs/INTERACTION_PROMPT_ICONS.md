# Interaction Prompt Icon System

Integration of the Input library's icon system with interaction prompts, providing automatic keyboard/gamepad adaptive button displays.

## Overview

The interaction prompt system now displays sprite-based icons that automatically adapt to the player's current input device (keyboard or gamepad). When a player switches from keyboard to gamepad (or vice versa), the prompts update instantly to show the correct button.

## Quick Start

### Using Verb-Based Prompts (Recommended)

```gml
// In your interactable object's Create event
interaction_verb = INPUT_VERB.INTERACT;  // Or any Input verb
interaction_action = "Open";

// In Step event (when this is the active interactive)
show_interaction_prompt_verb(interaction_radius, 0, -24, interaction_verb, interaction_action);
```

This displays:
- Gamepad: [Cross button sprite] Open
- Keyboard: [E key sprite] Open (or whatever key is bound to INTERACT)

### Legacy Text-Based Prompts (Deprecated)

```gml
// Old system - still works but doesn't adapt to input device
show_interaction_prompt(interaction_radius, 0, -24, "Space", "Open");
// Always shows: [Space] Open regardless of input device
```

## How It Works

### Automatic Device Detection

The Input library automatically tracks which input device the player last used:
- When player presses a keyboard key → shows keyboard icons
- When player presses a gamepad button → shows gamepad icons
- Switches happen instantly without any code changes needed

### Icon Display

**Sprite icons** (configured in Input icon system):
- PlayStation icons: Cross, Circle, Square, Triangle, L1, R1, L2, R2, Start
- Keyboard icons: Available for all keys (requires mapping in `__InputIconConfigKeyboard`)

**Text fallback** (for unmapped buttons):
- Displays button name in brackets: `[L3]`, `[share]`, `[dpad up]`

## Implementation Guide

### 1. For New Interactive Objects

Inherit from `obj_interactable_parent` and set the verb:

```gml
// In Create event
event_inherited();  // Sets interaction_verb = INPUT_VERB.INTERACT by default

// Override if needed
interaction_verb = INPUT_VERB.ATTACK;  // Use a different verb
interaction_action = "Strike";
```

The Step event code is already handled by parent objects:
- `obj_openable` - containers, chests
- `obj_item_parent` - pickups
- `obj_companion_parent` - companions

### 2. Migrating Existing Objects

**Replace:**
```gml
show_interaction_prompt(radius, 0, -24, "Space", "Open");
```

**With:**
```gml
show_interaction_prompt_verb(radius, 0, -24, INPUT_VERB.INTERACT, "Open");
```

Or use the property from `obj_interactable_parent`:
```gml
show_interaction_prompt_verb(radius, 0, -24, interaction_verb, interaction_action);
```

### 3. Custom Verbs

Create custom verbs for special actions:

```gml
// Example: Different verb for looting vs opening
if (is_dead) {
    interaction_verb = INPUT_VERB.INTERACT;  // E/Cross for loot
    interaction_action = "Loot";
} else {
    interaction_verb = INPUT_VERB.ATTACK;    // Space/Square for attack
    interaction_action = "Attack";
}

show_interaction_prompt_verb(radius, 0, -24, interaction_verb, interaction_action);
```

## Visual Examples

### Gamepad Mode (PlayStation)
```
[Cross sprite icon] Open
[Square sprite icon] Attack
[L1 sprite icon] Shield
```

### Keyboard Mode
```
[E key sprite] Open
[Space key sprite] Attack
[Shift key sprite] Shield
```

### Fallback Mode (unmapped buttons)
```
[L3] Sprint
[touchpad] Map
```

## Properties

### obj_interactable_parent Properties

**interaction_verb** (real) - Input verb to display
- Default: `INPUT_VERB.INTERACT`
- Use any verb from the Input library

**interaction_action** (string) - Action text to display
- Example: `"Open"`, `"Talk"`, `"Recruit"`

**interaction_radius** (real) - Distance for prompt display
- Default: `32` pixels

**interaction_priority** (real) - Selection priority
- Default: `50`
- Higher values = higher priority when multiple interactables overlap

**interaction_key** (string) - DEPRECATED
- Legacy property for backwards compatibility
- Use `interaction_verb` instead

## Functions

### show_interaction_prompt_verb(radius, offset_x, offset_y, verb, action)

Display an input-adaptive interaction prompt.

**Parameters:**
- `radius` (real) - Distance from object to show prompt
- `offset_x` (real) - X offset from object position
- `offset_y` (real) - Y offset from object (usually negative, e.g., -24)
- `verb` (Enum.INPUT_VERB) - Input verb to display icon for
- `action` (string) - Action text (e.g., "Open", "Talk")

**Example:**
```gml
show_interaction_prompt_verb(32, 0, -24, INPUT_VERB.INTERACT, "Open");
```

### show_interaction_prompt(radius, offset_x, offset_y, key, action)

**DEPRECATED** - Legacy text-based prompt (no device adaptation).

**Use `show_interaction_prompt_verb()` instead** for automatic keyboard/gamepad support.

## Customization

### Changing Icon Sprites

To use different icons:
1. Create your sprite with all button frames
2. Edit `/scripts/__InputIconConfigPlayStation/__InputIconConfigPlayStation.gml`
3. Map buttons to your sprite frames using `input_icon_sprite(sprite, frame)`

See `/docs/INPUT_ICON_SPRITE_SETUP.md` for detailed instructions.

### Styling Prompts

Modify `obj_interaction_prompt/Draw_0.gml` to change:
- Text color (`text_color`)
- Text size (`text_scale`)
- Outline/shadow effects (Scribble formatting)
- Icon spacing (`_spacing` variable)

## Best Practices

1. **Use verbs, not hardcoded keys**
   - ✅ `INPUT_VERB.INTERACT`
   - ❌ `"Space"` or `"E"`

2. **Let the Input system handle device detection**
   - Don't manually check `InputPlayerUsingGamepad()`
   - The icon system handles it automatically

3. **Use descriptive action text**
   - ✅ `"Open Chest"`, `"Talk to Villager"`
   - ❌ `"Interact"`, `"Do Thing"`

4. **Keep prompts consistent**
   - Use the same verb for similar actions
   - Example: All "pick up" actions use `INPUT_VERB.INTERACT`

## Troubleshooting

**Prompt shows text instead of sprite:**
- Icon not configured in Input system
- Check `/scripts/__InputIconConfigPlayStation/` and `/scripts/__InputIconConfigKeyboard/`
- Map the button using `input_icon_sprite(sprite, frame)`

**Prompt doesn't update when switching devices:**
- Make sure you're using `show_interaction_prompt_verb()`, not the legacy `show_interaction_prompt()`
- Verify `verb` parameter is an `INPUT_VERB` enum, not a string

**Wrong icon appears:**
- Check verb bindings in Input configuration
- Verify sprite frame numbers in icon config files

## See Also

- `/docs/INPUT_ICON_SPRITE_SETUP.md` - Setting up icon sprites
- `/docs/INPUT_ICON_QUICK_REFERENCE.md` - Quick reference guide
- `/scripts/scr_interaction_prompts/` - Helper functions
