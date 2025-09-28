enum PlayerState {
	idle,
	walking,
	dashing,
	attacking,
	on_grid,
	dead,
}

enum Direction {
	down,
	right,
	left,
	up
}

enum ButtonType {
	resume,
	settings,
	quit
}

// Item Database based on your sprite sheet
// Sprite frames are indexed 0-24 from left to right, top to bottom

enum ItemType {
    weapon,
    armor,
    consumable,
    tool,
    ammo
}

enum EquipSlot {
    none = -1,
    right_hand,
    left_hand,
    helmet,
    armor,
    boots,
    either_hand
}

enum WeaponHandedness {
    one_handed,
    two_handed,
    versatile
}

// Item definition constructor
function create_item_definition(_frame, _id, _name, _type, _slot, _stats) constructor {
    item_id = _id;
    name = _name;
    type = _type;
    equip_slot = _slot;
    stats = _stats;
    world_sprite_frame = _frame;
    
    // Determine handedness from stats
    handedness = _stats[$ "handedness"] ?? WeaponHandedness.one_handed;
    
    // Sprite key for equipped version (used for save/load compatibility)
    equipped_sprite_key = _stats[$ "equipped_key"] ?? string_lower(string_replace(_name, " ", "_"));
}


// Create the global item database
global.item_database = {
    // Row 1 - Bladed weapons (frames 0-5)
    rusty_dagger: new create_item_definition(
        0, "rusty_dagger", "Rusty Dagger", ItemType.weapon, EquipSlot.either_hand,
        {damage: 2, attack_speed: 1.5, range: 20, handedness: WeaponHandedness.one_handed}
    ),
    short_sword: new create_item_definition(
        1, "short_sword", "Short Sword", ItemType.weapon, EquipSlot.either_hand,
        {damage: 3, attack_speed: 1.2, range: 28, handedness: WeaponHandedness.one_handed}
    ),
    long_sword: new create_item_definition(
        2, "long_sword", "Long Sword", ItemType.weapon, EquipSlot.either_hand,
        {damage: 4, attack_speed: 1.0, range: 36, handedness: WeaponHandedness.versatile, two_handed_damage: 5, two_handed_range: 40}
    ),
    master_sword: new create_item_definition(
        3, "master_sword", "Master Sword", ItemType.weapon, EquipSlot.either_hand,
        {damage: 6, attack_speed: 1.1, range: 38, handedness: WeaponHandedness.versatile, two_handed_damage: 7, two_handed_range: 42, magic_power: 5}
    ),
    greatsword: new create_item_definition(
        4, "greatsword", "Greatsword", ItemType.weapon, EquipSlot.right_hand,
        {damage: 8, attack_speed: 0.7, range: 45, handedness: WeaponHandedness.two_handed}
    ),
    spear: new create_item_definition(
        5, "spear", "Spear", ItemType.weapon, EquipSlot.right_hand,
        {damage: 4, attack_speed: 1.1, range: 50, handedness: WeaponHandedness.versatile, two_handed_damage: 5, two_handed_range: 55}
    ),
    
    // Row 2 - Axe and bows (frames 6-11)
    axe: new create_item_definition(
        6, "axe", "Axe", ItemType.weapon, EquipSlot.either_hand,
        {damage: 5, attack_speed: 0.8, range: 30, handedness: WeaponHandedness.versatile, two_handed_damage: 6}
    ),
    wooden_bow: new create_item_definition(
        7, "wooden_bow", "Wooden Bow", ItemType.weapon, EquipSlot.right_hand,
        {damage: 2, attack_speed: 1.2, range: 120, handedness: WeaponHandedness.two_handed, requires_ammo: "arrows"}
    ),
    longbow: new create_item_definition(
        8, "longbow", "Longbow", ItemType.weapon, EquipSlot.right_hand,
        {damage: 5, attack_speed: 1.0, range: 150, handedness: WeaponHandedness.two_handed, requires_ammo: "arrows"}
    ),
    crossbow: new create_item_definition(
        9, "crossbow", "Crossbow", ItemType.weapon, EquipSlot.right_hand,
        {damage: 3, attack_speed: 0.6, range: 140, handedness: WeaponHandedness.two_handed, requires_ammo: "arrows"}
    ),
    heavy_crossbow: new create_item_definition(
        10, "heavy_crossbow", "Heavy Crossbow", ItemType.weapon, EquipSlot.right_hand,
        {damage: 6, attack_speed: 0.4, range: 160, armor_penetration: 0.3, handedness: WeaponHandedness.two_handed, requires_ammo: "arrows"}
    ),
    torch: new create_item_definition(
        11, "torch", "Torch", ItemType.tool, EquipSlot.left_hand,
        {light_radius: 100, handedness: WeaponHandedness.one_handed}
    ),
    
    // Row 3 - Chain armor set (frames 12-14) and Leather armor set (frames 15-17)
    chain_helmet: new create_item_definition(
        12, "chain_helmet", "Chain Helmet", ItemType.armor, EquipSlot.helmet,
        {defense: 4}
    ),
    chain_armor: new create_item_definition(
        13, "chain_armor", "Chain Armor", ItemType.armor, EquipSlot.armor,
        {defense: 10, speed_modifier: 0.9}
    ),
    chain_greaves: new create_item_definition(
        14, "chain_greaves", "Chain Greaves", ItemType.armor, EquipSlot.boots,
        {defense: 3, speed_modifier: 0.95}
    ),
    leather_helmet: new create_item_definition(
        15, "leather_helmet", "Leather Helmet", ItemType.armor, EquipSlot.helmet,
        {defense: 2}
    ),
    leather_armor: new create_item_definition(
        16, "leather_armor", "Leather Armor", ItemType.armor, EquipSlot.armor,
        {defense: 5}
    ),
    leather_greaves: new create_item_definition(
        17, "leather_greaves", "Leather Greaves", ItemType.armor, EquipSlot.boots,
        {defense: 2, speed_modifier: 1.05}
    ),
    
    // Row 4 - Shields and consumables (frames 18-23)
    shield: new create_item_definition(
        18, "shield", "Shield", ItemType.armor, EquipSlot.left_hand,
        {defense: 5, block_chance: 0.25}
    ),
    greatshield: new create_item_definition(
        19, "greatshield", "Greatshield", ItemType.armor, EquipSlot.left_hand,
        {defense: 10, block_chance: 0.35, speed_modifier: 0.85}
    ),
    health_potion: new create_item_definition(
        20, "health_potion", "Health Potion", ItemType.consumable, EquipSlot.none,
        {heal_amount: 50, stack_size: 10}
    ),
    water: new create_item_definition(
        21, "water", "Water", ItemType.consumable, EquipSlot.none,
        {stamina_restore: 30, stack_size: 10}
    ),
    purple_potion: new create_item_definition(
        22, "purple_potion", "Purple Potion", ItemType.consumable, EquipSlot.none,
        {mana_restore: 40, stack_size: 10}
    ),
    red_potion: new create_item_definition(
        23, "red_potion", "Red Potion", ItemType.consumable, EquipSlot.none,
        {damage_buff: 5, duration: 600, stack_size: 5}  // Strength/damage boost potion
    ),
    
    // Additional item (frame 24)
    arrows: new create_item_definition(
        24, "arrows", "Arrows", ItemType.ammo, EquipSlot.none,
        {stack_size: 99}
    )
};

