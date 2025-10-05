# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-05-enemy-approach-variation/spec.md

> Created: 2025-10-05
> Version: 1.0.0

## Technical Requirements

### Enemy Parent Object Variables

Add to `obj_enemy_parent` Create event:
- `approach_mode` - String: "direct" or "flanking" (default: "direct")
- `approach_chosen` - Boolean: false (set to true once approach angle selected)
- `flank_offset_angle` - Number: 0 (stores chosen perpendicular offset, ±90 degrees)
- `flank_trigger_distance` - Number: 120 (distance threshold to trigger approach selection)
- `flank_chance` - Number: 0.4 (40% chance to flank, configurable per enemy type)

### Approach Angle Selection Logic

In `obj_enemy_parent` Step event, during targeting state:

```gml
// Check distance to player for approach variation
var dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);

// Trigger approach selection when entering close range (once per aggro)
if (!approach_chosen && dist_to_player <= flank_trigger_distance) {
    approach_chosen = true;

    // Random chance to select flanking approach
    if (random(1) < flank_chance) {
        approach_mode = "flanking";

        // Choose perpendicular offset: +90 or -90 degrees
        flank_offset_angle = choose(90, -90);
    } else {
        approach_mode = "direct";
        flank_offset_angle = 0;
    }
}
```

### Target Position Calculation

Modify enemy targeting to apply flanking offset:

```gml
// Calculate base direction to player
var base_dir = point_direction(x, y, obj_player.x, obj_player.y);

// Apply flanking offset if in flanking mode
var approach_dir = base_dir;
if (approach_mode == "flanking") {
    approach_dir = base_dir + flank_offset_angle;
}

// Calculate target position at approach angle
var approach_distance = 32; // Distance from player to aim for
target_x = obj_player.x + lengthdir_x(approach_distance, approach_dir);
target_y = obj_player.y + lengthdir_y(approach_distance, approach_dir);
```

### Approach Reset on State Change

Reset approach variables when enemy loses aggro or changes state:

```gml
// In enemy state machine when transitioning away from targeting
if (state != EnemyState.targeting && approach_chosen) {
    approach_chosen = false;
    approach_mode = "direct";
    flank_offset_angle = 0;
}
```

### Integration with Existing Pathfinding

- Use existing `target_x` and `target_y` variables for pathfinding destination
- No changes needed to `mp_grid` pathfinding system
- Flanking offset applies before pathfinding calculates route
- Enemies follow calculated path using existing movement code

### Visual Debugging (Optional)

Add debug visualization to see approach angles:

```gml
// In Draw event (debug mode only)
if (global.debug_mode && approach_mode == "flanking") {
    draw_set_color(c_yellow);
    draw_line(x, y, target_x, target_y);
    draw_circle(target_x, target_y, 8, true);
    draw_set_color(c_white);
}
```

### Configuration Per Enemy Type

Allow enemy types to override flanking behavior:

```gml
// In specific enemy Create events (e.g., obj_orc)
flank_chance = 0.6; // Orcs flank 60% of the time
flank_trigger_distance = 100; // Orcs trigger flanking closer

// In obj_burglar Create event
flank_chance = 0.3; // Burglars flank less often (30%)
flank_trigger_distance = 150; // But trigger from farther away
```

### Performance Considerations

- Approach angle calculated once per aggro cycle (not every frame)
- Uses simple trigonometry (point_direction, lengthdir_x/y) - very fast
- No additional collision checks or pathfinding overhead
- Existing pathfinding handles movement to calculated target position

### Edge Case Handling

**Confined Spaces:**
- Flanking may place target position inside walls
- Existing pathfinding will route around obstacles
- If unreachable, enemy will get as close as possible using mp_grid

**Multiple Enemies:**
- Each enemy chooses flanking independently
- No coordination between enemies (keeps AI simple)
- Natural variation creates diverse attack patterns

**Player Movement:**
- Target position recalculates based on current player position
- Flanking angle remains constant once chosen
- Creates circling behavior as enemy maintains perpendicular approach

### Testing Checkpoints

1. Enemy enters flank_trigger_distance and chooses approach mode (direct or flanking)
2. Flanking enemies select ±90 degree offset from direct path
3. Target position calculated correctly at approach angle
4. Enemies pathfind to offset target position successfully
5. Approach mode persists until enemy loses aggro or reaches player
6. Visual variety in enemy approach patterns during spawner combat
7. Player must reposition to avoid flanking enemies
8. Performance remains stable with multiple flanking enemies (3+ simultaneous)
