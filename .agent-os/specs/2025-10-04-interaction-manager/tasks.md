# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-04-interaction-manager/spec.md

> Created: 2025-10-04
> Status: Ready for Implementation

## Tasks

- [ ] 1. Create Interactive Object Parent and Base Infrastructure
  - [ ] 1.1 Create obj_interactable_parent with required properties (interaction_radius, interaction_priority, interaction_key, interaction_action)
  - [ ] 1.2 Implement can_interact() stub method in obj_interactable_parent
  - [ ] 1.3 Implement on_interact() stub method in obj_interactable_parent
  - [ ] 1.4 Create obj_interaction_manager singleton object
  - [ ] 1.5 Add manager initialization in obj_game_controller Create event
  - [ ] 1.6 Implement object query and priority scoring logic in manager Step event
  - [ ] 1.7 Store selected object in global.active_interactive
  - [ ] 1.8 Test manager detects and selects nearest object correctly

- [ ] 2. Refactor Container System (Chests, Barrels, Crates)
  - [ ] 2.1 Update obj_openable to inherit from obj_interactable_parent
  - [ ] 2.2 Set interaction_priority = 50 in obj_openable Create event
  - [ ] 2.3 Set interaction_action = "Open" in obj_openable Create event
  - [ ] 2.4 Implement can_interact() to return !is_opened
  - [ ] 2.5 Refactor on_interact() to call existing open_container() logic
  - [ ] 2.6 Remove direct keyboard_check_pressed(vk_space) from obj_openable Step event
  - [ ] 2.7 Update show_interaction_prompt() call to check global.active_interactive
  - [ ] 2.8 Test chest interaction with manager (single chest scenario)

- [ ] 3. Refactor Companion Interaction System
  - [ ] 3.1 Update obj_companion_parent to inherit from obj_interactable_parent (or add to inheritance chain)
  - [ ] 3.2 Set interaction_priority = 100 in obj_companion_parent Create event
  - [ ] 3.3 Set interaction_action based on recruitment state ("Recruit" or "Talk")
  - [ ] 3.4 Implement can_interact() method for companions
  - [ ] 3.5 Refactor on_interact() to handle recruitment and dialogue
  - [ ] 3.6 Remove direct SPACE key handling from companion Step event
  - [ ] 3.7 Update companion interaction prompts to check global.active_interactive
  - [ ] 3.8 Test companion interaction with manager

- [ ] 4. Update Interaction Prompt System
  - [ ] 4.1 Modify show_interaction_prompt() in scr_ui_functions.gml to check global.active_interactive
  - [ ] 4.2 Only create/update prompt if calling object is the active interactive
  - [ ] 4.3 Destroy existing prompts when object is no longer active
  - [ ] 4.4 Test prompt appears only on selected object
  - [ ] 4.5 Verify prompt switches correctly when player moves between objects

- [ ] 5. Integration Testing and Priority Validation
  - [ ] 5.1 Test companion + chest scenario (companion should have priority)
  - [ ] 5.2 Test multiple chests (nearest should have priority)
  - [ ] 5.3 Test priority correctly uses distance as tiebreaker
  - [ ] 5.4 Test edge cases (player moving quickly, objects at same distance)
  - [ ] 5.5 Verify no input conflicts or double-interactions
  - [ ] 5.6 Test with existing game saves (backward compatibility)
  - [ ] 5.7 Performance check (no frame drops with many interactive objects)
  - [ ] 5.8 Final validation that all interactive objects work correctly
