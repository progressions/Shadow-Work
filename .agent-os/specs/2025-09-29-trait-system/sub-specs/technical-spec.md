# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-09-29-trait-system/spec.md

> Updated: 2025-09-30 (VERSION 2.0)
> Architecture: Tag/Trait Separation with Age of Wonders Stacking Mechanics

## Technical Requirements

### Code Files to Create

1. **scripts/tag_database/tag_database.gml** - New script containing:
   - `global.tag_database` struct with tag definitions
   - Each tag specifies permanent traits granted (with initial stack counts)
   - Initialize in Game Start event or persistent controller

2. **scripts/trait_database/trait_database.gml** - New script containing:
   - `global.trait_database` struct with trait definitions
   - Each trait specifies: name, description, effect_type, value_per_stack, max_stacks, opposite_trait
   - Initialize in Game Start event or persistent controller

3. **scripts/trait_system/trait_system.gml** - New script containing:
   - `add_permanent_trait(_trait_key, _stacks)` - Add stacks to permanent_traits (max 5 total)
   - `add_temporary_trait(_trait_key, _stacks)` - Add stacks to temporary_traits (max 5 total)
   - `remove_temporary_trait(_trait_key, _stacks)` - Remove stacks from temporary_traits
   - `get_net_trait_stacks(_trait_key)` - Calculate net stacks after opposite trait cancellation
   - `get_damage_modifier(_damage_type)` - Calculate final damage multiplier from net trait stacks
   - `has_immunity(_damage_type)` - Check if net immunity stacks >= 1
   - `apply_tag(_tag_key)` - Apply all permanent traits from a tag
   - `get_total_trait_stacks(_trait_key)` - Sum permanent and temporary stacks (before cancellation)

### Code Files to Modify

1. **objects/obj_player/Create_0.gml**
   - Add `tags = [];` initialization
   - Add `permanent_traits = {};` initialization (struct, not array)
   - Add `temporary_traits = {};` initialization (struct, not array)

2. **objects/obj_enemy_parent/Create_0.gml**
   - Add `tags = [];` initialization
   - Add `permanent_traits = {};` initialization
   - Add `temporary_traits = {};` initialization
   - Document that child enemies can set `tags = ["fireborne", "venomous"];` and call `apply_tags()` in Create

3. **objects/obj_enemy_parent/Collision_obj_attack.gml** (line 7)
   - Current code: `hp -= other.damage;`
   - Modify to:
     ```gml
     var _damage_type = get_attack_damage_type(other);
     var _modifier = get_damage_modifier(_damage_type);
     var _final_damage = other.damage * _modifier;
     hp -= _final_damage;
     ```

4. **objects/obj_player/Collision_obj_enemy_parent.gml** (line 3)
   - Same modification as above for enemy-to-player damage

5. **scripts/wielder_effects/wielder_effects.gml**
   - Modify `apply_wielder_effects(_item_def)` to add temporary traits instead of setting `damage_resistances`
   - Modify `remove_wielder_effects(_item_def)` to remove temporary traits
   - Example: If item has `fire_resistance: 1`, call `add_temporary_trait("fire_resistance", 1)`

### Tag Database Structure

Each tag entry in `global.tag_database`:
```gml
tag_key: {
    name: "Display Name",
    description: "Thematic description",
    traits_granted: {
        fire_immunity: 1,
        ice_vulnerability: 1,
        fire_aura: 1
    }
}
```

### Initial Tag Definitions

Include these tags in `global.tag_database`:
- **fireborne** - Grants: fire_immunity (1), ice_vulnerability (1), fire_aura (1)
- **arboreal** - Grants: fire_vulnerability (2), poison_resistance (1), nature_affinity (1)
- **aquatic** - Grants: lightning_vulnerability (2), fire_resistance (1), water_breathing (1)
- **glacial** - Grants: ice_immunity (1), fire_vulnerability (2), freeze_immunity (1)
- **venomous** - Grants: poison_immunity (1), disease_resistance (1), poison_touch (1)
- **sandcrawler** - Grants: fire_resistance (1), ice_resistance (1), desert_stride (1)
- **undead** - Grants: poison_immunity (1), disease_immunity (1), holy_vulnerability (2), unholy_resistance (2)

### Trait Database Structure

Each trait entry in `global.trait_database`:
```gml
trait_key: {
    name: "Display Name",
    description: "Effect description",
    effect_type: "immunity" | "resistance" | "vulnerability" | "special",
    damage_type: "fire" | "ice" | "lightning" | "poison" | "disease" | "holy" | "unholy" | "physical" | "magical",
    value_per_stack: 0.75,  // For resistance: 0.75 = 25% reduction per stack (multiplicative)
                             // For vulnerability: 1.5 = 50% increase per stack (multiplicative)
                             // For immunity: 0 (binary: 1+ stacks = immune)
    max_stacks: 5,
    opposite_trait: "fire_vulnerability"  // Used for cancellation
}
```

### Initial Trait Definitions

Resistance traits (value_per_stack: 0.75):
- **fire_resistance**, **ice_resistance**, **lightning_resistance**, **poison_resistance**, **disease_resistance**, **holy_resistance**, **unholy_resistance**, **physical_resistance**, **magical_resistance**

Vulnerability traits (value_per_stack: 1.5):
- **fire_vulnerability**, **ice_vulnerability**, **lightning_vulnerability**, **poison_vulnerability**, **disease_vulnerability**, **holy_vulnerability**, **unholy_vulnerability**, **physical_vulnerability**, **magical_vulnerability**