// Helper function to spawn items in the world with count support
function spawn_item(_x, _y, _item_key, _count = 1) {
    var _item = instance_create_layer(_x, _y, "Items", obj_item_pickup);
    _item.item_def = global.item_database[$ _item_key];
    _item.sprite_index = spr_items;  // Your items sprite
    _item.image_index = _item.item_def.world_sprite_frame;
    _item.image_speed = 0;
    
    // For stackable items like arrows
    _item.count = _count;
    
    return _item;
}

// Example: Spawn arrows with random count
// spawn_item(x, y, "arrows", choose(6, 12));


// ============================================
// INVENTORY MANAGEMENT FUNCTIONS
// ============================================

// Add item to inventory with stacking support
function inventory_add_item(_item_def, _count = 1) {
    // Check if item is stackable and already exists in inventory
    if (_item_def.stats[$ "stack_size"] != undefined) {
        // Look for existing stack
        for (var i = 0; i < array_length(inventory); i++) {
            var _existing = inventory[i];
            if (_existing.definition.item_id == _item_def.item_id) {
                var _max_stack = _item_def.stats.stack_size;
                var _space_left = _max_stack - _existing.count;
                
                if (_space_left > 0) {
                    var _to_add = min(_space_left, _count);
                    _existing.count += _to_add;
                    _count -= _to_add;
                    
                    if (_count <= 0) return true; // All items added
                }
            }
        }
    }
    
    // Add remaining items as new stacks
    while (_count > 0 && array_length(inventory) < max_inventory_size) {
        var _stack_size = _item_def.stats[$ "stack_size"] ?? 1;
        var _this_stack = min(_count, _stack_size);
        
        var _item_instance = {
            definition: _item_def,
            count: _this_stack,
            durability: 100  // Optional durability system
        };
        
        array_push(inventory, _item_instance);
        _count -= _this_stack;
    }
    
    return (_count <= 0); // Return true if all items were added
}

