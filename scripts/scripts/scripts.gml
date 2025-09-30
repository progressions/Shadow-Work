enum PlayerState {
	idle,
	walking,
	dashing,
	attacking,
	on_grid,
	dead,
}

enum EnemyState {
	idle,
	attacking,
	dead,
}

enum StatusEffectType {
	burning,
	wet,
	empowered,
	weakened,
	swift,
	slowed,
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
        {damage: 6, attack_speed: 1.1, range: 38, handedness: WeaponHandedness.versatile, two_handed_damage: 7, two_handed_range: 42, magic_power: 5, status_effects: [{effect: StatusEffectType.empowered, chance: 0.3}]}
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
        {light_radius: 100, handedness: WeaponHandedness.one_handed, status_effects: [{effect: StatusEffectType.burning, chance: 0.2}]}
    ),
    
    // Row 3 - Chain armor set (frames 12-14) and Leather armor set (frames 15-17)
    chain_coif: new create_item_definition(
        12, "chain_coif", "Chain Coif", ItemType.armor, EquipSlot.helmet,
        {defense: 4}
    ),
    chain_armor: new create_item_definition(
        13, "chain_armor", "Chain Armor", ItemType.armor, EquipSlot.armor,
        {defense: 10, speed_modifier: 0.9}
    ),
    chain_leggings: new create_item_definition(
        14, "chain_leggings", "Chain Leggings", ItemType.armor, EquipSlot.boots,
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
    ),

    // Plate armor set (frames 25-27) - Heavy tier
    plate_helmet: new create_item_definition(
        25, "plate_helmet", "Plate Helmet", ItemType.armor, EquipSlot.helmet,
        {defense: 6, speed_modifier: 0.9}
    ),
    plate_armor: new create_item_definition(
        26, "plate_armor", "Plate Armor", ItemType.armor, EquipSlot.armor,
        {defense: 15, speed_modifier: 0.8}
    ),
    plate_sabatons: new create_item_definition(
        27, "plate_sabatons", "Plate Sabatons", ItemType.armor, EquipSlot.boots,
        {defense: 4, speed_modifier: 0.9}
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
    
    show_debug_message("Inventory full!");
    return false;
}

// Helper function to get slot name
function get_slot_name(_slot) {
    switch(_slot) {
        case EquipSlot.right_hand: return "right_hand";
        case EquipSlot.left_hand: return "left_hand";
        case EquipSlot.helmet: return "head";
        case EquipSlot.armor: return "torso";
        case EquipSlot.boots: return "legs";
        default: return "none";
    }
}

