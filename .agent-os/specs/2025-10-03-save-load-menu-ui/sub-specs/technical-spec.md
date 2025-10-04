# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-03-save-load-menu-ui/spec.md

> Created: 2025-10-03
> Version: 1.0.0

## Technical Requirements

### 1. RoomUI Integration

**RoomUI Layer Structure**
- Add new `SaveLoadLayer` to `RoomUI.yy` alongside existing `PauseLayer` and `GameUI`
- Layer should be initially hidden (`visible: false`)
- Layer should be positioned above `PauseLayer` in rendering order

**SaveLoadLayer Flexbox Structure**
```
SaveLoadLayer (GMRUILayer)
├── SaveLoadContainer (GMRFlexPanel) - flexDirection: 2 (horizontal), justifyContent: 1 (center)
    ├── SaveSlotListPanel (GMRFlexPanel) - flexDirection: 0 (vertical), width: 400px, height: 80%
    │   ├── SaveSlotHeaderPanel (GMRFlexPanel) - height: 60px
    │   │   ├── TitleText (GMRTextItem) - "Save / Load"
    │   │   └── ModeIndicatorText (GMRTextItem) - "(Saving)" or "(Loading)"
    │   │
    │   ├── SaveSlotScrollPanel (GMRFlexPanel) - flexDirection: 0, overflow: scroll
    │   │   ├── SaveSlot_0 (GMRFlexPanel) - AutoSave slot (read-only)
    │   │   │   ├── SlotGraphic (GMRSpriteGraphic) - Icon for autosave
    │   │   │   ├── SlotInfoPanel (GMRFlexPanel)
    │   │   │   │   ├── SlotTitleText (GMRTextItem) - "Auto-Save"
    │   │   │   │   ├── LocationText (GMRTextItem) - Room name
    │   │   │   │   └── TimestampText (GMRTextItem) - Date/time
    │   │   │   └── ButtonInstance (GMRInstance: obj_button)
    │   │   │
    │   │   ├── SaveSlot_1 through SaveSlot_8 (GMRFlexPanel) - Manual save slots
    │   │   │   ├── SlotGraphic (GMRSpriteGraphic)
    │   │   │   ├── SlotInfoPanel (GMRFlexPanel)
    │   │   │   │   ├── SlotNumberText (GMRTextItem) - "Slot 1"
    │   │   │   │   ├── LocationText (GMRTextItem) - Room name or "Empty"
    │   │   │   │   ├── LevelText (GMRTextItem) - "Level X"
    │   │   │   │   ├── PlaytimeText (GMRTextItem) - "HH:MM:SS"
    │   │   │   │   └── TimestampText (GMRTextItem) - Date/time
    │   │   │   └── ButtonInstance (GMRInstance: obj_button)
    │   │
    │   └── BackButtonPanel (GMRFlexPanel)
    │       └── BackButton (GMRInstance: obj_button) - Return to pause menu
    │
    └── PreviewPanel (GMRFlexPanel) - flexDirection: 0, width: 350px, height: 80%
        ├── PreviewHeaderPanel (GMRFlexPanel)
        │   └── PreviewTitleText (GMRTextItem) - "Save Details"
        │
        ├── PreviewContentPanel (GMRFlexPanel) - flexDirection: 0
        │   ├── CharacterNameText (GMRTextItem)
        │   ├── LevelText (GMRTextItem)
        │   ├── LocationText (GMRTextItem)
        │   ├── PlaytimeText (GMRTextItem)
        │   ├── TimestampText (GMRTextItem)
        │   ├── HPText (GMRTextItem)
        │   └── XPText (GMRTextItem)
        │
        └── PreviewBackground (GMRSpriteGraphic) - Background frame
```

### 2. Pause Menu Integration

