# Trait System v2.0 - Tag-Based Stacking Traits

## Overview

The trait system provides damage type resistances and vulnerabilities through a tag-based architecture with stacking mechanics inspired by Age of Wonders 4. Tags grant bundles of traits, and traits stack up to 5 times with opposite traits canceling stack-by-stack.

## Core Principles

- **Tag/Trait Separation**: Tags (fireborne, arboreal) grant bundles of individual traits (fire_immunity, ice_vulnerability)
- **Stacking Mechanics**: Traits stack up to 5 times with multiplicative effects
- **Opposite Cancellation**: Immunity vs vulnerability and resistance vs vulnerability cancel stack-by-stack
- **Permanent vs Temporary**: Permanent traits from tags/quests, temporary traits from equipment/buffs
- **Status Effects as Traits**: Burning, wet, empowered, and similar effects are defined as timed traits in `global.trait_database`
- **Single Source of Truth**: All damage modifiers flow through trait system

## Architecture

### 1. Damage Types

```gml
enum DamageType {
    physical,
    magical,
    fire,
    ice,
    lightning,
    poison,
    disease,
    holy,
    unholy
}
```

### 2. Resistance Levels

```gml
enum ResistanceLevel {
    immune,      // 0.0x damage (complete immunity)
    resistant,   // 0.75x damage per stack (multiplicative)
    normal,      // 1.0x damage
    vulnerable   // 1.5x damage per stack (multiplicative)
}
```

### 3. Tag Database

Tags are thematic descriptors that grant bundles of traits. Defined in `obj_game_controller/Create_0.gml`:

```gml
global.tag_database = {
    fireborne: {
        name: "Fireborne",
        description: "Born of flame, immune to fire but weak to ice",
        grants_traits: ["fire_immunity", "ice_vulnerability"]
    },

    arboreal: {
        name: "Arboreal",
        description: "Forest dweller, vulnerable to fire, resistant to poison",
        grants_traits: ["fire_vulnerability", "poison_resistance"]
    },

    aquatic: {
        name: "Aquatic",
        description: "Water-born, vulnerable to lightning, resistant to fire",
        grants_traits: ["lightning_vulnerability", "fire_resistance"]
    },

    glacial: {
        name: "Glacial",
        description: "From frozen lands, immune to ice but weak to fire",
        grants_traits: ["ice_immunity", "fire_vulnerability"]
    },

    swampridden: {
        name: "Swampridden",
        description: "Born in swamps, immune to poison and disease",
        grants_traits: ["poison_immunity", "disease_immunity"]
    },

    sandcrawler: {
        name: "Sandcrawler",
        description: "Desert wanderer, resistant to fire",
        grants_traits: ["fire_resistance"]
    },

    venomous: {
        name: "Venomous",
        description: "Toxic creature, immune to poison",
        grants_traits: ["poison_immunity"]
    }
}
```

### 4. Trait Database

Individual traits with stacking mechanics. Defined in `obj_game_controller/Create_0.gml`:

```gml
global.trait_database = {
    // Fire traits
    fire_immunity: {
        name: "Fire Immunity",
        damage_modifier: 0.0,
        opposite_trait: "fire_vulnerability",
        max_stacks: 5
    },
    fire_resistance: {
        name: "Fire Resistance",
        damage_modifier: 0.75,
        opposite_trait: "fire_vulnerability",
        max_stacks: 5
    },
    fire_vulnerability: {
        name: "Fire Vulnerability",
        damage_modifier: 1.5,
        opposite_trait: "fire_immunity",
        max_stacks: 5
    },

    // Ice traits
    ice_immunity: { /* ... */ },
    ice_resistance: { /* ... */ },
    ice_vulnerability: { /* ... */ },

    // Lightning, poison, disease, holy, unholy...
    // (Pattern repeats for each damage type)
}
```

### 5. Character Trait Storage

Both player and enemies store traits in two structs:

```gml
// In obj_player/Create_0.gml and obj_enemy_parent/Create_0.gml
permanent_traits = {}; // From tags, quests (cannot be removed)
temporary_traits = {};  // From equipment, companions, buffs (removable)
```

**Storage format:**
```gml
permanent_traits = {
    fire_immunity: 1,      // 1 stack of fire immunity
    ice_vulnerability: 1   // 1 stack of ice vulnerability
}
```

## Stacking Mechanics

### Basic Stacking

