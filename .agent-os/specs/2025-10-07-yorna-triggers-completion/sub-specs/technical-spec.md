# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-07-yorna-triggers-completion/spec.md

## Technical Requirements

### 1. Companion Notification System

Create new notification functions in `scr_companion_system.gml`:

- **companion_on_player_hit(player_instance, enemy_instance, damage_dealt)** - Called when player successfully hits an enemy
  - Iterate through active companions
  - Check for on_hit triggers
  - Apply bonus damage and cooldowns
  - Visual feedback via floating text

- **companion_on_player_crit(player_instance)** - Called when player lands a critical hit
  - Activate dash/crit-based triggers (Expose Weakness, Execution Window)
  - Not needed if already called by companion_on_player_dash

- Update existing **companion_on_player_dash()** to also trigger crit-based abilities

### 2. On-Hit Strike Implementation

Location: `scr_companion_system.gml` - new function `companion_on_player_hit()`

Logic:
1. Get active companions with `get_active_companions()`
2. For each companion with `on_hit_strike` trigger:
   - Check if unlocked (should be true for Yorna by default)
   - Check if cooldown == 0
   - If both true:
     - Add bonus_damage to enemy's damage (modify final_damage calculation)
     - Set cooldown to cooldown_max (30 frames)
     - Spawn floating text at Yorna's position
     - Play trigger sound via `companion_play_trigger_sfx()`

Integration Point: `obj_enemy_parent/Collision_obj_attack.gml` line ~96 (after damage calculation, before spawn_damage_number)

### 3. Expose Weakness Implementation

Location: `scr_companion_system.gml` - extend `companion_on_player_dash()`

Logic:
1. Check if Yorna has expose_weakness trigger unlocked (affinity >= 8.0)
2. Check if cooldown == 0
3. If both true:
   - Enter casting state (already implemented for other triggers)
   - Set trigger active and cooldown
   - Find all enemies within radius (64 pixels from player)
   - Apply temporary armor reduction debuff to each enemy
   - Store original armor values for restoration
   - Set alarm or timer for duration (180 frames)
   - Visual feedback and sound

Debuff System:
- Add `expose_weakness_active` flag to affected enemies
- Store `expose_weakness_original_dr` values
- Reduce melee_damage_resistance by 2
- On expiration: restore original DR and clear flags

### 4. Execution Window Implementation

Location: `scr_companion_system.gml` - extend `companion_on_player_dash()`

Logic:
1. Check if Yorna has execution_window trigger unlocked (affinity >= 10.0)
2. Check if cooldown == 0
3. If both true:
   - Enter casting state
   - Set trigger active and cooldown
   - Set timer for duration (120 frames)
   - Store damage_multiplier (2.0) and armor_pierce (3) in trigger
   - Visual feedback and sound

Integration:
- Since Yorna doesn't attack, this trigger modifies player's damage instead
- Add checks in damage calculation to apply execution_window bonuses
- Alternative: Add execution bonuses to player's damage calculation when trigger is active

### 5. Cooldown Management

Location: `obj_companion_parent/Step_0.gml` lines 7-21 (existing cooldown section)

Add Yorna-specific cooldowns:
```gml
if (variable_struct_exists(triggers, "on_hit_strike") && triggers.on_hit_strike.cooldown > 0)
    triggers.on_hit_strike.cooldown--;
if (variable_struct_exists(triggers, "expose_weakness") && triggers.expose_weakness.cooldown > 0)
    triggers.expose_weakness.cooldown--;
if (variable_struct_exists(triggers, "execution_window") && triggers.execution_window.cooldown > 0)
    triggers.execution_window.cooldown--;
```

Add affinity-based unlock checks:
```gml
if (variable_struct_exists(triggers, "expose_weakness"))
    triggers.expose_weakness.unlocked = (affinity >= 8.0);
if (variable_struct_exists(triggers, "execution_window"))
    triggers.execution_window.unlocked = (affinity >= 10.0);
```

### 6. Universal Affinity Debug Command

Location: Find where K key is currently handled (likely `obj_player/Step_0.gml` or debug controller)

Current implementation (assumed):
```gml
if (keyboard_check_pressed(ord("K"))) {
    // Only increases Canopy's affinity
}
```

New implementation:
```gml
if (keyboard_check_pressed(ord("K"))) {
    var companions = get_active_companions();
    show_debug_message("=== AFFINITY DEBUG (K) ===");
    for (var i = 0; i < array_length(companions); i++) {
        var companion = companions[i];
        companion.affinity = min(companion.affinity + 1, 10.0);
        show_debug_message(companion.companion_name + " affinity: " + string(companion.affinity));
        spawn_floating_text(companion.x, companion.bbox_top - 16,
            "Affinity: " + string(companion.affinity), c_yellow, companion);
    }
}
```

### 7. Damage Calculation Integration

Location: `obj_enemy_parent/Collision_obj_attack.gml`

Add companion notification after base damage calculation (around line 60, before final_damage calculation):

```gml
// Apply damage type resistance multiplier
var _resistance_multiplier = get_damage_modifier_for_type(_weapon_damage_type);

// Apply damage type resistance, then subtract damage resistance
var _final_damage = max(0, (_base_damage * _resistance_multiplier) - melee_damage_resistance);

// NEW: Notify companions of hit (adds on_hit_strike bonus damage)
var _bonus_damage = companion_on_player_hit(other.creator, id, _final_damage);
_final_damage += _bonus_damage;

hp -= _final_damage;
```

### 8. Testing Integration Points

Key files to modify:
1. `/scripts/scr_companion_system/scr_companion_system.gml` - Add new notification functions
2. `/objects/obj_companion_parent/Step_0.gml` - Add Yorna cooldown/unlock management
3. `/objects/obj_enemy_parent/Collision_obj_attack.gml` - Add companion hit notification
4. Find K key handler location - Update to affect all companions

Debug commands to verify:
- K key: increase affinity for all recruited companions
- Recruit Yorna and attack enemies to see On-Hit Strike
- Press K until affinity 8+, dash or crit to see Expose Weakness
- Press K until affinity 10, dash or crit to see Execution Window
