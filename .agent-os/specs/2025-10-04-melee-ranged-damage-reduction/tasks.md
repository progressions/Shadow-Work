# Spec Tasks

> Status: IMPLEMENTATION COMPLETE

## Tasks

- [x] 1. Create Attack Category System
  - [x] 1.1 Add `AttackCategory` enum with `melee` and `ranged` values to `scripts/scr_combat_system/scr_combat_system.gml`
  - [x] 1.2 Add `attack_category = AttackCategory.melee` to `objects/obj_attack/Create_0.gml`
  - [x] 1.3 Add `attack_category = AttackCategory.ranged` to `objects/obj_arrow/Create_0.gml`
  - [x] 1.4 Add `attack_category = AttackCategory.melee` to `objects/obj_enemy_attack/Create_0.gml`
  - [x] 1.5 Add `attack_category = AttackCategory.ranged` to `objects/obj_enemy_arrow/Create_0.gml`
  - [x] 1.6 Verify all attack objects have attack_category property set

- [x] 2. Implement New Damage Reduction Functions
  - [x] 2.1 Add `get_equipment_general_dr()` function to `scripts/scr_combat_system/scr_combat_system.gml`
  - [x] 2.2 Add `get_equipment_melee_dr()` function to `scripts/scr_combat_system/scr_combat_system.gml`
  - [x] 2.3 Add `get_equipment_ranged_dr()` function to `scripts/scr_combat_system/scr_combat_system.gml`
  - [x] 2.4 Add `get_melee_damage_reduction()` function (calls equipment + companion functions)
  - [x] 2.5 Add `get_ranged_damage_reduction()` function (calls equipment + companion functions)
  - [x] 2.6 Mark `get_total_defense()` as deprecated with comment
  - [x] 2.7 Test DR calculation functions with debug output

- [x] 3. Update Companion DR System
  - [x] 3.1 Add `get_companion_melee_dr_bonus()` function to `scripts/scr_companion_system/scr_companion_system.gml`
  - [x] 3.2 Add `get_companion_ranged_dr_bonus()` function to `scripts/scr_companion_system/scr_companion_system.gml`
  - [x] 3.3 Update functions to check for `damage_reduction`, `melee_damage_reduction`, `ranged_damage_reduction` properties
  - [x] 3.4 Replace `get_companion_dr_bonus()` entirely
  - [x] 3.5 Test companion DR functions with debug output

- [x] 4. Update Hola Companion Aura
  - [x] 4.1 Modify `objects/obj_hola/Create_0.gml` wind_ward aura: remove `projectile_dr`, add `ranged_damage_reduction: 3`
  - [x] 4.2 Test Hola's aura provides ranged DR when recruited
  - [x] 4.3 Verify Hola's DR bonus appears in debug display

- [x] 5. Update Item Database (Shields and Armor)
  - [x] 5.1 Update `shield` definition in `scripts/scr_item_database/scr_item_database.gml`: remove `block_chance` and `defense`, add `melee_damage_reduction: 3` and `ranged_damage_reduction: 8`
  - [x] 5.2 Update `greatshield` definition: remove `block_chance` and `defense`, add `melee_damage_reduction: 5` and `ranged_damage_reduction: 12`
  - [x] 5.3 Convert all armor `defense` stats to `damage_reduction` (general stat)
  - [x] 5.4 Remove `get_block_chance()` function from `scripts/scr_combat_system/scr_combat_system.gml`
  - [x] 5.5 Test shield and armor stats load correctly

- [x] 6. Refactor Enemy Melee Damage Calculation
  - [x] 6.1 Update `objects/obj_enemy_parent/Alarm_2.gml` lines 27-35 to check attack category and call appropriate DR function
  - [x] 6.2 Replace `get_total_defense()` call with melee/ranged DR based on `attack_category`
  - [x] 6.3 Test enemy melee attacks apply correct DR
  - [x] 6.4 Verify damage calculation in debug output shows melee DR

- [x] 7. Refactor Enemy Ranged Damage Calculation
  - [x] 7.1 Update `objects/obj_enemy_arrow/Step_0.gml` lines 30-33 to check attack category and call appropriate DR function
  - [x] 7.2 Replace DR calculation with ranged DR based on `attack_category`
  - [x] 7.3 Test enemy ranged attacks apply correct ranged DR
  - [x] 7.4 Verify Hola's ranged DR bonus reduces arrow damage
  - [x] 7.5 Verify shield ranged DR provides higher reduction than melee

- [x] 8. Integration Testing and Debug Display
  - [x] 8.1 Add debug display showing player's current melee DR and ranged DR
  - [x] 8.2 Add debug display showing attack category and damage type on incoming attacks
  - [x] 8.3 Test full combat scenarios: player with no equipment, with shield only, with armor only, with Hola recruited
  - [x] 8.4 Verify damage calculation breakdown shows correct DR application
  - [x] 8.5 Test edge cases: dual-wielding (no shield), two-handing, unequipped slots
  - [x] 8.6 Verify all expected deliverables from spec.md are met
