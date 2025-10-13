# Spec Summary (Lite)

Implement a hazard spawning attack system that allows enemies to launch projectiles that create persistent area-of-effect hazards (fire pools, poison clouds) at their landing points. Enemies perform a windup animation, launch a projectile that travels a configured distance, and spawn a hazard object at the landing point that damages players on contact. This system supports both dedicated hazard-spawning enemies and multi-attack boss patterns with configurable cooldowns, projectile/hazard types, travel distance, damage, and direction.
