# Combat System - Technical Documentation

This document provides comprehensive technical documentation for the core combat damage calculation and reduction systems in Shadow Work.

---

## Table of Contents

1. [Damage Calculation Pipeline (Player Attacks)](#damage-calculation-pipeline-player-attacks)
2. [Damage Reduction Pipeline (When Hit)](#damage-reduction-pipeline-when-hit)
3. [Attack Categories](#attack-categories)
4. [Combat Visual Feedback](#combat-visual-feedback)

---

## Damage Calculation Pipeline (Player Attacks)

The player's damage output goes through multiple stages of calculation to arrive at the final damage value dealt to enemies.

**Location:** `/scripts/scr_combat_system/scr_combat_system.gml`

### Stage 1: Base Damage

Get base damage from equipped weapon stats with modifiers:

```gml
// In get_total_damage() function
var _base_damage = 0;

// Get weapon damage with versatile/dual-wield modifiers
if (equipped[$ "right_hand"] != undefined) {
    var right_weapon = equipped[$ "right_hand"];
    _base_damage = right_weapon.stats.attack_damage;

    // Versatile weapon two-handing bonus (+50%)
    if (is_two_handing()) {
        _base_damage *= 1.5;
    }

    // Dual-wield penalty (-25% each hand)
    if (equipped[$ "left_hand"] != undefined &&
        equipped[$ "left_hand"].type == ItemType.weapon) {
        _base_damage *= 0.75;
    }
}
```

### Stage 2: Status Effect Modifiers

Apply damage buffs/debuffs from active status effects:

```gml
// Get status effect damage modifier
var _status_modifier = get_status_effect_modifier("damage");
_base_damage *= _status_modifier;
```

**Status Effects:**
- `empowered`: 1.5x damage multiplier
- `weakened`: 0.7x damage multiplier

**Location:** `/scripts/scr_status_effects/scr_status_effects.gml`

### Stage 3: Companion Bonuses

Add flat attack bonuses from companion auras:

```gml
// Get companion attack bonus
var _companion_bonus = get_companion_attack_bonus();
_base_damage += _companion_bonus;
```

**Example Companion Bonuses:**
- Yorna's Warriors Presence: +1 to +5 damage (scales with affinity)
- Cowsill's Strike Force: +2 to +8 damage (scales with affinity)

**Location:** `/scripts/scr_companion_system/scr_companion_system.gml`

### Stage 4: Dash Attack Bonus

Apply 1.5x multiplier if dash attacking:

```gml
if (is_dash_attacking) {
    _base_damage *= dash_attack_damage_multiplier;  // 1.5x
}
```

**Applies to:**
- Collision damage during dash
- Post-dash attack window (0.4 seconds after dash)

**Location:** `/scripts/player_dash_attack/player_dash_attack.gml`

### Stage 5: Execution Window Multiplier

Apply bonus damage when attacking low-health enemies:

```gml
// Example execution window implementation
if (target.hp <= target.hp_total * 0.2) {  // 20% HP threshold
    _base_damage *= 1.3;  // +30% execution bonus
}
```

### Stage 6: Critical Hit Roll

Roll for critical hit and apply multiplier if successful:

```gml
// Roll for crit
var _crit_roll = random(1.0);
var _is_crit = (_crit_roll < crit_chance);

if (_is_crit) {
    _base_damage *= crit_multiplier;  // Default 1.75x
    last_attack_was_crit = true;
}
```

**Default Values:**
- `crit_chance`: 0.1 (10%)
- `crit_multiplier`: 1.75 (75% bonus damage)

### Complete Damage Calculation Order

```
Final Damage = (Base Weapon Damage
                × Versatile/Dual-Wield Modifiers
                × Status Effect Modifiers)
               + Companion Bonuses
               × Dash Attack Multiplier (if active)
               × Execution Multiplier (if low HP)
               × Critical Hit Multiplier (if crit)
```

---

## Damage Reduction Pipeline (When Hit)

When an entity takes damage, the incoming damage goes through multiple reduction stages before being applied to HP.

**Location:** `/scripts/scr_combat_system/scr_combat_system.gml` and collision events

### Stage 1: Damage Type Modifier

Apply trait-based resistance/vulnerability to incoming damage:

```gml
// Get damage type modifier from traits
var trait_modifier = get_damage_modifier_for_type(damage_type);
var modified_damage = base_damage * trait_modifier;
```

**Trait System Integration:**
- `fire_immunity`: 0.0x multiplier (no damage)
- `fire_resistance`: 0.75x multiplier per stack
- `fire_vulnerability`: 1.5x multiplier per stack
- Traits stack and can cancel each other out

**Location:** `/scripts/trait_system/trait_system.gml`

### Stage 2: Equipment DR

Subtract damage reduction from equipped armor:

```gml
// Get appropriate DR based on attack category
var equipment_dr = 0;

if (attack_category == AttackCategory.melee) {
    equipment_dr = get_equipment_melee_dr();
} else if (attack_category == AttackCategory.ranged) {
    equipment_dr = get_equipment_ranged_dr();
}

// Also add general DR (applies to all attacks)
equipment_dr += get_equipment_general_dr();
```

**DR Sources:**
- **general_dr**: Applies to all damage (shields, certain armor)
- **melee_dr**: Only applies to melee attacks (heavy armor)
- **ranged_dr**: Only applies to ranged attacks (certain traits/effects)

**Location:** `/scripts/player_attack_helpers/player_attack_helpers.gml`

### Stage 3: Companion DR

Add DR bonuses from companion auras:

```gml
var companion_dr = get_companion_dr_bonus();
var total_dr = equipment_dr + companion_dr;
```

**Example Companion DR:**
- Canopy's Guardian Shield: +2 to +10 DR (scales with affinity)
- Nellis's Sacred Ward: +1 to +6 DR (scales with affinity)

### Stage 4: Defense Trait Modifier

Multiply total DR by defense modifier from traits:

```gml
var defense_modifier = get_defense_trait_modifier();
total_dr *= defense_modifier;
```

**Defense Traits:**
- `defense_resistance` (bolstered): 1.33^stacks multiplier to DR
- `defense_vulnerability` (sundered): 0.75^stacks multiplier to DR

**Example:**
- 2 stacks of bolstered: DR × 1.77 (1.33²)
- 2 stacks of sundered: DR × 0.56 (0.75²)

### Stage 5: Final Damage and Chip Damage

Apply DR and ensure minimum damage:

```gml
var final_damage = modified_damage - total_dr;

// Chip damage: minimum 1 damage if attack landed
if (final_damage <= 0) {
    final_damage = 1;  // Chip damage
}

// Apply damage to HP
hp -= final_damage;
```

**Chip Damage Rule:**
- Even with perfect resistance/DR, attacks deal minimum 1 damage
- Prevents invulnerability exploits
- Only exception: 0.0x damage type immunity (fire_immunity, etc.)

### Complete Damage Reduction Order

```
Final Damage = max(1,
    (Base Damage × Damage Type Modifier)
    - (Equipment DR + Companion DR) × Defense Trait Modifier
)

Exception: If Damage Type Modifier = 0.0 (immunity), Final Damage = 0
```

---

## Attack Categories

Attacks are categorized to determine which DR calculation to use:

```gml
enum AttackCategory {
    melee,    // Sword swings, dagger strikes, unarmed attacks
    ranged    // Arrows, thrown weapons, projectiles
}
```

**Location:** `/scripts/scr_enums/scr_enums.gml`

### Usage in Combat

**Melee Attacks:**
- Player attack objects (`obj_attack`)
- Enemy melee collision damage
- Dash attack collision damage
- Uses `get_equipment_melee_dr()` for damage reduction

**Ranged Attacks:**
- Player arrows (`obj_arrow`)
- Enemy arrows (`obj_enemy_arrow`)
- Hazard projectiles (`obj_hazard_projectile`)
- Uses `get_equipment_ranged_dr()` for damage reduction

**Attack Info Structure:**
```gml
var attack_info = {
    damage: calculated_damage,
    damage_type: DamageType.physical,
    attack_category: AttackCategory.melee,  // or ranged
    is_crit: false,
    knockback_force: 2,
    shake_intensity: 4,
    apply_status_effects: true,
    allow_interrupt: true,
    armor_pierce: 0,
    flash_on_hit: true
};
```

---

## Combat Visual Feedback

### Freeze Frame

Brief pause on hit for impact feel:

```gml
freeze_frame(duration);  // 2-4 frames typical
```

**Location:** `/scripts/scr_combat_helpers/scr_combat_helpers.gml`

### Screen Shake

Intensity based on weapon type:

```gml
// Shake intensity by weapon handedness
var shake_intensity = 4;  // Default one-handed

if (weapon_handedness == WeaponHandedness.dagger) {
    shake_intensity = 2;
} else if (weapon_handedness == WeaponHandedness.two_handed) {
    shake_intensity = 8;
} else if (is_two_handing()) {
    shake_intensity = 6;
}

screen_shake(shake_intensity);
```

**Location:** Screen shake controller

### Enemy Flash

Visual feedback on enemy hit:

```gml
enemy_flash(color, duration);

// Normal hit: white flash
enemy_flash(c_white, 2);

// Critical hit: red flash
enemy_flash(c_red, 4);
```

**Location:** `/scripts/scr_combat_helpers/scr_combat_helpers.gml`

### Hit Sparkles

Particle spray from impact point:

```gml
spawn_hit_effect(x, y, direction);
```

**Properties:**
- Spawns at impact location
- Sprays in direction away from attacker
- Different particles for crit vs normal hit

### Slow-Mo

Bullet-time effect on companion triggers:

```gml
activate_slowmo(duration);

// Example: 0.5 second slow-mo on companion trigger
activate_slowmo(0.5);
```

**Effect:**
- Slows game speed to 50%
- Duration in seconds
- Used for impactful companion abilities

### Damage Numbers

Floating text showing damage amount and type:

```gml
spawn_damage_number(x, y, damage_amount, damage_type);
```

**Properties:**
- Color-coded by damage type
- Larger font for critical hits
- Floats upward and fades out
- Shows actual damage dealt (after all reductions)

**Color Mapping:**
```gml
// In damage_type_to_color() function
switch(damage_type) {
    case DamageType.physical: return c_white;
    case DamageType.fire:     return c_red;
    case DamageType.ice:      return c_aqua;
    case DamageType.lightning: return c_yellow;
    case DamageType.poison:   return c_lime;
    case DamageType.magical:  return c_fuchsia;
    // etc.
}
```

---

## Key Files Reference

| File | Purpose | Key Lines |
|------|---------|-----------|
| `/scripts/scr_combat_system/scr_combat_system.gml` | Core damage calculation | Full file |
| `/scripts/player_attack_helpers/player_attack_helpers.gml` | DR calculations | Full file |
| `/objects/obj_attack/Create_0.gml` | Melee attack instance | Full file |
| `/objects/obj_arrow/Create_0.gml` | Ranged attack projectile | Full file |
| `/objects/obj_enemy_parent/Collision_obj_attack.gml` | Damage application to enemies | Full file |
| `/scripts/scr_status_effects/scr_status_effects.gml` | Status effect modifiers | Full file |
| `/scripts/trait_system/trait_system.gml` | Trait damage modifiers | Full file |
| `/scripts/scr_companion_system/scr_companion_system.gml` | Companion bonuses | Full file |

---

*Last Updated: 2025-10-17*
