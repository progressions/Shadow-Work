# Projectile Range Profile Test Plan

This doc tracks the verification steps for the projectile range falloff helpers. Run these checks through the debug console or by calling `projectile_range_profiles_self_test()` once the helper module is loaded.

## Baseline Expectations

- Each range profile interpolates linearly from the point-blank modifier up to 1.0x by the end of its point-blank distance.
- Damage stays at 1.0x throughout the optimal band (`optimal_start` through `optimal_end`).
- Beyond the optimal band, damage falls toward `long_range_multiplier` and clamps there once `max_distance` is reached.
- Projectiles should flag for cleanup shortly after `max_distance + overshoot_buffer`.

## Manual Verification Steps

1. Toggle `global.debug_mode = true;` in the console or Room Start event.
2. Call `projectile_range_profiles_self_test();`
3. Confirm the console output logs three checkpoints per profile:
   - `PB` (point-blank distance) multiplier equals the configured `point_blank_multiplier`.
   - `OPT` (mid-point within optimal band) multiplier equals `1.0`.
   - `FAR` (beyond max distance) multiplier equals the configured `long_range_multiplier`.
4. Review the returned result struct to verify all `passed` flags are true. Any failing sample will include the observed vs expected value to help with tuning.
5. Optionally, call `projectile_debug_collect_range_samples(<profile_id>, [distances...]);` to spot-check specific travel distances while tuning values.

Re-run these steps after any adjustments to range profiles or helper math.
