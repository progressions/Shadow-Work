# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-16-enemy-collision-chain-attacks/spec.md

> Created: 2025-10-16
> Status: Ready for Implementation

## Tasks

- [ ] 1. Implement Enemy Collision Damage System
  - [ ] 1.1 Add collision damage configuration variables to obj_enemy_parent Create event
  - [ ] 1.2 Create Collision_obj_player.gml event for obj_enemy_parent
  - [ ] 1.3 Implement full damage calculation pipeline (damage type, DR, traits, chip damage)
  - [ ] 1.4 Add knockback effect pushing player away from enemy
  - [ ] 1.5 Add collision damage cooldown decrement to obj_enemy_parent Step event
  - [ ] 1.6 Register Collision event in obj_enemy_parent.yy
  - [ ] 1.7 Test collision damage with different enemy types and damage configurations

- [ ] 2. Implement Player Invulnerability System
  - [ ] 2.1 Add invulnerability variables to obj_player Create event
  - [ ] 2.2 Create trigger_invulnerability() function in obj_player
  - [ ] 2.3 Add invulnerability timer countdown to obj_player Step event
  - [ ] 2.4 Implement visual feedback (flashing sprite) in obj_player Draw event
  - [ ] 2.5 Integrate invulnerability check into enemy collision damage
  - [ ] 2.6 Test invulnerability prevents multi-hit from same enemy
  - [ ] 2.7 Test visual flashing appears correctly during invulnerability

- [ ] 3. Implement Auxiliary-Based Damage Reduction
  - [ ] 3.1 Add auxiliary_dr_bonus configuration variable to obj_chain_boss_parent
  - [ ] 3.2 Modify obj_enemy_parent Collision_obj_attack to calculate auxiliary DR bonus
  - [ ] 3.3 Add auxiliary DR to total DR calculation pipeline
  - [ ] 3.4 Add debug message showing DR breakdown with auxiliary bonus
  - [ ] 3.5 Test boss takes reduced damage with 4 auxiliaries alive
  - [ ] 3.6 Test DR decreases as auxiliaries die
  - [ ] 3.7 Test boss becomes vulnerable when all auxiliaries defeated

- [ ] 4. Implement Chain Boss Throw Attack State Machine
  - [ ] 4.1 Add throw attack configuration variables to obj_chain_boss_parent Create event
  - [ ] 4.2 Add auxiliary_state variable to auxiliaries (set during spawn)
  - [ ] 4.3 Implement throw attack trigger logic in boss Step event
  - [ ] 4.4 Create handle_throw_attack() function (target selection, windup, launch)
  - [ ] 4.5 Implement auxiliary "thrown" state in auxiliary Step event (projectile movement)
  - [ ] 4.6 Implement auxiliary "returning" state (move back to boss)
  - [ ] 4.7 Enable collision damage with multiplier during thrown state
  - [ ] 4.8 Add throw attack cooldown decrement to boss Step event
  - [ ] 4.9 Test throw attack: auxiliary flies at player, damages on hit, returns to boss

- [ ] 5. Implement Chain Boss Spin Attack State Machine
  - [ ] 5.1 Add spin attack configuration variables to obj_chain_boss_parent Create event
  - [ ] 5.2 Implement spin attack trigger logic in boss Step event
  - [ ] 5.3 Create handle_spin_attack() function (orbital positioning calculation)
  - [ ] 5.4 Force auxiliaries to orbit at max chain length during spin
  - [ ] 5.5 Rotate boss sprite visually during spin (image_angle increment)
  - [ ] 5.6 Enable collision damage on all auxiliaries during spin
  - [ ] 5.7 Set auxiliaries to "returning" state when spin completes
  - [ ] 5.8 Add spin attack cooldown decrement to boss Step event
  - [ ] 5.9 Test spin attack: boss rotates, auxiliaries orbit, damage player on contact

- [ ] 6. Visual and Audio Polish
  - [ ] 6.1 Add throw attack windup animation or visual telegraph
  - [ ] 6.2 Add spin attack sound effect (whoosh/wind sound)
  - [ ] 6.3 Ensure chains render taut during throw and spin attacks
  - [ ] 6.4 Add particle effects for throw impact
  - [ ] 6.5 Test all visual feedback looks correct in actual gameplay

- [ ] 7. Configure Example Enemies with Collision Damage
  - [ ] 7.1 Enable collision damage on obj_fire_imp (2 damage, fire type)
  - [ ] 7.2 Configure obj_chain_boss with throw and spin attacks
  - [ ] 7.3 Set auxiliary_dr_bonus on chain boss (2 DR per auxiliary)
  - [ ] 7.4 Test complete chain boss fight with all new mechanics
  - [ ] 7.5 Balance collision damage values and cooldowns based on gameplay feel

- [ ] 8. Edge Cases and Bug Fixes
  - [ ] 8.1 Test thrown auxiliary hits wall - returns correctly
  - [ ] 8.2 Test spin attack with only 1 auxiliary alive
  - [ ] 8.3 Test auxiliary dies while in "thrown" state
  - [ ] 8.4 Test player invulnerability works with multiple collision sources
  - [ ] 8.5 Test auxiliary DR calculation when boss has 0 auxiliaries
  - [ ] 8.6 Verify collision damage respects player dead state
