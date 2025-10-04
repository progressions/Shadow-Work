# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-03-companion-dismiss-recruit/spec.md

> Created: 2025-10-03
> Version: 1.0.0

## Technical Requirements

### 1. Companion Dismissal System

**Dialogue Integration**
- Add Yarn dialogue command `<<dismiss_companion()>>` callable from companion dialogue files
- Dialogue option appears only when companion `is_recruited == true` and `state == CompanionState.following`
- Dismissal dialogue should confirm the action before executing

**Party Removal**
- Set companion's `is_recruited` to `false`
- Set companion's `state` to `CompanionState.not_recruited`
- Set companion's `follow_target` to `noone`
- Deactivate all companion auras
- Stop companion follow behavior immediately

**Position Persistence**
- Companion's current `x`, `y` coordinates are preserved (no change needed)
- Companion remains at dismissal location (does not despawn)
- Position will be serialized by existing save system

### 2. Companion Recruitment System

**Dialogue Options**
- Use existing `recruit_companion()` function with dialogue wrapper
- "Join me" dialogue option appears only when:
  - Companion's `is_recruited` is `false`
  - Companion's `quest_flags.met_player` is `true` (has met before)
- Conditional dialogue check: `<<if can_recruit_companion()>>`

**Party Rejoining**
- Call existing `recruit_companion(companion_instance, player_instance)` function
- This automatically:
  - Sets `is_recruited` to `true`
  - Sets `state` to `CompanionState.following`
  - Sets `follow_target` to player
  - Activates all companion auras
  - Marks `quest_flags.met_player` as `true`
  - Plays recruitment sound effect

### 3. Save/Load Serialization

**Companion Data Already Serialized** (existing in `serialize_companions()`)
- `companion_id` (string identifier)
- `x`, `y` (world position)
- `is_recruited` (boolean)
- `state` (CompanionState enum value)
- `affinity` (relationship level)
- `quest_flags` (struct with companion quest flags)
- `dialogue_history` (Chatterbox dialogue state)
- `relationship_stage` (progression level)
- `triggers` (all trigger states: unlocked, cooldown, active)
- `auras` (all aura states: active)

**No New Save Structure Needed**
The existing `serialize_companions()` in `scr_save_system.gml` already handles all required companion data including position, state, and flags. The system already supports dismissed companions by serializing `is_recruited` and position data.

### 4. Companion State Deserialization

**Load Process** (existing in `deserialize_companions()`)
- Existing system already handles:
  - Restoring `is_recruited`, `state`, `affinity`
  - Setting position from saved `x`, `y` coordinates
  - Restoring `quest_flags` and `dialogue_history`
  - Reactivating auras if `is_recruited == true`
  - Setting `follow_target` to `obj_player` if recruited

**Current Limitation to Address**
- Existing system uses `deserialize_companion_data()` which expects companion instances to already exist
- Need to ensure dismissed companions are spawned at their saved positions
- Currently companions may only spawn if recruited or at predefined locations

## GameMaker-Specific Implementation

### Objects Requiring Modification

#### `obj_companion_parent` (parent object for all companions)
- **Existing variables** (already implemented):
  - `is_recruited` (boolean) - tracks if companion is in party
  - `state` (CompanionState enum) - current companion state
  - `follow_target` - reference to obj_player when following
  - `quest_flags` (struct) - companion-specific quest flags
  - `dialogue_history` (array) - Chatterbox dialogue state
  - `auras` (struct) - companion aura abilities
  - `triggers` (struct) - companion trigger abilities

- **Existing behavior** (already implemented):
  - Follow AI only active when `is_recruited == true`
  - Auras automatically activate/deactivate based on `is_recruited`
  - State transitions handle recruiting/dismissing

#### `scr_companion_system.gml`
- **New function needed**: `dismiss_companion(companion_instance)` - removes companion from party
- **Existing function to modify**: `recruit_companion()` - already handles recruitment, needs Chatterbox wrapper
- **New Chatterbox helper**: `can_recruit_companion()` - checks if companion can be recruited
- **New Chatterbox helper**: `is_companion_recruited()` - checks if companion is currently recruited

#### `scr_save_system.gml` (save/load handler)
- **Existing functions** (already implemented):
  - `serialize_companions()` - converts all companion data to saveable struct
  - `deserialize_companions()` - restores companion state from save data
- **Potential modification needed**:
  - Ensure dismissed companions spawn at saved positions when loading

### GML Functions to Create

#### Core Companion Management

