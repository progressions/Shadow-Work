# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-15-chain-boss-system/spec.md

> Created: 2025-10-15
> Status: Ready for Implementation

## Tasks

- [ ] 1. Create Chain Boss Parent Object and Configuration System
  - [ ] 1.1 Create obj_chain_boss_parent inheriting from obj_enemy_parent
  - [ ] 1.2 Add configuration variables (auxiliary_count, auxiliary_object, chain_max_length, chain_sprite)
  - [ ] 1.3 Add enrage multiplier variables (attack_speed, move_speed, damage multipliers)
  - [ ] 1.4 Initialize state tracking arrays (auxiliaries[], chain_data[]) and counters (auxiliaries_alive, is_enraged)
  - [ ] 1.5 Add object definition to Shadow Work.yyp
  - [ ] 1.6 Test boss spawns correctly with default configuration

- [ ] 2. Implement Auxiliary Spawn System
  - [ ] 2.1 Create auxiliary spawn logic in boss Create event (circular formation)
  - [ ] 2.2 Set bidirectional references (auxiliary.chain_boss = boss, boss.auxiliaries[] array)
  - [ ] 2.3 Initialize chain_data[] structs for each auxiliary
  - [ ] 2.4 Ensure auxiliaries spawn at half chain_max_length radius
  - [ ] 2.5 Test spawning with different auxiliary_count values (2, 3, 4, 5)

- [ ] 3. Implement Distance Constraint System
  - [ ] 3.1 Add chain_boss variable to auxiliary enemy objects
  - [ ] 3.2 Implement distance clamping in auxiliary Step event (after movement)
  - [ ] 3.3 Add pathfinding cleanup when auxiliary hits chain limit
  - [ ] 3.4 Test auxiliaries cannot exceed chain_max_length from boss
  - [ ] 3.5 Test auxiliaries can move freely within chain range while chasing player

- [ ] 4. Implement Chain Rendering System
  - [ ] 4.1 Create chain sprite (2px × 8px vertical chain link texture)
  - [ ] 4.2 Implement draw_chain_segment() helper function (stretching and rotation)
  - [ ] 4.3 Add chain drawing logic in boss Draw event (for each auxiliary)
  - [ ] 4.4 Implement tension calculation (distance ratio, sag amount based on slack)
  - [ ] 4.5 Draw chains as two segments (boss → sag midpoint → auxiliary)
  - [ ] 4.6 Test chains render correctly and react to auxiliary distance (sag when close, taut when far)

- [ ] 5. Implement Enrage Phase System
  - [ ] 5.1 Add enrage trigger check in boss Step event (auxiliaries_alive <= 0)
  - [ ] 5.2 Apply stat multipliers when entering enrage (attack_speed, move_speed, attack_damage)
  - [ ] 5.3 Add visual feedback (image_blend = c_red) and optional sound effect
  - [ ] 5.4 Implement auxiliary death notification in auxiliary Destroy event
  - [ ] 5.5 Update boss arrays (remove dead auxiliary from auxiliaries[] and chain_data[])
  - [ ] 5.6 Test enrage triggers correctly when last auxiliary dies
  - [ ] 5.7 Test boss stats increase visibly (faster attacks, faster movement)

- [ ] 6. Create Example Chain Boss Implementation
  - [ ] 6.1 Create obj_chain_boss_fire (or similar concrete boss type)
  - [ ] 6.2 Configure with specific values (4 auxiliaries, 96px chains, fire theme)
  - [ ] 6.3 Assign auxiliary_object to appropriate enemy type
  - [ ] 6.4 Set enrage multipliers and chain sprite
  - [ ] 6.5 Place in test room and verify full combat encounter
  - [ ] 6.6 Test complete boss fight: auxiliaries chase player, chains constrain movement, enrage triggers on defeat

- [ ] 7. Polish and Performance Testing
  - [ ] 7.1 Verify chain rendering performance with multiple bosses
  - [ ] 7.2 Test edge cases (boss dies before auxiliaries, auxiliaries stuck on walls)
  - [ ] 7.3 Add debug visualization option for chain constraint radius
  - [ ] 7.4 Ensure system is reusable (different bosses with different configurations)
  - [ ] 7.5 Final in-game testing of complete feature
