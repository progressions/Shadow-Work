# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-07-projectile-range-falloff/spec.md

## Technical Requirements

### 1. Range Profile Definitions

- Create `scripts/projectile_range_profiles/projectile_range_profiles.gml` that initializes `global.projectile_range_profiles` at game start.
- Use an enum `RangeProfile` to enumerate profile keys (`generic_arrow`, `wooden_bow`, `longbow`, `crossbow`, `heavy_crossbow`, `enemy_shortbow`).
- Each profile struct exposes:
  - `point_blank_distance` (pixels before the linear ramp to 1.0 begins)
  - `point_blank_multiplier` (damage at distance 0)
  - `optimal_start` / `optimal_end` (inclusive band in pixels where multiplier stays at 1.0)
  - `max_distance` (pixels where falloff finishes; projectiles may be culled after a small buffer)
  - `long_range_multiplier` (damage multiplier once past `max_distance`)
  - `overshoot_buffer` (pixels beyond `max_distance` before auto-destroy, default 32)
- Provide helper functions:
  ```gml
  function projectile_get_range_profile(_profile_id) {
      return struct_copy(global.projectile_range_profiles[$ _profile_id]);
  }

  function projectile_calculate_damage_multiplier(_profile, _distance) {
      if (_distance <= _profile.point_blank_distance) {
          return lerp(_profile.point_blank_multiplier, 1.0, _distance / max(1, _profile.point_blank_distance));
      }
      if (_distance <= _profile.optimal_end) {
          return 1.0;
      }

      var _falloff_span = max(1, _profile.max_distance - _profile.optimal_end);
      var _falloff_t = clamp((_distance - _profile.optimal_end) / _falloff_span, 0, 1);
      return lerp(1.0, _profile.long_range_multiplier, _falloff_t);
  }
  ```
- Populate initial profiles (distances are in pixels; 16 px ≈ 1 tile):
  - `RangeProfile.generic_arrow`: pb_dist 32, pb_mult 0.7, optimal 96–144, max 224, far_mult 0.55, buffer 32.
  - `RangeProfile.wooden_bow`: pb_dist 32, pb_mult 0.6, optimal 96–160, max 240, far_mult 0.5, buffer 32.
  - `RangeProfile.longbow`: pb_dist 48, pb_mult 0.5, optimal 160–260, max 340, far_mult 0.6, buffer 48.
  - `RangeProfile.crossbow`: pb_dist 24, pb_mult 0.55, optimal 64–120, max 200, far_mult 0.4, buffer 24.
  - `RangeProfile.heavy_crossbow`: pb_dist 32, pb_mult 0.6, optimal 96–160, max 260, far_mult 0.5, buffer 32.
  - `RangeProfile.enemy_shortbow`: pb_dist 32, pb_mult 0.65, optimal 80–140, max 220, far_mult 0.55, buffer 32.

### 2. Item Database Integration

- Extend `create_item_definition` (scripts/scr_item_database/scr_item_database.gml) to copy `range_profile` and optional `range_profile_override` values from the `_stats` struct onto the item definition for quick access.
- Update ranged weapon entries so each bow references the intended profile:
  ```gml
  {damage: 2, attack_speed: 1.2, range: 120, requires_ammo: "arrows",
   range_profile: RangeProfile.wooden_bow, ...}
  ```
- For weapons without a `range_profile`, default to `RangeProfile.generic_arrow` at runtime.
- Store enemy projectile defaults in the relevant enemy attack scripts (e.g., `obj_enemy_archer`) by assigning `RangeProfile.enemy_shortbow` to the projectile they spawn.

### 3. Projectile Spawn Setup

- Update `scripts/player_attacking/player_attacking.gml` when instantiating `obj_arrow`:
  - Capture the equipped weapon’s `range_profile` (or fallback) and assign it to `_arrow.range_profile_id`.
  - Store `_arrow.spawn_x = _arrow.x;` and `_arrow.spawn_y = _arrow.y;`
  - Set `_arrow.max_travel_distance = projectile_get_range_profile(_profile).max_distance + overshoot_buffer`.
  - Persist `_arrow.weapon_range_stat = _weapon_stats.range;` for future tuning comparisons.
- Ensure enemy projectile spawners assign the same fields (`range_profile_id`, `spawn_x`, `spawn_y`, `max_travel_distance`).

### 4. Distance Multiplier Application

- In `objects/obj_arrow/Create_0.gml`:
  - Initialize `spawn_x`, `spawn_y`, `range_profile = projectile_get_range_profile(range_profile_id ?? RangeProfile.generic_arrow)`, and `current_damage_multiplier = 1.0`.
- In `objects/obj_arrow/Step_0.gml` before collision checks:
  - Compute `var _distance = point_distance(spawn_x, spawn_y, x, y);`
  - Update `current_damage_multiplier = projectile_calculate_damage_multiplier(range_profile, _distance);`
  - If `_distance > range_profile.max_distance + range_profile.overshoot_buffer`, destroy the projectile.
- When resolving enemy collision:
  - Multiply the stored `damage` by `current_damage_multiplier` prior to subtracting ranged DR.
  - Store the multiplier on the target (e.g., `_hit_enemy.last_projectile_multiplier = current_damage_multiplier;`) for optional analytics.
- Apply the same pattern to `objects/obj_enemy_arrow/Create_0.gml` and `Step_0.gml`, using the assigned `range_profile_id`.
- For any other projectile templates (fireballs, thrown knives) that should participate, add the same fields and helper calls.

### 5. Debug Feedback Hooks

- When `global.debug_mode` is true, have projectiles call `show_debug_message` (or populate an existing debug overlay) with `{weapon_id, distance, multiplier}` each time the multiplier tier changes.
- Optionally tint damage numbers by scaling their alpha (e.g., alpha 0.8 for <1.0, alpha 1.2 clamped for >1.0) by extending `spawn_damage_number` to accept an optional `_alpha_override`.
- Ensure debug output is wrapped in `if (variable_global_exists("debug_mode") && global.debug_mode)` gates to avoid shipping noise.

