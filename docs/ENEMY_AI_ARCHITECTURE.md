# Enemy AI Architecture - Technical Documentation

This document provides comprehensive technical documentation for the enemy AI systems in Shadow Work, including state machines, pathfinding, dual-mode combat, and flanking behavior.

---

## Table of Contents

1. [State Machine](#state-machine)
2. [Pathfinding System](#pathfinding-system)
3. [Dual-Mode Combat System](#dual-mode-combat-system)
4. [Flanking & Approach Variation](#flanking--approach-variation)

---

## State Machine

Enemies use a state machine to control their behavior. The state machine runs in `obj_enemy_parent/Step_0.gml` and dispatches to state-specific scripts.

**Location:** `/objects/obj_enemy_parent/Step_0.gml`

### EnemyState Enum

```gml
enum EnemyState {
    idle,               // Standing still, no target
    targeting,          // Pursuing player with pathfinding
    attacking,          // Executing melee attack (cannot move)
    ranged_attacking,   // Firing projectile (can move while shooting)
    hazard_spawning,    // Spawning hazard projectile (boss ability)
    dead,               // Death state with animation
    wander              // Random movement within radius
}
```

**Location:** `/scripts/scr_enums/scr_enums.gml`

### State Dispatcher

```gml
// In obj_enemy_parent/Step_0.gml
switch(state) {
    case EnemyState.idle:
        scr_enemy_state_idle();
        break;

    case EnemyState.targeting:
        scr_enemy_state_targeting();
        break;

    case EnemyState.attacking:
        scr_enemy_state_attacking();
        break;

    case EnemyState.ranged_attacking:
        scr_enemy_state_ranged_attacking();
        break;

    case EnemyState.hazard_spawning:
        scr_enemy_state_hazard_spawning();
        break;

    case EnemyState.dead:
        scr_enemy_state_dead();
        break;

    case EnemyState.wander:
        scr_enemy_state_wander();
        break;
}
```

### State Descriptions

#### idle

**Purpose:** Default state when no target is present

**Behavior:**
- Stand still or play idle animation
- Check for player in detection range
- Transition to `targeting` when player detected

**Location:** `/scripts/scr_enemy_state_idle/scr_enemy_state_idle.gml`

#### targeting

**Purpose:** Pursue player and prepare to attack

**Behavior:**
- Calculate pathfinding to player
- Move toward player using pathfinding
- Maintain ideal range (distance varies by enemy type)
- Check if in attack range
- Transition to `attacking`, `ranged_attacking`, or `hazard_spawning` when ready

**Location:** `/scripts/scr_enemy_state_targeting/scr_enemy_state_targeting.gml`

**Key Variables:**
```gml
ideal_range = 80;              // Preferred distance from player
attack_range = 32;             // Range for melee attacks
path_update_timer = 0;         // Throttle pathfinding recalculation
path_update_interval = 120;    // Recalculate every 2 seconds
```

#### attacking

**Purpose:** Execute melee attack

**Behavior:**
- Stop movement (`target_x = x`, `target_y = y`)
- Play attack animation
- Cannot move during attack (committed)
- Create attack hitbox when animation completes
- Apply attack cooldown
- Transition back to `targeting` after attack

**Location:** `/scripts/scr_enemy_state_attacking/scr_enemy_state_attacking.gml`

**Attack Flow:**
1. Enter attacking state
2. Set attack animation playing
3. Wait for animation to complete
4. Spawn attack hitbox (`obj_enemy_attack`)
5. Set `alarm[0]` for cooldown
6. Return to targeting

#### ranged_attacking

**Purpose:** Execute ranged attack (fire projectile)

**Behavior:**
- **Can move while shooting** (unlike melee)
- Aim at player (update `facing_dir`)
- Play ranged attack animation
- Spawn projectile when animation completes
- Apply ranged attack cooldown
- Transition back to `targeting` after attack

**Key Difference from Melee:**
- Enemy continues pathfinding during ranged attack
- Allows kiting behavior
- Maintains distance from player

**Location:** `/scripts/scr_enemy_state_ranged_attacking/scr_enemy_state_ranged_attacking.gml`

**Attack Flow:**
1. Enter ranged_attacking state
2. Continue movement (pathfinding active)
3. Aim at player
4. Play ranged animation
5. Spawn projectile (`obj_enemy_arrow`)
6. Set `alarm[1]` for cooldown
7. Return to targeting

#### hazard_spawning

**Purpose:** Spawn hazard projectile (boss ability)

**Behavior:**
- Stop movement
- Play windup animation
- Show target indicator at player position
- Spawn hazard projectile after windup
- Apply hazard cooldown
- Transition back to `targeting`

**Location:** `/scripts/scr_enemy_state_hazard_spawning/scr_enemy_state_hazard_spawning.gml`

See `/docs/BOSS_MECHANICS.md` for detailed hazard spawning documentation.

#### dead

**Purpose:** Play death animation and cleanup

**Behavior:**
- Stop all movement
- Play death animation (frames 32-34)
- Drop loot if applicable
- Increment kill counters for quests
- Destroy instance when animation completes

**Location:** `/scripts/scr_enemy_state_dead/scr_enemy_state_dead.gml`

#### wander

**Purpose:** Random movement within area

**Behavior:**
- Pick random point within wander radius
- Move to that point
- Wait at point for short duration
- Pick new random point
- Check for player in detection range

**Location:** `/scripts/scr_enemy_state_wander/scr_enemy_state_wander.gml`

---

## Pathfinding System

Enemies use GameMaker's built-in `mp_grid` pathfinding system for obstacle avoidance.

**Location:** `/scripts/scr_enemy_state_targeting/scr_enemy_state_targeting.gml`

### Pathfinding Initialization

```gml
// In obj_game_controller Create event
global.mp_grid = mp_grid_create(0, 0, room_width div 16, room_height div 16, 16, 16);
mp_grid_add_instances(global.mp_grid, obj_wall, false);
```

### Path Update Throttling

Pathfinding is expensive, so it's throttled:

```gml
// Only recalculate path every 120 frames (2 seconds)
path_update_timer++;

if (path_update_timer >= path_update_interval) {
    path_update_timer = 0;
    recalculate_path();
}

// Also recalculate if player moved significantly
var player_moved_dist = point_distance(
    last_player_x, last_player_y,
    obj_player.x, obj_player.y
);

if (player_moved_dist >= 64) {
    recalculate_path();
    last_player_x = obj_player.x;
    last_player_y = obj_player.y;
}
```

### Ideal Range Maintenance

Enemies maintain an optimal distance from the player:

```gml
var dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);

// Melee enemies: Move to attack range
if (!is_ranged_attacker) {
    ideal_range = attack_range;
}

// Ranged enemies: Maintain 75-80% of attack range
if (is_ranged_attacker) {
    ideal_range = attack_range * 0.75;
}

// Stop pathfinding if within ideal range
if (dist_to_player <= ideal_range) {
    target_x = x;
    target_y = y;
    path_end();
}

// Move toward player if beyond ideal range
if (dist_to_player > ideal_range) {
    mp_path_to_point(path, obj_player.x, obj_player.y, move_speed, global.mp_grid);
}
```

### Line of Sight Checks

Ranged enemies require clear line of sight to attack:

```gml
function enemy_has_line_of_sight() {
    var _tilemap_col = layer_tilemap_get_id("Tiles_Col");
    if (_tilemap_col == -1) return true;

    // Check for collision tiles between enemy and player
    var collision = collision_line(
        x, y,
        obj_player.x, obj_player.y,
        obj_wall,
        false,
        true
    );

    return (collision == noone);
}
```

**Location:** `/scripts/scr_enemy_helpers/scr_enemy_helpers.gml`

### Unstuck System

Enemies can get stuck on geometry. The unstuck system detects this and forces movement:

```gml
// In obj_enemy_parent Create event
alarm[4] = 180;  // Check stuck every 3 seconds

// In Alarm[4] event
if (state == EnemyState.targeting) {
    var moved_dist = point_distance(x, y, stuck_check_x, stuck_check_y);

    if (moved_dist < 8) {
        // Enemy hasn't moved much, likely stuck
        // Force random direction movement
        var random_dir = random(360);
        x += lengthdir_x(move_speed * 30, random_dir);
        y += lengthdir_y(move_speed * 30, random_dir);

        // Recalculate path
        path_update_timer = path_update_interval;
    }

    stuck_check_x = x;
    stuck_check_y = y;
}

alarm[4] = 180;  // Reset alarm
```

---

## Dual-Mode Combat System

Enemies with `enable_dual_mode = true` can switch between melee and ranged attacks based on context.

**Location:** `/scripts/scr_enemy_state_targeting/scr_enemy_state_targeting.gml`

### Configuration Variables

```gml
// In enemy Create event
enable_dual_mode = true;                    // Toggle context-based switching
preferred_attack_mode = "ranged";           // "none", "melee", or "ranged"
melee_range_threshold = attack_range * 0.5; // Distance below which melee is preferred
ideal_range = attack_range * 0.75;          // Preferred standoff distance
retreat_when_close = true;                  // Retreat if player breaches ideal_range
retreat_cooldown = 0;                       // Prevents pathfinding spam (60 frames)
formation_role = undefined;                 // Set by party controller
```

### Attack Mode Decision Logic

```gml
// 1. Check formation role override
if (formation_role == "rear" || formation_role == "support") {
    // Force ranged mode
    use_ranged = true;
} else if (formation_role == "front" || formation_role == "vanguard") {
    // Force melee mode
    use_ranged = false;
}

// 2. Check distance thresholds
if (dist_to_player < melee_range_threshold) {
    // Very close, prefer melee
    use_ranged = false;
} else if (dist_to_player > ideal_range) {
    // Beyond ideal range, prefer ranged
    use_ranged = true;
}

// 3. Check cooldown availability
if (use_ranged && ranged_attack_cooldown > 0) {
    // Ranged on cooldown, try melee
    use_ranged = false;
} else if (!use_ranged && attack_cooldown > 0) {
    // Melee on cooldown, try ranged
    use_ranged = true;
}

// 4. Check line of sight for ranged
if (use_ranged && !enemy_has_line_of_sight()) {
    // No LOS, fall back to melee
    use_ranged = false;
}

// 5. Execute chosen attack mode
if (use_ranged) {
    state = EnemyState.ranged_attacking;
} else {
    state = EnemyState.attacking;
}
```

### Retreat Behavior

Ranged-preferring enemies retreat when player gets too close:

```gml
if (retreat_when_close &&
    preferred_attack_mode == "ranged" &&
    dist_to_player < ideal_range &&
    retreat_cooldown <= 0) {

    // Calculate retreat direction (away from player)
    var retreat_angle = point_direction(obj_player.x, obj_player.y, x, y);

    // Find retreat point
    var retreat_dist = 64;
    var retreat_x = x + lengthdir_x(retreat_dist, retreat_angle);
    var retreat_y = y + lengthdir_y(retreat_dist, retreat_angle);

    // Path to retreat point
    mp_path_to_point(path, retreat_x, retreat_y, move_speed * 1.2, global.mp_grid);

    // Set cooldown to prevent spam
    retreat_cooldown = 60;  // 1 second
}

// Cooldown countdown
if (retreat_cooldown > 0) {
    retreat_cooldown--;
}
```

### Separate Cooldowns

Dual-mode enemies have independent cooldowns for each attack type:

```gml
// Melee attack cooldown (Alarm[0])
alarm[0] = attack_cooldown_time;  // ~90 frames (1.5s)

// Ranged attack cooldown (Alarm[1])
alarm[1] = ranged_attack_cooldown_time;  // ~180 frames (3s)

// In Alarm[0]
attack_cooldown = 0;
can_attack = true;

// In Alarm[1]
ranged_attack_cooldown = 0;
can_ranged_attack = true;
```

### Example Dual-Mode Enemy

```gml
// obj_orc_raider - Melee-focused with ranged backup
event_inherited();

// Dual-mode config
enable_dual_mode = true;
preferred_attack_mode = "melee";
melee_range_threshold = 48;
retreat_when_close = false;  // Aggressive positioning

// Melee stats
attack_damage = 5;
attack_speed = 1.0;
attack_range = 32;

// Ranged stats
ranged_damage = 3;
ranged_attack_speed = 0.8;
ranged_attack_range = 150;
ranged_damage_type = DamageType.physical;

// Will primarily use melee, fall back to ranged when player at distance
```

---

## Flanking & Approach Variation

Enemies can approach from the side or behind the player for tactical variety.

**Location:** `/scripts/scr_enemy_state_targeting/scr_enemy_state_targeting.gml`

### Configuration

```gml
// In enemy Create event
flank_trigger_distance = 120;  // Distance threshold for flanking
flank_chance = 0.4;            // 40% probability
flank_approach_chosen = false;  // One-time selection flag
flank_target_x = 0;
flank_target_y = 0;
```

### Flank Calculation

```gml
// When enemy first aggros to player
if (!flank_approach_chosen && dist_to_player >= flank_trigger_distance) {
    flank_approach_chosen = true;

    // Roll for flank
    if (random(1.0) < flank_chance) {
        // Calculate flank position (behind player)
        var player_facing_angle = 0;

        switch(obj_player.facing_dir) {
            case "down":  player_facing_angle = 270; break;
            case "up":    player_facing_angle = 90;  break;
            case "left":  player_facing_angle = 180; break;
            case "right": player_facing_angle = 0;   break;
        }

        // Opposite of player's facing + random variance (±30°)
        var flank_angle = player_facing_angle + 180 + random_range(-30, 30);

        // Position 60-80 pixels behind player
        var flank_distance = random_range(60, 80);
        flank_target_x = obj_player.x + lengthdir_x(flank_distance, flank_angle);
        flank_target_y = obj_player.y + lengthdir_y(flank_distance, flank_angle);

        is_flanking = true;
    }
}

// Path to flank position instead of player
if (is_flanking && !flank_position_reached) {
    mp_path_to_point(path, flank_target_x, flank_target_y, move_speed, global.mp_grid);

    // Check if reached flank position
    if (point_distance(x, y, flank_target_x, flank_target_y) < 16) {
        flank_position_reached = true;
        is_flanking = false;
        // Now path directly to player
    }
}
```

### Reset on Aggro Loss

```gml
// If player exits detection range
if (dist_to_player > detection_range) {
    state = EnemyState.idle;
    flank_approach_chosen = false;
    is_flanking = false;
    flank_position_reached = false;
}
```

### Example Flanking Enemy

```gml
// obj_burglar - High flank chance
event_inherited();

flank_chance = 0.6;            // 60% chance to flank
flank_trigger_distance = 150;  // Starts flanking from farther away
move_speed = 1.2;              // Fast enough to execute flank

// Rogue-type enemy that tries to backstab
```

---

## Key Files Reference

| File | Purpose | Key Lines |
|------|---------|-----------|
| `/objects/obj_enemy_parent/Create_0.gml` | Enemy initialization | Full file |
| `/objects/obj_enemy_parent/Step_0.gml` | State machine dispatcher | Full file |
| `/scripts/scr_enemy_state_targeting/scr_enemy_state_targeting.gml` | Pathfinding, dual-mode, flanking | Full file |
| `/scripts/scr_enemy_state_attacking/scr_enemy_state_attacking.gml` | Melee attack state | Full file |
| `/scripts/scr_enemy_state_ranged_attacking/scr_enemy_state_ranged_attacking.gml` | Ranged attack state | Full file |
| `/scripts/scr_enemy_helpers/scr_enemy_helpers.gml` | Line of sight, utility functions | Full file |
| `/docs/ENEMY_AI_PATHFINDING_AND_RANGED_BEHAVIOR.md` | Advanced AI behaviors | Full file |
| `/docs/ENEMY_PARTY_SYSTEM.md` | Party formations and states | Full file |

---

*Last Updated: 2025-10-17*
