// === CREATE EVENT ===
is_open = false;
selected_slot = 0; // Current selected inventory slot (0-15)
grid_columns = 4;
grid_rows = 4;
health_bar_animation = {};

// Tab system
enum InventoryTab {
    loadout,
    paper_doll,
    inventory
}

current_tab = InventoryTab.inventory;

// Loadout tab selection
loadout_selected_hand = "left"; // "left" or "right"
loadout_selected_loadout = "melee"; // "melee" or "ranged"

// Paper doll tab selection
paper_doll_selected = "head"; // "head", "torso", or "legs"
