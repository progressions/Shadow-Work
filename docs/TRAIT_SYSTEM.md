# Trait System Design

## Overview

A trait system for characters (both player and enemy) that allows modular gameplay effects based on character origins and attributes. Traits are lowercase string identifiers (e.g., "fireborne", "arboreal") that characters can possess, with each trait providing specific gameplay effects defined in a centralized configuration.

## Core Principles

- **Centralized Configuration**: All trait definitions stored in `global.trait_database`
- **Character-Agnostic**: Any character with a trait receives the same effects
- **Stackable**: Characters can have multiple traits simultaneously
- **Modular**: Easy to add new traits without modifying existing code
- **Data-Driven**: Effects are configured in data structures, not hardcoded

## Architecture

### 1. Trait Database Structure

Create `global.trait_database` similar to the existing `global.item_database` pattern:

```gml
global.trait_database = {
    fireborne: {
        name: "Fireborne",
        description: "Born of flame, immune to fire damage",
        effects: {
            fire_damage_modifier: 0,      // 0 = immune, 1 = normal, 2 = double damage
            ice_damage_modifier: 1.5      // Takes 50% more ice damage
        },
        visual_indicator: spr_trait_fireborne  // Optional sprite for UI
    },

    arboreal: {
        name: "Arboreal",
        description: "Tree-dweller, weak to fire",
        effects: {
            fire_damage_modifier: 1.5,    // Takes 50% more fire damage
            poison_damage_modifier: 0.5   // Takes 50% less poison damage
        }
    },

    aquatic: {
        name: "Aquatic",
        description: "Water-born creature",
        effects: {
            lightning_damage_modifier: 2.0,    // Takes double lightning damage
            fire_damage_modifier: 0.75,        // Takes 25% less fire damage
            movement_speed_water: 1.5          // 50% faster in water tiles
        }
    },

    glacial: {
        name: "Glacial",
        description: "From frozen lands",
        effects: {
            ice_damage_modifier: 0,
            fire_damage_modifier: 2.0,
            movement_speed_ice: 1.25,
            freeze_immunity: true
        }
    },

    swampridden: {
        name: "Swampridden",
        description: "Born in murky swamps",
        effects: {
            poison_damage_modifier: 0,
            disease_resistance: 0.75,
            movement_speed_swamp: 1.5
        }
    },

    sandcrawler: {
        name: "Sandcrawler",
        description: "Desert wanderer",
        effects: {
            fire_damage_modifier: 0.5,
            movement_speed_desert: 1.5,
            quicksand_immunity: true
        }
    }
}
```

### 2. Character Trait Storage

Add to character objects (`obj_player`, `obj_enemy_parent`):

```gml
// In Create_0 event
traits = [];  // Array of trait keys: ["fireborne", "aquatic"]

// Example initialization
traits = ["fireborne"];  // Player starts with fireborne trait
```

### 3. Trait Helper Functions

Create in `scripts/trait_system.gml`:

