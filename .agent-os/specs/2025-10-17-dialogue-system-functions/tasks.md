# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-17-dialogue-system-functions/spec.md

> Created: 2025-10-17
> Status: Ready for Implementation

## Tasks

- [ ] 1. Implement Inventory Query and Modification Functions
  - [ ] 1.1 Add `has_item(item_id, quantity)` function to Chatterbox registration in obj_game_controller/Create_0.gml
  - [ ] 1.2 Add `inventory_count(item_id)` function to Chatterbox registration
  - [ ] 1.3 Add `give_item(item_id, quantity)` function to Chatterbox registration
  - [ ] 1.4 Add `remove_item(item_id, quantity)` function to Chatterbox registration
  - [ ] 1.5 Test all inventory functions in a test Yarn file with various item IDs and quantities
  - [ ] 1.6 Verify error handling when invalid item IDs are used

- [ ] 2. Implement Affinity Query Functions
  - [ ] 2.1 Create `get_companion_by_name(companion_name)` helper function in scr_companion_system.gml if not already exists
  - [ ] 2.2 Add `get_affinity(companion_name)` function to Chatterbox registration in obj_game_controller/Create_0.gml
  - [ ] 2.3 Test affinity function with all three companions (Canopy, Hola, Yorna)
  - [ ] 2.4 Verify function returns 0 for non-recruited or invalid companion names

- [ ] 3. Implement Quest Progress Query Functions
  - [ ] 3.1 Add `quest_objective_complete(quest_id, objective_index)` function to scr_quest_system.gml
  - [ ] 3.2 Add `quest_objective_progress(quest_id, objective_index)` function to scr_quest_system.gml
  - [ ] 3.3 Register both quest progress functions with Chatterbox in obj_game_controller/Create_0.gml
  - [ ] 3.4 Test quest progress functions with an active quest containing multiple objectives
  - [ ] 3.5 Verify functions handle invalid quest IDs and objective indices gracefully

- [ ] 4. Create Example Yarn Dialogue Files
  - [ ] 4.1 Create example merchant dialogue file demonstrating inventory functions (datafiles/example_merchant.yarn)
  - [ ] 4.2 Create example companion affinity dialogue file demonstrating affinity-gated content (datafiles/example_affinity.yarn)
  - [ ] 4.3 Create example quest dialogue file demonstrating progress checks (datafiles/example_quest.yarn)
  - [ ] 4.4 Test each example file in-game to verify all functions work correctly

- [ ] 5. Create VN Content Creation Skill
  - [ ] 5.1 Create skill file at .claude/skills/vn-content.md
  - [ ] 5.2 Implement content type selection workflow (companion/quest/NPC/intro)
  - [ ] 5.3 Add Yarn template generation for each content type with proper function usage
  - [ ] 5.4 Add GML integration code generation for each content type
  - [ ] 5.5 Add asset requirement documentation (sprites, videos, naming conventions)
  - [ ] 5.6 Add testing checklist to skill output
  - [ ] 5.7 Test skill by invoking /vn-content and creating a sample NPC dialogue
  - [ ] 5.8 Verify generated code is syntactically correct and works without modification

- [ ] 6. Documentation and Integration
  - [ ] 6.1 Update CLAUDE.md with new dialogue function documentation and examples
  - [ ] 6.2 Add section to QUEST_SYSTEM.md documenting the new quest progress functions
  - [ ] 6.3 Create or update VN_SYSTEM.md with complete Chatterbox function reference
  - [ ] 6.4 Add usage examples to documentation showing all new functions in context
  - [ ] 6.5 Verify all documentation cross-references are correct
