# Spec Summary (Lite)

Implement a casting animation state for companions that plays directional 3-frame casting animations when their triggers activate. Companions will stop moving during casting, play the animation corresponding to their facing direction, and automatically return to following state when complete. Update `CompanionState` enum to use `waiting`, `following`, and `casting` values for clear state management.