Traits stack up to 5 times with **multiplicative** effects:

- **Resistance**: 1 stack = 0.75x, 2 stacks = 0.75² = 0.5625x, 3 stacks = 0.421875x
- **Vulnerability**: 1 stack = 1.5x, 2 stacks = 1.5² = 2.25x, 3 stacks = 3.375x
- **Immunity**: Always 0.0x regardless of stacks (but stacks matter for cancellation)

### Opposite Trait Cancellation (Age of Wonders Style)

Opposite traits cancel **stack-by-stack**:

**Example 1: Immunity vs Vulnerability**
```
fire_immunity(3) + fire_vulnerability(2) = net fire_immunity(1)
Result: 0.0x damage (still immune with 1 stack remaining)
```

**Example 2: Vulnerability Overcomes Immunity**
```
fire_immunity(2) + fire_vulnerability(3) = net fire_vulnerability(1)
Result: 1.5x damage (vulnerability won)
```

**Example 3: Resistance vs Vulnerability**
```
fire_resistance(3) + fire_vulnerability(2) = net fire_resistance(1)
Result: 0.75x damage
```

**Example 4: Perfect Cancellation**
```
fire_resistance(2) + fire_vulnerability(2) = perfect cancel
Result: 1.0x damage (normal)
```

### Calculation Priority

1. **Immunity Check**: If net immunity > 0, return 0.0x
2. **Immunity Cancelled**: If vulnerability > immunity, return vulnerability multiplier
3. **Resistance vs Vulnerability**: Calculate net stacks, apply appropriate multiplier
4. **No Traits**: Return 1.0x (normal damage)

## Core Functions

Location: `scripts/trait_system/trait_system.gml`

### has_trait(trait_key)
Check if character has a specific trait (1+ stacks).

```gml
function has_trait(_trait_key) {
    return get_total_trait_stacks(_trait_key) > 0;
}
```

### get_total_trait_stacks(trait_key)
Get total stacks from permanent + temporary (capped at 5).

```gml
function get_total_trait_stacks(_trait_key) {
    var _perm_stacks = permanent_traits[$ _trait_key] ?? 0;
    var _temp_stacks = temporary_traits[$ _trait_key] ?? 0;
    return min(_perm_stacks + _temp_stacks, 5);
}
```

### add_permanent_trait(trait_key)
Add a permanent trait stack (from tags, quest rewards).

```gml
function add_permanent_trait(_trait_key) {
    if (!variable_instance_exists(self, "permanent_traits")) {
        permanent_traits = {};
    }
    var _current = permanent_traits[$ _trait_key] ?? 0;
    permanent_traits[$ _trait_key] = min(_current + 1, 5);
}
```

### add_temporary_trait(trait_key)
Add a temporary trait stack (from equipment, companions, buffs).

```gml
function add_temporary_trait(_trait_key) {
    if (!variable_instance_exists(self, "temporary_traits")) {
        temporary_traits = {};
    }
    var _current = temporary_traits[$ _trait_key] ?? 0;
    temporary_traits[$ _trait_key] = min(_current + 1, 5);
}
```

### remove_temporary_trait(trait_key)
Remove a temporary trait stack (when unequipping, buff expires).

```gml
function remove_temporary_trait(_trait_key) {
    if (!variable_instance_exists(self, "temporary_traits")) return;
    if (!variable_struct_exists(temporary_traits, _trait_key)) return;

    var _current = temporary_traits[$ _trait_key];
    _current--;

    if (_current <= 0) {
        variable_struct_remove(temporary_traits, _trait_key);
    } else {
        temporary_traits[$ _trait_key] = _current;
    }
}
```

### apply_tag_traits(tag_key)
Apply all traits from a tag as permanent traits.

```gml
function apply_tag_traits(_tag_key) {
    if (!variable_global_exists("tag_database")) return;
    if (!variable_struct_exists(global.tag_database, _tag_key)) return;

    var _tag = global.tag_database[$ _tag_key];
    var _traits = _tag.grants_traits;

    for (var i = 0; i < array_length(_traits); i++) {
        add_permanent_trait(_traits[i]);
    }
}
```

### get_damage_modifier_for_type(damage_type)
Calculate final damage modifier with opposite trait cancellation.

