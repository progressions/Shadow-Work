/// @description Inherit parent initialization and configure chest loot

// Call parent create event to initialize all variables
event_inherited();

// Configure chest-specific loot (example configuration)
// You can customize this per chest instance in room creation code

// Example 1: Specific items mode (default)
loot_mode = "specific";
loot_items = ["health_potion", "short_sword"];

// Example 2: Random weighted loot (uncomment to test)
// loot_mode = "random_weighted";
// loot_count = 2;
// loot_table = [
//     {item_key: "health_potion", weight: 50},
//     {item_key: "rusty_dagger", weight: 30},
//     {item_key: "short_sword", weight: 15},
//     {item_key: "master_sword", weight: 5}
// ];

// Example 3: Variable quantity random loot (uncomment to test)
// loot_mode = "random_weighted";
// use_variable_quantity = true;
// loot_count_min = 1;
// loot_count_max = 3;
// loot_table = [
//     {item_key: "health_potion", weight: 40},
//     {item_key: "rusty_dagger", weight: 30},
//     {item_key: "leather_helmet", weight: 20},
//     {item_key: "axe", weight: 10}
// ];
