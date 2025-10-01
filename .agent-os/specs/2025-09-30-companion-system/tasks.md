# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-09-30-companion-system/spec.md

> Created: 2025-09-30
> Status: Ready for Implementation

## Tasks

### Phase 1A: Core Infrastructure

- [ ] **TASK-001**: Create `obj_companion_parent` base object
  - [ ] Add all instance variables (companion_id, is_recruited, affinity, etc.)
  - [ ] Set `persistent = true` for room transitions
  - [ ] Initialize empty auras and triggers arrays
  - [ ] Create quest_flags struct

- [ ] **TASK-002**: Implement companion core functions
  - [ ] `companion_recruit()` - Set is_recruited flag
  - [ ] `companion_activate()` - Add to party, start following, apply auras
  - [ ] `companion_deactivate()` - Remove from party, stop following, remove auras
  - [ ] `companion_apply_auras()` - Iterate and apply all auras
  - [ ] `companion_remove_auras()` - Remove all aura effects

- [ ] **TASK-003**: Implement following AI system
  - [ ] Create `companion_update_following()` function
  - [ ] Calculate distance to player each step
  - [ ] Implement 24-32 pixel follow distance logic
  - [ ] Add direction calculation using `point_direction()`
  - [ ] Implement movement with `move_and_collide()` (create helper if needed)
  - [ ] Add collision detection with tilemap ("Tiles_Col")
  - [ ] Update facing_direction based on movement vector

- [ ] **TASK-004**: Implement animation system
  - [ ] Create `companion_update_animation()` function
  - [ ] Set sprite_index based on animation state (idle vs walking)
  - [ ] Update image_index based on facing_direction
  - [ ] Implement animation cycling for walking state
  - [ ] Set image_speed = 0 for manual control

- [ ] **TASK-005**: Implement obj_companion_parent events
  - [ ] Create_0: Initialize all variables
  - [ ] Step_0: Call update_following(), evaluate_triggers(), update_animation()
  - [ ] Draw_0: Render companion sprite
  - [ ] Room_Start: Position near player if active, resume following
  - [ ] Room_End: Call companion_remove_auras()

- [ ] **TASK-006**: Test basic following behavior
  - [ ] Create test instance of obj_companion_parent in room
  - [ ] Set is_active and is_following to true manually
  - [ ] Verify companion follows player at correct distance
  - [ ] Test pathfinding around obstacles
  - [ ] Verify animation changes when moving/idle
  - [ ] Test room transitions with persistent flag

### Phase 1B: Canopy Implementation

- [ ] **TASK-007**: Create `obj_canopy` object
  - [ ] Set parent to obj_companion_parent
  - [ ] Set sprite to spr_canopy

- [ ] **TASK-008**: Configure Canopy identity and stats
  - [ ] Set companion_id = "canopy"
  - [ ] Set companion_name = "Canopy"
  - [ ] Set sprite_idle and sprite_walk to spr_canopy
  - [ ] Initialize affinity = 1.0

- [ ] **TASK-009**: Define Canopy auras
  - [ ] Create Protective aura struct (type: "protective", stat: "defense_rating", value: 1)
  - [ ] Create Regeneration aura struct (type: "regeneration", stat: "hp_regen", value: 0.1)
  - [ ] Add both auras to auras array

- [ ] **TASK-010**: Define Canopy triggers
  - [ ] Create Shield trigger struct with id "shield"
  - [ ] Implement condition function (player HP < 30%)
  - [ ] Implement effect function (apply shield buff to player)
  - [ ] Set cooldown = 600 frames (10 seconds)
  - [ ] Initialize trigger_cooldowns.shield = 0

- [ ] **TASK-011**: Implement aura system
  - [ ] Update companion_apply_auras() to handle defense_rating auras
  - [ ] Update companion_apply_auras() to handle hp_regen auras
  - [ ] Test aura application when companion activated
  - [ ] Test aura removal when companion deactivated

- [ ] **TASK-012**: Implement trigger system
  - [ ] Create `companion_evaluate_triggers()` function
  - [ ] Implement cooldown decrement logic
  - [ ] Implement trigger condition evaluation
  - [ ] Implement trigger effect execution
  - [ ] Implement cooldown reset after trigger fires
  - [ ] Test Shield trigger activation at low HP
  - [ ] Test Shield trigger cooldown behavior

### Phase 1C: Player Integration

- [ ] **TASK-013**: Add companion DR bonus calculation
  - [ ] Create `get_companion_dr_bonus()` function in obj_player
  - [ ] Iterate through active companions and sum DR auras
  - [ ] Integrate into `get_total_defense()` function
  - [ ] Test DR bonus applies correctly with Protective aura

- [ ] **TASK-014**: Add companion regeneration application
  - [ ] Create `apply_companion_regeneration_auras()` function in obj_player
  - [ ] Iterate through active companions and apply regen auras
  - [ ] Call in obj_player Step_0 event
  - [ ] Test HP regeneration over time
  - [ ] Verify regeneration stops at max HP

- [ ] **TASK-015**: Add Shield trigger support to player
  - [ ] Add shield_active, shield_dr_bonus, shield_duration variables to obj_player
  - [ ] Implement shield duration countdown in Step event
  - [ ] Remove shield when duration expires
  - [ ] Integrate shield_dr_bonus into get_total_defense()
  - [ ] Test Shield activates at low HP
  - [ ] Test Shield expires after 3 seconds
  - [ ] Test Shield respects 10 second cooldown

- [ ] **TASK-016**: Implement recruitment interaction
  - [ ] Add recruitment check in obj_canopy Step event (when not recruited)
  - [ ] Detect player proximity (distance < 32 pixels)
  - [ ] Detect interaction key press (E key or existing interaction system)
  - [ ] Call companion_recruit() on interaction
  - [ ] Call companion_activate() to add to party
  - [ ] Test recruitment flow from start to finish

