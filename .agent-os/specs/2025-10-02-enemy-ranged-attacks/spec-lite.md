# Spec Summary (Lite)

Implement a reusable ranged attack system for enemies that allows them to fire projectiles at the player using the existing `obj_enemy_arrow` object. The system will be configured through simple properties on `obj_enemy_parent` (`is_ranged_attacker`, `ranged_damage`, `ranged_attack_cooldown`) and a new `EnemyState.ranged_attacking` state. The Greenwood Bandit will serve as the first implementation, and the architecture is designed to support future hybrid ranged/melee enemy behaviors.
