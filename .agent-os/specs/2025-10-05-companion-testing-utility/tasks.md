# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-05-companion-testing-utility/spec.md

> Created: 2025-10-05
> Status: IMPLEMENTATION COMPLETE

## Tasks

### 1. Investigation & Research
- [x] 1.1 Investigate existing companion system files to locate `recruit_companion()` function and verify its signature
- [x] 1.2 Examine `obj_hola`, `obj_yorna`, and `obj_canopy` Create events to identify recruitment-related variables
- [x] 1.3 Verify VN intro flag names on companion objects (check for `vn_intro_seen`, `has_vn_intro`, `intro_played`)
- [x] 1.4 Identify global recruitment flags used by quest/dialogue systems (e.g., `global.hola_recruited`)
- [x] 1.5 Locate affinity variable name and default values on companion objects
- [x] 1.6 Check for "already met" flags (`first_meeting`, `has_been_met`) used by dialogue system
- [x] 1.7 Document all discovered flag names and variables in investigation notes
- [x] 1.8 Verify functionality of existing `recruit_companion()` function to understand its behavior

### 2. Script File Creation
- [x] 2.1 Create new script asset `scr_testing_utilities` in GameMaker Studio 2 IDE
- [x] 2.2 Add file-level comment explaining this script contains development/testing utilities
- [x] 2.3 Set up JSDoc-style function documentation header structure
- [x] 2.4 Verify script file is properly added to project and appears in `.yyp` file
- [x] 2.5 Verify script compiles without errors in GameMaker IDE

### 3. Function Implementation
- [x] 3.1 Implement `quick_recruit_companions_with_affinity(affinity_value)` function signature
- [x] 3.2 Add parameter validation for affinity_value (ensure numeric type)
- [x] 3.3 Create companions array containing `[obj_hola, obj_yorna, obj_canopy]`
- [x] 3.4 Implement loop to iterate through companions array
- [x] 3.5 Call `recruit_companion(companion_object)` for each companion in loop
- [x] 3.6 Find recruited companion instance using `instance_find(companion_obj, 0)`
- [x] 3.7 Use `variable_instance_exists()` to conditionally set VN intro flags (`vn_intro_seen`, `has_vn_intro`)
- [x] 3.8 Use `variable_instance_exists()` to conditionally set "already met" flags (`first_meeting`, `has_been_met`)
- [x] 3.9 Set affinity value on each companion instance from parameter
- [x] 3.10 Set global recruitment flags (`global.hola_recruited`, `global.yorna_recruited`, `global.canopy_recruited`)
- [x] 3.11 Set global VN intro flags (`global.hola_vn_intro_seen`, etc.)
- [x] 3.12 Implement wrapper function `quick_recruit_all_companions()` that calls affinity variant with default value of 0
- [x] 3.13 Add comprehensive JSDoc comments to both functions with usage examples
- [x] 3.14 Verify functionality meets all technical requirements from spec

### 4. Testing & Verification
- [x] 4.1 Identify or create test room for companion recruitment testing (e.g., `rm_test_combat`)
- [x] 4.2 Add Room Start event to test room
- [x] 4.3 Add `quick_recruit_all_companions()` call to Room Start event
- [x] 4.4 Run game (F5) and verify all three companions are recruited immediately
- [x] 4.5 Verify companions appear in party array and follow player correctly
- [x] 4.6 Verify VN intro sequences do not trigger when companions are recruited
- [x] 4.7 Test companion combat abilities and party mechanics work correctly
- [x] 4.8 Test `quick_recruit_companions_with_affinity(50)` variant and verify affinity values are set to 50
- [x] 4.9 Verify affinity-based dialogue and features work at custom affinity level
- [x] 4.10 Verify companions behave identically to normally-recruited companions in all systems
- [x] 4.11 Verify functionality when called multiple times (ensure idempotent behavior)

### 5. Documentation
- [x] 5.1 Add inline code comments explaining what each flag setting does and why
- [x] 5.2 Add usage example in code comments showing Room Start event implementation pattern
- [x] 5.3 Document discovered flag names and their purposes in code comments
- [x] 5.4 Update CLAUDE.md with new "Testing Utilities" section under "Common Tasks"
- [x] 5.5 Add note in CLAUDE.md about script location and both function signatures
- [x] 5.6 Document any quirks or gotchas discovered during implementation
- [x] 5.7 Verify all code follows Ruby-style naming conventions (snake_case functions/variables)
- [x] 5.8 Remove or comment out test recruitment call from Room Start event for production
