# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-09-30-damage-type-system/spec.md

> Created: 2025-09-30
> Status: Ready for Implementation

## Tasks

### Phase 1: Foundation (Enums & Helper Functions)

- [ ] **Task 1.1**: Create `DamageType` enum in `scripts/scr_enums/scr_enums.gml`
  - Add values: physical, magical, fire, holy, unholy
  - Test enum access works correctly

- [ ] **Task 1.2**: Create `scripts/scr_damage_type_helpers/scr_damage_type_helpers.gml`
  - Implement `get_damage_type_multiplier(target, damage_type)`
  - Implement `set_damage_resistance(target, damage_type, multiplier)`
  - Implement `damage_type_to_string(damage_type)`
  - Implement `damage_type_to_color(damage_type)`
  - Add JSDoc comments for all functions

- [ ] **Task 1.3**: Update `obj_floating_text` Create event
  - Add `damage_type` variable (default: DamageType.physical)
  - Add `text_color` variable (default: c_white)

- [ ] **Task 1.4**: Update `obj_floating_text` Draw event
  - Use `text_color` variable for drawing text
  - Ensure alpha blending works with colored text

### Phase 2: Entity Integration

- [ ] **Task 2.1**: Update `obj_player` Create event
  - Add `damage_resistances` struct with all five types set to 1.0

- [ ] **Task 2.2**: Update `obj_enemy_parent` Create event
  - Add `attack_damage_type` variable (default: DamageType.physical)
  - Add `damage_resistances` struct with all five types set to 1.0

- [ ] **Task 2.3**: Update item database in `scripts/scr_item_database/scr_item_database.gml`
  - Add `damage_type: DamageType.physical` to all existing weapons
  - Identify 2-3 weapons to assign non-physical types for testing
  - Document which weapons have which damage types

### Phase 3: Visual Feedback

- [ ] **Task 3.1**: Update `spawn_damage_number()` function in `scripts/scr_floating_text/scr_floating_text.gml`
  - Add `damage_type` parameter (default: DamageType.physical)
  - Set floating text color based on damage type using `damage_type_to_color()`

- [ ] **Task 3.2**: Create `spawn_immune_text()` function in `scripts/scr_floating_text/scr_floating_text.gml`
  - Display "IMMUNE!" text in gray
  - Use larger font size if possible
  - Match existing floating text behavior

### Phase 4: Damage Calculation Integration

- [ ] **Task 4.1**: Update player weapon attack damage calculation
  - Locate collision event in `obj_player` with `obj_enemy_parent`
  - Extract weapon's damage type from item definition
  - Call `get_damage_type_multiplier()` for target enemy
  - Apply resistance multiplier to final damage
  - Use `spawn_damage_number()` with damage type for visual feedback
  - Call `spawn_immune_text()` if multiplier is 0.0

- [ ] **Task 4.2**: Update enemy attack damage calculation
  - Locate damage event in `obj_enemy_parent` (collision or alarm)
  - Use enemy's `attack_damage_type` variable
  - Call `get_damage_type_multiplier()` for player
  - Apply resistance multiplier to final damage
  - Use `spawn_damage_number()` with damage type for visual feedback
  - Call `spawn_immune_text()` if multiplier is 0.0

- [ ] **Task 4.3**: Update all existing `spawn_damage_number()` calls
  - Find all locations where damage numbers are spawned
  - Add damage type parameter to each call
  - Verify correct damage type is passed based on context

### Phase 5: Testing & Validation

- [ ] **Task 5.1**: Create test enemy with fire immunity
  - Set fire resistance to 0.0 in Create event
  - Verify "IMMUNE!" appears when hit with fire damage
  - Verify normal damage still works

- [ ] **Task 5.2**: Create test weapon with fire damage type
  - Add fire weapon to item database if not present
  - Equip weapon and attack normal enemy
  - Verify orange damage numbers appear
  - Verify damage calculation is correct

- [ ] **Task 5.3**: Test resistance multiplier variations
  - Test 0.0 (immune) → No damage, "IMMUNE!" text
  - Test 0.5 (resistant) → Half damage, colored number
  - Test 1.0 (normal) → Full damage, colored number
  - Test 1.5 (vulnerable) → 1.5x damage, colored number
  - Test 2.0 (weak) → Double damage, colored number

- [ ] **Task 5.4**: Test all damage type colors
  - Physical → Red damage numbers
  - Magical → Blue damage numbers
  - Fire → Orange damage numbers
  - Holy → Yellow damage numbers
  - Unholy → Purple damage numbers

- [ ] **Task 5.5**: Verify backward compatibility
  - Test with weapons that don't have `damage_type` defined
  - Test with enemies that don't have `damage_resistances` defined
  - Ensure default values maintain existing behavior

- [ ] **Task 5.6**: Integration testing with wielder effects
  - Verify damage type resistance applies AFTER status effect modifiers
  - Verify damage type resistance applies BEFORE armor damage reduction
  - Test edge cases: neutralized effects + resistance, full immunity, etc.

### Phase 6: Documentation & Polish

- [ ] **Task 6.1**: Update weapon tooltips or descriptions
  - Consider adding damage type to item inspection (future enhancement)
  - Document which weapons deal which damage types for players

- [ ] **Task 6.2**: Code review and cleanup
  - Ensure all functions have proper JSDoc comments
  - Remove debug code and test objects
  - Verify naming conventions match codebase style

- [ ] **Task 6.3**: Performance check
  - Verify no FPS drops with damage type calculations
  - Ensure helper functions are efficient
  - Profile damage calculation flow if needed

## Notes

- Default all resistances to 1.0 for backward compatibility
- Default all weapons to physical damage type initially
- Resistance multipliers are applied AFTER status effects but BEFORE armor DR
- Visual feedback (colored numbers) is critical for player understanding
- Test with both player dealing damage AND player receiving damage
