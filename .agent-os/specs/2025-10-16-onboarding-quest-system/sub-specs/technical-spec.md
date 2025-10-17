# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-16-onboarding-quest-system/spec.md

> Created: 2025-10-16
> Version: 1.0.0

## Technical Requirements

### 1. Quest Definition System
- Extend existing quest system to support onboarding quest type with simple trigger-based resolution
- Store quest definitions in centralized location (ideally Yarn dialogue files for easy editing)
- Each quest definition includes: quest_id, display_text, trigger_type, trigger_condition, marker_location (optional)

### 2. HUD Rendering
- Use Scribble text renderer for advanced text rendering with fnt_quest font
- Add draw code to display current onboarding quest text (stored in global state)
- Position text centered near top of screen (below health/stamina bars if present)
- Use sentence case formatting for display text
- Support color and styling through Scribble tags
- Auto-update display when quest state changes (completion, advancement)

### 3. Trigger Detection
- Hook into existing game systems to detect when tutorial quest conditions are met:
  - **Input System** - Detect key presses (T for torch, WASD for movement)
  - **Interaction System** - Detect chest opening, NPC dialogue start
  - **Inventory System** - Detect item pickup, equipment changes
  - **Combat System** - Detect attack execution, enemy kill
- Call quest resolution function when trigger condition satisfied

### 4. Marker Rendering
- Create quest marker display system with animated sprite rendering
- Support optional off-screen arrow indicators pointing toward marker location
- Marker sprite automatically animates based on sprite frame tags
- Automatically destroy marker when associated quest completes

### 5. Save/Load Integration
- Serialize onboarding quest completion flags using existing obj_persistent_parent system
- Store current active quest index in global.quest_flags
- Restore quest state on game load, displaying correct next uncompleted quest

### 6. Yarn Integration
- Support defining quest text and sequence in Yarn dialogue files
- Create Yarn node structure for onboarding quests with trigger metadata
- Parse Yarn nodes to populate quest definitions at game start

### 7. Quest Notification Sounds
- Play "quest available" sound effect when new quest displays
- Play "quest resolved" sound effect when current quest completes
- Use existing play_sfx() system for consistent sound playback
- Sound effects should be short, non-intrusive notification chimes

### 8. Quest XP Rewards
- Award XP to player upon quest completion
- Each quest definition specifies xp_reward value (configurable per quest)
- Use existing player XP system to apply reward
- Display XP reward in floating text or HUD notification (optional)

## Approach

### Quest State Management
```gml
// Global state structure
global.onboarding_quests = {
    active_quest_index: 0,
    quest_sequence: [],           // Array of quest definitions
    current_quest: undefined,     // Current active quest struct
    all_completed: false
};

// Quest definition struct
{
    quest_id: "onboarding_light_torch",
    display_text: "It's dark! Press T to light a torch.",
    trigger_type: "key_press",
    trigger_condition: ord("T"),
    xp_reward: 50,                 // XP awarded on completion
    marker_location: undefined,    // {x, y, room} or undefined
    completed: false
}
```

### HUD Rendering (obj_hud or obj_game_controller Draw GUI event)
```gml
// Draw current quest objective using Scribble
if (global.onboarding_quests.current_quest != undefined) {
    var _quest = global.onboarding_quests.current_quest;

    var _text_x = display_get_gui_width() / 2;
    var _text_y = 60;  // Below health bars

    // Use Scribble for advanced text rendering with fnt_quest font
    // Format: [fnt_quest] for font selection, [c_white] for color, [center] for alignment
    var _scribble_text = "[fnt_quest][c_white]" + _quest.display_text;

    scribble(_scribble_text)
        .align(fa_center, fa_top)
        .draw(_text_x, _text_y);
}
```

### Trigger Detection Integration
```gml
// Example: Input system hook (obj_player Step event or input handler)
if (keyboard_check_pressed(ord("T"))) {
    // Existing torch lighting code...

    // Check onboarding quest trigger
    onboarding_check_trigger("key_press", ord("T"));
}

// Example: Inventory system hook (inventory_add_item function)
function inventory_add_item(item_key, quantity) {
    // Existing inventory add code...

    // Check onboarding quest trigger
    onboarding_check_trigger("item_pickup", item_key);
}
```

