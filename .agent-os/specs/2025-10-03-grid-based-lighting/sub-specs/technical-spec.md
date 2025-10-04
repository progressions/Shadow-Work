# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-03-grid-based-lighting/spec.md

> Created: 2025-10-03
> Version: 1.0.0

## Technical Requirements

### Core Architecture

**obj_lighting_controller** (singleton controller object)
- Created in each room to manage lighting system
- Properties:
  - `light_grid` - ds_grid(grid_width, grid_height) storing light intensity per cell (0.0 to 1.0)
  - `grid_cell_size` - constant 16 (pixels per cell)
  - `grid_width` - calculated as `ceil(room_width / grid_cell_size)`
  - `grid_height` - calculated as `ceil(room_height / grid_cell_size)`
  - `darkness_surface` - surface for rendering darkness overlay
  - `room_darkness_level` - 0.0 to 1.0 (default 0.0, configurable via room creation code)
  - `surface_dirty` - boolean flag to trigger surface recreation when the GPU context drops
- Functions:
  - `init_light_grid()` - Initialize ds_grid with all cells at 0 (dark)
  - `clear_light_grid()` - Reset all cells to 0 each frame before calculating lights
  - `add_light_source(x, y, radius)` - Calculate stepped light for grid cells within radius
  - `render_lighting()` - Draw darkness surface with subtractive blend mode for lights
  - `cleanup_surface()` - Free surface in Clean Up event
  - `step()` - Skip updates when `global.game_paused` is true and recreate the surface if `surface_dirty` is set

### Light Calculation System

**Stepped Light Falloff Algorithm**
- Calculate distance from light source to each grid cell center in grid units (not pixels)
- Distance formula: `dist = point_distance(light_grid_x, light_grid_y, cell_grid_x, cell_grid_y)`
- Map distance to brightness levels:
  - 0-1 grid cells: 1.0 (100% bright)
  - 1-2 grid cells: 0.75 (75% bright)
  - 2-3 grid cells: 0.5 (50% bright)
  - 3-4 grid cells: 0.25 (25% bright)
  - 4+ grid cells: 0.0 (dark)
- Use `max()` to combine overlapping lights (non-additive): `light_grid[# cell_x, cell_y] = max(current_value, new_light_value)`

**Light Source Detection**
- Player torch: Check `obj_player.equipped.left_hand != undefined` and `obj_player.equipped.left_hand.definition.item_id == "torch"` with `obj_player.torch_active == true`
- Companion torch: Iterate `with (obj_companion_parent)` or use `get_active_companions()` and check `carrying_torch == true`
- World sources: Loop through `obj_light_source` instances
- Extract radius from `item_def.stats.light_radius` or `obj.light_radius` property

### Rendering System

**Surface-Based Darkness Overlay** (Draw Event execution order)
1. Create/verify surface exists: `if (!surface_exists(darkness_surface)) { darkness_surface = surface_create(room_width, room_height) }`
2. Set surface as target: `surface_set_target(darkness_surface)`
3. Clear surface to black with room_darkness_level alpha: `draw_clear_alpha(c_black, room_darkness_level)`
4. Set subtractive blend mode: `gpu_set_blendmode(bm_subtract)`
5. Loop through light_grid cells and draw white rectangles for lit cells:
   - For each cell with light_intensity > 0:
   - Draw white rectangle at cell position with alpha = light_intensity
   - `draw_set_alpha(light_grid[# cx, cy])`
   - `draw_rectangle(cell_x * 16, cell_y * 16, (cell_x+1) * 16, (cell_y+1) * 16, false)`
6. Reset blend mode: `gpu_set_blendmode(bm_normal)`
7. Reset surface target: `surface_reset_target()`
8. Draw surface to screen: `draw_surface(darkness_surface, 0, 0)`

If `surface_exists(darkness_surface)` ever returns false, set `surface_dirty = true` and recreate the surface at the next update before drawing.

**Cleanup Requirements**
- Destroy the ds_grid in Clean Up: `ds_grid_destroy(light_grid)`
- Free the surface if it exists before the instance is destroyed: `surface_free(darkness_surface)`
- Reset stored references (`darkness_surface = -1`, `light_grid = undefined`) after cleanup to prevent double frees.

### Torch Duration System