**Add Save/Load Button to PauseLayer**
- Modify `RoomUI.yy` `PausePanel` to include new button between "Settings" and "Quit"
- Button structure follows existing pattern:
  ```
  SaveLoadButton (GMRFlexPanel)
  ├── FlexPanel_SaveLoadIcon (GMRFlexPanel)
  │   └── graphic_SaveLoadIcon (GMRSpriteGraphic: spr_ui_icon_saveload)
  ├── FlexPanel_SaveLoadText (GMRFlexPanel)
  │   └── text_SaveLoad (GMRTextItem: "Save/Load")
  └── inst_button_saveload (GMRInstance: obj_button, button_id: 3)
  ```

**Pause Controller Modification**
- Update `obj_pause_controller` to handle new button ID (3)
- Add function `open_save_load_menu()` to show SaveLoadLayer and hide PauseLayer

### 3. Save/Load Controller Object

**obj_save_load_controller** - New object to manage save/load UI state

**Create Event Properties**
```gml
// UI State
is_active = false;
current_mode = "save"; // "save" or "load"
selected_slot = 1; // Currently selected slot (0 = autosave, 1-8 = manual slots)
num_slots = 8; // Number of manual save slots
confirmation_pending = false;
confirmation_slot = -1;

// Navigation
navigation_cooldown = 0;
navigation_delay = 10; // frames between navigation inputs

// Save file data cache
save_slots_data = array_create(num_slots + 1, undefined); // Index 0 = autosave, 1-8 = manual

// Layer references
layer_name = "SaveLoadLayer";
pause_layer_name = "PauseLayer";
```

**Step Event Functions**
```gml
step_save_load_controller()
  ├── if (!is_active) return;
  ├── handle_navigation_input()
  │   ├── if W pressed: select_previous_slot()
  │   ├── if S pressed: select_next_slot()
  │   ├── if A pressed: switch_mode("load")
  │   ├── if D pressed: switch_mode("save")
  │   ├── if Enter pressed: execute_slot_action()
  │   └── if Escape pressed: close_save_load_menu()
  │
  ├── update_slot_data_cache()
  │   └── Scan save files and populate save_slots_data[]
  │
  └── update_ui_display()
      ├── Update selected slot visual highlight
      ├── Update preview panel with selected slot data
      └── Update mode indicator text
```

**Public Functions**
```gml
/// @function open_save_load_menu(mode)
/// @description Open the save/load menu in specified mode
/// @param {string} mode "save" or "load"
function open_save_load_menu(mode) {
    is_active = true;
    current_mode = mode;
    selected_slot = 1;
    confirmation_pending = false;

    // Show save/load layer, hide pause layer
    layer_set_visible(layer_name, true);
    layer_set_visible(pause_layer_name, false);

    // Scan and cache all save file data
    scan_all_save_slots();

    // Update UI
    update_ui_display();
}

/// @function close_save_load_menu()
/// @description Close save/load menu and return to pause menu
function close_save_load_menu() {
    is_active = false;
    layer_set_visible(layer_name, false);
    layer_set_visible(pause_layer_name, true);
}

/// @function scan_all_save_slots()
/// @description Read metadata from all save files
function scan_all_save_slots() {
    // Scan autosave
    save_slots_data[0] = get_save_slot_metadata("autosave");

    // Scan manual save slots
    for (var i = 1; i <= num_slots; i++) {
        save_slots_data[i] = get_save_slot_metadata(i);
    }
}

/// @function execute_slot_action()
/// @description Execute save or load action for selected slot
function execute_slot_action() {
    if (selected_slot == 0 && current_mode == "save") {
        // Cannot save to autosave manually
        return;
    }

    if (current_mode == "save") {
        // Check if slot has existing save
        if (save_slot_exists(selected_slot)) {
            // Show confirmation prompt
            show_overwrite_confirmation(selected_slot);
        } else {
            // Save directly to empty slot
            perform_save(selected_slot);
        }
    } else if (current_mode == "load") {
        // Check if slot has save data
        if (save_slot_exists(selected_slot)) {
            perform_load(selected_slot);
        }
    }
}

/// @function perform_save(slot)
/// @description Execute save operation
/// @param {real} slot Slot number to save to
function perform_save(slot) {
    if (save_game(slot)) {
        show_debug_message("Game saved to slot " + string(slot));
        // Refresh slot data
        scan_all_save_slots();
        update_ui_display();

        // Show feedback to player
        spawn_floating_text(obj_player.x, obj_player.y - 32, "Game Saved", c_green, obj_player);
    }
}

/// @function perform_load(slot)
/// @description Execute load operation
/// @param {real} slot Slot number to load from
function perform_load(slot) {
    if (load_game(slot)) {
        show_debug_message("Game loaded from slot " + string(slot));
        // close_save_load_menu() will be called after transition
    }
}
```

