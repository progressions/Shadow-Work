# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-16-enemy-collision-chain-attacks/spec.md

> Created: 2025-10-16
> Version: 1.0.0

## Technical Requirements

### Enemy Collision Damage System

**Implementation Location:** obj_enemy_parent

**Configuration Variables (Create event):**
```gml
// Collision damage configuration
collision_damage_enabled = false;        // Enable/disable collision damage
collision_damage_amount = 2;             // Base damage on collision
collision_damage_type = DamageType.physical;  // Damage type
collision_damage_cooldown = 30;          // Frames between collision hits (0.5s)
collision_damage_timer = 0;              // Current cooldown timer
```

**Collision Event Implementation:**
- Create new file: `obj_enemy_parent/Collision_obj_player.gml`
- Check: `collision_damage_enabled && collision_damage_timer <= 0 && player not dead`
- Apply full damage calculation pipeline:
  - Damage type modifier via `get_damage_modifier_for_type()`
  - Equipment DR (melee DR for collision damage)
  - Companion DR bonuses
  - Defense trait modifiers (bolstered/sundered)
  - Minimum 1 chip damage
- Apply knockback away from enemy
- Set `collision_damage_timer = collision_damage_cooldown`
- Trigger player invulnerability frames

**Step Event Addition:**
```gml
// Decrement collision damage cooldown
if (collision_damage_timer > 0) {
    collision_damage_timer--;
}
```

### Player Invulnerability System

**Implementation Location:** obj_player

**New Variables:**
```gml
invulnerable = false;                    // Invulnerability flag
invulnerability_duration = 30;           // Frames of invulnerability (0.5s default)
invulnerability_timer = 0;               // Current invulnerability counter
```

**Invulnerability Trigger Function:**
```gml
function trigger_invulnerability(duration) {
    invulnerable = true;
    invulnerability_timer = duration;
}
```

**Step Event:**
```gml
// Handle invulnerability countdown
if (invulnerability_timer > 0) {
    invulnerability_timer--;
    if (invulnerability_timer <= 0) {
        invulnerable = false;
    }
}
```

**Draw Event (Visual Feedback):**
```gml
// Flash sprite during invulnerability
if (invulnerable && (invulnerability_timer mod 4 < 2)) {
    draw_sprite_ext(sprite_index, image_index, x, y,
        image_xscale, image_yscale, image_angle,
        c_white, 0.5);  // 50% opacity flashing
} else {
    draw_self();
}
```

**Integration with Collision Damage:**
- Enemy collision checks `if (!other.invulnerable)` before applying damage
- Call `other.trigger_invulnerability(30)` after successful hit

### Chain Boss Throw Attack

**New Boss State:** Add to EnemyState enum or use existing targeting state with flag

**Configuration Variables (obj_chain_boss_parent):**
```gml
// Throw attack configuration
throw_attack_enabled = true;             // Enable throw attack
throw_attack_cooldown = 300;             // 5 seconds between throws
throw_attack_cooldown_timer = 0;         // Current cooldown
throw_windup_time = 20;                  // Windup before throw (0.33s)
throw_speed = 6;                         // Auxiliary projectile speed
throw_damage_multiplier = 1.5;           // 1.5x collision damage when thrown
```

**Throw Attack State Machine:**

1. **Target Selection:**
   - Boss checks if throw available: `throw_attack_cooldown_timer <= 0 && auxiliaries_alive > 0`
   - Select random living auxiliary
   - Calculate throw trajectory toward player's current position

2. **Windup Phase (20 frames):**
   - Boss animation: pulling back
   - Selected auxiliary moves slightly toward boss
   - Visual telegraph: chain glows or auxiliary flashes

3. **Throw Phase:**
   - Set auxiliary state: `auxiliary_state = AuxiliaryState.thrown`
   - Set auxiliary velocity toward target: `throw_speed` in direction of player
   - Enable collision damage temporarily: `collision_damage_enabled = true`
   - Apply damage multiplier: `collision_damage_amount *= throw_damage_multiplier`
   - Auxiliary becomes projectile (ignores pathfinding)

4. **Flight Phase:**
   - Auxiliary travels in straight line (could add arc with gravity simulation)
   - Chain renders taut from boss to auxiliary
   - Check collision with player or walls
   - Max flight time: 2 seconds before auto-return