**Torch Item Setup**
- Update the torch entry in `scr_item_database` to include `stack_size` (torches are stackable) and `burn_time_seconds` (or `burn_time_frames`) so duration logic can read from shared metadata.
- Treat torches as consumable tools; each burnout consumes one unit from the stack.

**Inventory Helper Functions**
- Add `inventory_has_item_id(_item_id)` that returns true/false for the player inventory.
- Add `inventory_find_item_id(_item_id)` that returns the first slot index containing the item or -1 if missing.
- Add `inventory_consume_item_id(_item_id, _count)` that uses the finder to decrement stacks and remove empty slots.
- Use these helpers for both player and companion torch replacement instead of relying on numeric slot assumptions.

**obj_player torch duration tracking**
- Properties:
  - `torch_active` - boolean, true when torch equipped in left hand
  - `torch_time_remaining` - frames remaining (60 frames per second)
  - `torch_duration` - frames total derived from `burn_time_seconds` (e.g., `burn_time_seconds * room_speed`)
  - `torch_sound_emitter` - audio emitter for looped torch burning sound
- Step Event logic:
  - Check if torch equipped: `torch_active = (equipped.left_hand != undefined && equipped.left_hand.item_id == "torch")`
  - If torch just became active (state change): Play `snd_torch_equip` sound effect
  - If torch_active, decrement `torch_time_remaining -= 1`
  - If `torch_time_remaining <= 0`:
    - Play `snd_torch_burnout` sound effect
    - Stop looped torch burning sound: `audio_stop_sound(torch_sound_emitter)`
    - Call `unequip_item("left_hand")` to remove burned-out torch
    - Check if player has torch in inventory: `_slot = inventory_find_item_id("torch")`
    - If yes: `inventory_consume_item_id("torch", 1)`, `equip_item("torch", "left_hand")`, reset `torch_time_remaining = torch_duration`, play `snd_torch_equip`
    - If no: set `torch_active = false` (light goes out)

**Companion torch system integration**
- Add to obj_companion_parent (or specific companion objects):
  - `carrying_torch` - boolean flag
  - `torch_time_remaining` - frames remaining
  - `torch_sound_emitter` - audio emitter for looped torch burning sound
- L key input handler in obj_player Step Event:
  - `var _companions = get_active_companions();`
  - `if (keyboard_check_pressed(ord("L")) && torch_active && array_length(_companions) > 0)`
  - Transfer torch to first active companion:
    - Play `snd_companion_torch_receive` sound effect
    - Stop player's torch burning loop: `audio_stop_sound(torch_sound_emitter)`
    - `_target = _companions[0];`
    - `_target.carrying_torch = true`
    - `_target.torch_time_remaining = torch_time_remaining`
    - Start companion's torch burning loop on companion's emitter
    - `unequip_item("left_hand")`
    - `torch_active = false`
- Companion Step Event torch countdown:
  - If `carrying_torch == true`, decrement `torch_time_remaining -= 1`
  - If `torch_time_remaining <= 0`:
    - Play `snd_torch_burnout` sound effect
    - Stop looped torch burning sound: `audio_stop_sound(torch_sound_emitter)`
    - Check if player has torch in inventory: `if (inventory_consume_item_id("torch", 1))`
    - If yes: reset `torch_time_remaining = torch_duration`, play `snd_torch_equip`, restart burning loop
    - If no: set `carrying_torch = false`

### World Light Sources

**obj_light_source** (parent object for static lights)
- Properties:
  - `light_radius` - configurable (default 100 pixels)
  - `light_active` - boolean (default true)
- Child objects:
  - `obj_torch_wall` - wall-mounted torch sprite
  - `obj_lamp_standing` - standing lamp sprite
- No Step Event needed (static position)
- obj_lighting_controller detects via `with (obj_light_source) { other.add_light_source(x, y, light_radius) }`

### Room Configuration

**Room Creation Code** (for each room requiring darkness)
```gml
// Set room darkness level (0 = fully lit, 1 = pitch black)
if (instance_exists(obj_lighting_controller)) {
    obj_lighting_controller.room_darkness_level = 0.8;
}
```

### Performance Considerations

- ds_grid operations are fast in GameMaker for grid-based calculations
- Surface creation/drawing happens once per frame
- Light calculation only processes cells within maximum light radius to avoid full-grid iteration
- Use `with` statement to batch-process light sources
- Clean up ds_grid in Clean Up event: `ds_grid_destroy(light_grid)`

### Sound Effects System

