# Item & Inventory System - Technical Documentation

This document provides comprehensive technical documentation for the item database and inventory systems in Shadow Work, including equipment, loadouts, and key functions.

---

## Table of Contents

1. [Item Database](#item-database)
2. [Equipment System](#equipment-system)
3. [Key Functions](#key-functions)

---

## Item Database

All items are defined in a global database initialized at game start.

**Location:** `/scripts/scripts.gml` (init_item_database function)

### Database Structure

```gml
// In obj_game_controller Create event
global.item_database = {};

// Initialized via init_item_database()
init_item_database();
```

### Item Definition Structure

```gml
global.item_database.item_key = {
    item_id: "item_key",              // Unique identifier (string)
    type: ItemType.weapon,            // Item type (enum)
    handedness: WeaponHandedness.one_handed,  // Weapon handedness (if weapon)

    // Stats struct
    stats: {
        attack_damage: 5,
        attack_speed: 1.0,
        attack_range: 32,
        damage_type: DamageType.physical,

        // Armor stats (if armor)
        general_dr: 0,
        melee_dr: 0,
        ranged_dr: 0,

        // Shield stats (if shield)
        block_dr: 5,
        block_arc: 90,

        // Consumable stats (if consumable)
        heal_amount: 10,
        effect_duration: 5.0
    },

    // Display
    display_name: "Rusty Dagger",
    description: "A worn blade that has seen better days",
    world_sprite_frame: 0,            // Frame in spr_items
    equipped_sprite_key: "rusty_dagger",  // For spr_wielded_[key]

    // Stacking (for consumables/ammo)
    stackable: false,
    max_stack: 1,

    // Wielder effects (applied while equipped)
    wielder_effects: [
        {trait: "empowered"}
    ],

    // Price and rarity
    gold_value: 25,
    rarity: "common"                  // "common", "uncommon", "rare", "epic", "legendary"
};
```

### ItemType Enum

```gml
enum ItemType {
    weapon,      // Swords, daggers, bows, etc.
    shield,      // Shields for blocking
    armor_head,  // Helmets, crowns
    armor_torso, // Chest armor, robes
    armor_legs,  // Leg armor, pants
    consumable,  // Potions, scrolls
    quest_item,  // Quest-specific items
    material,    // Crafting materials
    key          // Keys for doors/chests
}
```

**Location:** `/scripts/scr_enums/scr_enums.gml`

### WeaponHandedness Enum

```gml
enum WeaponHandedness {
    dagger,        // Light, fast weapons
    one_handed,    // Standard one-handed weapons
    versatile,     // Can be used one or two-handed
    two_handed     // Requires both hands
}
```

**Location:** `/scripts/scr_enums/scr_enums.gml`

### Example Item Definitions

#### Weapon Example

```gml
// Rusty Sword
global.item_database.rusty_sword = {
    item_id: "rusty_sword",
    type: ItemType.weapon,
    handedness: WeaponHandedness.one_handed,

    stats: {
        attack_damage: 5,
        attack_speed: 1.0,
        attack_range: 32,
        damage_type: DamageType.physical,
        knockback: 2,
        crit_chance: 0.1
    },

    display_name: "Rusty Sword",
    description: "A worn blade covered in rust",
    world_sprite_frame: 0,
    equipped_sprite_key: "rusty_sword",

    gold_value: 10,
    rarity: "common"
};

// Flaming Blade
global.item_database.flaming_blade = {
    item_id: "flaming_blade",
    type: ItemType.weapon,
    handedness: WeaponHandedness.one_handed,

    stats: {
        attack_damage: 8,
        attack_speed: 1.0,
        attack_range: 32,
        damage_type: DamageType.fire,  // Fire damage
        knockback: 3
    },

    wielder_effects: [
        {trait: "fire_resistance", stacks: 1}
    ],

    display_name: "Flaming Blade",
    description: "A sword wreathed in magical flames",
    world_sprite_frame: 12,
    equipped_sprite_key: "flaming_blade",

    gold_value: 150,
    rarity: "rare"
};

// Versatile Greatsword
global.item_database.greatsword = {
    item_id: "greatsword",
    type: ItemType.weapon,
    handedness: WeaponHandedness.versatile,

    stats: {
        attack_damage: 10,
        attack_speed: 0.8,
        attack_range: 40,
        damage_type: DamageType.physical,
        knockback: 5
    },

    display_name: "Greatsword",
    description: "Can be wielded with one or two hands",
    world_sprite_frame: 8,
    equipped_sprite_key: "greatsword",

    gold_value: 80,
    rarity: "uncommon"
};
```

#### Ranged Weapon Example

```gml
// Wooden Bow
global.item_database.wooden_bow = {
    item_id: "wooden_bow",
    type: ItemType.weapon,
    handedness: WeaponHandedness.two_handed,
    is_ranged: true,  // Flag for ranged weapon

    stats: {
        attack_damage: 2,
        attack_speed: 1.2,
        attack_range: 120,  // Range in pixels
        damage_type: DamageType.physical,
        ammo_type: "arrows",
        projectile_speed: 2
    },

    display_name: "Wooden Bow",
    description: "A simple hunting bow",
    world_sprite_frame: 15,
    equipped_sprite_key: "wooden_bow",

    gold_value: 40,
    rarity: "common"
};
```

#### Armor Example

```gml
// Leather Armor
global.item_database.leather_armor = {
    item_id: "leather_armor",
    type: ItemType.armor_torso,

    stats: {
        general_dr: 2,
        melee_dr: 1,
        ranged_dr: 0
    },

    display_name: "Leather Armor",
    description: "Light armor made from cured leather",
    world_sprite_frame: 20,
    equipped_sprite_key: "leather_armor",

    gold_value: 30,
    rarity: "common"
};

// Plate Mail
global.item_database.plate_mail = {
    item_id: "plate_mail",
    type: ItemType.armor_torso,

    stats: {
        general_dr: 5,
        melee_dr: 3,
        ranged_dr: 1
    },

    wielder_effects: [
        {trait: "defense_resistance", stacks: 1}  // Bolstered
    ],

    display_name: "Plate Mail",
    description: "Heavy armor forged from thick steel plates",
    world_sprite_frame: 24,
    equipped_sprite_key: "plate_mail",

    gold_value: 200,
    rarity: "rare"
};
```

#### Consumable Example

```gml
// Small Health Potion
global.item_database.small_health_potion = {
    item_id: "small_health_potion",
    type: ItemType.consumable,

    stats: {
        heal_amount: 10
    },

    stackable: true,
    max_stack: 99,

    display_name: "Small Health Potion",
    description: "Restores 10 HP",
    world_sprite_frame: 30,

    gold_value: 5,
    rarity: "common"
};

// Arrows
global.item_database.arrows = {
    item_id: "arrows",
    type: ItemType.consumable,

    stackable: true,
    max_stack: 99,

    display_name: "Arrows",
    description: "Ammunition for bows",
    world_sprite_frame: 32,

    gold_value: 1,
    rarity: "common"
};
```

---

## Equipment System

Equipment slots and the loadout system for switching between melee and ranged weapons.

**Location:** `/objects/obj_player/Create_0.gml` and `/scripts/scr_inventory/scr_inventory.gml`

### Equipment Slots

```gml
// In obj_player Create event
equipped = {
    right_hand: undefined,  // Primary weapon
    left_hand: undefined,   // Shield, off-hand weapon, or two-handed grip
    head: undefined,        // Helmet
    torso: undefined,       // Chest armor
    legs: undefined         // Leg armor
};
```

**Slot Rules:**
- **right_hand**: Any weapon
- **left_hand**: Shield, one-handed weapon, or empty (for two-handing)
- **head/torso/legs**: Appropriate armor type only

### Loadout System

Players can switch between melee and ranged loadouts:

```gml
// Loadout storage
melee_loadout = {
    right_hand: undefined,
    left_hand: undefined
};

ranged_loadout = {
    right_hand: undefined,
    left_hand: undefined
};

active_loadout = "melee";  // "melee" or "ranged"
```

**Switching Loadouts:**
```gml
function switch_loadout() {
    if (active_loadout == "melee") {
        // Save current melee loadout
        melee_loadout.right_hand = equipped.right_hand;
        melee_loadout.left_hand = equipped.left_hand;

        // Load ranged loadout
        equipped.right_hand = ranged_loadout.right_hand;
        equipped.left_hand = ranged_loadout.left_hand;

        active_loadout = "ranged";
    }
    else {
        // Save current ranged loadout
        ranged_loadout.right_hand = equipped.right_hand;
        ranged_loadout.left_hand = equipped.left_hand;

        // Load melee loadout
        equipped.right_hand = melee_loadout.right_hand;
        equipped.left_hand = melee_loadout.left_hand;

        active_loadout = "melee";
    }

    // Recalculate stats
    recalculate_player_stats();
}
```

**Auto-Equip Rules:**
When picking up a ranged weapon, automatically equip to ranged loadout:
```gml
if (item.is_ranged) {
    ranged_loadout.right_hand = item;
} else {
    melee_loadout.right_hand = item;
}
```

**Location:** `/docs/AUTO_EQUIP_RULES.md` for detailed auto-equip documentation

### Two-Handing System

Versatile weapons can be wielded with one or two hands:

```gml
function is_two_handing() {
    if (equipped.right_hand == undefined) return false;

    var right_weapon = equipped.right_hand;

    // Check if versatile weapon with empty left hand
    if (right_weapon.handedness == WeaponHandedness.versatile &&
        equipped.left_hand == undefined) {
        return true;
    }

    // Check if two-handed weapon
    if (right_weapon.handedness == WeaponHandedness.two_handed) {
        return true;
    }

    return false;
}
```

**Damage Bonus:**
Two-handing a versatile weapon grants +50% damage:
```gml
var base_damage = right_weapon.stats.attack_damage;

if (is_two_handing()) {
    base_damage *= 1.5;
}
```

**Location:** `/scripts/scr_combat_system/scr_combat_system.gml`

### Dual-Wield System

Wielding two one-handed weapons applies a damage penalty:

```gml
var right_weapon = equipped.right_hand;
var left_weapon = equipped.left_hand;

if (right_weapon != undefined &&
    left_weapon != undefined &&
    left_weapon.type == ItemType.weapon) {

    // -25% damage on each weapon
    right_damage *= 0.75;
    left_damage *= 0.75;
}
```

### Wielder Effects

Equipment can apply effects while equipped:

```gml
// Apply wielder effects from all equipped items
function apply_wielder_effects() {
    // Clear temporary traits
    temporary_traits = {};

    // Apply wielder effects from each equipped item
    for (var slot in equipped) {
        var item = equipped[$ slot];

        if (item != undefined && item.wielder_effects != undefined) {
            for (var i = 0; i < array_length(item.wielder_effects); i++) {
                var effect = item.wielder_effects[i];

                if (effect.trait != undefined) {
                    // Apply trait
                    var stacks = effect.stacks ?? 1;
                    add_temporary_trait(effect.trait, stacks);
                }

                if (effect.status != undefined) {
                    // Apply permanent status while equipped
                    apply_status_effect(effect.status);
                }
            }
        }
    }
}
```

**Called:**
- When equipping/unequipping items
- When loading save game
- On game start

---

## Key Functions

Core inventory and equipment functions.

**Location:** `/scripts/scr_inventory/scr_inventory.gml`

### inventory_add_item()

Add item to player inventory with stacking support.

```gml
function inventory_add_item(item_key, quantity = 1) {
    var item_def = global.item_database[$ item_key];

    if (item_def == undefined) {
        show_debug_message("Warning: Unknown item: " + item_key);
        return false;
    }

    // Check if stackable
    if (item_def.stackable) {
        // Find existing stack
        for (var i = 0; i < array_length(inventory); i++) {
            var inv_item = inventory[i];

            if (inv_item.item_id == item_key) {
                // Add to existing stack
                var space_left = item_def.max_stack - inv_item.quantity;
                var to_add = min(quantity, space_left);

                inv_item.quantity += to_add;
                quantity -= to_add;

                if (quantity <= 0) {
                    return true;  // All added
                }
            }
        }

        // Create new stack(s) for remaining quantity
        while (quantity > 0) {
            var new_stack_size = min(quantity, item_def.max_stack);

            array_push(inventory, {
                item_id: item_key,
                quantity: new_stack_size
            });

            quantity -= new_stack_size;
        }
    }
    else {
        // Non-stackable, add as individual items
        for (var i = 0; i < quantity; i++) {
            array_push(inventory, {
                item_id: item_key,
                quantity: 1
            });
        }
    }

    // Track for quest objectives
    quest_check_objective_progress("collect", item_key);

    return true;
}
```

### equip_item()

Equip item to specific slot.

```gml
function equip_item(item_key, slot) {
    var item_def = global.item_database[$ item_key];

    if (item_def == undefined) {
        return false;
    }

    // Validate slot for item type
    if (!is_valid_slot_for_item(item_def, slot)) {
        show_debug_message("Invalid slot for item type");
        return false;
    }

    // Unequip current item in slot
    if (equipped[$ slot] != undefined) {
        unequip_item(slot);
    }

    // Equip new item
    equipped[$ slot] = item_def;

    // Remove from inventory
    inventory_remove_item(item_key, 1);

    // Apply wielder effects
    apply_wielder_effects();

    // Recalculate stats
    recalculate_player_stats();

    return true;
}
```

### unequip_item()

Remove item from equipment slot.

```gml
function unequip_item(slot) {
    var item = equipped[$ slot];

    if (item == undefined) {
        return false;
    }

    // Add back to inventory
    inventory_add_item(item.item_id, 1);

    // Remove from equipment
    equipped[$ slot] = undefined;

    // Reapply wielder effects
    apply_wielder_effects();

    // Recalculate stats
    recalculate_player_stats();

    return true;
}
```

### get_total_damage()

Calculate total player damage with all modifiers.

```gml
function get_total_damage() {
    var _base_damage = 0;

    // Get weapon damage
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

    // Apply status effect modifiers
    var _status_modifier = get_status_effect_modifier("damage");
    _base_damage *= _status_modifier;

    // Add companion bonuses
    var _companion_bonus = get_companion_attack_bonus();
    _base_damage += _companion_bonus;

    // Apply dash attack multiplier
    if (is_dash_attacking) {
        _base_damage *= dash_attack_damage_multiplier;
    }

    return _base_damage;
}
```

**Location:** `/scripts/scr_combat_system/scr_combat_system.gml`

### get_attack_range()

Calculate total attack range.

```gml
function get_attack_range() {
    if (equipped[$ "right_hand"] == undefined) {
        return 20;  // Default unarmed range
    }

    return equipped[$ "right_hand"].stats.attack_range;
}
```

### get_equipment_general_dr()

Get total general damage reduction from equipment.

```gml
function get_equipment_general_dr() {
    var total_dr = 0;

    for (var slot in equipped) {
        var item = equipped[$ slot];

        if (item != undefined && item.stats.general_dr != undefined) {
            total_dr += item.stats.general_dr;
        }
    }

    return total_dr;
}
```

### get_equipment_melee_dr()

Get total melee-specific damage reduction.

```gml
function get_equipment_melee_dr() {
    var total_dr = 0;

    for (var slot in equipped) {
        var item = equipped[$ slot];

        if (item != undefined && item.stats.melee_dr != undefined) {
            total_dr += item.stats.melee_dr;
        }
    }

    return total_dr;
}
```

### get_equipment_ranged_dr()

Get total ranged-specific damage reduction.

```gml
function get_equipment_ranged_dr() {
    var total_dr = 0;

    for (var slot in equipped) {
        var item = equipped[$ slot];

        if (item != undefined && item.stats.ranged_dr != undefined) {
            total_dr += item.stats.ranged_dr;
        }
    }

    return total_dr;
}
```

**Location:** `/scripts/player_attack_helpers/player_attack_helpers.gml`

---

## Key Files Reference

| File | Purpose | Key Lines |
|------|---------|-----------|
| `/scripts/scripts.gml` | Item database initialization | Full file |
| `/scripts/scr_inventory/scr_inventory.gml` | Inventory functions | Full file |
| `/scripts/scr_combat_system/scr_combat_system.gml` | Combat stat calculations | Full file |
| `/scripts/player_attack_helpers/player_attack_helpers.gml` | DR calculations | Full file |
| `/objects/obj_player/Create_0.gml` | Equipment and inventory storage | Lines 100-150 |
| `/docs/AUTO_EQUIP_RULES.md` | Auto-equip documentation | Full file |
| `/docs/ITEM_ACQUISITION.md` | Item acquisition design | Full file |

---

*Last Updated: 2025-10-17*
