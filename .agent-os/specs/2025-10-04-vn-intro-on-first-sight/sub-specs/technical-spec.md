# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-04-vn-intro-on-first-sight/spec.md

## Technical Requirements

### Camera Detection System

- Create function `is_instance_in_camera_view(_instance)` that checks if an instance's bounding box intersects with view camera 0
- Use GameMaker built-in functions: `view_camera[0]`, `camera_get_view_x()`, `camera_get_view_y()`, `camera_get_view_width()`, `camera_get_view_height()`
- Check instance bbox against camera bounds: `_instance.bbox_left`, `_instance.bbox_right`, `_instance.bbox_top`, `_instance.bbox_bottom`
- Return true if any part of the instance bbox overlaps camera viewport

### Camera Panning System

- Create `camera_pan_to_target(_target_instance, _duration)` function
  - Store original camera position (player-centered)
  - Calculate target position (center on _target_instance.x, _target_instance.y)
  - Use smooth interpolation (lerp or ease-in-out) over _duration frames
  - Set `global.camera_pan_active = true` during pan
- Create `camera_pan_to_player(_duration)` function
  - Pan camera back to obj_player position
  - Use same interpolation as above
  - Clear `global.camera_pan_active` when complete
- Default pan duration: 30 frames (0.5 seconds at 60fps)
- Store pan state in global struct: `global.camera_pan_state = { active: bool, start_x: real, start_y: real, target_x: real, target_y: real, timer: real, duration: real }`

### VN Intro Configuration (Per-Instance Variables)

Each object instance that should trigger a VN intro can set these variables in Create event or instance creation code:

```gml
// Required
has_vn_intro = true;                          // Opt-in flag
vn_intro_yarn_file = "orc_intro.yarn";       // Which yarn file to load
vn_intro_node = "Start";                      // Which node to jump to
vn_intro_id = "orc_forest_01";               // Unique ID for persistence flag

// Optional
vn_intro_character_name = "Forest Orc";      // Speaker name (empty string = no speaker)
vn_intro_portrait_sprite = spr_orc_portrait; // Portrait sprite (noone = use companion default or none)
```

### Generic VN Helper Functions

Create new VN functions in `scr_vn_helpers.gml`:

```gml
/// @function start_vn_intro(_instance, _yarn_file, _start_node, _character_name, _portrait_sprite)
/// @description Start VN dialogue for non-companion intro (no theme song, recruitment vars)
/// @param _instance           The instance triggering the intro (can be noone for environmental triggers)
/// @param _yarn_file          Yarn file to load
/// @param _start_node         Starting node name
/// @param _character_name     Speaker name (use "" for no speaker)
/// @param _portrait_sprite    Portrait sprite index (use noone for no portrait)
```

Implementation:
- Similar to `start_vn_dialogue()` but skip companion-specific logic:
  - Do NOT change music/theme song
  - Do NOT set companion recruitment variables
  - Set `global.vn_active = true` and `global.game_paused = true`
  - Load yarn file and create chatterbox instance
  - Store _instance reference in `global.vn_intro_instance` (not `global.vn_companion`)
  - Jump to _start_node

```gml
/// @function stop_vn_intro()
/// @description Close VN intro and trigger camera pan back to player
```

Implementation:
- Set `global.vn_active = false` and `global.game_paused = false`
- Clean up chatterbox instance
- Trigger `camera_pan_to_player(30)` to smoothly return camera
- Clear `global.vn_intro_instance`

### VN Intro Trigger System

Create new script file `scr_vn_intro_system.gml` with:

```gml
/// @function check_vn_intro_triggers()
/// @description Check all instances with has_vn_intro flag and trigger if visible and not seen
```

Implementation:
- Exit early if `global.vn_active` or `global.camera_pan_active` (don't trigger during VN or camera pan)
- Loop through all instances with `has_vn_intro == true` using `with (all) { if (has_vn_intro) { ... } }`
- For each instance:
  - Check if `is_instance_in_camera_view(id)`
  - Check if intro not already seen: `!global.vn_intro_seen[$ vn_intro_id]`
  - If both true: trigger intro
    - Call `camera_pan_to_target(id, 30)`
    - After pan completes (use alarm or callback): call `start_vn_intro()`
    - Mark as seen: `global.vn_intro_seen[$ vn_intro_id] = true`
    - Break (only one intro per frame)

### Persistence System

- Initialize in `obj_game_controller` Create event:
  ```gml
  global.vn_intro_seen = {};  // Struct/map of seen intro IDs
  ```
- Add `vn_intro_seen` to save/load system (alongside existing save data)
- On game load, restore `global.vn_intro_seen` struct from save data

### Integration Points

1. **obj_game_controller Step event**: Call `check_vn_intro_triggers()` every frame
2. **obj_vn_controller Step event**: Modify to handle `stop_vn_intro()` for non-companion VN intros
3. **Camera system**: If no dedicated camera object exists, implement pan logic in obj_game_controller or create new `obj_camera_controller`
4. **obj_companion_parent**: Optionally add VN intro configuration to companions (using existing `start_vn_dialogue` or new intro system)

### VN Controller Modifications

Modify `obj_vn_controller/Step_0.gml`:
- Check if `global.vn_intro_instance` exists instead of just `global.vn_companion`
- Handle speaker name from `vn_intro_character_name` if available
- Handle portrait sprite from `vn_intro_portrait_sprite` if available
- On VN close (ESC, End node), call `stop_vn_intro()` instead of `stop_vn_dialogue()` when appropriate

### Camera Pan Implementation Location

**Option A**: Create new `obj_camera_controller` object (persistent)
- Handle camera pan state and interpolation in Step event
- Provides clean separation of concerns

**Option B**: Add camera pan logic to `obj_game_controller`
- Simpler, fewer objects
- obj_game_controller already manages game state

Recommendation: **Option B** for simplicity, unless dedicated camera control is needed elsewhere

### Performance Considerations

- Only check VN intro triggers when `global.vn_active == false` (avoid overhead during VN)
- Use `with (all) { if (has_vn_intro) }` pattern to avoid checking every instance
- Camera pan uses lerp per frame (low overhead)
- Seen flags stored in lightweight struct (fast lookups)

### Error Handling

- If yarn file doesn't exist: log warning, skip intro, mark as seen (prevent repeated errors)
- If instance with `has_vn_intro` is destroyed before intro triggers: no action needed (won't be in instance list)
- If player object doesn't exist during `camera_pan_to_player()`: snap camera to (0, 0) or last known position
- If `vn_intro_id` is undefined: use instance.id as fallback (warn in debug log)

### Debug Features

Add debug overlay (toggle with F3 key):
- Show all instances with `has_vn_intro == true` (draw bounding boxes)
- Display camera viewport bounds
- Show seen intro IDs in top-left corner
- Display camera pan state (active, target, progress)