**Required Sound Assets**
- `snd_torch_equip` - One-shot sound when torch is equipped (player or companion)
- `snd_torch_burnout` - One-shot sound when torch duration expires
- `snd_torch_burning_loop` - Looped ambient sound while torch is active
- `snd_companion_torch_receive` - Special sound when companion receives torch from player

**Audio Emitter Implementation**
- Create audio emitter in Create Event: `torch_sound_emitter = audio_emitter_create()`
- Position emitter at torch carrier: `audio_emitter_position(torch_sound_emitter, x, y, 0)`
- Update emitter position in Step Event while torch active
- Play looped burning sound: `audio_play_sound_on(torch_sound_emitter, snd_torch_burning_loop, true, 1)`
- Stop burning loop when torch burns out or transfers
- Free emitter in Clean Up Event: `audio_emitter_free(torch_sound_emitter)`

**Sound Trigger Points**
1. **Torch equip** - When `equip_item("torch", "left_hand")` succeeds
2. **Torch burnout** - When `torch_time_remaining <= 0`
3. **Torch transfer to companion (L key)** - When companion receives torch via keyboard
4. **Torch transfer to companion (VN dialogue)** - When dialogue option selected
5. **Burning loop start** - When torch becomes active
6. **Burning loop stop** - When torch burns out or transfers

### VN Dialogue Integration

**Companion Yarn File Addition**
Add dialogue node for torch request in companion's .yarn file:

```yarn
[[Carry the torch for me|if inventory_has_item_id("torch") && !carrying_torch]]
    <<companion_take_torch>>
    Of course! I'll keep the light going.
    -> END
```

**Custom Chatterbox Function**
Register in obj_game_controller Create Event:
```gml
ChatterboxAddFunction("companion_take_torch", companion_take_torch_function);
```

**Function Implementation** (create in scripts/scr_companion_system.gml):
```gml
function companion_take_torch_function() {
    // Get the companion being talked to (from global.vn_companion)
    var _companion = global.vn_companion;

    if (_companion != undefined && inventory_consume_item_id("torch", 1)) {
        // Transfer torch from inventory to companion
        _companion.carrying_torch = true;
        _companion.torch_time_remaining = obj_player.torch_duration;

        // Play companion torch receive sound
        audio_play_sound(snd_companion_torch_receive, 1, false);

        // Start burning loop on companion's emitter
        audio_play_sound_on(_companion.torch_sound_emitter, snd_torch_burning_loop, true, 1);

        // If player had torch equipped, unequip it
        if (obj_player.torch_active) {
            audio_stop_sound(obj_player.torch_sound_emitter);
            unequip_item("left_hand");
            obj_player.torch_active = false;
        }
    }
}
```

### Save/Load System Integration

**Torch State Serialization**

Player torch state to serialize:
- `torch_active` - boolean
- `torch_time_remaining` - integer (frames)
- Torch inventory count (handled by existing inventory serialization)

Companion torch state to serialize (per companion):
- `carrying_torch` - boolean
- `torch_time_remaining` - integer (frames)

**Save Data Structure**
```gml
// Example save data structure
save_data.player.torch = {
    active: obj_player.torch_active,
    time_remaining: obj_player.torch_time_remaining
};

// For each companion
var _companions = get_active_companions();
for (var i = 0; i < array_length(_companions); i++) {
    var _comp = _companions[i];
    save_data.companions[i].torch = {
        carrying: _comp.carrying_torch,
        time_remaining: _comp.torch_time_remaining
    };
}
```

**Load Data Restoration**
```gml
// Restore player torch state
if (variable_struct_exists(load_data.player, "torch")) {
    obj_player.torch_active = load_data.player.torch.active;
    obj_player.torch_time_remaining = load_data.player.torch.time_remaining;

    // If torch was active, restart audio emitter
    if (obj_player.torch_active && obj_player.torch_sound_emitter != undefined) {
        audio_play_sound_on(obj_player.torch_sound_emitter, snd_torch_burning_loop, true, 1);
    }
}

// Restore companion torch states
var _companions = get_active_companions();
for (var i = 0; i < array_length(_companions); i++) {
    if (variable_struct_exists(load_data.companions[i], "torch")) {
        var _comp = _companions[i];
        _comp.carrying_torch = load_data.companions[i].torch.carrying;
        _comp.torch_time_remaining = load_data.companions[i].torch.time_remaining;

        // If companion was carrying torch, restart audio
        if (_comp.carrying_torch && _comp.torch_sound_emitter != undefined) {
            audio_play_sound_on(_comp.torch_sound_emitter, snd_torch_burning_loop, true, 1);
        }
    }
}
```