```gml
/// @function has_trait(trait_key)
/// @description Check if character has a specific trait
/// @param {string} trait_key The trait to check for
function has_trait(_trait_key) {
    for (var i = 0; i < array_length(traits); i++) {
        if (traits[i] == _trait_key) {
            return true;
        }
    }
    return false;
}

/// @function add_trait(trait_key)
/// @description Add a trait to the character
/// @param {string} trait_key The trait to add
function add_trait(_trait_key) {
    if (!has_trait(_trait_key)) {
        array_push(traits, _trait_key);
    }
}

/// @function remove_trait(trait_key)
/// @description Remove a trait from the character
/// @param {string} trait_key The trait to remove
function remove_trait(_trait_key) {
    for (var i = 0; i < array_length(traits); i++) {
        if (traits[i] == _trait_key) {
            array_delete(traits, i, 1);
            break;
        }
    }
}

/// @function get_trait_effect(trait_key, effect_name)
/// @description Get a specific effect value from a trait
/// @param {string} trait_key The trait to query
/// @param {string} effect_name The effect property name
/// @return {real|bool|undefined} The effect value or undefined if not found
function get_trait_effect(_trait_key, _effect_name) {
    if (!variable_struct_exists(global.trait_database, _trait_key)) {
        return undefined;
    }

    var _trait_def = global.trait_database[$ _trait_key];

    if (!variable_struct_exists(_trait_def.effects, _effect_name)) {
        return undefined;
    }

    return _trait_def.effects[$ _effect_name];
}

/// @function get_all_trait_modifiers(effect_name)
/// @description Get combined modifier from all traits for a specific effect
/// @param {string} effect_name The effect property name
/// @return {real} Combined modifier value (multiplicative)
function get_all_trait_modifiers(_effect_name) {
    var _modifier = 1.0;

    for (var i = 0; i < array_length(traits); i++) {
        var _trait_key = traits[i];
        var _effect_value = get_trait_effect(_trait_key, _effect_name);

        if (_effect_value != undefined) {
            _modifier *= _effect_value;
        }
    }

    return _modifier;
}

/// @function has_trait_immunity(immunity_name)
/// @description Check if character has immunity from any trait
/// @param {string} immunity_name The immunity property name
/// @return {bool} True if any trait grants this immunity
function has_trait_immunity(_immunity_name) {
    for (var i = 0; i < array_length(traits); i++) {
        var _trait_key = traits[i];
        var _immunity = get_trait_effect(_trait_key, _immunity_name);

        if (_immunity == true) {
            return true;
        }
    }

    return false;
}
```

### 4. Damage Calculation Integration

Modify existing damage functions to respect traits:

```gml
/// @function apply_damage(target, base_damage, damage_type)
/// @description Apply damage to target with trait modifiers
/// @param {instance} target The target to damage
/// @param {real} base_damage Base damage amount
/// @param {string} damage_type Type of damage (fire, ice, poison, etc.)
/// @return {real} Final damage dealt
function apply_damage(_target, _base_damage, _damage_type) {
    var _final_damage = _base_damage;

    // Build modifier key (e.g., "fire_damage_modifier")
    var _modifier_key = _damage_type + "_damage_modifier";

    // Apply trait modifiers
    with (_target) {
        var _modifier = get_all_trait_modifiers(_modifier_key);
        _final_damage *= _modifier;
    }

    // Apply damage to target
    _target.hp_current -= _final_damage;

    return _final_damage;
}
```

## Effect Categories

### Damage Modifiers
Multiplicative modifiers to incoming damage:

- `fire_damage_modifier` - Fire/burning damage
- `ice_damage_modifier` - Ice/frost damage
- `poison_damage_modifier` - Poison/toxic damage
- `lightning_damage_modifier` - Lightning/electric damage
- `physical_damage_modifier` - Physical/melee damage
- `holy_damage_modifier` - Holy/light damage
- `shadow_damage_modifier` - Shadow/dark damage

**Values:**
- `0` = Immune (no damage)
- `< 1` = Resistant (reduced damage)
- `1` = Normal damage
- `> 1` = Vulnerable (increased damage)

### Environmental Effects
Affect movement and interaction with terrain:

- `movement_speed_water` - Speed modifier in water tiles
- `movement_speed_desert` - Speed modifier in desert/sand tiles
- `movement_speed_ice` - Speed modifier on ice tiles
- `movement_speed_swamp` - Speed modifier in swamp tiles
- `movement_speed_mountain` - Speed modifier in mountainous terrain

**Values:** Multiplicative speed modifier (1.0 = normal, 1.5 = 50% faster)

### Immunity Flags
Boolean flags granting complete immunity:

- `freeze_immunity` - Cannot be frozen
- `burn_immunity` - Cannot be set on fire
- `poison_immunity` - Cannot be poisoned
- `stun_immunity` - Cannot be stunned
- `quicksand_immunity` - Not affected by quicksand
- `can_breathe_underwater` - No drowning damage

