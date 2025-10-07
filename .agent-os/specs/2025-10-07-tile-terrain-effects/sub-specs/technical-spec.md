# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-07-tile-terrain-effects/spec.md

## Technical Requirements

### 1. Terrain Effects Database Structure

Create `global.terrain_effects_map` in `obj_game_controller/Create_0.gml`:

```gml
global.terrain_effects_map = {
    "lava": {
        traits: ["burning"],              // Array of trait keys to apply
        speed_modifier: 0.8,              // 20% slower (0.8x speed)
        is_hazard: true,                  // Mark as obstacle in pathfinding
        hazard_immunity_traits: ["fire_immunity"]  // Entities with these traits ignore hazard flag
    },
    "poison_pool": {
        traits: ["poisoned"],
        speed_modifier: 0.7,              // 30% slower
        is_hazard: true,
        hazard_immunity_traits: ["poison_immunity"]
    },
    "ice": {
        traits: [],                       // No traits applied
        speed_modifier: 1.4,              // 40% faster (slippery)
        is_hazard: false                  // Not a pathfinding obstacle
    },
    "path": {
        traits: [],
        speed_modifier: 1.25,             // 25% faster (existing behavior)
        is_hazard: false
    },
    "water": {
        traits: ["wet"],
        speed_modifier: 0.9,              // 10% slower
        is_hazard: false                  // Not hazardous (just slows)
    },
    "grass": {
        traits: [],
        speed_modifier: 1.0,              // Normal speed
        is_hazard: false
    }
};
```

### 2. Terrain Trait Tracking

Add to both `obj_player` and `obj_enemy_parent` in Create events:

```gml
terrain_applied_traits = {};  // Struct: {trait_key: true/false} - tracks which terrain traits are active
current_terrain = "grass";    // String: last detected terrain type
```

### 3. Terrain Effect Application Logic

Create function `apply_terrain_effects()` in `/scripts/trait_system/trait_system.gml`:

```gml
/// @function apply_terrain_effects()
/// @description Apply terrain-based traits and speed modifiers (call in Step event)
function apply_terrain_effects() {
    var _terrain = get_terrain_at_position(x, y);
    var _terrain_data = global.terrain_effects_map[$ _terrain];

    if (_terrain_data == undefined) {
        _terrain_data = global.terrain_effects_map[$ "grass"]; // Default
    }

    // Apply speed modifier (direct modification)
    terrain_speed_modifier = _terrain_data.speed_modifier;

    // Track terrain traits
    var _new_terrain_traits = {};

    // Apply traits from current terrain
    var _traits_to_apply = _terrain_data.traits;
    for (var i = 0; i < array_length(_traits_to_apply); i++) {
        var _trait_key = _traits_to_apply[i];
        _new_terrain_traits[$ _trait_key] = true;

        // Try to apply trait (will exit early if trait already exists)
        var _trait_def = global.trait_database[$ _trait_key];
        if (_trait_def != undefined) {
            var _duration = _trait_def.default_duration;
            apply_timed_trait(_trait_key, _duration, 1); // 1 stack
        }
    }

    // Terrain traits persist after leaving (expire naturally via timer)
    terrain_applied_traits = _new_terrain_traits;
    current_terrain = _terrain;
}
```

### 4. Player Integration

Update `obj_player/Step_0.gml` to call `apply_terrain_effects()` before state machine:

```gml
// Apply terrain effects (traits and speed modifier)
apply_terrain_effects();

// State machine
switch(state) {
    case PlayerState.idle:
        player_state_idle();
        break;
    // ... rest of state machine
}
```

Update `player_state_walking.gml` to use `terrain_speed_modifier`:

```gml
// Replace hardcoded path check with terrain modifier
var _status_speed_modifier = get_status_effect_modifier("speed");
var _final_move_speed = move_speed * terrain_speed_modifier * _status_speed_modifier;
```

### 5. Enemy Integration

Update `obj_enemy_parent/Step_0.gml` to call `apply_terrain_effects()`:

```gml
if (!global.game_paused) {
    // Apply terrain effects
    apply_terrain_effects();

    // State machine
    switch(state) {
        // ... existing state machine
    }
}
```

Update `enemy_get_terrain_speed_modifier()` in `/scripts/scr_enemy_pathfinding/scr_enemy_pathfinding.gml`:

```gml
/// @function enemy_get_terrain_speed_modifier()
/// @description Get terrain-based speed modifier for enemy
function enemy_get_terrain_speed_modifier() {
    return terrain_speed_modifier; // Use new system instead of hardcoded checks
}
```

### 6. Enemy Pathfinding Hazard Avoidance

Update `enemy_update_path()` in `/scripts/scr_enemy_pathfinding/scr_enemy_pathfinding.gml`:

Add hazard checking logic after pathfinding grid creation:

```gml
function enemy_update_path() {
    // ... existing path calculation ...

    // Mark hazardous terrain tiles as obstacles (unless immune)
    mark_hazardous_terrain_in_grid();

    // ... rest of pathfinding logic ...
}

/// @function mark_hazardous_terrain_in_grid()
/// @description Mark hazardous terrain tiles as obstacles in mp_grid
function mark_hazardous_terrain_in_grid() {
    if (!variable_instance_exists(id, "path_grid")) return;

    var _grid = path_grid;
    var _cell_width = mp_grid_get_cell_width(_grid);
    var _cell_height = mp_grid_get_cell_height(_grid);
    var _grid_width = mp_grid_width(_grid);
    var _grid_height = mp_grid_height(_grid);

    // Iterate through grid cells
    for (var _gx = 0; _gx < _grid_width; _gx++) {
        for (var _gy = 0; _gy < _grid_height; _gy++) {
            var _world_x = _gx * _cell_width + _cell_width / 2;
            var _world_y = _gy * _cell_height + _cell_height / 2;

            var _terrain = get_terrain_at_position(_world_x, _world_y);
            var _terrain_data = global.terrain_effects_map[$ _terrain];

            if (_terrain_data != undefined && _terrain_data.is_hazard) {
                // Check if entity has immunity
                var _is_immune = false;
                var _immunity_traits = _terrain_data.hazard_immunity_traits;
                for (var i = 0; i < array_length(_immunity_traits); i++) {
                    if (has_trait(_immunity_traits[i])) {
                        _is_immune = true;
                        break;
                    }
                }

                // Mark as obstacle if not immune
                if (!_is_immune) {
                    mp_grid_add_cell(_grid, _gx, _gy);
                }
            }
        }
    }
}
```

### 7. Initialization Order

In `obj_game_controller/Create_0.gml`, initialize `global.terrain_effects_map` AFTER `global.trait_database`:

```gml
// Initialize trait database first
init_trait_database();

// Then initialize terrain effects map (depends on trait database)
global.terrain_effects_map = { /* ... */ };
```

### 8. Backward Compatibility

Ensure existing terrain system continues to work:
- Keep `global.terrain_tile_map` for terrain detection
- Keep `get_terrain_at_position()` unchanged
- New system layers on top of existing terrain detection

### 9. Performance Considerations

- `apply_terrain_effects()` called once per frame per entity
- `get_terrain_at_position()` uses efficient tilemap lookups
- Pathfinding hazard marking only called during path recalculation (every 2 seconds)
- `apply_timed_trait()` exits early if trait already exists (minimal performance impact)

## External Dependencies

No new external dependencies required. The system uses existing GameMaker and trait system functions.
