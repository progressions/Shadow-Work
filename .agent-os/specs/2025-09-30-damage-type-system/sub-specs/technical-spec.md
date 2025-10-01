# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-09-30-damage-type-system/spec.md

> Created: 2025-09-30
> Version: 1.0.0

## Technical Requirements

### 1. DamageType Enum

Create a new enum in `scripts/scr_enums/scr_enums.gml`:

```gml
enum DamageType {
    physical,
    magical,
    fire,
    holy,
    unholy
}
```

### 2. Data Structure Changes

#### Item Database (scr_item_database)

Add `damage_type` property to weapon definitions:

```gml
global.item_database.short_sword = {
    // ... existing properties ...
    damage_type: DamageType.physical,  // NEW PROPERTY
};

global.item_database.staff_of_flames = {
    // ... existing properties ...
    damage_type: DamageType.fire,  // Fire damage weapon
};
```

**Migration Plan**: All existing weapons default to `DamageType.physical` for backward compatibility.

#### Enemy Parent Object (obj_enemy_parent)

Add in Create event:

```gml
// Damage type for this enemy's attacks
attack_damage_type = DamageType.physical;  // Default, override in children

// Resistance multipliers for incoming damage
damage_resistances = {
    physical: 1.0,  // Normal damage
    magical: 1.0,
    fire: 1.0,
    holy: 1.0,
    unholy: 1.0
};
```

#### Player Object (obj_player)

Add in Create event:

```gml
// Resistance multipliers for incoming damage
damage_resistances = {
    physical: 1.0,
    magical: 1.0,
    fire: 1.0,
    holy: 1.0,
    unholy: 1.0
};
```

### 3. Damage Calculation Flow

**Current Flow** (from wielder effects system):
1. Base weapon damage
2. Apply status effect modifiers (from wielder effects)
3. Apply armor damage reduction
4. Deal final damage

**New Flow** (insert resistance check):
1. Base weapon damage
2. Apply status effect modifiers (from wielder effects)
3. **Apply damage type resistance multiplier** ← NEW STEP
4. Apply armor damage reduction
5. Deal final damage

**Implementation Location**: Update damage calculation in collision events and alarm events where damage is dealt.

Example integration:

```gml
// In obj_player Collision with obj_enemy_parent
var _base_damage = get_total_damage();
var _final_damage = _base_damage;

// Apply status effect modifiers (existing wielder effects code)
// ... existing status effect code ...

// NEW: Apply damage type resistance
var _weapon = equipped.right_hand;
var _damage_type = (_weapon != noone && variable_struct_exists(_weapon, "damage_type"))
    ? _weapon.damage_type
    : DamageType.physical;
var _resistance_multiplier = get_damage_type_multiplier(other, _damage_type);
_final_damage *= _resistance_multiplier;

// Apply armor damage reduction (existing)
// ... existing armor code ...

// Deal damage
if (_resistance_multiplier > 0) {
    other.hp_current -= floor(_final_damage);
    spawn_damage_number(other.x, other.y, floor(_final_damage), _damage_type);
} else {
    spawn_immune_text(other.x, other.y);
}
```

### 4. Helper Functions

Create new script file `scripts/scr_damage_type_helpers/scr_damage_type_helpers.gml`:

```gml
/// @function get_damage_type_multiplier(target, damage_type)
/// @description Get the resistance multiplier for a damage type
/// @param {Id.Instance} target - The entity being damaged
/// @param {DamageType} damage_type - The type of damage
/// @return {Real} Resistance multiplier (0.0 = immune, 1.0 = normal, 2.0 = weak)
function get_damage_type_multiplier(_target, _damage_type) {
    if (!instance_exists(_target)) return 1.0;
    if (!variable_instance_exists(_target, "damage_resistances")) return 1.0;

    var _resistances = _target.damage_resistances;

    switch (_damage_type) {
        case DamageType.physical: return _resistances.physical;
        case DamageType.magical: return _resistances.magical;
        case DamageType.fire: return _resistances.fire;
        case DamageType.holy: return _resistances.holy;
        case DamageType.unholy: return _resistances.unholy;
        default: return 1.0;
    }
}

/// @function set_damage_resistance(target, damage_type, multiplier)
/// @description Set resistance multiplier for a specific damage type
/// @param {Id.Instance} target - The entity to modify
/// @param {DamageType} damage_type - The type of damage
/// @param {Real} multiplier - Resistance value (0.0 = immune, 1.0 = normal, 2.0 = weak)
function set_damage_resistance(_target, _damage_type, _multiplier) {
    if (!instance_exists(_target)) return;
    if (!variable_instance_exists(_target, "damage_resistances")) return;

    var _resistances = _target.damage_resistances;

    switch (_damage_type) {
        case DamageType.physical: _resistances.physical = _multiplier; break;
        case DamageType.magical: _resistances.magical = _multiplier; break;
        case DamageType.fire: _resistances.fire = _multiplier; break;
        case DamageType.holy: _resistances.holy = _multiplier; break;
        case DamageType.unholy: _resistances.unholy = _multiplier; break;
    }
}

/// @function damage_type_to_string(damage_type)
/// @description Convert damage type enum to readable string
/// @param {DamageType} damage_type
/// @return {String}
function damage_type_to_string(_damage_type) {
    switch (_damage_type) {
        case DamageType.physical: return "Physical";
        case DamageType.magical: return "Magical";
        case DamageType.fire: return "Fire";
        case DamageType.holy: return "Holy";
        case DamageType.unholy: return "Unholy";
        default: return "Unknown";
    }
}

/// @function damage_type_to_color(damage_type)
/// @description Get display color for damage type
/// @param {DamageType} damage_type
/// @return {Constant.Color}
function damage_type_to_color(_damage_type) {
    switch (_damage_type) {
        case DamageType.physical: return c_red;      // Red
        case DamageType.magical: return c_blue;      // Blue
        case DamageType.fire: return c_orange;       // Orange
        case DamageType.holy: return c_yellow;       // Yellow
        case DamageType.unholy: return c_purple;     // Purple
        default: return c_white;
    }
}
```

