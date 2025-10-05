# Spec Summary (Lite)

Implement combat evasion state for companions that causes them to automatically move away from the player and enemies during active combat, reducing visual clutter and improving tactical positioning. Companions use pathfinding to maintain 64-128 pixel distance from player and enemies when a combat timer is active (triggered by player taking/dealing damage), then smoothly return to following behavior after 3-5 seconds of combat inactivity.
