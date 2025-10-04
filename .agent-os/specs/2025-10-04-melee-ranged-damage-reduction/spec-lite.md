# Spec Summary (Lite)

Implement separate melee and ranged damage reduction stats that can be modified by equipment, traits, status effects, and companion auras. Shields will provide higher ranged DR than melee DR, and Hola's aura will specifically reduce ranged damage. All attacks (obj_attack, obj_arrow, obj_enemy_attack, obj_enemy_arrow) will be categorized as melee or ranged to determine which DR value applies during damage calculation.
