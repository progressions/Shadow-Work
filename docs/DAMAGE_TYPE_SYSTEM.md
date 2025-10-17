# Damage Type System - Technical Documentation

This document provides comprehensive technical documentation for the damage type system in Shadow Work, including type definitions, integration points, and visual feedback.

---

## Table of Contents

1. [DamageType Enum](#damagetype-enum)
2. [Integration Points](#integration-points)
3. [Visual Feedback](#visual-feedback)
4. [Adding New Damage Types](#adding-new-damage-types)

---

## DamageType Enum

The damage type system categorizes all damage sources for resistance/vulnerability calculations and visual feedback.

**Location:** `/scripts/scr_enums/scr_enums.gml`

### Enum Definition

```gml
enum DamageType {
    physical,   // Swords, daggers, unarmed attacks
    magical,    // Generic magical damage
    fire,       // Burning, fire-based attacks
    ice,        // Freezing, ice-based attacks
    lightning,  // Electrical damage
    poison,     // Toxins, venom
    disease,    // Plague, corruption
    holy,       // Divine, blessed damage
    unholy      // Dark, cursed damage
}
```

### Default Values

When no damage type is specified:
- **Weapons default to:** `DamageType.physical`
- **Spells/magic default to:** `DamageType.magical`
- **Status effects:** Use appropriate type (burning = fire, poisoned = poison)

---

## Integration Points

### 1. Weapons

Each weapon has a `damage_type` property in its stats:

```gml
// In global.item_database
rusty_sword: {
    item_id: "rusty_sword",
    type: ItemType.weapon,
    stats: {
        attack_damage: 5,
        attack_speed: 1.0,
        attack_range: 32,
        damage_type: DamageType.physical  // Default for most weapons
    }
}
```

**Special Weapon Examples:**

```gml
// Flaming sword
flaming_blade: {
    stats: {
        attack_damage: 8,
        damage_type: DamageType.fire
    }
}

// Frost dagger
ice_dagger: {
    stats: {
        attack_damage: 4,
        damage_type: DamageType.ice
    }
}

// Venomous weapon
poisoned_blade: {
    stats: {
        attack_damage: 6,
        damage_type: DamageType.poison
    }
}
```

**Location:** `/scripts/scripts.gml` (item database initialization)

### 2. Status Effects

Status effects apply damage with specific types:

```gml
// Burning status effect
case "burning":
    damage_per_tick = 1;
    damage_type = DamageType.fire;
    duration = 3.0;  // 3 seconds
    tick_interval = 0.5;  // Every 0.5 seconds
    break;

// Poisoned status effect
case "poisoned":
    damage_per_tick = 2;
    damage_type = DamageType.poison;
    duration = 5.0;
    tick_interval = 1.0;
    break;
```

**Location:** `/scripts/scr_status_effects/scr_status_effects.gml`

### 3. Traits

Traits modify incoming damage based on type:

```gml
// In global.trait_database
fire_resistance: {
    trait_key: "fire_resistance",
    display_name: "Fire Resistance",
    description: "Reduces fire damage taken",
    damage_type_affected: DamageType.fire,
    multiplier_per_stack: 0.75,  // 25% reduction per stack
    max_stacks: 5,
    opposing_trait: "fire_vulnerability"
}

fire_vulnerability: {
    trait_key: "fire_vulnerability",
    display_name: "Fire Vulnerability",
    description: "Increases fire damage taken",
    damage_type_affected: DamageType.fire,
    multiplier_per_stack: 1.5,  // 50% increase per stack
    max_stacks: 5,
    opposing_trait: "fire_resistance"
}

fire_immunity: {
    trait_key: "fire_immunity",
    display_name: "Fire Immunity",
    description: "Completely immune to fire damage",
    damage_type_affected: DamageType.fire,
    multiplier_per_stack: 0.0,  // No damage
    max_stacks: 1,
    opposing_trait: "fire_vulnerability"
}
```

**Damage Type Trait Pattern:**

For each damage type, there are typically three trait variants:
- `{type}_resistance` - Reduces damage (0.75x per stack)
- `{type}_vulnerability` - Increases damage (1.5x per stack)
- `{type}_immunity` - Negates damage (0.0x, max 1 stack)

**Location:** `/objects/obj_game_controller/Create_0.gml` (trait database initialization)

### 4. Enemy Tags

Tags apply trait bundles that often include damage type modifiers:

```gml
// In global.tag_database
fireborne: {
    tag_name: "fireborne",
    traits: [
        {trait_key: "fire_immunity", stacks: 1},
        {trait_key: "ice_vulnerability", stacks: 2}
    ]
}

arboreal: {
    tag_name: "arboreal",
    traits: [
        {trait_key: "fire_vulnerability", stacks: 2},
        {trait_key: "poison_resistance", stacks: 1}
    ]
}

aquatic: {
    tag_name: "aquatic",
    traits: [
        {trait_key: "lightning_vulnerability", stacks: 2},
        {trait_key: "fire_resistance", stacks: 1}
    ]
}

glacial: {
    tag_name: "glacial",
    traits: [
        {trait_key: "ice_immunity", stacks: 1},
        {trait_key: "fire_vulnerability", stacks: 2}
    ]
}

venomous: {
    tag_name: "venomous",
    traits: [
        {trait_key: "poison_immunity", stacks: 1},
        {trait_key: "deals_poison_damage", stacks: 1}
    ]
}
```

**Usage:**
```gml
// In enemy Create event
array_push(tags, "fireborne");
apply_tag_traits();  // Applies all traits from tag
```

**Location:** `/objects/obj_game_controller/Create_0.gml` (tag database initialization)

### 5. Projectiles and Hazards

Projectiles and hazards carry damage type information:

```gml
// Hazard projectile
projectile.damage_type = DamageType.fire;
projectile.damage_amount = 3;

// Enemy arrow
arrow.damage_type = ranged_damage_type;  // From enemy config

// Hazard (fire)
hazard.damage_type = DamageType.fire;
hazard.damage_mode = "continuous";
```

**Locations:**
- `/objects/obj_hazard_projectile/Create_0.gml`
- `/objects/obj_enemy_arrow/Create_0.gml`
- `/objects/obj_fire/Create_0.gml`
- `/objects/obj_poison/Create_0.gml`

---

## Visual Feedback

### Damage Number Colors

Damage numbers are color-coded by type for instant visual feedback:

```gml
function damage_type_to_color(_damage_type) {
    switch(_damage_type) {
        case DamageType.physical:   return c_white;
        case DamageType.magical:    return c_fuchsia;
        case DamageType.fire:       return c_red;
        case DamageType.ice:        return c_aqua;
        case DamageType.lightning:  return c_yellow;
        case DamageType.poison:     return c_lime;
        case DamageType.disease:    return c_olive;
        case DamageType.holy:       return make_color_rgb(255, 215, 0);  // Gold
        case DamageType.unholy:     return make_color_rgb(128, 0, 128);  // Dark purple
        default:                    return c_white;
    }
}
```

**Location:** `/scripts/scr_damage_type_helpers/scr_damage_type_helpers.gml`

### Usage in Damage Numbers

```gml
// Spawn damage number with color
var color = damage_type_to_color(damage_type);
spawn_damage_number(x, y - 16, final_damage, damage_type);

// Inside spawn_damage_number:
var damage_obj = instance_create_layer(x, y, "Instances", obj_damage_number);
damage_obj.damage_amount = damage;
damage_obj.text_color = damage_type_to_color(damage_type);
damage_obj.is_crit = is_crit;  // Larger font if true
```

### Hit Effects by Type

Different hit effects can be spawned based on damage type:

```gml
function spawn_damage_effect(x, y, damage_type) {
    switch(damage_type) {
        case DamageType.fire:
            // Spawn fire particles
            break;

        case DamageType.ice:
            // Spawn frost/snow particles
            break;

        case DamageType.lightning:
            // Spawn electric sparks
            break;

        case DamageType.poison:
            // Spawn poison bubbles
            break;

        default:
            // Default hit sparkles
            spawn_hit_effect(x, y, direction);
            break;
    }
}
```

---

## Adding New Damage Types

To add a new damage type to the system:

### Step 1: Add to Enum

```gml
// In /scripts/scr_enums/scr_enums.gml
enum DamageType {
    physical,
    magical,
    fire,
    ice,
    lightning,
    poison,
    disease,
    holy,
    unholy,
    arcane,     // NEW: Add new type here
    nature      // NEW: Another example
}
```

### Step 2: Add Color Mapping

```gml
// In /scripts/scr_damage_type_helpers/scr_damage_type_helpers.gml
function damage_type_to_color(_damage_type) {
    switch(_damage_type) {
        // ... existing cases ...

        case DamageType.arcane:
            return make_color_rgb(138, 43, 226);  // Blue-violet

        case DamageType.nature:
            return c_green;

        default:
            return c_white;
    }
}
```

### Step 3: Create Traits

```gml
// In /objects/obj_game_controller/Create_0.gml - init_trait_database()
global.trait_database.arcane_resistance = {
    trait_key: "arcane_resistance",
    display_name: "Arcane Resistance",
    description: "Reduces arcane damage taken",
    damage_type_affected: DamageType.arcane,
    multiplier_per_stack: 0.75,
    max_stacks: 5,
    opposing_trait: "arcane_vulnerability"
};

global.trait_database.arcane_vulnerability = {
    trait_key: "arcane_vulnerability",
    display_name: "Arcane Vulnerability",
    description: "Increases arcane damage taken",
    damage_type_affected: DamageType.arcane,
    multiplier_per_stack: 1.5,
    max_stacks: 5,
    opposing_trait: "arcane_resistance"
};

global.trait_database.arcane_immunity = {
    trait_key: "arcane_immunity",
    display_name: "Arcane Immunity",
    description: "Completely immune to arcane damage",
    damage_type_affected: DamageType.arcane,
    multiplier_per_stack: 0.0,
    max_stacks: 1,
    opposing_trait: "arcane_vulnerability"
};
```

### Step 4: Add to Tags (Optional)

```gml
// In /objects/obj_game_controller/Create_0.gml - init_tag_database()
global.tag_database.arcanist = {
    tag_name: "arcanist",
    traits: [
        {trait_key: "arcane_immunity", stacks: 1},
        {trait_key: "physical_vulnerability", stacks: 1}
    ]
};
```

### Step 5: Create Weapons/Effects

```gml
// In /scripts/scripts.gml - item database
arcane_staff: {
    item_id: "arcane_staff",
    type: ItemType.weapon,
    stats: {
        attack_damage: 10,
        attack_speed: 0.8,
        attack_range: 48,
        damage_type: DamageType.arcane  // Use new type
    }
}
```

### Step 6: Add Visual Effects (Optional)

```gml
// In spawn_damage_effect() or similar
case DamageType.arcane:
    // Create purple sparkles or arcane runes
    part_type_color1(arcane_particle, make_color_rgb(138, 43, 226));
    break;
```

---

## Damage Type Conversion

### String to Enum

```gml
function string_to_damage_type(_string) {
    switch(_string) {
        case "physical":   return DamageType.physical;
        case "magical":    return DamageType.magical;
        case "fire":       return DamageType.fire;
        case "ice":        return DamageType.ice;
        case "lightning":  return DamageType.lightning;
        case "poison":     return DamageType.poison;
        case "disease":    return DamageType.disease;
        case "holy":       return DamageType.holy;
        case "unholy":     return DamageType.unholy;
        default:           return DamageType.physical;
    }
}
```

### Enum to String

```gml
function damage_type_to_string(_damage_type) {
    switch(_damage_type) {
        case DamageType.physical:   return "physical";
        case DamageType.magical:    return "magical";
        case DamageType.fire:       return "fire";
        case DamageType.ice:        return "ice";
        case DamageType.lightning:  return "lightning";
        case DamageType.poison:     return "poison";
        case DamageType.disease:    return "disease";
        case DamageType.holy:       return "holy";
        case DamageType.unholy:     return "unholy";
        default:                    return "physical";
    }
}
```

**Location:** `/scripts/scr_damage_type_helpers/scr_damage_type_helpers.gml`

---

## Key Files Reference

| File | Purpose | Key Lines |
|------|---------|-----------|
| `/scripts/scr_enums/scr_enums.gml` | DamageType enum definition | Full file |
| `/scripts/scr_damage_type_helpers/scr_damage_type_helpers.gml` | Conversion and color functions | Full file |
| `/objects/obj_game_controller/Create_0.gml` | Trait and tag database initialization | Full file |
| `/scripts/trait_system/trait_system.gml` | Damage type modifier calculation | Full file |
| `/scripts/scripts.gml` | Item database with weapon damage types | Full file |
| `/scripts/scr_status_effects/scr_status_effects.gml` | Status effect damage types | Full file |

---

*Last Updated: 2025-10-17*
