# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-04-melee-ranged-damage-reduction/spec.md

## Technical Requirements

### 1. Attack Category System

**Enum Definition:**
- Create `AttackCategory` enum in appropriate GML script file (likely `scr_combat_system.gml` or new `scr_damage_types.gml`)
- Values: `melee`, `ranged`

**Attack Object Tagging:**
- `objects/obj_attack/Create_0.gml`: Add `attack_category = AttackCategory.melee`
- `objects/obj_arrow/Create_0.gml`: Add `attack_category = AttackCategory.ranged`
- `objects/obj_enemy_attack/Create_0.gml`: Add `attack_category = AttackCategory.melee`
- `objects/obj_enemy_arrow/Create_0.gml`: Add `attack_category = AttackCategory.ranged`

### 2. Damage Reduction Functions

**File:** `scripts/scr_combat_system/scr_combat_system.gml`

**New Functions:**

```gml
/// @function get_melee_damage_reduction()
/// @description Calculate total melee DR from equipment, traits, status effects, companions
function get_melee_damage_reduction() {
    var _total_dr = 0;

    // Equipment DR
    _total_dr += get_equipment_melee_dr();

    // General DR also applies to melee
    _total_dr += get_equipment_general_dr();

    // Companion DR bonuses
    _total_dr += get_companion_melee_dr_bonus();

    // Trait modifiers (future)
    // Status effect modifiers (future)

    return _total_dr;
}

/// @function get_ranged_damage_reduction()
/// @description Calculate total ranged DR from equipment, traits, status effects, companions
function get_ranged_damage_reduction() {
    var _total_dr = 0;

    // Equipment DR
    _total_dr += get_equipment_ranged_dr();

    // General DR also applies to ranged
    _total_dr += get_equipment_general_dr();

    // Companion DR bonuses
    _total_dr += get_companion_ranged_dr_bonus();

    // Trait modifiers (future)
    // Status effect modifiers (future)

    return _total_dr;
}

/// @function get_equipment_melee_dr()
/// @description Sum melee_damage_reduction from all equipped items
function get_equipment_melee_dr() {
    var _total = 0;
    var _slots = ["head", "torso", "legs", "left_hand", "right_hand"];

    for (var i = 0; i < array_length(_slots); i++) {
        if (equipped[$ _slots[i]] != undefined) {
            var _stats = equipped[$ _slots[i]].definition.stats;
            if (variable_struct_exists(_stats, "melee_damage_reduction")) {
                _total += _stats.melee_damage_reduction;
            }
        }
    }
    return _total;
}

/// @function get_equipment_ranged_dr()
/// @description Sum ranged_damage_reduction from all equipped items
function get_equipment_ranged_dr() {
    var _total = 0;
    var _slots = ["head", "torso", "legs", "left_hand", "right_hand"];

    for (var i = 0; i < array_length(_slots); i++) {
        if (equipped[$ _slots[i]] != undefined) {
            var _stats = equipped[$ _slots[i]].definition.stats;
            if (variable_struct_exists(_stats, "ranged_damage_reduction")) {
                _total += _stats.ranged_damage_reduction;
            }
        }
    }
    return _total;
}

/// @function get_equipment_general_dr()
/// @description Sum general damage_reduction from all equipped items (applies to both melee and ranged)
function get_equipment_general_dr() {
    var _total = 0;
    var _slots = ["head", "torso", "legs", "left_hand", "right_hand"];

    for (var i = 0; i < array_length(_slots); i++) {
        if (equipped[$ _slots[i]] != undefined) {
            var _stats = equipped[$ _slots[i]].definition.stats;
            if (variable_struct_exists(_stats, "damage_reduction")) {
                _total += _stats.damage_reduction;
            }
        }
    }
    return _total;
}
```

**Deprecation:**
- Mark `get_total_defense()` function as deprecated (comment: "// DEPRECATED: Use get_melee_damage_reduction() or get_ranged_damage_reduction() instead")
- Keep function for backward compatibility but update internals to use new system

### 3. Companion DR System Updates

**File:** `scripts/scr_companion_system/scr_companion_system.gml`

**Updated Functions:**

