# Enemy Ranged Attack Windup System - Lite Summary

Implement configurable windup system for enemy ranged attacks with slower animation speed and two-stage sound feedback (windup sound → projectile spawn + attack sound). Allows per-enemy configuration of windup speed (default 0.5 = half-speed) and sounds, improving combat readability and difficulty balance.

## Key Points
- Ranged attacks play at configurable slower speed during windup phase (default 0.5x speed)
- Two-stage audio feedback: windup sound at animation start, attack sound at projectile spawn
- Per-enemy configuration via `ranged_windup_speed` property and `enemy_sounds.on_ranged_windup`
- Projectile spawns after first animation cycle completes (not at state entry)
- Backward compatible with all existing ranged enemies using sensible defaults