5. **Return Phase:**
   - Set auxiliary state: `auxiliary_state = AuxiliaryState.returning`
   - Move auxiliary back toward boss using lerp or pathfinding
   - Disable collision damage
   - Reset state to `normal` when within 32 pixels of boss
   - Start throw cooldown: `throw_attack_cooldown_timer = throw_attack_cooldown`

**Auxiliary State Tracking:**
```gml
// Add to auxiliary Create event (via chain boss spawn)
auxiliary_state = "normal";  // normal, thrown, spinning, returning
```

**Auxiliary Step Override (when thrown):**
```gml
if (auxiliary_state == "thrown") {
    // Projectile movement
    x += throw_velocity_x;
    y += throw_velocity_y;

    // Check distance from boss (snap back if too far)
    if (point_distance(x, y, chain_boss.x, chain_boss.y) > chain_boss.chain_max_length * 1.5) {
        auxiliary_state = "returning";
    }

    // Collision with walls - bounce or return
    if (place_meeting(x, y, obj_wall)) {
        auxiliary_state = "returning";
    }
}
else if (auxiliary_state == "returning") {
    // Move toward boss
    var _return_speed = 3;
    var _dir = point_direction(x, y, chain_boss.x, chain_boss.y);
    x += lengthdir_x(_return_speed, _dir);
    y += lengthdir_y(_return_speed, _dir);

    // Reset when close to boss
    if (point_distance(x, y, chain_boss.x, chain_boss.y) < 32) {
        auxiliary_state = "normal";
        collision_damage_enabled = false;  // Disable collision damage
    }
}
```

### Chain Boss Spin Attack

**Configuration Variables:**
```gml
// Spin attack configuration
spin_attack_enabled = true;              // Enable spin attack
spin_attack_cooldown = 420;              // 7 seconds between spins
spin_attack_cooldown_timer = 0;          // Current cooldown
spin_attack_duration = 120;              // Spin for 2 seconds
spin_attack_rotation_speed = 6;          // Degrees per frame
spin_attack_active = false;              // Currently spinning flag
spin_attack_timer = 0;                   // Duration counter
```

**Spin Attack State Machine:**

1. **Activation Check:**
   - Boss checks: `spin_attack_cooldown_timer <= 0 && auxiliaries_alive >= 2`
   - Set `spin_attack_active = true`
   - Set `spin_attack_timer = spin_attack_duration`

2. **Spin Phase (120 frames / 2 seconds):**
   - Boss rotates visually: `image_angle += spin_attack_rotation_speed`
   - All auxiliaries forced to orbit at `chain_max_length` distance
   - Auxiliary positions calculated:
     ```gml
     for (var i = 0; i < array_length(auxiliaries); i++) {
         var _base_angle = (i * 360 / array_length(auxiliaries));
         var _current_angle = _base_angle + (spin_attack_rotation_speed * (spin_attack_duration - spin_attack_timer));

         auxiliaries[i].x = x + lengthdir_x(chain_max_length, _current_angle);
         auxiliaries[i].y = y + lengthdir_y(chain_max_length, _current_angle);
         auxiliaries[i].auxiliary_state = "spinning";
         auxiliaries[i].collision_damage_enabled = true;
     }
     ```
   - Chains render taut (tension = 1.0)
   - Decrement `spin_attack_timer`

3. **End Phase:**
   - When `spin_attack_timer <= 0`:
     - Set `spin_attack_active = false`
     - Reset all auxiliaries: `auxiliary_state = "returning"`
     - Auxiliaries pathfind back to normal positions
     - Disable collision damage
     - Start cooldown: `spin_attack_cooldown_timer = spin_attack_cooldown`
     - Reset boss angle: `image_angle = 0`

**Integration with Boss Step Event:**
```gml
// Check for spin attack trigger
if (spin_attack_enabled && !spin_attack_active &&
    spin_attack_cooldown_timer <= 0 && auxiliaries_alive >= 2) {

    // Random chance or HP threshold
    if (random(1) < 0.1) {  // 10% chance per frame when available
        spin_attack_active = true;
        spin_attack_timer = spin_attack_duration;
    }
}

// Handle active spin attack
if (spin_attack_active) {
    handle_spin_attack();
}

// Cooldown counters
if (spin_attack_cooldown_timer > 0) {
    spin_attack_cooldown_timer--;
}
if (throw_attack_cooldown_timer > 0) {
    throw_attack_cooldown_timer--;
}
```

