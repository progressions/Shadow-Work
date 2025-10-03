/// obj_player : Step

if (global.game_paused) exit;

// Make pillars slightly behind player at same position
depth = -bbox_bottom;

show_debug_message("depth " + string(depth));

var _hor = 0;
var _ver = 0;

// Update elevation and offset
if (elevation_source != noone) {
    y_offset = elevation_source.y_offset;
    current_elevation = elevation_source.height;
} else {
    y_offset = 0;
    current_elevation = -1;
}

if (instance_exists(obj_grid_controller)) {
    GRID_Y_OFFSET = obj_grid_controller.GRID_Y_OFFSET;
}


#region Movement

// State machine for player movement
switch (state) {
    case PlayerState.idle:
        player_state_idle();
        break;

    case PlayerState.walking:
        player_state_walking();
        break;

    case PlayerState.dashing:
        player_state_dashing();
        break;

    case PlayerState.attacking:
        player_state_attacking();
        break;

    case PlayerState.on_grid:
        if (!obj_grid_controller.hop.active) {
            player_on_grid();
        }
        break;

    case PlayerState.dead:
        player_state_dead();
        break;

    default:
        // Fallback to idle for any unexpected state
        state = PlayerState.idle;
        break;
}


#endregion Movement

// Tick status effects (runs even when dead)
tick_status_effects();

tilemap = layer_tilemap_get_id("Tiles_Col");

// Don't run other systems when dead
if (state != PlayerState.dead) {
    // ============================================
    // PLAYER STEP EVENT - PICKUP CODE
    // ============================================

    #region Pickup items
    player_handle_pickup();
    #endregion


    #region Animation
    player_handle_animation();
    #endregion Animation

    #region Attack System

    // Handle attack input and cooldown (applies to all states)
    player_handle_attack_input();

    // Handle dash cooldown
    player_handle_dash_cooldown();

    if (keyboard_check_pressed(ord("Q"))) {
        var _swap_method = method(self, swap_active_loadout);
        if (_swap_method != undefined && _swap_method()) {
            var _active_key_fn = method(self, loadouts_get_active_key);
            if (_active_key_fn != undefined) {
                var _active_key = _active_key_fn();
                show_debug_message("[Q] Swapped active loadout to " + string(_active_key));
            }
        }
    }

    #endregion Attack System

    #region Companion System
/*
    // Check for nearby recruitable companions
    var _nearest_companion = instance_nearest(x, y, obj_companion_parent);
    if (_nearest_companion != noone &&
        !_nearest_companion.is_recruited &&
        point_distance(x, y, _nearest_companion.x, _nearest_companion.y) < 32) {

        // Show recruitment prompt (Space key)
        if (keyboard_check_pressed(vk_space)) {
            recruit_companion(_nearest_companion, self);
            show_debug_message("Recruited " + _nearest_companion.companion_name);
        }
    }
*/
    // Apply companion regeneration auras
    apply_companion_regeneration_auras(self);

    // Evaluate and activate companion triggers
    evaluate_companion_triggers(self);

    #endregion Companion System
}

// Debug keys for testing status effects (remove in final version)
if (keyboard_check_pressed(ord("1"))) {
    apply_status_effect(StatusEffectType.burning);
    show_debug_message("Applied burning effect");
}
if (keyboard_check_pressed(ord("2"))) {
    apply_status_effect(StatusEffectType.wet);
    show_debug_message("Applied wet effect");
}
if (keyboard_check_pressed(ord("3"))) {
    apply_status_effect(StatusEffectType.empowered);
    show_debug_message("Applied empowered effect");
}
if (keyboard_check_pressed(ord("4"))) {
    apply_status_effect(StatusEffectType.weakened);
    show_debug_message("Applied weakened effect");
}
if (keyboard_check_pressed(ord("5"))) {
    apply_status_effect(StatusEffectType.swift);
    show_debug_message("Applied swift effect");
}
if (keyboard_check_pressed(ord("6"))) {
    apply_status_effect(StatusEffectType.slowed);
    show_debug_message("Applied slowed effect");
}