```gml
// In scripts/scr_companion_system/scr_companion_system.gml

/// @function dismiss_companion(companion_instance)
/// @description Removes companion from party and positions them in world
/// @param {instance} companion_instance The companion to dismiss
function dismiss_companion(companion_instance) {
    if (!instance_exists(companion_instance)) return false;

    with (companion_instance) {
        // Set state to not recruited
        is_recruited = false;
        state = CompanionState.not_recruited;
        follow_target = noone;

        // Deactivate all auras
        var _aura_names = variable_struct_get_names(auras);
        for (var i = 0; i < array_length(_aura_names); i++) {
            var _aura_name = _aura_names[i];
            auras[$ _aura_name].active = false;
        }

        // Play dismissal sound effect
        play_sfx(snd_companion_dismissed, 1, 8, false);

        show_debug_message("✓ " + companion_name + " has been dismissed from the party");
    }

    return true;
}

/// @function can_recruit_companion()
/// @description Checks if the VN companion can be recruited
/// @returns {Bool} True if companion can be recruited
function can_recruit_companion() {
    var _companion = global.vn_companion;
    if (_companion == undefined || !instance_exists(_companion)) return false;

    // Can recruit if: not currently recruited AND has met player before
    return (!_companion.is_recruited && _companion.quest_flags.met_player);
}

/// @function is_companion_recruited()
/// @description Checks if the VN companion is currently recruited
/// @returns {Bool} True if companion is in active party
function is_companion_recruited() {
    var _companion = global.vn_companion;
    if (_companion == undefined || !instance_exists(_companion)) return false;

    return _companion.is_recruited;
}

/// @function recruit_companion_from_dialogue()
/// @description Wrapper for VN dialogue to recruit current companion
function recruit_companion_from_dialogue() {
    var _companion = global.vn_companion;
    if (_companion == undefined || !instance_exists(_companion)) return;

    recruit_companion(_companion, obj_player);
}

/// @function dismiss_companion_from_dialogue()
/// @description Wrapper for VN dialogue to dismiss current companion
function dismiss_companion_from_dialogue() {
    var _companion = global.vn_companion;
    if (_companion == undefined || !instance_exists(_companion)) return;

    dismiss_companion(_companion);
}
```

#### Save/Load System Integration

**No new serialization code needed** - the existing `serialize_companions()` and `deserialize_companions()` functions in `scr_save_system.gml` already handle all companion data including:
- Position (`x`, `y`)
- Recruitment status (`is_recruited`)
- State (`state`)
- Quest flags (`quest_flags`)
- Dialogue history (`dialogue_history`)
- Affinity and relationship stage
- Triggers and auras

The dismissal system will work automatically with the existing save/load system because it uses the same `is_recruited` flag that's already being serialized.

### Dialogue System Integration (Yarn/Chatterbox)

**Chatterbox Function Registration**
Functions must be registered with Chatterbox to be callable from Yarn files:

```gml
// In obj_game_controller Create event or initialization script
ChatterboxAddFunction("can_recruit_companion", can_recruit_companion);
ChatterboxAddFunction("is_companion_recruited", is_companion_recruited);
ChatterboxAddFunction("recruit_companion", recruit_companion_from_dialogue);
ChatterboxAddFunction("dismiss_companion", dismiss_companion_from_dialogue);
```

**Yarn Dialogue Examples**

For dismissal (in companion's Yarn file):
```yarn
<<if is_companion_recruited()>>
    -> I think you should stay here for now
        Player: I think it's best if you stay here for now.
        Companion: I understand. I'll wait here if you need me.
        <<dismiss_companion()>>
        <<vn_stop>>
<<endif>>
```

For recruitment (in companion's Yarn file):
```yarn
<<if can_recruit_companion()>>
    -> Join me
        Companion: Good to see you again!
        Player: I could use your help. Want to come along?
        Companion: Absolutely! Let's go.
        <<recruit_companion()>>
        <<vn_stop>>
<<endif>>
```

### Variables and Data Structures

**Existing Companion Variables** (already implemented in `obj_companion_parent`)
All companion objects inherit these from the parent:
```gml
// Already exists in obj_companion_parent Create event
is_recruited = false;           // Tracks if companion is in party
state = CompanionState.not_recruited;  // Current companion state
follow_target = noone;          // Reference to obj_player when following
quest_flags = {};               // Companion quest/story flags
dialogue_history = [];          // Chatterbox dialogue state
auras = {};                     // Companion aura abilities
triggers = {};                  // Companion trigger abilities
affinity = 0;                   // Relationship level
relationship_stage = 0;         // Relationship progression
```

**No New Variables Needed** - the existing companion system already has all necessary state tracking for dismissal and recruitment.

### Implementation Order

1. **Create dismissal function** - Add `dismiss_companion()` to `scr_companion_system.gml`
2. **Create Chatterbox helper functions** - Add `can_recruit_companion()`, `is_companion_recruited()`, and dialogue wrappers
3. **Register Chatterbox functions** - Add function registrations in `obj_game_controller` initialization
4. **Update companion dialogue files** - Add dismissal and recruitment dialogue options to each companion's Yarn file
5. **Test basic dismissal/recruitment** - Verify companions can be dismissed and recruited through dialogue
6. **Test save/load** - Verify dismissed companions persist at correct locations across save/load
7. **Create dismissal sound effect** - Add `snd_companion_dismissed` to sounds (or reuse existing sound)

## Technical Notes

### Existing Systems Leveraged
- **Companion recruitment system** - Already exists in `recruit_companion()` function, handles all recruitment logic
- **Save/load system** - Already serializes companion position, state, and flags
- **Companion follow AI** - Already conditional on `is_recruited` flag
- **Chatterbox integration** - Already has VN dialogue system with `global.vn_companion` reference

### Key Design Decisions
- **No new state flags** - Uses existing `is_recruited` and `quest_flags.met_player` for all dismissal/recruitment logic
- **Minimal code addition** - Only adds dismissal function and Chatterbox helpers, reuses all existing systems
- **Automatic persistence** - Dismissed companions automatically save/load correctly with no additional serialization code
