# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-03-enemy-loot-tables/spec.md

> Created: 2025-10-03
> Status: Ready for Implementation

## Tasks

- [ ] 1. Create loot system helper functions
  - [ ] 1.1 Create scr_enemy_loot_system.gml script file
  - [ ] 1.2 Implement select_weighted_loot_item() function with weight calculation
  - [ ] 1.3 Implement find_loot_spawn_position() function with collision checking
  - [ ] 1.4 Implement enemy_drop_loot() main function coordinating drop logic
  - [ ] 1.5 Test weighted selection with sample loot tables in debug mode

- [ ] 2. Add loot table properties to enemy parent
  - [ ] 2.1 Add drop_chance property (default 0.3) to obj_enemy_parent Create event
  - [ ] 2.2 Add default loot_table array with basic consumables to obj_enemy_parent
  - [ ] 2.3 Document loot table structure in code comments
  - [ ] 2.4 Verify properties initialize correctly for all enemy types

- [ ] 3. Integrate loot drops with enemy death system
  - [ ] 3.1 Locate enemy death handling in obj_enemy_parent (Alarm_1 or state_dead)
  - [ ] 3.2 Add enemy_drop_loot(self) call when enemy hp reaches 0
  - [ ] 3.3 Ensure loot drops before enemy cleanup/destruction
  - [ ] 3.4 Test loot drops trigger correctly on enemy death

- [ ] 4. Configure custom loot tables for enemy types
  - [ ] 4.1 Add custom loot table to obj_orc with weighted melee items
  - [ ] 4.2 Add custom loot table to obj_fire_imp with fire-themed items
  - [ ] 4.3 Add custom loot table to obj_burglar with thief-appropriate loot
  - [ ] 4.4 Add custom loot table to obj_fire_spitter with ranged items
  - [ ] 4.5 Adjust drop_chance values per enemy type based on difficulty

- [ ] 5. Add loot drop sound effect (optional)
  - [ ] 5.1 Create or find suitable loot drop sound (snd_loot_drop)
  - [ ] 5.2 Import sound into GameMaker project
  - [ ] 5.3 Integrate sound playback in enemy_drop_loot() function
  - [ ] 5.4 Test sound volume and timing feel appropriate

- [ ] 6. Testing and balancing
  - [ ] 6.1 Set drop_chance = 1.0 temporarily for guaranteed drop testing
  - [ ] 6.2 Kill multiple enemies and verify items spawn on walkable tiles
  - [ ] 6.3 Verify weighted probabilities work (high weight items drop more often)
  - [ ] 6.4 Test each enemy type's custom loot table
  - [ ] 6.5 Verify items don't spawn on blocked tiles or pillars
  - [ ] 6.6 Reset drop_chance to balanced values (0.3-0.5 range)
  - [ ] 6.7 Playtest to ensure loot drops feel rewarding but not excessive