// Apply status effects to nearest enemy
if (keyboard_check_pressed(ord("7"))) {
    var nearest_enemy = instance_nearest(x, y, obj_enemy_parent);
    if (nearest_enemy != noone && point_distance(x, y, nearest_enemy.x, nearest_enemy.y) < 50) {
        with (nearest_enemy) {
            apply_status_effect(StatusEffectType.burning);
        }
        show_debug_message("Applied burning to enemy");
    }
}

// Debug key for testing XP gain
if (keyboard_check_pressed(ord("8"))) {
    gain_xp(10);
    show_debug_message("Gained 10 XP via debug key");
}

// Debug key for adding arrows
if (keyboard_check_pressed(ord("9"))) {
    inventory_add_item(global.item_database.arrows, 10);
    show_debug_message("Added 10 arrows to inventory");
}

// Debug keys for testing trait system v2.0
if (keyboard_check_pressed(ord("T"))) {
    // Add fire_resistance trait (3 stacks)
    add_temporary_trait("fire_resistance", 3);
    show_debug_message("Added 3 stacks of fire_resistance to player");
}

if (keyboard_check_pressed(ord("Y"))) {
    // Add fire_vulnerability trait (2 stacks)
    add_temporary_trait("fire_vulnerability", 2);
    show_debug_message("Added 2 stacks of fire_vulnerability to player (should cancel 2 resistance stacks)");
}

if (keyboard_check_pressed(ord("U"))) {
    // Clear all temporary traits
    temporary_traits = {};
    show_debug_message("Cleared all temporary traits from player");
}

if (keyboard_check_pressed(ord("I"))) {
    // Add fireborne tag (grants fire immunity)
    if (!array_contains(tags, "fireborne")) {
        array_push(tags, "fireborne");
        apply_tag_traits();
        show_debug_message("Added fireborne tag to player (grants fire_immunity)");
    }
}

if (keyboard_check_pressed(ord("O"))) {
    show_debug_message("=== PLAYER TRAIT STATUS ===");
    show_debug_message("Tags: " + json_stringify(tags));
    show_debug_message("Permanent Traits: " + json_stringify(permanent_traits));
    show_debug_message("Temporary Traits: " + json_stringify(temporary_traits));
    show_debug_message("Fire Resistance Stacks: " + string(get_total_trait_stacks("fire_resistance")));
    show_debug_message("Fire Vulnerability Stacks: " + string(get_total_trait_stacks("fire_vulnerability")));
    show_debug_message("Fire Damage Modifier: " + string(get_damage_modifier_for_type(DamageType.fire)));

    // Show nearest enemy traits too
    var nearest_enemy = instance_nearest(x, y, obj_enemy_parent);
    if (nearest_enemy != noone && point_distance(x, y, nearest_enemy.x, nearest_enemy.y) < 200) {
        with (nearest_enemy) {
            show_debug_message("=== NEAREST ENEMY TRAIT STATUS ===");
            show_debug_message("Tags: " + json_stringify(tags));
            show_debug_message("Permanent Traits: " + json_stringify(permanent_traits));
            show_debug_message("Temporary Traits: " + json_stringify(temporary_traits));
        }
    }
}

