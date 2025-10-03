# Spec Summary (Lite)

Implement a weighted loot table system that allows enemies to drop items when killed with configurable drop rates and item probabilities. Each enemy type has a drop_chance (0.0-1.0) and a loot table containing item keys with optional weights, defaulting to equal probability when weights are omitted. Dropped items spawn near the enemy's death location with 16px scatter on walkable terrain.
