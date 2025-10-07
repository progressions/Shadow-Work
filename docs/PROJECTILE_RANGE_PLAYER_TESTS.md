# Player Projectile Range Test Plan

Use this checklist to confirm that player-fired arrows respect the new distance-based damage modifiers.

## Setup

1. Launch a test room with plenty of open space (e.g., `room_initial`).
2. Enable developer instrumentation by setting `global.debug_mode = true;` in a Room Start event or the debugger console.
3. Equip each bow type (wooden bow, longbow, crossbow, heavy crossbow) and give yourself sufficient arrows.

## Test Steps

### Baseline Multiplier Logging

1. Stand still and fire an arrow straight ahead.
2. In the debug console, call `projectile_debug_collect_range_samples(RangeProfile.longbow, [0, 64, 128, 192, 256, 320]);` to review expected multipliers for comparison.
3. Observe the console/IDE output from the projectile (emitted when `global.debug_mode` is true) to confirm distance and active multiplier updates as the arrow travels.

### Longbow Far-Damage Verification

1. Using the longbow, measure tiles to an enemy dummy (or target object) roughly 10 tiles away (~160 px).
2. Fire from three ranges: 1 tile (point-blank), within the optimal band (10 tiles), and at 14+ tiles (beyond optimal).
3. Compare the damage numbers:
   - Point-blank should read ~50–60% of the optimal hit.
   - Optimal range should show 1.0x (baseline).
   - Very far shots should drop toward ~0.6x.

### Crossbow Close-Range Verification

1. Equip the crossbow and repeat the three-distance test at 1, 5, and 12 tiles.
2. Confirm the crossbow produces its highest damage near 4–7 tiles and tails off more sharply past 12 tiles.

### Heavy Crossbow Consistency

1. Equip the heavy crossbow and fire at 1, 6, and 11 tiles.
2. Ensure damage aligns with the configured profile (point-blank reduction, optimal plateau, soft falloff).

### Regression Sweep

1. Confirm melee attacks still produce the same damage numbers as before.
2. Fire arrows with `global.debug_mode = false;` to verify no debug output or visual artifacts leak into normal gameplay.

Document any deviations from expected multipliers and include distance + damage readings for follow-up tuning.
