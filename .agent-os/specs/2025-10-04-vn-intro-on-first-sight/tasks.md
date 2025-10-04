# Spec Tasks

## Tasks

- [ ] 1. Implement Core VN Intro System Functions
  - [ ] 1.1 Create `scr_vn_intro_system.gml` with camera detection and intro checking functions
  - [ ] 1.2 Add `is_instance_in_camera_view(_instance)` function using view_camera[0] bounds checking
  - [ ] 1.3 Add `check_vn_intro_triggers()` function to scan for visible instances with intro flags
  - [ ] 1.4 Initialize `global.vn_intro_seen = {}` in obj_game_controller Create event
  - [ ] 1.5 Call `check_vn_intro_triggers()` from obj_game_controller Step event
  - [ ] 1.6 Test camera detection with debug overlay showing camera bounds and flagged instances

- [ ] 2. Implement Camera Panning System
  - [ ] 2.1 Create camera pan state struct in obj_game_controller Create event
  - [ ] 2.2 Add `camera_pan_to_target(_target_instance, _duration)` function to scr_vn_intro_system.gml
  - [ ] 2.3 Add `camera_pan_to_player(_duration)` function to scr_vn_intro_system.gml
  - [ ] 2.4 Implement camera pan interpolation logic in obj_game_controller Step event
  - [ ] 2.5 Add `global.camera_pan_active` flag to prevent simultaneous pans
  - [ ] 2.6 Test camera panning to arbitrary coordinates and back to player

- [ ] 3. Create Generic VN Helper Functions
  - [ ] 3.1 Add `start_vn_intro(_instance, _yarn_file, _start_node, _character_name, _portrait_sprite)` to scr_vn_helpers.gml
  - [ ] 3.2 Add `stop_vn_intro()` function that triggers camera pan back to player
  - [ ] 3.3 Modify obj_vn_controller Step_0.gml to handle `global.vn_intro_instance` (non-companion intros)
  - [ ] 3.4 Update obj_vn_controller Draw_64.gml to display character name from `vn_intro_character_name`
  - [ ] 3.5 Handle portrait sprite from `vn_intro_portrait_sprite` in VN controller draw event
  - [ ] 3.6 Test generic VN intro with test yarn file and no companion instance

- [ ] 4. Integrate VN Intro Triggers with Camera Pan
  - [ ] 4.1 Connect `check_vn_intro_triggers()` to call `camera_pan_to_target()` when intro detected
  - [ ] 4.2 Add callback/alarm system to call `start_vn_intro()` after camera pan completes
  - [ ] 4.3 Mark intro as seen in `global.vn_intro_seen` struct after triggering
  - [ ] 4.4 Ensure `stop_vn_intro()` properly calls `camera_pan_to_player()` on VN close
  - [ ] 4.5 Test full flow: walk near flagged object → camera pans → VN opens → close VN → camera returns

- [ ] 5. Add Persistence and Polish
  - [ ] 5.1 Integrate `global.vn_intro_seen` into existing save/load system
  - [ ] 5.2 Test save/load preserves seen intro flags across sessions
  - [ ] 5.3 Add error handling for missing yarn files (log warning, skip intro, mark as seen)
  - [ ] 5.4 Create test instances: companion with intro, enemy with intro, invisible environmental trigger
  - [ ] 5.5 Add debug overlay (F3 toggle) showing intro-flagged instances and camera bounds
  - [ ] 5.6 Verify all systems work correctly and no intros re-trigger after being seen
