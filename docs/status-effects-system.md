# Status Effects System Documentation

## Overview

The status effects system implements 6 different status effects organized into 3 opposing pairs that cancel each other out when applied. This creates strategic gameplay where applying certain effects can counter existing ones.

## Status Effect Types

### Opposing Pairs

1. **Burning ↔ Wet**
   - **Burning**: Deals 1 damage every 30 frames (0.5 seconds) for 3 seconds
   - **Wet**: Reduces movement speed by 10% for 5 seconds

2. **Empowered ↔ Weakened**
   - **Empowered**: Increases damage output by 50% for 10 seconds
   - **Weakened**: Reduces damage output by 30% for 10 seconds

3. **Swift ↔ Slowed**
   - **Swift**: Increases movement speed by 30% for 8 seconds
   - **Slowed**: Reduces movement speed by 40% for 5 seconds

### Cancellation Mechanics

When a status effect is applied to an entity that already has its opposing effect:
- The existing opposing effect is immediately removed
- The new effect is **not** applied
- This creates a "cleansing" mechanic where effects counter each other

## Core Implementation

### Data Structures

**File**: `scripts/scripts/scripts.gml` (lines 570-622)

```gml
enum StatusEffectType {
    burning, wet, empowered, weakened, swift, slowed
}

global.status_effect_data = {
    burning: {
        duration: 180,     // 3 seconds at 60fps
        tick_rate: 30,     // Damage every 0.5 seconds
        damage: 1,
        opposing: StatusEffectType.wet
    },
    wet: {
        duration: 300,     // 5 seconds at 60fps
        speed_modifier: 0.9, // 10% speed reduction
        opposing: StatusEffectType.burning
    },
    // ... additional effects
};
```

### Core Functions

**File**: `scripts/scripts/scripts.gml` (lines 637-759)

#### `init_status_effects()`
- **Purpose**: Initializes the status_effects array for an entity
- **Usage**: Called in Create events of player and enemies
- **Location**: Line 638

#### `apply_status_effect(_effect_type, _duration_override = -1)`
- **Purpose**: Applies a status effect to the current entity
- **Parameters**:
  - `_effect_type`: StatusEffectType enum value
  - `_duration_override`: Optional custom duration (uses default if -1)
- **Returns**: Boolean indicating success
- **Logic**:
  1. Checks for opposing effects and removes them if found
  2. Refreshes duration if effect already exists
  3. Adds new effect if not present
- **Location**: Lines 642-674

#### `remove_status_effect(_effect_type)`
- **Purpose**: Removes a specific status effect
- **Location**: Lines 677-683

#### `has_status_effect(_effect_type)`
- **Purpose**: Checks if entity has a specific status effect
- **Location**: Lines 686-688

#### `tick_status_effects()`
- **Purpose**: Updates all active status effects each frame
- **Responsibilities**:
  - Handles damage over time for burning
  - Reduces effect durations
  - Removes expired effects
  - Handles death from burning damage
- **Location**: Lines 703-732

#### `get_status_effect_modifier(_modifier_type)`
- **Purpose**: Calculates cumulative modifiers from all active effects
- **Parameters**: `_modifier_type` ("speed" or "damage")
- **Returns**: Multiplier value (1.0 = no change)
- **Location**: Lines 734-759

## Entity Integration

### Player Integration

**Files**:
- `objects/obj_player/Create_0.gml` (line 131)
- `objects/obj_player/Step_0.gml` (lines 62-63)

```gml
// In Create event
init_status_effects();

// In Step event
tick_status_effects();
```

**Speed Modifier Application**:
- `scripts/player_state_walking/player_state_walking.gml` (lines 48-50)
- `scripts/player_state_dashing/player_state_dashing.gml` (lines 14-16)

**Damage Modifier Application**:
- `scripts/scripts/scripts.gml` (lines 486-488) in `get_total_damage()`

### Enemy Integration

**Files**:
- `objects/obj_enemy_parent/Create_0.gml` (line 37)
- `objects/obj_enemy_parent/Step_0.gml` (lines 2-3)
- `objects/obj_enemy_parent/Alarm_2.gml` (lines 11-13)

