# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-05-party-controller-optimization/spec.md

> Created: 2025-10-05
> Status: IMPLEMENTATION COMPLETE

## Tasks

- [x] 1. Implement Staggered Decision Weight Updates
  - [x] 1.1 Add `decision_update_index` variable to `obj_enemy_party_controller/Create_0.gml`
  - [x] 1.2 Replace decision weight loop in `obj_enemy_party_controller/Step_0.gml` with round-robin update logic
  - [x] 1.3 Add safety checks for empty party array (array_length > 0)
  - [x] 1.4 Test with 2 orc raiding parties (10 enemies) to verify smooth performance
  - [x] 1.5 Verify each enemy still updates every 5-10 frames (responsive AI behavior)

- [x] 2. Add Empty Party Controller Cleanup
  - [x] 2.1 Add cleanup check at end of `obj_enemy_party_controller/Step_0.gml`
  - [x] 2.2 Destroy controller when `array_length(party_members) == 0`
  - [x] 2.3 Test party controller destruction after all members killed
  - [x] 2.4 Verify no lingering party controllers remain after combat

- [x] 3. Add Performance Debug Output (Optional)
  - [x] 3.1 Add update index display to `obj_enemy_party_controller/Draw_64.gml`
  - [x] 3.2 Add updates-per-frame counter to debug overlay
  - [x] 3.3 Test debug display shows correct update rotation
  - [x] 3.4 Verify performance metrics are accurate

- [x] 4. Final Testing and Verification
  - [x] 4.1 Test large battle scenario (2 raiding parties + spawner with 12+ enemies)
  - [x] 4.2 Verify no noticeable lag or frame drops during combat
  - [x] 4.3 Verify AI behavior remains responsive (enemies react to player quickly)
  - [x] 4.4 Verify party controllers clean up properly when all members dead
  - [x] 4.5 Test edge cases: single-member parties, member death during update, rapid party size changes
