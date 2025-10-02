# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-02-enemy-grid-pathfinding/spec.md

> Created: 2025-10-02
> Version: 1.0.0

## Technical Requirements

### 1. Pathfinding Controller (obj_pathfinding_controller)

**Room-Specific Grid Setup**
- Create mp_grid in Create event with dimensions based on room size
- Cell size: 16x16 pixels (matches tile_size from grid puzzle system)
- Formula: `horizontal_cells = room_width / 16`, `vertical_cells = room_height / 16`
- Grid origin: (0, 0) top-left corner of room

**Obstacle Marking**
- Use `mp_grid_add_instances()` to mark obstacles:
  - Tiles_Col layer (collision tilemap) - `layer_tilemap_get_id("Tiles_Col")`
  - obj_enemy_parent instances
  - obj_rising_pillar instances
  - obj_companion_parent instances
- Update obstacles dynamically if pillars rise/fall during gameplay

**Controller Lifecycle**
- Place obj_pathfinding_controller in each room except room_initial
- OR: Make persistent and detect room changes in Step event, skip room_initial
- Recommendation: Room-specific placement for simplicity (one instance per gameplay room)
- Clean up grid in Clean Up event: `mp_grid_destroy(grid)`

**Debug Visualization**
- Check `global.debug_pathfinding` flag (set in obj_game_controller Create event)
- In Draw event: `if (global.debug_pathfinding) mp_grid_draw(grid)`
- Grid display: Green cells = walkable, Red cells = obstacles
- Set alpha to 0.3 for transparency: `draw_set_alpha(0.3)` before mp_grid_draw

### 2. Enemy State System Updates

**New Enum Value**
Add to EnemyState enum in `/scripts/scr_enums/scr_enums.gml`:
```gml
enum EnemyState {
    idle,
    targeting,  // NEW - pathfinding and pursuit
    attacking,
    ranged_attacking,
    dead,
}
```

**State Transition Logic**
- `idle` → `targeting`: Player within `aggro_distance` (configurable per enemy, default 160)
- `targeting` → `attacking`: Melee enemy + player within `attack_range`
- `targeting` → `ranged_attacking`: Ranged enemy + player within ideal shooting range
- `targeting` → `idle`: Player beyond `aggro_distance`
- Play `enemy_sounds.on_aggro` sound effect when entering `targeting` state

### 3. Enemy Parent Modifications (obj_enemy_parent/Create_0.gml)

**New Variables**
```gml
// Pathfinding variables
path = path_add();              // GameMaker path instance
ideal_range = attack_range;      // Ideal distance from player (override for ranged)
path_update_timer = 0;           // Frame counter for path updates
last_target_x = 0;               // Track player position changes
last_target_y = 0;
current_path_target_x = 0;       // Where path is leading
current_path_target_y = 0;
```

**Cleanup in Destroy/Clean Up Event**
```gml
if (path_exists(path)) {
    path_delete(path);
}
```

### 4. Pathfinding Helper Functions

Create new script file: `/scripts/scr_enemy_pathfinding/scr_enemy_pathfinding.gml`

**Function: enemy_calculate_target_position()**
```gml
/// @desc Calculate ideal target position based on enemy type
/// @return {x: number, y: number} Target coordinates
function enemy_calculate_target_position() {
    if (!instance_exists(obj_player)) return {x: x, y: y};

    var player_x = obj_player.x;
    var player_y = obj_player.y;

    // Melee enemies: target player position directly
    if (!is_ranged_attacker) {
        return {x: player_x, y: player_y};
    }

    // Ranged enemies: maintain ideal_range ± 20px
    var dist_to_player = point_distance(x, y, player_x, player_y);
    var target_dist = ideal_range;

    // If too close, back away
    if (dist_to_player < ideal_range - 20) {
        target_dist = ideal_range + 20; // Move to outer range
    }
    // If too far, close in
    else if (dist_to_player > ideal_range + 20) {
        target_dist = ideal_range - 20; // Move to inner range
    }
    // In good range, try to circle strafe
    else {
        // Calculate perpendicular position for circle strafing
        var angle_to_player = point_direction(x, y, player_x, player_y);
        var strafe_angle = angle_to_player + choose(-90, 90); // Perpendicular
        var strafe_x = player_x + lengthdir_x(ideal_range, strafe_angle);
        var strafe_y = player_y + lengthdir_y(ideal_range, strafe_angle);

        // Check if strafe position is walkable
        if (instance_exists(obj_pathfinding_controller)) {
            var grid = obj_pathfinding_controller.grid;
            var grid_x = floor(strafe_x / 16);
            var grid_y = floor(strafe_y / 16);
            if (mp_grid_get_cell(grid, grid_x, grid_y) == 0) { // 0 = walkable
                return {x: strafe_x, y: strafe_y};
            }
        }

        // Fallback: maintain current distance
        return {x: player_x + lengthdir_x(ideal_range, angle_to_player),
                y: player_y + lengthdir_y(ideal_range, angle_to_player)};
    }

    var angle = point_direction(player_x, player_y, x, y);
    return {
        x: player_x + lengthdir_x(target_dist, angle),
        y: player_y + lengthdir_y(target_dist, angle)
    };
}
```