// Remove item from inventory
function inventory_remove_item(_inventory_index, _count = 1) {
    if (_inventory_index < 0 || _inventory_index >= array_length(inventory)) return false;
    
    var _item = inventory[_inventory_index];
    
    if (_item.count > _count) {
        _item.count -= _count;
        return true;
    } else {
        array_delete(inventory, _inventory_index, 1);
        return true;
    }
}

// ============================================
// EQUIPMENT FUNCTIONS
// ============================================

// Equip item with two-handed weapon handling
function equip_item(_inventory_index, _target_hand = undefined) {
    if (_inventory_index < 0 || _inventory_index >= array_length(inventory)) return false;
    
    var _item = inventory[_inventory_index];
    var _def = _item.definition;
    
    if (_def.equip_slot == EquipSlot.none) return false;
    
    var _slot_name = "";
    
    // Handle hand slots
    if (_def.equip_slot == EquipSlot.right_hand ||
        _def.equip_slot == EquipSlot.left_hand ||
        _def.equip_slot == EquipSlot.either_hand) {
        
        // Determine which hand to equip to
        if (_def.equip_slot == EquipSlot.right_hand) {
            _slot_name = "right_hand";
        } else if (_def.equip_slot == EquipSlot.left_hand) {
            _slot_name = "left_hand";
        } else if (_def.equip_slot == EquipSlot.either_hand) {
            // Player can choose, or auto-select empty hand
            if (_target_hand != undefined) {
                _slot_name = _target_hand;
            } else {
                // Auto-select: prefer right hand if empty, then left hand
                if (equipped.right_hand == undefined) {
                    _slot_name = "right_hand";
                } else if (equipped.left_hand == undefined) {
                    _slot_name = "left_hand";
                } else {
                    _slot_name = "right_hand"; // Default to right if both occupied
                }
            }
        }
        
        // Check for two-handed weapon restrictions
        if (_def.handedness == WeaponHandedness.two_handed) {
            // Clear both hands for two-handed weapons
            if (equipped.right_hand != undefined) {
                inventory_add_item(equipped.right_hand.definition, equipped.right_hand.count);
                equipped.right_hand = undefined;
            }
            if (equipped.left_hand != undefined) {
                inventory_add_item(equipped.left_hand.definition, equipped.left_hand.count);
                equipped.left_hand = undefined;
            }
            _slot_name = "right_hand"; // Two-handed weapons go in right hand
        } else {
            // Check if currently holding a two-handed weapon
            var _current_right = equipped.right_hand;
            if (_current_right != undefined && 
                _current_right.definition.handedness == WeaponHandedness.two_handed) {
                // Can't equip anything else while holding two-handed weapon
                show_message("Cannot equip " + _def.name + " while wielding a two-handed weapon!");
                return false;
            }
        }
    } else {
        // Non-hand slots (helmet, armor, boots)
        _slot_name = get_slot_name(_def.equip_slot);
    }
    
    // Unequip current item in that slot
    if (equipped[$ _slot_name] != undefined) {
        inventory_add_item(equipped[$ _slot_name].definition, equipped[$ _slot_name].count);
    }
    
    // Equip new item
    equipped[$ _slot_name] = _item;
    
    // For stackable items, only take 1 from the stack
    if (_item.count > 1) {
        _item.count--;
        // Create new instance for equipped item
        equipped[$ _slot_name] = {
            definition: _def,
            count: 1,
            durability: _item.durability
        };
    } else {
        array_delete(inventory, _inventory_index, 1);
    }
    
    return true;
}

// Unequip item back to inventory
function unequip_item(_slot_name) {
    if (equipped[$ _slot_name] == undefined) return false;
    
    var _item = equipped[$ _slot_name];
    if (inventory_add_item(_item.definition, _item.count)) {
        equipped[$ _slot_name] = undefined;
        return true;
    }
    
    show_message("Inventory full!");
    return false;
}

// Helper function to get slot name
function get_slot_name(_slot) {
    switch(_slot) {
        case EquipSlot.right_hand: return "right_hand";
        case EquipSlot.left_hand: return "left_hand";
        case EquipSlot.helmet: return "helmet";
        case EquipSlot.armor: return "armor";
        case EquipSlot.boots: return "boots";
        default: return "none";
    }
}