### Quest Resolution and Advancement
```gml
// Function to check and resolve quests
function onboarding_check_trigger(trigger_type, trigger_value) {
    var _quest = global.onboarding_quests.current_quest;

    if (_quest == undefined || _quest.completed) return;

    if (_quest.trigger_type == trigger_type && _quest.trigger_condition == trigger_value) {
        onboarding_complete_quest(_quest.quest_id);
    }
}

// Function to complete quest and advance sequence
function onboarding_complete_quest(quest_id) {
    var _quest = global.onboarding_quests.current_quest;

    if (_quest == undefined || _quest.quest_id != quest_id) return;

    // Mark completed
    _quest.completed = true;

    // Award XP
    if (instance_exists(obj_player) && variable_instance_exists(_quest, "xp_reward")) {
        obj_player.xp += _quest.xp_reward;
        // Show floating text for XP reward
        spawn_floating_text(obj_player.x, obj_player.y, "+" + string(_quest.xp_reward) + " XP", c_yellow);
    }

    // Play quest resolved sound
    play_sfx(snd_onboarding_quest_resolved, 1);

    // Advance to next quest
    global.onboarding_quests.active_quest_index++;

    var _quest_count = array_length(global.onboarding_quests.quest_sequence);

    if (global.onboarding_quests.active_quest_index >= _quest_count) {
        // All quests complete
        global.onboarding_quests.all_completed = true;
        global.onboarding_quests.current_quest = undefined;
    } else {
        // Load next quest
        global.onboarding_quests.current_quest = global.onboarding_quests.quest_sequence[global.onboarding_quests.active_quest_index];

        // Play quest available sound for new quest
        play_sfx(snd_onboarding_quest_available, 1);
    }
}
```

### Save/Load Implementation
```gml
// Serialize (in obj_game_controller or save system)
function serialize_onboarding_state() {
    return {
        active_quest_index: global.onboarding_quests.active_quest_index,
        all_completed: global.onboarding_quests.all_completed
    };
}

// Deserialize (in load system)
function deserialize_onboarding_state(data) {
    global.onboarding_quests.active_quest_index = data.active_quest_index;
    global.onboarding_quests.all_completed = data.all_completed;

    // Restore current quest
    if (!global.onboarding_quests.all_completed) {
        global.onboarding_quests.current_quest = global.onboarding_quests.quest_sequence[data.active_quest_index];
    }
}
```

### Quest Marker System
```gml
// Create marker object (obj_onboarding_marker)
// In Create event:
quest_id = "";                 // Set by spawner
marker_sprite = spr_quest_marker_arrow;
show_offscreen_arrow = true;
image_index = 0;               // Animation frame
image_speed = 0.1;             // Animation speed

// In Step event:
// Update animation
image_index += image_speed;
if (image_index >= image_number) {
    image_index -= image_number;  // Loop animation
}

// Destroy when quest completes
if (global.onboarding_quests.current_quest == undefined ||
    global.onboarding_quests.current_quest.quest_id != quest_id) {
    instance_destroy();
}

// In Draw event:
if (point_in_rectangle(x, y, camera_get_view_x(view_camera[0]), camera_get_view_y(view_camera[0]),
    camera_get_view_x(view_camera[0]) + camera_get_view_width(view_camera[0]),
    camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]))) {
    // Draw animated marker at location
    draw_sprite(marker_sprite, image_index, x, y);
} else if (show_offscreen_arrow) {
    // Draw off-screen arrow indicator
    // Calculate arrow position at screen edge pointing toward marker
}
```

## Sound Assets Required

Two new sound effects need to be created and added to the project:

1. **snd_onboarding_quest_available** - Short notification chime when new quest appears
   - Duration: ~0.3-0.5 seconds
   - Type: Positive/ascending tone
   - Example: Quest notification ding, UI confirmation chime

2. **snd_onboarding_quest_resolved** - Short notification chime when quest completes
   - Duration: ~0.3-0.5 seconds
   - Type: Satisfying/completion tone
   - Example: Success bell, quest complete chime

Both sounds should use `play_sfx()` system for volume control and variant support.

## External Dependencies

**Scribble Text Renderer** - Required for HUD quest text rendering
- Used for advanced text rendering with fnt_quest font
- Provides text alignment, coloring, and styling capabilities
- Must be installed in GameMaker project

**Other Systems** - Uses existing infrastructure:
- obj_game_controller (quest flags and global state management)
- HUD rendering (Draw GUI event)
- Input system (keyboard_check_pressed, input handlers)
- Interaction system (obj_interactable_parent collision/interaction)
- Save/load system (obj_persistent_parent serialization)
- Yarn dialogue system (Chatterbox integration for quest definitions)
- SFX system (play_sfx() function for sound playback)
