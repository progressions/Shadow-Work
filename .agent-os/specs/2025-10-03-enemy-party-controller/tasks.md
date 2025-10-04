# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-03-enemy-party-controller/spec.md

> Created: 2025-10-03
> Status: Ready for Implementation

## Tasks

- [ ] 1. Create Party Controller Foundation
  - [ ] 1.1 Create `obj_enemy_party_controller` object with Create event
  - [ ] 1.2 Add party member tracking properties (party_members array, party_leader, initial_party_size)
  - [ ] 1.3 Add formation properties (formation_template string, formation_data struct)
  - [ ] 1.4 Add protection properties (protect_x, protect_y, protect_radius)
  - [ ] 1.5 Create PartyState enum in scripts (protecting, aggressive, cautious, desperate, emboldened, retreating)
  - [ ] 1.6 Add party_state property and state transition thresholds (desperate_threshold, cautious_threshold, emboldened_player_hp_threshold)
  - [ ] 1.7 Add decision weight properties (weight_attack, weight_formation, weight_flee, weight_modifiers struct)

- [ ] 2. Implement Formation System
  - [ ] 2.1 Create `global.formation_database` in game controller with formation templates (line_3, wedge_5, circle_4, protective_3)
  - [ ] 2.2 Implement `init_party(enemy_array, formation_template_key)` function to initialize party with enemies
  - [ ] 2.3 Implement `assign_formation_roles()` function to assign roles and offsets to party members
  - [ ] 2.4 Implement `get_formation_position(enemy_instance)` function to calculate target formation coordinates
  - [ ] 2.5 Add procedural formation adjustment logic for when party size doesn't match template max_members
  - [ ] 2.6 Test formation assignment and position calculation with different party sizes

- [ ] 3. Implement Party State Machine
  - [ ] 3.1 Implement `update_party_state()` function with state transition logic
  - [ ] 3.2 Implement `get_party_survival_percentage()` helper function
  - [ ] 3.3 Add Step event to party controller that calls `update_party_state()` each frame
  - [ ] 3.4 Implement `transition_to_state(new_state)` function to handle state changes
  - [ ] 3.5 Add audio feedback on state transitions (snd_party_aggressive, snd_party_cautious, snd_party_desperate, snd_party_retreat)
  - [ ] 3.6 Test state transitions by simulating different party survival and player HP scenarios

- [ ] 4. Implement Weighted Decision System
  - [ ] 4.1 Add party_controller reference property to `obj_enemy_parent`
  - [ ] 4.2 Add objective tracking properties to enemies (current_objective, objective_target_x, objective_target_y, formation_target_x, formation_target_y)
  - [ ] 4.3 Implement `calculate_decision_weights(enemy_instance)` function in party controller
  - [ ] 4.4 Integrate weight calculation into enemy Step event to set current objective
  - [ ] 4.5 Modify enemy pathfinding logic to use objective_target_x/y instead of always targeting player
  - [ ] 4.6 Implement flee behavior (calculate flee_target_x/y away from player)
  - [ ] 4.7 Test weight modifiers respond correctly to party survival, player HP, enemy HP, and distance from formation
  - [ ] 4.8 Verify enemies switch between attack/formation/flee objectives dynamically

- [ ] 5. Implement Party Member Management
  - [ ] 5.1 Implement `on_member_death(enemy_instance)` function to remove dead enemies from party_members array
  - [ ] 5.2 Call `on_member_death()` from enemy death event when enemy belongs to a party
  - [ ] 5.3 Implement formation reassignment when party size changes
  - [ ] 5.4 Implement `on_leader_death()` virtual function (placeholder, can be overridden by child controllers)
  - [ ] 5.5 Check if dead enemy is party leader and call `on_leader_death()` if true
  - [ ] 5.6 Test party behavior adapts correctly as members are killed

- [ ] 6. Implement Save/Load Integration
  - [ ] 6.1 Implement `serialize_party_data()` function to return save struct
  - [ ] 6.2 Implement `deserialize_party_data(data)` function to restore party from struct
  - [ ] 6.3 Add UUID references to enemies for save/load linkage
  - [ ] 6.4 Integrate party controller serialization into room save data in existing save system
  - [ ] 6.5 Test saving and loading a room with active party controllers, verify state and members persist correctly

- [ ] 7. Implement Debug Visualization
  - [ ] 7.1 Add Draw event to `obj_enemy_party_controller`
  - [ ] 7.2 Draw formation positions (circles) and lines connecting enemies to their formation targets when `global.debug_mode == true`
  - [ ] 7.3 Draw party state text and member count above controller position
  - [ ] 7.4 Draw protection radius circle when in protecting state
  - [ ] 7.5 Test debug visualization displays correctly for different party states and formations

- [ ] 8. Create Example Party Controllers and Test Scenarios
  - [ ] 8.1 Create child object `obj_orc_raiding_party` inheriting from `obj_enemy_party_controller` with aggressive configuration
  - [ ] 8.2 Create child object `obj_gate_guard_party` inheriting from `obj_enemy_party_controller` with protecting configuration
  - [ ] 8.3 Place test parties in a test room with various enemy types and formations
  - [ ] 8.4 Test aggressive party behavior (chase and attack player)
  - [ ] 8.5 Test protecting party behavior (guard location, limited pursuit)
  - [ ] 8.6 Test state transitions (cautious after casualties, desperate with few survivors, emboldened when player is weak)
  - [ ] 8.7 Test mixed enemy type parties (melee and ranged in same party)
  - [ ] 8.8 Verify all major features work end-to-end (formations, weights, states, save/load, audio, debug viz)
