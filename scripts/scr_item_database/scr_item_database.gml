// ============================================
// ITEM DATABASE - Item definitions and spawning
// ============================================

// Item ID constants - Use Items.torch instead of "torch" strings
global.Items = {
    // Weapons
    rusty_dagger: "rusty_dagger",
    short_sword: "short_sword",
    long_sword: "long_sword",
    master_sword: "master_sword",
    greatsword: "greatsword",
    spear: "spear",
    axe: "axe",
    wooden_bow: "wooden_bow",
    longbow: "longbow",
    crossbow: "crossbow",
    heavy_crossbow: "heavy_crossbow",

    // Tools
    torch: "torch",

    // Armor - Chain
    chain_coif: "chain_coif",
    chain_armor: "chain_armor",
    chain_leggings: "chain_leggings",

    // Armor - Leather
    leather_helmet: "leather_helmet",
    leather_armor: "leather_armor",
    leather_greaves: "leather_greaves",

    // Armor - Plate
    plate_helmet: "plate_helmet",
    plate_armor: "plate_armor",
    plate_sabatons: "plate_sabatons",

    // Shields
    shield: "shield",
    greatshield: "greatshield",

    // Consumables
    small_health_potion: "small_health_potion",
    medium_health_potion: "medium_health_potion",
    large_health_potion: "large_health_potion",
    water: "water",
    purple_potion: "purple_potion",
    red_potion: "red_potion",

    // Ammo
    arrows: "arrows",

    // Quest Items
    mysterious_letter: "mysterious_letter",
    ancient_artifact: "ancient_artifact",
    wolf_pelt: "wolf_pelt",
};

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
        {damage: 2, attack_speed: 1.8, range: 30, handedness: WeaponHandedness.one_handed, damage_type: DamageType.physical, knockback_force: 2}
    ),
    short_sword: new create_item_definition(
        1, "short_sword", "Short Sword", ItemType.weapon, EquipSlot.either_hand,
        {damage: 3, attack_speed: 1.6, range: 38, handedness: WeaponHandedness.one_handed, damage_type: DamageType.physical, knockback_force: 3}
    ),
    long_sword: new create_item_definition(
        2, "long_sword", "Long Sword", ItemType.weapon, EquipSlot.either_hand,
        {damage: 4, attack_speed: 1.4, range: 46, handedness: WeaponHandedness.versatile, two_handed_damage: 5, two_handed_range: 40, damage_type: DamageType.physical, knockback_force: 4}
    ),
    master_sword: new create_item_definition(
        3, "master_sword", "Master Sword", ItemType.weapon, EquipSlot.either_hand,
        {damage: 6, attack_speed: 1.5, range: 48, handedness: WeaponHandedness.versatile, two_handed_damage: 7, two_handed_range: 42, magic_power: 5, wielder_effects: [{trait: "empowered"}], damage_type: DamageType.holy, knockback_force: 6}
    ),
    greatsword: new create_item_definition(
        4, "greatsword", "Greatsword", ItemType.weapon, EquipSlot.right_hand,
        {damage: 8, attack_speed: 0.9, range: 55, handedness: WeaponHandedness.two_handed, large_sprite: true, damage_type: DamageType.physical, knockback_force: 7}
    ),
    spear: new create_item_definition(
        5, "spear", "Spear", ItemType.weapon, EquipSlot.right_hand,
        {damage: 4, attack_speed: 1.1, range: 60, handedness: WeaponHandedness.versatile, two_handed_damage: 5, two_handed_range: 55, damage_type: DamageType.physical, knockback_force: 6}
    ),

    // Row 2 - Axe and bows (frames 6-11)
    axe: new create_item_definition(
        6, "axe", "Axe", ItemType.weapon, EquipSlot.either_hand,
        {damage: 5, attack_speed: 0.8, range: 30, handedness: WeaponHandedness.versatile, two_handed_damage: 6, damage_type: DamageType.physical, knockback_force: 6}
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
        {damage: 3, attack_speed: 0.6, range: 140, handedness: WeaponHandedness.one_handed, requires_ammo: "arrows", large_sprite: true, damage_type: DamageType.physical}
    ),
    heavy_crossbow: new create_item_definition(
        10, "heavy_crossbow", "Heavy Crossbow", ItemType.weapon, EquipSlot.right_hand,
        {damage: 6, attack_speed: 0.4, range: 160, armor_penetration: 0.3, handedness: WeaponHandedness.two_handed, requires_ammo: "arrows", large_sprite: true, damage_type: DamageType.physical}
    ),
    torch: new create_item_definition(
        11, "torch", "Torch", ItemType.tool, EquipSlot.left_hand,
        {
            light_radius: 125,
            handedness: WeaponHandedness.one_handed,
            status_effects: [{trait: "burning", chance: 0.2}],
            damage_type: DamageType.fire,
            stack_size: 99,
            burn_time_seconds: 60,
            knockback_force: 3
        }
    ),

    // Row 3 - Chain armor set (frames 12-14) and Leather armor set (frames 15-17)
    chain_coif: new create_item_definition(
        12, "chain_coif", "Chain Coif", ItemType.armor, EquipSlot.helmet,
        {damage_reduction: 4}
    ),
    chain_armor: new create_item_definition(
        13, "chain_armor", "Chain Armor", ItemType.armor, EquipSlot.armor,
        {damage_reduction: 10, speed_modifier: 0.9, trait_grants: [{trait: "lightning_resistance", stacks: 1}]}
    ),
    chain_leggings: new create_item_definition(
        14, "chain_leggings", "Chain Leggings", ItemType.armor, EquipSlot.boots,
        {damage_reduction: 3, speed_modifier: 0.95}
    ),
    leather_helmet: new create_item_definition(
        15, "leather_helmet", "Leather Helmet", ItemType.armor, EquipSlot.helmet,
        {damage_reduction: 2}
    ),
    leather_armor: new create_item_definition(
        16, "leather_armor", "Leather Armor", ItemType.armor, EquipSlot.armor,
        {damage_reduction: 5, trait_grants: [{trait: "poison_resistance", stacks: 2}]}
    ),
    leather_greaves: new create_item_definition(
        17, "leather_greaves", "Leather Greaves", ItemType.armor, EquipSlot.boots,
        {damage_reduction: 2, speed_modifier: 1.05}
    ),

    // Row 4 - Shields and consumables (frames 18-23)
    shield: new create_item_definition(
        18, "shield", "Shield", ItemType.armor, EquipSlot.left_hand,
        {melee_damage_reduction: 3, ranged_damage_reduction: 8}
    ),
    greatshield: new create_item_definition(
        19, "greatshield", "Greatshield", ItemType.armor, EquipSlot.left_hand,
        {melee_damage_reduction: 100, ranged_damage_reduction: 200, speed_modifier: 0.85, trait_grants: [{trait: "physical_resistance", stacks: 1}]}
    ),
    small_health_potion: new create_item_definition(
        20, "small_health_potion", "Small Health Potion", ItemType.consumable, EquipSlot.none,
        {heal_amount: 5, stack_size: 3}
    ),
    medium_health_potion: new create_item_definition(
        20, "medium_health_potion", "Medium Health Potion", ItemType.consumable, EquipSlot.none,
        {heal_amount: 10, stack_size: 3}
    ),
    large_health_potion: new create_item_definition(
        20, "large_health_potion", "Large Health Potion", ItemType.consumable, EquipSlot.none,
        {heal_amount: 15, stack_size: 3}
    ),
    water: new create_item_definition(
        21, "water", "Water", ItemType.consumable, EquipSlot.none,
        {stack_size: 3}
    ),
    purple_potion: new create_item_definition(
        22, "purple_potion", "Purple Potion", ItemType.consumable, EquipSlot.none,
        {manstack_size: 3}
    ),
    red_potion: new create_item_definition(
        23, "red_potion", "Red Potion", ItemType.consumable, EquipSlot.none,
        { stack_size: 3}  // Strength/damage boost potion
    ),

    // Additional item (frame 24)
    arrows: new create_item_definition(
        24, "arrows", "Arrows", ItemType.ammo, EquipSlot.none,
        {stack_size: 99, is_ammo: true}
    ),

    // Plate armor set (frames 25-27) - Heavy tier
    plate_helmet: new create_item_definition(
        25, "plate_helmet", "Plate Helmet", ItemType.armor, EquipSlot.helmet,
        {damage_reduction: 6, speed_modifier: 0.9}
    ),
    plate_armor: new create_item_definition(
        26, "plate_armor", "Plate Armor", ItemType.armor, EquipSlot.armor,
		{damage_reduction: 15, speed_modifier: 0.8, trait_grants: []}
        //{damage_reduction: 15, speed_modifier: 0.8, trait_grants: [{trait: "fire_resistance", stacks: 2}]}
    ),
    plate_sabatons: new create_item_definition(
        27, "plate_sabatons", "Plate Sabatons", ItemType.armor, EquipSlot.boots,
        {damage_reduction: 4, speed_modifier: 0.9, trait_grants: [{trait: "ice_resistance", stacks: 1}]}
    ),

    // Quest Items (frames 28-30) - Special items for quests
    mysterious_letter: new create_item_definition(
        28, "mysterious_letter", "Mysterious Letter", ItemType.quest_item, EquipSlot.none,
        {quest_id: "example_quest", stack_size: 1}
    ),
    ancient_artifact: new create_item_definition(
        29, "ancient_artifact", "Ancient Artifact", ItemType.quest_item, EquipSlot.none,
        {quest_id: "example_quest", stack_size: 1}
    ),
    wolf_pelt: new create_item_definition(
        30, "wolf_pelt", "Wolf Pelt", ItemType.quest_item, EquipSlot.none,
        {quest_id: "example_collect_quest", stack_size: 5}
    )
};

// Helper function to spawn items in the world with count support
function spawn_item(_x, _y, _item_key, _count = 1) {
    var _pickup_object = asset_get_index("obj_item_pickup");
    if (_pickup_object == -1) {
        _pickup_object = obj_item_parent;
    }

    var _target_layer = "Instances";
    if (!layer_exists(_target_layer)) {
        _target_layer = layer_get_name(layer_get_id(0));
    }

    var _item = instance_create_layer(_x, _y, _target_layer, _pickup_object);
    _item.item_def = global.item_database[$ _item_key];
    _item.sprite_index = spr_items;  // Your items sprite
    _item.image_index = _item.item_def.world_sprite_frame;
    _item.image_speed = 0;

    // For stackable items like arrows
    _item.count = _count;

    return _item;
}
