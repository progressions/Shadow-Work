# Spec Summary (Lite)

Implement a grid-based pathfinding system for enemies using GameMaker's mp_grid functions, enabling intelligent navigation around obstacles and sophisticated AI behaviors. Ranged enemies will use pathfinding to maintain optimal attack distance and circle strafe, while all enemies will move faster on terrain types matching their traits (aquatic on water, fireborne on fire tiles, etc.). The system supports up to 15 enemies per room with debug visualization and uses a new EnemyState.targeting state for pathfinding behavior.
