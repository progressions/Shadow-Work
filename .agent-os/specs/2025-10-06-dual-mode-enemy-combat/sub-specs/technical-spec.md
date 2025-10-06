# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-06-dual-mode-enemy-combat/spec.md

## Technical Requirements

### 1. New Configuration Properties (obj_enemy_parent/Create_0.gml)

Add the following properties after existing combat properties (around line 61):

```gml
// Dual-mode combat configuration
enable_dual_mode = false;              // Flag to enable dual-mode attack switching
preferred_attack_mode = "none";        // Options: "none", "melee", "ranged"
melee_range_threshold = attack_range * 0.5;  // Distance below which melee is preferred
retreat_when_close = false;            // Whether to retreat if player breaches ideal_range
```

**Property Behaviors:**
- `enable_dual_mode`: When `true`, enemy can use both melee and ranged attacks based on distance
- `preferred_attack_mode`:
  - `"none"` = choose purely by distance
  - `"melee"` = bias toward melee, only use ranged when too far
  - `"ranged"` = bias toward ranged, retreat when player gets close
- `melee_range_threshold`: Distance below which melee is preferred (default 50% of attack_range)
- `retreat_when_close`: When `true` and player is inside ideal_range, enemy attempts to path away from player

### 2. Attack Mode Decision Logic (scr_enemy_state_targeting.gml)

**Current Implementation (lines 53-74):** Binary choice based on `is_ranged_attacker` flag

**New Implementation:** Replace lines 53-74 with distance-based dual-mode logic:

```gml
// Calculate distance to player
var _dist_to_player = point_distance(x, y, _player_x, _player_y);

// Dual-mode attack decision
if (enable_dual_mode) {
    // Determine which attack mode to use based on distance and preference
    var _use_ranged = false;
    var _use_melee = false;

    // Distance-based decision
    if (_dist_to_player > ideal_range) {
        _use_ranged = true;  // Player is far, use ranged
    } else if (_dist_to_player < melee_range_threshold) {
        _use_melee = true;   // Player is close, use melee
    } else {
        // In the "flexible zone" - use preference
        if (preferred_attack_mode == "ranged") {
            _use_ranged = true;
        } else if (preferred_attack_mode == "melee") {
            _use_melee = true;
        } else {
            // No preference - default to closer range = melee
            _use_melee = (_dist_to_player < ideal_range);
            _use_ranged = !_use_melee;
        }
    }

    // Check party formation influence
    if (variable_instance_exists(id, "formation_role")) {
        if (formation_role == "rear" || formation_role == "support") {
            _use_ranged = true;
            _use_melee = false;
        } else if (formation_role == "front" || formation_role == "vanguard") {
            _use_melee = true;
            _use_ranged = false;
        }
    }

    // Execute ranged attack if chosen and ready
    if (_use_ranged && _dist_to_player <= attack_range && can_ranged_attack) {
        var _has_los = enemy_has_line_of_sight(_player_x, _player_y);
        if (_has_los) {
            enemy_handle_ranged_attack();
            return;
        } else {
            alarm[0] = 0;  // Force path recalc for LOS
        }
    }

    // Execute melee attack if chosen and ready
    if (_use_melee && _dist_to_player <= attack_range && can_attack) {
        state = EnemyState.attacking;
        attack_cooldown = round(90 / attack_speed);
        can_attack = false;
        alarm[2] = 15;  // Trigger melee execution
        if (path_exists(path)) {
            path_end();
        }
        return;
    }

    // Handle retreat for ranged-preferring enemies
    if (retreat_when_close && preferred_attack_mode == "ranged" && _dist_to_player < ideal_range) {
        // Calculate retreat direction (away from player)
        var _retreat_dir = point_direction(_player_x, _player_y, x, y);
        var _retreat_distance = ideal_range + 32;  // Retreat beyond ideal_range

        // Set retreat target
        target_x = _player_x + lengthdir_x(_retreat_distance, _retreat_dir);
        target_y = _player_y + lengthdir_y(_retreat_distance, _retreat_dir);

        // Force immediate path recalc
        alarm[0] = 0;
    }
}
// Legacy single-mode logic (fallback for enable_dual_mode = false)
else if (is_ranged_attacker) {
    // ... existing ranged-only logic
} else {
    // ... existing melee-only logic
}
```

### 3. Party Formation Integration

**File:** `objects/obj_enemy_party_controller/Step_0.gml`

**Integration Point:** When updating party member formation positions (around line 40-50), assign formation roles:

```gml
// In update_formation_positions() or equivalent function
for (var i = 0; i < array_length(party_members); i++) {
    var _enemy = party_members[i];
    if (!instance_exists(_enemy)) continue;

    // Assign formation role based on position
    var _formation_pos = formation_positions[i];

    // Determine role based on Y-offset in formation (rear = negative Y, front = positive Y)
    if (_formation_pos.y < -16) {
        _enemy.formation_role = "rear";
    } else if (_formation_pos.y > 16) {
        _enemy.formation_role = "front";
    } else {
        _enemy.formation_role = "support";
    }

    // Update target position
    _enemy.target_x = formation_center_x + _formation_pos.x;
    _enemy.target_y = formation_center_y + _formation_pos.y;
}
```

### 4. Animation System Compatibility

**File:** `scripts/scr_animation_helpers/scr_animation_helpers.gml`

**Existing System (lines 58-67):** Already supports ranged attack animation fallback

**Requirement:** Ensure all dual-mode enemies have animation data for both modes:

- **Ranged animations:** `ranged_attack_down`, `ranged_attack_right`, `ranged_attack_left`, `ranged_attack_up`
- **Melee animations:** `attack_down`, `attack_right`, `attack_left`, `attack_up`