**Values:** `true` or omitted (false)

### Combat Bonuses
Passive stat increases:

- `crit_chance_bonus` - Added to critical hit chance
- `dodge_chance_bonus` - Added to dodge chance
- `attack_speed_modifier` - Multiplier to attack speed
- `damage_bonus` - Flat damage increase to all attacks
- `armor_bonus` - Added to armor/defense value

### Status Effect Resistance
Reduce duration or chance of status effects:

- `poison_resistance` - Reduces poison duration/damage
- `stun_resistance` - Reduces stun duration
- `slow_resistance` - Reduces slow effect magnitude
- `disease_resistance` - Reduces disease effects

**Values:** `0-1` range where `1` = normal, `0` = immune

### Trait Interactions
Damage modifiers based on target traits:

```gml
// Example in trait definition
fireborne: {
    name: "Fireborne",
    effects: {
        damage_vs_arboreal: 1.5,    // +50% damage to arboreal enemies
        damage_vs_aquatic: 1.25     // +25% damage to aquatic enemies
    }
}
```

## Implementation Checklist

### Core Files to Create/Modify

- [ ] **`scripts/trait_database.gml`** - Global trait definitions
- [ ] **`scripts/trait_system.gml`** - Trait helper functions
- [ ] Modify **`obj_player/Create_0.gml`** - Add `traits = []` initialization
- [ ] Modify **`obj_enemy_parent/Create_0.gml`** - Add `traits = []` initialization
- [ ] Modify damage calculation in combat system to use `apply_damage()` with trait modifiers
- [ ] Create **`obj_trait_ui`** (optional) - Display active traits to player

### Testing Scenarios

1. **Damage Type Modifiers**
   - Fireborne character takes fire damage → should be immune
   - Arboreal character takes fire damage → should take 150% damage

2. **Multiple Traits**
   - Character with both fireborne and aquatic traits
   - Verify both sets of effects apply correctly

3. **Environmental Interactions**
   - Aquatic character moves through water tiles → should be faster
   - Glacial character on ice tiles → should move faster

4. **Immunity Flags**
   - Swampridden character exposed to poison → should be immune
   - Glacial character hit by freeze effect → should be immune

## Design Decisions

### Trait Stacking
**Decision:** Traits are stackable with multiplicative modifiers.

**Rationale:** Allows interesting combinations (fireborne + sandcrawler = desert fire creature) while preventing overpowered additive stacking.

**Example:**
```gml
// Character with fireborne (0.5 ice modifier) and aquatic (0.75 fire modifier)
// Takes ice damage: 100 * 0.5 = 50 damage
// Takes fire damage: 100 * 0.75 = 75 damage
```

### Dynamic Trait Management
**Decision:** Traits can be added/removed during gameplay via `add_trait()` and `remove_trait()`.

**Rationale:** Enables:
- Status effects that temporarily grant traits
- Permanent trait acquisition through story/quests
- Equipment that grants traits while worn
- Environmental adaptation mechanics

### Trait Display
**Decision:** Traits shown in UI with lowercase identifiers and full name/description on hover.

**Rationale:**
- Lowercase feels more natural/mystical
- Full details available when needed without cluttering UI
- Consistent with existing item system display patterns

### Damage Type Nomenclature
**Decision:** Use standard fantasy damage types (fire, ice, lightning, poison, physical, holy, shadow).

**Rationale:**
- Familiar to players of RPGs
- Expandable for future damage types
- Maps clearly to trait themes (fireborne → fire immunity)

## Future Extensions

### Potential Additions

1. **Trait Levels**
   ```gml
   traits = [
       { key: "fireborne", level: 2 }  // Level 2 fireborne = stronger effects
   ]
   ```

2. **Conditional Effects**
   ```gml
   effects: {
       fire_damage_modifier: 0,
       on_fire_damage_taken: "heal_hp"  // Heal instead of taking damage
   }
   ```

