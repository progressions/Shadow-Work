# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-11-enemy-movement-profiles/spec.md

> Created: 2025-10-11
> Version: 1.0.0

## Technical Requirements

### Movement Profile Database

- Create `global.movement_profile_database` in obj_game_controller/Create_0.gml
- Structure similar to `global.trait_database` with profile definitions
- Each profile contains:
  - `name`: Display name
  - `type`: Movement type identifier ("kiting_swooper", etc.)
  - `parameters`: Struct with configurable values
  - `update_function`: Script reference for movement logic

**Example Profile Structure:**
```gml
global.movement_profile_database = {
    kiting_swooper: {
        name: "Kiting Swoop Attacker",
        type: "kiting_swooper",
        parameters: {
            kite_min_distance: 75,      // Minimum distance to maintain
            kite_max_distance: 150,     // Maximum distance before closing in
            kite_ideal_distance: 110,   // Preferred distance
            erratic_offset: 16,         // Random position offset for erratic movement
            erratic_update_interval: 30, // Frames between erratic adjustments
            swoop_range: 200,           // Max distance to initiate swoop
            swoop_speed: 8,             // Dash attack speed
            swoop_cooldown: 120,        // Frames between swoops (2 seconds)
            return_speed: 4,            // Speed when returning to anchor
            anchor_tolerance: 16        // How close to anchor before resuming kiting
        },
        update_function: movement_profile_kiting_swooper_update
    }
};
```

### Enemy Movement Profile Variables

Add to obj_enemy_parent/Create_0.gml:
```gml
// Movement profile system
movement_profile = undefined;           // Assigned profile from database
movement_profile_state = "idle";       // Profile-specific state: "idle", "kiting", "swooping", "returning"
movement_profile_anchor_x = x;         // Home position X
movement_profile_anchor_y = y;         // Home position Y
movement_profile_target_x = x;         // Current movement target X
movement_profile_target_y = y;         // Current movement target Y
movement_profile_erratic_timer = 0;    // Timer for erratic adjustments
movement_profile_swoop_cooldown = 0;   // Cooldown timer for swoop attacks
```

### Movement Profile Assignment

Enemies opt-in to movement profiles in their Create event:
```gml
// In obj_bat/Create_0.gml
event_inherited();
movement_profile = global.movement_profile_database.kiting_swooper;
```

### Movement Profile Update Integration

Modify `scr_enemy_state_targeting/scr_enemy_state_targeting.gml`:
- Check if `movement_profile != undefined` at start of function
- If movement profile exists, call `movement_profile.update_function(self)`
- Profile update function controls pathfinding and state transitions
- If no profile, use default pathfinding behavior (existing code)

### Kiting Swooper Update Function

Create `scripts/movement_profile_kiting_swooper_update/movement_profile_kiting_swooper_update.gml`:

**State: "kiting"**
- Calculate distance to player
- If distance < kite_min_distance: Move away from player
- If distance > kite_max_distance: Move toward player
- Else: Maintain current distance with erratic offsets
- Update erratic target position every N frames (random offset within radius)
- Use pathfinding to reach erratic target position
- Check swoop conditions: if player in range + cooldown ready → transition to "swooping"

**State: "swooping"**
- Set state to EnemyState.attacking (for animation)
- Calculate direction to player
- Move in straight line at swoop_speed (bypass pathfinding)
- Spawn swoop attack hitbox (use existing attack system)
- On collision or reaching player position → transition to "returning"

**State: "returning"**
- Calculate direction to anchor position
- Move toward anchor at return_speed using pathfinding
- If distance to anchor < anchor_tolerance → transition to "kiting"
- Reset swoop cooldown

### Swoop Attack Hitbox

- Reuse existing obj_attack or obj_enemy_attack system
- Set damage, knockback, and damage type from enemy stats
- Linear movement along swoop trajectory
- Destroy on collision or max distance

### Animation Integration

- Use existing enemy animation system
- Map movement_profile_state to animation states:
  - "kiting" → walk animation in facing direction
  - "swooping" → attack animation in swoop direction
  - "returning" → walk animation toward anchor

### Stun/Stagger Integration

- Movement profile updates should respect `is_stunned` and `is_staggered`
- If stunned: Cannot initiate swoop attack
- If staggered: Cannot move (kiting/returning paused)
- Profile state preserved during CC, resumes when cleared

### Pathfinding Collision

- Use existing `mp_grid` pathfinding system
- Kiting and returning states use path_find_to()
- Swooping state bypasses pathfinding (direct line)
- Handle path_end() when switching between profile states

## Approach

The movement profile system extends the existing enemy AI architecture without modifying core pathfinding logic. By checking for a movement profile at the start of the targeting state, we allow profile-enabled enemies to override default behavior while maintaining compatibility with existing systems.

The kiting swooper profile uses a state machine within the movement profile itself, allowing complex multi-phase behaviors (kite → swoop → return) while still respecting the parent enemy state machine for animations and CC effects.

## External Dependencies

None - uses existing GameMaker pathfinding and enemy AI systems.