```gml
function get_damage_modifier_for_type(_damage_type) {
    var _type_str = damage_type_to_string(_damage_type);

    var _immunity_stacks = get_total_trait_stacks(_type_str + "_immunity");
    var _resistance_stacks = get_total_trait_stacks(_type_str + "_resistance");
    var _vulnerability_stacks = get_total_trait_stacks(_type_str + "_vulnerability");

    // Immunity check with cancellation
    if (_immunity_stacks > 0) {
        if (_vulnerability_stacks > 0) {
            var _net_immunity = _immunity_stacks - _vulnerability_stacks;
            if (_net_immunity > 0) {
                return 0.0; // Still immune
            } else {
                var _net_vuln = _vulnerability_stacks - _immunity_stacks;
                return power(1.5, _net_vuln);
            }
        } else {
            return 0.0; // Immune, no cancellation
        }
    }

    // Resistance vs vulnerability
    if (_resistance_stacks > 0 || _vulnerability_stacks > 0) {
        var _net_stacks = _resistance_stacks - _vulnerability_stacks;

        if (_net_stacks > 0) {
            return power(0.75, _net_stacks); // Net resistance
        } else if (_net_stacks < 0) {
            return power(1.5, abs(_net_stacks)); // Net vulnerability
        } else {
            return 1.0; // Perfect cancellation
        }
    }

    return 1.0; // No traits
}
```

## Damage Calculation Integration

Location: `objects/obj_enemy_parent/Collision_obj_attack.gml`

```gml
// Get weapon damage type from attacker's equipped weapon
var _weapon_damage_type = DamageType.physical; // Default

if (other.creator != noone && instance_exists(other.creator)) {
    // Check right hand first
    if (other.creator.equipped.right_hand != undefined) {
        var _weapon_stats = other.creator.equipped.right_hand.definition.stats;
        if (variable_struct_exists(_weapon_stats, "damage_type")) {
            _weapon_damage_type = _weapon_stats.damage_type;
        }
    }
    // Check left hand if no right hand weapon
    else if (other.creator.equipped.left_hand != undefined) {
        var _left_stats = other.creator.equipped.left_hand.definition.stats;
        if (variable_struct_exists(_left_stats, "damage_type")) {
            _weapon_damage_type = _left_stats.damage_type;
        }
    }
}

// Apply damage type resistance multiplier using trait system v2.0
var _base_damage = other.damage;
var _resistance_multiplier = get_damage_modifier_for_type(_weapon_damage_type);
var _final_damage = _base_damage * _resistance_multiplier;

hp -= _final_damage;

// Spawn damage number or immunity text
if (_resistance_multiplier <= 0) {
    spawn_immune_text(x, y - 16, self);
} else {
    spawn_damage_number(x, y - 16, _final_damage, _weapon_damage_type, self);
}
```

## Visual Feedback

### Damage Numbers

Colored damage numbers based on damage type:

```gml
function damage_type_to_color(_damage_type) {
    switch(_damage_type) {
        case DamageType.physical: return c_red;
        case DamageType.magical: return make_color_rgb(138, 43, 226); // Blue-violet
        case DamageType.fire: return make_color_rgb(255, 140, 0); // Dark orange
        case DamageType.ice: return make_color_rgb(135, 206, 250); // Light sky blue
        case DamageType.lightning: return make_color_rgb(255, 255, 0); // Bright yellow
        case DamageType.poison: return make_color_rgb(0, 255, 0); // Bright green
        case DamageType.disease: return make_color_rgb(139, 69, 19); // Saddle brown
        case DamageType.holy: return make_color_rgb(255, 215, 0); // Gold
        case DamageType.unholy: return make_color_rgb(128, 0, 128); // Purple
        default: return c_white;
    }
}
```

### Immunity Text

When resistance multiplier is 0.0, show "IMMUNE!" instead of damage number:

```gml
function spawn_immune_text(_x, _y, _target) {
    var _text = instance_create_layer(_x, _y, "Instances", obj_floating_text);
    _text.text = "IMMUNE!";
    _text.color = c_gray;
    _text.follow_target = _target;
}
```

## Example Enemy Configuration

### Fire Imp (Fireborne Tag)

```gml
// objects/obj_fire_imp/Create_0.gml
event_inherited();

attack_damage = 1;
attack_damage_type = DamageType.fire; // Fire imp deals fire damage
attack_speed = 0.8;
attack_range = 32;
hp = 12;
hp_total = hp;
move_speed = 0.75;

// Apply fireborne tag (grants fire_immunity + ice_vulnerability)
apply_tag_traits("fireborne");

// Fire imp attacks cause burning
attack_status_effects = [
    {trait: "burning", chance: 0.5} // 50% chance to burn on hit
];
```

