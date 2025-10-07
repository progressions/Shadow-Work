# Status Effects (Trait-Driven)

## Overview

Status effects are now implemented as trait definitions that apply timed stacks. Instead of the old `status_effects` array, each instance tracks an array of timed trait entries (`timed_traits`) managed by `traits/trait_system.gml`. Every effect—burning, wet, empowered, weakened, swift, slowed, and poisoned—is defined in `objects/obj_game_controller/Create_0.gml` with metadata describing durations, modifiers, and visual presentation.

Key advantages:

- **Single source of truth** – resistances, buffs, and debuffs all live in `global.trait_database`.
- **Stack-aware** – traits share the same stacking and cancellation rules as elemental resistances.
- **Timed by default** – the trait system refreshes timers, applies DoT, and cleans up expired stacks.
- **UI ready** – draw helpers consume timed trait data and render duration bars/icons for any configured trait.

## Trait Definitions

Each status effect is a trait entry with optional fields:

```gml
burning: {
    name: "Burning",
    default_duration: 3,             // Seconds
    tick_damage: 1,
    tick_rate_seconds: 0.5,          // Damage every 0.5s
    damage_type: DamageType.fire,
    opposite_trait: "wet",
    max_stacks: 5,
    ui_color: c_red,
    show_feedback: true,
    blocked_by: ["fire_immunity"]
},
wet: {
    name: "Wet",
    default_duration: 5,
    modifiers: {speed: 0.9},         // Multiplier per effective stack
    opposite_trait: "burning",
    max_stacks: 5,
    ui_color: c_blue,
    show_feedback: true
},
```

Supported keys:

- `default_duration` (seconds) – used when no override is provided.
- `tick_damage` + `tick_rate_seconds` – automatic DoT application.
- `modifiers` – per-stack multipliers (e.g., `speed`, `damage`).
- `opposite_trait` – enables stack-by-stack cancellation (`swift` vs `slowed`).
- `ui_color`, `icon_sprite`, `show_feedback` – drive visual feedback.
- `blocked_by` – optional trait keys that prevent the effect from being applied.

## Application Flow

1. **Configuration sources**
   - Weapons/items: `status_effects` arrays in item stats (`scripts/scr_item_database.gml`), normalized by `get_weapon_status_effects`.
   - Hazards: `effect_type = "status"` plus a trait key (`objects/obj_hazard_parent`).
   - Scripts/abilities: direct calls to `apply_status_effect`.

2. **Entry normalization**
   - `status_effect_normalize_entry` converts legacy `{effect: StatusEffectType.burning}` structs to `{trait: "burning", chance, stacks, duration}`.

3. **Application**
   - `apply_status_effect()` resolves the trait key, merges stacks, and uses `apply_timed_trait` or `add_temporary_trait` depending on duration.
   - `apply_timed_trait()` clamps stacks, respects immunities (`blocked_by`), creates/refreshes `timed_traits` entries, and calls `status_effect_spawn_feedback`.

4. **Ticking**
   - `update_timed_traits()` (invoked via `tick_status_effects`) refreshes timers, applies DoT using either `tick_rate_seconds` or `tick_rate`, and removes expired stacks via `remove_temporary_trait`.

## Getting Modifiers

Use `get_trait_modifier("speed")` or `get_trait_modifier("damage")` to obtain multiplicative modifiers that include status effects. This replaces the old `get_status_effect_modifier` logic. The helper automatically accounts for opposing traits—for example, `slowed` stacks cancel `swift` stacks before applying multipliers.

## UI & Feedback

- `get_active_timed_trait_data()` returns an array of `{trait, remaining, total, stacks, effective_stacks}` entries for any actor.
- `objects/obj_player/Draw_0.gml` and `objects/obj_enemy_parent/Draw_0.gml` use these entries to draw duration bars with colors from `ui_color`.
- `ui_draw_status_effects` (in `scripts/scr_ui_functions.gml`) draws icon rectangles/sprites and duration bars for any actor.
- `status_effect_spawn_feedback` spawns floating text when `show_feedback` is true and `ui_color` is defined.

## Adding a New Status Effect

1. **Define the trait** in `global.trait_database` with the fields described above.
2. **Reference it** in weapons, hazards, abilities, or scripts using the trait key string (e.g., `"bleeding"`).
3. **Update UI** (optional) by providing `ui_color` and `icon_sprite`.
4. **Leverage modifiers** by adding entries to the trait’s `modifiers` struct or DoT parameters.

Because status effects now share infrastructure with all other traits, there is no separate status-effect array to maintain—timers, stacking, serialization, and UI all flow through the trait system.
