# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-16-onboarding-quest-system/spec.md

> Created: 2025-10-16
> Status: Ready for Implementation

## Tasks

- [ ] 1. Initialize Onboarding Quest System Core Infrastructure
  - [ ] 1.1 Create global onboarding quest system initialization in obj_game_controller
  - [ ] 1.2 Define quest definition struct with all required fields (quest_id, display_text, trigger_type, trigger_condition, xp_reward, marker_location, completed)
  - [ ] 1.3 Create quest sequence array and store in global.onboarding_quests
  - [ ] 1.4 Write onboarding_check_trigger() function for detecting quest condition matches
  - [ ] 1.5 Write onboarding_complete_quest() function with XP reward and sound playback
  - [ ] 1.6 Write onboarding_advance_to_next_quest() helper function
  - [ ] 1.7 Write test cases for quest state transitions and trigger detection
  - [ ] 1.8 Verify all tests pass

- [ ] 2. Implement HUD Overlay Quest Display System
  - [ ] 2.1 Create or extend HUD draw code to display onboarding quest text
  - [ ] 2.2 Position quest text centered near top of screen (below health bars)
  - [ ] 2.3 Apply text formatting (sentence case, shadow effect, white text)
  - [ ] 2.4 Implement smooth fade-in/fade-out for quest text transitions
  - [ ] 2.5 Test HUD display updates correctly when quests resolve
  - [ ] 2.6 Verify text renders without pausing gameplay
  - [ ] 2.7 Write tests for HUD rendering and text positioning
  - [ ] 2.8 Verify all tests pass

- [ ] 3. Integrate Quest Trigger Detection Into Game Systems
  - [ ] 3.1 Add onboarding_check_trigger() hooks to input system (torch, dash, inventory, weapon swap)
  - [ ] 3.2 Add onboarding_check_trigger() hooks to interaction system (NPC dialogue, chest opening)
  - [ ] 3.3 Add onboarding_check_trigger() hooks to inventory system (item pickup, equipment changes)
  - [ ] 3.4 Add onboarding_check_trigger() hooks to combat system (attack execution, dash attack)
  - [ ] 3.5 Test each trigger type fires correctly in gameplay
  - [ ] 3.6 Verify triggers don't interfere with normal gameplay
  - [ ] 3.7 Write integration tests for trigger detection
  - [ ] 3.8 Verify all tests pass

- [ ] 4. Create Quest Marker System With Animation
  - [ ] 4.1 Create obj_onboarding_marker object with Create/Step/Draw events
  - [ ] 4.2 Implement animated sprite rendering with looping animation
  - [ ] 4.3 Implement on-screen marker display logic
  - [ ] 4.4 Implement off-screen arrow indicator pointing toward marker location
  - [ ] 4.5 Add marker destruction when associated quest completes
  - [ ] 4.6 Test marker spawning and animation
  - [ ] 4.7 Test marker removal on quest completion
  - [ ] 4.8 Verify all tests pass

- [ ] 5. Define Quest Sequence and Configure All 6-8 Onboarding Quests
  - [ ] 5.1 Create onboarding quest Yarn file (onboarding_quests.yarn) with all quest definitions
  - [ ] 5.2 Define "Light Torch" quest (T key press) with trigger and XP reward
  - [ ] 5.3 Define "Find Chest" quest (chest interaction) with marker location
  - [ ] 5.4 Define "Pick Up Weapon" quest (item pickup) with marker and XP
  - [ ] 5.5 Define "Talk to Canopy" quest (NPC interaction) with marker
  - [ ] 5.6 Define "Give Canopy Torch" quest (L key press) with XP
  - [ ] 5.7 Define "Dash Attack" quest (dash attack execution) with XP
  - [ ] 5.8 Define "Inventory & Weapon Swap" quest (I and Q keys) with completion check

- [ ] 6. Implement Save/Load Persistence
  - [ ] 6.1 Update obj_game_controller serialize() function to save onboarding quest state
  - [ ] 6.2 Update obj_game_controller deserialize() function to restore quest state on load
  - [ ] 6.3 Store active_quest_index and all_completed flags in save data
  - [ ] 6.4 Restore current quest display after load
  - [ ] 6.5 Test quest progress persists through save/load cycle
  - [ ] 6.6 Test mid-tutorial save preserves correct next quest
  - [ ] 6.7 Write persistence tests
  - [ ] 6.8 Verify all tests pass

- [ ] 7. Create Sound Assets and Implement Audio Feedback
  - [ ] 7.1 Create snd_onboarding_quest_available sound effect (short positive chime, ~0.3-0.5s)
  - [ ] 7.2 Create snd_onboarding_quest_resolved sound effect (completion tone, ~0.3-0.5s)
  - [ ] 7.3 Add sound assets to GameMaker project
  - [ ] 7.4 Test quest available sound plays when new quest displays
  - [ ] 7.5 Test quest resolved sound plays when quest completes
  - [ ] 7.6 Verify sounds use existing play_sfx() system
  - [ ] 7.7 Write audio feedback tests
  - [ ] 7.8 Verify all tests pass

- [ ] 8. Polish and Final Integration Testing
  - [ ] 8.1 Playtest complete quest sequence from start to finish
  - [ ] 8.2 Verify XP rewards display as floating text and add to player total
  - [ ] 8.3 Test quest markers animate and point to correct locations
  - [ ] 8.4 Verify off-screen arrow indicators work correctly
  - [ ] 8.5 Test complete quest sequence completes without errors
  - [ ] 8.6 Verify onboarding doesn't repeat after completion
  - [ ] 8.7 Test game saves/loads mid-tutorial correctly
  - [ ] 8.8 Final verification: all systems integrated and functioning