**Animation Frame Reference (from `/Users/isaacpriestley/Library/CloudStorage/Dropbox/GAMES/SHADOW KINGDOM/SPRITES/source/characters/enemy_with_ranged_attack.json`):**

Standard enemy sprite sheet layout with ranged attacks:
```
Frames 0-1:   idle_down
Frames 2-3:   idle_right
Frames 4-5:   idle_left
Frames 6-7:   idle_up
Frames 8-10:  walk_down
Frames 11-13: walk_right
Frames 14-16: walk_left
Frames 17-19: walk_up
Frames 20-22: attack_down (melee)
Frames 23-25: attack_right (melee)
Frames 26-28: attack_left (melee)
Frames 29-31: attack_up (melee)
Frames 32-34: dying
Frames 35-37: ranged_attack_down
Frames 38-40: ranged_attack_right
Frames 41-43: ranged_attack_left
Frames 44-46: ranged_attack_up
```

**enemy_anim_overrides Configuration:**
```gml
enemy_anim_overrides = {
    ranged_attack_down: {start: 35, length: 3},
    ranged_attack_right: {start: 38, length: 3},
    ranged_attack_left: {start: 41, length: 3},
    ranged_attack_up: {start: 44, length: 3}
};
```

**Implementation Notes:**
- If enemy has `enemy_anim_overrides` with ranged animations, those will be used
- If no ranged animations exist, fallback to melee attack frames (existing behavior)
- No code changes needed - existing animation system already supports this
- User will provide sprites following the 47-frame layout shown above

### 5. Cooldown Independence

**Current Implementation:** Already supports independent cooldowns (obj_enemy_parent/Step_0.gml lines 262-278)

**Requirement:** Ensure mode-switching doesn't abuse cooldowns

**Safeguard:** Add cooldown gate to mode decision:

```gml
// In dual-mode decision logic, before executing attacks
if (_use_ranged && !can_ranged_attack) {
    _use_ranged = false;
    _use_melee = (_use_melee && can_attack);  // Fallback to melee if ready
}

if (_use_melee && !can_attack) {
    _use_melee = false;
    _use_ranged = (_use_ranged && can_ranged_attack);  // Fallback to ranged if ready
}
```

### 6. Enemy Configuration Examples

**Sandsnake Javelin Warrior (obj_sandsnake/Create_0.gml):**
```gml
// Add after existing properties
enable_dual_mode = true;
preferred_attack_mode = "ranged";
melee_range_threshold = 32;  // Very close before melee
retreat_when_close = true;   // Maintain range
```

**Orc Raider (obj_orc/Create_0.gml):**
```gml
// Configure for dual-mode with melee preference
enable_dual_mode = true;
preferred_attack_mode = "melee";
ranged_damage = 3;  // Throwing axe damage
ranged_attack_speed = 0.6;  // Slower than melee
ranged_projectile_object = obj_throwing_axe;  // New projectile type
melee_range_threshold = 48;
retreat_when_close = false;  // Orcs don't retreat
```

**Greenwood Bandit Archer (obj_greenwood_bandit/Create_0.gml):**
```gml
// Add melee capability to existing archer
enable_dual_mode = true;
preferred_attack_mode = "ranged";
attack_damage = 1;  // Weak dagger swipe
melee_range_threshold = 24;  // Only melee when desperate
retreat_when_close = true;
```

### 7. Performance Considerations

**Decision Frequency:** Mode decision runs every frame in targeting state
- **Optimization:** Cache mode decision for 5-10 frames unless distance threshold crossed
- **Implementation:** Add `attack_mode_cache` and `cache_timer` variables

**Path Recalculation:** Retreat behavior triggers frequent pathfinding
- **Mitigation:** Use existing alarm[0] throttling (already prevents spam)
- **Additional:** Add minimum retreat cooldown of 60 frames (1 second)

### 8. Testing Requirements

**Functional Tests:**
1. Dual-mode enemy switches from ranged to melee when player approaches below ideal_range
2. Ranged-preferring enemy retreats when player breaches ideal_range
3. Party formation rear positions use ranged, front positions use melee
4. Both cooldowns work independently (can't spam by switching modes)
5. Animation system shows correct attack type for current mode

**Edge Cases:**
1. Enemy with dual-mode but no ranged animations (should fallback to melee frames)
2. Enemy stuck against wall while trying to retreat (should stop pathing and defend with melee)
3. Both attacks on cooldown (enemy should reposition/idle)
4. LOS blocked for ranged but player in melee range (should use melee)

### 9. File Modifications Summary

**Files to Modify:**
1. `/objects/obj_enemy_parent/Create_0.gml` - Add dual-mode properties
2. `/scripts/scr_enemy_state_targeting/scr_enemy_state_targeting.gml` - Implement mode decision logic
3. `/objects/obj_enemy_party_controller/Step_0.gml` - Add formation role assignment
4. `/objects/obj_sandsnake/Create_0.gml` - Configure for dual-mode
5. `/objects/obj_orc/Create_0.gml` - Configure for dual-mode with ranged capability
6. `/objects/obj_greenwood_bandit/Create_0.gml` - Configure for dual-mode with melee fallback

**New Files (if needed):**
- `/objects/obj_throwing_axe/` - New projectile type for orc ranged attacks (optional)

**Files to Review (no changes):**
- `/scripts/scr_animation_helpers/scr_animation_helpers.gml` - Already supports dual-mode
- `/scripts/enemy_handle_ranged_attack/enemy_handle_ranged_attack.gml` - Already functional
- `/objects/obj_enemy_parent/Alarm_2.gml` - Melee attack execution (already functional)

## External Dependencies

None - this feature uses existing GameMaker systems and project infrastructure.
