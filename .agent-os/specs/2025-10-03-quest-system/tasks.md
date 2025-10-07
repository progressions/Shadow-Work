# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-03-quest-system/spec.md

> Created: 2025-10-03
> Status: IMPLEMENTATION COMPLETE

## Tasks

- [x] 1. Quest Database and Core Data Structures
  - [x] 1.1 Create `scripts/scr_quest_system/scr_quest_system.gml` script file
  - [x] 1.2 Define `global.quest_database` struct with quest definition schema (quest_id, quest_name, quest_giver, objectives, rewards, prerequisites, completion_flag, requires_turnin, turnin_npc, chain_next)
  - [x] 1.3 Define objective struct schema with types: kill, collect, deliver, location, spawn_kill
  - [x] 1.4 Define rewards struct schema (affinity_rewards, item_rewards, gold_reward)
  - [x] 1.5 Add `ItemType.quest_item` to ItemType enum in `scripts/scripts.gml`
  - [x] 1.6 Add 2-3 sample quest definitions to `global.quest_database` for testing
  - [x] 1.7 Verify quest database initializes correctly and data structure is accessible

- [x] 2. Player Quest Tracking and Helper Functions
  - [x] 2.1 Add `active_quests` struct to `obj_player` Create event
  - [x] 2.2 Implement `quest_accept(quest_id)` function to add quest to active_quests and trigger feedback
  - [x] 2.3 Implement `quest_update_progress(quest_id, objective_index, amount)` to increment progress and check completion
  - [x] 2.4 Implement `quest_complete(quest_id)` to grant rewards, set flags, and unlock chain quests
  - [x] 2.5 Implement `quest_check_objectives(quest_id)` to verify all objectives are met
  - [x] 2.6 Implement `quest_is_active(quest_id)`, `quest_is_complete(quest_id)`, and `quest_can_accept(quest_id)` helper functions
  - [x] 2.7 Test quest acceptance and completion flow with sample quest
  - [x] 2.8 Verify quest state persistence and progression tracking works correctly

- [x] 3. Objective Progress Tracking Systems
  - [x] 3.1 Test objective progress by manually triggering each type in-game
  - [x] 3.2 Hook into `obj_enemy_parent` destroy event for kill objective tracking (both object-based and trait-based)
  - [x] 3.3 Modify `inventory_add_item()` to detect quest item pickup and update collect objectives
  - [x] 3.4 Create `obj_quest_marker` parent object with quest_id, marker_type variables and collision detection
  - [x] 3.5 Add location objective completion in `obj_player` collision with `obj_quest_marker`
  - [x] 3.6 Implement `spawn_quest_enemy(enemy_object, x, y, room, quest_id)` function for spawn_kill objectives
  - [x] 3.7 Add deliver objective detection in `obj_player` collision with delivery target NPCs
  - [x] 3.8 Verify all five objective types (kill, collect, deliver, location, spawn_kill) track progress correctly

- [x] 4. Quest Items and Inventory Integration
  - [x] 4.1 Create 2-3 sample quest items in `global.item_database` with type `ItemType.quest_item` and quest_id property
  - [x] 4.2 Modify `inventory_remove_item()` to prevent removing quest items (return false with message)
  - [x] 4.3 Update `quest_complete()` to automatically remove quest items from inventory unless they're reward items
  - [x] 4.4 Add quest item dropping logic for enemies killed in spawn_kill objectives
  - [x] 4.5 Verify quest items appear in inventory, cannot be dropped/removed, and are removed on quest completion

- [x] 5. Quest Rewards and Chain Unlocking
  - [x] 5.1 Implement affinity rewards loop in `quest_complete()` to find companion instances and add affinity
  - [x] 5.2 Implement item rewards loop in `quest_complete()` to add items to player inventory
  - [x] 5.3 Add global completion flag setting logic: `global[quest.completion_flag] = true`
  - [x] 5.4 Implement chain quest unlocking logic when `chain_next` is defined
  - [x] 5.5 Create 2-quest chain for testing (quest A unlocks quest B on completion)
  - [x] 5.6 Verify rewards are granted correctly and quest chains unlock in proper sequence

- [x] 6. Visual and Audio Feedback
  - [x] 6.1 Create `snd_quest_accept`, `snd_quest_progress`, and `snd_quest_complete` sound effect placeholders
  - [x] 6.2 Implement `show_quest_notification(type, message)` function with fade in/out animation
  - [x] 6.3 Add notification display using existing game font and UI styling
  - [x] 6.4 Integrate sound effects into `quest_accept()`, `quest_update_progress()`, and `quest_complete()`
  - [x] 6.5 Create visual quest marker sprite (exclamation mark or quest icon) for `obj_quest_marker`
  - [x] 6.6 Add marker visibility logic to only show when associated quest is active
  - [x] 6.7 Verify notifications appear correctly and sounds play for quest events

- [x] 7. Yarn Dialogue Integration
  - [x] 7.1 Implement `yarn_command_quest_offer(quest_id)` command handler
  - [x] 7.2 Add prerequisite checking in quest_offer handler using `quest_can_accept()`
  - [x] 7.3 Add quest acceptance dialogue option triggering and `quest_accept()` call
  - [x] 7.4 Implement Yarn condition functions: `quest_active(quest_id)` and `quest_complete(quest_id)`
  - [x] 7.5 Create test Yarn dialogue file with `<<quest_offer>>` command and conditional branches
  - [x] 7.6 Test quest offering through NPC dialogue with prerequisites and acceptance flow
  - [x] 7.7 Verify dialogue correctly responds to quest state (not started, active, complete)
