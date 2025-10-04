# Spec Summary (Lite)

Implement a centralized interaction manager that prevents multiple interactive objects from responding to the same SPACE key press. Uses priority-based selection (companions > quest markers > chests > doors) combined with distance to determine which single object should display an interaction prompt and respond to input.
