# Spec Tasks

## Tasks

- [ ] 1. Implement breakable parent core
  - [ ] 1.1 Write tests for `obj_breakable` melee collision handling
  - [ ] 1.2 Add Create/Step/Collision events with idle→breaking state machine and HP tracking
  - [ ] 1.3 Extend `obj_attack` to track `hit_breakables` so single swings only damage once
  - [ ] 1.4 Verify all tests pass

- [ ] 2. Hook particle and audio feedback
  - [ ] 2.1 Write tests for break burst particle/audio timing
  - [ ] 2.2 Implement `scr_spawn_breakable_particles` helper and update FX object support
  - [ ] 2.3 Play particles and `break_sfx` inside `begin_break()`
  - [ ] 2.4 Verify all tests pass

- [ ] 3. Configure grass breakable variant
  - [ ] 3.1 Write tests for `obj_breakable_grass` visuals and gameplay behaviour
  - [ ] 3.2 Import/tag `spr_breakable_grass` idle and breaking frame ranges
  - [ ] 3.3 Override child Create event with sprite, durability, and particle palette
  - [ ] 3.4 Place instances in a sandbox room for validation
  - [ ] 3.5 Verify all tests pass

- [ ] 4. Ensure persistence coverage
  - [ ] 4.1 Write tests for destroyed breakables persisting across loads
  - [ ] 4.2 Override `serialize()`/`deserialize()` to record `is_destroyed`
  - [ ] 4.3 Playtest room transitions/save-load to confirm broken props stay gone
  - [ ] 4.4 Verify all tests pass
