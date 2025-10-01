# Spec Summary (Lite)

Implement a 5-slot save/load system using JSON serialization that captures complete game state including player stats/inventory, companion affinity/quest flags/triggers, enemy states with position/HP/traits/status effects, NPC dialogue progress, quest flags, and room state persistence. The system includes auto-save on room transitions and stores room states in a global collection so enemies, items, and puzzles persist across room visits.