### 4. Save File Metadata Extraction

**Function: get_save_slot_metadata(slot)**
```gml
/// @function get_save_slot_metadata(slot)
/// @description Extract metadata from a save file without loading the full game
/// @param {real|string} slot Slot number (1-8) or "autosave"
/// @return {struct|undefined} Metadata struct or undefined if file doesn't exist
function get_save_slot_metadata(slot) {
    var filename = (slot == "autosave") ? "autosave.json" : ("save_slot_" + string(slot) + ".json");

    if (!file_exists(filename)) {
        return undefined;
    }

    try {
        // Read JSON file
        var file = file_text_open_read(filename);
        var json_string = "";

        while (!file_text_eof(file)) {
            json_string += file_text_read_string(file);
            file_text_readln(file);
        }

        file_text_close(file);

        // Parse JSON
        var save_data = json_parse(json_string);

        // Extract metadata
        var metadata = {
            exists: true,
            timestamp: save_data.timestamp,
            current_room: save_data.current_room,
            room_name: room_get_name(save_data.current_room),
            player_level: save_data.player.level,
            player_hp: save_data.player.hp,
            player_hp_total: save_data.player.hp_total,
            player_xp: save_data.player.xp,
            save_version: save_data.save_version,
            // Calculate playtime if available (placeholder - needs playtime tracking)
            playtime_seconds: 0 // TODO: Add playtime tracking to save system
        };

        return metadata;

    } catch (error) {
        show_debug_message("Error reading save slot " + string(slot) + ": " + string(error));
        return undefined;
    }
}

/// @function save_slot_exists(slot)
/// @description Check if a save file exists for the given slot
/// @param {real|string} slot Slot number (1-8) or "autosave"
/// @return {bool} True if save file exists
function save_slot_exists(slot) {
    return save_slots_data[slot] != undefined;
}

/// @function format_timestamp(timestamp)
/// @description Format timestamp into readable date/time string
/// @param {real} timestamp GameMaker timestamp value
/// @return {string} Formatted date/time
function format_timestamp(timestamp) {
    var datetime = date_current_datetime();
    var diff_seconds = (datetime - timestamp) / 1000;

    if (diff_seconds < 60) {
        return "Just now";
    } else if (diff_seconds < 3600) {
        var mins = floor(diff_seconds / 60);
        return string(mins) + " minute" + (mins == 1 ? "" : "s") + " ago";
    } else if (diff_seconds < 86400) {
        var hours = floor(diff_seconds / 3600);
        return string(hours) + " hour" + (hours == 1 ? "" : "s") + " ago";
    } else {
        var days = floor(diff_seconds / 86400);
        return string(days) + " day" + (days == 1 ? "" : "s") + " ago";
    }
}

/// @function format_playtime(seconds)
/// @description Format playtime seconds into HH:MM:SS string
/// @param {real} seconds Total playtime in seconds
/// @return {string} Formatted playtime
function format_playtime(seconds) {
    var hours = floor(seconds / 3600);
    var minutes = floor((seconds % 3600) / 60);
    var secs = floor(seconds % 60);

    return string_format(hours, 2, 0) + ":" +
           string_format(minutes, 2, 0) + ":" +
           string_format(secs, 2, 0);
}
```

### 5. UI Display and Navigation

**obj_button Integration**
- Each save slot FlexPanel contains an `obj_button` instance
- Button IDs: 100 (autosave), 101-108 (manual slots), 200 (back button)
- Selected button receives visual highlight (existing button hover/select system)
- obj_button already handles mouse interaction; controller adds keyboard navigation