3. **Trait Synergies**
   ```gml
   effects: {
       synergy_with_aquatic: {
           steam_damage_bonus: 2.0  // Fireborne + Aquatic = steam attacks
       }
   }
   ```

4. **Trait Evolution**
   - Traits evolve after meeting certain conditions
   - `fireborne` → `infernal` after dealing X fire damage

5. **Trait Conflicts**
   ```gml
   fireborne: {
       conflicts_with: ["aquatic", "glacial"]  // Cannot have both
   }
   ```

## Integration with Existing Systems

### Item System
Equipment can grant traits while worn:

```gml
// In item database
flame_ring: {
    name: "Ring of Flames",
    type: ItemType.equipment,
    grants_trait: "fireborne"
}

// In equip_item() function
if (variable_struct_exists(_item_def, "grants_trait")) {
    add_trait(_item_def.grants_trait);
}
```

### Status Effect System
Status effects can temporarily apply traits:

```gml
// Burning status could temporarily give "on_fire" trait
// Frozen status could give "frozen" trait with movement penalties
```

### Save/Load System
Traits serialize easily as string arrays:

```gml
save_data = {
    player_traits: obj_player.traits  // ["fireborne", "sandcrawler"]
}
```

## Example Trait Definitions

```gml
global.trait_database = {
    // Environmental Origin Traits
    fireborne: {
        name: "Fireborne",
        description: "Born of flame, immune to fire but weak to ice",
        effects: {
            fire_damage_modifier: 0,
            ice_damage_modifier: 1.5,
            burn_immunity: true
        }
    },

    arboreal: {
        name: "Arboreal",
        description: "Tree-dweller, weak to fire and axes",
        effects: {
            fire_damage_modifier: 1.5,
            poison_damage_modifier: 0.5,
            movement_speed_forest: 1.3
        }
    },

    aquatic: {
        name: "Aquatic",
        description: "Water-born, vulnerable to lightning",
        effects: {
            lightning_damage_modifier: 2.0,
            fire_damage_modifier: 0.75,
            movement_speed_water: 1.5,
            can_breathe_underwater: true
        }
    },

    glacial: {
        name: "Glacial",
        description: "From frozen lands, moves easily on ice",
        effects: {
            ice_damage_modifier: 0,
            fire_damage_modifier: 2.0,
            movement_speed_ice: 1.25,
            freeze_immunity: true
        }
    },

    swampridden: {
        name: "Swampridden",
        description: "Born in murky swamps, resistant to disease",
        effects: {
            poison_damage_modifier: 0,
            disease_resistance: 0.75,
            movement_speed_swamp: 1.5
        }
    },

    sandcrawler: {
        name: "Sandcrawler",
        description: "Desert wanderer, adapted to heat and sand",
        effects: {
            fire_damage_modifier: 0.5,
            movement_speed_desert: 1.5,
            quicksand_immunity: true
        }
    },

    // Combat Traits
    berserker: {
        name: "Berserker",
        description: "Raging warrior with increased damage but lower defense",
        effects: {
            damage_bonus: 5,
            physical_damage_modifier: 1.25,
            crit_chance_bonus: 0.1
        }
    },

    nimble: {
        name: "Nimble",
        description: "Quick and evasive",
        effects: {
            dodge_chance_bonus: 0.15,
            attack_speed_modifier: 1.2,
            movement_speed_modifier: 1.1
        }
    },

    // Supernatural Traits
    undead: {
        name: "Undead",
        description: "Neither living nor dead",
        effects: {
            holy_damage_modifier: 2.0,
            shadow_damage_modifier: 0,
            poison_immunity: true,
            disease_immunity: true
        }
    },

    celestial: {
        name: "Celestial",
        description: "Blessed by divine power",
        effects: {
            holy_damage_modifier: 0.5,
            shadow_damage_modifier: 1.5,
            crit_chance_bonus: 0.1
        }
    }
}
```