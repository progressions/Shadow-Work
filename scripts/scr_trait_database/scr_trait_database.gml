
// Initialize trait database (individual traits with stacking mechanics)
global.trait_database = {
    // Fire traits
    fire_immunity: {
        name: "Fire Immunity",
        damage_modifier: 0.0,
        opposite_trait: "fire_vulnerability",
        max_stacks: 5
    },
    fire_resistance: {
        name: "Fire Resistance",
        damage_modifier: 0.75,
        opposite_trait: "fire_vulnerability",
        max_stacks: 5
    },
    fire_vulnerability: {
        name: "Fire Vulnerability",
        damage_modifier: 1.5,
        opposite_trait: "fire_resistance",
        max_stacks: 5
    },

    // Ice traits
    ice_immunity: {
        name: "Ice Immunity",
        damage_modifier: 0.0,
        opposite_trait: "ice_vulnerability",
        max_stacks: 5
    },
    ice_resistance: {
        name: "Ice Resistance",
        damage_modifier: 0.75,
        opposite_trait: "ice_vulnerability",
        max_stacks: 5
    },
    ice_vulnerability: {
        name: "Ice Vulnerability",
        damage_modifier: 1.5,
        opposite_trait: "ice_resistance",
        max_stacks: 5
    },

    // Lightning traits
    lightning_immunity: {
        name: "Lightning Immunity",
        damage_modifier: 0.0,
        opposite_trait: "lightning_vulnerability",
        max_stacks: 5
    },
    lightning_resistance: {
        name: "Lightning Resistance",
        damage_modifier: 0.75,
        opposite_trait: "lightning_vulnerability",
        max_stacks: 5
    },
    lightning_vulnerability: {
        name: "Lightning Vulnerability",
        damage_modifier: 1.5,
        opposite_trait: "lightning_resistance",
        max_stacks: 5
    },

    // Poison traits
    poison_immunity: {
        name: "Poison Immunity",
        damage_modifier: 0.0,
        opposite_trait: "poison_vulnerability",
        max_stacks: 5
    },
    poison_resistance: {
        name: "Poison Resistance",
        damage_modifier: 0.75,
        opposite_trait: "poison_vulnerability",
        max_stacks: 5
    },
    poison_vulnerability: {
        name: "Poison Vulnerability",
        damage_modifier: 1.5,
        opposite_trait: "poison_resistance",
        max_stacks: 5
    },

    // Unholy traits
    unholy_immunity: {
        name: "Unholy Immunity",
        damage_modifier: 0.0,
        opposite_trait: "unholy_vulnerability",
        max_stacks: 5
    },
    unholy_resistance: {
        name: "Unholy Resistance",
        damage_modifier: 0.75,
        opposite_trait: "unholy_vulnerability",
        max_stacks: 5
    },
    unholy_vulnerability: {
        name: "Unholy Vulnerability",
        damage_modifier: 1.5,
        opposite_trait: "unholy_resistance",
        max_stacks: 5
    },

    // Disease traits
    disease_immunity: {
        name: "Disease Immunity",
        damage_modifier: 0.0,
        opposite_trait: "disease_vulnerability",
        max_stacks: 5
    },
    disease_resistance: {
        name: "Disease Resistance",
        damage_modifier: 0.75,
        opposite_trait: "disease_vulnerability",
        max_stacks: 5
    },

    // Bleeding traits (physical damage resistance)
    bleeding_immunity: {
        name: "Bleeding Immunity",
        description: "Complete immunity to bleeding effects",
        damage_modifier: 0.0,
        max_stacks: 5
    },

    // Special traits
    deals_poison_damage: {
        name: "Deals Poison Damage",
        effect_type: "damage_type_change",
        max_stacks: 1
    },
    heat_adapted: {
        name: "Heat Adapted",
        effect_type: "environmental",
        max_stacks: 1
    },

    // Status traits (timed effects)
    burning: {
        name: "Burning",
        default_duration: 3,
        tick_damage: 1,
        tick_rate_seconds: 0.5,
        damage_type: DamageType.fire,
        opposite_trait: "wet",
        max_stacks: 5,
        ui_color: c_red,
        show_feedback: true,
        blocked_by: ["fire_immunity"]
    },
    wet: {
        name: "Wet",
        default_duration: 5,
        modifiers: {speed: 0.9},
        opposite_trait: "burning",
        max_stacks: 5,
        ui_color: c_blue,
        show_feedback: true
    },
    empowered: {
        name: "Empowered",
        default_duration: 10,
        modifiers: {damage: 1.5},
        opposite_trait: "weakened",
        max_stacks: 5,
        ui_color: c_yellow,
        show_feedback: true
    },
    weakened: {
        name: "Weakened",
        default_duration: 10,
        modifiers: {damage: 0.7},
        opposite_trait: "empowered",
        max_stacks: 5,
        ui_color: c_gray,
        show_feedback: true
    },
    swift: {
        name: "Swift",
        default_duration: 8,
        modifiers: {speed: 1.3},
        opposite_trait: "slowed",
        max_stacks: 5,
        ui_color: c_green,
        show_feedback: true
    },
    slowed: {
        name: "Slowed",
        default_duration: 5,
        modifiers: {speed: 0.6},
        opposite_trait: "swift",
        max_stacks: 5,
        ui_color: c_purple,
        show_feedback: true
    },
    poisoned: {
        name: "Poisoned",
        default_duration: 3,
        tick_damage: 1,
        tick_rate_seconds: 0.5,
        damage_type: DamageType.poison,
        max_stacks: 5,
        ui_color: make_color_rgb(0, 255, 0),
        show_feedback: true,
        blocked_by: ["poison_immunity"]
    },
    cursed: {
        name: "Cursed",
        default_duration: 3,
        tick_damage: 1,
        tick_rate_seconds: 0.75,
        damage_type: DamageType.unholy,
        max_stacks: 5,
        ui_color: make_color_rgb(128, 0, 128),
        show_feedback: true,
        blocked_by: [],
		opposite_trait: "blessed"
    },
    blessed: {
        name: "Blessed",
        default_duration: 3,
        tick_damage: -1,
        tick_rate_seconds: 0.75,
        damage_type: DamageType.unholy,
        max_stacks: 5,
        ui_color: make_color_rgb(173, 216, 230), // Light blue
        show_feedback: true,
        blocked_by: [],
		opposite_trait: "cursed"
    },
    diseased: {
        name: "Diseased",
        default_duration: 5,
        tick_damage: 1,
        tick_rate_seconds: 1.0,
        damage_type: DamageType.disease,
        max_stacks: 5,
        ui_color: make_color_rgb(139, 69, 19), // Brown
        show_feedback: true,
        blocked_by: ["disease_immunity"]
    },
    bleeding: {
        name: "Bleeding",
        default_duration: 4,
        tick_damage: 1,
        tick_rate_seconds: 0.5,
        damage_type: DamageType.physical,
        max_stacks: 5,
        ui_color: make_color_rgb(139, 0, 0), // Dark red
        show_feedback: true,
        blocked_by: ["bleeding_immunity"]
    },
    // Defense traits (affect damage reduction, not damage type)
    defense_resistance: {
        name: "Bolstered Defense",
        description: "Increases damage reduction",
        defense_modifier: 1.33, // +33% damage reduction per stack
        opposite_trait: "defense_vulnerability",
        max_stacks: 5
    },
    defense_vulnerability: {
        name: "Sundered Defense",
        description: "Decreases damage reduction",
        defense_modifier: 0.75, // -25% damage reduction per stack
        opposite_trait: "defense_resistance",
        max_stacks: 5
    },

    // Crowd control status effects
    stunned: {
        name: "Stunned!",
        default_duration: 1.5,
        max_stacks: 1,
        ui_color: c_yellow,
        show_feedback: true,
        blocked_by: ["stun_immunity"]
    },
    staggered: {
        name: "Staggered!",
        default_duration: 1.0,
        max_stacks: 1,
        ui_color: make_color_rgb(160, 32, 240), // Purple
        show_feedback: true,
        blocked_by: ["stagger_immunity"]
    },

    // Crowd control resistance traits
    stun_immunity: {
        name: "Stun Immunity",
        description: "Complete immunity to stun effects",
        damage_modifier: 0.0, // Treated as immunity
        opposite_trait: "stun_vulnerability",
        max_stacks: 5
    },
    stun_resistance: {
        name: "Stun Resistance",
        description: "Reduces stun chance and duration",
        damage_modifier: 0.75, // 25% reduction per stack
        opposite_trait: "stun_vulnerability",
        max_stacks: 5
    },
    stun_vulnerability: {
        name: "Stun Vulnerability",
        description: "Increases stun chance and duration",
        damage_modifier: 1.5, // 50% increase per stack
        opposite_trait: "stun_resistance",
        max_stacks: 5
    },

    stagger_immunity: {
        name: "Stagger Immunity",
        description: "Complete immunity to stagger effects",
        damage_modifier: 0.0, // Treated as immunity
        opposite_trait: "stagger_vulnerability",
        max_stacks: 5
    },
    stagger_resistance: {
        name: "Stagger Resistance",
        description: "Reduces stagger chance and duration",
        damage_modifier: 0.75, // 25% reduction per stack
        opposite_trait: "stagger_vulnerability",
        max_stacks: 5
    },
    stagger_vulnerability: {
        name: "Stagger Vulnerability",
        description: "Increases stagger chance and duration",
        damage_modifier: 1.5, // 50% increase per stack
        opposite_trait: "stagger_resistance",
        max_stacks: 5
    }
};
