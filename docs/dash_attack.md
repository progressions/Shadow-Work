# Dash Attack System Overview

The dash attack lets the player turn a mobility burst into a close–quarters strike by damaging the foes they pass through. This document explains the runtime flow, scaling hooks, and tuning levers that drive the feature.

## When the Dash Attack Triggers

- Pressing the dash input calls `start_dash`, which kicks off the normal movement burst and invokes `player_dash_begin`.
- `player_dash_begin`:
  - Clears or creates the `dash_hit_enemies` list so each dash tracks fresh contacts.
  - Resets `dash_hit_count`, impact SFX flags, and rolls the target cap via `player_get_dash_target_cap`.
  - Flags whether a companion multi‑target bonus (currently Yorna’s aura) triggered for this dash.
- Each Step while `PlayerState.dashing`:
  - The player moves via `move_and_collide`.
  - The previous position is cached and passed to `player_dash_handle_collisions`.
- A dash ends naturally (timer expires) or early (stagger/stun). In both cases `player_dash_end` clears lists and resets counters.

## How Collision Damage Works

`player_dash_handle_collisions` walks every live instance of `obj_enemy_parent` once per frame and applies three filters before a hit can land:

1. Has this enemy already been struck this dash? (tracked in `dash_hit_enemies`)
2. Is the enemy dead or in post‑hit invulnerability (`alarm[1]` ≥ 0)?
3. Does the enemy overlap the dash path?
   - First check bounding box intersection at the new position.
   - If not, run `collision_line` between the previous and current player coordinates to catch tunnelling cases.

When all checks pass:

- The helper flips the player’s `is_dash_attacking` flag momentarily and calls `get_total_damage()`. This bakes in:
  - Weapon stats, dash damage multiplier, status bonuses.
  - Crit chance and multiplier (a crit dash plays the crit feedback pipeline).
  - Execution Window bonuses and armor pierce.
- A structured payload is handed to `player_attack_apply_damage`, which executes the shared melee/ranged damage routine:
  - Damage type mitigation via trait stacks.
  - DR subtraction (melee for dash hits) minus Execution Window pierce.
  - Companion hooks (`companion_on_player_hit`, status effect bonuses) when the attacker is the player.
  - Stun/stagger rolls and weapon status effect application (right/left hand).
  - Knockback, visual feedback, freeze frames, loot/XP rolls, quest counters.
- The first confirmed hit plays `snd_dash_attack`, and the combat timer is reset so companions recognise active combat.
- After each strike `dash_hit_count` increments; once it reaches `dash_target_cap` the helper stops processing further enemies this frame.

## Target Cap and Scaling Rules

### Base Targets by Player Level

| Player Level | Base Targets |
|--------------|--------------|
| 1 – 4        | 1            |
| 5 – 9        | 2            |
| 10 – 14      | 3            |
| 15+          | 4            |

### Companion Aura Boosts

- `player_get_dash_target_cap` queries `get_companion_multi_target_params`.
- Currently only Yorna’s **Warriors Presence** aura populates this struct.
  - On a successful proc the dash’s `dash_multi_bonus_active` flag is set and `dash_target_cap` is raised to at least the aura’s `max_targets`.
  - The aura never reduces the level‑based cap—it only raises it when the chance roll succeeds.

### Damage Scaling Summary

- Dash strikes use the same `get_total_damage` output as a melee attack during the dash window, so any system that modifies the player’s melee damage (weapon upgrades, execution window, temporary traits, companion attack buffs) automatically applies.
- Crit chance and multiplier come directly from the player stats; crit dashes trigger the extended flash/freeze feedback just like crit weapon swings.
- Execution Window adds both the damage multiplier and the armor pierce stored in `get_execution_window_armor_pierce`.

## Status Effects and Crowd Control

- Weapon status effects from either hand can proc on dash hits (the helper checks both right and left hand definitions if the attacker exposes an `equipped` struct).
- `process_attack_cc_effects` runs using the same weapon stats package, allowing dash attacks to stun or stagger when the weapon supports it.
- Dash hits respect enemy `stun_resistance` and `stagger_resistance` values; no special bypass is applied.

## Implementation Touchpoints

| Script/Event                                      | Responsibility |
|---------------------------------------------------|----------------|
| `objects/obj_player/Create_0`                     | Seeds dash tracking variables, injects `player_dash_begin` call. |
| `player_dash_begin`, `player_dash_end`            | Manage per-dash state, hit lists, and target rolls. |
| `player_state_dashing`                            | Captures pre-move position, calls `player_dash_handle_collisions`, resets tracking on exit. |
| `player_dash_handle_collisions`                   | Detects dash brushes and fires the shared damage helper. |
| `player_attack_apply_damage`                      | Shared combat resolution, now tolerant of non-player attackers and missing equipment structs. |
| `obj_enemy_parent/Collision_obj_attack`           | Uses the same helper for traditional melee swings, ensuring consistent damage semantics. |

## Tuning Notes

- **Target caps** are currently stepped by level and boosted by companion procs. Adjusting the thresholds or introducing new affinity breakpoints only requires editing `player_get_dash_target_cap`.
- **Enemy immunity windows** are respected via `alarm[1]`; reducing that alarm lets enemies take damage from every frame of a dash, while raising it makes them briefly invulnerable to rapid hits.
- **Sound/feedback**: Only the first enemy hit per dash plays `snd_dash_attack` to avoid audio spam. Duplicate hits still spawn damage numbers and hit sparks per enemy.
- **Companion integration**: Any new companion aura that needs to influence dash behaviour should extend `get_companion_multi_target_params` or add logic inside `player_dash_handle_collisions` before the helper call.

Use this reference when adjusting dash balance, adding new weapons, or wiring additional companion bonuses so the mechanic stays coherent with the rest of the combat system.  
