# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-05-sound-variant-randomization/spec.md

## Technical Requirements

### Variant Detection System

**Initialization Location**: `obj_game_controller` Create event

**Detection Logic**:
1. Iterate through all sound assets in the project using GameMaker's asset iteration functions
2. Identify sounds ending with `_1` pattern (e.g., `snd_shield_trigger_1`)
3. For each base sound name, count sequential variants (_2, _3, _4...) until a variant doesn't exist
4. Store results in global struct: `global.sound_variant_lookup`

**Data Structure**:
```gml
global.sound_variant_lookup = {
    "snd_shield_trigger": 3,  // has _1, _2, _3
    "snd_hit": 2,             // has _1, _2
    "snd_explosion": 0        // no variants, just base sound
}
```

**GameMaker Asset Iteration**:
- Use `asset_get_index(asset_name)` to check if sound exists
- Pattern: Check `snd_name_1`, then `snd_name_2`, increment until not found
- Alternative: Iterate all sound assets and parse names for _N pattern

### Enhanced play_sfx() Function

**Location**: Modify existing function in `scripts/scr_sfx_functions/scr_sfx_functions.gml`

**Signature**: Keep existing signature intact
```gml
function play_sfx(_sound, _volume=1, _priority=8, _loop=false, _fade_in_speed=0, _fade_out_speed=0)
```

**Logic Flow**:
1. Extract base sound name (parameter can be string "snd_name" or asset `snd_name`)
2. Check `global.sound_variant_lookup[$ _base_name]` for variant count
3. If variant count > 0: randomly select variant using `irandom_range(1, variant_count)`
4. If variant count = 0: use original sound parameter
5. If sound doesn't exist at all: show debug warning and fail gracefully

**Implementation**:
```gml
function play_sfx(_sound, _volume=1, _priority=8, _loop=false, _fade_in_speed=0, _fade_out_speed=0) {
    var _sound_asset = _sound;
    var _base_name = "";

    // Handle both string and asset references
    if (is_string(_sound)) {
        _base_name = _sound;
        _sound_asset = asset_get_index(_sound);
    } else {
        _base_name = audio_get_name(_sound);
    }

    // Check for variants in cache
    var _variant_count = global.sound_variant_lookup[$ _base_name] ?? 0;

    if (_variant_count > 0) {
        // Pick random variant
        var _variant_num = irandom_range(1, _variant_count);
        var _variant_name = _base_name + "_" + string(_variant_num);
        _sound_asset = asset_get_index(_variant_name);

        // Debug logging (optional, controlled by global flag)
        if (global.debug_sound_variants) {
            show_debug_message("Sound variant: " + _variant_name + " (picked " + string(_variant_num) + " of " + string(_variant_count) + ")");
        }
    }

    // Call existing sfx controller logic
    obj_sfx_controller.play_sfx(_sound_asset, _volume, _priority, _loop, _fade_in_speed, _fade_out_speed);
}
```

### Fallback & Error Handling

**Scenarios**:
1. **No variants, base sound exists**: Play base sound normally (backward compatible)
2. **No variants, no base sound**: Show debug warning, fail gracefully (don't crash)
3. **Variants exist but asset_get_index fails**: Fall back to base sound, show warning

**Debug Flag**:
```gml
global.debug_sound_variants = false; // Set to true for testing
```

### Performance Considerations

**Cache Building** (one-time cost at game start):
- Estimated ~50-200ms depending on total sound count
- Runs once during obj_game_controller Create event
- Does not impact gameplay

**Runtime Performance** (per sound effect):
- One struct lookup: `global.sound_variant_lookup[$ _base_name]`
- One random number generation: `irandom_range(1, N)`
- One asset_get_index call (same as original)
- **Total overhead**: < 0.1ms per sound effect (negligible)

### Integration Points

**Modified Files**:
- `objects/obj_game_controller/Create_0.gml` - Add variant detection initialization
- `scripts/scr_sfx_functions/scr_sfx_functions.gml` - Enhance play_sfx() function

**No Changes Required**:
- All existing play_sfx() calls throughout codebase work without modification
- obj_sfx_controller remains unchanged
- Sound asset files just need _1, _2, _3 naming convention

### Testing Requirements

**Test Coverage**:
1. Variant detection correctly identifies all _1, _2, _3 patterns
2. play_sfx() correctly randomizes between variants
3. play_sfx() falls back to base sound when no variants exist
4. Existing sounds without variants continue working
5. Debug logging shows variant selection when enabled
6. Performance benchmark shows negligible runtime overhead

**Test Scenarios**:
- Sound with 3 variants (snd_shield_trigger_1, _2, _3)
- Sound with 2 variants (snd_hit_1, _2)
- Sound with no variants (snd_explosion)
- Sound that doesn't exist (error case)
- Rapid repeated calls (100+ per second) to verify performance
