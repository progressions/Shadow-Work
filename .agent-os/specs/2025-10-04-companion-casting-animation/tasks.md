# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-04-companion-casting-animation/spec.md

> Created: 2025-10-04
> Status: Ready for Implementation

## Tasks

- [ ] 1. Update CompanionState enum and refactor existing companion state references
  - [ ] 1.1 Modify `CompanionState` enum in `scripts/scr_enums/scr_enums.gml` to use `waiting`, `following`, `casting` values
  - [ ] 1.2 Update initial state assignment in `obj_companion_parent/Create_0.gml` to use `CompanionState.waiting`
  - [ ] 1.3 Update state assignment in `obj_companion_parent/Step_0.gml` for non-recruited companions to use `CompanionState.waiting`
  - [ ] 1.4 Update `get_active_companions()` function in `scripts/scr_companion_system/scr_companion_system.gml` to check for `CompanionState.following`
  - [ ] 1.5 Update `recruit_companion()` function in `scripts/scr_companion_system/scr_companion_system.gml` to set state to `CompanionState.following`
  - [ ] 1.6 Search codebase for any other companion state references and update them to use new enum values
  - [ ] 1.7 Test that companions still spawn correctly in waiting state and transition to following state when recruited

- [ ] 2. Add casting animation data structure and variables to companion parent object
  - [ ] 2.1 Extend `anim_data` struct in `obj_companion_parent/Create_0.gml` with casting animation frame data (down, right, left, up)
  - [ ] 2.2 Add `casting_frame_index` variable initialized to 0 in Create event
  - [ ] 2.3 Add `casting_animation_speed` variable set to 6 frames in Create event
  - [ ] 2.4 Add `casting_timer` variable initialized to 0 in Create event
  - [ ] 2.5 Add `previous_state` variable initialized to `CompanionState.waiting` in Create event
  - [ ] 2.6 Verify Canopy sprite (`spr_canopy`) has frames 6-17 available for casting animations
  - [ ] 2.7 Document casting animation frame ranges (6-8 down, 9-11 right, 12-14 left, 15-17 up) in code comments

- [ ] 3. Implement casting state management in companion Step event
  - [ ] 3.1 Add casting state handler block in `obj_companion_parent/Step_0.gml` after line 23
  - [ ] 3.2 Implement movement halt (set `move_dir_x` and `move_dir_y` to 0) during casting state
  - [ ] 3.3 Implement casting animation timer advancement logic
  - [ ] 3.4 Implement frame index increment every `casting_animation_speed` frames
  - [ ] 3.5 Implement animation completion check (3 frames total) with state transition back to `previous_state`
  - [ ] 3.6 Add early exit after casting state processing to prevent following logic from running
  - [ ] 3.7 Wrap existing following behavior logic (lines 24-85) in conditional check for `state == CompanionState.following`
  - [ ] 3.8 Test that companion stops moving during casting and resumes following after animation completes

- [ ] 4. Implement casting animation rendering in companion Draw event
  - [ ] 4.1 Add casting state check at beginning of `obj_companion_parent/Draw_0.gml`
  - [ ] 4.2 Implement direction-based casting animation key selection using `last_dir_index` (down=0, right=1, left=2, up=3)
  - [ ] 4.3 Add existence check for casting animation in `anim_data` struct before rendering
  - [ ] 4.4 Set `image_index` to `anim.start + casting_frame_index` for casting animations
  - [ ] 4.5 Preserve existing idle/walk animation logic in else block for non-casting states
  - [ ] 4.6 Test rendering with Canopy to verify correct directional casting animations display
  - [ ] 4.7 Test rendering with companions without casting sprites to ensure graceful fallback

- [ ] 5. Integrate casting state into trigger activation logic
  - [ ] 5.1 Modify shield trigger activation in `evaluate_companion_triggers()` to enter casting state and store `previous_state`
  - [ ] 5.2 Modify guardian_veil trigger activation to enter casting state
  - [ ] 5.3 Modify gust trigger activation to enter casting state
  - [ ] 5.4 Modify dash_mend trigger activation to enter casting state
  - [ ] 5.5 Modify aegis trigger activation to enter casting state
  - [ ] 5.6 Modify slipstream_boost trigger activation to enter casting state
  - [ ] 5.7 Modify maelstrom trigger activation to enter casting state
  - [ ] 5.8 Add existence check wrapper around casting state entry for companions without casting animations (fallback to immediate trigger activation)
  - [ ] 5.9 Test each trigger with Canopy to verify casting animation plays before trigger effect activates
  - [ ] 5.10 Test triggers with non-Canopy companions to verify they still activate without casting animations
