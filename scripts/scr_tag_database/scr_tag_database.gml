
// Initialize tag database (tags grant permanent trait bundles)
global.tag_database = {
    fireborne: {
        name: "Fireborne",
        description: "Born of flame",
        grants_traits: ["fire_immunity", "ice_vulnerability"]
    },

    venomous: {
        name: "Venomous",
        description: "Deadly poison wielder",
        grants_traits: ["poison_immunity", "deals_poison_damage"]
    },

    arboreal: {
        name: "Arboreal",
        description: "Tree-dwelling creature",
        grants_traits: ["fire_vulnerability", "poison_resistance"]
    },

    aquatic: {
        name: "Aquatic",
        description: "Water-born creature",
        grants_traits: ["lightning_vulnerability", "fire_resistance"]
    },

    glacial: {
        name: "Glacial",
        description: "From frozen lands",
        grants_traits: ["ice_immunity", "fire_vulnerability"]
    },

    swampridden: {
        name: "Swampridden",
        description: "Murky swamp dweller",
        grants_traits: ["poison_immunity", "disease_resistance"]
    },

    sandcrawler: {
        name: "Sandcrawler",
        description: "Desert wanderer",
        grants_traits: ["fire_resistance", "heat_adapted"]
    },
	undead: {
		name: "Undead",
		description: "Unholy living dead",
		grants_traits: ["fire_immunity", "poison_immunity", "holy_vulnerability"]
	},
	flying: {
		name: "Flying",
		description: "Airborne creature",
		grants_traits: ["ground_hazard_immunity"]
	}
};
