# Openable Containers - Lite Summary

Implement an inheritable openable container system that plays a 4-frame opening animation when the player presses SPACE nearby, then spawns configured loot items. Containers can be configured to drop specific items, random items from a weighted loot table, or a variable quantity (1-X) of items. The system integrates with existing loot spawning logic and save/load persistence.

## Key Points
- Parent object (`obj_container_parent`) with 4-frame opening animation
- Configurable loot tables supporting specific items, random selection, and variable quantities
- Integration with existing `spawn_loot()` system
- Save/load persistence to track opened containers
- SPACE key interaction when player is nearby
