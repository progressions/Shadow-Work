# Chain Boss System - Lite Summary

Implement a reusable boss enemy system where a central boss (32x32px) is visually connected to 2-5 smaller auxiliary enemies (16x16px) via dynamic chain sprites that react to distance. Auxiliaries chase the player within configurable chain length, with chains visually sagging when slack and stretching taut at maximum distance. When all auxiliaries are defeated, the boss enters an enraged phase with increased attack speed, movement, and aggression.

## Key Points
- Central boss (32x32px) connected to 2-5 auxiliary enemies (16x16px) via dynamic chain sprites
- Chains react visually to distance: sagging when slack, stretching taut at maximum length
- Auxiliaries chase player within configurable chain length constraint (default 128-192px)
- Boss enters enraged phase when all auxiliaries defeated: +50% attack speed, +30% movement speed, increased aggression weights
- Reusable system via `obj_chain_boss_controller` parent with configurable parameters (chain length, sag amount, enrage multipliers)