Immunity traits (value_per_stack: 0, effect_type: "immunity"):
- **fire_immunity**, **ice_immunity**, **lightning_immunity**, **poison_immunity**, **disease_immunity**, **holy_immunity**, **unholy_immunity**

Special traits (effect_type: "special"):
- **fire_aura**, **poison_touch**, **cold_touch**, **nature_affinity**, **water_breathing**, **freeze_immunity**, **desert_stride**

### Stacking Mechanics

#### Adding Traits
```gml
// Add 2 stacks of fire_resistance
add_permanent_trait("fire_resistance", 2);
// permanent_traits.fire_resistance = 2

// Add 1 more stack (total: 3)
add_permanent_trait("fire_resistance", 1);
// permanent_traits.fire_resistance = 3

// Attempt to add 4 more stacks (max 5 total, capped at 5)
add_permanent_trait("fire_resistance", 4);
// permanent_traits.fire_resistance = 5
```

#### Opposite Trait Cancellation
```gml
// Character has:
// permanent_traits.fire_resistance = 3
// temporary_traits.fire_vulnerability = 2

// Calculate net stacks:
var _net_stacks = get_net_trait_stacks("fire_resistance");
// Returns: 3 - 2 = 1 (net 1 stack of fire_resistance)

// Calculate damage modifier:
var _modifier = get_damage_modifier("fire");
// Returns: 0.75^1 = 0.75 (25% fire damage reduction)
```

#### Immunity Cancellation
```gml
// Character has:
// permanent_traits.fire_immunity = 1

// Check immunity:
var _is_immune = has_immunity("fire");
// Returns: true (1+ stacks of fire_immunity, no opposing fire_vulnerability)

// Add vulnerability:
add_temporary_trait("fire_vulnerability", 2);

// Check immunity again:
var _is_immune = has_immunity("fire");
// Returns: false (1 immunity - 2 vulnerability = net -1, which is 1 vulnerability)

// Calculate damage modifier:
var _modifier = get_damage_modifier("fire");
// Returns: 1.5^1 = 1.5 (50% increased fire damage)
```

### Damage Type System Expansion

Extend existing damage types to include:
- **physical** - Default melee/projectile damage
- **magical** - Generic magical damage
- **fire** - Burning, flame attacks
- **ice** - Cold, freezing attacks
- **lightning** - Electrical, shock attacks
- **poison** - Toxic, venomous attacks
- **disease** - Plague, infection attacks
- **holy** - Divine, radiant attacks
- **unholy** - Necrotic, shadow attacks

### Equipment Integration Changes

**Current System** (to be replaced):
```gml
// apply_wielder_effects() currently does:
damage_resistances.fire = 0.5;  // Direct modification
```

**New System** (trait-based):
```gml
// apply_wielder_effects() should do:
if (variable_struct_exists(_item_def, "fire_resistance")) {
    add_temporary_trait("fire_resistance", _item_def.fire_resistance);
}

// remove_wielder_effects() should do:
if (variable_struct_exists(_item_def, "fire_resistance")) {
    remove_temporary_trait("fire_resistance", _item_def.fire_resistance);
}
```

### Damage Calculation Flow

1. **Get Attack Damage Type**: `var _type = get_attack_damage_type(attack_obj);`
   - Check weapon stats, status effects (e.g., burning → fire)
   - Default to "physical"

2. **Check Immunity**: `if (has_immunity(_type)) { damage = 0; }`
   - Calculates net immunity stacks (immunity - vulnerability)
   - If net >= 1, return true

3. **Calculate Modifier**: `var _mod = get_damage_modifier(_type);`
   - Get net resistance stacks (resistance - vulnerability)
   - If net > 0: modifier = 0.75^net_stacks (resistance)
   - If net < 0: modifier = 1.5^abs(net_stacks) (vulnerability)
   - If net = 0: modifier = 1.0 (neutral)

4. **Apply Damage**: `hp -= (base_damage * _mod);`

### Debug System

Add to `obj_player` Step event or dedicated debug controller:
- **T key**: `add_permanent_trait("fire_resistance", 1)` to player
- **Y key**: `add_temporary_trait("fire_vulnerability", 1)` to player
- **U key**: `temporary_traits = {}` (clear all temporary traits from player)
- **I key**: Show debug message with all permanent and temporary traits, listing stacks
- **O key**: Add "fireborne" tag to nearest enemy (calls `apply_tag("fireborne")`)
- **P key**: Show net trait stacks for all traits after cancellation

### Integration Order

1. **Phase 1**: Create tag database and trait database with initial definitions
2. **Phase 2**: Implement trait system helper functions (add, remove, get_net_stacks, get_modifier)
3. **Phase 3**: Add trait storage to obj_player and obj_enemy_parent
4. **Phase 4**: Modify equipment system to use trait grants instead of damage_resistances
5. **Phase 5**: Integrate damage modifiers into collision events
6. **Phase 6**: Add debug commands for testing
7. **Phase 7**: Create test enemies with tags and verify stacking/cancellation

### GameMaker Specific Considerations

- Use structs (`{}`) for `permanent_traits` and `temporary_traits`, NOT arrays
- Struct keys are trait names, values are stack counts: `permanent_traits.fire_resistance = 3`
- Use `variable_struct_exists(permanent_traits, "fire_resistance")` for safe checks
- Use `variable_struct_get(permanent_traits, "fire_resistance", 0)` to get stacks with default 0
- Snake_case naming throughout (Ruby-style per CLAUDE.md)
- Multiplicative stacking uses `power()` function: `power(0.75, stacks)`

### External Dependencies

None. System is self-contained within GameMaker's GML scripting environment.