// Debug key for terrain/tile detection
if (keyboard_check_pressed(ord("P"))) {
    show_debug_message("=== TILE DEBUG ===");
    show_debug_message("Position: (" + string(x) + ", " + string(y) + ")");

    // Check Tiles_Forest layer
    var _forest_layer = layer_get_id("Tiles_Forest");
    if (_forest_layer != -1) {
        var _tilemap_forest = layer_tilemap_get_id(_forest_layer);
        if (_tilemap_forest != -1) {
            var _tile_data = tilemap_get_at_pixel(_tilemap_forest, x, y);
            var _tile_index = tile_get_index(_tile_data);
            show_debug_message("Tiles_Forest index: " + string(_tile_index));
        }
    }

    // Check Tiles_Path layer
    var _path_layer = layer_get_id("Tiles_Path");
    if (_path_layer != -1) {
        var _tilemap_path = layer_tilemap_get_id(_path_layer);
        if (_tilemap_path != -1) {
            var _path_tile = tilemap_get_at_pixel(_tilemap_path, x, y);
            var _path_index = tile_get_index(_path_tile);
            show_debug_message("Tiles_Path index: " + string(_path_index) + " (0=no path)");
        }
    }

    // Check Tiles_Water layer
    var _water_layer = layer_get_id("Tiles_Water");
    if (_water_layer != -1) {
        var _tilemap_water = layer_tilemap_get_id(_water_layer);
        if (_tilemap_water != -1) {
            var _water_tile = tilemap_get_at_pixel(_tilemap_water, x, y);
            var _water_index = tile_get_index(_water_tile);
            show_debug_message("Tiles_Water index: " + string(_water_index) + " (0=no water)");
        }
    }

    // Check Tiles_Water_Moving layer
    var _water_moving_layer = layer_get_id("Tiles_Water_Moving");
    if (_water_moving_layer != -1) {
        var _tilemap_water_moving = layer_tilemap_get_id(_water_moving_layer);
        if (_tilemap_water_moving != -1) {
            var _water_moving_tile = tilemap_get_at_pixel(_tilemap_water_moving, x, y);
            var _water_moving_index = tile_get_index(_water_moving_tile);
            show_debug_message("Tiles_Water_Moving index: " + string(_water_moving_index));
        }
    }

    show_debug_message("==================");

    // Show current terrain type
    var _current_terrain = get_terrain_at_position(x, y);
    show_debug_message(">>> Current terrain: " + _current_terrain);
}

// ============================================
// DEBUG SAVE/LOAD KEYS
// ============================================

// F5 - Save to slot 1
if (keyboard_check_pressed(vk_f5)) {
    save_game(1);
    show_debug_message("=== MANUAL SAVE TO SLOT 1 ===");
}

// F9 - Load from slot 1
if (keyboard_check_pressed(vk_f9)) {
    load_game(1);
    show_debug_message("=== MANUAL LOAD FROM SLOT 1 ===");
}

// F6 - Save to slot 2
if (keyboard_check_pressed(vk_f6)) {
    save_game(2);
    show_debug_message("=== MANUAL SAVE TO SLOT 2 ===");
}

// F10 - Load from slot 2
if (keyboard_check_pressed(vk_f10)) {
    load_game(2);
    show_debug_message("=== MANUAL LOAD FROM SLOT 2 ===");
}

// F8 - Load from autosave
if (keyboard_check_pressed(vk_f8)) {
    load_game("autosave");
    show_debug_message("=== LOAD FROM AUTOSAVE ===");
}

// F9 - Debug: Add test items to inventory
if (keyboard_check_pressed(vk_f9)) {
    show_debug_message("=== ADDING TEST ITEMS TO INVENTORY ===");

    // Clear inventory first
    inventory = [];

    // Add variety of items to test scaling
    inventory_add_item(global.item_database.short_sword, 1);      // Normal weapon (2x)
    inventory_add_item(global.item_database.greatsword, 1);       // Large weapon (1x)
    inventory_add_item(global.item_database.health_potion, 5);    // Stackable (2x, count: 5)
    inventory_add_item(global.item_database.leather_helmet, 1);   // Armor (2x)
    inventory_add_item(global.item_database.shield, 1);           // Shield (2x)
    inventory_add_item(global.item_database.longbow, 1);          // Large weapon (1x)
    inventory_add_item(global.item_database.crossbow, 1);         // Large weapon (1x)
    inventory_add_item(global.item_database.chain_armor, 1);      // Armor (2x)
    inventory_add_item(global.item_database.water, 3);            // Stackable (2x, count: 3)

    show_debug_message("Added " + string(array_length(inventory)) + " test items to inventory");
}
