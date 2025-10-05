# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-04-dash-attack-combo/spec.md

## Technical Requirements

### Player State Tracking
- Add `dash_attack_window` timer variable to `obj_player` (tracks time since dash ended)
- Add `last_dash_direction` variable to `obj_player` (stores direction: "up", "down", "left", "right")
- Add `is_dash_attacking` boolean flag to `obj_player` (true during dash attack execution)

### Dash Attack Window Logic
- Start `dash_attack_window` timer when dash state ends (transitions from `PlayerState.dashing` to another state)
- Window duration: 0.3 to 0.5 seconds (recommend starting with 0.4 seconds, tunable via constant)
- Reset `dash_attack_window` to 0 when:
  - Player changes movement direction (input different from `last_dash_direction`)
  - Timer exceeds window duration
  - Attack is executed (successful or not)

### Directional Consistency Check
- When attack input is detected, check if `dash_attack_window` is active (timer > 0 and <= window duration)
- Compare current player facing direction with `last_dash_direction`
- If directions match AND window is active: trigger dash attack combo
- If directions don't match OR window expired: execute normal attack

### Damage Calculation Modification
- In `get_total_damage()` function (or equivalent damage calculation):
  - Check `is_dash_attacking` flag
  - If true: multiply final damage by 1.5 (+50% boost)
  - Set `is_dash_attacking` flag for duration of attack animation/state

### Damage Reduction Modification
- In player damage reception logic (likely in collision with enemy attacks or `obj_enemy_parent`):
  - Check `is_dash_attacking` flag
  - If true: multiply damage reduction by 0.75 (-25% penalty)
  - This means player takes more damage while dash attacking

### Audio Integration
- Create/assign sound effect for dash attack (player will provide asset)
- Play sound effect when `is_dash_attacking` flag is set to true
- Use `audio_play_sound(snd_dash_attack, 1, false)` or similar GML audio function

### Animation Considerations
- Use existing attack animation (no new visual assets required initially)
- Optional future enhancement: Add visual effect (particles, trail, etc.) when `is_dash_attacking` is true

## Implementation Constants

Recommend adding these constants/macros for easy tuning:
- `DASH_ATTACK_WINDOW_DURATION = 0.4` (seconds)
- `DASH_ATTACK_DAMAGE_MULTIPLIER = 1.5` (+50%)
- `DASH_ATTACK_DEFENSE_PENALTY = 0.75` (-25% damage reduction)

## GML Code Integration Points

### obj_player Step Event
```gml
// Track dash attack window
if (dash_attack_window > 0) {
    dash_attack_window -= 1/room_speed; // Decrement by delta time

    // Check for direction change
    if (input_direction != last_dash_direction && input_direction != -1) {
        dash_attack_window = 0; // Cancel window
    }

    // Expire window
    if (dash_attack_window > DASH_ATTACK_WINDOW_DURATION) {
        dash_attack_window = 0;
    }
}
```

### obj_player Attack Input Handling
```gml
// When attack button pressed
if (dash_attack_window > 0 && facing_direction == last_dash_direction) {
    is_dash_attacking = true;
    audio_play_sound(snd_dash_attack, 1, false);
} else {
    is_dash_attacking = false;
}
```

### Damage Calculation (get_total_damage or equivalent)
```gml
var _damage = base_damage; // Calculate base damage from weapon/stats
if (is_dash_attacking) {
    _damage *= DASH_ATTACK_DAMAGE_MULTIPLIER;
}
return _damage;
```

### Player Damage Reception
```gml
// When player takes damage
var _incoming_damage = enemy_damage;
var _damage_reduction = calculate_damage_reduction(); // Armor/stats

if (is_dash_attacking) {
    _damage_reduction *= DASH_ATTACK_DEFENSE_PENALTY;
}

var _final_damage = _incoming_damage * (1 - _damage_reduction);
hp -= _final_damage;
```

## Testing Considerations

- Test edge cases: dashing into wall, dashing then immediately moving different direction
- Verify damage boost is applied correctly (use debug output or damage numbers)
- Verify defense penalty makes player more vulnerable (intentionally take hits during dash attack)
- Test with different weapon types and damage values
- Ensure dash cooldown interaction works correctly (no unintended combo spamming)