### Auxiliary-Based Damage Reduction

**Configuration Variable:**
```gml
// Auxiliary shield configuration
auxiliary_dr_bonus = 2;                  // DR per living auxiliary
```

**Implementation in Collision_obj_attack:**
```gml
// Calculate auxiliary-based DR bonus
var _auxiliary_dr = 0;
if (variable_instance_exists(self, "auxiliary_dr_bonus") &&
    variable_instance_exists(self, "auxiliaries_alive")) {
    _auxiliary_dr = auxiliaries_alive * auxiliary_dr_bonus;
}

// Add to total enemy DR calculation
var _total_dr = base_dr + equipment_dr + trait_dr + _auxiliary_dr;
```

**Visual Feedback:**
- Damage numbers show reduced damage when boss has auxiliaries
- Optional: Draw shield icons above boss (1 per auxiliary)
- Console debug: "Boss DR: +X from Y auxiliaries"

### Performance Considerations

1. **Collision Checks:** Only check when `collision_damage_enabled = true`
2. **Invulnerability:** Single boolean check prevents redundant calculations
3. **Throw Attack:** Only one auxiliary thrown at a time (max 1 projectile)
4. **Spin Attack:** Position calculation once per frame for all auxiliaries
5. **Chain Rendering:** Taut chains during spin (simpler calculation)

## Approach

### Implementation Order

1. **Phase 1: Core Collision System**
   - Add collision damage variables to obj_enemy_parent
   - Create Collision_obj_player event
   - Implement cooldown in Step event
   - Test with single enemy type

2. **Phase 2: Player Invulnerability**
   - Add invulnerability variables to obj_player
   - Implement trigger function
   - Add Step countdown logic
   - Add Draw event flashing
   - Test collision damage with invulnerability

3. **Phase 3: Chain Boss Foundation**
   - Add auxiliary state tracking
   - Implement state override logic for auxiliaries
   - Add throw/spin configuration variables
   - Test auxiliary state transitions

4. **Phase 4: Throw Attack**
   - Implement throw state machine
   - Add windup/flight/return phases
   - Test trajectory and collision
   - Add visual polish (chain tension, telegraph)

5. **Phase 5: Spin Attack**
   - Implement spin state machine
   - Add orbital positioning calculation
   - Test multi-auxiliary coordination
   - Add visual polish (rotation, chain rendering)

6. **Phase 6: Auxiliary DR System**
   - Add DR bonus calculation to boss
   - Integrate with existing DR pipeline
   - Test damage scaling with auxiliary count
   - Add visual feedback (shield icons)

### Testing Strategy

1. **Unit Tests:**
   - Collision damage applies once per cooldown period
   - Invulnerability prevents all collision damage during duration
   - Auxiliary state transitions correctly (normal → thrown → returning → normal)
   - Auxiliary state transitions correctly (normal → spinning → returning → normal)
   - DR bonus scales linearly with auxiliary count

2. **Integration Tests:**
   - Throw attack doesn't break auxiliary pathfinding after return
   - Spin attack doesn't overlap with throw attack
   - Multiple enemies with collision damage don't stack-hit player
   - Auxiliary DR applies to all damage types correctly

3. **Performance Tests:**
   - 4 auxiliaries spinning doesn't drop framerate
   - Multiple collision-enabled enemies don't cause lag
   - Chain rendering during spin attack maintains 60 FPS

### Edge Cases

1. **Auxiliary dies mid-throw:** Auxiliary destroyed, chain disappears, no return phase
2. **Boss dies during spin:** All auxiliaries released, return to normal AI
3. **Player dashes through spinning auxiliaries:** Invulnerability prevents rapid multi-hit
4. **Throw attack hits wall immediately:** Bounce or immediate return to boss
5. **All auxiliaries dead:** Throw/spin attacks disabled, DR bonus = 0

## External Dependencies

No new external dependencies required. Uses existing GameMaker functions:
- Collision events (built-in)
- `point_distance()`, `point_direction()` for positioning
- `lengthdir_x()`, `lengthdir_y()` for movement
- Existing damage calculation pipeline from combat system
- Existing trait system for damage type modifiers