**Result:**
- Immune to fire damage (fire_immunity trait)
- Takes 1.5x damage from ice (ice_vulnerability trait)
- Deals fire damage to enemies
- 50% chance to apply burning status effect

### Burglar (Arboreal Tag)

```gml
// objects/obj_burglar/Create_0.gml
event_inherited();

attack_damage = 1;
attack_speed = 1.2;
attack_range = 18;
hp = 3;
move_speed = 1.3;

// Burglar traits - forest dweller, vulnerable to fire, resistant to poison
apply_tag_traits("arboreal");
```

**Result:**
- Takes 1.5x damage from fire (fire_vulnerability trait)
- Takes 0.75x damage from poison (poison_resistance trait)

## Equipment Integration (Future)

Equipment can grant temporary traits while equipped:

```gml
// Example: Ring of Fire Protection
flame_ring: new create_item_definition(
    12, "flame_ring", "Ring of Fire Protection", ItemType.equipment, EquipSlot.ring,
    {grants_traits: ["fire_resistance"]}
)

// In apply_wielder_effects()
if (variable_struct_exists(_item_stats, "grants_traits")) {
    var _traits = _item_stats.grants_traits;
    for (var i = 0; i < array_length(_traits); i++) {
        add_temporary_trait(_traits[i]);
    }
}

// In remove_wielder_effects()
if (variable_struct_exists(_item_stats, "grants_traits")) {
    var _traits = _item_stats.grants_traits;
    for (var i = 0; i < array_length(_traits); i++) {
        remove_temporary_trait(_traits[i]);
    }
}
```

## Testing Scenarios

### Scenario 1: Fire Immunity Test
1. Spawn fire imp (has fireborne tag → fire_immunity)
2. Equip torch (deals DamageType.fire)
3. Attack fire imp
4. **Expected**: "IMMUNE!" text appears, fire imp takes 0 damage

### Scenario 2: Ice Vulnerability Test
1. Spawn fire imp (has fireborne tag → ice_vulnerability)
2. Equip ice weapon (deals DamageType.ice)
3. Attack fire imp with 10 base damage
4. **Expected**: Fire imp takes 15 damage (1.5x multiplier)

### Scenario 3: Trait Stacking
1. Player equips ring of fire resistance (grants fire_resistance)
2. Player drinks potion of fire resistance (grants fire_resistance)
3. Player now has 2 stacks of fire_resistance
4. Fire imp deals 10 fire damage
5. **Expected**: Player takes 10 * 0.75² = 5.625 damage

### Scenario 4: Opposite Trait Cancellation
1. Player has fire_immunity(1) from quest
2. Player equips cursed amulet of fire vulnerability (grants fire_vulnerability)
3. Net result: fire_immunity cancelled, fire_vulnerability(0) remains
4. Fire imp deals 10 fire damage
5. **Expected**: Player takes 10 damage (normal, perfect cancellation)

## Save/Load System

Traits serialize easily:

```gml
save_data = {
    permanent_traits: obj_player.permanent_traits,
    temporary_traits: {} // Don't save temporary traits from equipment
}

// On load
obj_player.permanent_traits = save_data.permanent_traits;
// temporary_traits will be rebuilt when equipment is re-applied
```

## Future Extensions

### Trait Synergies
```gml
// Example: Fire + Ice = Steam
if (has_trait("fire_immunity") && has_trait("ice_immunity")) {
    add_permanent_trait("steam_mastery");
}
```

### Conditional Traits
```gml
// Example: Stronger at night
if (global.time_of_day == "night" && has_trait("nocturnal")) {
    add_temporary_trait("shadow_damage_bonus");
}
```

### Companion Auras
```gml
// Example: Fire mage companion grants fire resistance aura
if (companion_nearby(obj_fire_mage)) {
    add_temporary_trait("fire_resistance");
}
```

## Related Systems

- **Status Effects**: Burning, wet, empowered, weakened, swift, slowed, poisoned (see `status-effects-system.md`)
- **Armor Defense**: Physical damage reduction (see `ARMOR_DEFENSE_SYSTEM.md`)
- **Item System**: Equipment granting traits (see `scr_item_database.gml`)
- **Combat System**: Damage calculation flow (see `scr_combat_system.gml`)
