# Spec Requirements Document

> Spec: damage-type-system
> Created: 2025-09-30
> Status: Planning

## Overview

Add damage type categorization to Shadow Work's combat system, enabling different types of damage (physical, magical, fire, holy, unholy) with a resistance and immunity system. This will allow for trait and status effect interactions where entities can be immune to, resistant to, or vulnerable to specific damage types, creating deeper combat mechanics and build variety.

The system will classify all damage sources by type and apply multipliers based on the target's resistance values before final damage calculation. This enables gameplay scenarios like fire-immune enemies, holy damage bonus against undead, or status effects that grant temporary resistances.

## User Stories

### Player Experiences Immunity
**As a player**, when I encounter an enemy with fire immunity and attack it with a fire weapon, I want to see "IMMUNE!" displayed and deal zero damage, so I understand I need to switch to a different damage type.

### Enemy Deals Typed Damage
**As a player**, when I'm attacked by an enemy that deals fire damage, I want fire-themed visual feedback (orange damage numbers) and the ability to use fire resistance items/traits to reduce the damage taken.

### Resistance Modifiers
**As a player**, when I equip armor or activate a trait that grants holy resistance, I want incoming holy damage to be reduced by the resistance percentage, allowing me to build defensive strategies against specific enemy types.

### Visual Damage Feedback
**As a player**, when damage is dealt of any type, I want to see color-coded floating damage numbers that indicate the damage type (red for physical, blue for magical, orange for fire, yellow for holy, purple for unholy), making combat clearer and more readable.

## Spec Scope

### In Scope

1. **DamageType Enum Creation**
   - Create `DamageType` enum with values: physical, magical, fire, holy, unholy
   - Set physical as default damage type for backward compatibility

2. **Weapon Damage Type Assignment**
   - Add `damage_type` property to item database for weapons
   - Assign appropriate damage types to all existing weapons (most physical, some magical)
   - Support damage type specification in attack spawning

3. **Enemy Damage Type Assignment**
   - Add `attack_damage_type` property to `obj_enemy_parent`
   - Override in enemy child objects to specify their attack damage type
   - Pass damage type through collision/alarm damage events

4. **Resistance System**
   - Add `damage_resistances` struct to entities (player and enemies)
   - Default all resistances to 1.0 (normal damage)
   - Support multipliers: 0.0 (immune), 0.5 (resistant), 1.0 (normal), 1.5 (vulnerable), 2.0 (weak)

5. **Damage Calculation Integration**
   - Integrate resistance multipliers into existing damage calculation flow
   - Apply after status effect modifiers, before armor damage reduction
   - Round final damage to integer values

6. **Helper Functions**
   - `get_damage_type_multiplier(target, damage_type)` - Retrieve resistance value
   - `set_damage_resistance(target, damage_type, multiplier)` - Set resistance
   - `damage_type_to_string(damage_type)` - Convert enum to readable string
   - `damage_type_to_color(damage_type)` - Get color for visual feedback

7. **Visual Feedback**
   - Color-coded damage numbers by type (physical=red, magical=blue, fire=orange, holy=yellow, unholy=purple)
   - Display "IMMUNE!" text when damage is fully blocked (multiplier 0.0)
   - Maintain existing floating text behavior with color variations

8. **Testing Examples**
   - Create test enemy with fire immunity (multiplier 0.0)
   - Create test weapon with fire damage type
   - Verify resistance calculations with various multiplier values

## Out of Scope

The following features are explicitly excluded from this initial implementation and reserved for future phases:

1. **Elemental Interactions**
   - Fire vs Ice counters
   - Water conducts lightning
   - Environmental weakness chains

2. **Combo/Hybrid Damage**
   - Weapons dealing multiple damage types simultaneously
   - Split damage calculations (50% fire, 50% physical)

3. **Environmental Damage**
   - Terrain-based damage types (lava pools, poison gas)
   - Weather effects on damage types

4. **Damage Over Time (DoT) Typing**
   - Typed damage for burn/poison/bleed effects
   - Status effect resistance based on damage type

5. **Dynamic Resistance Changes**
   - Resistances that change based on player state
   - Temporary buffs/debuffs modifying resistances (will be Phase 2 with status effect expansion)

6. **Enemy AI Awareness**
   - Enemies switching tactics based on player resistances
   - Smart weapon selection

## Expected Deliverable

A working damage type system where:

1. All weapons have assigned damage types (defaulting to physical)
2. All enemies have attack damage types (defaulting to physical)
3. Damage calculations apply resistance multipliers correctly
4. Setting an entity's fire resistance to 0.0 makes them immune to fire damage
5. Colored floating damage numbers appear based on damage type
6. "IMMUNE!" text displays when damage is blocked by immunity
7. The system integrates seamlessly with existing wielder effects and status effects
8. Default multipliers of 1.0 ensure backward compatibility with existing gameplay

## Spec Documentation

- Tasks: @.agent-os/specs/2025-09-30-damage-type-system/tasks.md
- Technical Specification: @.agent-os/specs/2025-09-30-damage-type-system/sub-specs/technical-spec.md