**Keyboard Navigation Logic**
```gml
/// @function handle_navigation_input()
/// @description Process WASD keyboard input for slot selection
function handle_navigation_input() {
    // Cooldown to prevent rapid navigation
    if (navigation_cooldown > 0) {
        navigation_cooldown--;
        return;
    }

    var moved = false;

    // W - Previous slot
    if (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up)) {
        select_previous_slot();
        moved = true;
    }

    // S - Next slot
    if (keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_down)) {
        select_next_slot();
        moved = true;
    }

    // A - Switch to Load mode
    if (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left)) {
        if (current_mode != "load") {
            switch_mode("load");
            moved = true;
        }
    }

    // D - Switch to Save mode
    if (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right)) {
        if (current_mode != "save") {
            switch_mode("save");
            moved = true;
        }
    }

    // Enter - Execute action on selected slot
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
        execute_slot_action();
    }

    // Escape - Return to pause menu
    if (keyboard_check_pressed(vk_escape)) {
        close_save_load_menu();
    }

    if (moved) {
        navigation_cooldown = navigation_delay;
        update_ui_display();
    }
}

/// @function select_previous_slot()
function select_previous_slot() {
    selected_slot--;
    if (selected_slot < 0) {
        selected_slot = num_slots; // Wrap to last slot
    }
}

/// @function select_next_slot()
function select_next_slot() {
    selected_slot++;
    if (selected_slot > num_slots) {
        selected_slot = 0; // Wrap to autosave
    }
}

/// @function switch_mode(new_mode)
/// @param {string} new_mode "save" or "load"
function switch_mode(new_mode) {
    current_mode = new_mode;
    update_ui_display();
}
```

### 6. Confirmation Dialog System

**Overwrite Confirmation**
```gml
/// @function show_overwrite_confirmation(slot)
/// @description Show confirmation dialog for overwriting existing save
/// @param {real} slot The slot to potentially overwrite
function show_overwrite_confirmation(slot) {
    confirmation_pending = true;
    confirmation_slot = slot;

    // Create confirmation overlay panel (or use existing dialogue system)
    // Display message: "Overwrite save in Slot X? Press Enter to confirm, Escape to cancel"

    // Alternative: Use simple flag and draw confirmation in Draw GUI event
}

/// @function handle_confirmation_input()
/// @description Process input during confirmation state
function handle_confirmation_input() {
    if (keyboard_check_pressed(vk_enter)) {
        // Confirm overwrite
        perform_save(confirmation_slot);
        confirmation_pending = false;
        confirmation_slot = -1;
    }

    if (keyboard_check_pressed(vk_escape)) {
        // Cancel overwrite
        confirmation_pending = false;
        confirmation_slot = -1;
    }
}
```

## Approach

### Implementation Order

1. **Phase 1: Core Infrastructure**
   - Create `obj_save_load_controller` with basic structure
   - Add metadata extraction functions to `scr_save_system.gml`
   - Implement `get_save_slot_metadata()` and helper formatting functions

2. **Phase 2: UI Structure**
   - Create SaveLoadLayer in RoomUI.yy with flexbox layout
   - Add save slot panels (0-8) with text elements and obj_button instances
   - Add preview panel with detailed information display
   - Create or reuse sprite for save/load icon (`spr_ui_icon_saveload`)

3. **Phase 3: Pause Menu Integration**
   - Add "Save/Load" button to PausePanel in RoomUI.yy
   - Modify `obj_pause_controller` to handle new button
   - Implement `open_save_load_menu()` function

4. **Phase 4: Controller Logic**
   - Implement keyboard navigation (WASD)
   - Implement slot selection highlighting
   - Connect button clicks to slot actions
   - Add mode switching (save/load)

5. **Phase 5: Save/Load Operations**
   - Implement `perform_save()` function
   - Implement `perform_load()` function
   - Add overwrite confirmation dialog
   - Add empty slot detection

