# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-03-enemy-party-controller/spec.md

> Created: 2025-10-03
> Status: IMPLEMENTATION COMPLETE

## Tasks

- [x] 1. Create Party Controller Foundation
  - [x] 1.1 Create `obj_enemy_party_controller` object with Create event
  - [x] 1.2 Add party member tracking properties (party_members array, party_leader, initial_party_size)
  - [x] 1.3 Add formation properties (formation_template string, formation_data struct)
  - [x] 1.4 Add protection properties (protect_x, protect_y, protect_radius)
  - [x] 1.5 Create PartyState enum in scripts (protecting, aggressive, cautious, desperate, emboldened, retreating)
  - [x] 1.6 Add party_state property and state transition thresholds (desperate_threshold, cautious_threshold, emboldened_player_hp_threshold)
  - [x] 1.7 Add decision weight properties (weight_attack, weight_formation, weight_flee, weight_modifiers struct)

- [x] 2. Implement Formation System
  - [x] 2.1 Create `global.formation_database` in game controller with formation templates (line_3, wedge_5, circle_4, protective_3)
  - [x] 2.2 Implement `init_party(enemy_array, formation_template_key)` function to initialize party with enemies
  - [x] 2.3 Implement `assign_formation_roles()` function to assign roles and offsets to party members
  - [x] 2.4 Implement `get_formation_position(enemy_instance)` function to calculate target formation coordinates
  - [x] 2.5 Add procedural formation adjustment logic for when party size doesn't match template max_members
  - [x] 2.6 Test formation assignment and position calculation with different party sizes

- [x] 3. Implement Party State Machine
  - [x] 3.1 Implement `update_party_state()` function with state transition logic
  - [x] 3.2 Implement `get_party_survival_percentage()` helper function
  - [x] 3.3 Add Step event to party controller that calls `update_party_state()` each frame
  - [x] 3.4 Implement `transition_to_state(new_state)` function to handle state changes
  - [x] 3.5 Add audio feedback on state transitions (snd_party_aggressive, snd_party_cautious, snd_party_desperate, snd_party_retreat)
  - [x] 3.6 Test state transitions by simulating different party survival and player HP scenarios

- [x] 4. Implement Weighted Decision System
  - [x] 4.1 Add party_controller reference property to `obj_enemy_parent`
  - [x] 4.2 Add objective tracking properties to enemies (current_objective, objective_target_x, objective_target_y, formation_target_x, formation_target_y)
  - [x] 4.3 Implement `calculate_decision_weights(enemy_instance)` function in party controller
  - [x] 4.4 Integrate weight calculation into enemy Step event to set current objective
  - [x] 4.5 Modify enemy pathfinding logic to use objective_target_x/y instead of always targeting player
  - [x] 4.6 Implement flee behavior (calculate flee_target_x/y away from player)
  - [x] 4.7 Test weight modifiers respond correctly to party survival, player HP, enemy HP, and distance from formation
  - [x] 4.8 Verify enemies switch between attack/formation/flee objectives dynamically

- [x] 5. Implement Party Member Management
  - [x] 5.1 Implement `on_member_death(enemy_instance)` function to remove dead enemies from party_members array
  - [x] 5.2 Call `on_member_death()` from enemy death event when enemy belongs to a party
  - [x] 5.3 Implement formation reassignment when party size changes
  - [x] 5.4 Implement `on_leader_death()` virtual function (placeholder, can be overridden by child controllers)
  - [x] 5.5 Check if dead enemy is party leader and call `on_leader_death()` if true
  - [x] 5.6 Test party behavior adapts correctly as members are killed

- [x] 6. Implement Save/Load Integration
  - [x] 6.1 Implement `serialize_party_data()` function to return save struct
  - [x] 6.2 Implement `deserialize_party_data(data)` function to restore party from struct
  - [x] 6.3 Add UUID references to enemies for save/load linkage
  - [x] 6.4 Integrate party controller serialization into room save data in existing save system
  - [x] 6.5 Test saving and loading a room with active party controllers, verify state and members persist correctly

- [x] 7. Implement Debug Visualization
  - [x] 7.1 Add Draw event to `obj_enemy_party_controller`
  - [x] 7.2 Draw formation positions (circles) and lines connecting enemies to their formation targets when `global.debug_mode == true`
  - [x] 7.3 Draw party state text and member count above controller position
  - [x] 7.4 Draw protection radius circle when in protecting state
  - [x] 7.5 Test debug visualization displays correctly for different party states and formations

- [x] 8. Create Example Party Controllers and Test Scenarios
  - [x] 8.1 Create child object `obj_orc_raiding_party` inheriting from `obj_enemy_party_controller` with aggressive configuration
  - [x] 8.2 Create child object `obj_gate_guard_party` inheriting from `obj_enemy_party_controller` with protecting configuration
  - [x] 8.3 Place test parties in a test room with various enemy types and formations
  - [x] 8.4 Test aggressive party behavior (chase and attack player)
  - [x] 8.5 Test protecting party behavior (guard location, limited pursuit)
  - [x] 8.6 Test state transitions (cautious after casualties, desperate with few survivors, emboldened when player is weak)
  - [x] 8.7 Test mixed enemy type parties (melee and ranged in same party)
  - [x] 8.8 Verify all major features work end-to-end (formations, weights, states, save/load, audio, debug viz)
