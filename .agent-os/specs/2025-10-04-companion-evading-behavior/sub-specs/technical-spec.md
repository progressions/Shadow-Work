# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-04-companion-evading-behavior/spec.md

> Created: 2025-10-04
> Version: 1.0.0

## Technical Requirements

### Player Combat Timer System

- Add `combat_timer` variable to `obj_player` (tracks time since last combat activity)
- Add `combat_cooldown` constant (3-5 seconds, configurable)
- Add `is_in_combat()` function that returns `combat_timer < combat_cooldown`
- Reset `combat_timer = 0` in player's collision events:
  - When player takes damage (collision with enemy attack objects)
  - When `obj_attack` collides with `obj_enemy_parent` (in obj_attack collision event)
- Increment `combat_timer += delta_time / 1000000` in player Step event

### Companion State System

- Add `CompanionState` enum to companion parent or existing companion code:
  - `CompanionState.following` - Normal follow behavior
  - `CompanionState.evading` - Combat evasion behavior
- Add `companion_state` variable to all companion objects (obj_grimnir, obj_runa, obj_thrain, or shared parent if exists)
- Add `evade_distance_min` = 64 pixels (minimum distance from player/enemies)
- Add `evade_distance_max` = 128 pixels (maximum distance for visibility)
- Add `evade_detection_radius` = 200 pixels (range to detect enemies to avoid)

### Evasion Pathfinding Logic

In companion Step event, add state check:

```gml
// Check player combat status and transition states
if (obj_player.is_in_combat()) {
    if (companion_state == CompanionState.following) {
        companion_state = CompanionState.evading;
    }
} else {
    if (companion_state == CompanionState.evading) {
        companion_state = CompanionState.following;
    }
}

// Execute behavior based on state
switch (companion_state) {
    case CompanionState.following:
        // Existing follow logic
        break;

    case CompanionState.evading:
        // New evasion logic
        evade_from_combat();
        break;
}
```

### Evade Function Implementation

Create `evade_from_combat()` function for companions:

1. **Find evasion target position:**
   - Calculate vector away from player position
   - Check for nearby enemies (within `evade_detection_radius`)
   - Calculate combined avoidance vector from player + all nearby enemies
   - Find position at `evade_distance_min` to `evade_distance_max` range along avoidance vector

2. **Pathfinding:**
   - Use existing pathfinding system (mp_grid if available, or direct movement)
   - Move toward evasion target position
   - Recalculate every N frames (e.g., every 15-30 frames to reduce CPU usage)

3. **Edge case handling:**
   - If no valid path found (tight corridor), move to farthest walkable corner
   - If already at sufficient distance, idle in place
   - Respect collision with walls using existing tilemap collision system

### State Transition Smoothness

- Do not recalculate evasion position every frame (cache for 0.5-1 second)
- When transitioning from evading → following, smoothly pathfind back to follow position rather than snapping
- Add small hysteresis to prevent rapid state switching at cooldown boundary (e.g., require 0.5s buffer)

### Visual Feedback (Optional)

- Add `evading_sprite` variable to companions (alternative sprite or animation)
- In Draw event, check `if (companion_state == CompanionState.evading)` and use different sprite/animation
- Could use existing animation system with different frame or speed
- Alternatively, add particle effect or color tint during evading

### Performance Considerations

- Maximum 3 companions active simultaneously
- Pathfinding recalculation throttled to every 15-30 frames per companion
- Enemy detection uses collision_circle or instance_position checks (fast)
- No expensive distance calculations every frame (cache and reuse)

### Integration Points

- **obj_player**: Add combat timer, modify collision events to reset timer
- **obj_attack**: Reset player combat timer on enemy hit
- **Companion objects** (obj_grimnir, obj_runa, obj_thrain): Add state system and evasion logic
- **Existing pathfinding**: Leverage current companion pathfinding system (mp_grid or custom)

### Testing Checkpoints

1. Combat timer correctly resets when player takes damage
2. Combat timer correctly resets when player hits enemy
3. Companions transition to evading state when combat starts
4. Companions pathfind away from player and enemies during evasion
5. Companions maintain 64-128 pixel distance during evasion
6. Companions return to following after 3-5 seconds of no combat
7. Behavior works in open rooms and tight corridors
8. No performance degradation with 3 companions evading simultaneously