### 5. Visual Feedback System

#### Modify obj_floating_text

Update Create event to accept damage type:

```gml
// Add to existing Create event
damage_type = DamageType.physical;  // Default
text_color = c_white;  // Will be set based on damage_type
```

Update Draw event to use damage type color:

```gml
// In Draw_0 event
draw_set_color(text_color);
draw_set_alpha(alpha);
draw_text(x, y, text);
draw_set_alpha(1.0);
draw_set_color(c_white);
```

#### Update spawn_damage_number Function

Modify in `scripts/scr_floating_text/scr_floating_text.gml`:

```gml
/// @function spawn_damage_number(x, y, damage, damage_type)
/// @description Spawn floating damage number with color based on damage type
/// @param {Real} x - X position
/// @param {Real} y - Y position
/// @param {Real} damage - Damage value to display
/// @param {DamageType} damage_type - Type of damage for color coding
function spawn_damage_number(_x, _y, _damage, _damage_type = DamageType.physical) {
    var _text = instance_create_layer(_x, _y, "Instances", obj_floating_text);
    _text.text = string(floor(_damage));
    _text.damage_type = _damage_type;
    _text.text_color = damage_type_to_color(_damage_type);
    return _text;
}

/// @function spawn_immune_text(x, y)
/// @description Spawn "IMMUNE!" text when damage is blocked
/// @param {Real} x - X position
/// @param {Real} y - Y position
function spawn_immune_text(_x, _y) {
    var _text = instance_create_layer(_x, _y, "Instances", obj_floating_text);
    _text.text = "IMMUNE!";
    _text.text_color = c_gray;
    _text.font_size = 1.5;  // Larger text (if supported)
    return _text;
}
```

### 6. Integration Points

#### Weapon Attack (obj_player collision with enemies)

```gml
// In obj_player Collision_[obj_enemy_parent] event
var _weapon = equipped.right_hand;
var _damage_type = DamageType.physical;  // Default

if (_weapon != noone && variable_struct_exists(_weapon, "damage_type")) {
    _damage_type = _weapon.damage_type;
}

// ... damage calculation ...

var _resistance_multiplier = get_damage_type_multiplier(other, _damage_type);
_final_damage *= _resistance_multiplier;

if (_resistance_multiplier > 0) {
    other.hp_current -= floor(_final_damage);
    spawn_damage_number(other.x, other.y - 20, floor(_final_damage), _damage_type);
} else {
    spawn_immune_text(other.x, other.y - 20);
}
```

#### Enemy Attack (obj_enemy_parent collision with player)

```gml
// In obj_enemy_parent Alarm[0] or collision event where enemy damages player
var _damage_type = attack_damage_type;  // Use enemy's attack type
var _base_damage = attack_damage;

// ... damage calculation ...

var _resistance_multiplier = get_damage_type_multiplier(obj_player, _damage_type);
_final_damage *= _resistance_multiplier;

if (_resistance_multiplier > 0) {
    obj_player.hp_current -= floor(_final_damage);
    spawn_damage_number(obj_player.x, obj_player.y - 20, floor(_final_damage), _damage_type);
} else {
    spawn_immune_text(obj_player.x, obj_player.y - 20);
}
```

## Approach

### Implementation Order

1. **Phase 1: Foundation**
   - Create `DamageType` enum
   - Add helper functions
   - Update `obj_floating_text` for colored damage

2. **Phase 2: Entity Integration**
   - Add `damage_resistances` struct to `obj_player` and `obj_enemy_parent`
   - Add `attack_damage_type` to `obj_enemy_parent`
   - Add `damage_type` property to item database weapons

3. **Phase 3: Damage Calculation**
   - Integrate resistance multipliers into player attack code
   - Integrate resistance multipliers into enemy attack code
   - Update all `spawn_damage_number()` calls to pass damage type

4. **Phase 4: Testing & Balancing**
   - Create test enemy with fire immunity
   - Create test weapon with fire damage
   - Verify visual feedback works correctly
   - Test all damage type combinations

### Backward Compatibility

- All existing weapons default to `DamageType.physical`
- All existing enemies default to `DamageType.physical` attacks
- Default resistance multipliers of 1.0 mean no behavior change
- Existing damage calculation flow remains intact with resistance as additional step

### Testing Strategy

Create test scenarios:
1. Fire weapon vs fire-immune enemy (multiplier 0.0) → "IMMUNE!" appears, no damage
2. Fire weapon vs normal enemy (multiplier 1.0) → Orange damage number, normal damage
3. Holy weapon vs unholy-weak enemy (multiplier 2.0) → Yellow damage number, double damage
4. Physical weapon vs resistant enemy (multiplier 0.5) → Red damage number, half damage

## External Dependencies

None. This system uses only GameMaker built-in features:
- Enums (native GML)
- Structs (native GML 2.3+)
- Color constants (c_red, c_blue, etc.)
- Existing combat and visual feedback systems