```gml
/// @function get_companion_melee_dr_bonus()
/// @description Calculate total melee DR bonus from all active companions
function get_companion_melee_dr_bonus() {
    var total_dr = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Check all auras for melee DR bonuses
        var _aura_names = variable_struct_get_names(companion.auras);
        for (var j = 0; j < array_length(_aura_names); j++) {
            var _aura_name = _aura_names[j];
            var _aura = companion.auras[$ _aura_name];

            if (_aura.active) {
                // General DR applies to melee
                if (variable_struct_exists(_aura, "damage_reduction")) {
                    total_dr += _aura.damage_reduction;
                }
                // Melee-specific DR
                if (variable_struct_exists(_aura, "melee_damage_reduction")) {
                    total_dr += _aura.melee_damage_reduction;
                }
            }
        }

        // Check triggers for melee DR bonuses
        var _trigger_names = variable_struct_get_names(companion.triggers);
        for (var j = 0; j < array_length(_trigger_names); j++) {
            var _trigger_name = _trigger_names[j];
            var _trigger = companion.triggers[$ _trigger_name];

            if (_trigger.active) {
                if (variable_struct_exists(_trigger, "damage_reduction")) {
                    total_dr += _trigger.damage_reduction;
                }
                if (variable_struct_exists(_trigger, "melee_damage_reduction")) {
                    total_dr += _trigger.melee_damage_reduction;
                }
            }
        }
    }

    return total_dr;
}

/// @function get_companion_ranged_dr_bonus()
/// @description Calculate total ranged DR bonus from all active companions
function get_companion_ranged_dr_bonus() {
    var total_dr = 0;
    var companions = get_active_companions();

    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];

        // Check all auras for ranged DR bonuses
        var _aura_names = variable_struct_get_names(companion.auras);
        for (var j = 0; j < array_length(_aura_names); j++) {
            var _aura_name = _aura_names[j];
            var _aura = companion.auras[$ _aura_name];

            if (_aura.active) {
                // General DR applies to ranged
                if (variable_struct_exists(_aura, "damage_reduction")) {
                    total_dr += _aura.damage_reduction;
                }
                // Ranged-specific DR (Hola's wind_ward uses this)
                if (variable_struct_exists(_aura, "ranged_damage_reduction")) {
                    total_dr += _aura.ranged_damage_reduction;
                }
                // Legacy: projectile_dr maps to ranged_damage_reduction
                if (variable_struct_exists(_aura, "projectile_dr")) {
                    total_dr += _aura.projectile_dr;
                }
            }
        }

        // Check triggers for ranged DR bonuses
        var _trigger_names = variable_struct_get_names(companion.triggers);
        for (var j = 0; j < array_length(_trigger_names); j++) {
            var _trigger_name = _trigger_names[j];
            var _trigger = companion.triggers[$ _trigger_name];

            if (_trigger.active) {
                if (variable_struct_exists(_trigger, "damage_reduction")) {
                    total_dr += _trigger.damage_reduction;
                }
                if (variable_struct_exists(_trigger, "ranged_damage_reduction")) {
                    total_dr += _trigger.ranged_damage_reduction;
                }
            }
        }
    }

    return total_dr;
}
```

**Deprecation:**
- Mark `get_companion_dr_bonus()` as deprecated but keep for compatibility
- Update its implementation to call `get_companion_melee_dr_bonus()` for backward compatibility

### 4. Damage Calculation Updates

**File:** `objects/obj_enemy_parent/Alarm_2.gml` (Enemy melee attack hitting player)

**Lines 27-35 Update:**

```gml
// Determine attack category and get appropriate DR
var _attack_category = AttackCategory.melee; // Enemy melee attack
var _player_dr = 0;
with (_player) {
    if (_attack_category == AttackCategory.melee) {
        _player_dr = get_melee_damage_reduction();
    } else {
        _player_dr = get_ranged_damage_reduction();
    }
}

var _after_defense = _after_resistance - _player_dr;
```

**File:** `objects/obj_enemy_arrow/Step_0.gml` (Enemy ranged attack hitting player)

**Lines 30-33 Update:**

```gml
// Determine attack category and get appropriate DR
var _attack_category = attack_category; // Should be AttackCategory.ranged
var _player_dr = 0;
with (_hit_player) {
    if (_attack_category == AttackCategory.melee) {
        _player_dr = get_melee_damage_reduction();
    } else {
        _player_dr = get_ranged_damage_reduction();
    }
}

var _after_defense = _after_resistance - _player_dr;
```

**Similar updates needed for:**
- Any player collision events with enemies (if exists)
- Any other damage calculation locations

### 5. Item Database Updates

**File:** `scripts/scr_item_database/scr_item_database.gml`

**Shield Updates (lines 166-172):**

Remove `block_chance`, add separate DR stats:

```gml
shield: new create_item_definition(
    18, "shield", "Shield", ItemType.armor, EquipSlot.left_hand,
    {
        melee_damage_reduction: 3,
        ranged_damage_reduction: 8
    }
),
greatshield: new create_item_definition(
    19, "greatshield", "Greatshield", ItemType.armor, EquipSlot.left_hand,
    {
        melee_damage_reduction: 5,
        ranged_damage_reduction: 12,
        speed_modifier: 0.85,
        trait_grants: [{trait: "physical_resistance", stacks: 1}]
    }
),
```

**Armor Conversion:**

Convert existing `defense` stats to `damage_reduction` (general, applies to both):

```gml
// Example: Leather armor
leather_helmet: new create_item_definition(
    12, "leather_helmet", "Leather Helmet", ItemType.armor, EquipSlot.helmet,
    {damage_reduction: 2, speed_modifier: 1.0}
),
```

### 6. Hola Companion Updates

**File:** `objects/obj_hola/Create_0.gml`

**Lines 23-26 Update:**

```gml
wind_ward: {
    active: false, // Activated on recruitment
    ranged_damage_reduction: 3 // Strong resistance to ranged damage
},
```

Remove old `projectile_dr` property, replace with `ranged_damage_reduction`.

## External Dependencies

None. This spec uses existing GameMaker Studio 2 and GML functionality.

## Performance Considerations

- DR calculation functions are called during damage events (not every frame)
- Minimal performance impact expected
- Companion DR functions already iterate through active companions; adding melee/ranged split doesn't increase iteration count

## Testing Approach

- Debug mode should display:
  - Attack category (melee/ranged) and damage type (physical/fire/etc)
  - Player's current melee DR and ranged DR values
  - Damage calculation breakdown showing DR application
- Test cases:
  - Player with no equipment takes full damage from melee and ranged
  - Player with shield takes reduced ranged damage (more reduction than melee)
  - Player with Hola recruited takes additional reduced ranged damage
  - General armor DR applies to both melee and ranged attacks equally
