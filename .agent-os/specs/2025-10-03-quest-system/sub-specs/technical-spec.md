# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-03-quest-system/spec.md

> Created: 2025-10-03
> Version: 1.0.0

## Technical Requirements

### Quest Database Structure

- Create `scripts/scr_quest_system/scr_quest_system.gml` script file
- Define `global.quest_database` as a struct with quest definitions keyed by quest_id strings
- Each quest definition contains:
  - `quest_id`: string - Unique identifier for the quest
  - `quest_name`: string - Display name for the quest
  - `quest_giver`: string - Object name or companion ID that gives the quest
  - `objectives`: array of objective structs (see below)
  - `rewards`: struct containing reward data (see below)
  - `prerequisites`: array of quest_id strings that must be completed first (empty array if none)
  - `completion_flag`: string - Global flag name set to true when quest completes
  - `requires_turnin`: bool - Whether quest needs manual NPC turn-in (default false)
  - `turnin_npc`: string - Object name of NPC for turn-in (if requires_turnin is true)
  - `chain_next`: string or undefined - quest_id of next quest in chain (if part of a chain)

### Objective Types Structure

Each objective in the `objectives` array is a struct with:
- `type`: string - One of: "kill", "collect", "deliver", "location", "spawn_kill"
- `target`: string - Enemy object name, item key, location object name, or trait tag
- `count`: real - Number required (for kill/collect objectives)
- `current`: real - Current progress (initialized to 0, tracked at runtime)
- `use_trait`: bool - If true for kill objectives, match enemies by trait tag instead of object type
- `spawn_locations`: array of {x, y, room} structs for spawn_kill objectives
- `delivery_target`: string - NPC object name or location object for deliver objectives

### Player Quest Tracking

- Add `active_quests` struct to `obj_player` Create event
- Structure: `active_quests[quest_id] = quest_data_copy`
- Quest data copy includes all quest definition fields plus runtime progress
- Add helper functions in quest system script:
  - `quest_accept(quest_id)` - Add quest to player's active_quests, trigger acceptance feedback
  - `quest_update_progress(quest_id, objective_index, amount)` - Increment objective progress, check completion
  - `quest_complete(quest_id)` - Grant rewards, set completion flag, unlock chain quest if exists
  - `quest_check_objectives(quest_id)` - Return true if all objectives met
  - `quest_is_active(quest_id)` - Check if quest in active_quests
  - `quest_is_complete(quest_id)` - Check if completion flag is set
  - `quest_can_accept(quest_id)` - Check if prerequisites are met

### Quest Item Integration

- Add `ItemType.quest_item` to ItemType enum in `scripts/scripts.gml`
- Modify `inventory_remove_item()` function to prevent removing quest items (return false)
- Quest items are defined in `global.item_database` with `type: ItemType.quest_item`
- Add `quest_id` property to quest item definitions to link item to specific quest
- Quest items automatically removed from inventory when quest completes (unless reward item)

### Objective Progress Tracking

**Kill Objectives:**
- Hook into enemy death events (when `obj_enemy_parent` is destroyed)
- Check all active quests with "kill" objectives
- If `use_trait` is true, check if enemy has matching trait tag using existing trait system
- If `use_trait` is false, check if enemy object_index matches target object
- Increment objective progress and call `quest_update_progress()`

**Collect Objectives:**
- Quest items dropped by enemies should reference quest_id
- Hook into `inventory_add_item()` to detect quest item pickup
- Find active quest matching item's quest_id
- Increment collect objective progress for that item

**Deliver Objectives:**
- Create collision event in `obj_player` with delivery target objects
- Check if player has required quest item in inventory
- If quest with delivery objective is active and item present, complete objective

**Location Objectives:**
- Create `obj_quest_marker` parent object with `quest_id` variable
- Create collision event in `obj_player` with `obj_quest_marker`
- Check if colliding marker's quest_id matches active quest
- Complete location objective on collision

**Spawn Kill Objectives:**
- When quest is accepted with spawn_kill objective, spawn enemies at specified locations
- Tag spawned enemies with `quest_enemy = true` and `quest_id = [quest_id]`
- Track kills same as kill objectives but check for quest_enemy tag match

### Quest Rewards System

Rewards struct in quest definition contains:
- `affinity_rewards`: array of {companion_id: string, amount: real} - Affinity increases for companions
- `item_rewards`: array of item_key strings - Items to add to player inventory
- `gold_reward`: real - Gold amount (optional, for future currency system)

When quest completes:
- Loop through affinity_rewards, find companion instances, add to their affinity value
- Loop through item_rewards, call `inventory_add_item()` for each
- Set global completion flag: `global[quest.completion_flag] = true`
- If quest has `chain_next`, check if next quest prerequisites met and make available

### Visual and Audio Feedback

- Define three new sound effects:
  - `snd_quest_accept` - Played when quest is accepted
  - `snd_quest_progress` - Played when objective progress updates
  - `snd_quest_complete` - Played when quest completes
- Create visual feedback function `show_quest_notification(type, message)`:
  - `type`: "accept", "progress", "complete"
  - Display temporary text overlay on screen (fade in/out animation)
  - Play corresponding sound effect
  - Text should use existing game font and UI styling

### Yarn Dialogue Integration

- Quest acceptance is handled through Yarn dialogue nodes
- Yarn files will use custom command: `<<quest_offer [quest_id]>>`
- Implement Yarn command handler `yarn_command_quest_offer(quest_id)`:
  - Check if quest prerequisites met using `quest_can_accept(quest_id)`
  - If met, enable "Accept Quest" dialogue option
  - When player selects accept option, call `quest_accept(quest_id)`
- Yarn dialogue nodes should check quest states using: `<<if quest_active("quest_id")>>` or `<<if quest_complete("quest_id")>>`

### Quest Marker Objects

- Create `obj_quest_marker` parent object with:
  - `quest_id` variable (set in editor or Create event)
  - `marker_type` variable: "location", "delivery", "turnin"
  - Visible sprite with quest icon (exclamation mark or similar)
  - Collision event with `obj_player` to handle objective completion
- Inherit from `obj_quest_marker` for specific quest objectives as needed
- Marker should only be visible when associated quest is active

### Quest Enemy Spawning

- Create helper function `spawn_quest_enemy(enemy_object, x, y, room, quest_id)`:
  - Create enemy instance at specified location
  - Set `quest_enemy = true` and `quest_id` variables on enemy
  - Add quest marker or visual indicator above enemy (optional)
  - Enemy drops quest items if defined in quest objective
- Spawned enemies persist in room until killed
- If player leaves and returns to room, enemies remain (use persistent objects)

## Approach

The quest system will be implemented as a modular, data-driven system that integrates seamlessly with existing game systems:

1. **Central Quest Database**: All quest definitions stored in `global.quest_database` for easy authoring and maintenance
2. **Event-Driven Progress**: Quest objectives automatically track progress by hooking into existing game events (enemy deaths, item pickup, collisions)
3. **Yarn Integration**: Quest flow controlled through existing dialogue system using custom commands
4. **Companion Rewards**: Quest completion directly impacts companion affinity using existing affinity system
5. **Item-Based Quests**: Leverages existing inventory system with new quest_item type for special quest items
6. **Trait-Based Targeting**: Uses existing enemy trait system for flexible kill objectives (e.g., "kill 5 bandits" matches any enemy with "bandit" trait)

## External Dependencies

No new external dependencies required. The quest system uses existing GameMaker Studio 2 features and integrates with:
- Existing item/inventory system
- Existing companion affinity system
- Existing Yarn dialogue integration
- Existing trait system for enemy tagging
- Existing sound effect playback system