- [ ] **TASK-017**: Add global companion management
  - [ ] Create global.active_companions array in initialization
  - [ ] Create global.max_party_size = 4
  - [ ] Create get_active_companion_count() function
  - [ ] Create add_companion_to_party() function
  - [ ] Create remove_companion_from_party() function
  - [ ] Update companion_activate() to use add_companion_to_party()
  - [ ] Update companion_deactivate() to use remove_companion_from_party()

### Phase 1D: Persistence

- [ ] **TASK-018**: Implement companion save system
  - [ ] Create save_companion_data() function
  - [ ] Initialize global.save_data.companions struct if needed
  - [ ] Iterate through all companion instances
  - [ ] Serialize is_recruited, affinity, quest_flags for each companion
  - [ ] Save global.save_data.active_companions array (companion IDs)
  - [ ] Integrate save_companion_data() into existing save system

- [ ] **TASK-019**: Implement companion load system
  - [ ] Create load_companion_data() function
  - [ ] Check if global.save_data.companions exists
  - [ ] Iterate through all companion instances
  - [ ] Restore is_recruited, affinity, quest_flags from save data
  - [ ] Check active_companions list and call companion_activate() if needed
  - [ ] Integrate load_companion_data() into existing load system

- [ ] **TASK-020**: Test save/load cycle
  - [ ] Recruit Canopy in game
  - [ ] Save game
  - [ ] Close and restart game
  - [ ] Load save file
  - [ ] Verify Canopy is still recruited and active
  - [ ] Verify affinity value persists
  - [ ] Verify auras still apply after load

- [ ] **TASK-021**: Test room transition persistence
  - [ ] Activate Canopy in one room
  - [ ] Transition to another room
  - [ ] Verify Canopy instance persists (persistent = true)
  - [ ] Verify Canopy repositions near player on Room_Start
  - [ ] Verify following resumes immediately
  - [ ] Verify auras remain active across transitions

### Phase 1E: Polish and Testing

- [ ] **TASK-022**: Refine Canopy animation
  - [ ] Adjust spr_canopy frame indices for directions (up, down, left, right)
  - [ ] Fine-tune animation speed for walking
  - [ ] Ensure smooth transitions between idle and walking
  - [ ] Test all four facing directions

- [ ] **TASK-023**: Add Shield trigger feedback
  - [ ] Add debug message when Shield activates (optional)
  - [ ] Add sound effect for Shield activation (future)
  - [ ] Add visual effect for Shield active state (future)
  - [ ] Test feedback appears correctly

- [ ] **TASK-024**: Performance testing
  - [ ] Test with Canopy following for extended periods
  - [ ] Monitor CPU usage with companion active
  - [ ] Test pathfinding in complex room layouts
  - [ ] Verify no frame rate drops with regeneration aura

- [ ] **TASK-025**: Edge case testing
  - [ ] Test player death while companion active
    - [ ] Verify auras clean up properly
    - [ ] Verify companion state persists for respawn
  - [ ] Test room transition during Shield trigger
    - [ ] Verify shield duration continues in new room
    - [ ] Verify cooldown persists across rooms
  - [ ] Test loading save with Shield on cooldown
    - [ ] Note: Cooldowns may reset on load (acceptable for Phase 1)
  - [ ] Test deactivating companion while auras active
    - [ ] Verify all auras removed from player
    - [ ] Verify player stats return to normal

- [ ] **TASK-026**: Code cleanup and documentation
  - [ ] Add inline comments to all companion functions
  - [ ] Document aura system usage in comments
  - [ ] Document trigger system usage in comments
  - [ ] Verify all code follows Ruby-style conventions (snake_case)
  - [ ] Remove debug messages and test code
  - [ ] Run final code review

- [ ] **TASK-027**: Integration verification
  - [ ] Test full gameplay loop with Canopy recruited
  - [ ] Verify no conflicts with existing systems (combat, inventory, etc.)
  - [ ] Test companion behavior with various player actions (dashing, attacking)
  - [ ] Verify no visual glitches or z-order issues with companion sprite
  - [ ] Test multiple save/load cycles

- [ ] **TASK-028**: Create helper functions if needed
  - [ ] Create move_and_collide() helper if doesn't exist
  - [ ] Create array_get_index() helper if doesn't exist
  - [ ] Test helper functions independently

## Implementation Notes

### Task Dependencies

- **TASK-001 to TASK-006** must be completed before starting Phase 1B
- **TASK-007 to TASK-012** require Phase 1A completion
- **TASK-013 to TASK-017** require TASK-011 and TASK-012 completion
- **TASK-018 to TASK-021** can be done in parallel with Phase 1C
- **TASK-022 to TASK-028** should be done last after all features implemented

### Estimated Time

- Phase 1A: 8-12 hours
- Phase 1B: 6-8 hours
- Phase 1C: 6-8 hours
- Phase 1D: 4-6 hours
- Phase 1E: 4-6 hours

**Total**: 28-40 hours (approximately 1 week of development)

### Testing Checklist

After all tasks completed, verify:
- [ ] Canopy can be recruited via interaction
- [ ] Canopy follows player maintaining 24-32 pixel distance
- [ ] Protective aura grants +1 DR to player
- [ ] Regeneration aura heals player over time
- [ ] Shield trigger activates when player HP < 30%
- [ ] Shield provides +3 DR for 3 seconds
- [ ] Shield has 10 second cooldown
- [ ] Canopy persists across room transitions
- [ ] Companion state saves and loads correctly
- [ ] Affinity value persists (set to 1.0 by default)
- [ ] No performance issues or bugs
- [ ] All code follows project conventions
