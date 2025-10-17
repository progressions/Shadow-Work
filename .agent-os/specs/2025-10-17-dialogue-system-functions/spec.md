# Spec Requirements Document

> Spec: Dialogue System Functions for Inventory, Affinity, and Quest Progress
> Created: 2025-10-17

## Overview

Implement custom Chatterbox functions that enable Yarn dialogue files to query and modify inventory items, companion affinity levels, and quest progress states. Additionally, create a Claude Code skill that guides content creators through adding new VN dialogue content using these functions. This will allow dialogue trees to dynamically respond to player state, create meaningful choices with gameplay consequences, and integrate quest rewards and item trading directly into conversations.

## User Stories

### Dynamic Dialogue Based on Player Inventory

As a dialogue designer, I want to check if the player has specific items in their inventory, so that I can create conditional dialogue branches and trading sequences that respond to what the player is carrying.

When designing companion or NPC dialogue, the writer can use functions like `has_item("healing_herbs", 3)` to show or hide dialogue options based on inventory contents. For example, a healing dialogue option only appears if the player has the required herbs, or a quest giver acknowledges the player already has a quest item.

### Affinity-Gated Dialogue Content

As a narrative designer, I want to query companion affinity levels in dialogue, so that I can unlock deeper personal conversations, romance options, and special events at appropriate relationship milestones.

Dialogue trees can use `get_affinity("Canopy")` to check relationship progress and conditionally display options like backstory reveals at affinity 5+, training offers at 3+, and romance conversations at 8+. This creates a sense of relationship progression and rewards players for investing in companion relationships.

### Quest Progress Feedback in Conversations

As a quest designer, I want to query specific objective completion states in dialogue, so that NPCs can provide contextual feedback about ongoing quests and offer completion rewards when appropriate.

Quest givers can use `quest_progress("quest_id", 0)` and `objective_complete("quest_id", 0)` to give specific feedback like "You've defeated 3 out of 5 enemies" or unlock quest completion dialogue only when all objectives are met, making the world feel more responsive to player actions.

### Streamlined VN Content Creation

As a content creator, I want a guided workflow for adding new VN dialogue that leverages all the new dialogue functions, so that I can quickly create companion conversations, quest dialogues, NPC interactions, and environmental story sequences without memorizing syntax or forgetting integration steps.

The VN content skill walks the creator through the entire process: choosing content type (companion dialogue, quest dialogue, NPC, or VN intro), gathering requirements, generating Yarn file templates with proper function usage, creating necessary sprites/videos, and integrating with game objects. For example, when creating a new merchant NPC, the skill generates a Yarn template with inventory checks, guides portrait sprite creation, and provides the object code to trigger the dialogue.

## Spec Scope

1. **Inventory Query Functions** - Functions to check item presence and quantity in player inventory (`has_item`, `inventory_count`)
2. **Inventory Modification Functions** - Functions to add and remove items with quantity support (`give_item`, `remove_item`)
3. **Affinity Query Functions** - Function to retrieve companion affinity level by name (`get_affinity`)
4. **Quest Progress Query Functions** - Functions to check objective completion and progress counts (`objective_complete`, `quest_progress`)
5. **Chatterbox Function Registration** - Register all functions in obj_game_controller for use in Yarn files
6. **VN Content Creation Skill** - Claude Code skill that guides through creating companion dialogue, quest dialogues, NPC interactions, and VN intro sequences with proper Yarn templates and integration code

## Out of Scope

- Player stat modifications (health, XP, level) - these should remain in game code
- Complex inventory operations (sorting, filtering, stacking logic)
- Affinity modification from dialogue (affinity changes should come from quest completion and gameplay events)
- Quest acceptance/completion (already implemented via existing quest functions)
- Save/load integration (Chatterbox variables already handle this)

## Expected Deliverable

1. All inventory, affinity, and quest progress functions are registered with Chatterbox and usable in Yarn files
2. Yarn dialogue can successfully query inventory contents and conditionally display options based on item presence
3. Dialogue trees can check companion affinity levels and unlock content at appropriate thresholds
4. Quest dialogue can display specific progress feedback (e.g., "3/5 enemies defeated") using the new functions
5. VN content creation skill is available via `/vn-content` command and successfully guides through creating new dialogue content with proper templates and integration
