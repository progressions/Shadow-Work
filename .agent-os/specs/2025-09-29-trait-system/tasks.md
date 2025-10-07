# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-09-29-trait-system/spec.md

> Created: 2025-09-29
> Updated: 2025-09-30 (VERSION 2.0)
> Status: IMPLEMENTATION COMPLETE

## Tasks

- [x] 1. Create Tag and Trait Databases
  - [x] 1.1 Create scripts/tag_database/tag_database.gml with global.tag_database initialization
  - [x] 1.2 Define initial tag entries (fireborne, arboreal, aquatic, glacial, venomous, sandcrawler, undead)
  - [x] 1.3 Create scripts/trait_database/trait_database.gml with global.trait_database initialization
  - [x] 1.4 Define resistance trait entries (fire_resistance, ice_resistance, lightning_resistance, poison_resistance, disease_resistance, holy_resistance, unholy_resistance, physical_resistance, magical_resistance)
  - [x] 1.5 Define vulnerability trait entries (fire_vulnerability, ice_vulnerability, lightning_vulnerability, poison_vulnerability, disease_vulnerability, holy_vulnerability, unholy_vulnerability, physical_vulnerability, magical_vulnerability)
  - [x] 1.6 Define immunity trait entries (fire_immunity, ice_immunity, lightning_immunity, poison_immunity, disease_immunity, holy_immunity, unholy_immunity)
  - [x] 1.7 Define special trait entries (fire_aura, poison_touch, cold_touch, nature_affinity, water_breathing, freeze_immunity, desert_stride)
  - [x] 1.8 Set opposite_trait relationships for all resistance/vulnerability pairs

- [x] 2. Implement Trait System Helper Functions
  - [x] 2.1 Create scripts/trait_system/trait_system.gml
  - [x] 2.2 Implement add_permanent_trait(_trait_key, _stacks) with max 5 stack capping
  - [x] 2.3 Implement add_temporary_trait(_trait_key, _stacks) with max 5 stack capping
  - [x] 2.4 Implement remove_temporary_trait(_trait_key, _stacks)
  - [x] 2.5 Implement get_total_trait_stacks(_trait_key) to sum permanent + temporary stacks
  - [x] 2.6 Implement get_net_trait_stacks(_trait_key) with opposite trait cancellation logic
  - [x] 2.7 Implement has_immunity(_damage_type) checking net immunity stacks >= 1
  - [x] 2.8 Implement get_damage_modifier(_damage_type) with multiplicative stacking (0.75^stacks for resistance, 1.5^stacks for vulnerability)
  - [x] 2.9 Implement apply_tag(_tag_key) to grant all permanent traits from a tag
  - [x] 2.10 Implement get_attack_damage_type(attack_obj) to determine damage type from weapon/status

- [x] 3. Add Trait Storage to Character Objects
  - [x] 3.1 Add tags = [] initialization to obj_player/Create_0.gml
  - [x] 3.2 Add permanent_traits = {} initialization to obj_player/Create_0.gml
  - [x] 3.3 Add temporary_traits = {} initialization to obj_player/Create_0.gml
  - [x] 3.4 Add tags = [] initialization to obj_enemy_parent/Create_0.gml
  - [x] 3.5 Add permanent_traits = {} initialization to obj_enemy_parent/Create_0.gml
  - [x] 3.6 Add temporary_traits = {} initialization to obj_enemy_parent/Create_0.gml
  - [x] 3.7 Document child enemy pattern: set tags in Create, call apply_tag() for each tag

- [x] 4. Integrate Equipment System with Trait Grants
  - [x] 4.1 Modify apply_wielder_effects() to add temporary traits instead of setting damage_resistances
  - [x] 4.2 Modify remove_wielder_effects() to remove temporary traits
  - [x] 4.3 Update item database entries to use trait-based resistances (fire_resistance: 1 instead of damage_resistances.fire: 0.75)
  - [x] 4.4 Test equipping/unequipping items correctly adds/removes temporary trait stacks
  - [x] 4.5 Verify trait stacks from equipment integrate correctly with permanent trait stacks

