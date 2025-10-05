# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-05-companion-testing-utility/spec.md

> Created: 2025-10-05
> Version: 1.0.0

## Technical Requirements

### Function Signature
```gml
// Primary function - recruits all companions with default affinity
quick_recruit_all_companions()

// Optional variant - recruits all companions with custom affinity value
quick_recruit_companions_with_affinity(affinity_value)
```

### Companion Objects to Recruit
- `obj_hola` - First companion
- `obj_yorna` - Second companion
- `obj_canopy` - Third companion

### Required State Changes Per Companion

For each companion, the utility must:

1. **Call Existing Recruitment Function**
   - Use existing `recruit_companion(companion_object)` function to leverage established recruitment logic
   - This ensures compatibility with existing party management system

2. **Set Recruitment Flag**
   - Set `is_recruited = true` on the companion instance
   - Set global flag if exists (e.g., `global.hola_recruited = true`)

3. **Mark VN Intro as Seen**
   - Set companion's `vn_intro_seen = true` or similar flag
   - Set global VN intro flag if exists (e.g., `global.hola_vn_intro_seen = true`)
   - Skip any `has_vn_intro` checks by marking intro as completed

4. **Initialize Affinity**
   - Set companion's `affinity` value to default (e.g., 0 or 10)
   - For custom variant, set to provided `affinity_value` parameter

5. **Set "Already Met" Flags**
   - Set any `first_meeting` or `has_been_met` flags to true
   - Ensure dialogue system recognizes companion as already introduced

## Approach

### Implementation Location
Create a new script file: `scripts/scr_testing_utilities/scr_testing_utilities.gml`

This keeps testing code separate from production companion system code.

### Implementation Pattern

```gml
/// @function quick_recruit_all_companions()
/// @description Instantly recruits Hola, Yorna, and Canopy for testing purposes
function quick_recruit_all_companions() {
    quick_recruit_companions_with_affinity(0);
}

/// @function quick_recruit_companions_with_affinity(affinity_value)
/// @description Recruits all companions with specified affinity value
/// @param {real} affinity_value - Starting affinity for all companions
function quick_recruit_companions_with_affinity(affinity_value) {
    var _companions = [obj_hola, obj_yorna, obj_canopy];

    for (var i = 0; i < array_length(_companions); i++) {
        var _companion_obj = _companions[i];

        // Use existing recruitment system
        recruit_companion(_companion_obj);

        // Find the recruited companion instance
        var _companion = instance_find(_companion_obj, 0);

        if (instance_exists(_companion)) {
            // Set recruitment flags
            _companion.is_recruited = true;

            // Skip VN intro
            if (variable_instance_exists(_companion, "vn_intro_seen")) {
                _companion.vn_intro_seen = true;
            }
            if (variable_instance_exists(_companion, "has_vn_intro")) {
                _companion.has_vn_intro = false; // No intro needed
            }

            // Set already met flags
            if (variable_instance_exists(_companion, "first_meeting")) {
                _companion.first_meeting = false;
            }
            if (variable_instance_exists(_companion, "has_been_met")) {
                _companion.has_been_met = true;
            }

            // Initialize affinity
            if (variable_instance_exists(_companion, "affinity")) {
                _companion.affinity = affinity_value;
            }
        }
    }

    // Set global flags if they exist
    global.hola_recruited = true;
    global.yorna_recruited = true;
    global.canopy_recruited = true;

    global.hola_vn_intro_seen = true;
    global.yorna_vn_intro_seen = true;
    global.canopy_vn_intro_seen = true;
}
```

### Usage Pattern

In any room's Room Start event (e.g., `rm_test_combat`):

```gml
// Recruit all companions with default affinity (0)
quick_recruit_all_companions();

// OR recruit with custom affinity value
quick_recruit_companions_with_affinity(50);
```

### Integration Points

1. **Existing Recruitment System**
   - Must call `recruit_companion(companion_object)` to ensure party array is updated
   - Should not duplicate recruitment logic, only set testing-specific flags

2. **VN Intro System**
   - Check companion objects for VN intro flag names (may vary: `vn_intro_seen`, `has_vn_intro`, `intro_played`)
   - Set appropriate flags to skip intro sequences

3. **Affinity System**
   - Locate affinity variable on companion objects
   - Initialize to sensible default (0) or custom value

4. **Global State**
   - Set any global recruitment flags used by quest system or dialogue
   - Ensure companions appear in party UI and follow player

## External Dependencies

### Required Existing Systems
- `recruit_companion(companion_object)` function (assumed to exist in companion system)
- Companion objects: `obj_hola`, `obj_yorna`, `obj_canopy`
- Party management system that tracks recruited companions

### Assumptions
- Companion objects have `is_recruited` variable
- VN intro flags exist on companion objects or globally
- Affinity system is implemented with numeric values
- `recruit_companion()` handles adding companions to player's party array

### Code to Investigate
Before implementation, verify:
1. Exact names of VN intro flags on each companion object
2. Whether `recruit_companion()` function exists and its parameters
3. Global flag naming conventions (e.g., `global.hola_recruited`)
4. Affinity variable name and default values
5. Any prerequisite quest flags that might block companion functionality
