
// VN torch variables and identifiers
ChatterboxVariableDefault("torch_carrier", "none");
ChatterboxVariableDefault("vn_torch_transfer_success", false);
set_torch_carrier("none");
if (variable_global_exists("ChatterboxVariableSetConstant")) {
    ChatterboxVariableSetConstant("player_id", "player");
    ChatterboxVariableSetConstant("canopy_id", "canopy");
    ChatterboxVariableSetConstant("hola_id", "hola");
    ChatterboxVariableSetConstant("yorna_id", "yorna");
}

if (variable_global_exists("ChatterboxVariableSet")) {
    ChatterboxVariableSet("vn_torch_transfer_success", false);
}
global.vn_torch_transfer_success = false;

// Register custom Chatterbox functions
ChatterboxAddFunction("bg", background_set_index);
ChatterboxAddFunction("quest_accept", quest_accept);
ChatterboxAddFunction("quest_is_active", quest_is_active);
ChatterboxAddFunction("quest_is_complete", quest_is_complete);
ChatterboxAddFunction("quest_can_accept", quest_can_accept);
ChatterboxAddFunction("companion_take_torch", companion_take_torch_function);
ChatterboxAddFunction("companion_stop_carrying_torch", companion_stop_carrying_torch_function);

// Inventory functions for Chatterbox
ChatterboxAddFunction("has_item", function(_item_id, _quantity = 1) {
    if (!instance_exists(obj_player)) return false;
    if (_quantity <= 0) return true; // Asking for 0 or less is always true

    var _total_count = 0;
    for (var i = 0; i < array_length(obj_player.inventory); i++) {
        var _entry = obj_player.inventory[i];
        if (_entry != undefined && _entry.definition != undefined) {
            if (_entry.definition.item_id == _item_id) {
                _total_count += _entry.count;
                if (_total_count >= _quantity) return true;
            }
        }
    }
    return false;
});

ChatterboxAddFunction("inventory_count", function(_item_id) {
    if (!instance_exists(obj_player)) return 0;

    var _total_count = 0;
    for (var i = 0; i < array_length(obj_player.inventory); i++) {
        var _entry = obj_player.inventory[i];
        if (_entry != undefined && _entry.definition != undefined) {
            if (_entry.definition.item_id == _item_id) {
                _total_count += _entry.count;
            }
        }
    }
    return _total_count;
});

ChatterboxAddFunction("give_item", function(_item_id, _quantity = 1) {
    if (!instance_exists(obj_player)) return false;
    if (_quantity <= 0) return false;

    // Look up item definition from database
    if (!variable_struct_exists(global.item_database, _item_id)) {
        show_debug_message("Chatterbox give_item: Invalid item_id '" + string(_item_id) + "'");
        return false;
    }

    var _item_def = global.item_database[$ _item_id];
    if (_item_def == undefined) return false;

    // Use existing inventory system to add item
    with (obj_player) {
        return inventory_add_item(_item_def, _quantity);
    }
    return false;
});

ChatterboxAddFunction("remove_item", function(_item_id, _quantity = 1) {
    if (!instance_exists(obj_player)) return false;
    if (_quantity <= 0) return true; // Removing 0 or less is always successful

    // Use existing inventory_consume_item_id function
    with (obj_player) {
        return inventory_consume_item_id(_item_id, _quantity);
    }
    return false;
});

// Affinity functions for Chatterbox
ChatterboxAddFunction("get_affinity", function(_companion_name) {
    var _companion = get_companion_by_name(_companion_name);

    // Return 0 if companion not found or not recruited
    if (_companion == noone) return 0;
    if (!_companion.is_recruited) return 0;

    // Return the companion's affinity level
    return _companion.affinity;
});

// Quest progress functions for Chatterbox
ChatterboxAddFunction("objective_complete", quest_objective_complete);
ChatterboxAddFunction("quest_progress", quest_objective_progress);

// Declare Chatterbox variables for companions
ChatterboxVariableDefault("canopy_recruited", false);
ChatterboxVariableDefault("hola_recruited", false);
ChatterboxVariableDefault("yorna_recruited", false);
ChatterboxVariableDefault("hola_thanked_for_yorna", false);

// Companion availability for talk menu (tracks which companions can be talked to)
ChatterboxVariableDefault("canopy_available", false);
ChatterboxVariableDefault("hola_available", false);
ChatterboxVariableDefault("yorna_available", false);