**Important Notes**
- Audio emitters are NOT serialized (recreated on load)
- Torch inventory counts are handled by existing inventory save/load system
- Room darkness levels are per-room configuration (not saved in player data)
- Light grid state is regenerated each frame (not saved)

### Integration Points

- Item system: Read `light_radius` from `global.item_database.torch.stats.light_radius`
- Companion system: Use `get_active_companions()` (backed by `obj_companion_parent`) for torch transfer and `global.vn_companion` for VN dialogue
- Inventory system: Extend utilities with `inventory_find_item_id()` / `inventory_consume_item_id()` for stack-based torches
- Player equipment: Use existing `equipped.left_hand` struct and `unequip_item()` function
- VN system: Use Chatterbox custom functions for dialogue integration
- Audio system: Use audio emitters for positional torch sounds
- Save/Load system: Serialize torch_active, torch_time_remaining for player and companions; restore audio emitters on load

### Code Style Compliance

Following project's Ruby-like GML conventions:
- Functions: `snake_case` (e.g., `add_light_source()`, `clear_light_grid()`)
- Variables: `snake_case` (e.g., `light_grid`, `torch_time_remaining`)
- Local variables: `_prefixed` (e.g., `_cell_x`, `_light_value`)
- Constants: `UPPER_SNAKE_CASE` (e.g., `GRID_CELL_SIZE`)

## Approach

### Implementation Phases

**Phase 1: Core Lighting System**
1. Create obj_lighting_controller object with grid initialization
2. Implement add_light_source() with stepped falloff algorithm
3. Implement surface-based rendering with subtractive blend mode
4. Test with manual light source placement

**Phase 2: Player Torch Integration**
1. Add torch_active, torch_time_remaining properties to obj_player
2. Implement torch detection in Step Event
3. Add torch duration countdown logic
4. Test torch equip/unequip and duration expiry

**Phase 3: Companion Torch System**
1. Add carrying_torch property to obj_companion_parent
2. Implement L key torch transfer logic
3. Add companion torch auto-refill from inventory
4. Test torch passing and inventory consumption

**Phase 4: World Light Sources**
1. Create obj_light_source parent object
2. Create obj_torch_wall and obj_lamp_standing child objects
3. Add light source detection to obj_lighting_controller
4. Place light sources in test room

**Phase 5: Room Darkness Configuration**
1. Add room_darkness_level property to obj_lighting_controller
2. Test darkness levels in different rooms
3. Document room creation code pattern

### Testing Strategy

- Unit test: Single light source with stepped falloff verification
- Integration test: Multiple overlapping lights with max() blending
- Performance test: Full room with 20+ light sources
- Edge case test: Surface recreation, grid boundary conditions
- Gameplay test: Torch duration, companion transfer, inventory refill

## External Dependencies

### GameMaker Built-in Functions
- `ds_grid_create()`, `ds_grid_destroy()` - Grid data structure
- `surface_create()`, `surface_exists()`, `surface_free()` - Surface management
- `surface_set_target()`, `surface_reset_target()` - Surface rendering
- `gpu_set_blendmode()` - Blend mode control (bm_subtract, bm_normal)
- `draw_clear_alpha()`, `draw_rectangle()`, `draw_surface()` - Drawing functions
- `point_distance()` - Distance calculation
- `ceil()`, `max()` - Math functions
- `with` statement - Batch object processing

### Existing Game Systems
- Item Database: `global.item_database.torch` definition with `stats.light_radius`
- Inventory System: `inventory_has_item_id()`, `inventory_find_item_id()`, `inventory_consume_item_id()` helpers
- Equipment System: `obj_player.equipped.left_hand`, `unequip_item()` function
- Companion System: `obj_companion_parent` instances queried via `get_active_companions()`

### New Assets Required
- Sprites:
  - `spr_torch_wall` - Wall-mounted torch sprite
  - `spr_lamp_standing` - Standing lamp sprite
- Objects:
  - `obj_lighting_controller` - Main lighting controller
  - `obj_light_source` - Parent for static light sources
  - `obj_torch_wall` - Wall torch child object
  - `obj_lamp_standing` - Standing lamp child object
