# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-09-29-trait-system/spec.md

## Technical Requirements

### Code Files to Create

1. **scripts/trait_database/trait_database.gml** - New script containing:
   - `global.trait_database` struct with trait definitions
   - Initialize in Game Start event or persistent controller

2. **scripts/trait_system/trait_system.gml** - New script containing:
   - `has_trait(_trait_key)` - Check if character has trait
   - `add_trait(_trait_key)` - Add trait to character
   - `remove_trait(_trait_key)` - Remove trait from character
   - `get_trait_effect(_trait_key, _effect_name)` - Get specific effect value
   - `get_all_trait_modifiers(_effect_name)` - Get combined modifiers from all traits
   - `has_trait_immunity(_immunity_name)` - Check for immunity flags

### Code Files to Modify

1. **objects/obj_player/Create_0.gml**
   - Add `traits = [];` initialization

2. **objects/obj_enemy_parent/Create_0.gml**
   - Add `traits = [];` initialization
   - Document that child enemies can override with `traits = ["fireborne", "aquatic"];`

3. **objects/obj_enemy_parent/Collision_obj_attack.gml** (line 7)
   - Current code: `hp -= other.damage;`
   - Modify to apply trait-based damage modifiers
   - Calculate damage type from weapon/status effects
   - Apply trait modifier: `var _modifier = get_all_trait_modifiers(_damage_type + "_damage_modifier");`
   - Apply modified damage: `hp -= (other.damage * _modifier);`

4. **objects/obj_player/Collision_obj_enemy_parent.gml** (line 3)
   - Current code: `hp -= other.damage;`
   - Same modification as above for enemy-to-player damage

### Damage Type System

Current game has no damage typing system. Need to establish:

1. **Default Damage Type**: All attacks default to "physical" damage type
2. **Weapon Damage Types**: Infer from weapon stats or status effects
   - Torch (has burning status) → "fire" damage
   - Future: Add `damage_type: "ice"` to weapon stats
3. **Damage Type Keys**: fire, ice, lightning, poison, physical, holy, shadow

### Trait Database Structure

Each trait entry:
```gml
trait_key: {
    name: "Display Name",
    description: "Trait description",
    effects: {
        fire_damage_modifier: 0,      // 0 = immune, 0.5 = resistant, 1.5 = vulnerable
        ice_damage_modifier: 1.5,
        movement_speed_water: 1.5,    // Future: terrain-based speed
        freeze_immunity: true         // Boolean immunity flags
    }
}
```

### Initial Trait Definitions

Include these traits in `global.trait_database`:
- **fireborne** - Fire immune, ice vulnerable
- **arboreal** - Fire vulnerable, poison resistant
- **aquatic** - Lightning vulnerable, fire resistant, water movement bonus
- **glacial** - Ice immune, fire vulnerable, freeze immunity
- **swampridden** - Poison immune, disease resistant
- **sandcrawler** - Fire resistant, desert movement bonus

### Debug System

Add to `obj_player` Step event or dedicated debug controller:
- Press **T** key: add "fireborne" trait to player
- Press **Y** key: add "arboreal" trait to nearest enemy
- Press **U** key: remove all traits from player
- Press **I** key: show debug message listing all active traits

### Integration Order

1. **Phase 1**: Create trait database and helper functions
2. **Phase 2**: Integrate damage modifiers into collision events
3. **Phase 3**: Add debug commands
4. **Phase 4**: Test with trait-assigned enemies

### GameMaker Specific Considerations

- Use `variable_struct_exists()` for safe struct property checks
- Use `with (target)` scope switching for applying effects to other instances
- Traits array uses GameMaker array functions: `array_push()`, `array_delete()`
- Snake_case naming convention throughout (Ruby-style per CLAUDE.md)