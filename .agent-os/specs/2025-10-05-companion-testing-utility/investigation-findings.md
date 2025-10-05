# Investigation Findings - Companion Testing Utility
> Date: 2025-10-05
> Task 1.8: Documentation of research findings

## Summary
Research completed for understanding the companion recruitment system and all flags needed for the testing utility.

## Key Findings

### 1. Recruitment Function
**Location:** `scripts/scr_companion_system/scr_companion_system.gml:456`

**Function signature:**
```gml
recruit_companion(companion_instance, player_instance)
```

**What it does:**
- Sets `is_recruited = true` on the companion
- Sets `state = CompanionState.following`
- Sets `follow_target = player_instance`
- Sets `quest_flags.met_player = true`
- Activates all companion auras
- Plays recruitment sound effect
- Calls `quest_check_companion_recruitment(companion_id)` for quest system integration

**Important:** The function requires companion instances to already exist in the room. It does NOT spawn companions.

### 2. VN Intro System
**Location:** `scripts/scr_vn_intro_system/scr_vn_intro_system.gml`

**How VN intros are tracked:**
- Global struct: `global.vn_intro_seen[$ vn_intro_id]`
- When set to `true`, the intro won't trigger again
- Each companion has `has_vn_intro = true` flag

**Companion VN intro IDs:**
- Hola: `"hola_intro"`
- Yorna: `"yorna_intro"`
- Canopy: `"canopy_intro"`

**To skip VN intros, set:**
```gml
global.vn_intro_seen[$ "hola_intro"] = true;
global.vn_intro_seen[$ "yorna_intro"] = true;
global.vn_intro_seen[$ "canopy_intro"] = true;
```

### 3. Companion Parent Variables
**Location:** `objects/obj_companion_parent/Create_0.gml`

**Default values:**
```gml
is_recruited = false;
state = CompanionState.waiting;
affinity = 3.0;
affinity_max = 10.0;
quest_flags = {
    met_player: false,
    first_conversation: false,
    romantic_quest_unlocked: false,
    romantic_quest_complete: false,
    adventure_quest_active: false,
    adventure_quest_complete: false
};
relationship_stage = 0; // 0=stranger, 1=acquaintance, 2=friend, 3=close, 4=romance
```

### 4. Companion Objects
- `obj_hola` - Wind companion
- `obj_yorna` - Warrior companion
- `obj_canopy` - Protective/healer companion

All inherit from `obj_companion_parent`.

### 5. Global Recruitment Flags
**Finding:** There are NO global recruitment flags (like `global.hola_recruited`) in the current codebase.

The technical spec initially assumed these existed, but they don't. We should remove references to global flags from the implementation.

### 6. Affinity System
**Variable:** `affinity`
- **Default value:** `3.0`
- **Maximum:** `10.0`
- **Location:** Instance variable on each companion

**To set custom affinity:**
```gml
companion_instance.affinity = desired_value;
```

### 7. Quest System Integration
**Function:** `quest_check_companion_recruitment(companion_id)`
- Called automatically by `recruit_companion()`
- Updates quest objectives related to companion recruitment
- No additional setup needed - works automatically

### 8. Companion Spawning
**Finding:** Companions must already exist as instances in the room before recruitment.

The `recruit_companion()` function does NOT spawn companions. For testing:
- Companions must be placed in the test room in GameMaker IDE
- OR the testing utility could spawn them using `instance_create_layer()`

## Implementation Recommendations

### Approach A: Require Companions in Room (Simpler)
```gml
function quick_recruit_all_companions() {
    // Find existing companion instances
    var _hola = instance_find(obj_hola, 0);
    var _yorna = instance_find(obj_yorna, 0);
    var _canopy = instance_find(obj_canopy, 0);

    // Recruit each if they exist
    if (instance_exists(_hola)) recruit_companion(_hola, obj_player);
    if (instance_exists(_yorna)) recruit_companion(_yorna, obj_player);
    if (instance_exists(_canopy)) recruit_companion(_canopy, obj_player);

    // Skip VN intros
    global.vn_intro_seen[$ "hola_intro"] = true;
    global.vn_intro_seen[$ "yorna_intro"] = true;
    global.vn_intro_seen[$ "canopy_intro"] = true;
}
```

### Approach B: Spawn Companions if Missing (More Robust)
```gml
function quick_recruit_all_companions() {
    var _companions = [
        { obj: obj_hola, vn_id: "hola_intro" },
        { obj: obj_yorna, vn_id: "yorna_intro" },
        { obj: obj_canopy, vn_id: "canopy_intro" }
    ];

    for (var i = 0; i < array_length(_companions); i++) {
        var _comp_data = _companions[i];
        var _comp_obj = _comp_data.obj;

        // Find or create companion instance
        var _comp = instance_find(_comp_obj, 0);
        if (!instance_exists(_comp)) {
            // Spawn near player
            var _player = instance_find(obj_player, 0);
            _comp = instance_create_layer(_player.x + 32, _player.y, "Instances", _comp_obj);
        }

        // Recruit
        recruit_companion(_comp, obj_player);

        // Skip VN intro
        global.vn_intro_seen[$ _comp_data.vn_id] = true;
    }
}
```

**Recommendation:** Use Approach B for maximum flexibility - works whether companions exist in room or not.

## Updated Technical Requirements

Based on findings, the testing utility should:

1. ✅ Check if companion instances exist, spawn if needed
2. ✅ Call `recruit_companion(companion_instance, player_instance)` for each
3. ✅ Set VN intro flags: `global.vn_intro_seen[$ vn_intro_id] = true`
4. ✅ Optionally set custom affinity values after recruitment
5. ❌ ~~Set global recruitment flags~~ (these don't exist)

## Next Steps
Proceed to Task 2: Script File Creation with this information.