**Function: enemy_update_path(target_x, target_y)**
```gml
/// @desc Update pathfinding path to target position
/// @param {real} target_x Target x coordinate
/// @param {real} target_y Target y coordinate
/// @return {bool} True if path created successfully
function enemy_update_path(target_x, target_y) {
    if (!instance_exists(obj_pathfinding_controller)) return false;

    var grid = obj_pathfinding_controller.grid;

    // Delete old path
    if (path_exists(path)) {
        path_delete(path);
        path = path_add();
    }

    // Create new path
    var path_found = mp_grid_path(
        grid,           // The grid to use
        path,           // Path to populate
        x, y,           // Start position
        target_x, target_y,  // End position
        true            // Allow diagonal movement
    );

    if (path_found) {
        current_path_target_x = target_x;
        current_path_target_y = target_y;

        // Start following path
        var speed_modifier = get_status_effect_modifier("speed");
        var terrain_speed = enemy_get_terrain_speed_modifier();
        var final_speed = move_speed * speed_modifier * terrain_speed;

        path_start(path, final_speed, path_action_stop, false);
        return true;
    }

    return false;
}
```

**Function: enemy_get_terrain_speed_modifier()**
```gml
/// @desc Get movement speed modifier based on current terrain and traits
/// @return {real} Speed multiplier (1.0 = normal)
function enemy_get_terrain_speed_modifier() {
    var terrain = get_terrain_at_position(x, y);
    var speed_mult = 1.0;

    // Check permanent traits for terrain bonuses
    if (variable_struct_exists(permanent_traits, "aquatic") && terrain == "water") {
        speed_mult = 1.5; // 50% faster on water
    }
    else if (variable_struct_exists(permanent_traits, "fireborne") && terrain == "lava") {
        speed_mult = 1.5; // 50% faster on lava (if lava terrain added)
    }
    // Add more terrain type checks as needed

    return speed_mult;
}
```

### 5. Enemy State Targeting Script

Create new script file: `/scripts/enemy_state_targeting/enemy_state_targeting.gml`

```gml
/// @desc Enemy targeting state - handles pathfinding and pursuit
function enemy_state_targeting() {
    if (!instance_exists(obj_player)) {
        state = EnemyState.idle;
        return;
    }

    var dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);

    // Check if player is out of aggro range
    if (dist_to_player > aggro_distance) {
        state = EnemyState.idle;
        path_end(); // Stop following path
        return;
    }

    // Check if in attack range
    if (is_ranged_attacker) {
        // Ranged attack logic
        if (dist_to_player <= attack_range && can_ranged_attack) {
            enemy_handle_ranged_attack();
            return;
        }
    } else {
        // Melee attack logic
        if (dist_to_player <= attack_range && can_attack) {
            state = EnemyState.attacking;
            attack_cooldown = round(90 / attack_speed);
            can_attack = false;
            alarm[2] = 15; // Attack hits after 15 frames
            path_end(); // Stop pathing while attacking
            return;
        }
    }

    // Recalculate path if Alarm[0] fired (every 120 frames)
    if (alarm[0] <= 0) {
        var target_pos = enemy_calculate_target_position();
        var path_created = enemy_update_path(target_pos.x, target_pos.y);

        if (!path_created) {
            // No valid path - wander randomly in small area
            target_x = x + random_range(-50, 50);
            target_y = y + random_range(-50, 50);
        }

        alarm[0] = 120; // Reset path update timer (2 seconds at 60fps)
    }

    // Continue following current path
    // Path movement is automatic via path_start() in enemy_update_path()
}
```

### 6. Enemy Parent Step Event Integration

Modify `/objects/obj_enemy_parent/Step_0.gml` to handle targeting state:

Add after existing state checks (around line 59):
```gml
// Targeting state (pathfinding)
if (state == EnemyState.targeting) {
    enemy_state_targeting();
}

// Check for player aggro (transition idle → targeting)
if (state == EnemyState.idle && instance_exists(obj_player)) {
    var dist = point_distance(x, y, obj_player.x, obj_player.y);
    if (dist <= aggro_distance) {
        state = EnemyState.targeting;
        alarm[0] = 1; // Trigger immediate path calculation
        play_enemy_sfx("on_aggro");
    }
}
```