// Check if using weapon two-handed
function is_two_handing() {
    if (equipped.right_hand != undefined) {
        var _handedness = equipped.right_hand.definition.handedness;
        if (_handedness == WeaponHandedness.two_handed) return true;
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
// ENEMY ANIMATION DATA
// ============================================

// Standard enemy animation structure based on sprite frame tags
global.enemy_anim_data = {
    idle_down: {start: 0, length: 2},
    idle_right: {start: 2, length: 2},
    idle_left: {start: 4, length: 2},
    idle_up: {start: 6, length: 2},

    walk_down: {start: 8, length: 3},
    walk_right: {start: 11, length: 3},
    walk_left: {start: 14, length: 3},
    walk_up: {start: 17, length: 3},

    attack_down: {start: 20, length: 3},
    attack_right: {start: 23, length: 3},
    attack_left: {start: 26, length: 3},
    attack_up: {start: 29, length: 3},

    dying: {start: 32, length: 3}
};

// Get animation data for enemy state and direction
function get_enemy_anim(state, dir_index) {
    var dir_names = ["down", "right", "left", "up"];
    var state_name = "";

    switch(state) {
        case EnemyState.idle: state_name = "idle"; break;
        case EnemyState.attacking: state_name = "attack"; break;
        case EnemyState.dead: state_name = "dying"; break;
        default: state_name = "idle"; break;
    }

    var anim_key = state_name + "_" + dir_names[dir_index];
    return global.enemy_anim_data[$ anim_key] ?? global.enemy_anim_data.idle_down;
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

    // Apply status effect damage modifiers
    var damage_modifier = get_status_effect_modifier("damage");
    _base_damage *= damage_modifier;

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

function gain_xp(_amount) {
    if (_amount <= 0) return; // No negative or zero XP

    xp += _amount;
    show_debug_message("Gained " + string(_amount) + " XP");

    // Check for level ups
    while (xp >= xp_to_next) {
        xp -= xp_to_next;
        level++;

        // Increase XP requirement for next level (25% increase per level)
        xp_to_next = ceil(xp_to_next * 1.25);

        // Level up bonuses
        var old_hp_total = hp_total;
        hp_total += 2; // Gain 2 max HP per level
        hp += 2; // Also heal 2 HP when leveling up

        show_debug_message("LEVEL UP! Now level " + string(level));
        show_debug_message("Max HP increased from " + string(old_hp_total) + " to " + string(hp_total));
        show_debug_message("Next level requires " + string(xp_to_next) + " XP");

        // TODO: Add level up sound effect
        // audio_play_sound(snd_level_up, 1, false);
    }
}

function get_total_defense() {
    var _total_defense = 0;
    var _slots = ["head", "torso", "legs", "left_hand", "right_hand"];
    
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
    var _slots = ["head", "torso", "legs", "left_hand", "right_hand"];
    
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

// ============================================
// STATUS EFFECTS SYSTEM
// ============================================

// Helper function to get status effects from weapon/item (backward compatible)
function get_weapon_status_effects(_item_stats) {
    // New format: array of effects
    if (variable_struct_exists(_item_stats, "status_effects")) {
        return _item_stats.status_effects;
    }

    // Old format: single effect - convert to array
    if (variable_struct_exists(_item_stats, "status_effect")) {
        return [{
            effect: _item_stats.status_effect,
            chance: _item_stats[$ "status_chance"] ?? 1.0
        }];
    }

    return []; // No effects
}

// Status effect definitions
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
    empowered: {
        duration: 600,     // 10 seconds at 60fps
        damage_modifier: 1.5, // 50% damage increase
        opposing: StatusEffectType.weakened
    },
    weakened: {
        duration: 600,     // 10 seconds at 60fps
        damage_modifier: 0.7, // 30% damage reduction
        opposing: StatusEffectType.empowered
    },
    swift: {
        duration: 480,     // 8 seconds at 60fps
        speed_modifier: 1.3, // 30% speed increase
        opposing: StatusEffectType.slowed
    },
    slowed: {
        duration: 300,     // 5 seconds at 60fps
        speed_modifier: 0.6, // 40% speed reduction
        opposing: StatusEffectType.swift
    }
};

// Helper function to get status effect data
function get_status_effect_data(_effect_type) {
    switch(_effect_type) {
        case StatusEffectType.burning: return global.status_effect_data.burning;
        case StatusEffectType.wet: return global.status_effect_data.wet;
        case StatusEffectType.empowered: return global.status_effect_data.empowered;
        case StatusEffectType.weakened: return global.status_effect_data.weakened;
        case StatusEffectType.swift: return global.status_effect_data.swift;
        case StatusEffectType.slowed: return global.status_effect_data.slowed;
        default: return undefined;
    }
}

// Core status effects management functions
function init_status_effects() {
    status_effects = [];
}

function apply_status_effect(_effect_type, _duration_override = -1) {
    var effect_data = get_status_effect_data(_effect_type);
    if (effect_data == undefined) return false;

    // Check for opposing effect
    var opposing_type = effect_data.opposing;
    if (has_status_effect(opposing_type)) {
        // Remove opposing effect instead of applying new one
        remove_status_effect(opposing_type);
        return true;
    }

    // Check if effect already exists
    var existing_index = find_status_effect(_effect_type);
    if (existing_index != -1) {
        // Refresh duration
        var duration = (_duration_override != -1) ? _duration_override : effect_data.duration;
        status_effects[existing_index].remaining_duration = duration;
        status_effects[existing_index].tick_timer = 0;
        return true;
    }

    // Add new effect
    var duration = (_duration_override != -1) ? _duration_override : effect_data.duration;
    var new_effect = {
        type: _effect_type,
        remaining_duration: duration,
        tick_timer: 0,
        data: effect_data
    };

    array_push(status_effects, new_effect);
    return true;
}

function remove_status_effect(_effect_type) {
    var index = find_status_effect(_effect_type);
    if (index != -1) {
        array_delete(status_effects, index, 1);
        return true;
    }
    return false;
}

function has_status_effect(_effect_type) {
    return find_status_effect(_effect_type) != -1;
}

function find_status_effect(_effect_type) {
    for (var i = 0; i < array_length(status_effects); i++) {
        if (status_effects[i].type == _effect_type) {
            return i;
        }
    }
    return -1;
}

function tick_status_effects() {
    for (var i = array_length(status_effects) - 1; i >= 0; i--) {
        var effect = status_effects[i];

        // Handle damage over time effects
        if (effect.type == StatusEffectType.burning) {
            effect.tick_timer++;
            if (effect.tick_timer >= effect.data.tick_rate) {
                hp -= effect.data.damage;

                // Check if entity died from burning
                if (hp <= 0) {
                    if (object_index == obj_player) {
                        state = PlayerState.dead;
                        show_debug_message("Player died from burning");
                    } else if (object_is_ancestor(object_index, obj_enemy_parent)) {
                        state = EnemyState.dead;
                        show_debug_message("Enemy died from burning");

                        // Award XP to player for burning kill
                        if (instance_exists(obj_player)) {
                            var xp_reward = 5;
                            with (obj_player) {
                                gain_xp(xp_reward);
                            }
                            show_debug_message("Enemy burned to death! Player gained " + string(xp_reward) + " XP");
                        }
                    }
                }

                effect.tick_timer = 0;
            }
        }

        // Reduce duration
        effect.remaining_duration--;

        // Remove expired effects
        if (effect.remaining_duration <= 0) {
            array_delete(status_effects, i, 1);
        }
    }
}

function get_status_effect_modifier(_modifier_type) {
    var modifier = 1.0;

    for (var i = 0; i < array_length(status_effects); i++) {
        var effect = status_effects[i];

        switch(_modifier_type) {
            case "speed":
                if (variable_struct_exists(effect.data, "speed_modifier")) {
                    modifier *= effect.data.speed_modifier;
                }
                break;

            case "damage":
                if (variable_struct_exists(effect.data, "damage_modifier")) {
                    modifier *= effect.data.damage_modifier;
                }
                break;
        }
    }

    return modifier;
}

// ============================================
// UI HELPERS
// ============================================

function ui_draw_bar(_x, _y, _w, _h, _value, _value_max, _fill_color, _back_color, _border_color) {
    var _max_value = max(1, _value_max);
    var _pct = clamp(_value / _max_value, 0, 1);

    draw_set_color(_back_color);
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);

    draw_set_color(_fill_color);
    draw_rectangle(_x + 1, _y + 1, _x + 1 + (_w - 2) * _pct, _y + _h - 1, false);

    draw_set_color(_border_color);
    draw_rectangle(_x, _y, _x + _w, _y + _h, true);
}

function ui_draw_health_bar(_player, _x, _y, _w, _h, _animation_data = undefined) {
    // If no animation data provided, fall back to simple bar
    if (_animation_data == undefined) {
        ui_draw_bar(_x, _y, _w, _h, _player.hp, _player.hp_total, c_red, make_color_rgb(24, 16, 16), c_black);
        return;
    }

    var _current_hp = _player.hp;
    var _max_hp = _player.hp_total;

    // Initialize animation data if needed
    if (!variable_struct_exists(_animation_data, "previous_hp")) {
        _animation_data.previous_hp = _current_hp;
        _animation_data.displayed_previous_hp = _current_hp;
        _animation_data.damage_delay_timer = 0;
        _animation_data.damage_delay_duration = 30; // 0.5 seconds at 60fps
        _animation_data.animation_speed = 0.01; // How fast the grey bar slides down
    }

    // Check if player took damage
    if (_current_hp < _animation_data.previous_hp) {
        // Player took damage - reset the animation
        _animation_data.displayed_previous_hp = _animation_data.previous_hp;
        _animation_data.damage_delay_timer = _animation_data.damage_delay_duration;
    }

    // Update the damage delay timer
    if (_animation_data.damage_delay_timer > 0) {
        _animation_data.damage_delay_timer--;
    } else {
        // Animate the grey bar sliding down
        if (_animation_data.displayed_previous_hp > _current_hp) {
            _animation_data.displayed_previous_hp = max(_current_hp, _animation_data.displayed_previous_hp - (_max_hp * _animation_data.animation_speed));
        }
    }

    // Update previous_hp for next frame
    _animation_data.previous_hp = _current_hp;

    // Calculate widths
    var _current_percentage = _current_hp / _max_hp;
    var _current_width = _w * _current_percentage;

    var _previous_percentage = _animation_data.displayed_previous_hp / _max_hp;
    var _previous_width = _w * _previous_percentage;

    // Determine health bar color frame
    var _healthbar_frame = 0;
    if (_current_percentage < 0.33) { _healthbar_frame = 2; }
    else if (_current_percentage < 0.66) { _healthbar_frame = 1; }

    // Draw black background
    draw_sprite_stretched(spr_ui_healthbar_filler, 3, _x, _y, _w, _h);

    // Draw grey "previous health" bar (frame 4)
    draw_sprite_stretched(spr_ui_healthbar_filler, 4, _x, _y, _previous_width, _h);

    // Draw current health bar on top
    draw_sprite_stretched(spr_ui_healthbar_filler, _healthbar_frame, _x, _y, _current_width, _h);

    // Draw border
    draw_sprite(spr_ui_healthbar, 0, _x + 1, _y + 1);
}

function ui_draw_xp_bar(_player, _x, _y, _w, _h, _label_x = undefined, _label_y = undefined) {
    ui_draw_bar(_x, _y, _w, _h, _player.xp, _player.xp_to_next, c_aqua, make_color_rgb(12, 20, 32), c_black);

    draw_set_color(c_white);
    var _text_x = is_undefined(_label_x) ? _x + _w + 6 : _label_x;
    var _text_y = is_undefined(_label_y) ? _y - 2 : _label_y;
    draw_text(_text_x, _text_y, "Lv " + string(_player.level));
}

function ui_get_status_effect_color(_effect_type) {
    switch(_effect_type) {
        case StatusEffectType.burning: return c_red;
        case StatusEffectType.wet: return c_blue;
        case StatusEffectType.empowered: return c_yellow;
        case StatusEffectType.weakened: return c_gray;
        case StatusEffectType.swift: return c_green;
        case StatusEffectType.slowed: return c_purple;
        default: return c_white;
    }
}

function ui_draw_status_effects(_player, _x, _y, _icon_size, _spacing) {
    if (!variable_instance_exists(_player, "status_effects")) return;

    var _effects = _player.status_effects;
    if (array_length(_effects) == 0) return;

    for (var i = 0; i < array_length(_effects); i++) {
        var _effect = _effects[i];
        var _icon_x = _x + (i * (_icon_size + _spacing));
        var _icon_y = _y;
        var _icon_sprite = -1;

        if (is_struct(_effect.data) && variable_struct_exists(_effect.data, "icon_sprite")) {
            _icon_sprite = _effect.data.icon_sprite;
        }

        if (_icon_sprite != -1 && sprite_exists(_icon_sprite)) {
            draw_sprite(_icon_sprite, 0, _icon_x, _icon_y);
        } else {
            draw_set_color(ui_get_status_effect_color(_effect.type));
            draw_rectangle(_icon_x, _icon_y, _icon_x + _icon_size, _icon_y + _icon_size, false);
        }

        var _duration_pct = 0;
        if (is_struct(_effect) && variable_struct_exists(_effect, "remaining_duration") && variable_struct_exists(_effect.data, "duration")) {
            _duration_pct = clamp(_effect.remaining_duration / max(1, _effect.data.duration), 0, 1);
        }

        draw_set_color(c_black);
        draw_rectangle(_icon_x, _icon_y + _icon_size + 1, _icon_x + _icon_size, _icon_y + _icon_size + 3, false);
        draw_set_color(ui_get_status_effect_color(_effect.type));
        draw_rectangle(_icon_x, _icon_y + _icon_size + 1, _icon_x + (_icon_size * _duration_pct), _icon_y + _icon_size + 3, false);
    }

    draw_set_color(c_white);
}