6. **Phase 6: UI Display Updates**
   - Implement `update_ui_display()` to refresh all text elements
   - Update preview panel when slot selection changes
   - Add visual feedback for selected slot
   - Show "Empty" for slots without saves

7. **Phase 7: Polish & Testing**
   - Add sound effects for navigation and save/load actions
   - Test all keyboard navigation edge cases
   - Test save/load with various game states
   - Verify metadata extraction accuracy

### Integration Points

**Save System Integration**
- Uses existing `save_game(slot)` function from `scr_save_system.gml`
- Uses existing `load_game(slot)` function from `scr_save_system.gml`
- Metadata extraction parses same JSON structure as save/load functions
- No modifications needed to core save/load logic

**Pause System Integration**
- `obj_pause_controller` calls `obj_save_load_controller.open_save_load_menu()`
- Save/load menu visibility managed through RoomUI layer visibility
- Returning to pause menu re-shows PauseLayer

**RoomUI System**
- Leverages existing flexbox layout system
- Uses existing `obj_button` for interactive elements
- Follows established UI styling (fonts, colors, sprites)

## External Dependencies

### GameMaker Resources Required

**Sprites**
- `spr_ui_icon_saveload` - Icon for Save/Load menu button (48x48px)
- `spr_save_slot_icon` - Icon for save slot entries (32x32px)
- `spr_box_frame` - Already exists, used for panel backgrounds

**Fonts**
- `fnt_ui` - Already exists, used for all text elements

**Sounds**
- `snd_ui_navigate` - Navigation sound (optional, may exist)
- `snd_ui_select` - Selection sound (optional, may exist)
- `snd_save_success` - Save confirmation sound (new)
- `snd_load_success` - Load confirmation sound (new)

**Scripts**
- `scr_save_system.gml` - Existing, no modifications needed
- `scr_ui_functions.gml` - May add helper functions for formatting

**Objects**
- `obj_button` - Already exists, used for slot interaction
- `obj_pause_controller` - Existing, requires minor modification
- `obj_save_load_controller` - NEW, core controller for save/load UI
- `obj_floating_text` - Already exists, used for save/load feedback

### Save File Format

**Existing Save File Structure (from scr_save_system.gml)**
```json
{
  "save_version": 1,
  "timestamp": <GameMaker timestamp>,
  "current_room": <room index>,
  "player": {
    "x": <number>,
    "y": <number>,
    "hp": <number>,
    "hp_total": <number>,
    "level": <number>,
    "xp": <number>,
    ...
  },
  "companions": [...],
  "inventory": {...},
  "quest_data": {...},
  "room_states": {...},
  "visited_rooms": [...],
  "chatterbox_vars": {...}
}
```

**Metadata Extracted for UI Display**
- `timestamp` - Last save time
- `current_room` - Room index (converted to room name)
- `player.level` - Character level
- `player.hp` / `player.hp_total` - Health status
- `player.xp` - Experience points
- `save_version` - Save file version compatibility

### Future Enhancement: Playtime Tracking

**Note:** Current save system does not track playtime. To add this feature:

1. Add `global.playtime_seconds` to game initialization
2. Increment in `obj_game_controller` Step event
3. Include in `save_game()` serialization:
   ```gml
   save_data.playtime_seconds = global.playtime_seconds;
   ```
4. Restore in `load_game()` deserialization:
   ```gml
   global.playtime_seconds = save_data.playtime_seconds;
   ```

This enhancement is **out of scope** for this spec but referenced for future implementation.

## Ruby-Style Naming Conventions

All new code follows project conventions:
- **Functions**: `snake_case` (e.g., `get_save_slot_metadata`, `perform_save`, `format_timestamp`)
- **Variables**: `snake_case` (e.g., `selected_slot`, `current_mode`, `navigation_cooldown`)
- **Local variables**: `_snake_case` with underscore prefix (e.g., `_metadata`, `_slot_data`)
- **Struct properties**: `snake_case` (e.g., `metadata.player_level`, `metadata.room_name`)
- **Constants/Enums**: Would use `PascalCase` for enum types if needed, but this spec uses string literals for modes ("save", "load")