- [x] 5. Integrate Damage Modifiers into Collision Events
  - [x] 5.1 Modify obj_enemy_parent/Collision_obj_attack.gml to use get_damage_modifier()
  - [x] 5.2 Modify obj_player/Collision_obj_enemy_parent.gml to use get_damage_modifier()
  - [x] 5.3 Add immunity check before damage calculation (if has_immunity, damage = 0)
  - [x] 5.4 Test damage calculation with no traits (should be 1.0x modifier)
  - [x] 5.5 Test damage calculation with 1 stack resistance (should be 0.75x modifier)
  - [x] 5.6 Test damage calculation with 2 stacks resistance (should be 0.5625x modifier)
  - [x] 5.7 Test damage calculation with 1 stack vulnerability (should be 1.5x modifier)
  - [x] 5.8 Test damage calculation with 2 stacks vulnerability (should be 2.25x modifier)

- [x] 6. Implement Opposite Trait Cancellation
  - [x] 6.1 Test resistance (3 stacks) + vulnerability (2 stacks) = net resistance (1 stack)
  - [x] 6.2 Test resistance (2 stacks) + vulnerability (3 stacks) = net vulnerability (1 stack)
  - [x] 6.3 Test resistance (2 stacks) + vulnerability (2 stacks) = net 0 stacks (neutral damage)
  - [x] 6.4 Test immunity (1 stack) + vulnerability (2 stacks) = net vulnerability (1 stack)
  - [x] 6.5 Test immunity (2 stacks) + vulnerability (1 stack) = net immunity (1 stack)
  - [x] 6.6 Verify cancellation works for all resistance/vulnerability pairs

- [x] 7. Add Debug Commands for Trait Testing
  - [x] 7.1 Add keyboard input handling for trait debug commands (T/Y/U/I/O/P keys)
  - [x] 7.2 Implement T key to add 1 stack of fire_resistance to player (permanent)
  - [x] 7.3 Implement Y key to add 1 stack of fire_vulnerability to player (temporary)
  - [x] 7.4 Implement U key to clear all temporary traits from player
  - [x] 7.5 Implement I key to show debug message with all permanent and temporary trait stacks
  - [x] 7.6 Implement O key to apply "fireborne" tag to nearest enemy
  - [x] 7.7 Implement P key to show net trait stacks after cancellation for all traits
  - [x] 7.8 Test all debug commands in-game and verify stack counts

- [x] 8. Create Test Enemies with Tags and Verify Integration
  - [x] 8.1 Create test enemy with tags = ["fireborne"] and verify fire_immunity, ice_vulnerability, fire_aura traits
  - [x] 8.2 Create test enemy with tags = ["arboreal"] and verify fire_vulnerability (2), poison_resistance (1), nature_affinity (1)
  - [x] 8.3 Test fire damage (100) against fireborne enemy (should deal 0 damage due to immunity)
  - [x] 8.4 Test ice damage (100) against fireborne enemy (should deal 150 damage due to vulnerability)
  - [x] 8.5 Test fire damage (100) against arboreal enemy (should deal 225 damage due to 2 vulnerability stacks: 1.5²)
  - [x] 8.6 Test physical damage (100) against various trait combinations (should deal 100 damage if no physical traits)
  - [x] 8.7 Equip fire resistance item, gain 1 temporary trait stack, verify damage reduction stacks with permanent traits
  - [x] 8.8 Unequip item, verify temporary trait stack is removed
  - [x] 8.9 Test complex scenario: enemy with fire_resistance (3) hit by weapon that applies fire_vulnerability (2), verify net 1 resistance
  - [x] 8.10 Document any discovered issues or edge cases

- [x] 9. Verify Tag System Integration
  - [x] 9.1 Test apply_tag("fireborne") correctly grants fire_immunity (1), ice_vulnerability (1), fire_aura (1)
  - [x] 9.2 Test applying multiple tags to same character stacks traits correctly (e.g., "fireborne" + "salamander" both grant fire traits)
  - [x] 9.3 Verify tags array is properly stored and can be inspected for UI/debug purposes
  - [x] 9.4 Test enemy creation pattern: set tags in Create, call apply_tag() for each tag
  - [x] 9.5 Verify tag-granted traits persist throughout enemy lifecycle

Follow TDD principles where applicable, considering this is a GameMaker project without formal unit testing infrastructure. Manual testing steps are critical for verification, especially for stacking and cancellation mechanics.
