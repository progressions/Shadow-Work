# Spec Summary (Lite)

Implement a configurable tile-based terrain effects system that applies temporary traits (burning, poisoned) and speed modifiers when entities stand on specific tiles. The system uses a centralized database to map terrain types to effects, applies traits once on entry with duration refresh, and integrates with enemy pathfinding to avoid hazardous terrains unless the enemy has trait immunity.
