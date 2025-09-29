# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-09-29-trait-system/spec.md

> Created: 2025-09-29
> Status: Ready for Implementation

## Tasks

- [ ] 1. Create Trait Database and Helper Functions
  - [ ] 1.1 Create scripts/trait_database/trait_database.gml with global.trait_database initialization
  - [ ] 1.2 Define initial trait entries (fireborne, arboreal, aquatic, glacial, swampridden, sandcrawler)
  - [ ] 1.3 Create scripts/trait_system/trait_system.gml with helper functions
  - [ ] 1.4 Implement has_trait(), add_trait(), remove_trait() functions
  - [ ] 1.5 Implement get_trait_effect() and get_all_trait_modifiers() functions
  - [ ] 1.6 Implement has_trait_immunity() function
  - [ ] 1.7 Add traits = [] initialization to obj_player/Create_0.gml
  - [ ] 1.8 Add traits = [] initialization to obj_enemy_parent/Create_0.gml

- [ ] 2. Integrate Damage Type System with Trait Modifiers
  - [ ] 2.1 Create get_damage_type() helper function to determine damage type from weapon/status
  - [ ] 2.2 Modify obj_enemy_parent/Collision_obj_attack.gml to apply trait damage modifiers
  - [ ] 2.3 Modify obj_player/Collision_obj_enemy_parent.gml to apply trait damage modifiers
  - [ ] 2.4 Test damage modifier application with fireborne (immune) and arboreal (vulnerable) traits

- [ ] 3. Add Debug Commands for Trait Testing
  - [ ] 3.1 Add keyboard input handling for trait debug commands (T/Y/U/I keys)
  - [ ] 3.2 Implement "T" key to add fireborne trait to player
  - [ ] 3.3 Implement "Y" key to add arboreal trait to nearest enemy
  - [ ] 3.4 Implement "U" key to remove all traits from player
  - [ ] 3.5 Implement "I" key to show debug message with all active traits
  - [ ] 3.6 Test all debug commands in-game

- [ ] 4. Assign Traits to Enemies and Verify Integration
  - [ ] 4.1 Assign appropriate traits to 2-3 test enemies in their Create events
  - [ ] 4.2 Test fire damage against arboreal enemy (should take 150% damage)
  - [ ] 4.3 Test fire damage against fireborne enemy (should take 0 damage)
  - [ ] 4.4 Test physical damage against various trait combinations
  - [ ] 4.5 Verify trait effects persist correctly throughout combat
  - [ ] 4.6 Document any discovered issues or edge cases

Follow TDD principles where applicable, considering this is a GameMaker project without formal unit testing infrastructure. Manual testing steps are critical for verification.