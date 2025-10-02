// ============================================
// ITEM DATABASE - Item definitions and spawning
// ============================================

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

    // Extract large_sprite from stats (not a stat, but a rendering property)
    large_sprite = _stats[$ "large_sprite"] ?? false;

    // Sprite key for equipped version (used for save/load compatibility)
    equipped_sprite_key = _stats[$ "equipped_key"] ?? string_lower(string_replace(_name, " ", "_"));
}

// Create the global item database
global.item_database = {
    // Row 1 - Bladed weapons (frames 0-5)
    rusty_dagger: new create_item_definition(
        0, "rusty_dagger", "Rusty Dagger", ItemType.weapon, EquipSlot.either_hand,
        {damage: 2, attack_speed: 1.5, range: 30, handedness: WeaponHandedness.one_handed, damage_type: DamageType.physical}
    ),
    short_sword: new create_item_definition(
        1, "short_sword", "Short Sword", ItemType.weapon, EquipSlot.either_hand,
        {damage: 3, attack_speed: 1.2, range: 38, handedness: WeaponHandedness.one_handed, damage_type: DamageType.physical}
    ),
    long_sword: new create_item_definition(
        2, "long_sword", "Long Sword", ItemType.weapon, EquipSlot.either_hand,
        {damage: 4, attack_speed: 1.0, range: 46, handedness: WeaponHandedness.versatile, two_handed_damage: 5, two_handed_range: 40, damage_type: DamageType.physical}
    ),
    master_sword: new create_item_definition(
        3, "master_sword", "Master Sword", ItemType.weapon, EquipSlot.either_hand,
        {damage: 6, attack_speed: 1.1, range: 48, handedness: WeaponHandedness.versatile, two_handed_damage: 7, two_handed_range: 42, magic_power: 5, wielder_effects: [{effect: StatusEffectType.empowered}], damage_type: DamageType.holy}
    ),
    greatsword: new create_item_definition(
        4, "greatsword", "Greatsword", ItemType.weapon, EquipSlot.right_hand,
        {damage: 8, attack_speed: 0.7, range: 55, handedness: WeaponHandedness.two_handed, large_sprite: true, damage_type: DamageType.physical}
    ),
    spear: new create_item_definition(
        5, "spear", "Spear", ItemType.weapon, EquipSlot.right_hand,
        {damage: 4, attack_speed: 1.1, range: 60, handedness: WeaponHandedness.versatile, two_handed_damage: 5, two_handed_range: 55, damage_type: DamageType.physical}
    ),

    // Row 2 - Axe and bows (frames 6-11)
    axe: new create_item_definition(
        6, "axe", "Axe", ItemType.weapon, EquipSlot.either_hand,
        {damage: 5, attack_speed: 0.8, range: 30, handedness: WeaponHandedness.versatile, two_handed_damage: 6, damage_type: DamageType.physical}
    ),
    wooden_bow: new create_item_definition(
        7, "wooden_bow", "Wooden Bow", ItemType.weapon, EquipSlot.right_hand,
        {damage: 2, attack_speed: 1.2, range: 120, handedness: WeaponHandedness.two_handed, requires_ammo: "arrows", large_sprite: true, damage_type: DamageType.physical}
    ),
    longbow: new create_item_definition(
        8, "longbow", "Longbow", ItemType.weapon, EquipSlot.right_hand,
        {damage: 5, attack_speed: 1.0, range: 150, handedness: WeaponHandedness.two_handed, requires_ammo: "arrows", large_sprite: true, damage_type: DamageType.physical}
    ),
    crossbow: new create_item_definition(
        9, "crossbow", "Crossbow", ItemType.weapon, EquipSlot.right_hand,
        {damage: 3, attack_speed: 0.6, range: 140, handedness: WeaponHandedness.two_handed, requires_ammo: "arrows", large_sprite: true, damage_type: DamageType.physical}
    ),
    heavy_crossbow: new create_item_definition(
        10, "heavy_crossbow", "Heavy Crossbow", ItemType.weapon, EquipSlot.right_hand,
        {damage: 6, attack_speed: 0.4, range: 160, armor_penetration: 0.3, handedness: WeaponHandedness.two_handed, requires_ammo: "arrows", large_sprite: true, damage_type: DamageType.physical}
    ),
    torch: new create_item_definition(
        11, "torch", "Torch", ItemType.tool, EquipSlot.left_hand,
        {light_radius: 100, handedness: WeaponHandedness.one_handed, status_effects: [{effect: StatusEffectType.burning, chance: 0.2}], damage_type: DamageType.fire}
    ),

    // Row 3 - Chain armor set (frames 12-14) and Leather armor set (frames 15-17)
    chain_coif: new create_item_definition(
        12, "chain_coif", "Chain Coif", ItemType.armor, EquipSlot.helmet,
        {defense: 4}
    ),
    chain_armor: new create_item_definition(
        13, "chain_armor", "Chain Armor", ItemType.armor, EquipSlot.armor,
        {defense: 10, speed_modifier: 0.9, trait_grants: [{trait: "lightning_resistance", stacks: 1}]}
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
        {defense: 5, trait_grants: [{trait: "poison_resistance", stacks: 2}]}
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
        {defense: 10, block_chance: 0.35, speed_modifier: 0.85, trait_grants: [{trait: "physical_resistance", stacks: 1}]}
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
        {defense: 15, speed_modifier: 0.8, trait_grants: [{trait: "fire_resistance", stacks: 2}]}
    ),
    plate_sabatons: new create_item_definition(
        27, "plate_sabatons", "Plate Sabatons", ItemType.armor, EquipSlot.boots,
        {defense: 4, speed_modifier: 0.9, trait_grants: [{trait: "ice_resistance", stacks: 1}]}
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