// Check if using weapon two-handed
function is_two_handing() {
    if (equipped.right_hand != undefined) {
        var _handedness = equipped.right_hand.definition.handedness;
        if (_handedness == WeaponHandedness.two_handed) return true;
        
        // Versatile weapons are two-handed when left hand is empty
        if (_handedness == WeaponHandedness.versatile && equipped.left_hand == undefined) {
            return true;
        }
    }
    return false;
}

// Check if dual-wielding
function is_dual_wielding() {
    return (equipped.right_hand != undefined && 
            equipped.left_hand != undefined &&
            equipped.right_hand.definition.type == ItemType.weapon &&
            equipped.left_hand.definition.type == ItemType.weapon);
}

// ============================================
// COMBAT STATS CALCULATION
// ============================================

function get_total_damage() {
    var _base_damage = 1; // Base unarmed damage

    // Right hand weapon
    if (equipped.right_hand != undefined && equipped.right_hand.definition.type == ItemType.weapon) {
        var _weapon_stats = equipped.right_hand.definition.stats;

        // Check if using versatile weapon two-handed
        if (is_two_handing() && equipped.right_hand.definition.handedness == WeaponHandedness.versatile) {
            _base_damage = _weapon_stats[$ "two_handed_damage"] ?? _weapon_stats.damage;
        } else {
            _base_damage = _weapon_stats.damage;
        }
    }

    // Add left hand weapon damage if dual-wielding
    if (is_dual_wielding()) {
        var _left_damage = equipped.left_hand.definition.stats.damage;
        _base_damage += _left_damage * 0.5; // Off-hand does 50% damage
    }

    return _base_damage;
}

function get_attack_range() {
    var _base_range = 16; // Base punch range
    
    if (equipped.right_hand != undefined && equipped.right_hand.definition.type == ItemType.weapon) {
        var _weapon_stats = equipped.right_hand.definition.stats;
        
        // Check if using versatile weapon two-handed
        if (is_two_handing() && equipped.right_hand.definition.handedness == WeaponHandedness.versatile) {
            return _weapon_stats[$ "two_handed_range"] ?? _weapon_stats.range;
        } else {
            return _weapon_stats.range;
        }
    }
    
    return _base_range;
}

function get_total_defense() {
    var _total_defense = 0;
    var _slots = ["helmet", "armor", "boots", "left_hand", "right_hand"];
    
    for (var i = 0; i < array_length(_slots); i++) {
        if (equipped[$ _slots[i]] != undefined) {
            var _stats = equipped[$ _slots[i]].definition.stats;
            if (variable_struct_exists(_stats, "defense")) {
                _total_defense += _stats.defense;
            }
        }
    }
    
    return _total_defense;
}

function get_block_chance() {
    // Check left hand for shield
    if (equipped.left_hand != undefined && !is_two_handing()) {
        var _stats = equipped.left_hand.definition.stats;
        return _stats[$ "block_chance"] ?? 0;
    }
    return 0;
}

function get_speed_modifier() {
    var _speed = 1.0;
    var _slots = ["helmet", "armor", "boots", "left_hand", "right_hand"];
    
    for (var i = 0; i < array_length(_slots); i++) {
        if (equipped[$ _slots[i]] != undefined) {
            var _stats = equipped[$ _slots[i]].definition.stats;
            if (variable_struct_exists(_stats, "speed_modifier")) {
                _speed *= _stats.speed_modifier;
            }
        }
    }
    
    return _speed;
}

// Check if player has enough arrows for bow
function has_ammo() {
    if (equipped.right_hand == undefined) return true;
    
    var _weapon = equipped.right_hand.definition;
    if (_weapon.stats[$ "requires_ammo"] != undefined) {
        var _ammo_type = _weapon.stats.requires_ammo;
        
        // Check inventory for ammo
        for (var i = 0; i < array_length(inventory); i++) {
            if (inventory[i].definition.item_id == _ammo_type) {
                return inventory[i].count > 0;
            }
        }
        return false;
    }
    
    return true;
}

// Consume ammo when firing
function consume_ammo() {
    if (equipped.right_hand == undefined) return;
    
    var _weapon = equipped.right_hand.definition;
    if (_weapon.stats[$ "requires_ammo"] != undefined) {
        var _ammo_type = _weapon.stats.requires_ammo;
        
        // Find and consume ammo
        for (var i = 0; i < array_length(inventory); i++) {
            if (inventory[i].definition.item_id == _ammo_type) {
                inventory_remove_item(i, 1);
                return;
            }
        }
    }
}


