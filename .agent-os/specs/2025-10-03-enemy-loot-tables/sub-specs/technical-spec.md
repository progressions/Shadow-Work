# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-03-enemy-loot-tables/spec.md

## Technical Requirements

### Loot Table Structure

Each enemy will have a `loot_table` property defined as an array of structs:

```gml
loot_table = [
    {item_key: "small_health_potion", weight: 5},
    {item_key: "rusty_dagger", weight: 2},
    {item_key: "leather_armor", weight: 1}
]
```

Simplified syntax for equal-weight items (no weight specified defaults to weight: 1):

```gml
loot_table = [
    {item_key: "small_health_potion"},
    {item_key: "rusty_dagger"},
    {item_key: "leather_armor"}
]
```

### Drop Chance Property

Add to obj_enemy_parent Create event:

```gml
drop_chance = 0.3; // 30% chance to drop loot (default)
```

Individual enemies can override in their Create event:

```gml
event_inherited();
drop_chance = 0.8; // 80% chance for this enemy type
```

### Loot Drop Function

Create a new script file: `scr_enemy_loot_system.gml`

```gml
/// @desc Roll for loot drop and spawn item if successful
/// @param {Id.Instance} enemy The enemy instance that died
function enemy_drop_loot(enemy) {
    // Check if enemy has loot table
    if (!variable_instance_exists(enemy, "loot_table") || array_length(enemy.loot_table) == 0) {
        return; // No loot table configured
    }

    // Roll for drop chance
    if (!variable_instance_exists(enemy, "drop_chance")) {
        enemy.drop_chance = 0.3; // Default 30%
    }

    if (random(1) > enemy.drop_chance) {
        return; // No drop this time
    }

    // Select item from weighted loot table
    var selected_item_key = select_weighted_loot_item(enemy.loot_table);

    if (selected_item_key == undefined) {
        return; // Failed to select item
    }

    // Find valid spawn position
    var spawn_pos = find_loot_spawn_position(enemy.x, enemy.y);

    if (spawn_pos != noone) {
        spawn_item(spawn_pos.x, spawn_pos.y, selected_item_key);
        play_sfx(snd_loot_drop, 0.5, false); // Optional sound effect
    }
}

/// @desc Select an item from weighted loot table
/// @param {Array<Struct>} loot_table Array of {item_key, weight} structs
/// @return {String} Selected item key from global.item_database
function select_weighted_loot_item(loot_table) {
    if (array_length(loot_table) == 0) {
        return undefined;
    }

    // Calculate total weight (default weight = 1 if not specified)
    var total_weight = 0;
    for (var i = 0; i < array_length(loot_table); i++) {
        var entry = loot_table[i];
        var weight = entry[$ "weight"] ?? 1;
        total_weight += weight;
    }

    // Random selection based on weights
    var roll = random(total_weight);
    var cumulative = 0;

    for (var i = 0; i < array_length(loot_table); i++) {
        var entry = loot_table[i];
        var weight = entry[$ "weight"] ?? 1;
        cumulative += weight;

        if (roll <= cumulative) {
            return entry.item_key;
        }
    }

    // Fallback to first item
    return loot_table[0].item_key;
}

/// @desc Find valid spawn position for dropped loot
/// @param {Real} origin_x Enemy x position
/// @param {Real} origin_y Enemy y position
/// @return {Struct|noone} {x, y} position or noone if no valid position found
function find_loot_spawn_position(origin_x, origin_y) {
    var scatter_distance = 16;
    var max_attempts = 8;
    var tilemap = layer_tilemap_get_id("Tiles_Col");

    for (var attempt = 0; attempt < max_attempts; attempt++) {
        var angle = random(360);
        var test_x = origin_x + lengthdir_x(scatter_distance, angle);
        var test_y = origin_y + lengthdir_y(scatter_distance, angle);

        // Check if position is within room bounds
        if (test_x < 0 || test_x >= room_width || test_y < 0 || test_y >= room_height) {
            continue;
        }

        // Check collision tilemap
        if (tilemap != -1) {
            var tile_value = tilemap_get_at_pixel(tilemap, test_x, test_y);
            if (tile_value != 0) {
                continue; // Blocked tile
            }
        }

        // Check for collisions with solid objects
        if (place_meeting(test_x, test_y, obj_rising_pillar) ||
            place_meeting(test_x, test_y, obj_companion_parent)) {
            continue; // Object blocking
        }

        // Valid position found
        return {x: test_x, y: test_y};
    }

    // Fallback to enemy position if no valid scatter position found
    return {x: origin_x, y: origin_y};
}
```

### Integration with Enemy Death

Modify the enemy death logic in `scr_enemy_state_dead.gml` or the relevant collision/damage handler:

When enemy dies (hp <= 0), call:

```gml
enemy_drop_loot(self);
```

This should be added in the location where enemies are currently destroyed or marked as dead. Based on the codebase, this is likely in:
- `objects/obj_enemy_parent/Alarm_1.gml` (delayed death check)
- `objects/obj_enemy_parent/Collision_obj_attack.gml` (damage handling)

### Default Loot Table in obj_enemy_parent

Add to obj_enemy_parent Create event:

```gml
// Default loot table (30% chance to drop basic consumables)
drop_chance = 0.3;
loot_table = [
    {item_key: "small_health_potion", weight: 3},
    {item_key: "water", weight: 2},
    {item_key: "arrows", weight: 1}
];
```

### Example Enemy Customization

In obj_orc Create event:

```gml
event_inherited();

// Orcs have better loot and higher drop rate
drop_chance = 0.5; // 50% chance
loot_table = [
    {item_key: "rusty_dagger", weight: 2},
    {item_key: "medium_health_potion", weight: 3},
    {item_key: "leather_armor", weight: 1},
    {item_key: "arrows", weight: 4}
];
```

In obj_fire_imp Create event:

```gml
event_inherited();

// Fire imps drop fire-themed items
drop_chance = 0.4; // 40% chance
loot_table = [
    {item_key: "torch"},  // Equal weights
    {item_key: "small_health_potion"}
];
```

## Sound Effect Requirements

Add a loot drop sound effect (`snd_loot_drop`) to the project. This will be played when an item successfully drops. The sound should be subtle and not overwhelming since drops may happen frequently in combat.

## Testing Approach

1. Create a test room with multiple enemy types
2. Set enemy `drop_chance = 1.0` temporarily to guarantee drops for testing
3. Kill multiple enemies and verify:
   - Items spawn near enemy death locations
   - Items don't spawn on blocked tiles
   - Weighted probabilities work correctly (e.g., higher weight items drop more frequently)
   - Each enemy type respects its custom loot table
4. Reset `drop_chance` to balanced values after testing