Similar integration pattern as player with initialization, ticking, and modifier application.

## Visual Feedback System

### Player Status Icons

**File**: `objects/obj_player/Draw_0.gml` (lines 374-428)

- Displays colored circles above player
- Shows duration bars below each icon
- Icon colors:
  - Burning: Red
  - Wet: Blue
  - Empowered: Yellow
  - Weakened: Gray
  - Swift: Green
  - Slowed: Purple

### Enemy Status Icons

**File**: `objects/obj_enemy_parent/Draw_0.gml` (lines 17-71)

- Similar to player icons but smaller (6px vs 8px)
- Only shown when enemy is alive
- Positioned above enemy health bars

### UI Helper Functions

**File**: `scripts/scripts/scripts.gml` (lines 791-838)

#### `ui_get_status_effect_color(_effect_type)`
- Returns standardized colors for each effect type

#### `ui_draw_status_effects(_player, _x, _y, _icon_size, _spacing)`
- Flexible function for drawing status effect icons
- Supports custom sprites or fallback colored rectangles
- Includes duration bars

## Status Effect Sources

### Weapon-Based Effects

**Configuration**: `scripts/scripts/scripts.gml`

#### Master Sword (lines 97-100)
```gml
master_sword: new create_item_definition(
    3, "master_sword", "Master Sword", ItemType.weapon, EquipSlot.either_hand,
    {damage: 6, attack_speed: 1.1, range: 38, handedness: WeaponHandedness.versatile,
     two_handed_damage: 7, two_handed_range: 42, magic_power: 5,
     status_effect: StatusEffectType.empowered, status_chance: 0.3}
),
```

#### Torch (lines 131-134)
```gml
torch: new create_item_definition(
    11, "torch", "Torch", ItemType.tool, EquipSlot.left_hand,
    {light_radius: 100, handedness: WeaponHandedness.one_handed,
     status_effect: StatusEffectType.burning, status_chance: 0.2}
),
```

**Application Logic**: `objects/obj_enemy_parent/Collision_obj_attack.gml` (lines 6-32)

When an attack hits an enemy:
1. Checks attacker's right-hand weapon for status effects
2. Checks attacker's left-hand item (like torch) for status effects
3. Applies effects based on random chance

### Debug Testing Interface

**File**: `objects/obj_player/Step_0.gml` (lines 91-126)

Debug keys for testing:
- **Keys 1-6**: Apply different status effects to player
- **Key 7**: Apply burning effect to nearest enemy within 50 pixels

```gml
// Example debug key
if (keyboard_check_pressed(ord("1"))) {
    apply_status_effect(StatusEffectType.burning);
    show_debug_message("Applied burning effect");
}
```

## Technical Details

### Frame Rate Considerations

All durations are specified in frames assuming 60 FPS:
- 60 frames = 1 second
- 180 frames = 3 seconds
- 300 frames = 5 seconds

### Error Handling

The system includes several safety checks:
- Validation of effect data existence
- Struct property existence checks
- Array bounds checking
- Death state validation

### Performance Considerations

- Status effects tick every frame but only process actions when needed
- Visual icons only drawn when effects are active
- Array operations use proper iteration (backwards for removal)

## Extensibility

### Adding New Status Effects

1. Add new enum value to `StatusEffectType`
2. Add data entry to `global.status_effect_data`
3. Update `get_status_effect_data()` switch statement
4. Add color mapping in `ui_get_status_effect_color()`
5. Handle any special logic in `tick_status_effects()`

### Adding New Sources

1. Add `status_effect` and `status_chance` properties to item definitions
2. Modify collision/interaction events to check for and apply effects
3. Consider environmental sources (water tiles for wet, fire tiles for burning)

## Example Usage

```gml
// Apply burning effect to an enemy
with (obj_enemy_parent) {
    apply_status_effect(StatusEffectType.burning);
}

// Check if player is empowered
if (has_status_effect(StatusEffectType.empowered)) {
    // Player deals extra damage
}

// Get current speed modifier
var speed_mod = get_status_effect_modifier("speed");
var final_speed = base_speed * speed_mod;
```