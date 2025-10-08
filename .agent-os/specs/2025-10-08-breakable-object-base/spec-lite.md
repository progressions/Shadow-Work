# Breakable Object Base – Lite Summary

Create a reusable breakable object framework that hooks melee attacks into destructible environmental props. `obj_breakable` handles HP, animation state, melee-only damage checks, particle bursts, and persistence, while child objects (starting with `obj_breakable_grass`) supply sprites, durability, and debris styling.

## Key Points
- Parent `obj_breakable` with Create/Step/Collision events and idle → breaking state machine
- Uses frames 0‑3 for idle loop and 4‑7 for the one-shot break animation from `breakable_grass.png`
- Damage only when `obj_attack` overlaps; ignore `obj_arrow` and other projectiles
- Spawn themed particle bursts and destroy instance when break animation finishes
- Persist broken state through `obj_persistent_parent` serialization so props stay gone