### 7. Alarm[0] Modification

Modify `/objects/obj_enemy_parent/Alarm_0.gml`:

```gml
// Only pick random targets if idle (not targeting player with pathfinding)
if (state == EnemyState.idle) {
    if (instance_exists(obj_player) && distance_to_object(obj_player) < aggro_distance) {
        state = EnemyState.targeting;
        play_enemy_sfx("on_aggro");
        alarm[0] = 1; // Trigger immediate path calculation
    } else {
        target_x = random_range(xstart - 100, xstart + 100);
        target_y = random_range(ystart - 100, ystart + 100);
        alarm[0] = 60;
    }
} else if (state == EnemyState.targeting) {
    // Path recalculation happens in enemy_state_targeting()
    // This alarm is used as a timer flag, reset there
}
```

### 8. Debug Path Visualization

Modify enemy Draw event to show paths when debugging:

In `/objects/obj_enemy_parent/Draw_0.gml`, add before the existing draw code:
```gml
// Debug: Draw pathfinding path
if (global.debug_pathfinding && path_exists(path)) {
    draw_set_color(c_yellow);
    draw_set_alpha(0.5);
    draw_path(path, x, y, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
```

### 9. Terrain Detection Function

Ensure `/scripts/scr_ui_functions/scr_ui_functions.gml` or create in new pathfinding script:

```gml
/// @desc Get terrain type at position
/// @param {real} x X coordinate
/// @param {real} y Y coordinate
/// @return {string} Terrain type name
function get_terrain_at_position(pos_x, pos_y) {
    // Check each terrain layer in priority order
    var water_tile = tilemap_get_at_pixel(layer_tilemap_get_id("Tiles_Water"), pos_x, pos_y);
    if (water_tile != 0) return "water";

    var water_moving_tile = tilemap_get_at_pixel(layer_tilemap_get_id("Tiles_Water_Moving"), pos_x, pos_y);
    if (water_moving_tile != 0) return "water";

    var path_tile = tilemap_get_at_pixel(layer_tilemap_get_id("Tiles_Path"), pos_x, pos_y);
    if (path_tile != 0) return "path";

    // Default to grass
    return "grass";
}
```

### 10. Global Debug Flag Setup

In `/objects/obj_game_controller/Create_0.gml`, add:
```gml
// Pathfinding debug visualization
global.debug_pathfinding = true; // Set to false for production
```

## Performance Considerations

- **Max 15 enemies per room**: Path recalculation every 2 seconds (120 frames) keeps computational load reasonable
- **Grid cleanup**: Always destroy grids in Clean Up event to prevent memory leaks
- **Path reuse**: Only recalculate when target moves significantly or timer expires
- **Obstacle updates**: Only refresh mp_grid obstacles when pillars toggle (not every frame)

## Testing Checklist

1. Enemies navigate around walls without getting stuck
2. Enemies avoid other enemies, pillars, and companions as obstacles
3. Ranged enemies maintain distance and circle strafe when possible
4. Melee enemies close to player and attack when in range
5. Debug visualization shows grid and paths correctly
6. Enemies move faster on preferred terrain (aquatic on water, etc.)
7. State transitions work: idle ↔ targeting ↔ attacking
8. Path updates occur every 2 seconds without performance issues
9. Enemies wander when no path to player exists
10. System works in all rooms except room_initial

## Files Modified/Created

**Created:**
- `/objects/obj_pathfinding_controller/` (new object)
- `/scripts/scr_enemy_pathfinding/scr_enemy_pathfinding.gml`
- `/scripts/enemy_state_targeting/enemy_state_targeting.gml`

**Modified:**
- `/scripts/scr_enums/scr_enums.gml` - Add EnemyState.targeting
- `/objects/obj_enemy_parent/Create_0.gml` - Add pathfinding variables
- `/objects/obj_enemy_parent/Step_0.gml` - Add targeting state logic
- `/objects/obj_enemy_parent/Alarm_0.gml` - Modify for pathfinding
- `/objects/obj_enemy_parent/Draw_0.gml` - Add debug path visualization
- `/objects/obj_enemy_parent/CleanUp_0.gml` - Delete path on destroy
- `/objects/obj_game_controller/Create_0.gml` - Add global.debug_pathfinding flag

## Code Style Compliance

Following the Ruby-like GML conventions from CLAUDE.md:
- Functions: `snake_case` (e.g., `enemy_calculate_target_position()`)
- Variables: `snake_case` (e.g., `path_update_timer`, `ideal_range`)
- Local variables: underscore prefix (e.g., `_target_pos`, `_grid`)
- Enums: `PascalCase` (e.g., `EnemyState`)
- Enum values: `snake_case` (e.g., `EnemyState.targeting`)
