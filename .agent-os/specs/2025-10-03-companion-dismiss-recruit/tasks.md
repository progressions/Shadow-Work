# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-03-companion-dismiss-recruit/spec.md

> Created: 2025-10-03
> Status: IMPLEMENTATION COMPLETE

## Tasks

- [x] 1. Implement core dismissal and recruitment functions
  - [x] 1.1 Write tests for `dismiss_companion()` function
  - [x] 1.2 Create `dismiss_companion(companion_instance)` in `scr_companion_system.gml` to remove companion from party
  - [x] 1.3 Implement companion state updates (set `is_recruited` to false, `state` to `CompanionState.not_recruited`, `follow_target` to `noone`)
  - [x] 1.4 Add aura deactivation logic to loop through all companion auras and set `active` to false
  - [x] 1.5 Write tests for `can_recruit_companion()` helper function
  - [x] 1.6 Create `can_recruit_companion()` to check if companion can be recruited (not recruited AND has met player)
  - [x] 1.7 Write tests for `is_companion_recruited()` helper function
  - [x] 1.8 Create `is_companion_recruited()` to check if companion is currently in party
  - [x] 1.9 Write tests for dialogue wrapper functions
  - [x] 1.10 Create `recruit_companion_from_dialogue()` wrapper to call existing `recruit_companion()` from Yarn files
  - [x] 1.11 Create `dismiss_companion_from_dialogue()` wrapper to call `dismiss_companion()` from Yarn files
  - [x] 1.12 Verify all tests pass

- [x] 2. Register Chatterbox functions and integrate with dialogue system
  - [x] 2.1 Write tests for Chatterbox function registration
  - [x] 2.2 Add `ChatterboxAddFunction("can_recruit_companion", can_recruit_companion)` to `obj_game_controller` Create event or initialization script
  - [x] 2.3 Add `ChatterboxAddFunction("is_companion_recruited", is_companion_recruited)` to `obj_game_controller` Create event or initialization script
  - [x] 2.4 Add `ChatterboxAddFunction("recruit_companion", recruit_companion_from_dialogue)` to `obj_game_controller` Create event or initialization script
  - [x] 2.5 Add `ChatterboxAddFunction("dismiss_companion", dismiss_companion_from_dialogue)` to `obj_game_controller` Create event or initialization script
  - [x] 2.6 Verify Chatterbox functions are accessible from Yarn dialogue files
  - [x] 2.7 Verify all tests pass

- [x] 3. Update companion dialogue files with dismissal and recruitment options
  - [x] 3.1 Add dismissal dialogue option to Torchbearer's Yarn file (`yarn/Torchbearer.yarn`) with `<<if is_companion_recruited()>>` conditional
  - [x] 3.2 Add recruitment dialogue option to Torchbearer's Yarn file with `<<if can_recruit_companion()>>` conditional
  - [x] 3.3 Add dismissal dialogue option to Canopy's Yarn file (`yarn/Canopy.yarn`) with `<<if is_companion_recruited()>>` conditional
  - [x] 3.4 Add recruitment dialogue option to Canopy's Yarn file with `<<if can_recruit_companion()>>` conditional
  - [x] 3.5 Test dismissal dialogue flows in-game for both companions
  - [x] 3.6 Test recruitment dialogue flows in-game for both companions

- [x] 4. Create sound effects and verify save/load functionality
  - [x] 4.1 Create or source dismissal sound effect (`snd_companion_dismissed`) or identify existing sound to reuse
  - [x] 4.2 Import dismissal sound effect to `sounds/` directory
  - [x] 4.3 Add sound effect playback to `dismiss_companion()` function
  - [x] 4.4 Write tests for save/load persistence of dismissed companions
  - [x] 4.5 Test that dismissed companions remain at dismissal location when game is saved and loaded
  - [x] 4.6 Test that dismissed companions retain their state (`is_recruited = false`) across save/load
  - [x] 4.7 Test that recruited companions can be dismissed, saved, loaded, and re-recruited successfully
  - [x] 4.8 Verify all tests pass

- [x] 5. Final integration testing
  - [x] 5.1 Test complete dismissal flow: recruit companion → dismiss companion → verify companion stays at location
  - [x] 5.2 Test complete recruitment flow: dismiss companion → save game → load game → recruit companion again
  - [x] 5.3 Test edge cases: dismissing companion in different rooms, dismissing multiple times, recruiting without prior dismissal
  - [x] 5.4 Verify companion auras properly deactivate on dismissal and reactivate on recruitment
  - [x] 5.5 Verify companion follow AI stops on dismissal and resumes on recruitment
  - [x] 5.6 Perform full playthrough test with both Torchbearer and Canopy
  - [x] 5.7 Verify all tests pass and implementation is complete
