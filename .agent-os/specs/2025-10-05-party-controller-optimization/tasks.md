# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-05-party-controller-optimization/spec.md

> Created: 2025-10-05
> Status: Ready for Implementation

## Tasks

- [ ] 1. Implement Staggered Decision Weight Updates
  - [ ] 1.1 Add `decision_update_index` variable to `obj_enemy_party_controller/Create_0.gml`
  - [ ] 1.2 Replace decision weight loop in `obj_enemy_party_controller/Step_0.gml` with round-robin update logic
  - [ ] 1.3 Add safety checks for empty party array (array_length > 0)
  - [ ] 1.4 Test with 2 orc raiding parties (10 enemies) to verify smooth performance
  - [ ] 1.5 Verify each enemy still updates every 5-10 frames (responsive AI behavior)

- [ ] 2. Add Empty Party Controller Cleanup
  - [ ] 2.1 Add cleanup check at end of `obj_enemy_party_controller/Step_0.gml`
  - [ ] 2.2 Destroy controller when `array_length(party_members) == 0`
  - [ ] 2.3 Test party controller destruction after all members killed
  - [ ] 2.4 Verify no lingering party controllers remain after combat

- [ ] 3. Add Performance Debug Output (Optional)
  - [ ] 3.1 Add update index display to `obj_enemy_party_controller/Draw_64.gml`
  - [ ] 3.2 Add updates-per-frame counter to debug overlay
  - [ ] 3.3 Test debug display shows correct update rotation
  - [ ] 3.4 Verify performance metrics are accurate

- [ ] 4. Final Testing and Verification
  - [ ] 4.1 Test large battle scenario (2 raiding parties + spawner with 12+ enemies)
  - [ ] 4.2 Verify no noticeable lag or frame drops during combat
  - [ ] 4.3 Verify AI behavior remains responsive (enemies react to player quickly)
  - [ ] 4.4 Verify party controllers clean up properly when all members dead
  - [ ] 4.5 Test edge cases: single-member parties, member death during update, rapid party size changes
