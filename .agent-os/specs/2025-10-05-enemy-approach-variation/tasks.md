# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-05-enemy-approach-variation/spec.md

> Created: 2025-10-05
> Status: Ready for Implementation

## Tasks

- [x] 1. Add Approach Variation Variables to Enemy Parent
  - [x] 1.1 Add approach_mode variable (default: "direct") to obj_enemy_parent Create event
  - [x] 1.2 Add approach_chosen boolean (default: false) to track if angle selected
  - [x] 1.3 Add flank_offset_angle variable (default: 0) to store perpendicular offset
  - [x] 1.4 Add flank_trigger_distance variable (default: 120) for detection range
  - [x] 1.5 Add flank_chance variable (default: 0.4) for flanking probability
  - [x] 1.6 Test variables initialize correctly on enemy spawn

- [x] 2. Implement Approach Angle Selection Logic
  - [x] 2.1 Add distance check to player in obj_enemy_parent Step event
  - [x] 2.2 Implement approach selection when entering flank_trigger_distance
  - [x] 2.3 Add random chance check for flanking vs direct approach
  - [x] 2.4 Choose perpendicular offset (+90 or -90 degrees) for flanking mode
  - [x] 2.5 Set approach_chosen flag to prevent re-selection
  - [x] 2.6 Test enemies select approach mode when entering trigger range

- [x] 3. Modify Target Position Calculation with Flanking Offset
  - [x] 3.1 Calculate base direction to player from enemy position
  - [x] 3.2 Apply flank_offset_angle to base direction when in flanking mode
  - [x] 3.3 Calculate target_x and target_y at approach angle with offset distance
  - [x] 3.4 Integrate with existing pathfinding to calculated target position
  - [x] 3.5 Test flanking enemies move perpendicular to direct path
  - [x] 3.6 Test direct approach enemies move straight toward player

- [x] 4. Add Approach Reset and Enemy Type Configuration
  - [x] 4.1 Reset approach variables when enemy loses aggro or changes state
  - [x] 4.2 Add state transition check in enemy state machine
  - [x] 4.3 Configure flank_chance for specific enemy types (obj_orc, obj_burglar, etc.)
  - [x] 4.4 Configure flank_trigger_distance per enemy type as needed
  - [x] 4.5 (Optional) Add debug visualization for approach angles
  - [x] 4.6 Test approach resets correctly on state changes
  - [x] 4.7 Test enemy-specific flanking behavior variations
  - [x] 4.8 Final integration testing with spawner combat scenarios
